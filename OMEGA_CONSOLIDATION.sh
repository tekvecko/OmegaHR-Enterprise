#!/data/data/com.termux/files/usr/bin/bash
set -e

PROJECT_DIR="/data/data/com.termux/files/home/OmegaPlatinum_PROD"
cd $PROJECT_DIR

echo "💎 Zahajuji finální konsolidaci systému OMEGA (Integrity & Logic Upgrade)..."

# 1. ROZŠÍŘENÍ DATABÁZE O CHYBĚJÍCÍ LOGICKÉ VRSTVY
python3 << 'PYEOF'
import sqlite3
conn = sqlite3.connect("omega_database.db")
c = conn.cursor()

# Asset Aging & Compliance Clock columns
updates = [
    ("assets", "purchase_date", "TEXT"),
    ("assets", "warranty_months", "INTEGER DEFAULT 36"),
    ("candidates", "badge_id", "TEXT"),
    ("candidates", "compliance_score", "INTEGER DEFAULT 100")
]

for table, col, dtype in updates:
    try:
        c.execute(f"ALTER TABLE {table} ADD COLUMN {col} {dtype}")
    except:
        pass

# Nastavení defaultních dat pro aging u existujících assetů
c.execute("UPDATE assets SET purchase_date = '2024-01-01' WHERE purchase_date IS NULL")
conn.commit()
conn.close()
print("✅ Databázové schéma konsolidováno.")
PYEOF

# 2. IMPLEMENTACE CLI TOOLS (omega-cli)
cat > omega-cli << 'CLIEOF'
#!/data/data/com.termux/files/usr/bin/python
import sys, sqlite3, uuid, datetime

DB_FILE = "omega_database.db"

def quick_onboard(name):
    token = str(uuid.uuid4())[:8]
    conn = sqlite3.connect(DB_FILE)
    conn.execute("INSERT INTO candidates (token, name, status, hired_at) VALUES (?, ?, 'ACTIVE', ?)",
                 (token, name, str(datetime.date.today())))
    conn.commit()
    conn.close()
    print(f"🚀 [CLI] Zaměstnanec {name} vytvořen. Token: {token}")

if len(sys.argv) > 2 and sys.argv[1] == "onboard":
    quick_onboard(sys.argv[2])
else:
    print("Použití: omega-cli onboard 'Jméno'")
CLIEOF
chmod +x omega-cli

# 3. UPGRADE JÁDRA (Analytics, Badges, Magic Links)
cat > omega_core.py << 'COREEOF'
#!/data/data/com.termux/files/usr/bin/python
import os, json, uuid, datetime, sqlite3, random
from flask import Flask, request, session, redirect, url_for, render_template, send_from_directory, jsonify
from fpdf import FPDF

app = Flask(__name__)
app.secret_key = os.getenv("API_KEY", "SECURE_ENTERPRISE_KEY_2026")
BASE_DIR = "/data/data/com.termux/files/home/OmegaPlatinum_PROD"
DB_FILE = os.path.join(BASE_DIR, "omega_database.db")
CONTRACTS_PATH = os.path.join(BASE_DIR, "contracts")

def query_db(query, args=(), one=False):
    conn = sqlite3.connect(DB_FILE)
    conn.row_factory = sqlite3.Row
    cur = conn.cursor()
    cur.execute(query, args)
    rv = cur.fetchall()
    conn.commit()
    conn.close()
    return (rv[0] if rv else None) if one else rv

def log_action(action, user='SYSTEM'):
    conn = sqlite3.connect(DB_FILE)
    conn.execute("INSERT INTO audit_logs (timestamp, action, user) VALUES (?, ?, ?)",
                 (datetime.datetime.now().strftime("%H:%M:%S"), action, user))
    conn.commit()
    conn.close()

# --- ASSET AGING LOGIC ---
def get_asset_health():
    assets = query_db("SELECT * FROM assets")
    report = []
    now = datetime.datetime.now()
    for a in assets:
        p_date = datetime.datetime.strptime(a['purchase_date'], '%Y-%m-%d')
        age_months = (now.year - p_date.year) * 12 + now.month - p_date.month
        status = "OK" if age_months < a['warranty_months'] else "REPLACE"
        report.append({"name": a['name'], "sn": a['serial'], "age": age_months, "status": status})
    return report

@app.route('/')
def index():
    if not session.get('logged_in'): return redirect(url_for('login'))
    employees = query_db("SELECT * FROM candidates WHERE status != 'TERMINATED'")
    stock = query_db("SELECT name, count(*) as count FROM assets WHERE owner_token IS NULL GROUP BY name")
    asset_map = {}
    all_assigned = query_db("SELECT * FROM assets WHERE owner_token IS NOT NULL")
    for a in all_assigned:
        if a['owner_token'] not in asset_map: asset_map[a['owner_token']] = []
        asset_map[a['owner_token']].append(a)
    return render_template('index.html', employees=employees, count=len(employees), stock=stock, asset_map=asset_map)

@app.route('/analytics')
def analytics():
    if not session.get('logged_in'): return redirect(url_for('login'))
    health_report = get_asset_health()
    active_count = query_db("SELECT count(*) as count FROM candidates WHERE status='ACTIVE'", one=True)['count']
    return render_template('analytics.html', health_report=health_report, count=active_count)

@app.route('/badge/<token>')
def badge_engine(token):
    emp = query_db("SELECT * FROM candidates WHERE token=?", (token,), one=True)
    if not emp: return "Not Found", 404
    return f"""
    <div style="width:300px; height:400px; background:linear-gradient(135deg, #00a2ff, #00ff9d); border-radius:20px; color:white; font-family:sans-serif; padding:20px; text-align:center; box-shadow:0 10px 30px rgba(0,0,0,0.5);">
        <h2 style="margin-top:40px;">OMEGA ELITE</h2>
        <div style="font-size:3rem; margin:20px 0;">🏆</div>
        <h3>{emp['name']}</h3>
        <p style="font-size:0.8rem; opacity:0.8;">Verified Talent</p>
        <div style="margin-top:50px; font-family:monospace; font-size:0.7rem;">HASH: {uuid.uuid4().hex[:16].upper()}</div>
    </div>
    """

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        if request.form.get('username') == 'admin' and request.form.get('password') == 'admin':
            session['logged_in'], session['user'], session['role'] = True, 'admin', 'SUPERADMIN'
            return redirect(url_for('index'))
    return render_template('login.html')

@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('login'))

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=8080)
COREEOF

# 4. AKTUALIZACE ALIASŮ PRO RYCHLÝ PŘÍSTUP
echo "alias omega-cli='$PROJECT_DIR/omega-cli'" >> ~/.bashrc
source ~/.bashrc 2>/dev/null || true

echo "✅ Konsolidace dokončena."
echo "🚀 Nové funkce aktivní: Asset Aging, CLI Tools, Badge Engine."
echo "💡 Zkus příkaz: omega-cli onboard 'Elon Musk'"
