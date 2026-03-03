#!/data/data/com.termux/files/usr/bin/bash
set -e
cd /data/data/com.termux/files/home/OmegaPlatinum_PROD

echo "💎 RESTAURACE KOMPLETNÍHO SYSTÉMU OMEGA PLATINUM PROD..."

# 1. TVORBA SLOŽEK
mkdir -p db contracts templates

# 2. TVORBA JÁDRA (omega_core.py)
cat > omega_core.py << 'PYEOF'
import os, json, uuid, datetime
from flask import Flask, request, session, redirect, url_for, render_template

app = Flask(__name__)
app.secret_key = 'omega_ultra_secret_2026'

BASE_DIR = "/data/data/com.termux/files/home/OmegaPlatinum_PROD"
DB_PATH = os.path.join(BASE_DIR, "db")
CONTRACTS_PATH = os.path.join(BASE_DIR, "contracts")

def log_action(user, action, target="", details=""):
    log_file = os.path.join(DB_PATH, "audit_log.json")
    entry = {
        "timestamp": datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "user": user, "action": action, "target": target, "details": details
    }
    try:
        logs = json.load(open(log_file, 'r')) if os.path.exists(log_file) else []
        logs.insert(0, entry)
        with open(log_file, 'w') as f: json.dump(logs[:500], f, indent=4)
    except: pass

@app.route('/')
def index():
    if not session.get('logged_in'): return redirect(url_for('login'))
    files = [f for f in os.listdir(DB_PATH) if f.endswith('.json') and f != 'audit_log.json']
    employees = []
    total_sal = 0
    for f in files:
        with open(os.path.join(DB_PATH, f), 'r') as j:
            d = json.load(j)
            employees.append(d)
            total_sal += int(d['hr_data']['salary'])
    avg = int(total_sal / len(employees)) if employees else 0
    return render_template('index.html', employees=employees, count=len(employees), avg=avg)

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        if request.form.get('username') == 'admin' and request.form.get('password') == 'admin':
            session['logged_in'], session['user'] = True, 'admin'
            log_action('admin', 'LOGIN', details='Vstup do systému')
            return redirect(url_for('index'))
    return render_template('login.html')

@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('login'))

@app.route('/new', methods=['GET', 'POST'])
def new_employee():
    if not session.get('logged_in'): return redirect(url_for('login'))
    if request.method == 'POST':
        token = str(uuid.uuid4())[:8]
        data = {
            "personal_data": {"name": request.form.get('name'), "surname": request.form.get('surname'), "email": request.form.get('email')},
            "hr_data": {"position": request.form.get('position'), "salary": request.form.get('salary')},
            "token": token, "hired_at": str(datetime.date.today())
        }
        with open(os.path.join(DB_PATH, f"{token}.json"), 'w') as f:
            json.dump(data, f, indent=4)
        log_action(session['user'], 'NÁBOR', token, f"{data['personal_data']['surname']}")
        return redirect(url_for('index'))
    return render_template('new.html')

@app.route('/hr/lifecycle/<token>', methods=['POST'])
def lifecycle(token):
    if not session.get('logged_in'): return redirect(url_for('login'))
    path = os.path.join(DB_PATH, f"{token}.json")
    if os.path.exists(path):
        data = json.load(open(path, 'r'))
        if request.form.get('action') == 'salary':
            old = data['hr_data']['salary']
            data['hr_data']['salary'] = request.form.get('new_salary')
            log_action(session['user'], 'PLAT', token, f"Z {old} na {data['hr_data']['salary']}")
        os.remove(path)
        with open(path, 'w') as f: json.dump(data, f, indent=4)
    return redirect(url_for('index'))

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
PYEOF

# 3. TVORBA ŠABLON (HTML)
cat > templates/index.html << 'HOF'
<!DOCTYPE html>
<html lang="cs">
<head>
    <meta charset="UTF-8">
    <title>OMEGA PLATINUM - Dashboard</title>
    <style>
        body { background: #0a0a0a; color: #eee; font-family: 'Segoe UI', sans-serif; margin: 0; }
        .nav { background: #111; padding: 15px 50px; display: flex; justify-content: space-between; border-bottom: 2px solid #3498db; }
        .container { padding: 30px; }
        .stats { display: flex; gap: 20px; margin-bottom: 30px; }
        .card { background: #151515; padding: 20px; border-radius: 8px; flex: 1; border-left: 4px solid #3498db; }
        table { width: 100%; border-collapse: collapse; background: #111; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #222; }
        .btn { background: #3498db; color: white; padding: 8px 15px; text-decoration: none; border-radius: 4px; border: none; cursor: pointer; }
        .btn-logout { background: #e74c3c; }
    </style>
</head>
<body>
    <div class="nav">
        <h2 style="margin:0; color:#3498db;">OMEGA PLATINUM</h2>
        <a href="/logout" class="btn btn-logout">Odhlásit se</a>
    </div>
    <div class="container">
        <div class="stats">
            <div class="card"><h3>Zaměstnanci</h3><p style="font-size:2em;">{{ count }}</p></div>
            <div class="card"><h3>Průměrný plat</h3><p style="font-size:2em;">{{ avg }} CZK</p></div>
            <div class="card"><a href="/new" class="btn" style="display:inline-block; margin-top:20px;">+ Nový nábor</a></div>
        </div>
        <table>
            <tr><th>Token</th><th>Jméno</th><th>Pozice</th><th>Plat</th><th>Akce</th></tr>
            {% for e in employees %}
            <tr>
                <td><code>{{ e.token }}</code></td>
                <td>{{ e.personal_data.name }} {{ e.personal_data.surname }}</td>
                <td>{{ e.hr_data.position }}</td>
                <td>{{ e.hr_data.salary }} CZK</td>
                <td>
                    <form action="/hr/lifecycle/{{ e.token }}" method="post" style="display:inline;">
                        <input type="hidden" name="action" value="salary">
                        <input name="new_salary" placeholder="Nový plat" style="padding:5px; width:80px;">
                        <button type="submit" class="btn">Upravit</button>
                    </form>
                </td>
            </tr>
            {% endfor %}
        </table>
    </div>
</body>
</html>
HOF

cat > templates/login.html << 'HOF'
<!DOCTYPE html>
<html lang="cs">
<head>
    <meta charset="UTF-8">
    <style>
        body { background: #0a0a0a; color: white; font-family: sans-serif; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; }
        form { background: #111; padding: 40px; border-radius: 10px; border: 1px solid #333; width: 300px; }
        input { width: 100%; padding: 10px; margin-bottom: 15px; background: #222; border: 1px solid #444; color: white; box-sizing: border-box; }
        button { width: 100%; padding: 10px; background: #3498db; border: none; color: white; font-weight: bold; cursor: pointer; }
    </style>
</head>
<body>
    <form method="post">
        <h1 style="color:#3498db;">OMEGA LOGIN</h1>
        <input name="username" placeholder="Uživatel">
        <input name="password" type="password" placeholder="Heslo">
        <button type="submit">VSTOUPIT</button>
    </form>
</body>
</html>
HOF

cat > templates/new.html << 'HOF'
<!DOCTYPE html>
<html lang="cs">
<head>
    <meta charset="UTF-8">
    <style>
        body { background: #0a0a0a; color: white; font-family: sans-serif; padding: 50px; }
        .form-box { max-width: 500px; background: #111; padding: 30px; border-radius: 8px; border: 1px solid #333; }
        input { width: 100%; padding: 10px; margin-bottom: 15px; background: #222; border: 1px solid #444; color: white; box-sizing: border-box; }
        button { background: #3498db; color: white; padding: 10px 20px; border: none; border-radius: 4px; cursor: pointer; }
    </style>
</head>
<body>
    <div class="form-box">
        <h2>Nový nábor</h2>
        <form method="post">
            <input name="name" placeholder="Jméno" required>
            <input name="surname" placeholder="Příjmení" required>
            <input name="email" placeholder="Email" required>
            <input name="position" placeholder="Pozice" required>
            <input name="salary" placeholder="Plat" required>
            <button type="submit">Vytvořit zaměstnance</button>
            <a href="/" style="color: #666; margin-left: 20px;">Zpět</a>
        </form>
    </div>
</body>
</html>
HOF

echo "✅ OBNOVA HOTOVA. Nyní v Ubuntu okně vypni starý Python a spusť: python3 omega_core.py"
