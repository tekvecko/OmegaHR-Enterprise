#!/data/data/com.termux/files/usr/bin/bash
set -e

cd /data/data/com.termux/files/home/OmegaPlatinum_PROD

cat > repair_pdf_once_for_all.py << 'PYEOF'
#!/data/data/com.termux/files/usr/bin/python
import os, unicodedata

def strip_accents(s):
    if not s: return ""
    return "".join(c for c in unicodedata.normalize('NFD', str(s)) if unicodedata.category(c) != 'Mn')

print("☢️ Aplikuji nukleární opravu PDF: Přechod na standardní fonty s odstraněním diakritiky...")

with open('omega_core.py', 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_lines = []
skip = False
for line in lines:
    if "def gen_pdf" in line:
        new_lines.append(line)
        # Nové tělo funkce - maximálně jednoduché, bez externích fontů
        new_lines.append("    import json, datetime, unicodedata\n")
        new_lines.append("    import omega_config as cfg\n")
        new_lines.append("    from fpdf import FPDF\n")
        new_lines.append("    def clean(s): return ''.join(c for c in unicodedata.normalize('NFD', str(s)) if unicodedata.category(c) != 'Mn') if s else ''\n")
        new_lines.append("    try:\n")
        new_lines.append("        with open('settings.json', 'r', encoding='utf-8') as sf: comp = json.load(sf)\n")
        new_lines.append("    except: comp = {}\n")
        new_lines.append("    try:\n")
        new_lines.append("        c = get_candidate(token)\n")
        new_lines.append("        pdf = FPDF(); pdf.add_page(); pdf.set_font('Arial', 'B', 16)\n")
        new_lines.append("        pdf.cell(0, 10, clean(f'DOKUMENT: {type.upper()}'), ln=1, align='C')\n")
        new_lines.append("        pdf.set_font('Arial', '', 12); pdf.ln(10)\n")
        new_lines.append("        c_type = (c.get('hr_data') or {}).get('contract_type', 'HPP')\n")
        new_lines.append("        t_file = 'dpp_template.txt' if str(c_type).lower() == 'dpp' else 'contract_template.txt'\n")
        new_lines.append("        if type == 'nda': t_file = 'nda_template.txt'\n")
        new_lines.append("        elif type == 'handover': t_file = 'handover_template.txt'\n")
        new_lines.append("        content = ''\n")
        new_lines.append("        if os.path.exists(t_file):\n")
        new_lines.append("            with open(t_file, 'r', encoding='utf-8') as f: content = f.read()\n")
        new_lines.append("        else: content = f'Smlouva pro: {token}'\n")
        new_lines.append("        vals = {\n")
        new_lines.append("            '{token}': token, \n")
        new_lines.append("            '{name}': clean(f\"{c['personal_data']['name']} {c['personal_data']['surname']}\"),\n")
        new_lines.append("            '{salary}': str((c.get('hr_data') or {}).get('salary', '0')),\n")
        new_lines.append("            '{position}': clean(str((c.get('hr_data') or {}).get('position', '-'))),\n")
        new_lines.append("            '{company_name}': clean(comp.get('company_name', 'OmegaHR')),\n")
        new_lines.append("            '{company_address}': clean(comp.get('company_address', '-')),\n")
        new_lines.append("            '{date}': str(datetime.date.today())\n")
        new_lines.append("        }\n")
        new_lines.append("        for k, v in vals.items(): content = content.replace(k, str(v))\n")
        new_lines.append("        pdf.multi_cell(0, 8, clean(content))\n")
        new_lines.append("        fname = f'{type}_{token}.pdf'\n")
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

print("✅ Jádro opraveno. Používáme standardní fonty s automatickým čištěním textu.")
PYEOF

chmod +x repair_pdf_once_for_all.py
/data/data/com.termux/files/usr/bin/python repair_pdf_once_for_all.py
rm repair_pdf_once_for_all.py

echo "🚀 Poslední bitva. Restartuji a pouštím E2E test..."
pkill -f python || true
./start.sh &
sleep 4
./run_e2e_final.sh
