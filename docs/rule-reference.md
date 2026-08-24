# Detection Rule Reference

This page provides a quick reference for the 20 custom Wazuh rules and their corresponding Suricata signatures.

## Wazuh Rules

| Wazuh ID | Severity |          Detection                              | MITRE ATT&CK |
|---------:|---------:|-------------------------------------------------|--------------|
|  100001  |    5     | Nikto Scanner Detected                          | T1595        |
|  100002  |    5     | Gobuster Scan Detected                          | T1595        |
|  100003  |    3     | Curl Usage Detected                             | T1595        |
|  100004  |    3     | Wget Usage Detected                             | T1595        |
|  100005  |    10    | SQL Injection Attempt Detected                  | T1190        |
|  100006  |    8     | XSS Script Tag Detected                         | T1190        |
|  100007  |    8     | XSS Event Handler Detected                      | T1190        |
|  100008  |    10    | Command Injection - Semicolon                   | T1059        |
|  100009  |    10    | Command Injection - AND Operator                | T1059        |
|  100010  |    10    | Command Injection - Pipe                        | T1059        |
|  100011  |    12    | PHP Web Shell Upload Detected                   | T1505.003    |
|  100012  |    10    | PHP System Call Detected                        | T1059        |
|  100013  |    12    | Netcat Reverse Shell Upload Detected            | T1505.003    |
|  100014  |    12    | Netcat Reverse Shell Detected                   | T1059        |
|  100015  |    13    | Reverse Shell Indicator - Shell Output Detected | T1059        |
|  100016  |    10    | HTTP Flood Detected                             | T1498        |
|  100017  |    10    | SYN Flood Detected                              | T1498        |
|  100018  |    12    | EICAR Test File Detected                        | T1036        |
|  100019  |    8     | DNS Long Query Detected                         | T1071.004    |
|  100020  |    8     | DNS High Entropy Query Detected                 | T1071.004    |

## Suricata Signatures

The corresponding Suricata signatures are stored in [`rules/suricata/suricata.rules`](../rules/suricata/suricata.rules).

|     SID | Category          | Detection                   |
| ------: | ----------------- | --------------------------- |
| 1000300 | Reconnaissance    | Nikto scanner               |
| 1000301 | Reconnaissance    | Gobuster scanner            |
| 1000302 | Reconnaissance    | Curl                        |
| 1000303 | Reconnaissance    | Wget                        |
| 1001001 | Web Attack        | SQL Injection               |
| 1001002 | Web Attack        | XSS — Script Tag            |
| 1001003 | Web Attack        | XSS — Event Handler         |
| 111111  | Command Injection | Semicolon (`;`)             |
| 111112  | Command Injection | AND Operator (`&&`)         |
| 111113  | Command Injection | Pipe (`\|`)                 |
| 1002001 | Web Shell         | PHP Web-Shell Upload        |
| 1002002 | Web Shell         | PHP System Call             |
| 1002003 | Web Shell         | Netcat Reverse-Shell Upload |
| 1003001 | Reverse Shell     | Netcat Shell Output         |
| 1003002 | Reverse Shell     | Shell Output Indicator      |
| 1004001 | Denial of Service | HTTP Flood                  |
| 1004002 | Denial of Service | SYN Flood                   |
| 1005001 | Malware Test      | EICAR Test File             |
| 1006001 | DNS               | Long DNS Query              |
| 1006002 | DNS               | High-Entropy DNS Query      |



## Rule Validation

Use Wazuh Logtest after changing `local_rules.xml`:

```bash
sudo /var/ossec/bin/wazuh-logtest
```

Validate Suricata syntax before restarting the service:

```bash
sudo suricata -T -c /etc/suricata/suricata.yaml
```

See [`detection-testing.md`](detection-testing.md) for the actual validation results and troubleshooting notes.
