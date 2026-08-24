#!/bin/bash
# Starts a simple HTTP server on Ubuntu-SOC-Server to act as a target
# for detection testing (see docs/detection-testing.md).
# Run from Ubuntu-SOC-Server. Requires sudo (binds port 80).

sudo python3 -m http.server 80 --bind 10.0.2.3
