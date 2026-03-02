#!/data/data/com.termux/files/usr/bin/bash
set -e

cd /data/data/com.termux/files/home/OmegaPlatinum_PROD

echo "🔧 Opravuji špatně uloženou adresu repozitáře..."
git remote set-url origin "https://github.com/tekvecko/OmegaHR-Enterprise.git"

echo "🚀 Znovu odesílám na GitHub..."
git push -u origin main
