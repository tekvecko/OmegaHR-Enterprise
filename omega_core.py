#!/data/data/com.termux/files/usr/bin/python
import os, uuid, datetime, json, sys, sqlite3, io
from flask import Flask, render_template, request, redirect, session, send_file, send_from_directory
from fpdf import FPDF
from waitress import serve
from werkzeug.middleware.proxy_fix import ProxyFix
from cryptography.fernet import Fernet
from werkzeug.security import check_password_hash
from authlib.integrations.flask_client import OAuth
import qrcode
import omega_config as cfg
import omega_db as db
import omega_services

app = Flask(__name__)
app.config.from_object(cfg)
app.config['SESSION_COOKIE_SECURE'] = True
app.config['SESSION_COOKIE_SAMESITE'] = 'Lax'

app.wsgi_app = ProxyFix(app.wsgi_app, x_proto=1, x_host=1)

@app.after_request
def security_headers(response):
    response.headers['X-Frame-Options'] = 'SAMEORIGIN'
    response.headers['X-Content-Type-Options'] = 'nosniff'
    return response

# Šifrování
try:
    with open('master.key', 'rb') as k: cipher = Fernet(k.read())
except Exception as e:
    print(f"Critical: Cannot read master.key - {e}")
    sys.exit(1)

def encrypt_data(d): return cipher.encrypt(json.dumps(d).encode()).decode()
def decrypt_data(s):
    try:
        if not s.startswith("gAAAA"): return json.loads(s)
        return json.loads(cipher.decrypt(s.encode()).decode())
    except Exception: return {}

# Načítání dynamické konfigurace z JSONu
def get_sys_config():
    default_config = {
        "base_url": "http://localhost:8080",
        "name": "Omega Corp", "address": "Neznámá", "ceo": "Admin",
        "mojeid_client_id": "", "mojeid_client_secret": "",
        "bankid_client_id": "", "bankid_client_secret": ""
    }
    if os.path.exists('sys_config.json'):
        try:
            with open('sys_config.json', 'r') as f:
                saved = json.load(f)
                default_config.update(saved)
        except: pass
    return default_config

# Inicializace OIDC s dynamickými klíči
sys_config = get_sys_config()
oauth = OAuth(app)

try:
    mojeid = oauth.register(
        name='mojeid',
        client_id=sys_config.get('mojeid_client_id'),
        client_secret=sys_config.get('mojeid_client_secret'),
        server_metadata_url=cfg.MOJEID_METADATA_URL,
        client_kwargs={'scope': 'openid profile email birthdate'}
    )
except Exception:
    mojeid = None

try:
    bankid = oauth.register(
        name='bankid',
        client_id=sys_config.get('bankid_client_id'),
        client_secret=sys_config.get('bankid_client_secret'),
        server_metadata_url=cfg.BANKID_METADATA_URL,
        client_kwargs={'scope': 'openid profile.birthdate'}
    )
except Exception:
    bankid = None

def is_staff(): return session.get('role') in ['admin', 'hr']

def fix_data(c):
    if not c: return None
    if isinstance(c.get('hr_data'), str): c['hr_data'] = decrypt_data(c['hr_data'])
    c.setdefault('offboarding_status', 'active')
    return c

def gen_pdf(token, type='contract'):
    try:
        c = fix_data(db.get_candidate(token))
        comp = load_settings()
        pdf = FPDF(); pdf.add_page()
        
        font_path = os.path.join(cfg.BASE_DIR, 'Roboto-Regular.ttf')
        loaded = False
        if os.path.exists(font_path) and os.path.getsize(font_path) > 1000:
            try:
                pdf.add_font('Roboto', '', font_path)
                pdf.set_font('Roboto', '', 12)
                loaded = True
            except: pass
        if not loaded: pdf.set_font("Arial", size=12)

        c_type = c.get('hr_data', {}).get('contract_type', 'hpp')
        if type == 'contract':
            t_file = "dpp_template.txt" if c_type == 'dpp' else "contract_template.txt"
        elif type == 'nda':
            t_file = "nda_template.txt"
        elif type == 'handover':
            t_file = "handover_template.txt"
        else:
            t_file = "termination_template.txt"
        content = ""
        if os.path.exists(t_file):
            try:
                with open(t_file, 'r', encoding='utf-8') as f: content = f.read()
            except: content = f"DOCUMENT: {type}"
        
        vals = {
            "{token}": token, "{name}": str(c['name']),
            "{salary}": str(c['hr_data'].get('salary', '0')),
            "{position}": str(c['hr_data'].get('position', '-')),
            "{birthdate}": str(c.get('birthdate_mojeid', '-')),
            "{company_name}": comp.get('name'), "{company_address}": comp.get('address'),
            "{date}": str(datetime.date.today())
        }
        for k, v in vals.items(): content = content.replace(k, v)
        

        pdf.multi_cell(0, 8, content)
        if c.get('status') == 'signed':
            pdf.ln(10); pdf.set_text_color(0, 100, 0)
            pdf.cell(0, 10, "DIGITALLY SIGNED VIA OIDC", ln=1)

        fname = f"{type}_{token}.pdf"
        pdf.output(os.path.join(cfg.CONTRACTS_DIR, fname))
        return fname
    except Exception as e:
        print(f"PDF Error: {e}")
        return None

@app.route('/')
def dash():
    if not is_staff(): return redirect('/login')
    cands = [fix_data(c) for c in db.get_all()]
    f = request.args.get('filter')
    if f == 'signed': cands = [c for c in cands if c['status'] == 'signed']
    elif f == 'active': cands = [c for c in cands if c['offboarding_status'] == 'active']
    stats = {'total': len(cands)}
    return render_template('dashboard.html', cands=cands, stats=stats, role=session.get('role'))

@app.route('/login_old_disabled')
def login_page(): return render_template('login.html', error=request.args.get('error'))

@app.route('/auth/internal', methods=['POST'])
def auth():
    u = request.form.get('username')
    p = request.form.get('password')
    conn = db.get_conn(); c = conn.cursor()
    c.execute("SELECT password_hash, role FROM users WHERE username=?", (u,))
    row = c.fetchone(); conn.close()
    
    if row and check_password_hash(row[0], p):
        session.permanent = True
        session['role'] = row[1]; session['user_token'] = u
        return redirect('/')
    return redirect('/login?error=1')

@app.route('/logout')
def logout(): session.clear(); return redirect('/login')

@app.route('/new', methods=['POST'])
def new():
    if not is_staff(): return "403"
    tk = uuid.uuid4().hex[:8]
    data = {"salary": request.form.get('salary'), "position": request.form.get('position'), "contract_type": request.form.get('contract_type', 'hpp')}
    db.upsert_candidate(tk, {"name": request.form.get('name'), "hr_data": encrypt_data(data)})
    gen_pdf(tk)
    return redirect('/')

@app.route('/recruit/upload', methods=['POST'])
def upload_cv():
    if not is_staff(): return redirect('/')
    d = omega_services.parse_cv(request.files['cv'].stream)
    if d:
        tk = uuid.uuid4().hex[:8]
        sens_data = {"position": "New", "salary": "0", "email": d['email'], "phone": d['phone']}
        db.upsert_candidate(tk, {"name": d['name'], "hr_data": encrypt_data(sens_data)})
        gen_pdf(tk)
        return redirect(f'/candidate/{tk}')
    return "CV Parsing Error"

@app.route('/candidate/<token>')
def detail(token):
    if not is_staff(): return redirect('/')
    c = fix_data(db.get_candidate(token))
    c['filename'] = f"contract_{token}.pdf"
    if not os.path.exists(os.path.join(cfg.CONTRACTS_DIR, c['filename'])): gen_pdf(token, 'contract')
    c['term_filename'] = f"termination_{token}.pdf"
    
    c['nda_filename'] = f"nda_{token}.pdf"
    if not os.path.exists(os.path.join(cfg.CONTRACTS_DIR, c['nda_filename'])): gen_pdf(token, 'nda')
        
    c['handover_filename'] = f"handover_{token}.pdf"
    if not os.path.exists(os.path.join(cfg.CONTRACTS_DIR, c['handover_filename'])): gen_pdf(token, 'handover')
    
    conn = db.get_conn(); cur = conn.cursor()
    cur.execute("SELECT * FROM evaluations WHERE user_token=?", (token,))
    evals = cur.fetchall(); conn.close()
    return render_template('candidate_detail.html', c=c, evals=evals, role=session.get('role'))

@app.route('/download/<path:f>')
def dl(f): return send_from_directory(cfg.CONTRACTS_DIR, f, as_attachment=True)

# --- MOJEID INTEGRACE S DYNAMICKOU BASE URL ---
@app.route('/auth/mojeid/verify/<token>')
def mojeid_verify(token):
    base_url = get_sys_config().get('base_url', 'http://localhost:8080').rstrip('/')
    if not mojeid or not get_sys_config().get('mojeid_client_id'):
        return "MojeID klientské klíče nejsou nastaveny v Administraci."
    session['verify_token'] = token
    return mojeid.authorize_redirect(redirect_uri=f"{base_url}/oidc/callback")

@app.route('/oidc/callback')
def mojeid_callback():
    try:
        t = mojeid.authorize_access_token()
        ui = mojeid.userinfo(token=t)
        session['pending_identity_data'] = {'name': ui.get('name', 'Neznámo'), 'birthdate': ui.get('birthdate', 'Neznámo'), 'source': 'Produkční MojeID'}
        return redirect('/auth/review_data')
    except Exception as e: return f"OIDC Error: Zkontrolujte API klíče a Base URL v Nastavení. Detail: {e}"

@app.route('/auth/review_data')
def review_data(): return render_template('review_data.html', data=session.get('pending_identity_data'))

@app.route('/auth/confirm_data', methods=['POST'])
def confirm_data():
    data = session.get('pending_identity_data'); target = session.get('verify_token')
    if data and target:
        conn = db.get_conn()
        conn.execute("UPDATE candidates SET full_name_mojeid=?, birthdate_mojeid=?, is_verified=1, status='signed' WHERE token=?", (data['name'], data['birthdate'], target))
        conn.commit(); conn.close()
        gen_pdf(target, 'contract')
        gen_pdf(target, 'nda')
        gen_pdf(target, 'handover')
        session.pop('pending_identity_data', None)
        return redirect(f"/employee/{target}")
    return "Chyba při potvrzování dat"

# Nástroje
@app.route('/manage/otp/generate/<token>', methods=['POST'])
def generate_otp(token):
    if not is_staff(): return "403"
    code = uuid.uuid4().hex; conn = db.get_conn()
    conn.execute("DELETE FROM otps WHERE user_token=?", (token,))
    conn.execute("INSERT INTO otps VALUES (?,?,0,?)", (code, token, str(datetime.date.today())))
    conn.commit(); conn.close()
    return redirect(f'/candidate/{token}?show_otp={code}')

# Generátor QR Kódu s dynamickou Base URL
@app.route('/tools/qr_otp/<code>')
def qr_gen(code):
    base_url = get_sys_config().get('base_url', 'http://localhost:8080').rstrip('/')
    img = qrcode.make(f"{base_url}/auth/magic/{code}")
    buf = io.BytesIO(); img.save(buf); buf.seek(0)
    return send_file(buf, mimetype='image/png')

@app.route('/auth/magic/<code>')
def magic_login(code):
    conn = db.get_conn(); c = conn.cursor()
    c.execute("SELECT user_token FROM otps WHERE code=? AND used=0", (code,)); r = c.fetchone()
    if r:
        conn.execute("UPDATE otps SET used=1 WHERE code=?", (code,)); conn.commit(); conn.close()
        session.permanent = True; session['user_token'] = r[0]; session['role'] = 'employee'
        return redirect(f'/employee/{r[0]}')
    return "Neplatný odkaz"

@app.route('/employee/<token>')
def emp(token):
    c = fix_data(db.get_candidate(token))
    if c['offboarding_status'] == 'terminated': return "<h1>Přístup ukončen</h1>"
    c['filename'] = f"contract_{token}.pdf"
    return render_template('employee_dashboard.html', c=c)

@app.route('/manage/evaluate/<token>', methods=['POST'])
def evaluate(token):
    if not is_staff(): return "403"
    conn = db.get_conn()
    conn.execute("INSERT INTO evaluations (user_token, rating, note, date) VALUES (?,?,?,?)", (token, request.form.get('rating'), request.form.get('note'), str(datetime.date.today())))
    conn.commit(); conn.close()
    return redirect(f'/candidate/{token}')

@app.route('/manage/terminate/<token>', methods=['POST'])
def terminate(token):
    if not is_staff(): return "403"
    conn = db.get_conn()
    conn.execute("UPDATE candidates SET offboarding_status='terminated', exit_date=? WHERE token=?", (str(datetime.date.today()), token))
    conn.commit(); conn.close()
    gen_pdf(token, 'termination')
    return redirect(f'/candidate/{token}')

@app.route('/reports')
def reports():
    if not is_staff(): return redirect('/')
    return render_template('reports.html', data={"avg_salary": 55000, "headcount": [12, 1], "total_payroll": 650000})

@app.route('/docs')
def docs(): return render_template('docs.html')

@app.route('/admin/settings', methods=['GET', 'POST'])
def settings():
    if session.get('role') != 'admin': return "403"
    success = False
    if request.method == 'POST':
        new_config = {
            "base_url": request.form.get('base_url'),
            "name": request.form.get('name'),
            "address": request.form.get('address'),
            "ceo": request.form.get('ceo'),
            "mojeid_client_id": request.form.get('mojeid_client_id'),
            "mojeid_client_secret": request.form.get('mojeid_client_secret'),
            "bankid_client_id": request.form.get('bankid_client_id'),
            "bankid_client_secret": request.form.get('bankid_client_secret')
        }
        try:
            with open('sys_config.json', 'w') as f: json.dump(new_config, f)
            success = True
        except: pass
    return render_template('settings.html', config=get_sys_config(), success=success)

if __name__ == "__main__":
    serve(app, host='0.0.0.0', port=8080)


@app.route('/hr/regenerate_pdfs', methods=['POST'])
def hr_regenerate_pdfs():
    try:
        import os
        import glob
        import omega_config as cfg
        
        # Projdeme databázi kandidátů a vynutíme generování
        if hasattr(cfg, 'DB_DIR') and os.path.exists(cfg.DB_DIR):
            for filepath in glob.glob(os.path.join(cfg.DB_DIR, '*.json')):
                token = os.path.basename(filepath).replace('.json', '')
                gen_pdf(token, 'contract')
                gen_pdf(token, 'nda')
                gen_pdf(token, 'handover')
    except Exception as e:
        print(f"Hromadna chyba PDF: {e}")
        
    from flask import redirect
    return redirect('/dashboard')


# --- RBAC (ROLE-BASED ACCESS CONTROL) MODUL ---
import json
from flask import request, session, render_template


def load_settings():
    import json
    import os
    if not os.path.exists('settings.json'):
        default = {
            "company_name": "Omega Corp",
            "company_address": "Neznámá 1, 110 00 Praha",
            "company_id": "00000000",
            "base_url": ""
        }
        with open('settings.json', 'w', encoding='utf-8') as f:
            json.dump(default, f, indent=4)
    with open('settings.json', 'r', encoding='utf-8') as f:
        return json.load(f)

def save_settings(data):
    import json
    with open('settings.json', 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=4)

@app.route('/admin/settings', methods=['GET', 'POST'])
def admin_settings():
    if not session.get('logged_in') or session.get('role') != 'admin':
        return "Přístup odepřen.", 403
    settings = load_settings()
    if request.method == 'POST':
        settings['company_name'] = request.form.get('company_name', '').strip()
        settings['company_address'] = request.form.get('company_address', '').strip()
        settings['company_id'] = request.form.get('company_id', '').strip()
        settings['base_url'] = request.form.get('base_url', '').strip()
        save_settings(settings)
        return redirect('/admin/settings')
    from flask import render_template
    return render_template('settings.html', settings=settings)

def load_users():
    if not os.path.exists('users.json'):
        with open('users.json', 'w', encoding='utf-8') as f:
            # Výchozí uživatelé, pokud soubor neexistuje
            json.dump({
                "admin": {"password": "admin", "role": "admin"},
                "hr": {"password": "hr", "role": "hr"}
            }, f, indent=4)
    with open('users.json', 'r', encoding='utf-8') as f:
        return json.load(f)

def save_users(users):
    with open('users.json', 'w', encoding='utf-8') as f:
        json.dump(users, f, indent=4)

@app.route('/login', methods=['GET', 'POST'], endpoint='rbac_login')
def rbac_login():
    if request.method == 'POST':
        username = request.form.get('username', '').strip()
        password = request.form.get('password', '').strip()
        users = load_users()
        
        if username in users and users[username]['password'] == password:
            session['logged_in'] = True
            session['user'] = username
            session['role'] = users[username]['role']
            return redirect('/dashboard')
        return "Nesprávné jméno nebo heslo. Zkuste to znovu.", 401
    return render_template('login.html')

@app.route('/admin/users', methods=['GET', 'POST'], endpoint='rbac_users')
def manage_users():
    # Tvrdá bezpečnostní kontrola - pustí jen Admina
    if not session.get('logged_in') or session.get('role') != 'admin':
        return "Přístup odepřen. Tuto sekci může spravovat pouze Administrátor.", 403
        
    users = load_users()
    if request.method == 'POST':
        action = request.form.get('action')
        username = request.form.get('username', '').strip()
        if action == 'add' and username:
            users[username] = {
                "password": request.form.get('password', ''),
                "role": request.form.get('role', 'hr')
            }
            save_users(users)
        elif action == 'change_password' and username:
            if username in users:
                users[username]['password'] = request.form.get('new_password', '')
                save_users(users)
        elif action == 'delete' and username and username != 'admin':
            if username in users:
                del users[username]
                save_users(users)
        return redirect('/admin/users')
        
    return render_template('users.html', users=users)
# ----------------------------------------------
