#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "🛠️ Integruji Automatic Asset Assignment Module..."

# Aktualizace Python jádra
cat > omega_core.py << 'PYEOF'
#!/data/data/com.termux/files/usr/bin/python
import os, json, uuid, datetime, sqlite3, random
from flask import Flask, request, session, redirect, url_for, render_template, send_from_directory, jsonify

app = Flask(__name__)
app.secret_key = os.getenv("API_KEY", "SECURE_ENTERPRISE_KEY_2026")

BASE_DIR = "/data/data/com.termux/files/home/OmegaPlatinum_PROD"
DB_FILE = os.path.join(BASE_DIR, "omega_database.db")

def query_db(query, args=(), one=False):
    conn = sqlite3.connect(DB_FILE)
    conn.row_factory = sqlite3.Row
    cur = conn.cursor()
    cur.execute(query, args)
    rv = cur.fetchall()
    conn.commit()
    conn.close()
    return (rv[0] if rv else None) if one else rv

# --- ENTERPRISE FUNKCE 11: AUTOMATICKÝ GENERÁTOR MAJETKU ---
def assign_assets(token):
    assets = [
        {"name": "MacBook Pro 14", "type": "LAPTOP", "serial_prefix": "MBP-2026-"},
        {"name": "iPhone 15 Pro", "type": "PHONE", "serial_prefix": "IPH-15-"},
        {"name": "Dell UltraSharp 27", "type": "MONITOR", "serial_prefix": "DEL-US-"}
    ]
    
    for asset in assets:
        serial = f"{asset['serial_prefix']}{random.randint(1000, 9999)}"
        query_db("INSERT INTO assets (name, serial, type, owner_token, assigned_date) VALUES (?, ?, ?, ?, ?)",
                 (asset['name'], serial, asset['type'], token, str(datetime.date.today())))

@app.route('/')
def index():
    if not session.get('logged_in'): return redirect(url_for('login'))
    employees = query_db("SELECT * FROM candidates")
    # Načtení majetku pro zobrazení v dashboardu
    all_assets = query_db("SELECT * FROM assets")
    asset_map = {}
    for a in all_assets:
        if a['owner_token'] not in asset_map: asset_map[a['owner_token']] = []
        asset_map[a['owner_token']].append(f"{a['name']} ({a['serial']})")
        
    stats = query_db("SELECT count(*) as count FROM candidates", one=True)
    return render_template('index.html', employees=employees, count=stats['count'], asset_map=asset_map)

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        u, p = request.form.get('username'), request.form.get('password')
        if u == 'admin' and p == 'admin':
            session['logged_in'], session['user'], session['role'] = True, u, 'SUPERADMIN'
            return redirect(url_for('index'))
    return render_template('login.html')

@app.route('/new', methods=['GET', 'POST'])
def new_employee():
    if not session.get('logged_in'): return redirect(url_for('login'))
    if request.method == 'POST':
        token = str(uuid.uuid4())[:8]
        moje_id = f"ID-{str(uuid.uuid4())[:4].upper()}"
        hr_data = json.dumps({"position": request.form.get('position'), "salary": request.form.get('salary')})
        onboarding = json.dumps({"it_hardware": "done", "security_training": "pending", "access_card": "pending"})
        
        query_db("INSERT INTO candidates (token, name, mojeid_sub, hr_data, onboarding, status, hired_at) VALUES (?, ?, ?, ?, ?, 'NEW', ?)", 
                 (token, request.form.get('surname'), moje_id, hr_data, onboarding, str(datetime.date.today())))
        
        # SPUŠTĚNÍ AUTOMATICKÉHO PŘIŘAZENÍ MAJETKU
        assign_assets(token)
        
        return redirect(url_for('index'))
    return render_template('new.html')

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=8080)
PYEOF

echo "✅ Asset Module integrován. Restartuj aplikaci."
