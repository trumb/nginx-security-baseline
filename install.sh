#!/usr/bin/env bash
set -euo pipefail

# Nginx Security Baseline Installer
# Usage: curl -sSL https://raw.githubusercontent.com/trumb/nginx-security-baseline/main/install.sh | sudo bash

REPO_RAW="https://raw.githubusercontent.com/trumb/nginx-security-baseline/main"

echo "=== Nginx Security Baseline Installer ==="

# Install security snippet
echo "[1/4] Installing nginx security snippet..."
mkdir -p /etc/nginx/snippets
curl -sSL "$REPO_RAW/security-hardening.conf" -o /etc/nginx/snippets/security-hardening.conf
echo "  -> /etc/nginx/snippets/security-hardening.conf"

# Install fail2ban if not present
if ! command -v fail2ban-client &>/dev/null; then
  echo "[2/4] Installing fail2ban..."
  apt-get install -y -qq fail2ban
else
  echo "[2/4] fail2ban already installed"
fi

# Install fail2ban filters
echo "[3/4] Installing fail2ban filters and jails..."
curl -sSL "$REPO_RAW/fail2ban/filter.d/nginx-badbots.conf" -o /etc/fail2ban/filter.d/nginx-badbots.conf
curl -sSL "$REPO_RAW/fail2ban/filter.d/nginx-uploadfuzz.conf" -o /etc/fail2ban/filter.d/nginx-uploadfuzz.conf
curl -sSL "$REPO_RAW/fail2ban/filter.d/nginx-scanners.conf" -o /etc/fail2ban/filter.d/nginx-scanners.conf
curl -sSL "$REPO_RAW/fail2ban/jail.d/nginx.conf" -o /etc/fail2ban/jail.d/nginx.conf

# Restart services
echo "[4/4] Restarting services..."
nginx -t && systemctl reload nginx
systemctl restart fail2ban
systemctl enable fail2ban

echo ""
echo "=== Installation complete ==="
echo ""
echo "Next steps:"
echo "  1. Add this line inside each nginx server block:"
echo "     include /etc/nginx/snippets/security-hardening.conf;"
echo ""
echo "  2. Add the GitHub Action to your repos (.github/workflows/security.yml):"
echo "     - uses: trumb/nginx-security-baseline@main"
echo ""
echo "  3. For Dockerfiles, COPY the snippet into the image:"
echo "     COPY security-hardening.conf /etc/nginx/snippets/security-hardening.conf"
