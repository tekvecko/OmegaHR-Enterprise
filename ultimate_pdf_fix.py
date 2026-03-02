#!/data/data/com.termux/files/usr/bin/python
import os
import urllib.request
import sys
import datetime

print("🧹 1/3 Čištění starého prostředí...")
os.system("rm -f Roboto-Regular.ttf")
os.system("rm -f contract_*.pdf")
os.system("rm -f termination_*.pdf")

print("⬇️ 2/3 Stahování čistého fontu Roboto (Python downloader)...")
url = "https://raw.githubusercontent.com/google/fonts/main/ofl/roboto/Roboto-Regular.ttf"
try:
    urllib.request.urlretrieve(url, "Roboto-Regular.ttf")
    size = os.path.getsize("Roboto-Regular.ttf")
    print(f"   Velikost fontu: {size} bajtů.")
    if size < 100000:
        print("   ❌ CHYBA: Font se stáhl špatně (je moc malý)!")
        sys.exit(1)
    else:
        print("   ✅ Font úspěšně a správně stažen.")
except Exception as e:
    print(f"   ❌ CHYBA stahování: {e}")
    sys.exit(1)

print("🔧 3/3 Aplikuji absolutní fix do omega_core.py...")
with open('omega_core.py', 'r', encoding='utf-8') as f:
    lines = f.readlines()

out = []
in_gen_pdf = False
for line in lines:
    if line.startswith("def gen_pdf("):
        in_gen_pdf = True
        out.append(line)
        out.append('''    try:
        import omega_config as cfg
        c = fix_data(db.get_candidate(token))
        comp = get_sys_config()
        from fpdf import FPDF
        pdf = FPDF()
        pdf.add_page()
        
        font_path = os.path.join(cfg.BASE_DIR, 'Roboto-Regular.ttf')
        # NATVRDO NAČTEME FONT BEZ ZÁCHRANNÉHO REŽIMU - musí projít
        pdf.add_font('Roboto', '', font_path)
        pdf.set_font('Roboto', '', 12)
        
        t_file = "contract_template.txt" if type == 'contract' else "termination_template.txt"
        content = "CHYBA NAČTENÍ ŠABLONY"
        if os.path.exists(t_file):
            with open(t_file, 'r', encoding='utf-8') as f:
                content = f.read()
        
        vals = {
            "{token}": token, "{name}": str(c.get('name', '')),
            "{salary}": str(c.get('hr_data', {}).get('salary', '0')),
            "{position}": str(c.get('hr_data', {}).get('position', '-')),
            "{birthdate}": str(c.get('birthdate_mojeid', '-')),
            "{company_name}": comp.get('name', ''), "{company_address}": comp.get('address', ''),
            "{date}": str(datetime.date.today())
        }
        for k, v in vals.items():
            content = content.replace(k, v)
            
        pdf.multi_cell(0, 8, content)
        
        if c.get('status') == 'signed':
            pdf.ln(10)
            pdf.set_text_color(0, 100, 0)
            pdf.cell(0, 10, "DIGITALLY SIGNED VIA OIDC", ln=1)
            
        fname = f"{type}_{token}.pdf"
        out_path = os.path.join(cfg.CONTRACTS_DIR, fname)
        pdf.output(out_path)
        print(f"✅ Smlouva {fname} úspěšně vygenerována s UTF-8.")
        return fname
    except Exception as e:
        print(f"❌ KRITICKÁ CHYBA PDF: {e}")
        return None
''')
    elif in_gen_pdf and line.startswith("@app.route"):
        in_gen_pdf = False
        out.append(line)
    elif not in_gen_pdf:
        out.append(line)

with open('omega_core.py', 'w', encoding='utf-8') as f:
    f.writelines(out)

print("   ✅ Jádro opraveno.")
