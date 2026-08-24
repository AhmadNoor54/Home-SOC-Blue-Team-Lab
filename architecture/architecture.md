# Architecture

## Network Topology

```text
                    VirtualBox NAT Network (SOC-Lab-Network)
                              10.0.2.0/24
                                  |
          +-----------------------+-----------------------+
          |                       |                       |
          v                       v                       v
   Kali-Attacker           Windows11-Endpoint        Ubuntu-SOC-Server
   10.0.2.15                10.0.2.4                  10.0.2.3
   Attacker                 Victim/Endpoint           SOC Server
                                  |                       |
                            Sysmon + Wazuh Agent    Wazuh Manager/Indexer/Dashboard
                                                     Suricata IDS
```

## VM Specifications

| VM                 | RAM  |   CPU   |             Disk           |        OS             |
|--------------------|------|---------|----------------------------|-----------------------|
| Kali-Attacker      | 2 GB | 2 cores | 40 GB                      | Kali Linux 2025.4     |
| Ubuntu-SOC-Server  | 6 GB | 2 cores | 40 GB                      | Ubuntu Server 22.04.5 |
| Windows11-Endpoint | 4 GB | 2 cores | 50 GB                      | Windows 11 Pro        |

## End-to-End Detection Pipeline

```text
Kali Attack Traffic
        |
        v
Suricata (enp0s3, Ubuntu)
        |
   custom rule matches (SID 1000300-1006002)
        |
        v
   /var/log/suricata/eve.json
        |
        v
Wazuh Manager (<localfile> ingests eve.json)
        |
   generic rule 86601 "Suricata: Alert - <signature>"
        |
        v
Custom Wazuh rule (local_rules.xml)
   matches on <field name="alert.signature">
        |
        v
Rule ID 100001-100020, severity level, MITRE ATT&CK tag
        |
        v
Wazuh Dashboard (Threat Hunting / MITRE ATT&CK view)
```

## Endpoint Telemetry Pipeline

```text
Windows 11 activity (process creation, network, etc.)
        |
        v
Sysmon (Neo23x0 config) -> Windows Event Log
   Applications and Services Logs > Microsoft > Windows > Sysmon > Operational
        |
        v
Wazuh Agent (ossec.conf localfile: eventchannel)
        |
        v
Wazuh Manager (10.0.2.3:1514, encrypted)
        |
        v
Wazuh Dashboard (agent: WIN11-ENDPOINT)
```

## Why a Shared NAT Network (not default NAT)

VirtualBox's default "NAT" attachment gives each VM its own isolated virtual network — VMs can reach the internet but not each other. A custom **NAT Network** (`SOC-Lab-Network`, `10.0.2.0/24`) was created via VirtualBox's Network Manager and all three VMs were attached to it, enabling full inter-VM communication while still allowing outbound internet access for package installation.
