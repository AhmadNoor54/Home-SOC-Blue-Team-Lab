# Architecture

The detailed network topology and end-to-end detection flows are documented in [`architecture.md`](architecture.md).

The architecture covers:

- VirtualBox NAT Network
- Kali attacker
- Windows 11 endpoint
- Ubuntu SOC server
- Suricata network IDS
- Wazuh Manager / Indexer / Dashboard
- Sysmon + Wazuh Agent
- Suricata `eve.json` → Wazuh ingestion
- Custom Wazuh rule classification
- MITRE ATT&CK mapping
