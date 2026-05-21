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






