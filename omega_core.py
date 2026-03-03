#!/data/data/com.termux/files/usr/bin/python
import os, json, uuid, datetime, sqlite3
from flask import Flask, request, session, redirect, url_for, render_template, send_from_directory, jsonify
from fpdf import FPDF
import qrcode

app = Flask(__name__)
app.secret_key = os.getenv("API_KEY", "SECURE_FULL_PLATINUM_2026")
BASE_DIR = "/data/data/com.termux/files/home/OmegaPlatinum_PROD"
DB_FILE = os.path.join(BASE_DIR, "omega_database.db")
CONTRACTS_DIR = os.path.join(BASE_DIR, "contracts")
QR_DIR = os.path.join(BASE_DIR, "static/qr")

os.makedirs(CONTRACTS_DIR, exist_ok=True)
os.makedirs(QR_DIR, exist_ok=True)

def query_db(query, args=(), one=False):
    conn = sqlite3.connect(DB_FILE)
    conn.row_factory = sqlite3.Row
    cur = conn.cursor()
    cur.execute(query, args)
    rv = cur.fetchall()
    conn.commit()
    conn.close()
    return (rv[0] if rv else None) if one else rv

def generate_pdf_contract(emp):
    pdf = FPDF()
    pdf.add_font('DejaVu', '', 'fonts/DejaVuSans.ttf', )
    pdf.add_page()
    pdf.set_font('DejaVu', size=16)
    pdf.cell(190, 10, 'PRACOVNÍ SMLOUVA OMEGA PLATINUM', ln=True, align='C')
    pdf.ln(10)
    pdf.set_font('DejaVu', size=12)
    pdf.cell(100, 10, f'Zaměstnanec: {emp["name"]}')
    pdf.ln(10)
    pdf.cell(100, 10, f'MojeID ID: {emp["mojeid_sub"]}')
    pdf.output(os.path.join(CONTRACTS_DIR, f'Smlouva_{emp["token"]}.pdf'))
    return f'Smlouva_{emp["token"]}.pdf'

@app.route('/')
def index():
    if not session.get('logged_in'): return redirect(url_for('login'))
    employees = query_db("SELECT * FROM candidates WHERE status != 'TERMINATED'")
    stock = query_db("SELECT name, count(*) as count FROM assets WHERE owner_token IS NULL GROUP BY name")
    asset_map = {}
    assets_raw = query_db("SELECT * FROM assets WHERE owner_token IS NOT NULL")
    for a in assets_raw:
        if a['owner_token'] not in asset_map: asset_map[a['owner_token']] = []
        asset_map[a['owner_token']].append(a)
    # Automatické generování asset_map pro UI
    assets_raw = query_db('SELECT * FROM assets')
    asset_map = {}
    for a in assets_raw:
        token = a['owner_token']
        if token:
            if token not in asset_map: asset_map[token] = []
            asset_map[token].append(a)
    return render_template('index.html', employees=employees, stock=stock, asset_map=asset_map, count=len(employees), asset_map=asset_map, stock=stock)

@app.route('/generate_contract/<token>')
def contract_route(token):
    if not session.get('logged_in'): return redirect(url_for('login'))
    emp = query_db("SELECT * FROM candidates WHERE token=?", (token,), one=True)
    if emp:
        file = generate_pdf_contract(emp)
        return send_from_directory(CONTRACTS_DIR, file)
    return "Error", 404

@app.route('/api/stats')
def get_stats():
    count = query_db("SELECT count(*) as count FROM candidates WHERE status='ACTIVE'", one=True)['count']
    stock = [dict(row) for row in query_db("SELECT name, count(*) as count FROM assets WHERE owner_token IS NULL GROUP BY name")]
    return jsonify({"active_personnel": count, "stock": stock})

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        if request.form.get('username') == 'admin': # Zjednoduseno pro demo
            session['logged_in'] = True
            return redirect(url_for('index'))
    return render_template('login.html')

@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('login'))

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=8080)
