# Setup Guide

This guide builds the Home SOC Blue Team Lab from the ground up. It assumes a Windows host running Oracle VirtualBox and three isolated virtual machines.

> **Safety:** Use the attack commands only against your own lab systems. Do not run them against public or unauthorized targets.

## 1. Lab Requirements

| VM                 | OS                    |     RAM | CPU |  Disk |
| ------------------ | --------------------- | ------: | --: | ----: |
| Kali-Attacker      | Kali Linux 2025.4     | 2048 MB |   2 | 40 GB |
| Ubuntu-SOC-Server  | Ubuntu Server 22.04.5 | 6144 MB |   2 | 40 GB |
| Windows11-Endpoint | Windows 11 Pro        | 4096 MB |   2 | 50 GB |



Windows 11 should have EFI, TPM 2.0, and Secure Boot enabled as required by the selected VirtualBox Windows 11 profile.

## 2. Configure the Lab Network

Create a VirtualBox NAT Network named `SOC-Lab-Network` with the `10.0.2.0/24` network and DHCP enabled. Attach all three VMs to this NAT Network.

The documented lab used:

| VM                 |      Lab IP |
| ------------------ | ----------: |
| Kali-Attacker      | `10.0.2.15` |
| Ubuntu-SOC-Server  |  `10.0.2.3` |
| Windows11-Endpoint |  `10.0.2.4` |


These addresses are the values captured during the project; DHCP can assign different addresses in a new deployment. Update the examples and configuration if your addresses differ.

Verify connectivity from Kali:

```bash
ping 10.0.2.3
ping 10.0.2.4
```

For Windows ICMP testing, allow inbound ICMPv4 Echo Request in Windows Defender Firewall if necessary.

## 3. Install Wazuh 4.12

On Ubuntu-SOC-Server:

```bash
curl -sO https://packages.wazuh.com/4.12/wazuh-install.sh
sudo bash ./wazuh-install.sh -a
```

Store the generated `admin` password securely.

Open the dashboard using the actual Ubuntu SOC server address, for example:

```text
https://10.0.2.3
```


## 4. Deploy the Windows Wazuh Agent

From the Wazuh Dashboard, open the agent deployment workflow and configure:

- Operating system: Windows
- Wazuh server address: `10.0.2.3`
- Agent name: `WIN11-ENDPOINT`

Run the generated PowerShell command as Administrator.

Verify the agent appears as active in the dashboard.

## 5. Install Sysmon

Install Sysmon on Windows and use a suitable Sysmon configuration such as the Neo23x0 configuration used during this project:

```powershell
.\Sysmon64.exe -accepteula -i sysmonconfig-export.xml
```

Add the Sysmon event channel to the Wazuh Agent configuration:

```xml
<localfile>
  <location>Microsoft-Windows-Sysmon/Operational</location>
  <log_format>eventchannel</log_format>
</localfile>
```

Restart the agent:

```powershell
Restart-Service -Name WazuhSvc
```

## 6. Install and Configure Suricata

On Ubuntu:

```bash
sudo apt update
sudo apt install -y suricata
```

Configure Suricata to monitor the Ubuntu VM's active interface. The project used `enp0s3`.

Copy the repository rules to the Suricata rules directory:

```bash
sudo cp rules/suricata/suricata.rules /etc/suricata/rules/suricata.rules
```

Make sure the rules file is referenced by `suricata.yaml`.

Validate the configuration before starting Suricata:

```bash
sudo suricata -T -c /etc/suricata/suricata.yaml
```

Start Suricata:

```bash
sudo systemctl enable --now suricata
```

Monitor alerts:

```bash
sudo tail -f /var/log/suricata/fast.log
```

Monitor structured events:

```bash
sudo tail -f /var/log/suricata/eve.json
```

## 7. Integrate Suricata with Wazuh

Add the Suricata JSON log as a Wazuh JSON input in `/var/ossec/etc/ossec.conf`:

```xml
<localfile>
  <log_format>json</log_format>
  <location>/var/log/suricata/eve.json</location>
</localfile>
```

Restart Wazuh Manager:

```bash
sudo systemctl restart wazuh-manager
```

Check the service immediately after editing configuration:

```bash
sudo systemctl status wazuh-manager --no-pager
```

## 8. Install the Custom Wazuh Rules

Copy the repository rules:

```bash
sudo cp rules/wazuh/local_rules.xml /var/ossec/etc/rules/local_rules.xml
```

Validate with Wazuh Logtest:

```bash
sudo /var/ossec/bin/wazuh-logtest
```

Then restart Wazuh:

```bash
sudo /var/ossec/bin/wazuh-control restart
```

If Wazuh fails to start after a rule change, inspect `/var/ossec/logs/ossec.log` before making further edits.

## 9. Start the Controlled HTTP Target

On Ubuntu:

```bash
chmod +x scripts/test-webserver.sh
./scripts/test-webserver.sh
```

This starts a simple Python HTTP server on port 80. It is intentionally a test target and does not provide application-level SQL or PHP functionality; the attack payloads are used to exercise the IDS signatures.

## 10. Run Detection Tests

Follow:

- [`attack-simulation.md`](attack-simulation.md) for the end-to-end scenario.
- [`detection-testing.md`](detection-testing.md) for the complete rule-by-rule validation.
- [`rule-reference.md`](rule-reference.md) for the rule mapping.

## 11. Final Verification

Confirm:

```bash
sudo systemctl is-active suricata
sudo systemctl is-active wazuh-manager
sudo tail -n 20 /var/log/suricata/fast.log
sudo tail -n 5 /var/log/suricata/eve.json
```

Then verify the resulting alerts in Wazuh Dashboard → Threat Hunting → Events.
