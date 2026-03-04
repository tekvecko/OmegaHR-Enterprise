#!/data/data/com.termux/files/usr/bin/bash
set -e

PROJ="/data/data/com.termux/files/home/OmegaPlatinum_PROD"
cd $PROJ

echo "⚙️ Obnovuji globální konfigurační vrstvu..."

# 1. Vytvoření globálního JSON konfigu
cat > omega_config.json << 'JEOF'
{
    "system_name": "OMEGA PLATINUM",
    "version": "2.6.5-ENTERPRISE",
    "security": {
        "session_timeout_minutes": 60,
        "max_login_attempts": 5,
        "force_https_sim": false
    },
    "paths": {
        "base": "/data/data/com.termux/files/home/OmegaPlatinum_PROD",
        "db": "omega_database.db",
        "contracts": "contracts",
        "backups": "backups"
    },
    "localization": {
        "language": "cs",
        "timezone": "Europe/Prague",
        "pdf_font": "System-Roboto.ttf"
    }
}
JEOF

# 2. Úprava jádra, aby načítalo tento JSON
python3 << 'PYEOF'
import json

path = "omega_core.py"
with open(path, 'r') as f:
    lines = f.readlines()

new_lines = []
config_load_code = """
# LOAD GLOBAL CONFIG
with open('omega_config.json', 'r') as f:
    CONFIG = json.load(f)
"""

# Vložíme načítání konfigu hned za importy
for i, line in enumerate(lines):
    new_lines.append(line)
    if "from fpdf import FPDF" in line:
        new_lines.append(config_load_code)

# Dynamické nahrazení hardcoded hodnot za CONFIG
content = "".join(new_lines)
content = content.replace('app.secret_key = os.getenv("API_KEY", "PLATINUM_2026_SECURE_KEY")', 
                          'app.secret_key = os.getenv("API_KEY", CONFIG["security"]["session_timeout_minutes"])')

with open(path, 'w') as f:
    f.write(content)
PYEOF

echo "🚀 Restartuji jádro s globální konfigurací..."
pkill -f "omega_core.py" || true
nohup python3 omega_core.py > dev_server.log 2>&1 &
echo "💎 GLOBÁLNÍ NASTAVENÍ AKTIVOVÁNO. Nyní můžeš měnit chování systému v omega_config.json."
