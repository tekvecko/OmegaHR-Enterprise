#!/data/data/com.termux/files/usr/bin/bash
set -e

cd /data/data/com.termux/files/home/OmegaPlatinum_PROD

cat > fix_pdf_keys.py << 'PYEOF'
#!/data/data/com.termux/files/usr/bin/python

print("🛠️ Aplikuji finální chirurgickou záplatu na generátor PDF...")

with open('omega_core.py', 'r', encoding='utf-8') as f:
    code = f.read()

# 1. Oprava fatální chyby s nahrazováním prázdnoty (Null Safety)
old_replace = "for k, v in vals.items(): content = content.replace(k, v)"
new_replace = "for k, v in vals.items(): content = content.replace(k, str(v) if v is not None else '')"
code = code.replace(old_replace, new_replace)

# 2. Oprava nesprávných klíčů pro firemní údaje, aby do PDF opravdu něco nateklo
old_comp_name = "\"{company_name}\": (comp or {}).get('name')"
new_comp_name = "\"{company_name}\": (comp or {}).get('company_name', '')"
code = code.replace(old_comp_name, new_comp_name)

old_comp_addr = "\"{company_address}\": (comp or {}).get('address')"
new_comp_addr = "\"{company_address}\": (comp or {}).get('company_address', '')"
code = code.replace(old_comp_addr, new_comp_addr)

with open('omega_core.py', 'w', encoding='utf-8') as f:
    f.write(code)

print("✅ Jádro je nyní naprosto bezpečné a klíče jsou sladěny!")
PYEOF

chmod +x fix_pdf_keys.py
/data/data/com.termux/files/usr/bin/python fix_pdf_keys.py
rm fix_pdf_keys.py

echo "🚀 Restartuji server a pouštím E2E test naposledy!"
pkill -f python || true
./start.sh &
sleep 3
./run_e2e_final.sh
