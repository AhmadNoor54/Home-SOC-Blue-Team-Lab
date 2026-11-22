# Security Policy

## Scope

This repository contains a defensive cybersecurity lab for testing network detection, IDS signatures, SIEM rules, and security monitoring.

## Safe Use

- Run simulations only in isolated environments.
- Test only systems you own or have permission to assess.
- Never target public, third-party, or production networks without authorization.
- Use virtual machine snapshots before major changes.

## Reporting a Problem

If you discover a security issue in the repository itself, open a private report through GitHub's repository security features when available. Do not publish credentials, private IP information, tokens, passwords, or other sensitive data in a public issue.

## Credentials

Never commit Wazuh administrator passwords, API keys, SSH keys, private certificates, `.env` files, or other secrets. The repository's `.gitignore` includes common secret and runtime-file patterns, but contributors should still review staged files before pushing.
