#  Home SOC Blue Team Lab

---

## About the Project
The **Home SOC Blue Team Lab** is a virtual cybersecurity environment that simulates a Security Operations Center (SOC) using three virtual machines.

It integrates **Suricata** for network intrusion detection, **Wazuh** for SIEM and security monitoring, and **Sysmon** with **Wazuh Agent** for Windows endpoint monitoring.

The lab generates controlled attack traffic from Kali Linux, detects suspicious activity, analyzes security events, and investigates alerts using custom rules and MITRE ATT&CK mapping.

## Objectives
- Build an isolated virtual SOC environment.
- Configure communication between three virtual machines.
- Deploy Wazuh 4.12 and Suricata.
- Collect Windows telemetry using Sysmon and Wazuh Agent.
- Develop and test custom Suricata and Wazuh rules.
- Map detections to MITRE ATT&CK.
- Simulate and detect common network and web-based threats.
- Validate alerts and document detection results.

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

---

## Repository Structure

```text

architecture/  → SOC architecture and network design
docs/          → Setup, attack simulation, testing, limitations, and lessons learned
rules/         → Suricata and Wazuh detection rules
scripts/       → Lab helper scripts
screenshots/   → Project evidence and detection screenshots

```

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

See [`LICENSE`](LICENSE).
