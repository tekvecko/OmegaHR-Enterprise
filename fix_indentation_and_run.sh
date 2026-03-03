#!/data/data/com.termux/files/usr/bin/bash
set -e

cd /data/data/com.termux/files/home/OmegaPlatinum_PROD

cat > repair_core.py << 'PYEOF'
#!/data/data/com.termux/files/usr/bin/python
import os

print("🔧 Opravuji syntaxi a odsazení v omega_core.py...")

with open('omega_core.py', 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_lines = []
skip = False
for line in lines:
    if "def gen_pdf" in line:
        new_lines.append(line)
        # Vložíme kompletně opravené tělo funkce se správným odsazením
        new_lines.append("    import json, datetime\n")
        new_lines.append("    import omega_config as cfg\n")
        new_lines.append("    from fpdf import FPDF\n")
        new_lines.append("    try:\n")
        new_lines.append("        with open('settings.json', 'r', encoding='utf-8') as sf: comp = json.load(sf)\n")
        new_lines.append("    except: comp = {}\n")
        new_lines.append("    try:\n")
        new_lines.append("        import db_adapter as db\n")
        new_lines.append("        c = db.get_candidate(token)\n")
        new_lines.append("        pdf = FPDF(); pdf.add_page()\n")
        new_lines.append("        font_path = '/data/data/com.termux/files/home/OmegaPlatinum_PROD/Roboto-Regular.ttf'\n")
        new_lines.append("        pdf.add_font('Roboto', '', font_path, uni=True)\n")
        new_lines.append("        pdf.set_font('Roboto', '', 12)\n")
        new_lines.append("        c_type = (c.get('hr_data') or {}).get('contract_type', 'HPP').lower()\n")
        new_lines.append("        if type == 'contract': t_file = 'dpp_template.txt' if c_type == 'dpp' else 'contract_template.txt'\n")
        new_lines.append("        elif type == 'nda': t_file = 'nda_template.txt'\n")
        new_lines.append("        elif type == 'handover': t_file = 'handover_template.txt'\n")
        new_lines.append("        else: t_file = 'termination_template.txt'\n")
        new_lines.append("        content = ''\n")
        new_lines.append("        if os.path.exists(t_file):\n")
        new_lines.append("            with open(t_file, 'r', encoding='utf-8') as f: content = f.read()\n")
        new_lines.append("        else: content = f'DOKUMENT: {type}'\n")
        new_lines.append("        vals = {\n")
        new_lines.append("            '{token}': token, '{name}': f\"{c['personal_data']['name']} {c['personal_data']['surname']}\",\n")
        new_lines.append("            '{salary}': str((c.get('hr_data') or {}).get('salary', '0')),\n")
        new_lines.append("            '{position}': str((c.get('hr_data') or {}).get('position', '-')),\n")
        new_lines.append("            '{company_name}': comp.get('company_name', 'OmegaHR'),\n")
        new_lines.append("            '{company_address}': comp.get('company_address', '-'),\n")
        new_lines.append("            '{date}': str(datetime.date.today())\n")
        new_lines.append("        }\n")
        new_lines.append("        for k, v in vals.items(): content = content.replace(k, str(v) if v is not None else '')\n")
        new_lines.append("        pdf.multi_cell(0, 8, content)\n")
        new_lines.append("        fname = f\"{type}_{token}.pdf\"\n")
        new_lines.append("        pdf.output(os.path.join(cfg.CONTRACTS_DIR, fname))\n")
        new_lines.append("        return fname\n")
        new_lines.append("    except Exception as e:\n")
        new_lines.append("        print(f'PDF Error: {e}'); return None\n")
        skip = True
    elif skip and (line.startswith("def ") or line.startswith("@app.route")):
        skip = False
        new_lines.append(line)
    elif not skip:
        new_lines.append(line)

with open('omega_core.py', 'w', encoding='utf-8') as f:
    f.writelines(new_lines)

print("✅ Odsazení opraveno a funkce gen_pdf stabilizována.")
PYEOF

chmod +x repair_core.py
/data/data/com.termux/files/usr/bin/python repair_core.py
rm repair_core.py

echo "🚀 Poslední pokus o E2E test..."
pkill -f python || true
./start.sh &
sleep 4
./run_e2e_final.sh
