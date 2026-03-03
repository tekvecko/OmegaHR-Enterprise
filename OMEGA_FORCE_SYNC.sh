#!/data/data/com.termux/files/usr/bin/bash
set -e

PROJECT_DIR="/data/data/com.termux/files/home/OmegaPlatinum_PROD"
cd $PROJECT_DIR

echo "🔄 Vynucuji synchronizaci vizuálních funkcí..."

# 1. Čištění Python cache
find . -type d -name "__pycache__" -exec rm -rf {} + || true

# 2. Restart Jádra
pkill -f "omega_core.py" || true
nohup python3 omega_core.py > dev_server.log 2>&1 &

echo "✅ Jádro restartováno."
echo "💡 DŮLEŽITÉ: V prohlížeči (na tom zrok odkazu) udělej 'Hard Refresh':"
echo "   - Mobil: Zavři tab a otevři ho znovu v anonymním okně."
echo "   - PC: Stiskni Ctrl + F5."
