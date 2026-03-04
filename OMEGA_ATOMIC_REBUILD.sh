#!/data/data/com.termux/files/usr/bin/bash
set -e

PROJ="/data/data/com.termux/files/home/OmegaPlatinum_PROD"
CORE="$PROJ/omega_core.py"
DB="$PROJ/omega_database.db"

echo "🛡️ Zahajuji atomickou rekonstrukci jádra v16.0..."

cat > "$CORE" << 'PYEOF'
import os, sqlite3, hashlib, uuid
from flask import Flask, render_template, request, redirect, url_for, session, send_file
from datetime import datetime

app = Flask(__name__)
# Bezpečnostní oprava: vynucený string pro secret_key
app.secret_key = str(os.getenv("API_KEY", "OMEGA_MASTER_SECRET_2026_PLATINUM"))

def get_db():
    conn = sqlite3.connect("/data/data/com.termux/files/home/OmegaPlatinum_PROD/omega_database.db")
    conn.row_factory = sqlite3.Row
    return conn

def query_db(query, args=(), one=False):
    db = get_db()
    cur = db.execute(query, args)
    rv = cur.fetchall()
    db.commit()
    db.close()
    return (rv[0] if rv else None) if one else rv

def log_action(user, action, details):
    db = get_db()
    db.execute("INSERT INTO audit_logs (timestamp, user, action, details) VALUES (?, ?, ?, ?)",
               (datetime.now().strftime("%Y-%m-%d %H:%M:%S"), user, action, details))
    db.commit()
    db.close()

# --- AUTHENTICATION ---
@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        if request.form['username'] == 'admin' and request.form['password'] == 'omega2026':
            session['logged_in'] = True
            session['user'] = 'admin'
            session['role'] = 'SUPERADMIN'
            return redirect(url_for('index'))
    return '''<form method="post">User: <input name="username"><br>Pass: <input name="password" type="password"><br><button>Login</button></form>'''

@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('login'))

# --- MAIN DASHBOARD ---
@app.route('/')
def index():
    if not session.get('logged_in'): return redirect(url_for('login'))
    employees = query_db("SELECT * FROM candidates WHERE status != 'ARCHIVED'")
    assets = query_db("SELECT * FROM assets")
    return render_template('index.html', employees=employees, assets=assets)

# --- HR & AGENDA MODUL ---
@app.route('/agenda')
def agenda():
    if not session.get('logged_in'): return redirect(url_for('login'))
    employees = query_db("SELECT * FROM candidates WHERE status != 'ARCHIVED'")
    assets = query_db("SELECT * FROM assets WHERE owner_token IS NULL")
    return render_template('agenda.html', employees=employees, assets=assets)

@app.route('/api/update_agenda/<token>', methods=['POST'])
def update_agenda(token):
    ctype = request.form.get('contract_type')
    start = request.form.get('start_date')
    query_db("UPDATE candidates SET contract_type=?, start_date=? WHERE token=?", (ctype, start, token))
    return redirect(url_for('agenda'))

# --- LOGISTIKA & ASSETS ---
@app.route('/assets')
def assets():
    if not session.get('logged_in'): return redirect(url_for('login'))
    items = query_db("SELECT * FROM assets")
    return render_template('assets.html', assets=items)

@app.route('/api/assign_asset', methods=['POST'])
def assign_asset():
    token = request.form.get('token')
    asset_id = request.form.get('asset_id')
    query_db("UPDATE assets SET owner_token=?, status='ASSIGNED' WHERE id=?", (token, asset_id))
    log_action(session.get('user'), "ASSET_ASSIGN", f"Asset {asset_id} to {token}")
    return redirect(request.referrer)

@app.route('/api/unassign_asset/<int:asset_id>')
def unassign_asset(asset_id):
    query_db("UPDATE assets SET owner_token=NULL, status='IN_STOCK' WHERE id=?", (asset_id,))
    return redirect(request.referrer)

# --- FINANCE MODUL (MODUL C) ---
@app.route('/admin/finance')
def finance():
    if not session.get('logged_in'): return redirect(url_for('login'))
    employees = query_db("SELECT name, salary_base, tax_rate, insurance_rate FROM candidates WHERE status IN ('ACTIVE', 'CONTRACT_SIGNED')")
    stats = []
    total_cost = 0
    for e in employees:
        sal = float(e['salary_base'] or 0)
        tax, ins = sal * 0.15, sal * 0.11
        netto = sal - tax - ins
        cost = sal * 1.34
        stats.append({'name': e['name'], 'brutto': sal, 'netto': netto, 'cost': cost})
        total_cost += cost
    return render_template('finance_admin.html', stats=stats, total=total_cost)

# --- SPRÁVA ÚČTŮ & IDENTITY (MODUL A + SPRÁVA) ---
@app.route('/manage/users')
def manage_users():
    if not session.get('logged_in'): return redirect(url_for('login'))
    users = query_db("SELECT * FROM candidates")
    return render_template('manage_users.html', employees=users)

@app.route('/admin/identities')
def admin_identities():
    if not session.get('logged_in'): return redirect(url_for('login'))
    users = query_db("SELECT * FROM candidates")
    return render_template('admin_identities.html', users=users)

@app.route('/admin/reset_identity/<token>')
def reset_identity(token):
    query_db("UPDATE candidates SET is_verified=0, mojeid_sub=NULL, full_name_mojeid=NULL WHERE token=?", (token,))
    log_action(session.get('user'), "GDPR_PURGE", f"Identity reset for {token}")
    return redirect(request.referrer)

# --- SMLOUVY & DOKUMENTY (MODUL B) ---
@app.route('/manage/contracts')
def manage_contracts():
    if not session.get('logged_in'): return redirect(url_for('login'))
    employees = query_db("SELECT * FROM candidates")
    return render_template('manage_contracts.html', employees=employees)

@app.route('/api/sign_contract/<token>')
def sign_contract(token):
    sig = hashlib.sha256(f"{token}-{datetime.now()}".encode()).hexdigest()
    query_db("UPDATE candidates SET contract_hash=?, status='CONTRACT_SIGNED' WHERE token=?", (sig, token))
    log_action("SYSTEM", "SIGNATURE", f"Signed: {token}")
    return redirect(request.referrer)

# --- SYSTÉMOVÉ ---
@app.route('/audit')
def audit():
    if not session.get('logged_in'): return redirect(url_for('login'))
    logs = query_db("SELECT * FROM audit_logs ORDER BY timestamp DESC LIMIT 100")
    return render_template('audit.html', logs=logs)

@app.route('/manage/others')
def manage_others():
    return "<h1>Systémová nastavení</h1><p>Backup, API, Network Scan.</p><a href='/'>Zpět</a>"

@app.route('/my_data/<token>')
def my_data(token):
    u = query_db("SELECT * FROM candidates WHERE token=?", (token,), one=True)
    return render_template('gdpr_export.html', u=dict(u) if u else {})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080, debug=True)
PYEOF

echo "✅ Jádro bylo atomicky sestaveno bez duplicit."
pkill -f "omega_core.py" || true
echo "🚀 Spouštím čistou instanci Omega Platinum v16.0..."
python3 "$CORE"
