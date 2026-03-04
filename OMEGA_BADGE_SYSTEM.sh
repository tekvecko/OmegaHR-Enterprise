#!/data/data/com.termux/files/usr/bin/bash
set -e

PROJ="/data/data/com.termux/files/home/OmegaPlatinum_PROD"
cd $PROJ

echo "📡 Aktivuji Verifikační Portál a Badge Engine..."

# 1. Update jádra o Badge logiku
python3 << 'PYEOF'
path = "omega_core.py"
with open(path, 'r') as f:
    content = f.read()

badge_logic = """
@app.route('/badge/<token>')
def badge(token):
    # Veřejný endpoint - bez nutnosti login
    emp = query_db("SELECT * FROM candidates WHERE token=?", (token,), one=True)
    if not emp: return "Neplatný verifikační token", 404
    
    # Získání majetku pro badge
    assets = query_db("SELECT name FROM assets WHERE owner_token=?", (token,))
    return render_template('welcome_portal.html', emp=emp, assets=assets)
"""

if "@app.route('/badge/<token>')" not in content:
    content = content.replace("if __name__ == '__main__':", badge_logic + "\nif __name__ == '__main__':")
    with open(path, 'w') as f:
        f.write(content)
PYEOF

# 2. Vytvoření šablony welcome_portal.html (Badge)
cat > templates/welcome_portal.html << 'HOF'
<!DOCTYPE html>
<html lang="cs">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>VERIFIKACE | OMEGA PLATINUM</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body { background: #05080a; color: white; font-family: sans-serif; display: flex; justify-content: center; align-items: center; min-height: 100vh; margin: 0; }
        .badge-card { background: linear-gradient(145deg, #0d1216, #151c23); width: 90%; max-width: 350px; padding: 40px 20px; border-radius: 20px; border: 1px solid #00d2ff; text-align: center; box-shadow: 0 0 30px rgba(0,210,255,0.2); }
        .shield-icon { font-size: 4rem; color: #00ff9d; margin-bottom: 20px; }
        .verified-text { color: #00ff9d; font-weight: bold; letter-spacing: 2px; text-transform: uppercase; font-size: 0.8rem; }
        .name { font-size: 1.8rem; margin: 15px 0 5px; }
        .id-sub { font-family: monospace; color: #6a7682; font-size: 0.9rem; }
        .info-grid { margin-top: 30px; border-top: 1px solid #1a2228; padding-top: 20px; text-align: left; }
        .info-item { margin-bottom: 10px; font-size: 0.85rem; color: #aab4be; }
        .info-item i { color: #00d2ff; width: 25px; }
    </style>
</head>
<body>
    <div class="badge-card">
        <div class="shield-icon"><i class="fa-solid fa-shield-check"></i></div>
        <div class="verified-text"><i class="fa-solid fa-circle-check"></i> MojeID VERIFIKOVÁNO</div>
        <div class="name">{{ emp.name }}</div>
        <div class="id-sub">SUB: {{ emp.mojeid_sub or 'PLATINUM-CORE-ID' }}</div>
        
        <div class="info-grid">
            <div class="info-item"><i class="fa-solid fa-calendar"></i> Členem od: {{ emp.hired_at }}</div>
            <div class="info-item"><i class="fa-solid fa-key"></i> Security Token: {{ emp.token }}</div>
            <div class="info-item"><i class="fa-solid fa-microchip"></i> Aktivní HW: {{ assets|length }} položek</div>
        </div>
        
        <div style="margin-top:30px; font-size:0.7rem; color:#444;">
            OMEGA PLATINUM SECURITY PROTOCOL v2.6
        </div>
    </div>
</body>
</html>
HOF

echo "🚀 Restartuji systém s aktivním Badge portálem..."
pkill -f "omega_core.py" || true
nohup python3 $PROJ/omega_core.py > $PROJ/dev_server.log 2>&1 &

echo "✅ HOTOVO. Veřejné badge jsou aktivní na /badge/<token>."
