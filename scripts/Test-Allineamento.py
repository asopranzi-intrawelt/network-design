#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# Controllo di allineamento: dice quali affermazioni di questo progetto stanno
# invecchiando in silenzio. Attua ADR-026.
#
# PERCHE' ESISTE. Ogni correzione che in questo progetto e' rimasta e' venuta da un
# confronto deterministico fra un'affermazione scritta e una misura; tutto cio' che
# dipendeva da qualcuno che si ricordasse, e' fallito. Il 04/09/2026 sono state
# misurate tre obsolescenze insieme, e nessuna era una contraddizione: la copia fuori
# sede dei backup era ferma da sei settimane e nessun documento lo diceva, la scheda
# dello stack elencava cinque script su ventuno, e una pendenza dichiarava scaduta una
# cadenza che era invece rispettata. Nessuna di queste era visibile a un lettore
# attento: erano affermazioni vere che avevano smesso di esserlo.
#
# COSA CONTROLLA, in quattro famiglie e in ordine di resa misurata sulla storia del
# progetto. Le SCADENZE, cioe' le date scritte in prosa che nessuno guardava: erano
# sedici, e ogni incidente che ha fatto male era una di queste. La FRESCHEZZA delle
# fonti, cioe' l'eta' di ogni misura contro la cadenza dichiarata in
# .claude/rules/fonti-e-riallineamento.md. Gli INVARIANTI, cioe' i confronti meccanici
# fra cio' che i documenti affermano e cio' che sta davvero nel repository. E le
# ASSERZIONI UMANE, quelle che nessun programma puo' verificare e che ricevono percio'
# una validita' dichiarata: quando scade tornano come domanda, con la domanda gia'
# scritta e la persona a cui porla.
#
# COSA NON FA, ed e' deliberato. Non aggiorna niente e non decide niente, come
# Test-TopologyDrift.py: dice che un'affermazione e' scaduta, non la corregge. Non
# rinfresca gli snapshot: quello e' compito dell'attivita' pianificata di ADR-026, e
# tenerli separati significa che questo controllo resta leggibile, veloce e senza
# credenziali. Non blocca: e' rumoroso all'avvio e basta, per decisione dell'IT
# Manager del 04/09/2026. Ed esce con codice diverso da zero quando trova qualcosa,
# cosi' che un domani possa diventare bloccante senza riscriverlo.
#
# COSA NON STAMPA. Nessun valore reale. Legge la sola data di modifica dei file di
# output/, mai il loro contenuto, quindi nomi host, utenti e indirizzi non entrano mai
# nell'output nemmeno per errore. Il registro data/scadenze.json e' tracciato e passa
# il guard-rail dell'anonimizzazione insieme a tutto il resto.
#
# Uso:
#   python scripts/Test-Allineamento.py              report completo
#   python scripts/Test-Allineamento.py --silenzioso solo il verdetto finale
#   python scripts/Test-Allineamento.py --giorni 30  orizzonte delle scadenze da mostrare
#
# Codici di uscita: 0 allineato, 1 c'e' qualcosa di scaduto o arretrato,
# 2 non giudicabile (registro mancante o illeggibile).

import json
import os
import re
import subprocess
import sys
from datetime import date, datetime

RADICE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
REGISTRO = os.path.join(RADICE, 'data', 'scadenze.json')

# I colori si accendono solo se l'uscita e' un terminale vero. Questo controllo gira
# anche dentro un hook di avvio e dentro una pipe, dove le sequenze di colore non
# verrebbero interpretate e comparirebbero come spazzatura in mezzo al testo: un
# avviso illeggibile e' un avviso che non viene letto, che e' il difetto che questo
# script esiste per combattere.
ROSSO = GIALLO = VERDE = GRIGIO = FINE = ''
if sys.stdout.isatty():
    ROSSO, GIALLO, VERDE, GRIGIO, FINE = '\033[31m', '\033[33m', '\033[32m', '\033[90m', '\033[0m'
    if os.name == 'nt':
        try:
            import ctypes
            manico = ctypes.windll.kernel32.GetStdHandle(-11)
            modo = ctypes.c_uint32()
            ctypes.windll.kernel32.GetConsoleMode(manico, ctypes.byref(modo))
            ctypes.windll.kernel32.SetConsoleMode(manico, modo.value | 0x0004)
        except Exception:
            ROSSO = GIALLO = VERDE = GRIGIO = FINE = ''


def colora(testo, colore):
    return colore + testo + FINE if colore else testo


def percorso(rel):
    return os.path.join(RADICE, rel.replace('/', os.sep))


def leggi_json(rel):
    p = percorso(rel)
    if not os.path.exists(p):
        return None
    with open(p, encoding='utf-8-sig') as f:
        return json.load(f)


def giorni_da(iso):
    """Giorni trascorsi da una data ISO. None se non interpretabile."""
    if not iso:
        return None
    testo = str(iso).strip().replace('T', ' ')
    for formato in ('%Y-%m-%d %H:%M:%S', '%Y-%m-%d %H:%M', '%Y-%m-%d'):
        try:
            return (datetime.now() - datetime.strptime(testo[:len(datetime.now().strftime(formato))], formato)).days
        except ValueError:
            continue
    return None


def eta_file(rel):
    """Giorni dalla data di modifica di un file. None se il file non c'e'."""
    p = percorso(rel)
    if not os.path.exists(p):
        return None
    return (datetime.now() - datetime.fromtimestamp(os.path.getmtime(p))).days


def git(*argomenti):
    try:
        return subprocess.run(['git'] + list(argomenti), cwd=RADICE, capture_output=True,
                              text=True, encoding='utf-8', errors='replace').stdout.strip()
    except Exception:
        return ''


def solo_frontmatter(commit, rel):
    """Vero se quel commit, su quel file, ha toccato il solo campo `last-verified`.

    Serve al confronto del frontmatter: un commit di firma non e' una modifica della scheda,
    e contarlo come tale rende l'allineamento irraggiungibile. Si guardano le sole righe di
    diff, quindi un commit che aggiunge una riga di contenuto e ribumpa insieme conta come
    modifica di contenuto, che e' il verso prudente dell'errore.
    """
    diff = git('show', '--format=', '-U0', commit, '--', rel)
    if not diff:
        return False
    cambiate = [r for r in diff.split(chr(10))
                if (r.startswith('+') or r.startswith('-'))
                and not r.startswith('+++') and not r.startswith('---')]
    if not cambiate:
        return False
    return all(re.match(r'^[-+]last-verified:', r) for r in cambiate)


def ultima_modifica_di_contenuto(rel):
    """L'hash pieno del commit piu' recente che ha cambiato il contenuto del file.

    Risale la storia del solo file e salta i commit di firma. Si ferma al primo commit utile,
    quindi nel caso normale costa una o due invocazioni di git per scheda.
    """
    storia = [c for c in git('log', '--format=%H', '--', rel).split(chr(10)) if c]
    for commit in storia:
        if not solo_frontmatter(commit, rel):
            return commit
    # Ogni commit del file e' di firma: caso teorico (una scheda nata col solo frontmatter),
    # e in quel caso il piu' antico e' la sua nascita.
    return storia[-1] if storia else ''


class Esito(object):
    def __init__(self):
        self.righe = []
        self.problemi = 0
        self.controlli = 0

    def ok(self, testo):
        self.controlli += 1
        self.righe.append(('ok', testo))

    def avviso(self, testo):
        self.controlli += 1
        self.problemi += 1
        self.righe.append(('avviso', testo))

    def grave(self, testo):
        self.controlli += 1
        self.problemi += 1
        self.righe.append(('grave', testo))

    def nota(self, testo):
        self.righe.append(('nota', testo))


# ---------------------------------------------------------------------------
# 1. Scadenze
# ---------------------------------------------------------------------------
def controlla_scadenze(reg, esito, orizzonte):
    oggi = date.today()
    for voce in reg.get('scadenze', []):
        try:
            scad = datetime.strptime(voce['data'], '%Y-%m-%d').date()
        except (KeyError, ValueError):
            esito.grave("scadenza %s: data illeggibile nel registro" % voce.get('id', '?'))
            continue
        mancano = (scad - oggi).days
        preavviso = int(voce.get('preavviso_giorni', 30))
        etichetta = "%s  %s" % (voce['data'], voce.get('cosa', voce.get('id', '')))
        if mancano < 0:
            esito.grave("SCADUTA da %d giorni  %s" % (-mancano, etichetta))
            esito.nota("      rompe: %s" % voce.get('rompe', ''))
            esito.nota("      dove:  %s" % voce.get('dove', ''))
        elif mancano <= preavviso:
            esito.avviso("fra %d giorni  %s" % (mancano, etichetta))
            esito.nota("      rompe: %s" % voce.get('rompe', ''))
            esito.nota("      dove:  %s" % voce.get('dove', ''))
        elif mancano <= orizzonte:
            esito.ok("fra %d giorni  %s" % (mancano, etichetta))
        else:
            esito.controlli += 1


# ---------------------------------------------------------------------------
# 2. Freschezza delle fonti
# ---------------------------------------------------------------------------
def controlla_freschezza(reg, esito):
    # I marcatori di rinfresco fallito scritti da Invoke-RefreshFonti.ps1. Sono la
    # seconda delle tre guardie di ADR-026: un'automazione che fallisce in silenzio
    # produce fiducia mal riposta, che e' peggio dell'assenza di automazione. La misura
    # resta quella vecchia e la sua eta' compare qui sotto, ma il fatto che il rinfresco
    # non stia piu' funzionando va detto a parte, perche' l'eta' da sola non lo spiega.
    cartella = os.path.join(RADICE, 'output')
    if os.path.isdir(cartella):
        for nome in sorted(n for n in os.listdir(cartella) if n.startswith('.refresh-fallito-')):
            fonte = nome[len('.refresh-fallito-'):-len('.txt')] if nome.endswith('.txt') else nome
            eta = eta_file('output/' + nome)
            motivo = ''
            for riga in testo_di('output/' + nome).splitlines():
                if riga.startswith('Motivo:'):
                    motivo = riga.split(':', 1)[1].strip()
                    break
            esito.grave("RINFRESCO FALLITO da %s giorni  fonte %s" % (eta, fonte))
            esito.nota("      motivo: %s" % motivo)
            esito.nota("      la misura precedente non e' stata toccata: e' l'ultima buona")

    for voce in reg.get('freschezza', []):
        rel = voce.get('percorso', '')
        cadenza = int(voce.get('cadenza_giorni', 30))
        nome = voce.get('cosa', voce.get('id', rel))
        eta = None
        if voce.get('campo_data'):
            dati = None
            try:
                dati = leggi_json(rel)
            except Exception:
                dati = None
            if dati is not None:
                eta = giorni_da(dati.get(voce['campo_data']))
        if eta is None:
            eta = eta_file(rel)
        if eta is None:
            esito.grave("misura ASSENTE  %s  (%s)" % (nome, rel))
            continue
        if eta > cadenza * 2:
            esito.grave("misura di %d giorni, cadenza %d  %s" % (eta, cadenza, nome))
            esito.nota("      %s" % voce.get('dove', ''))
        elif eta > cadenza:
            esito.avviso("misura di %d giorni, cadenza %d  %s" % (eta, cadenza, nome))
            esito.nota("      %s" % voce.get('dove', ''))
        else:
            esito.ok("misura di %d giorni, cadenza %d  %s" % (eta, cadenza, nome))


# ---------------------------------------------------------------------------
# 3. Invarianti: la logica sta qui, non nel registro, perche' sono strutturali
# ---------------------------------------------------------------------------
def file_tracciati():
    elenco = git('ls-files')
    return [r for r in elenco.split('\n') if r] if elenco else []


def testo_di(rel):
    p = percorso(rel)
    if not os.path.exists(p):
        return ''
    try:
        with open(p, encoding='utf-8-sig', errors='replace') as f:
            return f.read()
    except Exception:
        return ''


def controlla_invarianti(esito):
    tracciati = file_tracciati()
    if not tracciati:
        esito.grave("git non risponde: gli invarianti non sono calcolabili")
        return

    # 3a. Ogni script presente deve essere citato nella scheda dello stack.
    stack = testo_di('.claude/context/STACK.md')
    if not stack:
        esito.grave("STACK.md non leggibile: l'inventario degli script non e' verificabile")
    else:
        cartella = os.path.join(RADICE, 'scripts')
        presenti = sorted(n for n in os.listdir(cartella)
                          if os.path.isfile(os.path.join(cartella, n))
                          and os.path.splitext(n)[1] in ('.ps1', '.py', '.sh'))
        mancanti = [n for n in presenti if n not in stack]
        if mancanti:
            esito.grave("%d script presenti in scripts/ e non citati in STACK.md" % len(mancanti))
            for n in mancanti:
                esito.nota("      %s" % n)
        else:
            esito.ok("tutti i %d script di scripts/ sono citati in STACK.md" % len(presenti))

    # 3b. Ogni ADR richiamato deve esistere nel registro delle decisioni.
    decisioni = testo_di('.claude/memory/decisions.md')
    definiti = set(re.findall(r'^##\s+(ADR-\d+)', decisioni, re.M))
    citati = set()
    for rel in tracciati:
        if rel.endswith('.md') and rel != '.claude/memory/decisions.md':
            citati.update(re.findall(r'\bADR-\d+\b', testo_di(rel)))
    orfani = sorted(citati - definiti)
    if orfani:
        esito.grave("%d ADR richiamati e non definiti in decisions.md: %s" % (len(orfani), ', '.join(orfani)))
    else:
        esito.ok("i %d ADR richiamati sono tutti definiti" % len(citati))

    # 3c. Ogni difetto richiamato come #NNN deve esistere nel registro dei gap.
    gap = testo_di('docs/infrastructure-timeline/GAP-TBC.md')
    definiti_gap = set(re.findall(r'^\|\s*(\d+)\s*\|\s*[A-Z]{3,4}-\d+\s*\|', gap, re.M))
    massimo = max((int(n) for n in definiti_gap), default=0)
    citati_gap = set()
    for rel in tracciati:
        if rel.endswith('.md'):
            citati_gap.update(re.findall(r'#(\d{2,3})\b', testo_di(rel)))
    oltre = sorted((n for n in citati_gap if int(n) > massimo), key=int)
    if oltre:
        # Avviso e non diagnosi, per un motivo verificato il 04/09/2026: il registro
        # porta anche la numerazione per sezione delle prime fasi (per esempio
        # "#195 (sec-007)"), che convive con quella principale e non e' un errore.
        # Uno strumento che non sa distinguere i due mondi lo dichiara invece di
        # decidere al posto di chi legge.
        esito.avviso("%d richiami di difetto oltre il massimo del registro principale (#%d): %s"
                     % (len(oltre), massimo, ', '.join('#' + n for n in oltre)))
        esito.nota("      possono essere riferimenti alla numerazione per sezione: da guardare, non da correggere a scatola chiusa")
    else:
        esito.ok("nessun difetto richiamato oltre il massimo definito (#%d)" % massimo)

    # 3c-ter. Nel registro dei difetti un numero non si assegna due volte.
    #
    # Invariante nato l'08/09/2026 da una collisione reale: il difetto del guard-rail di
    # anonimizzazione e quello del volume BitLocker a protezione sospesa erano entrambi #191 e
    # SEC-047, scritti lo stesso giorno da due sessioni di lavoro diverse su un file che
    # nessuna delle due sapeva di condividere. La collisione e' arrivata in un commit senza
    # che nulla la dichiarasse, ed e' stata trovata da una persona che leggeva il registro per
    # altro. Non e' un difetto di forma: il numero e' il modo in cui ogni scheda si riferisce a
    # un difetto, quindi due voci allo stesso numero rendono ambiguo ogni richiamo esistente e
    # ogni richiamo futuro. E' il punto cieco di classe D di .claude/rules/fonti-e-riallineamento.md
    # nella sua forma piu' banale, cioe' due mani sullo stesso file.
    #
    # Il numero non ammette eccezioni e la sua collisione e' quindi rossa. L'identificatore ne
    # ammette due, dichiarate, ed e' la ragione per cui il suo esito e' un avviso: una riga di
    # aggiornamento che porta il parentetico nella cella, come "TEL-002 (aggiornamento)", e una
    # riga di seguito numerata con un suffisso di lettera, come 136b che continua 136. Fuori da
    # questi due casi due voci con lo stesso identificatore sono due difetti diversi che si
    # presentano con lo stesso nome, che e' la stessa ambiguita' un livello piu' in basso.
    if not gap:
        esito.grave("registro dei difetti non leggibile: l'unicita' dei numeri non e' verificabile")
    else:
        righe = re.findall(r'^\|\s*(\d+[a-z]?)\s*\|\s*([^|]*)\|', gap, re.M)
        per_numero = {}
        per_id = {}
        for numero, cella in righe:
            per_numero.setdefault(numero, 0)
            per_numero[numero] += 1
            cella = cella.strip()
            # La cella con un parentetico e' una continuazione dichiarata e non una collisione.
            if '(' in cella:
                continue
            trovato = re.match(r'^\*{0,2}([A-Z]{2,6}-\d+[a-z]*)', cella)
            if trovato:
                per_id.setdefault(trovato.group(1), []).append(numero)
        ripetuti = sorted((n for n, quanti in per_numero.items() if quanti > 1),
                          key=lambda n: (int(re.match(r'\d+', n).group()), n))
        if ripetuti:
            esito.grave("%d numeri assegnati a piu' di una voce del registro: %s"
                        % (len(ripetuti), ', '.join('#' + n for n in ripetuti)))
            esito.nota("      un numero vale per una voce sola: ogni richiamo a un numero doppio e' ambiguo")
            esito.nota("      si rinumera la voce piu' recente, che e' quella con meno richiami da rompere")
        else:
            esito.ok("i %d numeri del registro dei difetti sono tutti distinti" % len(per_numero))
        # Un suffisso di lettera sullo stesso numero e' una riga di seguito: 136b continua 136.
        collisi = []
        for identificativo, numeri in sorted(per_id.items()):
            radici = set(re.match(r'\d+', n).group() for n in numeri)
            if len(numeri) > 1 and len(radici) > 1:
                collisi.append((identificativo, sorted(numeri, key=lambda n: (int(re.match(r'\d+', n).group()), n))))
        if collisi:
            esito.avviso("%d identificatori portati da voci diverse del registro" % len(collisi))
            for identificativo, numeri in collisi:
                esito.nota("      %-12s su %s" % (identificativo, ', '.join('#' + n for n in numeri)))
            esito.nota("      due difetti distinti con lo stesso nome: da guardare, non da rinominare a scatola chiusa")
        else:
            esito.ok("nessun identificatore e' portato da due voci distinte")

    # 3c-bis. La mappa dei segnaposto e il file dei pattern devono coprire le stesse cose.
    #
    # La regola di anonimizzazione dichiara che sono "due facce dello stesso dato", ed era
    # un'affermazione senza verifica: il 07/09/2026 si e' scoperto che divergevano su dodici
    # prefissi reali, fra cui le due LAN principali, quindi per quelle subnet il guard-rail
    # classificava un valore reale come ambiguita' da valutare a mano invece che come fuga.
    # Nessuno se n'era accorto perche' nessuno confrontava i due file.
    #
    # Non stampa mai un valore, solo quanti: entrambi i file vivono nel layer privato e
    # l'uscita di questo controllo finisce sotto gli occhi di chiunque guardi la sessione.
    mappa = testo_di('_notes/.anonymization-map.md')
    if not mappa:
        esito.nota("      mappa dei segnaposto assente: il confronto con i pattern non e' calcolabile")
    else:
        try:
            pat = leggi_json('_notes/.anonymization-patterns.json') or {}
        except Exception:
            pat = {}
        if not pat:
            esito.grave("file dei pattern assente o illeggibile: il guard-rail di anonimizzazione non e' giudicabile")
        else:
            noti = set(pat.get('prefissi_reali', []))
            # Un'esclusione decisa da una persona va dichiarata nel file dove sta la decisione,
            # non subita come avviso perpetuo: un controllo che segnala sempre la stessa cosa
            # insegna a ignorarlo, che e' il modo in cui muore.
            esclusi = set(pat.get('prefissi_esclusi_per_decisione', []))
            doc = tuple(pat.get('reti_documentali_ammesse', []))
            amm = set(pat.get('ip_ammessi', []))
            scoperti = set()
            for trovato in re.finditer(r'\b(?:\d{1,3}\.){3}\d{1,3}\b', mappa):
                indirizzo = trovato.group(0)
                prefisso = indirizzo.rsplit('.', 1)[0] + '.'
                if indirizzo in amm or prefisso in noti or prefisso in esclusi:
                    continue
                if doc and prefisso.startswith(doc):
                    continue
                if indirizzo.startswith(('127.', '255.', '0.', '224.')) or indirizzo.split('.')[0] in ('255', '0'):
                    continue
                scoperti.add(prefisso)
            if scoperti:
                esito.avviso("%d prefissi compaiono nella mappa dei segnaposto e in nessuna lista dei pattern"
                             % len(scoperti))
                esito.nota("      la regola dichiara che i due file sono due facce dello stesso dato: se un")
                esito.nota("      prefisso reale manca ai pattern, il guard-rail non lo cerca. Valori non stampati")
                esito.nota("      di proposito: vanno guardati aprendo i due file in `_notes/`")
            else:
                coda = ""
                if esclusi:
                    coda = " (%d esclusi per decisione dichiarata)" % len(esclusi)
                esito.ok("mappa dei segnaposto e file dei pattern coprono gli stessi prefissi" + coda)

    # 3d. Il frontmatter di una scheda deve dichiarare un commit a partire dal quale il
    # contenuto della scheda non e' piu' cambiato.
    #
    # Due correzioni, entrambe dell'08/09/2026, e la seconda e' quella che rende il controllo
    # raggiungibile invece che soltanto giusto.
    #
    # La prima: NON si confronta con HEAD. Confrontare con HEAD segnalava tutte le schede dopo
    # qualunque commit, anche uno che non le riguardava, cioe' un giallo perpetuo.
    #
    # La seconda: non si confronta nemmeno con il commit che ha toccato la scheda per ultimo,
    # perche' quel confronto conserva la circolarita' che il primo aveva soltanto ridotto. La
    # regola prescrive di bumpare dopo il commit, ma il bump scrive dentro la scheda, quindi
    # crea un commit nuovo che tocca la scheda e riporta il confronto in giallo: l'allineamento
    # resta irraggiungibile per costruzione, e la sessione che bumpa in buona fede si ritrova
    # segnalata proprio per averlo fatto. Il fatto che conta non e' quando la scheda e' stata
    # scritta ma quando ne e' cambiato il CONTENUTO: un commit che tocca il solo campo
    # `last-verified` non e' una modifica della scheda, e' la sua firma.
    #
    # Il confronto e' quindi di discendenza e non di uguaglianza: la scheda e' allineata se il
    # commit dichiarato e' quello dell'ultima modifica di contenuto oppure un suo discendente.
    # Cosi' resta verde anche chi rilegge una scheda immutata a una data successiva e ribumpa
    # in avanti, che e' esattamente cio' che la regola del bump chiede di fare.
    cartella = os.path.join(RADICE, '.claude', 'context')
    # Il percorso si estrae separando sul primo spazio, non tagliando a posizione fissa: il
    # taglio a posizione fissa si e' rotto l'08/09/2026 perche' l'helper normalizza l'output e
    # lo spazio iniziale della prima riga spariva, sfasando quella sola riga di un carattere.
    # Nel caso di una rinomina la porcelain scrive "vecchio -> nuovo": interessa il nuovo.
    sporche = set()
    for riga in git('status', '--porcelain').split(chr(10)):
        riga = riga.strip()
        if not riga:
            continue
        pezzi = riga.split(None, 1)
        if len(pezzi) < 2:
            continue
        percorso = pezzi[1].strip().strip('"')
        if ' -> ' in percorso:
            percorso = percorso.split(' -> ', 1)[1].strip().strip('"')
        sporche.add(percorso)
    disallineate = []
    illeggibili = []
    quante = 0
    if os.path.isdir(cartella):
        for nome in sorted(n for n in os.listdir(cartella) if n.endswith('.md')):
            rel = '.claude/context/' + nome
            corpo = testo_di(rel)
            trovato = re.search(r'^last-verified:\s*(\S+)', corpo, re.M)
            if not trovato:
                continue
            quante += 1
            dichiarato = trovato.group(1)
            if rel in sporche:
                # Modificata e non ancora committata: il bump si valuta al commit, non ora.
                continue
            contenuto = ultima_modifica_di_contenuto(rel)
            if not contenuto:
                continue
            pieno = git('rev-parse', '--verify', dichiarato + '^{commit}')
            if not pieno:
                # Un hash che non risolve non e' un disallineamento ma un riferimento rotto:
                # o e' stato scritto a mano sbagliato, o la storia e' stata riscritta sotto.
                illeggibili.append((nome, dichiarato))
                continue
            discende = subprocess.run(['git', 'merge-base', '--is-ancestor', contenuto, pieno],
                                      cwd=RADICE, capture_output=True).returncode == 0
            if not discende:
                disallineate.append((nome, dichiarato, contenuto[:7]))
        if illeggibili:
            esito.grave("%d schede dichiarano un commit che non esiste nella storia" % len(illeggibili))
            for nome, dichiarato in illeggibili:
                esito.nota("      %-26s dichiara %s, che non risolve" % (nome, dichiarato))
        if disallineate:
            esito.avviso("%d schede il cui contenuto e' cambiato dopo il commit dichiarato" % len(disallineate))
            for nome, dichiarato, contenuto in disallineate:
                esito.nota("      %-26s dichiara %s, contenuto cambiato in %s" % (nome, dichiarato, contenuto))
            esito.nota("      il bump va fatto dopo aver riletto la scheda, non in blocco: l'hash dichiara una rilettura")
        if not disallineate and not illeggibili:
            esito.ok("il frontmatter delle %d schede copre l'ultima modifica di contenuto" % quante)


# ---------------------------------------------------------------------------
# 4. Asserzioni umane
# ---------------------------------------------------------------------------
def controlla_asserzioni(reg, esito):
    for voce in reg.get('asserzioni_umane', []):
        eta = giorni_da(voce.get('verificata_il'))
        validita = int(voce.get('validita_giorni', 30))
        testa = "%s  %s" % (voce.get('stato', '?'), voce.get('afferma', ''))
        if eta is None:
            esito.avviso("MAI VERIFICATA  %s" % voce.get('afferma', ''))
            esito.nota("      chiedere a %s: %s" % (voce.get('a_chi', '?'), voce.get('domanda', '')))
            esito.nota("      dove:  %s" % voce.get('dove', ''))
        elif eta > validita:
            esito.avviso("verificata %d giorni fa, validita' %d  %s" % (eta, validita, voce.get('afferma', '')))
            esito.nota("      chiedere a %s: %s" % (voce.get('a_chi', '?'), voce.get('domanda', '')))
        else:
            esito.ok("verificata %d giorni fa  %s" % (eta, testa))


# ---------------------------------------------------------------------------
def stampa(titolo, esito, silenzioso):
    if silenzioso:
        return
    print('')
    print(titolo)
    print('-' * 78)
    if not esito.righe:
        print(colora('  nessuna voce', GRIGIO))
    for tipo, testo in esito.righe:
        if tipo == 'grave':
            print(colora('  ' + testo, ROSSO))
        elif tipo == 'avviso':
            print(colora('  ' + testo, GIALLO))
        elif tipo == 'ok':
            print(colora('  ' + testo, VERDE))
        else:
            print(colora(testo, GRIGIO))


def main():
    silenzioso = '--silenzioso' in sys.argv
    orizzonte = 120
    if '--giorni' in sys.argv:
        try:
            orizzonte = int(sys.argv[sys.argv.index('--giorni') + 1])
        except (IndexError, ValueError):
            pass

    if not os.path.exists(REGISTRO):
        print(colora("NON GIUDICABILE: manca data/scadenze.json, il registro delle affermazioni che invecchiano.", ROSSO))
        print("Senza quel file questo controllo non ha nulla da verificare, e un verde non calcolato")
        print("sarebbe peggio di un rosso: si ferma qui invece di dichiararsi allineato.")
        return 2
    try:
        reg = leggi_json('data/scadenze.json')
    except Exception as errore:
        print(colora("NON GIUDICABILE: data/scadenze.json non e' leggibile (%s)" % errore, ROSSO))
        return 2

    scad, fresc, inv, ass = Esito(), Esito(), Esito(), Esito()
    controlla_scadenze(reg, scad, orizzonte)
    controlla_freschezza(reg, fresc)
    controlla_invarianti(inv)
    controlla_asserzioni(reg, ass)

    if not silenzioso:
        print("Allineamento - registro revisione %s, aggiornato al %s" %
              (reg.get('revisione', '?'), reg.get('aggiornato', '?')))
    stampa("SCADENZE  (entro %d giorni; le piu' lontane sono contate e non elencate)" % orizzonte, scad, silenzioso)
    stampa("FRESCHEZZA DELLE FONTI  (eta' della misura contro la cadenza dichiarata)", fresc, silenzioso)
    stampa("INVARIANTI  (cio' che i documenti affermano contro cio' che c'e' davvero)", inv, silenzioso)
    stampa("ASSERZIONI UMANE  (nessun programma puo' verificarle: sono domande)", ass, silenzioso)

    tutte = scad.righe + fresc.righe + inv.righe + ass.righe
    gravi = sum(1 for tipo, _ in tutte if tipo == 'grave')
    problemi = scad.problemi + fresc.problemi + inv.problemi + ass.problemi
    controlli = scad.controlli + fresc.controlli + inv.controlli + ass.controlli
    print('')
    print('-' * 78)
    # Il codice di uscita distingue due cose che sarebbe comodo confondere e sbagliato
    # confondere. Il giallo e' un'affermazione che sta invecchiando: normale, va letta,
    # e non deve marcare come fallito ogni singolo avvio di sessione, altrimenti in due
    # settimane nessuno guarda piu' l'esito ed e' esattamente il difetto da cui questo
    # script nasce. Il rosso e' qualcosa di gia' rotto: una data passata, una misura
    # assente, un documento che afferma cio' che non c'e'.
    if gravi:
        print(colora("DA SANARE: %d voci gia' rotte, piu' %d da guardare, su %d controlli."
                     % (gravi, problemi - gravi, controlli), ROSSO))
        print("  Non blocca il lavoro per decisione dell'IT Manager del 04/09/2026, ma una voce")
        print("  rossa e' un'affermazione che il progetto sta facendo e che non e' piu' vera.")
        return 1
    if problemi:
        print(colora("DA GUARDARE: %d voci su %d controlli, nessuna gia' rotta."
                     % (problemi, controlli), GIALLO))
        print("  Ciascuna e' un'affermazione che sta invecchiando, e l'unico modo in cui fa")
        print("  danno e' che nessuno la legga.")
        return 0
    print(colora("ALLINEATO: %d controlli, nessuna voce da guardare." % controlli, VERDE))
    return 0


if __name__ == '__main__':
    sys.exit(main())
