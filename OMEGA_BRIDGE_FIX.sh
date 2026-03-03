#!/data/data/com.termux/files/usr/bin/bash
set -e

PROJECT_DIR="/data/data/com.termux/files/home/OmegaPlatinum_PROD"
cd $PROJECT_DIR

echo "🔗 Propojuji osiřelé šablony s jádrem systému..."

# Kompletní přepis jádra se všemi funkčními routami
cat > omega_core.py << 'PYEOF'
#!/data/data/com.termux/files/usr/bin/python
import os, json, uuid, datetime, sqlite3, random
from flask import Flask, request, session, redirect, url_for, render_template, send_from_directory, jsonify
from fpdf import FPDF

app = Flask(__name__)
app.secret_key = os.getenv("API_KEY", "SECURE_ENTERPRISE_KEY_2026")
BASE_DIR = "/data/data/com.termux/files/home/OmegaPlatinum_PROD"
DB_FILE = os.path.join(BASE_DIR, "omega_database.db")
CONTRACTS_PATH = os.path.join(BASE_DIR, "contracts")

# --- CORE UTILS ---
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

# --- ROUTES ---

@app.route('/')
def index():
    if not session.get('logged_in'): return redirect(url_for('login'))
    employees = query_db("SELECT * FROM candidates WHERE status != 'TERMINATED'")
    stock = query_db("SELECT name, count(*) as count FROM assets WHERE owner_token IS NULL GROUP BY name")
    asset_map = {a['owner_token']: [] for a in query_db("SELECT owner_token FROM assets WHERE owner_token IS NOT NULL")}
    for a in query_db("SELECT * FROM assets WHERE owner_token IS NOT NULL"):
        asset_map[a['owner_token']].append(a)
    return render_template('index.html', employees=employees, count=len(employees), stock=stock, asset_map=asset_map)

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
        name = request.form.get('surname')
        mojeid = f"ID-{str(uuid.uuid4())[:4].upper()}"
        query_db("INSERT INTO candidates (token, name, mojeid_sub, status, hired_at) VALUES (?, ?, ?, 'ACTIVE', ?)", 
                 (token, name, mojeid, str(datetime.date.today())))
        log_action(f"Vytvořen nový profil: {name}")
        return redirect(url_for('index'))
    return render_template('new.html')

@app.route('/welcome/<token>')
def welcome_portal(token):
    emp = query_db("SELECT * FROM candidates WHERE token = ?", (token,), one=True)
    if not emp: return render_template('404.html'), 404
    assets = query_db("SELECT * FROM assets WHERE owner_token = ?", (token,))
    return render_template('welcome_portal.html', emp=emp, assets=assets)

@app.route('/analytics')
def analytics():
    if not session.get('logged_in'): return redirect(url_for('login'))
    # Logika pro aging i compliance
    active_count = query_db("SELECT count(*) as count FROM candidates WHERE status='ACTIVE'", one=True)['count']
    return render_template('analytics.html', count=active_count)

@app.route('/badge/<token>')
def badge(token):
    emp = query_db("SELECT * FROM candidates WHERE token = ?", (token,), one=True)
    if not emp: return "Not Found", 404
    return render_template('candidate.html', emp=emp) # Propojení s candidate.html

@app.errorhandler(404)
def page_not_found(e):
    return render_template('404.html'), 404

@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('login'))

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=8080)
PYEOF

echo "✅ Jádro bylo re-linkováno. Nyní spustím audit znovu pro ověření..."
chmod +x omega_core.py
./OMEGA_INTEGRITY_AUDITOR.sh
