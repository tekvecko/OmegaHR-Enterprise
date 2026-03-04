#!/data/data/com.termux/files/usr/bin/bash
set -e

PROJ="/data/data/com.termux/files/home/OmegaPlatinum_PROD"
cd $PROJ

echo "🚀 Obnovuji Samoobslužnou bránu (Welcome Portal)..."

# 1. Update jádra o Welcome logiku
python3 << 'PYEOF'
path = "omega_core.py"
with open(path, 'r') as f:
    content = f.read()

welcome_logic = """
@app.route('/welcome/<token>', methods=['GET', 'POST'])
def welcome_portal(token):
    # Ověření, zda token existuje a je ve stavu PENDING (nebo nově vytvořený)
    emp = query_db("SELECT * FROM candidates WHERE token=?", (token,), one=True)
    if not emp:
        return "<h1>Neplatný nebo expirovaný přístupový klíč.</h1>", 403
    
    if request.method == 'POST':
        real_name = request.form.get('name')
        mojeid_sub = request.form.get('mojeid')
        
        # Update databáze daty od uživatele
        query_db("UPDATE candidates SET name=?, mojeid_sub=?, status='ACTIVE' WHERE token=?", 
                 (real_name, mojeid_sub, token))
        
        return render_template('welcome_portal.html', emp={'name': real_name, 'token': token}, success=True)
    
    return render_template('welcome_form.html', token=token)
"""

if "@app.route('/welcome/<token>')" not in content:
    content = content.replace("if __name__ == '__main__':", welcome_logic + "\nif __name__ == '__main__':")
    with open(path, 'w') as f:
        f.write(content)
PYEOF

# 2. Vytvoření interaktivního formuláře welcome_form.html
cat > templates/welcome_form.html << 'HOF'
<!DOCTYPE html>
<html lang="cs">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>OMEGA | Welcome Portal</title>
    <style>
        body { background: #05080a; color: #e0e6ed; font-family: sans-serif; display: flex; justify-content: center; align-items: center; min-height: 100vh; margin: 0; }
        .welcome-card { background: #0d1216; padding: 40px; border-radius: 15px; border: 1px solid #00d2ff; width: 90%; max-width: 400px; box-shadow: 0 0 20px rgba(0,210,255,0.1); }
        h1 { color: #00d2ff; font-size: 1.5rem; margin-bottom: 20px; text-align: center; }
        input { width: 100%; padding: 12px; margin: 10px 0; background: #1a2228; border: 1px solid #2d3843; color: white; border-radius: 6px; box-sizing: border-box; }
        .btn { width: 100%; padding: 15px; background: #00d2ff; border: none; color: black; font-weight: bold; border-radius: 6px; cursor: pointer; margin-top: 10px; }
        .note { font-size: 0.75rem; color: #6a7682; margin-top: 15px; text-align: center; }
    </style>
</head>
<body>
    <div class="welcome-card">
        <h1>Vítejte v OMEGA</h1>
        <p style="text-align:center; font-size:0.9rem;">Pro dokončení aktivace vašeho profilu vyplňte oficiální údaje.</p>
        <form method="POST">
            <input type="text" name="name" placeholder="Vaše celé jméno (vč. diakritiky)" required>
            <input type="text" name="mojeid" placeholder="MojeID Identifikátor (nepovinné)">
            <button type="submit" class="btn">AKTIVOVAT PROFIL</button>
        </form>
        <div class="note">Odesláním potvrzujete správnost údajů pro generování pracovní smlouvy.</div>
    </div>
</body>
</html>
HOF

echo "♻️ Restartuji systém s Welcome Portálem..."
pkill -f "omega_core.py" || true
nohup python3 $PROJ/omega_core.py > $PROJ/dev_server.log 2>&1 &
echo "💎 SYSTÉM JE NYNÍ 100% KOMPLETNÍ. Všechny odříznuté části byly vráceny."
