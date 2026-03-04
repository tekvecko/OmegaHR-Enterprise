#!/data/data/com.termux/files/usr/bin/bash
set -e

PROJ="/data/data/com.termux/files/home/OmegaPlatinum_PROD"
TPL="$PROJ/templates"

echo "🏗️ Buduji pokročilé moduly správy..."

# 1. MODUL: SPRÁVA SMLUV (Document Management System)
cat > "$TPL/manage_contracts.html" << 'HOF'
<!DOCTYPE html><html><head><meta charset="UTF-8"><link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>body{font-family:sans-serif;background:#f0f2f5;margin:0;display:flex}.sidebar{width:260px;background:#1c1e21;height:100vh;color:white}.main{flex:1;padding:30px}.card{background:white;padding:25px;border-radius:12px;border:1px solid #dddfe2}table{width:100%;border-collapse:collapse}td,th{padding:12px;border-bottom:1px solid #eee;text-align:left}.btn{padding:8px 12px;border-radius:6px;text-decoration:none;background:#0062cc;color:white;font-size:0.8rem}</style></head>
<body><div class="sidebar" id="inject-sidebar"></div><div class="main">
<div class="card"><h1><i class="fa-solid fa-file-signature"></i> Archiv smluv a dokumentů</h1>
<table><tr><th>Subjekt</th><th>Typ dokumentu</th><th>Digitální podpis (Hash)</th><th>Akce</th></tr>
{% for e in employees %}
<tr><td>{{e.name}}</td><td>Pracovní smlouva (HPP)</td><td><code>{{e.contract_hash or 'NEPODEPISÁNO'}}</code></td>
<td><a href="/generate_verified_contract/{{e.token}}" class="btn"><i class="fa-solid fa-download"></i> PDF</a></td></tr>
{% endfor %}</table></div></div>
<script>fetch('/').then(r=>r.text()).then(h=>{const p=new DOMParser();const d=p.parseFromString(h,'text/html');document.getElementById('inject-sidebar').innerHTML=d.querySelector('.sidebar').innerHTML;});</script>
</body></html>
HOF

# 2. MODUL: SPRÁVA UŽIVATELSKÝCH ÚČTŮ (Admin Panel)
cat > "$TPL/manage_users.html" << 'HOF'
<!DOCTYPE html><html><head><meta charset="UTF-8"><link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>body{font-family:sans-serif;background:#f0f2f5;margin:0;display:flex}.sidebar{width:260px;background:#1c1e21;height:100vh;color:white}.main{flex:1;padding:30px}.card{background:white;padding:25px;border-radius:12px;border:1px solid #dddfe2}table{width:100%;border-collapse:collapse}td,th{padding:12px;border-bottom:1px solid #eee;text-align:left}.badge{padding:4px 8px;border-radius:4px;font-size:0.7rem;background:#e9ecef}</style></head>
<body><div class="sidebar" id="inject-sidebar"></div><div class="main">
<div class="card"><h1><i class="fa-solid fa-user-shield"></i> Správa systémových účtů</h1>
<table><tr><th>ID</th><th>Username</th><th>Role</th><th>Status</th><th>Akce</th></tr>
<tr><td>1</td><td>admin</td><td><span class="badge" style="background:#0062cc;color:white">SUPERADMIN</span></td><td>Aktivní</td><td><button disabled>Změnit heslo</button></td></tr>
{% for e in employees %}
<tr><td>{{loop.index + 1}}</td><td>{{e.token}}</td><td><span class="badge">OPERATOR</span></td><td>{{e.status}}</td><td><a href="/admin/reset_identity/{{e.token}}" style="color:red">Reset identity</a></td></tr>
{% endfor %}</table></div></div>
<script>fetch('/').then(r=>r.text()).then(h=>{const p=new DOMParser();const d=p.parseFromString(h,'text/html');document.getElementById('inject-sidebar').innerHTML=d.querySelector('.sidebar').innerHTML;});</script>
</body></html>
HOF

# 3. AKTUALIZACE JÁDRA (Nové routy pro frontend)
python3 << 'PYEOF'
path = "/data/data/com.termux/files/home/OmegaPlatinum_PROD/omega_core.py"
with open(path, 'r') as f: content = f.read()

new_routes = """
@app.route('/manage/contracts')
def manage_contracts():
    if not session.get('logged_in'): return redirect(url_for('login'))
    return render_template('manage_contracts.html', employees=query_db("SELECT * FROM candidates"))

@app.route('/manage/users')
def manage_users():
    if not session.get('logged_in'): return redirect(url_for('login'))
    return render_template('manage_users.html', employees=query_db("SELECT * FROM candidates"))

@app.route('/manage/others')
def manage_others():
    if not session.get('logged_in'): return redirect(url_for('login'))
    return "<h1>Ostatní nastavení</h1><p>Zálohování DB, API klíče, Systémové logy.</p><a href='/'>Zpět</a>"
"""

if "/manage/contracts" not in content:
    content = content.replace("if __name__ == '__main__':", new_routes + "\nif __name__ == '__main__':")
    with open(path, 'w') as f: f.write(content)
PYEOF

# 4. AKTUALIZACE SIDEBARU (V index.html pro globální přístup)
sed -i '/<a href="\/admin\/identities"/a \        <a href="/manage/users" class="nav-item"><i class="fa-solid fa-users-cog"></i> Správa účtů</a>\n        <a href="/manage/contracts" class="nav-item"><i class="fa-solid fa-file-invoice"></i> Správa smluv</a>\n        <a href="/manage/others" class="nav-item"><i class="fa-solid fa-gears"></i> Ostatní</a>' "$TPL/index.html"

echo "🚀 Restartuji Enterprise modul..."
pkill -f "omega_core.py" || true
nohup python3 "$PROJ/omega_core.py" > "$PROJ/dev_server.log" 2>&1 &
echo "💎 SYSTÉM ROZŠÍŘEN. Všechny moduly jsou nyní v postranním panelu."
