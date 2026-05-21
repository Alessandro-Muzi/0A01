  Servizi di Directory e Risoluzione dei Nomi (Active Directory & DNS)

  Questa sezione documenta l'infrastruttura di identità e risoluzione dei nomi del laboratorio, centralizzata su un Domain Controller **Windows Server**.

  L'estrazione dei dati e la manutenzione del server sono stati eseguiti sfruttando il tunnel VPN/SSH dal Gateway Debian, al fine di testare meglio la struttura.
  Macchina fisica (CMD) → SSH su Fedora/Debian → Cockpit sul browser → SSH verso il DC Windows → Powershell


  Architettura del Dominio Active Directory (AD DS)

  Il cuore della gestione delle identità è un dominio Active Directory configurato con i seguenti parametri logici, estratti via PowerShell:

  Carta d'Identità del Dominio

  Comando eseguito via SSH: Get-ADDomain | Select-Object Name, DomainMode, ForestMode | Format-List

Name       : lab
DomainMode : Windows2016Domain
ForestMode : Windows2016Forest

 Nota Architetturale: Il livello di funzionalità del dominio e della foresta è impostato su Windows Server 2016. 
 Questo rappresenta il livello logico massimo e standard introdotto da Microsoft, garantendo la totale compatibilità con le funzionalità moderne 
 di Active Directory anche su edizioni successive di Windows Server.

     Struttura delle Unità Organizzative (OU)

Per mappare le risorse del laboratorio (Utenti, Gruppi e Computer) è stata creata un'alberatura logica dedicata:

Name               DistinguishedName
----               -----------------
Domain Controllers OU=Domain Controllers,DC=lab,DC=local
Sviluppo           OU=Sviluppo,DC=lab,DC=local
Utenti             OU=Utenti,DC=lab,DC=local
DEV                OU=DEV,DC=lab,DC=local


Configurazione del Servizio DNS Autoritative

Il Domain Controller agisce come server DNS primario e autoritativo per l'intera infrastruttura (IP: 10.0.20.100). 
Come documentato nella Sezione 1, questo IP viene iniettato a tutti i client tramite KEA DHCP.
Verifica delle Zone DNS Attive
PowerShell

L'estrazione dello stato del server DNS conferma la corretta configurazione delle zone di ricerca diretta e inversa:


PS C:\Users\Administrator> Get-DnsServerZone | Select-Object ZoneName, ZoneType, IsDsIntegrated | Format-Table -AutoSize

ZoneName              ZoneType  IsDsIntegrated
--------              --------  --------------
_msdcs.lab.local      Primary              True
0.in-addr.arpa        Primary             False
10.0.10.in-addr.arpa  Primary              True
127.in-addr.arpa      Primary             False
20.0.100.in-addr.arpa Primary              True
255.in-addr.arpa      Primary             False
a                     Forwarder           False
b                     Forwarder           False
debian                Primary              True
lab.local             Primary              True
TrustAnchors          Primary              True

Analisi Tecnica delle Zone DNS:

    Integrazione con Active Directory (IsDsIntegrated = True): Le zone vitali come lab.local e _msdcs.lab.local 
(fondamentale per i record SRV di localizzazione dei servizi del dominio) sono integrate in AD, garantendo massima 
sicurezza e aggiornamenti dinamici.

    Risoluzione Inversa (10.0.10.in-addr.arpa): È stata configurata la zona di reverse lookup per la subnet dei client (10.0.10.0/24). 
Questa è una best practice indispensabile per permettere ai servizi Linux e agli strumenti di monitoring di risolvere gli IP in nomi host reali.

    Interoperabilità (debian): È presente una zona primaria dedicata al gateway Linux, a dimostrazione della perfetta federazione 
e raggiungibilità tra l'ambiente Debian e il Domain Controller Windows.
