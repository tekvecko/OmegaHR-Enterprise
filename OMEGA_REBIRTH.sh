#!/data/data/com.termux/files/usr/bin/bash
set -e

PROJ="/data/data/com.termux/files/home/OmegaPlatinum_PROD"
cd $PROJ

echo "🧬 Generuji nové, čisté jádro systému..."

cat > omega_core.py << 'PYEOF'
#!/data/data/com.termux/files/usr/bin/python
import os, sqlite3
from flask import Flask, request, session, redirect, url_for, render_template, send_from_directory, jsonify
from fpdf import FPDF

app = Flask(__name__)
app.secret_key = os.getenv("API_KEY", "PLATINUM_2026_SECURE_KEY")

BASE_DIR = "/data/data/com.termux/files/home/OmegaPlatinum_PROD"
DB_FILE = os.path.join(BASE_DIR, "omega_database.db")
CONTRACTS_DIR = os.path.join(BASE_DIR, "contracts")
FONT_PATH = os.path.join(BASE_DIR, "fonts/System-Roboto.ttf")

os.makedirs(CONTRACTS_DIR, exist_ok=True)

def query_db(query, args=(), one=False):
    conn = sqlite3.connect(DB_FILE)
    conn.row_factory = sqlite3.Row
    cur = conn.cursor()
    cur.execute(query, args)
    rv = cur.fetchall()
    conn.commit()
    conn.close()
    return (rv[0] if rv else None) if one else rv

@app.route('/')
def index():
    if not session.get('logged_in'): return redirect(url_for('login'))
    employees = query_db("SELECT * FROM candidates WHERE status != 'TERMINATED'")
    stock = query_db("SELECT name, count(*) as count FROM assets WHERE owner_token IS NULL GROUP BY name")
    assets_raw = query_db("SELECT * FROM assets")
    asset_map = {}
    for a in assets_raw:
        token = a['owner_token']
        if token:
            if token not in asset_map: asset_map[token] = []
            asset_map[token].append(a)
    return render_template('index.html', employees=employees, stock=stock, asset_map=asset_map, count=len(employees))

@app.route('/generate_contract/<token>')
def generate_contract(token):
    if not session.get('logged_in'): return redirect(url_for('login'))
    emp = query_db("SELECT * FROM candidates WHERE token=?", (token,), one=True)
    if not emp: return "Employee not found", 404

    try:
        pdf = FPDF()
        pdf.add_font('Roboto', '', FONT_PATH)
        pdf.add_page()
        pdf.set_font('Roboto', size=16)
        pdf.cell(190, 10, text="PRACOVNÍ SMLOUVA OMEGA PLATINUM", align='C')
        pdf.ln(20)
        pdf.set_font('Roboto', size=12)
        pdf.cell(190, 10, text=f"Zaměstnanec: {emp['name']}", align='L')
        pdf.ln(10)
        pdf.cell(190, 10, text=f"Identifikátor: {emp['mojeid_sub'] or 'N/A'}", align='L')
        pdf.ln(10)
        pdf.cell(190, 10, text=f"Datum nástupu: {emp['hired_at']}", align='L')
        
        filename = f"Smlouva_{token}.pdf"
        dest = os.path.join(CONTRACTS_DIR, filename)
        pdf.output(dest)
        return send_from_directory(CONTRACTS_DIR, filename)
    except Exception as e:
        return f"Chyba při generování: {str(e)}", 500

@app.route('/api/stats')
def get_stats():
    count = query_db("SELECT count(*) as count FROM candidates WHERE status='ACTIVE'", one=True)['count']
    return jsonify({"active_personnel": count})

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        if request.form.get('username') == 'admin':
            session['logged_in'] = True
            return redirect(url_for('index'))
    return render_template('login.html')

@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('login'))

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=8080)
PYEOF

echo "🚀 Startuji nové čisté jádro..."
pkill -f "omega_core.py" || true
nohup python3 omega_core.py > dev_server.log 2>&1 &
sleep 2

if pgrep -f "omega_core.py" > /dev/null; then
    echo -e "\033[0;32m[VICTORY]\033[0m Jádro běží bez chyb!"
else
    echo -e "\033[0;31m[FAIL]\033[0m Něco je špatně. Zkus: python3 omega_core.py"
fi
