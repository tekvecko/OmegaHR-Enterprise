#!/data/data/com.termux/files/usr/bin/bash
set -e

cd /data/data/com.termux/files/home/OmegaPlatinum_PROD

echo "⏪ 1/2 Vracím poškozený soubor z naší poslední bezpečné zálohy (Git)..."
git checkout omega_core.py

echo "🛡️ 2/2 Aplikuji BEZPEČNOU přesnou záplatu pro chybějící tokeny..."
cat > safe_patch.py << 'PYEOF'
#!/data/data/com.termux/files/usr/bin/python

with open('omega_core.py', 'r', encoding='utf-8') as f:
    core = f.read()

# Oprava jen a pouze pro konkrétní řádek v portálu zaměstnance (žádné hromadné přepisování)
old_line = "if c['offboarding_status'] == 'terminated':"
new_line = "if not c: return 'Záznam nenalezen nebo byl smazán.', 404\n    if c.get('offboarding_status') == 'terminated':"

if old_line in core:
    core = core.replace(old_line, new_line)

with open('omega_core.py', 'w', encoding='utf-8') as f:
    f.write(core)
PYEOF

chmod +x safe_patch.py
/data/data/com.termux/files/usr/bin/python safe_patch.py
rm safe_patch.py

echo "🚀 Restartuji opravený server..."
pkill -f python || true
./start.sh
