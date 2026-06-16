
### PREMESSA
Sono Alessandro Muzi, ho recentemente completato un corso di 300 ore presso il CEFI, focalizzato sulla gestione dei sistemi e sulla sicurezza informatica.

Questo repository nasce con l'obiettivo di documentare la creazione di un ambiente aziendale simulato in cui il Domain Controller Windows gestisce Active Directory e DNS, mentre i sistemi Debian ospitano tutti i servizi infrastrutturali complementari

La struttura è questa:

Server Debian 13 "Trixie" (Oracle VM), configurato con funzioni di routing e Nat tramite Iptables e Ip forwarding e DHCP Kea,ospita 3 interfacce:
1 bridge (enp0s3) e 2 LAN (LAN1=enp0s8, LAN2=enp0s9)

la prima LAN (10.0.10.1) è destinata a 2 client Linux (Fedora=10.0.10.101, Ubuntu=10.0.10.102), la seconda invece (10.0.20.1) collega il server Debian
a una macchina Windows Server, Controller di Dominio, che gestisce Active Directory e server DNS , per tutta la struttura.Tutto il traffico
della rete privata passa crittografato nel tunnel di WireGuard (VPN).

Samba, da Debian, tramite Winbind si interfaccia con AD, e per mezzo di CUPS gestisce un Print Server condiviso.
Grafana, Prometheus, Loki, Promtail e cAdvisor, containerizzati in Docker, monitorano e loggano lo stato delle macchine e della rete.

Rsync e Cron gestiscono ,in modo incrementale il backup automatizzato tramite script.

[Interfaces](interfaces)

[Firewall](firewall.sh)

[VPN](VPN)

[DHCP](kea-dhcp4.conf)

[Windows Domain Controller - Active Directory](windowsADDCDNS)

[Samba Winbind CUPS](samba.conf)

[Docker Prometheus Grafana Alloy Loki](DOCKERPROMGRAF)

[Maintenance](maintenance)







