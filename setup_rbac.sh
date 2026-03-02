#!/data/data/com.termux/files/usr/bin/bash
set -e

cd /data/data/com.termux/files/home/OmegaPlatinum_PROD

echo "🔐 1/3 Vytvářím šablonu pro Admin sekci (Správa účtů)..."
cat > templates/users.html << 'HTMLEOF'
<!DOCTYPE html>
<html lang="cs">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Správa Uživatelských Účtů - OmegaHR</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">
</head>
<body class="bg-gray-100 p-4 md:p-8 font-sans text-gray-800">
    <div class="max-w-4xl mx-auto">
        <div class="flex justify-between items-center mb-8">
            <h1 class="text-2xl md:text-3xl font-black">Správa Uživatelů a Práv</h1>
            <a href="/dashboard" class="text-gray-500 hover:text-gray-800 font-bold transition"><i class="ri-arrow-left-line"></i> Zpět</a>
        </div>
        
        <div class="bg-white p-6 rounded-2xl shadow-sm mb-8">
            <h2 class="text-lg font-bold mb-4 text-gray-700">Přidat nového uživatele</h2>
            <form action="/admin/users" method="POST" class="flex flex-col md:flex-row gap-4 items-end">
                <input type="hidden" name="action" value="add">
                <div class="flex-1 w-full">
                    <label class="block text-xs font-bold text-gray-500 mb-1">Přihlašovací jméno</label>
                    <input type="text" name="username" required class="w-full bg-gray-50 p-3 rounded-xl outline-none border border-gray-100">
                </div>
                <div class="flex-1 w-full">
                    <label class="block text-xs font-bold text-gray-500 mb-1">Heslo</label>
                    <input type="text" name="password" required class="w-full bg-gray-50 p-3 rounded-xl outline-none border border-gray-100">
                </div>
                <div class="flex-1 w-full">
                    <label class="block text-xs font-bold text-gray-500 mb-1">Role</label>
                    <select name="role" class="w-full bg-gray-50 p-3 rounded-xl outline-none border border-gray-100">
                        <option value="hr">HR Pracovník (Běžný)</option>
                        <option value="admin">Administrátor (Plný přístup)</option>
                    </select>
                </div>
                <button type="submit" class="bg-gray-800 text-white px-6 py-3 rounded-xl font-bold hover:bg-black transition w-full md:w-auto">Přidat účet</button>
            </form>
        </div>

        <div class="bg-white rounded-2xl shadow-sm overflow-hidden border border-gray-100">
            <table class="w-full text-left">
                <thead class="bg-gray-50">
                    <tr>
                        <th class="p-4 text-xs font-bold text-gray-500 uppercase tracking-wider">Uživatel</th>
                        <th class="p-4 text-xs font-bold text-gray-500 uppercase tracking-wider">Úroveň Práv</th>
                        <th class="p-4 text-xs font-bold text-gray-500 uppercase tracking-wider">Akce</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-50">
                    {% for uname, udata in users.items() %}
                    <tr>
                        <td class="p-4 font-bold text-gray-700">{{ uname }}</td>
                        <td class="p-4">
                            {% if udata.role == 'admin' %}
                            <span class="bg-red-50 text-red-600 px-3 py-1 rounded-lg text-xs font-bold">Administrátor</span>
                            {% else %}
                            <span class="bg-blue-50 text-blue-600 px-3 py-1 rounded-lg text-xs font-bold">HR Pracovník</span>
                            {% endif %}
                        </td>
                        <td class="p-4">
                            {% if uname != 'admin' %}
                            <form action="/admin/users" method="POST" class="inline">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="username" value="{{ uname }}">
                                <button type="submit" class="text-red-400 hover:text-red-600 font-bold text-sm transition"><i class="ri-delete-bin-line"></i> Odstranit</button>
                            </form>
                            {% else %}
                            <span class="text-xs text-gray-400 font-bold">Hlavní účet</span>
                            {% endif %}
                        </td>
                    </tr>
                    {% endfor %}
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>
HTMLEOF

echo "⚙️ 2/3 Aplikuji logiku oprávnění do jádra a UI..."
cat > patch_rbac.py << 'PYEOF'
import os
import re

# 1. Zajištění formuláře na Login obrazovce (přidání pole username, pokud chybí)
with open('templates/login.html', 'r', encoding='utf-8') as f:
    login_html = f.read()

if 'name="username"' not in login_html:
    login_html = re.sub(
        r'(<form[^>]*>)', 
        r'\1\n<div class="mb-4"><label class="block text-xs font-bold text-gray-500 mb-1">Přihlašovací jméno</label><input type="text" name="username" class="w-full bg-gray-50 border border-gray-100 p-3 rounded-xl outline-none" required></div>', 
        login_html
    )
    # Změníme i nápis u hesla pro přehlednost
    login_html = login_html.replace('placeholder="Zadejte heslo"', 'placeholder="Zadejte heslo" class="w-full bg-gray-50 border border-gray-100 p-3 rounded-xl outline-none"')
    with open('templates/login.html', 'w', encoding='utf-8') as f:
        f.write(login_html)

# 2. Úprava Dashboardu - Přidání zabezpečeného tlačítka Admin
with open('templates/dashboard.html', 'r', encoding='utf-8') as f:
    dash = f.read()
    
admin_btn = """
    {% if session.get('role') == 'admin' %}
    <a href="/admin/users" class="mt-2 mb-6 bg-red-50 text-red-600 border border-red-100 px-4 py-3 rounded-xl text-sm font-bold w-full hover:bg-red-100 transition shadow-sm flex items-center justify-center">
        <i class="ri-shield-user-fill mr-2"></i>Admin Sekce: Správa uživatelů
    </a>
    {% endif %}
"""
if "Admin Sekce: Správa" not in dash:
    dash = dash.replace('</h1>', '</h1>\n' + admin_btn, 1)
    with open('templates/dashboard.html', 'w', encoding='utf-8') as f:
        f.write(dash)

# 3. Patch jádra omega_core.py
with open('omega_core.py', 'r', encoding='utf-8') as f:
    core = f.read()

# Deaktivace původního jednoduchého loginu
if "@app.route('/login_old_disabled')" not in core:
    core = core.replace("@app.route('/login')", "@app.route('/login_old_disabled')")
    core = core.replace("@app.route('/login', methods=['GET', 'POST'])", "@app.route('/login_old_disabled', methods=['GET', 'POST'])")

new_rbac_code = """
# --- RBAC (ROLE-BASED ACCESS CONTROL) MODUL ---
import json
from flask import request, session, render_template

def load_users():
    if not os.path.exists('users.json'):
        with open('users.json', 'w', encoding='utf-8') as f:
            # Výchozí uživatelé, pokud soubor neexistuje
            json.dump({
                "admin": {"password": "admin", "role": "admin"},
                "hr": {"password": "hr", "role": "hr"}
            }, f, indent=4)
    with open('users.json', 'r', encoding='utf-8') as f:
        return json.load(f)

def save_users(users):
    with open('users.json', 'w', encoding='utf-8') as f:
        json.dump(users, f, indent=4)

@app.route('/login', methods=['GET', 'POST'], endpoint='rbac_login')
def rbac_login():
    if request.method == 'POST':
        username = request.form.get('username', '').strip()
        password = request.form.get('password', '').strip()
        users = load_users()
        
        if username in users and users[username]['password'] == password:
            session['logged_in'] = True
            session['user'] = username
            session['role'] = users[username]['role']
            return redirect('/dashboard')
        return "Nesprávné jméno nebo heslo. Zkuste to znovu.", 401
    return render_template('login.html')

@app.route('/admin/users', methods=['GET', 'POST'], endpoint='rbac_users')
def manage_users():
    # Tvrdá bezpečnostní kontrola - pustí jen Admina
    if not session.get('logged_in') or session.get('role') != 'admin':
        return "Přístup odepřen. Tuto sekci může spravovat pouze Administrátor.", 403
        
    users = load_users()
    if request.method == 'POST':
        action = request.form.get('action')
        username = request.form.get('username', '').strip()
        if action == 'add' and username:
            users[username] = {
                "password": request.form.get('password', ''),
                "role": request.form.get('role', 'hr')
            }
            save_users(users)
        elif action == 'delete' and username and username != 'admin':
            if username in users:
                del users[username]
                save_users(users)
        return redirect('/admin/users')
        
    return render_template('users.html', users=users)
# ----------------------------------------------
"""

if "# --- RBAC" not in core:
    parts = core.split("if __name__ == '__main__':")
    if len(parts) >= 2:
        core = parts[0] + new_rbac_code + "\nif __name__ == '__main__':" + parts[1]
    else:
        core = core + "\n" + new_rbac_code
    with open('omega_core.py', 'w', encoding='utf-8') as f:
        f.write(core)

print("   ✅ Jádro a UI úspěšně zazáplatováno.")
PYEOF

python patch_rbac.py
rm patch_rbac.py

echo "🚀 3/3 Restartuji server..."
pkill -f python || true
./start.sh
