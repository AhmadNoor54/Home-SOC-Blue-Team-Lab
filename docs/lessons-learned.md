# Lessons Learned

The most useful part of this project was not installing the tools; it was discovering how detection systems behave when real traffic, parsers, encoders, and multiple telemetry sources interact.


## 1. VirtualBox Networking

Default VirtualBox NAT isolates the VMs from one another. Each VM can reach the Internet while still being unable to communicate directly with another VM.

The solution was a shared NAT Network named `SOC-Lab-Network` with the `10.0.2.0/24` address space.

This was essential because the project needs:

```text
Kali → Ubuntu
Kali → Windows
Windows → Wazuh
Suricata → observe lab traffic
```

## 2. Suricata Rule Syntax

Several special characters caused detection failures.

- `;` is a Suricata rule-option separator, so a literal semicolon requires escaping.
- `|` is used for hexadecimal byte notation; a literal pipe can be represented as `|7C|`.
- Literal backslashes need correct escaping.
- HTTP URI buffers may already be URL-decoded before rule matching.

The general lesson is to test what Suricata actually sees rather than assuming the wire representation and rule-buffer representation are identical.

## 3. Thresholding Matters

Gobuster generates many HTTP requests. A signature that matches every request can flood the SIEM with duplicate alerts.

The rule was tuned with a source-based threshold so the lab demonstrates the detection without producing unnecessary alert noise.

## 4. Network Visibility Matters for DNS

A DNS test using Kali's default resolver did not trigger because the query bypassed the Ubuntu sensor.

Directing the query to Ubuntu with:

```bash
dig @10.0.2.3 example.com
```

made the traffic visible to Suricata.

This reinforced an important SOC principle: a detection cannot fire on traffic the sensor never sees.

## 5. Reverse-Shell Detection Requires Network-Aware Thinking

The initial idea was to detect:

```text
/dev/tcp/
```

but that string is interpreted locally by Bash and does not necessarily cross the network.

The final approach detects shell output such as:

```text
uid=
```

which is observable on the return channel.

The lesson is to distinguish between attacker commands executed locally and artifacts that are actually transmitted across the monitored network.

## 6. Wazuh Rule Chaining

Wazuh's built-in Suricata rule `86601` sets `no_full_log`. As a result, custom rules chained with `<if_sid>86601</if_sid>` should match the decoded field:

```xml
<field name="alert.signature">...</field>
```

rather than assuming the complete raw JSON event is available to `<match>`.

## 7. XML Errors Can Stop the Entire Manager

A malformed `local_rules.xml` can prevent the Wazuh analysis engine from starting.

The safe workflow is:

```bash
sudo /var/ossec/bin/wazuh-logtest
sudo /var/ossec/bin/wazuh-control restart
sudo systemctl status wazuh-manager --no-pager
```

and then immediately inspect:

```bash
sudo tail -n 50 /var/ossec/logs/ossec.log
```

## 8. JSON Complexity Can Affect Ingestion

Suricata `dns` and `stats` events can contain large nested structures. Wazuh's JSON decoder may reject these events when the field count becomes too large.

The practical solution in this lab was to disable non-essential event types while keeping the important alert events flowing.

## 9. Detection Engineering Is an Iterative Process

A signature is not finished when it looks correct on paper.

The actual cycle is:

```text
Write Rule
   ↓
Validate Syntax
   ↓
Generate Traffic
   ↓
Inspect Raw Event
   ↓
Check Detection
   ↓
Investigate False Positives
   ↓
Tune Rule
   ↓
Retest
   ↓
Document
```

That cycle is one of the main skills demonstrated by this project.
