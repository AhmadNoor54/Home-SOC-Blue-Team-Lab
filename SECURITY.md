# Security Policy

## Scope

This repository contains a defensive cybersecurity laboratory with intentionally crafted attack traffic, IDS signatures, SIEM rules, and detection-testing commands.

The material is designed for isolated, authorized environments.

## Safe Use

Only run the attack simulations against systems you own or have explicit permission to test.

Do not point the commands, signatures, or scripts at public infrastructure, third-party systems, university networks, corporate networks, or any other environment without authorization.

Keep the lab isolated from production systems and use snapshots before major configuration changes.

## Reporting a Problem

If you discover a security issue in the repository itself, open a private report through GitHub's repository security features when available. Do not publish credentials, private IP information, tokens, passwords, or other sensitive data in a public issue.

## Credentials

Never commit Wazuh administrator passwords, API keys, SSH keys, private certificates, `.env` files, or other secrets. The repository's `.gitignore` includes common secret and runtime-file patterns, but contributors should still review staged files before pushing.
