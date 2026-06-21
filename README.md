
### PREMESSA
Sono Alessandro Muzi, ho recentemente completato un corso di 300 ore presso il CEFI, focalizzato sulla gestione dei sistemi e sulla sicurezza informatica.

Questo repository nasce con l'obiettivo di documentare la creazione di un ambiente aziendale simulato in cui il Domain Controller Windows gestisce Active Directory e DNS, mentre i sistemi Debian ospitano tutti i servizi infrastrutturali complementari.

La struttura è la seguente: il server Debian 13 "Trixie" (Oracle VM) funge da core dell'infrastruttura, configurato con funzioni di routing e NAT tramite nftables e IP forwarding, oltre alla gestione del servizio DHCP Kea. Il server ospita 3 interfacce di rete: una in modalità bridge (enp0s3) e due LAN dedicate (LAN1=enp0s8, LAN2=enp0s9).

La prima LAN (10.0.10.1) è destinata a due client Linux (Fedora 10.0.10.101 e Ubuntu 10.0.10.102), mentre la seconda (10.0.20.1) collega il server Debian alla macchina Windows Server (Controller di Dominio), che gestisce Active Directory e il servizio DNS per l'intera struttura. Tutto il traffico della rete privata transita crittografato all'interno del tunnel WireGuard (VPN).

Samba, da Debian, tramite Winbind si interfaccia con AD, e per mezzo di CUPS gestisce un Print Server condiviso. Grafana, Prometheus, Loki, Grafana Alloy e cAdvisor, containerizzati in Docker, monitorano e loggano lo stato delle macchine e della rete, inclusi gli alert generati da Suricata, il sistema di rilevamento intrusioni (IDS) attivo sul gateway.

Fail2ban completa la difesa attiva, bannando automaticamente gli IP responsabili di tentativi di accesso SSH falliti.

Rsync e Cron gestiscono in modo incrementale il backup automatizzato tramite script, le cui metriche sono integrate nello stesso stack di monitoring.


[Interfaces](interfaces)

[Firewall](firewall.sh)

[VPN](VPN)

[DHCP](kea-dhcp4.conf)

[Windows Domain Controller - Active Directory](windowsADDCDNS)

[Samba Winbind CUPS](samba.conf)

[Docker Prometheus Grafana Alloy Loki](DOCKERPROMGRAF)

[Maintenance](maintenance)

[Suricata](suricata)

[Fail2ban](fail2ban)






