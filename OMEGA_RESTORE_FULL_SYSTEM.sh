#!/data/data/com.termux/files/usr/bin/bash
set -e
cd /data/data/com.termux/files/home/OmegaPlatinum_PROD

echo "🛠️ Obnovuji plnohodnotné jádro Omega Platinum PROD..."

cat > omega_core.py << 'PYEOF'
import os, json, uuid, datetime
from flask import Flask, request, session, redirect, url_for, render_template

app = Flask(__name__)
app.secret_key = 'omega_platinum_prod_secret_key'
db_path = "/data/data/com.termux/files/home/OmegaPlatinum_PROD/db"
contracts_path = "/data/data/com.termux/files/home/OmegaPlatinum_PROD/contracts"

# Zajištění složek
for p in [db_path, contracts_path]:
    os.makedirs(p, exist_ok=True)

def log_action(user, action, target="", details="", category="HR"):
    log_file = os.path.join(db_path, "audit_log.json")
    entry = {
        "timestamp": datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "user": user, "action": action, "target": target, 
        "details": details, "category": category
    }
    try:
        logs = []
        if os.path.exists(log_file):
            with open(log_file, 'r', encoding='utf-8') as f:
                logs = json.load(f)
        logs.insert(0, entry)
        with open(log_file, 'w', encoding='utf-8') as f:
            json.dump(logs[:500], f, indent=4, ensure_ascii=False)
    except: pass

def gen_pdf(token, type='contract'):
    # Generování dokumentu (pro Termux/Ubuntu simulaci jako textový PDF)
    filename = f"{type}_{token}.pdf"
    full_path = os.path.join(contracts_path, filename)
    with open(full_path, 'w', encoding='utf-8') as f:
        f.write(f"--- OMEGA PLATINUM OFFICIAL DOCUMENT ---\n")
        f.write(f"Typ: {type.upper()}\nReference: {token}\nDatum: {datetime.datetime.now()}\nStatus: VALIDATED")
    return filename

@app.route('/')
def index():
    if not session.get('logged_in'): return redirect(url_for('login'))
    return render_template('index.html')

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        u, p = request.form.get('username'), request.form.get('password')
        if (u == 'admin' and p == 'admin') or (u == 'hr' and p == 'hr'):
            session['logged_in'] = True
            session['user'] = u
            log_action(u, "Přihlášení", "", "Vstup do systému")
            return redirect(url_for('index'))
    return '''<body style="background:#0a0a0a;color:#fff;font-family:sans-serif;display:flex;justify-content:center;align-items:center;height:100vh;margin:0;">
                <form method="post" style="background:#111;padding:40px;border-radius:15px;border:1px solid #333;width:300px;box-shadow:0 10px 30px rgba(0,0,0,0.5);">
                    <h1 style="color:#3498db;margin:0 0 10px 0;">OMEGA<span style="color:#fff">PROD</span></h1>
                    <p style="color:#666;font-size:0.8em;margin-bottom:20px;">Secure Management Console</p>
                    <input name="username" placeholder="Uživatel" style="width:100%;padding:12px;margin-bottom:15px;background:#222;border:1px solid #444;color:white;">
                    <input name="password" type="password" placeholder="Heslo" style="width:100%;padding:12px;margin-bottom:20px;background:#222;border:1px solid #444;color:white;">
                    <button type="submit" style="width:100%;padding:12px;background:#3498db;color:white;border:none;border-radius:5px;cursor:pointer;font-weight:bold;">VSTOUPIT</button>
                </form></body>'''

@app.route('/new', methods=['GET', 'POST'])
def new_candidate():
    if not session.get('logged_in'): return redirect(url_for('login'))
    if request.method == 'POST':
        token = str(uuid.uuid4())[:8]
        data = {
            "personal_data": {"name": request.form.get('name'), "surname": request.form.get('surname'), "email": request.form.get('email')},
            "hr_data": {"position": request.form.get('position', 'Staff'), "salary": request.form.get('salary', '55000')},
            "token": token, "status": "Aktivní", "created_at": str(datetime.datetime.now())
        }
        path = os.path.join(db_path, f"{token}.json")
        with open(path, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=4, ensure_ascii=False)
        gen_pdf(token, 'contract')
        log_action(session.get('user'), "Nábor", token, f"Nový zaměstnanec: {request.form.get('surname')}")
        return redirect(url_for('index'))
    return render_template('new.html')

@app.route('/hr/lifecycle/<token>', methods=['POST'])
def hr_lifecycle(token):
    if not session.get('logged_in'): return redirect(url_for('login'))
    path = os.path.join(db_path, f"{token}.json")
    if os.path.exists(path):
        with open(path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        action = request.form.get('action')
        if action == 'salary':
            old_val = data['hr_data']['salary']
            new_val = request.form.get('new_salary')
            data['hr_data']['salary'] = new_val
            log_action(session.get('user'), "Změna platu", token, f"Z {old_val} na {new_val}")
        
        # Bezpečný přepis (smazat a vytvořit znovu kvůli právům v proot)
        os.remove(path)
        with open(path, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=4, ensure_ascii=False)
            
    return redirect(url_for('index'))

@app.route('/api/stats')
def stats():
    files = [f for f in os.listdir(db_path) if f.endswith('.json') and f != 'audit_log.json']
    return {"employees_count": len(files), "system": "Omega Platinum PROD"}

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
PYEOF

echo "♻️ Restartuji Python proces uvnitř Ubuntu..."
proot-distro login ubuntu -- bash -c "pkill -9 python3 || true"
sleep 1
proot-distro login ubuntu -- bash -c "cd /data/data/com.termux/files/home/OmegaPlatinum_PROD && nohup python3 omega_core.py > server_ubuntu.log 2>&1 &"

echo "✅ Plná verze obnovena a běží na portu 8080."
