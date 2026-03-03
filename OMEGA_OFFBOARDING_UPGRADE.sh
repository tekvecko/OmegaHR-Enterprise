#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "🧹 Integruji Offboarding & Asset Recovery Module..."

cat > omega_core.py << 'PYEOF'
#!/data/data/com.termux/files/usr/bin/python
import os, json, uuid, datetime, sqlite3, random
from flask import Flask, request, session, redirect, url_for, render_template, send_from_directory, jsonify

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

# --- ENTERPRISE FUNKCE 13: RECOVERY PROTOKOL (VRÁCENÍ MAJETKU) ---
def generate_recovery_protocol(token, name, assets):
    filename = f"RECOVERY_{token}_{name.replace(' ', '_')}.txt"
    path = os.path.join(CONTRACTS_PATH, filename)
    with open(path, 'w', encoding='utf-8') as f:
        f.write("====================================================\n")
        f.write("       PROTOKOL O VRÁCENÍ PRACOVNÍCH PROSTŘEDKŮ     \n")
        f.write("====================================================\n\n")
        f.write(f"ZAMĚSTNANEC:  {name}\n")
        f.write(f"ID TOKEN:     {token}\n")
        f.write(f"DATUM VÝSTUPU: {datetime.date.today()}\n\n")
        f.write("Níže uvedené položky byly v pořádku vráceny:\n")
        f.write("-" * 52 + "\n")
        for asset in assets:
            f.write(f"[✓] {asset['name']:<20} | SN: {asset['serial']} | STAV: OK\n")
        f.write("-" * 52 + "\n\n")
        f.write("Potvrzujeme, že zaměstnanec vypořádal veškeré závazky\n")
        f.write("vůči OMEGA PLATINUM CORE.\n\n")
        f.write(f"ARD ARCHIVNÍ KÓD: {uuid.uuid4().hex.upper()}\n")
        f.write("====================================================\n")
    return filename

@app.route('/')
def index():
    if not session.get('logged_in'): return redirect(url_for('login'))
    employees = query_db("SELECT * FROM candidates WHERE status != 'TERMINATED'")
    all_assets = query_db("SELECT * FROM assets")
    asset_map = {a['owner_token']: [] for a in all_assets if a['owner_token']}
    for a in all_assets:
        if a['owner_token'] in asset_map:
            asset_map[a['owner_token']].append({"name": a['name'], "serial": a['serial']})
    return render_template('index.html', employees=employees, count=len(employees), asset_map=asset_map)

# --- ENTERPRISE FUNKCE 14: OFFBOARDING LOGIKA ---
@app.route('/offboard/<token>', methods=['POST'])
def offboard_employee(token):
    if not session.get('logged_in'): return redirect(url_for('login'))
    
    # 1. Získání dat o zaměstnanci a jeho majetku
    emp = query_db("SELECT name FROM candidates WHERE token = ?", (token,), one=True)
    assets = query_db("SELECT name, serial FROM assets WHERE owner_token = ?", (token,))
    
    if emp:
        # 2. Generování protokolu o vrácení
        generate_recovery_protocol(token, emp['name'], assets)
        
        # 3. Uvolnění assetů (owner_token = NULL)
        query_db("UPDATE assets SET owner_token = NULL, status = 'available' WHERE owner_token = ?", (token,))
        
        # 4. Deaktivace zaměstnance
        query_db("UPDATE candidates SET status = 'TERMINATED', stage = 'offboarded' WHERE token = ?", (token,))
        
        print(f"🧹 Offboarding dokončen pro: {emp['name']}")
        
    return redirect(url_for('index'))

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        if request.form.get('username') == 'admin' and request.form.get('password') == 'admin':
            session['logged_in'], session['user'], session['role'] = True, 'admin', 'SUPERADMIN'
            return redirect(url_for('index'))
    return render_template('login.html')

@app.route('/new', methods=['GET', 'POST'])
def new_employee():
    if not session.get('logged_in'): return redirect(url_for('login'))
    if request.method == 'POST':
        token = str(uuid.uuid4())[:8]
        moje_id = f"ID-{str(uuid.uuid4())[:4].upper()}"
        surname = request.form.get('surname')
        query_db("INSERT INTO candidates (token, name, mojeid_sub, hr_data, status, hired_at) VALUES (?, ?, ?, ?, 'ACTIVE', ?)", 
                 (token, surname, moje_id, "{}", str(datetime.date.today())))
        
        # Auto-assignment (MBP a Phone)
        for name, prefix in [("MacBook Pro 14", "MBP-"), ("iPhone 15 Pro", "IPH-")]:
            sn = f"{prefix}{random.randint(1000, 9999)}"
            query_db("INSERT INTO assets (name, serial, type, owner_token, assigned_date, status) VALUES (?, ?, 'HW', ?, ?, 'assigned')",
                     (name, sn, token, str(datetime.date.today())))
        return redirect(url_for('index'))
    return render_template('new.html')

@app.route('/contracts/<path:filename>')
def download(filename):
    return send_from_directory(CONTRACTS_PATH, filename)

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=8080)
PYEOF

echo "✅ Offboarding modul integrován. Restartuj omega_core.py."
