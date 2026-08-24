# Known Limitations

This document records limitations discovered during implementation and testing. They are intentionally documented rather than hidden because understanding detection gaps is part of SOC engineering.

## 1. Active Response Is Not Enabled

An attempt was made to automatically block an attacker's IP when Wazuh rule `100005` fired.

The initial approach failed because the Suricata-derived source address was nested in the event data rather than exposed in the same structure expected by Wazuh's standard `firewall-drop` workflow. A custom response script was also tested, but `wazuh-execd` did not reliably invoke it for the local Suricata-derived event.

A separate false-positive test also demonstrated why automatic blocking must be implemented carefully: an overly broad reverse-shell signature could match legitimate Wazuh agent traffic and potentially block the monitored endpoint's own telemetry channel.

### Final decision

The final repository therefore uses an alert-only pipeline:

```text
Detect → Alert → Investigate
```

rather than:

```text
Detect → Automatically Block
```

This avoids allowing an experimental response mechanism to disrupt the lab itself.

### Future work

A future implementation should first create a reliable normalized source-IP field using a decoder, then validate Active Response in a dedicated test snapshot before enabling automated blocking.

## 2. Suricata DNS and Stats Events Were Disabled for Wazuh Ingestion

During integration, some Suricata `dns` and `stats` events produced `Too many fields for JSON decoder` errors because of their nested or high-volume structure.

The lab disabled those non-essential event types in the Suricata `eve.json` output while keeping Suricata alert events available.

This does not mean DNS detection was removed: the custom DNS alert signatures remain enabled.

## 3. Nikto User-Agent Detection Is Evasive

The `Nikto Scanner Detected` rule is based on the HTTP User-Agent. Modern Nikto versions may use a browser-like User-Agent by default, so a default scan can evade this specific signature.

The rule was validated with:

```bash
nikto -useragent "Nikto-Scanner-Test"
```

A stronger production rule should detect scanning behavior rather than relying only on a User-Agent string.

## 4. Signature-Based Detection Has False Positives and False Negatives

The rules are intentionally educational and focused on demonstrating detection engineering concepts. They are not production-grade signatures.

Examples:

- `uid=` may appear in legitimate traffic.
- A simple `curl` User-Agent can be spoofed.
- SQL injection patterns can be obfuscated.
- DNS entropy thresholds can produce benign matches.
- Web-shell signatures can be bypassed through encoding or alternative syntax.

Production deployment would require behavioral correlation, allowlists, context enrichment, and continuous tuning.

## 5. Lab IP Addresses Are Environment-Specific

The project documentation uses the addresses captured during the original build:

- Kali: `10.0.2.15`
- Ubuntu: `10.0.2.3`
- Windows: `10.0.2.4`

DHCP may assign different addresses in another environment. Update the configuration, scripts, and test commands if necessary.
