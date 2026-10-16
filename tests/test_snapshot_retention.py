"""Prove della cancellazione su directory isolate, senza API, task o dati reali."""
from pathlib import Path
import hashlib
import json
import os
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
SHELL = Path(os.environ.get('SystemRoot', 'C:/Windows')) / 'System32/WindowsPowerShell/v1.0/powershell.exe'


@unittest.skipUnless(SHELL.is_file(), 'Richiede Windows PowerShell 5.1')
class SnapshotRetention(unittest.TestCase):
    SOURCE = ROOT / 'scripts/Invoke-SnapshotRetention.ps1'
    def setUp(self):
        parent = ROOT / '_notes' / 'retention-fixtures'
        parent.mkdir(parents=True, exist_ok=True)
        self.temp = tempfile.TemporaryDirectory(prefix='case-', dir=parent)
        self.root = Path(self.temp.name).resolve()
        assert self.root.is_relative_to(parent.resolve())
        self.addCleanup(self.temp.cleanup)
        (self.root / 'scripts').mkdir()
        (self.root / '_notes').mkdir()
        (self.root / 'output').mkdir()
        (self.root / '.gitignore').write_text('output/\n_notes/\n', encoding='utf-8')
        subprocess.run(['git', 'init', '--quiet', str(self.root)], check=True, capture_output=True)
        self.script = self.root / 'scripts/Invoke-SnapshotRetention.ps1'
        self.script.write_bytes(self.SOURCE.read_bytes())
        self.output = self.root / 'output'
        self.pinfile = self.root / '_notes/snapshot-retention-pins.json'
        self.pinfile.write_text('{"version":1,"files":[]}', encoding='utf-8')
        self.make('proxmox-snapshot.json', {'nodes': [{}], 'resources': [{}]})
        self.make('nebula-snapshot.json', {'organizations': [{'id': 'test'}]})
        self.old = self.make('proxmox-20260101-073000.json', {'sample': 'old'})
        self.recent = self.make('proxmox-20261010-073000.json', {'sample': 'recent'})
        self.latest = self.make('proxmox-20261016-073000.json', {'sample': 'latest'})
        self.boundary = self.make('proxmox-20260719-000000.json', {'sample': 'boundary'})
        self.outside = self.make('proxmox-20260718-235959.json', {'sample': 'expired'})

    def make(self, name, value):
        p = self.output / name
        p.write_text(json.dumps(value), encoding='utf-8')
        return p

    def run_policy(self, *args, ok=True):
        p = subprocess.run([str(SHELL), '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', str(self.script),
                            '-AsOf', '2026-10-16', *args], capture_output=True, text=True)
        if ok:
            self.assertEqual(p.returncode, 0, p.stdout + p.stderr)
            return json.loads(p.stdout)
        self.assertNotEqual(p.returncode, 0, p.stdout + p.stderr)
        return p

    def test_plan_and_boundary_then_apply(self):
        before = {p.name: p.read_bytes() for p in self.output.iterdir()}
        result = self.run_policy()
        self.assertEqual(result['cutoff'], '2026-07-19')
        self.assertEqual(result['candidate_files'], 2)
        self.assertEqual({p.name: p.read_bytes() for p in self.output.iterdir()}, before)
        result = self.run_policy('-Apply')
        self.assertEqual(result['removed_files'], 2)
        self.assertFalse(self.old.exists())
        self.assertFalse(self.outside.exists())
        self.assertTrue(self.boundary.exists())
        self.assertTrue(self.recent.exists())
        self.assertTrue(self.latest.exists())
        self.assertTrue((self.output / 'proxmox-snapshot.json').exists())

    def test_pins_references_and_alias_content(self):
        self.pinfile.write_text(json.dumps({'version': 1, 'files': [{'name': self.old.name,
            'sha256': hashlib.sha256(self.old.read_bytes()).hexdigest()}]}), encoding='utf-8')
        (self.root / 'evidence.md').write_text(self.outside.name, encoding='utf-8')
        alias_copy = self.make('nebula-20260101-073000.json', {'organizations': [{'id': 'test'}]})
        self.make('nebula-20261016-073000.json', {'organizations': [{'id': 'new'}]})
        self.run_policy('-Apply')
        self.assertTrue(self.old.exists())
        self.assertTrue(self.outside.exists())
        self.assertTrue(alias_copy.exists())

    def test_latest_old_copy_and_unknown_files(self):
        last = self.make('nebula-snapshot-20260101-073000.json', {'sample': 'last'})
        arbitrary = self.make('audit-20260101-073000.json', {'sample': 'other'})
        folder = self.output / 'proxmox-20250101-073000.json'
        folder.mkdir()
        self.run_policy('-Apply')
        self.assertTrue(last.exists())
        self.assertTrue(arbitrary.exists())
        self.assertTrue(folder.is_dir())

    def test_invalid_json_preserved(self):
        self.old.write_text('broken-json', encoding='utf-8')
        result = self.run_policy('-Apply')
        self.assertTrue(self.old.exists())
        self.assertEqual(result['invalid_preserved'], 1)

    def test_changed_pin_refuses_before_any_delete(self):
        self.pinfile.write_text(json.dumps({'version': 1, 'files': [{'name': self.old.name, 'sha256': '0' * 64}]}), encoding='utf-8')
        self.run_policy('-Apply', ok=False)
        self.assertTrue(self.outside.exists())
        self.assertTrue(self.old.exists())

    def test_missing_alias_and_missing_pins_refuse_apply(self):
        (self.output / 'nebula-snapshot.json').unlink()
        self.run_policy('-Apply', ok=False)
        self.assertTrue(self.old.exists())
        self.make('nebula-snapshot.json', {'organizations': [{}]})
        self.pinfile.unlink()
        self.run_policy('-Apply', ok=False)
        self.assertTrue(self.old.exists())

    def test_invalid_alias_refuses_apply(self):
        self.make('proxmox-snapshot.json', {})
        self.run_policy('-Apply', ok=False)
        self.assertTrue(self.old.exists())

    def test_scheduled_plan_enable_then_apply(self):
        self.assertEqual(self.run_policy('-Scheduled')['mode'], 'plan')
        self.assertTrue(self.old.exists())
        self.assertEqual(self.run_policy('-EnableScheduled')['mode'], 'enable')
        self.assertTrue(self.old.exists())
        result = self.run_policy('-Scheduled')
        self.assertEqual(result['mode'], 'apply')
        self.assertFalse(self.old.exists())
        policy_path = self.root / '_notes/snapshot-retention-policy.json'
        policy = json.loads(policy_path.read_text(encoding='utf-8-sig'))
        policy['enabled'] = False
        policy_path.write_text(json.dumps(policy), encoding='utf-8')
        self.old = self.make(self.old.name, {'sample': 'restored fixture'})
        self.assertEqual(self.run_policy('-Scheduled')['mode'], 'plan')
        self.assertTrue(self.old.exists())

    def test_warning_does_not_authorize_early_deletion(self):
        result = self.run_policy('-WarningBytes', '1')
        self.assertTrue(result['warning'])
        self.assertTrue(self.recent.exists())

    def test_symlink_outside_and_drive_root_refused(self):
        # Junction di directory non richiede il privilegio Windows dei symlink file.
        outside = self.root / 'outside'
        outside.mkdir()
        junction = self.root / 'linked-output'
        helper = self.root / 'make-junction.ps1'
        helper.write_text('param([string]$Link,[string]$Target)\nNew-Item -ItemType Junction -Path $Link -Target $Target | Out-Null\n', encoding='utf-8')
        p = subprocess.run([str(SHELL), '-NoProfile', '-File', str(helper), '-Link', str(junction), '-Target', str(outside)], capture_output=True, text=True)
        self.assertEqual(p.returncode, 0, p.stdout + p.stderr)
        self.run_policy('-Apply', '-OutputDir', str(junction), ok=False)
        self.run_policy('-Apply', '-OutputDir', self.root.anchor, ok=False)
        self.assertTrue(self.old.exists())

    def test_refresh_success_failure_dryrun_and_retention_error(self):
        scripts = self.root / 'scripts'
        (scripts / 'Invoke-RefreshFonti.ps1').write_bytes((ROOT / 'scripts/Invoke-RefreshFonti.ps1').read_bytes())
        (scripts / 'Read-ProjectEnv.ps1').write_text("function Get-ProjectSecret([string]$Name,[string]$ProjectRoot) { if ($Name -eq 'PROXMOX_URL') { return 'https://192.0.2.1:8006' }; return 'fixture' }\n", encoding='utf-8')
        (scripts / 'Get-NebulaSnapshot.ps1').write_text("param($ApiKey,$OutputDir)\n'{\"organizations\":[{\"sites\":[{\"devices\":[{}]}]}]}' | Set-Content -LiteralPath (Join-Path $OutputDir 'nebula-snapshot.json')\n", encoding='utf-8')
        # La forma if produce un valore, poi il file: nessuna chiamata HTTP.
        (scripts / 'Get-ProxmoxSnapshot.ps1').write_text("param($ProxmoxHost,$Port,$OutputDir)\n$value=if ($env:RETENTION_FIXTURE_MODE -eq 'source-failure') { '{\"nodes\":[],\"resources\":[]}' } else { '{\"nodes\":[{}],\"resources\":[{}]}' }\n$value | Set-Content -LiteralPath (Join-Path $OutputDir 'proxmox-snapshot.json')\n", encoding='utf-8')
        self.script.write_text("param([switch]$Scheduled)\nSet-Content -LiteralPath (Join-Path (Split-Path -Parent $PSScriptRoot) '_notes/called') -Value 'yes'\nif ($env:RETENTION_FIXTURE_MODE -eq 'retention-error') { throw 'fixture retention error' }\n[ordered]@{mode='plan';candidate_files=0;removed_files=0;bytes_before=1;warning=($env:RETENTION_FIXTURE_MODE -eq 'budget-warning')} | ConvertTo-Json\n", encoding='utf-8')
        called = self.root / '_notes/called'
        for mode, extra, expected, invokes in [('normal', [], 0, True), ('source-failure', [], 1, False),
                                              ('normal', ['-DryRun'], 0, False), ('retention-error', [], 3, True),
                                              ('budget-warning', [], 3, True)]:
            with self.subTest(mode=mode, flags=extra):
                called.unlink(missing_ok=True)
                env = dict(os.environ, RETENTION_FIXTURE_MODE=mode)
                run = subprocess.run([str(SHELL), '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File',
                                      str(scripts / 'Invoke-RefreshFonti.ps1'), *extra], capture_output=True, text=True, env=env)
                self.assertEqual(run.returncode, expected, run.stdout + run.stderr)
                self.assertEqual(called.exists(), invokes)


if __name__ == '__main__':
    unittest.main()
