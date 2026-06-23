Firewall — nftables 
legacy
La sicurezza perimetrale e il routing interno sono gestiti tramite nftables. Il firewall implementa una politica di tipo Whitelisting (DROP di default), isola e unisce selettivamente
i segmenti di rete e attiva il NAT (Masquerading) per l'uscita su Internet. La configurazione è stata migrata da iptables, mantenuta di seguito come riferimento storico.

#!/usr/sbin/nft -f
flush ruleset

table ip filter {
    chain input {
        type filter hook input priority 0 ; policy drop ;
        iifname lo accept                      # loopback
        ct state established,related accept    # connessioni già stabilite
        tcp dport 22 accept                    # SSH
        udp dport 51820 accept                 # WireGuard
        icmp type echo-request accept          # ping
    }
    chain forward {
        type filter hook forward priority 0 ; policy drop ;
        ct state established,related accept    # connessioni già stabilite
        # VPN WireGuard verso tutte le interfacce
        iifname "wg0" oifname { "enp0s9", "enp0s8", "enp0s3" } accept
        # traffico di ritorno verso wg0
        oifname "wg0" ct state established,related accept
        # LAN e Windows verso internet
        iifname "enp0s8" oifname "enp0s3" accept
        iifname "enp0s9" oifname "enp0s3" accept
        # tra rete Windows e LAN client (bidirezionale)
        iifname "enp0s9" oifname "enp0s8" accept
        iifname "enp0s8" oifname "enp0s9" accept
    }
    chain output {
        type filter hook output priority 0 ; policy accept ;
    }
}

table ip nat {
    chain postrouting {
        type nat hook postrouting priority 100 ; policy accept ;
        oifname "enp0s3" masquerade           # NAT: nasconde gli IP privati dietro l'IP WAN
    }
}




# /etc/sysctl.d/99-forwarding.conf
net.ipv4.ip_forward = 1






-- Legacy ------------------------------------------------------------------------------------------------------------

#!/bin/bash
# Azzera tutte le regole esistenti (INPUT, FORWARD, OUTPUT)
iptables -F
# Azzera le regole della tabella nat
iptables -t nat -F

# Accetta tutto il traffico sul loopback (localhost)
iptables -A INPUT -i lo -j ACCEPT
# Accetta pacchetti di connessioni già stabilite o correlate
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
# Accetta connessioni SSH in entrata
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
# Accetta connessioni WireGuard in entrata
iptables -A INPUT -p udp --dport 51820 -j ACCEPT
# Accetta ping
iptables -A INPUT -p icmp -j ACCEPT

# NAT: masquerade del traffico in uscita su enp0s3 (WAN/internet),nasconde gi IP privati dietro quello pubblico/bridge
iptables -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE

# Accetta in FORWARD le connessioni già stabilite o correlate
iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Forwarding da VPN WireGuard verso tutte e tre le interfacce (LAN client Linux, rete Windows/AD/DC, WAN)
iptables -A FORWARD -i wg0 -o enp0s9 -j ACCEPT
iptables -A FORWARD -i wg0 -o enp0s8 -j ACCEPT
iptables -A FORWARD -i wg0 -o enp0s3 -j ACCEPT

# Permette il traffico di ritorno verso la VPN WireGuard (Fedora) e tra le interfacce
iptables -A FORWARD -o wg0 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Forwarding dalla LAN client Linux e dalla rete Windows verso internet
iptables -A FORWARD -i enp0s8 -o enp0s3 -j ACCEPT
iptables -A FORWARD -i enp0s9 -o enp0s3 -j ACCEPT

# Forwarding tra rete Windows/AD/DC e LAN client Linux (bidirezionale)
iptables -A FORWARD -i enp0s9 -o enp0s8 -j ACCEPT
iptables -A FORWARD -i enp0s8 -o enp0s9 -j ACCEPT

# Policy di default: blocca tutto il traffico in entrata e forward non esplicitamente permesso
iptables -P INPUT DROP
iptables -P FORWARD DROP
# Output libero
iptables -P OUTPUT ACCEPT

# Abilita il forwarding IPv4 a livello kernel
echo 1 > /proc/sys/net/ipv4/ip_forward

--------------------------------------------------------------------------------------------------------------
[Unit]
# Descrizione del servizio mostrata da systemctl status
Description=Firewall iptables - NAT e regole di rete

# Assicura che lo script venga eseguito solo dopo l'inizializzazione della rete,
# evitando che la policy DROP venga applicata durante l'avvio dei servizi di sistema
After=network.target


[Service]

# Percorso dello script firewall (assicurarsi che sia eseguibile: chmod +x)
ExecStart=/etc/systemd/system/nat.sh

[Install]
# Il servizio viene avviato nel normale target multiutente (avvio standard)
WantedBy=multi-user.target





