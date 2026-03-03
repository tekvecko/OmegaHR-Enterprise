#!/data/data/com.termux/files/usr/bin/bash
set -e

PROJECT_DIR="/data/data/com.termux/files/home/OmegaPlatinum_PROD"
cd $PROJECT_DIR

echo "🎭 Inicializuji Milestone Engine & Life-Cycle Simulator..."

# 1. ROZŠÍŘENÍ DATABÁZE O MILNÍKY
python3 << 'PYEOF'
import sqlite3
conn = sqlite3.connect("omega_database.db")
c = conn.cursor()
try:
    c.execute("ALTER TABLE candidates ADD COLUMN career_level TEXT DEFAULT 'Junior'")
    c.execute("ALTER TABLE candidates ADD COLUMN loyalty_points INTEGER DEFAULT 0")
    c.execute("CREATE TABLE IF NOT EXISTS milestones (id INTEGER PRIMARY KEY, token TEXT, title TEXT, date TEXT)")
    print("✅ DB schema pro životní cyklus připraveno.")
except:
    print("ℹ️ Milníky již v DB existují.")
conn.commit()
conn.close()
PYEOF

# 2. AKTUALIZACE KÓDU O LOGIKU JUBILEÍ
cat >> omega_core.py << 'PYEOF'

@app.route('/api/simulate_milestone/<token>')
def simulate_milestone(token):
    # Simulace postupu v čase
    events = [
        {"y": 0, "m": "Onboarding", "title": "🚀 Vítej na palubě! (Day 1)"},
        {"y": 1, "m": "Promotion", "title": "📈 Povýšení na Medior (Year 1)"},
        {"y": 3, "m": "Anniversary", "title": "🥉 Bronzové jubileum (Year 3)"},
        {"y": 5, "m": "Legend", "title": "🏆 OMEGA LEGEND - Platinum Member (Year 5)"}
    ]
    
    conn = sqlite3.connect(DB_FILE)
    c = conn.cursor()
    # Logování milníků do historie
    for e in events:
        c.execute("INSERT INTO milestones (token, title, date) VALUES (?, ?, ?)", 
                  (token, e['title'], f"202{6+e['y']}-01-01"))
    
    # Update statusu
    c.execute("UPDATE candidates SET career_level='Senior Platinum', loyalty_points=5000 WHERE token=?", (token,))
    conn.commit()
    conn.close()
    log_action(f"Simulace životního cyklu dokončena pro: {token}")
    return jsonify({"status": "Kariérní simulace proběhla", "level": "Senior Platinum"})
PYEOF

# 3. MASTER CONTROL SWITCH DO UI
# Přidáme tlačítko "LAUNCH LIFE-CYCLE" do dashboardu
python3 << 'PYEOF'
path = "templates/index.html"
with open(path, 'r') as f:
    content = f.read()

if "SIMULATE" not in content:
    btn = '<a href="#" onclick="fetch(\'/api/simulate_milestone/\' + token).then(r => location.reload())" class="btn btn-sm" style="background:var(--accent); color:black;">🚀 SIMULATE LIFE</a>'
    # Vložíme tlačítko do řádku tabulky (zjednodušeně pro demo)
    content = content.replace("</td>", f" {btn} </td>", 1)

with open(path, 'w') as f:
    f.write(content)
PYEOF

echo "✅ Life-Cycle Simulator integrován do Master Control."
