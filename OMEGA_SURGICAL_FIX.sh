#!/data/data/com.termux/files/usr/bin/bash
set -e
cd /data/data/com.termux/files/home/OmegaPlatinum_PROD

# 1. OPRAVA JÁDRA - Vynucení zápisu a absolutních cest
cat > surgical_patch.py << 'PYEOF'
import re

base_path = "/data/data/com.termux/files/home/OmegaPlatinum_PROD/db"

with open('omega_core.py', 'r', encoding='utf-8') as f:
    code = f.read()

# OPRAVA LOGOVÁNÍ (Absolutní cesta + okamžitý flush)
new_log_action = f"""
def log_action(user, action, target="", details="", category="Ostatní"):
    import datetime, json, os
    log_file = "{base_path}/audit_log.json"
    entry = {{
        "timestamp": datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "user": user, "action": action, "target": target, "details": details, "category": category
    }}
    try:
        logs = []
        if os.path.exists(log_file):
            with open(log_file, 'r', encoding='utf-8') as f:
                logs = json.load(f)
        logs.insert(0, entry)
        with open(log_file, 'w', encoding='utf-8') as f:
            json.dump(logs[:500], f, indent=4, ensure_ascii=False)
    except Exception: pass
"""

# OPRAVA LIFECYCLE (Absolutní cesta + vynucený commit do JSONu)
new_lifecycle = f"""
@app.route('/hr/lifecycle/<token>', methods=['POST'])
def hr_lifecycle(token):
    import json, os
    path = f"{base_path}/{{token}}.json"
    if not os.path.exists(path): return "Soubor nenalezen", 404
    
    with open(path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    action = request.form.get('action')
    if action == 'salary':
        val = request.form.get('new_salary')
        data['hr_data']['salary'] = str(val)
        log_action(session.get('user', 'System'), "Změna platu", token, f"Nový plat: {{val}}", "HR")
    
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=4, ensure_ascii=False)
    return redirect(url_for('index'))
"""

# Nahrazení funkcí v kódu
code = re.sub(r"def log_action\(.*?\):.*?except Exception: pass", new_log_action, code, flags=re.DOTALL)
code = re.sub(r"@app\.route\('/hr/lifecycle/.*?return redirect\(url_for\('index'\)\)", new_lifecycle, code, flags=re.DOTALL)

with open('omega_core.py', 'w', encoding='utf-8') as f:
    f.write(code)
PYEOF

python3 surgical_patch.py
rm surgical_patch.py

# 2. RESTART A FINÁLNÍ VERIFIKACE
pkill -f python || true
nohup python3 omega_core.py > server.log 2>&1 &
sleep 2

echo "💉 Jádro bylo operováno. Spouštím striktní verifikaci..."
./OMEGA_REAL_VERIFICATION.sh
