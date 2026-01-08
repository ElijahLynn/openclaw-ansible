# Clawdbot Ansible Installer

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Lint](https://github.com/pasogott/clawdbot-ansible/actions/workflows/lint.yml/badge.svg)](https://github.com/pasogott/clawdbot-ansible/actions/workflows/lint.yml)
[![Ansible](https://img.shields.io/badge/Ansible-2.14+-blue.svg)](https://www.ansible.com/)
[![Debian/Ubuntu](https://img.shields.io/badge/OS-Debian%2FUbuntu-orange.svg)](https://www.debian.org/)

Automated, hardened installation of [Clawdbot](https://github.com/clawdbot/clawdbot) in Docker with firewall isolation and Tailscale VPN.

## Features

- 🔒 **Firewall-first**: UFW + Docker isolation (only SSH + Tailscale accessible)
- 🔐 **Tailscale VPN**: Secure remote access without exposing services
- 🐳 **Docker**: Isolated containers, localhost-only bindings
- 🛡️ **Defense in depth**: 4-layer security architecture
- 🚀 **One-command install**: Complete setup in minutes
- 🔧 **Systemd integration**: Auto-start on boot

## Quick Start

```bash
curl -fsSL https://raw.githubusercontent.com/pasogott/clawdbot-ansible/main/install.sh | bash
```

## What Gets Installed

- Tailscale (mesh VPN)
- UFW firewall (SSH + Tailscale ports only)
- Docker CE + Compose V2
- Node.js 22.x + pnpm
- Clawdbot in hardened container
- Systemd service (auto-start)

## Post-Install

```bash
# 1. Connect to Tailscale
sudo tailscale up

# 2. Configure Clawdbot
sudo nano /home/clawdbot/.clawdbot/config.yml

# 3. Login
sudo docker exec -it clawdbot clawdbot login

# 4. Check status
sudo systemctl status clawdbot
```

## Security

- **Public ports**: SSH (22), Tailscale (41641/udp) only
- **Clawdbot port 3000**: Accessible via localhost or Tailscale only
- **Container isolation**: New containers can't expose ports externally
- **Non-root**: All processes run as unprivileged users

Verify: `nmap -p- YOUR_SERVER_IP` should show only port 22 open.

## Documentation

- [Security Architecture](docs/security.md)
- [Technical Details](docs/architecture.md)
- [Troubleshooting](docs/troubleshooting.md)
- [Agent Guidelines](AGENTS.md)

## Requirements

- Debian 11+ or Ubuntu 20.04+
- Root/sudo access
- Internet connection

## Manual Installation

```bash
# Install dependencies
sudo apt update && sudo apt install -y ansible git

# Clone repository
git clone https://github.com/pasogott/clawdbot-ansible.git
cd clawdbot-ansible

# Install Ansible collections
ansible-galaxy collection install -r requirements.yml

# Run playbook (as root or with sudo)
# If root: ansible-playbook playbook.yml -e ansible_become=false
# If non-root: ansible-playbook playbook.yml --ask-become-pass
ansible-playbook playbook.yml --ask-become-pass
```

## License

MIT - see [LICENSE](LICENSE)

## Support

- Clawdbot: https://github.com/clawdbot/clawdbot
- This installer: https://github.com/pasogott/clawdbot-ansible/issues
