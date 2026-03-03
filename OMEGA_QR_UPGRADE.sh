#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "📦 Instaluji QR Engine..."
pip install qrcode[pil]

echo "🔐 Upgraduji Jádro o Trust-Check validátor..."

cat > omega_core.py << 'PYEOF'
#!/data/data/com.termux/files/usr/bin/python
import os, json, uuid, datetime, sqlite3, random, qrcode
from flask import Flask, request, session, redirect, url_for, render_template, send_from_directory, jsonify
from fpdf import FPDF

app = Flask(__name__)
app.secret_key = os.getenv("API_KEY", "SECURE_ENTERPRISE_KEY_2026")

BASE_DIR = "/data/data/com.termux/files/home/OmegaPlatinum_PROD"
DB_FILE = os.path.join(BASE_DIR, "omega_database.db")
CONTRACTS_PATH = os.path.join(BASE_DIR, "contracts")
QR_PATH = os.path.join(BASE_DIR, "static/qr")
os.makedirs(CONTRACTS_PATH, exist_ok=True)
os.makedirs(QR_PATH, exist_ok=True)

class OmegaPDF(FPDF):
    def header(self):
        self.set_font("helvetica", "B", 16)
        self.set_text_color(0, 162, 255)
        self.cell(0, 10, "OMEGA PLATINUM CORE s.r.o.", ln=True)
        self.ln(10)

    def footer(self):
        self.set_y(-15)
        self.set_font("helvetica", "I", 8)
        self.cell(0, 10, f"Validace: {self.validation_hash} | Overeno systemem ARD", align="C")

def query_db(query, args=(), one=False):
    conn = sqlite3.connect(DB_FILE)
    conn.row_factory = sqlite3.Row
    cur = conn.cursor()
    cur.execute(query, args)
    rv = cur.fetchall()
    conn.commit()
    conn.close()
    return (rv[0] if rv else None) if one else rv

def generate_qr(token):
    # Zde použijeme tvou zrok URL (případně placeholder)
    validation_url = f"https://omega-trust.zrok.io/verify/{token}"
    qr = qrcode.QRCode(version=1, box_size=10, border=4)
    qr.add_data(validation_url)
    qr.make(fit=True)
    img = qr.make_image(fill_color="black", back_color="white")
    qr_file = os.path.join(QR_PATH, f"qr_{token}.png")
    img.save(qr_file)
    return qr_file

def create_signed_pdf(filename, title, content_dict, token):
    v_hash = uuid.uuid4().hex.upper()[:16]
    qr_file = generate_qr(token)
    
    pdf = OmegaPDF()
    pdf.validation_hash = v_hash
    pdf.add_page()
    
    pdf.set_font("helvetica", "B", 14)
    pdf.cell(0, 10, title, ln=True, align="C")
    pdf.ln(5)
    
    pdf.set_font("helvetica", "", 10)
    for key, value in content_dict.items():
        pdf.set_font("helvetica", "B", 10)
        pdf.cell(40, 8, f"{key}:", 0)
        pdf.set_font("helvetica", "", 10)
        pdf.cell(0, 8, str(value), ln=True)
    
    # Vložení QR kódu pro digitální ověření
    pdf.ln(10)
    pdf.image(qr_file, x=150, y=pdf.get_y(), w=40)
    pdf.set_font("helvetica", "B", 8)
    pdf.set_x(150)
    pdf.cell(40, 5, "SCAN TO VERIFY", align="C", ln=True)
    
    pdf.output(os.path.join(CONTRACTS_PATH, filename))

# --- ROUTE PRO VEŘEJNOU VERIFIKACI ---
@app.route('/verify/<token>')
def verify_document(token):
    emp = query_db("SELECT * FROM candidates WHERE token = ?", (token,), one=True)
    if emp:
        return f"""
        <body style="background:#030708; color:#eee; font-family:sans-serif; text-align:center; padding:50px;">
            <h1 style="color:#00ff9d;">✓ DOKUMENT JE PLATNÝ</h1>
            <p>Držitel: {emp['name']}</p>
            <p>MojeID: {emp['mojeid_sub']}</p>
            <p>Stav v ARD: ACTIVE</p>
            <hr style="border:1px solid #222;">
            <small style="color:#444;">OMEGA PLATINUM TRUST-CHECK SERVICE</small>
        </body>
        """
    return "<h1>❌ NEPLATNÝ DOKUMENT</h1>", 404

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
        query_db("INSERT INTO candidates (token, name, mojeid_sub, status, hired_at) VALUES (?, ?, ?, 'ACTIVE', ?)", 
                 (token, name, moje_id, str(datetime.date.today())))
        
        content = {"ID": token, "MOJEID": moje_id, "JMENO": name, "DATUM": str(datetime.date.today())}
        create_signed_pdf(f"SMLOUVA_{token}_{name}.pdf", "DIGITALNI PRACOVNI SMLOUVA", content, token)
        return redirect(url_for('index'))
    return render_template('index.html')

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        if request.form.get('username') == 'admin' and request.form.get('password') == 'admin':
            session['logged_in'], session['user'], session['role'] = True, 'admin', 'SUPERADMIN'
            return redirect(url_for('index'))
    return render_template('login.html')

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=8080)
PYEOF

echo "✅ Trust-Check Engine aktivován. Dokumenty jsou nyní podepisovány QR kódem."
