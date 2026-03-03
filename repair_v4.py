import re

with open('omega_core.py', 'r', encoding='utf-8') as f:
    code = f.read()

# Definujeme funkci gen_pdf s neprůstřelným f-stringem na jednom řádku
new_gen_pdf = """
def gen_pdf(token, type='contract'):
    import json, datetime, os, unicodedata
    from fpdf import FPDF
    def clean(s): return "".join(c for c in unicodedata.normalize('NFD', str(s)) if unicodedata.category(c) != 'Mn') if s else ""
    try:
        base = "/data/data/com.termux/files/home/OmegaPlatinum_PROD"
        db_path = os.path.join(base, 'db', f'{token}.json')
        c = {}
        if os.path.exists(db_path):
            with open(db_path, 'r', encoding='utf-8') as f: c = json.load(f)
        else:
            c = {'personal_data':{'name':'Test','surname':'User'}, 'hr_data':{'salary':'0','position':'-'}}
        
        pdf = FPDF(); pdf.add_page(); pdf.set_font('Arial', 'B', 16)
        pdf.cell(0, 10, clean(f'DOCUMENT: {type.upper()}'), ln=1, align='C')
        pdf.set_font('Arial', '', 12); pdf.ln(10)
        
        pd = c.get('personal_data', {}); hd = c.get('hr_data', {})
        content = f"Token: {token} | Name: {pd.get('name')} {pd.get('surname')} | Position: {hd.get('position')} | Salary: {hd.get('salary')}"
        
        pdf.multi_cell(0, 10, clean(content))
        fname = f"{type}_{token}.pdf"
        pdf.output(os.path.join(base, 'contracts', fname))
        return fname
    except Exception as e:
        print(f"PDF ERROR: {e}"); return None
"""

# Nahradíme starou funkci novou (použijeme širší záběr pro regex)
code = re.sub(r"def gen_pdf\(token, type='contract'\):.*?return fname", new_gen_pdf, code, flags=re.DOTALL)

with open('omega_core.py', 'w', encoding='utf-8') as f:
    f.write(code)
print("✅ Syntax opravena (f-string spojitý).")
