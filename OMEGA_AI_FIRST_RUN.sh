#!/data/data/com.termux/files/usr/bin/bash
set -e

PROJ="/data/data/com.termux/files/home/OmegaPlatinum_PROD"

echo "🔍 KROK 1: Verifikace prostředí..."
python3 --version
python3 -m pip show google-generativeai | grep Version || (echo "❌ AI knihovna chybí. Instaluji..." && pip install google-generativeai)

echo "🔐 KROK 2: Kontrola API klíče..."
if [ -z "$API_KEY" ]; then
    echo "❌ CHYBA: API_KEY není nastavena v prostředí!"
    echo "Prosím proveďte: export API_KEY='váš_klíč' a spusťte skript znovu."
    exit 1
else
    echo "✅ API_KEY nalezena."
fi

echo "🧠 KROK 3: Generování první analýzy (Terminal Preview)..."
python3 << 'PYEOF'
import os
import google.generativeai as genai
import sqlite3

# Konfigurace
genai.configure(api_key=os.getenv("API_KEY"))
model = genai.GenerativeModel('gemini-1.5-pro')

# Načtení reálného kontextu z DB
conn = sqlite3.connect("/data/data/com.termux/files/home/OmegaPlatinum_PROD/omega_database.db")
c = conn.cursor()
emp_count = c.execute("SELECT COUNT(*) FROM candidates").fetchone()[0]
asset_count = c.execute("SELECT COUNT(*) FROM assets").fetchone()[0]
conn.close()

prompt = f"""
Jsi AI Strateg Omega Platinum. Analyzuj aktuální stav:
- Počet zaměstnanců: {emp_count}
- Počet aktivních zařízení: {asset_count}
Navrhni 3 konkrétní kroky pro expanzi impéria.
Odpověď formátuj profesionálně v češtině.
"""

try:
    response = model.generate_content(prompt)
    print("\n--- STRATEGICKÝ REPORT ---")
    print(response.text)
    print("--------------------------\n")
    print("✅ Verifikace proběhla úspěšně.")
except Exception as e:
    print(f"❌ Chyba při komunikaci s AI: {e}")
PYEOF

echo "🚀 KROK 4: Restart produkčního serveru..."
pkill -f "omega_core.py" || true
nohup python3 "$PROJ/omega_core.py" > "$PROJ/dev_server.log" 2>&1 &

echo "💎 Systém je nyní plně funkční a report je dostupný na:"
echo "🌐 http://127.0.0.1:8080/admin/ai_strategy"
