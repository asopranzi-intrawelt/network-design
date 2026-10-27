# Log e osservabilità

Quest'area documenta come la rete si osserva: il collettore dei log degli accessi amministrativi e le sue sorgenti, l'osservabilità delle macchine Linux e dell'host di inferenza, e il processo che rinfresca e conserva gli snapshot delle fonti vive. Il collettore, il servizio QA e l'attestazione d'integrità sono progetti con un repository proprio: qui si scrive soltanto ciò che cambia la rete, cioè flussi, porte, accessi, retention e stato ISO.

| Documento | Che cosa risponde | Natura |
|---|---|---|
| [Integrazione del collettore](log-collector-integrazione.md) | quali sorgenti arrivano al collettore, con quale trasporto e quali prove | registro |
| [Normalizzazione, retention e capienza](normalizzazione-retention-capienza.md) | come si leggono gli archivi e quanto spazio serve | progetto |
| [Sorgenti Seeweb](sorgenti-log-seeweb.md) | quali log del datacenter sono davvero raccolti | scheda |
| [Osservabilità Linux](osservabilita-linux-netdata.md) | una console comune per le macchine Linux e l'host di inferenza | studio |
| [Fonti e passi dell'osservabilità Linux](fonti-osservabilita-linux.md) | da quale fonte viene ogni passo del pilota | registro delle fonti |
| [Runbook del pilota Linux e GPU](runbook-monitoraggio-linux.md) | come si è installato e verificato il pilota | runbook |
| [La GPU persa al riavvio](inferenza-gpu-persa-al-riavvio.md) | perché un servizio raggiungibile può essere guasto | rilievo |
| [Pacchetto linux-observability](progetto-pacchetto-linux-observability.md) | il mandato per renderlo riproducibile nel template | progetto |
| [Integrazione dei log del servizio QA](integrazione-log-qa-verifier.md) | come i log del servizio QA arriveranno al collettore | registro |
| [Attestazione d'integrità](integrita-docs-integrazione.md) | che cosa l'attestazione dei documenti chiede alla rete e al NAS | registro |
| [Fonti vive e retention](processo-fonti-vive-retention.md) | come si rinfrescano e si conservano gli snapshot | processo |

Torna alla [documentazione](../README.md).
