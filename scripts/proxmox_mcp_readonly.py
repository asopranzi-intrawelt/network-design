"""Expose only reviewed GET tools from the pinned Proxmox MCP package."""

from __future__ import annotations

import hashlib
from importlib.util import find_spec
from importlib import metadata
from pathlib import Path


SAFE_TOOLS = frozenset(
    {
        "list_nodes",
        "list_lxc_containers",
        "list_vms",
        "get_instance_config",
        "get_lxc_interfaces",
        "list_storage",
        "list_storage_content",
        "get_task_status",
        "get_task_log",
        "get_resource_usage",
    }
)

# The complete reviewed Python source tree of 0.1.0, including modules that
# register excluded tools. A changed file or added module fails closed.
EXPECTED_SOURCE_COUNT = 19
EXPECTED_SOURCE_SHA256 = "b7f321ac3bf88c33bbbe80bc25c79d5b7aa01872353a00bec987435152acb977"


def verify_package() -> None:
    if metadata.version("proxmox-mcp") != "0.1.0":
        raise RuntimeError("Versione proxmox-mcp non approvata")
    # Locate files without importing the package: a tampered __init__ must not
    # execute before the source digest has been checked.
    spec = find_spec("proxmox_mcp")
    if spec is None or spec.origin is None or Path(spec.origin).name != "__init__.py":
        raise RuntimeError("Pacchetto proxmox-mcp non individuabile")
    package_root = Path(spec.origin).parent
    sources = sorted(package_root.rglob("*.py"))
    digest = hashlib.sha256()
    for source in sources:
        digest.update(source.relative_to(package_root).as_posix().encode())
        digest.update(b"\0")
        digest.update(source.read_bytes())
        digest.update(b"\0")
    if len(sources) != EXPECTED_SOURCE_COUNT or digest.hexdigest() != EXPECTED_SOURCE_SHA256:
        raise RuntimeError("Codice proxmox-mcp diverso dalla baseline")


def configure_readonly() -> object:
    verify_package()
    from proxmox_mcp import server, tools

    # The upstream wheel omits config/safety_policy.json. Inject the reviewed
    # read-only list into the in-memory policy used by its safety decorator.
    tools.SAFETY_POLICY.clear()
    tools.SAFETY_POLICY.update({"safe_tools": sorted(SAFE_TOOLS), "safe_command_patterns": []})
    tools.PROXMOX_ALLOW_DANGER = False

    manager = server.mcp._tool_manager
    registered = manager._tools
    if not isinstance(registered, dict) or not SAFE_TOOLS <= registered.keys():
        raise RuntimeError("Catalogo MCP incompatibile; nessun server avviato")
    manager._tools = {name: registered[name] for name in SAFE_TOOLS}
    if set(manager._tools) != SAFE_TOOLS:
        raise RuntimeError("Filtro MCP incompleto; nessun server avviato")
    return server.mcp


def main() -> None:
    configure_readonly().run()


if __name__ == "__main__":
    main()
