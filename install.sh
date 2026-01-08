#!/bin/bash
set -e

# Clawdbot Ansible Installer
# This script installs Ansible if needed and runs the Clawdbot playbook

REPO_URL="https://raw.githubusercontent.com/pasogott/clawdbot-ansible/main"
PLAYBOOK_URL="${REPO_URL}/playbook.yml"
TEMP_DIR=$(mktemp -d)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   Clawdbot Ansible Installer          ║${NC}"
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo ""

# Check if running on Debian/Ubuntu
if ! command -v apt-get &> /dev/null; then
    echo -e "${RED}Error: This installer only supports Debian/Ubuntu systems.${NC}"
    exit 1
fi

# Check if running as root or with sudo access
if [ "$EUID" -eq 0 ]; then
    echo -e "${GREEN}Running as root.${NC}"
    SUDO=""
    ANSIBLE_EXTRA_VARS="-e ansible_become=false"
else
    if ! command -v sudo &> /dev/null; then
        echo -e "${RED}Error: sudo is not installed. Please install sudo or run as root.${NC}"
        exit 1
    fi
    SUDO="sudo"
    ANSIBLE_EXTRA_VARS="--ask-become-pass"
fi

echo -e "${GREEN}[1/4] Checking prerequisites...${NC}"

# Check if Ansible is installed
if ! command -v ansible-playbook &> /dev/null; then
    echo -e "${YELLOW}Ansible not found. Installing...${NC}"
    $SUDO apt-get update -qq
    $SUDO apt-get install -y ansible
    echo -e "${GREEN}✓ Ansible installed${NC}"
else
    echo -e "${GREEN}✓ Ansible already installed${NC}"
fi

echo -e "${GREEN}[2/5] Downloading playbook...${NC}"

# Download the playbook and role files
cd "$TEMP_DIR"

# For simplicity, we'll clone the entire repo
echo "Cloning repository..."
git clone https://github.com/pasogott/clawdbot-ansible.git
cd clawdbot-ansible

echo -e "${GREEN}✓ Playbook downloaded${NC}"

echo -e "${GREEN}[3/5] Installing Ansible collections...${NC}"
ansible-galaxy collection install -r requirements.yml

echo -e "${GREEN}[4/5] Running Ansible playbook...${NC}"
if [ "$EUID" -ne 0 ]; then
    echo -e "${YELLOW}You will be prompted for your sudo password.${NC}"
fi
echo ""

# Run the playbook
ansible-playbook playbook.yml $ANSIBLE_EXTRA_VARS

echo ""
echo -e "${GREEN}[5/5] Installation complete!${NC}"
echo ""
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║ ✅ Clawdbot installed successfully!   ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}🔒 Security Status:${NC}"
echo "  - UFW Firewall: ENABLED"
echo "  - Open Ports: SSH (22) + Tailscale (41641/udp)"
echo "  - Docker isolation: ACTIVE"
echo "  - Container ports: localhost-only"
echo ""
echo -e "${YELLOW}🔐 Tailscale (VPN):${NC}"
echo "  - Connect: sudo tailscale up"
echo "  - Status: sudo tailscale status"
echo ""
echo -e "${YELLOW}📋 Next steps:${NC}"
echo "1. Connect Tailscale: sudo tailscale up"
echo "2. Configure: sudo nano /home/clawdbot/.clawdbot/config.yml"
echo "3. Login: sudo docker exec -it clawdbot clawdbot login"
echo "4. Status: sudo systemctl status clawdbot"
echo "5. Logs: sudo docker logs -f clawdbot"
echo ""
echo -e "${YELLOW}🛡️  Verify security:${NC}"
echo "- Check firewall: sudo ufw status verbose"
echo "- Check isolation: sudo iptables -L DOCKER-USER -n"
echo ""
echo -e "📚 Documentation: ${GREEN}https://docs.clawd.bot${NC}"
echo ""

# Cleanup
cd /
rm -rf "$TEMP_DIR"
