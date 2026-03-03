#!/data/data/com.termux/files/usr/bin/bash
set -e
cd /data/data/com.termux/files/home/OmegaPlatinum_PROD

echo "💎 Upgraduji Omega Platinum na plnou PROD verzi..."

cat > omega_core.py << 'PYEOF'
import os, json, uuid, datetime
from flask import Flask, request, session, redirect, url_for, render_template

app = Flask(__name__)
app.secret_key = 'omega_platinum_ultra_secret_2026'

# Cesty k datům
BASE_DIR = "/data/data/com.termux/files/home/OmegaPlatinum_PROD"
DB_PATH = os.path.join(BASE_DIR, "db")
CONTRACTS_PATH = os.path.join(BASE_DIR, "contracts")

# Inicializace struktury
for folder in [DB_PATH, CONTRACTS_PATH]:
    os.makedirs(folder, exist_ok=True)

def log_action(user, action, target="", details="", category="SYSTEM"):
    log_file = os.path.join(DB_PATH, "audit_log.json")
    entry = {
        "timestamp": datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "user": user,
        "action": action,
        "target": target,
        "details": details,
        "category": category
    }
    try:
        logs = []
        if os.path.exists(log_file):
            with open(log_file, 'r', encoding='utf-8') as f:
                logs = json.load(f)
        logs.insert(0, entry)
        with open(log_file, 'w', encoding='utf-8') as f:
            json.dump(logs[:1000], f, indent=4, ensure_ascii=False)
    except Exception as e:
        print(f"Log Error: {e}")

def create_pdf_contract(token, name, surname, position, salary):
    filename = f"CONTRACT_{token}_{surname}.pdf"
    full_path = os.path.join(CONTRACTS_PATH, filename)
    with open(full_path, 'w', encoding='utf-8') as f:
        f.write("====================================================\n")
        f.write("          OMEGA PLATINUM - PRACOVNÍ SMLOUVA         \n")
        f.write("====================================================\n\n")
        f.write(f"ID ZAMĚSTNANCE: {token}\n")
        f.write(f"JMÉNO: {name} {surname}\n")
        f.write(f"POZICE: {position}\n")
        f.write(f"NÁSTUPNÍ PLAT: {salary} CZK\n")
        f.write(f"DATUM GENERACE: {datetime.datetime.now()}\n\n")
        f.write("----------------------------------------------------\n")
        f.write("Tento dokument je digitálně podepsán systémem OMEGA.\n")
    return filename

@app.route('/')
def index():
    if not session.get('logged_in'): return redirect(url_for('login'))
    
    # Načtení statistik pro dashboard
    files = [f for f in os.listdir(DB_PATH) if f.endswith('.json') and f != 'audit_log.json']
    employees = []
    total_salary = 0
    
    for f in files:
        with open(os.path.join(DB_PATH, f), 'r') as j:
            d = json.load(j)
            employees.append(d)
            try: total_salary += int(d['hr_data']['salary'])
            except: pass

    return render_template('index.html', 
                         count=len(employees), 
                         avg_salary=int(total_salary/len(employees)) if employees else 0,
                         employees=employees[:5])

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        u, p = request.form.get('username'), request.form.get('password')
        if (u == 'admin' and p == 'admin') or (u == 'hr' and p == 'hr'):
            session['logged_in'] = True
            session['user'] = u
            log_action(u, "LOGIN", "", "Úspěšný vstup do PROD jádra")
            return redirect(url_for('index'))
    return render_template('login.html')

@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('login'))

@app.route('/new', methods=['GET', 'POST'])
def new_candidate():
    if not session.get('logged_in'): return redirect(url_for('login'))
    if request.method == 'POST':
        token = str(uuid.uuid4())[:8]
        name = request.form.get('name')
        surname = request.form.get('surname')
        pos = request.form.get('position', 'Specialista')
        sal = request.form.get('salary', '60000')
        
        data = {
            "personal_data": {"name": name, "surname": surname, "email": request.form.get('email')},
            "hr_data": {"position": pos, "salary": sal},
            "token": token,
            "status": "AKTIVNÍ",
            "hired_at": str(datetime.date.today())
        }
        
        path = os.path.join(DB_PATH, f"{token}.json")
        with open(path, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=4, ensure_ascii=False)
        
        create_pdf_contract(token, name, surname, pos, sal)
        log_action(session['user'], "NÁBOR", token, f"Nový zaměstnanec: {name} {surname}")
        return redirect(url_for('index'))
    return render_template('new.html')

@app.route('/hr/lifecycle/<token>', methods=['POST'])
def hr_lifecycle(token):
    if not session.get('logged_in'): return redirect(url_for('login'))
    path = os.path.join(DB_PATH, f"{token}.json")
    if os.path.exists(path):
        with open(path, 'r') as f: data = json.load(f)
        
        action = request.form.get('action')
        if action == 'salary':
            old = data['hr_data']['salary']
            new = request.form.get('new_salary')
            data['hr_data']['salary'] = new
            log_action(session['user'], "PLAT", token, f"Zvýšení z {old} na {new}")
        
        # Bezpečný přepis
        if os.path.exists(path): os.remove(path)
        with open(path, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=4, ensure_ascii=False)
            
    return redirect(url_for('index'))

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
PYEOF

echo "✅ Upgrade dokončen. Nyní v Ubuntu okně znovu spusť: python3 omega_core.py"
