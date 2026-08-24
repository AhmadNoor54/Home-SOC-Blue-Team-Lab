# Scripts

This directory contains small helper scripts used by the Home SOC Blue Team Lab.

## `test-webserver.sh`

Starts a simple Python HTTP server on the Ubuntu SOC server so that the Suricata rules can be tested against controlled HTTP traffic.

```bash
chmod +x scripts/test-webserver.sh
./scripts/test-webserver.sh
```

The script binds to `10.0.2.3:80`, matching the IP used in the documented lab. If the Ubuntu VM receives a different address, edit the bind address before running it.

The script is intentionally simple. It is a test target, not a production web server.

## Safety

Run these scripts only inside the isolated lab described in `docs/setup-guide.md`. Stop the test server when testing is complete with `Ctrl+C`.
