#!/data/data/com.termux/files/usr/bin/bash
set -e
cd /data/data/com.termux/files/home/OmegaPlatinum_PROD

echo "🧹 1. Totální čistka procesů..."
pkill -9 python3 || true
pkill -9 zrok || true

echo "⚙️ 2. Oprava struktury omega_core.py (Zjednodušení na krev)..."
cat > omega_core.py << 'PYEOF'
import os, json, uuid, datetime
from flask import Flask, request, session, redirect, url_for, render_template

app = Flask(__name__)
app.secret_key = 'omega_platinum_secret'
db_path = "/data/data/com.termux/files/home/OmegaPlatinum_PROD/db"

def log_action(user, action, target="", details="", category="HR"):
    log_file = os.path.join(db_path, "audit_log.json")
    entry = {"timestamp": datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"), "user": user, "action": action, "target": target, "details": details, "category": category}
    try:
        logs = json.load(open(log_file, 'r')) if os.path.exists(log_file) else []
        logs.insert(0, entry)
        json.dump(logs[:100], open(log_file, 'w'), indent=4)
    except: pass

@app.route('/')
def index(): return render_template('index.html')

@app.route('/new', methods=['GET', 'POST'])
def new_candidate():
    if request.method == 'POST':
        token = str(uuid.uuid4())[:8]
        data = {"personal_data": {"name": request.form.get('name'), "surname": request.form.get('surname')}, "hr_data": {"salary": request.form.get('salary', '85000')}, "token": token}
        with open(os.path.join(db_path, f"{token}.json"), 'w') as f:
            json.dump(data, f, indent=4)
        log_action("Admin", "Nábor", token)
        return redirect(url_for('index'))
    return render_template('new.html')

@app.route('/hr/lifecycle/<token>', methods=['POST'])
def hr_lifecycle(token):
    path = os.path.join(db_path, f"{token}.json")
    if os.path.exists(path):
        data = json.load(open(path, 'r'))
        if request.form.get('action') == 'salary':
            data['hr_data']['salary'] = request.form.get('new_salary')
        if os.path.exists(path): os.remove(path)
        json.dump(data, open(path, 'w'), indent=4)
        log_action("Admin", "Změna platu", token)
    return redirect(url_for('index'))

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=8080)
PYEOF

echo "🚀 3. Start serveru v Ubuntu (Port 8080)..."
proot-distro login ubuntu -- bash -c "cd /data/data/com.termux/files/home/OmegaPlatinum_PROD && nohup python3 omega_core.py > server_ubuntu.log 2>&1 &"

sleep 3
echo "🧪 4. Kontrola lokální dostupnosti v Ubuntu..."
proot-distro login ubuntu -- bash -c "curl -s http://127.0.0.1:8080 > /dev/null && echo '✅ SERVER VNITŘNĚ BĚŽÍ' || echo '❌ SERVER NEODPOVÍDÁ'"

echo "============================================================"
echo "HOTOVO. Nyní v druhém okně restartuj zrok příkazem:"
echo "zrok share reserved p3085t3mscgc"
echo "============================================================"
