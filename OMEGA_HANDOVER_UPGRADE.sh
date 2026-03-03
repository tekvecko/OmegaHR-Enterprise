#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "📄 Integruji Handover Protocol Engine..."

cat > omega_core.py << 'PYEOF'
#!/data/data/com.termux/files/usr/bin/python
import os, json, uuid, datetime, sqlite3, random
from flask import Flask, request, session, redirect, url_for, render_template, send_from_directory, jsonify

app = Flask(__name__)
app.secret_key = os.getenv("API_KEY", "SECURE_ENTERPRISE_KEY_2026")

BASE_DIR = "/data/data/com.termux/files/home/OmegaPlatinum_PROD"
DB_FILE = os.path.join(BASE_DIR, "omega_database.db")
CONTRACTS_PATH = os.path.join(BASE_DIR, "contracts")

os.makedirs(CONTRACTS_PATH, exist_ok=True)

def query_db(query, args=(), one=False):
    conn = sqlite3.connect(DB_FILE)
    conn.row_factory = sqlite3.Row
    cur = conn.cursor()
    cur.execute(query, args)
    rv = cur.fetchall()
    conn.commit()
    conn.close()
    return (rv[0] if rv else None) if one else rv

# --- ENTERPRISE FUNKCE 12: GENERÁTOR PŘEDÁVACÍHO PROTOKOLU ---
def generate_handover_protocol(token, name, moje_id, assets):
    filename = f"HANDOVER_{token}_{name.replace(' ', '_')}.txt"
    path = os.path.join(CONTRACTS_PATH, filename)
    
    with open(path, 'w', encoding='utf-8') as f:
        f.write("====================================================\n")
        f.write("       PROTOKOL O SVĚŘENÍ PRACOVNÍCH PROSTŘEDKŮ      \n")
        f.write("====================================================\n\n")
        f.write(f"ZAMĚSTNANEC:  {name}\n")
        f.write(f"MOJEID TOKEN: {moje_id}\n")
        f.write(f"DATUM:        {datetime.date.today()}\n\n")
        f.write("Níže uvedené položky byly předány do užívání:\n")
        f.write("-" * 52 + "\n")
        for asset in assets:
            f.write(f"[*] {asset['name']:<20} | SN: {asset['serial']}\n")
        f.write("-" * 52 + "\n\n")
        f.write("Zaměstnanec potvrzuje převzetí a souhlasí s odpovědností\n")
        f.write("za ztrátu nebo poškození svěřených předmětů.\n\n")
        f.write(f"DIGITÁLNÍ PODPIS OMEGA: {uuid.uuid4().hex.upper()}\n")
        f.write("====================================================\n")
    return filename

@app.route('/')
def index():
    if not session.get('logged_in'): return redirect(url_for('login'))
    employees = query_db("SELECT * FROM candidates")
    all_assets = query_db("SELECT * FROM assets")
    asset_map = {}
    for a in all_assets:
        if a['owner_token'] not in asset_map: asset_map[a['owner_token']] = []
        asset_map[a['owner_token']].append({"name": a['name'], "serial": a['serial']})
        
    return render_template('index.html', employees=employees, count=len(employees), asset_map=asset_map)

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
        
        # 1. Uložení do DB
        query_db("INSERT INTO candidates (token, name, mojeid_sub, hr_data, status, hired_at) VALUES (?, ?, ?, ?, 'NEW', ?)", 
                 (token, surname, moje_id, "{}", str(datetime.date.today())))
        
        # 2. Automatické přiřazení majetku
        assigned = []
        asset_types = [("MacBook Pro 14", "MBP-"), ("iPhone 15 Pro", "IPH-"), ("YubiKey 5C", "YUB-")]
        for name, prefix in asset_types:
            sn = f"{prefix}{random.randint(1000, 9999)}"
            query_db("INSERT INTO assets (name, serial, type, owner_token, assigned_date) VALUES (?, ?, 'HW', ?, ?)",
                     (name, sn, token, str(datetime.date.today())))
            assigned.append({"name": name, "serial": sn})
        
        # 3. Generování protokolu
        generate_handover_protocol(token, surname, moje_id, assigned)
        
        return redirect(url_for('index'))
    return render_template('new.html')

@app.route('/contracts/<path:filename>')
def download(filename):
    return send_from_directory(CONTRACTS_PATH, filename)

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=8080)
PYEOF

echo "✅ Handover Engine připraven. Restartuj omega_core.py."
