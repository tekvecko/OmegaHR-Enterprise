#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "📦 Obnovuji Enterprise knihovny pro Python 3.13..."

# Instalace kompletního stacku
python3 -m pip install flask fpdf2 google-genai Pillow

echo "🚀 Spouštím Omega Core..."
PROJ="/data/data/com.termux/files/home/OmegaPlatinum_PROD"
python3 "$PROJ/omega_core.py"
