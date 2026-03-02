import traceback
import os, glob
import omega_config as cfg
from omega_core import app, gen_pdf

app.config['TESTING'] = True

print("🔍 DIAGNOSTIKA SYSTÉMU")
print("----------------------------------------")
print("1. TEST ADMIN SEKCE:")
try:
    with app.test_client() as c:
        with c.session_transaction() as sess:
            sess['logged_in'] = True
            sess['role'] = 'admin'
        c.get('/admin/users')
    print("✅ Admin sekce běží v pořádku.")
except Exception as e:
    print("❌ Admin sekce padá na této chybě:")
    traceback.print_exc()

print("\n2. TEST PDF GENERÁTORU:")
try:
    db_path = getattr(cfg, 'DB_DIR', '.')
    files = glob.glob(os.path.join(db_path, '*.json'))
    if files:
        token = os.path.basename(files[0]).replace('.json', '')
        gen_pdf(token, 'contract')
        print("✅ PDF Generátor běží v pořádku.")
    else:
        print("⚠️ Žádná data kandidátů k testu.")
except Exception as e:
    print("❌ PDF Generátor padá na této chybě:")
    traceback.print_exc()
print("----------------------------------------")
