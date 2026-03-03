#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "🎨 Upgraduji generátor na PDF Engine..."

cat > omega_core.py << 'PYEOF'
#!/data/data/com.termux/files/usr/bin/python
import os, json, uuid, datetime, sqlite3, random
from flask import Flask, request, session, redirect, url_for, render_template, send_from_directory, jsonify
from fpdf import FPDF

app = Flask(__name__)
app.secret_key = os.getenv("API_KEY", "SECURE_ENTERPRISE_KEY_2026")

BASE_DIR = "/data/data/com.termux/files/home/OmegaPlatinum_PROD"
DB_FILE = os.path.join(BASE_DIR, "omega_database.db")
CONTRACTS_PATH = os.path.join(BASE_DIR, "contracts")
os.makedirs(CONTRACTS_PATH, exist_ok=True)

class OmegaPDF(FPDF):
    def header(self):
        self.set_font("helvetica", "B", 16)
        self.set_text_color(0, 162, 255) # OMEGA Blue
        self.cell(0, 10, "OMEGA PLATINUM CORE s.r.o.", ln=True, align="L")
        self.set_font("helvetica", "I", 8)
        self.set_text_color(100, 100, 100)
        self.cell(0, 5, "Enterprise Resource Planning - Personnel Document v3.0", ln=True, align="L")
        self.ln(10)

    def footer(self):
        self.set_y(-15)
        self.set_font("helvetica", "I", 8)
        self.cell(0, 10, f"Strana {self.page_no()} | Validace: {self.validation_hash}", align="C")

def query_db(query, args=(), one=False):
    conn = sqlite3.connect(DB_FILE)
    conn.row_factory = sqlite3.Row
    cur = conn.cursor()
    cur.execute(query, args)
    rv = cur.fetchall()
    conn.commit()
    conn.close()
    return (rv[0] if rv else None) if one else rv

def create_pdf(filename, title, content_dict, v_hash):
    pdf = OmegaPDF()
    pdf.validation_hash = v_hash
    pdf.add_page()
    pdf.set_font("helvetica", "B", 14)
    pdf.cell(0, 10, title, ln=True, align="C")
    pdf.ln(5)
    
    pdf.set_font("helvetica", "", 10)
    for key, value in content_dict.items():
        pdf.set_font("helvetica", "B", 10)
        pdf.cell(40, 8, f"{key}:", border=0)
        pdf.set_font("helvetica", "", 10)
        pdf.cell(0, 8, str(value), ln=True)
    
    pdf.ln(10)
    pdf.set_font("helvetica", "I", 9)
    pdf.multi_cell(0, 5, "Tento dokument je generován automaticky systémem OMEGA. "
                         "Digitální otisk v zápatí garantuje integritu dat v době vystavení. "
                         "Smlouva je platná bez fyzického razítka.")
    
    pdf.output(os.path.join(CONTRACTS_PATH, filename))

@app.route('/')
def index():
    if not session.get('logged_in'): return redirect(url_for('login'))
    employees = query_db("SELECT * FROM candidates WHERE status != 'TERMINATED'")
    all_assets = query_db("SELECT * FROM assets")
    asset_map = {a['owner_token']: [] for a in all_assets if a['owner_token']}
    for a in all_assets:
        if a['owner_token'] in asset_map:
            asset_map[a['owner_token']].append({"name": a['name'], "serial": a['serial']})
    stock = query_db("SELECT name, count(*) as count FROM assets WHERE owner_token IS NULL GROUP BY name")
    return render_template('index.html', employees=employees, count=len(employees), asset_map=asset_map, stock=stock)

@app.route('/new', methods=['GET', 'POST'])
def new_employee():
    if not session.get('logged_in'): return redirect(url_for('login'))
    if request.method == 'POST':
        token = str(uuid.uuid4())[:8]
        moje_id = f"ID-{str(uuid.uuid4())[:4].upper()}"
        name = request.form.get('surname')
        v_hash = uuid.uuid4().hex.upper()[:12]
        
        query_db("INSERT INTO candidates (token, name, mojeid_sub, status, hired_at) VALUES (?, ?, ?, 'ACTIVE', ?)", 
                 (token, name, moje_id, str(datetime.date.today())))
        
        # Smlouva PDF
        content = {
            "ID Zamestnance": token,
            "MojeID Token": moje_id,
            "Jmeno": name,
            "Datum nastupu": str(datetime.date.today()),
            "Pracovni pomer": "Doba neurcita"
        }
        create_pdf(f"SMLOUVA_{token}_{name}.pdf", "PRACOVNI SMLOUVA", content, v_hash)
        
        return redirect(url_for('index'))
    return render_template('new.html')

@app.route('/contracts/<path:filename>')
def download(filename):
    return send_from_directory(CONTRACTS_PATH, filename)

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        if request.form.get('username') == 'admin' and request.form.get('password') == 'admin':
            session['logged_in'], session['user'], session['role'] = True, 'admin', 'SUPERADMIN'
            return redirect(url_for('index'))
    return render_template('login.html')

@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('login'))

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=8080)
PYEOF

# Oprava koncovek v Dashboardu (z .txt na .pdf)
sed -i 's/\.txt/.pdf/g' templates/index.html

echo "✅ PDF Engine aktivován. Soubory budou nyní generovány jako .pdf"
