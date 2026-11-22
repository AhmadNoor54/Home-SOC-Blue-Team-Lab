#  Home SOC Blue Team Lab


<p align="center">
  <b>A hands-on, fully virtualized Blue Team / SOC laboratory for attack simulation, network detection, endpoint telemetry, SIEM analysis, and MITRE ATT&CK mapping.</b>
</p>

<p align="center">
  <code>Attack → Detect → Collect → Analyze → Map → Investigate</code>
</p>

---

## About the Project

The **Home SOC Blue Team Lab** is a practical cybersecurity laboratory built to simulate a small Security Operations Center using three virtual machines.

The lab combines **Suricata** for network intrusion detection, **Wazuh** for centralized security monitoring and SIEM capabilities, and **Sysmon + Wazuh Agent** for Windows endpoint telemetry.

The project goes beyond installing security tools. Controlled attack traffic is generated from Kali Linux, Suricata detects the network behavior, Wazuh ingests and classifies the resulting events, custom rules assign severity and MITRE ATT&CK techniques, and the final alerts are investigated through the Wazuh Dashboard.

## Objectives

- Build an isolated virtual SOC environment.
- Configure attacker, endpoint, and SOC-server communication.
- Deploy Wazuh 4.12 as the central SIEM/security-monitoring platform.
- Deploy Suricata as a network IDS.
- Collect Windows endpoint telemetry using Sysmon and Wazuh Agent.
- Develop and test custom Suricata signatures.
- Develop and test custom Wazuh rules.
- Map detections to MITRE ATT&CK.
- Simulate reconnaissance, web attacks, command injection, web-shell activity, reverse shells, DoS patterns, malware-test traffic, and DNS anomalies.
- Validate detections with real controlled traffic and Wazuh Logtest.
- Document false positives, parser behavior, detection gaps, and tuning decisions.

---

## Lab Architecture

Detailed architecture: [`architecture/architecture.md`](architecture/architecture.md)

---

## Detection Coverage

The lab contains **20 custom Suricata signatures** and **20 corresponding Wazuh classification rules**.

Rule details: [`docs/rule-reference.md`](docs/rule-reference.md)

Suricata rules: [`rules/suricata/suricata.rules`](rules/suricata/suricata.rules)

Wazuh rules: [`rules/wazuh/local_rules.xml`](rules/wazuh/local_rules.xml)

## Attack Chain

```

Full walkthrough: [`docs/attack-simulation.md`](docs/attack-simulation.md)

---

## Detection Validation

Every custom signature was tested against controlled traffic rather than being left unverified.

Testing covered:

- Nmap reconnaissance
- Nikto scanning
- Gobuster enumeration
- Curl and Wget activity
- SQL injection patterns
- XSS patterns
- Command injection
- PHP web-shell upload patterns
- Netcat payloads
- Reverse-shell output
- HTTP flood patterns
- SYN flood patterns
- EICAR test-file traffic
- Long DNS queries
- High-entropy DNS queries

Each Wazuh rule from `100001` through `100020` was also validated using:

```bash
sudo /var/ossec/bin/wazuh-logtest
```

Detailed test log: [`docs/detection-testing.md`](docs/detection-testing.md)

---

## Evidence

The repository contains screenshots captured from the working lab.

### Wazuh Dashboard

![Wazuh Dashboard](screenshots/05-wazuh-dashboard-overview.png)

### Attack Chain

![Attack Chain](screenshots/07-attack-chain-timeline.png)

### MITRE ATT&CK

![MITRE ATT&CK](screenshots/08-mitre-attack-view.png)

### SQL Injection Detection

![SQL Injection](screenshots/09a-sql-injection-detail.png)

### Reverse Shell Detection

![Reverse Shell](screenshots/09c-reverse-shell-detail.png)

### Suricata Detection

![Suricata Detection](screenshots/10-suricata-live-detection.png)

### Wazuh Logtest

![Wazuh Logtest](screenshots/11-wazuh-logtest.png)

### Sysmon Telemetry

![Sysmon](screenshots/12-sysmon-telemetry.png)

More evidence: [`screenshots/README.md`](screenshots/README.md)

---

## Quick Setup

### 1. Create the VMs

Create the three virtual machines listed above and attach them to the same VirtualBox NAT Network.

### 2. Configure the NAT Network

Create:

```text
SOC-Lab-Network
10.0.2.0/24
```

### 3. Install Wazuh

On Ubuntu:

```bash
curl -sO https://packages.wazuh.com/4.12/wazuh-install.sh
sudo bash ./wazuh-install.sh -a
```

### 4. Install the Windows Agent + Sysmon

Deploy the Wazuh Agent from the dashboard, then configure Sysmon telemetry as documented in [`docs/setup-guide.md`](docs/setup-guide.md).

### 5. Install Suricata

```bash
sudo apt update
sudo apt install -y suricata
```

Copy the custom rules:

```bash
sudo cp rules/suricata/suricata.rules /etc/suricata/rules/suricata.rules
```

Validate:

```bash
sudo suricata -T -c /etc/suricata/suricata.yaml
```

### 6. Integrate Suricata with Wazuh

Configure Wazuh to ingest:

```text
/var/log/suricata/eve.json
```

Then install the custom Wazuh rules:

```bash
sudo cp rules/wazuh/local_rules.xml /var/ossec/etc/rules/local_rules.xml
sudo /var/ossec/bin/wazuh-logtest
sudo /var/ossec/bin/wazuh-control restart
```

### 7. Start the Test Target

```bash
chmod +x scripts/test-webserver.sh
./scripts/test-webserver.sh
```

### 8. Run the Attack Simulation

Follow [`docs/attack-simulation.md`](docs/attack-simulation.md), then verify the resulting alerts in the Wazuh Dashboard.

For the full build process, use [`docs/setup-guide.md`](docs/setup-guide.md).

---

## Repository Structure

```text

architecture/  → SOC architecture and network design
docs/          → Setup, attack simulation, testing, limitations, and lessons learned
rules/         → Suricata and Wazuh detection rules
scripts/       → Lab helper scripts
screenshots/   → Project evidence and detection screenshots

```

---

## Important Lessons Learned


details: [`docs/lessons-learned.md`](docs/lessons-learned.md)

---

## Known Limitations

This is an educational detection lab, not a production SOC.

Full details: [`docs/known-limitations.md`](docs/known-limitations.md)

---
---

## Ethical Use

This repository is intended for authorized cybersecurity education, Blue Team training, detection engineering, and controlled laboratory experimentation.

**Only test systems you own or are explicitly authorized to assess.** Never run the attack simulations against public or third-party infrastructure.

See [`SECURITY.md`](SECURITY.md) for the repository security policy.

---

## Documentation Map

| Document | Purpose |
|---|---|
| [`architecture/architecture.md`](architecture/architecture.md) | Network and detection architecture |
| [`docs/setup-guide.md`](docs/setup-guide.md) | Full environment setup |
| [`docs/attack-simulation.md`](docs/attack-simulation.md) | End-to-end attack simulation |
| [`docs/detection-testing.md`](docs/detection-testing.md) | Rule-by-rule testing |
| [`docs/rule-reference.md`](docs/rule-reference.md) | Detection and MITRE mapping reference |
| [`docs/lessons-learned.md`](docs/lessons-learned.md) | Troubleshooting and engineering lessons |
| [`docs/known-limitations.md`](docs/known-limitations.md) | Detection and architecture limitations |
| [`screenshots/README.md`](screenshots/README.md) | Evidence index |

---

## 👨‍💻 Author

**Ahmad Noor**

Areas of interest:

- Blue Team Operations
- SOC Analysis
- Network Security
- Security Automation

---

## License

This project is licensed under the **MIT License**.

See [`LICENSE`](LICENSE).
