#!/data/data/com.termux/files/usr/bin/bash
set -e

cd /data/data/com.termux/files/home/OmegaPlatinum_PROD

# 1. OPRAVA JÁDRA - Sjednocení klíčů a auditování
cat > core_calibrate.py << 'PYEOF'
import re

with open('omega_core.py', 'r', encoding='utf-8') as f:
    code = f.read()

# Oprava hr_lifecycle: Zajistíme, aby se plat skutečně přepsal a akce se logovala
hr_fix = """
@app.route('/hr/lifecycle/<token>', methods=['POST'])
def hr_lifecycle(token):
    import json, os
    path = f"/data/data/com.termux/files/home/OmegaPlatinum_PROD/db/{token}.json"
    if not os.path.exists(path): return "Not Found", 404
    
    with open(path, 'r') as f: data = json.load(f)
    
    action = request.form.get('action')
    if action == 'salary':
        new_val = request.form.get('new_salary')
        data['hr_data']['salary'] = new_val
        log_action(session.get('user', 'System'), "Zmena platu", token, f"Novy plat: {new_val}", "HR")
    
    with open(path, 'w') as f: json.dump(data, f, indent=4)
    return redirect(url_for('index'))
"""

# Výměna staré funkce za novou, robustnější
code = re.sub(r"@app\.route\('/hr/lifecycle/.*?return redirect\(url_for\('index'\)\)", hr_fix, code, flags=re.DOTALL)

with open('omega_core.py', 'w', encoding='utf-8') as f:
    f.write(code)
print("✅ Jádro bylo kalibrováno pro správný zápis a logování.")
PYEOF

python3 core_calibrate.py
rm core_calibrate.py

# 2. RESTART A SPUŠTĚNÍ TESTU ZNOVU
pkill -f python || true
nohup python3 omega_core.py > server.log 2>&1 &
sleep 2

echo "🚀 Restartováno. Spouštím znovu ultimátní test..."
./OMEGA_ULTIMATE_LIFECYCLE_TEST.sh
