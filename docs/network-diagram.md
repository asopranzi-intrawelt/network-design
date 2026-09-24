# Guida alla topologia di rete

La [mappa interattiva](network-map.html) rappresenta la topologia censita. La fonte modificabile e' [`data/network-topology.json`](../data/network-topology.json); [`scripts/Build-NetworkMap.ps1`](../scripts/Build-NetworkMap.ps1) rigenera la pagina HTML. Lo [snapshot dell'infrastruttura](snapshot-infrastruttura.md) racconta in forma lineare che cosa mostra il grafico, quali parti sono state confrontate con misure e quali richiedono un riscontro umano. Il [diagramma storico](archivio/network-diagram-2026-08.md) conserva la ricostruzione precedente e non descrive lo stato corrente.

## Percorso da leggere

La vista *Logica* parte dai tre accessi Internet, attraversa gli apparati del fornitore, il firewall e il core del Piano 2, quindi raggiunge lo switch del Piano Terra, il ramo storage, il server, i bridge e i servizi. La fibra e' primaria, il ponte radio e' il primo backup e la VDSL il secondo. Il failover appartiene agli apparati del fornitore; il firewall riceve una sola consegna dati. Il ramo voce arriva dal fornitore allo switch core sulla VLAN 2 e non passa dal firewall.

La vista *Fisica* raggruppa gli apparati per luogo. La vista *Segmenti* disegna soltanto i collegamenti che nella fonte dichiarano una VLAN; un collegamento senza etichetta non prova l'appartenenza alla VLAN nativa. La vista *Elettrica* risale dalla presa agli apparati usando solo le sorgenti censite. La vista *Porte* mostra la matrice derivata dallo snapshot Nebula, con data di misura propria. Lo stato di progetto e' nascosto all'apertura: il pulsante "Mostra il pianificato" rende visibile la DMZ e gli altri elementi previsti. Un tratteggio corto indica presenza o collegamento da confermare.

Un clic su un nodo apre la sua scheda; Invio o Spazio fanno lo stesso da tastiera. Il doppio clic isola il ramo documentato con due passaggi di contesto a monte; il tasto `i` lo fa sul nodo selezionato, `f` inquadra il disegno e `Esc` esce dall'isolamento. Il pulsante "Ripristina vista" azzera filtri, ricerca e isolamento. Si puo' condividere una vista con `#fisica`, `#segmenti`, `#elettrica` o `#porte`, e un ramo con `#isola=sw30`; per combinarli si usa `#fisica,isola=sw30`. L'isolamento segue la direzione dei collegamenti scritti nella fonte: e' una lettura del censimento, non una prova di dipendenza funzionale o di failover.

## Stato delle fonti e modifica

La data della topologia e' diversa dalla data di generazione dell'HTML e da quella della matrice porte. La fascia sopra il grafico dichiara la data, l'ambito e i limiti dell'ultima riconciliazione. Se la verifica supera sette giorni, la pagina la segnala come scaduta. I controlli automatici confrontano porte, inventario, bridge e alcune attestazioni delle macchine virtuali; non osservano le policy del firewall, la prova di ripristino dei backup o il cablaggio di entrambe le linee elettriche del server.

Una correzione parte dalla fonte JSON. Dopo la modifica, eseguire `powershell -NoProfile -File scripts/Build-NetworkMap.ps1`, poi `python scripts/Test-TopologyDrift.py` e `python scripts/Test-Anonymization.py`. L'HTML generato non si corregge direttamente. I dati reali e gli snapshot completi restano nel layer privato e in `output/`; la fonte pubblica usa segnaposto secondo [la regola di anonimizzazione](../.claude/rules/anonymization.md).
