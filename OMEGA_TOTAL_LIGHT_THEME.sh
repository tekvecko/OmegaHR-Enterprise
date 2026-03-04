#!/data/data/com.termux/files/usr/bin/bash
set -e

PROJ="/data/data/com.termux/files/home/OmegaPlatinum_PROD"
cd $PROJ

# 1. Společné CSS pro všechny stránky (Definice stylu)
STYLE="
    :root {
        --bg: #f4f7f9;
        --card-bg: #ffffff;
        --primary: #0062cc;
        --secondary: #5a6268;
        --text: #2c3e50;
        --border: #e1e8ed;
        --success: #28a745;
        --danger: #dc3545;
    }
    body { background: var(--bg); color: var(--text); font-family: 'Inter', sans-serif; margin: 0; padding: 15px; }
    .container { max-width: 900px; margin: 0 auto; }
    .card { background: var(--card-bg); border: 1px solid var(--border); border-radius: 12px; padding: 25px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); margin-bottom: 20px; }
    h1, h2 { color: var(--primary); margin-top: 0; }
    .btn { display: inline-flex; align-items: center; justify-content: center; padding: 12px 20px; border-radius: 8px; text-decoration: none; font-weight: 600; cursor: pointer; border: 1px solid var(--border); transition: 0.2s; font-size: 0.9rem; }
    .btn-primary { background: var(--primary); color: white; border: none; }
    .btn-primary:hover { background: #004da3; }
    input, select { width: 100%; padding: 12px; margin: 10px 0; border: 1px solid var(--border); border-radius: 8px; box-sizing: border-box; font-size: 1rem; background: #fff; }
    .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; padding-bottom: 15px; border-bottom: 2px solid var(--primary); }
    .badge { padding: 4px 10px; border-radius: 20px; font-size: 0.75rem; font-weight: bold; }
"

# 2. WELCOME PORTAL (První dojem pro kandidáty)
cat > templates/welcome_form.html << HOF
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Omega | Welcome</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>${STYLE} .mojeid-btn { background: #fff; color: #000; border: 1px solid #ccc; width: 100%; margin-bottom: 20px; }</style>
</head>
<body>
    <div class="container" style="margin-top: 50px;">
        <div class="card" style="text-align: center;">
            <div style="font-size: 3rem; color: var(--primary); margin-bottom: 10px;"><i class="fa-solid fa-gem"></i></div>
            <h1>Vítejte v OMEGA</h1>
            <p style="color: var(--secondary); margin-bottom: 30px;">Pro zahájení náboru a bezpečné generování dokumentů se prosím ověřte.</p>
            
            <a href="/auth/mojeid/verify/{{ token }}" class="btn mojeid-btn">
                <img src="https://mojeid.cz/static/img/logo.png" style="height:20px; margin-right:10px; vertical-align:middle;">
                Ověřit přes MojeID
            </a>

            <div style="margin: 20px 0; color: #ccc;">— nebo ruční zápis —</div>

            <form method="POST">
                <input type="text" name="name" placeholder="Celé jméno" required>
                <button type="submit" class="btn btn-primary" style="width: 100%;">Pokračovat k registraci</button>
            </form>
        </div>
    </div>
</body>
</html>
HOF

# 3. AGENDA (Pracovní agenda - Management)
cat > templates/agenda.html << HOF
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Omega | Agenda</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>${STYLE} .agenda-item { display: grid; grid-template-columns: 1fr; gap: 15px; align-items: center; padding: 15px; border-bottom: 1px solid var(--border); } 
    @media (min-width: 768px) { .agenda-item { grid-template-columns: 2fr 1.5fr 1.5fr auto; } }</style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1 style="margin:0;"><i class="fa-solid fa-calendar-day"></i> Pracovní Agenda</h1>
            <a href="/" class="btn"><i class="fa-solid fa-arrow-left"></i> Zpět</a>
        </div>
        <div class="card">
            {% for e in employees %}
            <form action="/api/update_agenda/{{ e.token }}" method="POST" class="agenda-item">
                <div><strong>{{ e.name }}</strong><div style="font-size:0.75rem; color:var(--secondary);">{{ e.token }}</div></div>
                <div><select name="contract_type"><option value="Full-time">Full-time</option><option value="Contractor">IČO</option></select></div>
                <div><input type="date" name="start_date" value="{{ e.start_date or '' }}"></div>
                <div style="display:flex; gap:10px;">
                    <button type="submit" class="btn btn-primary" style="padding:8px 12px;">Uložit</button>
                    <a href="/api/finalize_onboarding/{{ e.token }}" class="btn" style="background:var(--success); color:white; border:none; padding:8px 12px;">Aktivovat</a>
                </div>
            </form>
            {% endfor %}
        </div>
    </div>
</body>
</html>
HOF

# 4. ASSETS (Sklad)
cat > templates/assets.html << HOF
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Omega | Sklad</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>${STYLE}</style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1 style="margin:0;"><i class="fa-solid fa-box"></i> Skladový Management</h1>
            <a href="/" class="btn"><i class="fa-solid fa-arrow-left"></i> Zpět</a>
        </div>
        <div class="card">
            <form action="/api/add_asset" method="POST" style="display:flex; gap:10px;">
                <input type="text" name="name" placeholder="Název zařízení (např. MacBook Air)" required style="margin:0;">
                <button type="submit" class="btn btn-primary">Přidat</button>
            </form>
        </div>
        <div class="card">
            {% for a in assets %}
            <div style="display:flex; justify-content:space-between; padding:12px 0; border-bottom:1px solid var(--border);">
                <span>{{ a.name }}</span>
                <span class="badge" style="background:{{ '#ffeeba' if a.owner_token else '#d4edda' }}; color:{{ '#856404' if a.owner_token else '#155724' }};">
                    {{ a.owner_token if a.owner_token else 'VOLNÉ' }}
                </span>
            </div>
            {% endfor %}
        </div>
    </div>
</body>
</html>
HOF

# 5. AUDIT (Logy)
cat > templates/audit.html << HOF
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Omega | Audit</title>
    <style>${STYLE} .log-line { font-family: monospace; font-size: 0.8rem; padding: 8px; border-bottom: 1px solid #f1f1f1; }</style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1 style="margin:0;"><i class="fa-solid fa-shield-halved"></i> Audit Trail</h1>
            <a href="/" class="btn">Zpět</a>
        </div>
        <div class="card" style="padding:10px;">
            {% for log in logs %}
            <div class="log-line">
                <span style="color:#999;">[{{ log.timestamp }}]</span> 
                <span style="color:var(--primary); font-weight:bold;">{{ log.action }}</span> 
                <span style="color:#555;">{{ log.details }}</span>
            </div>
            {% endfor %}
        </div>
    </div>
</body>
</html>
HOF

echo "🚀 Restartuji systém v kompletním 'Enterprise Ivory' stylu..."
pkill -f "omega_core.py" || true
nohup python3 omega_core.py > dev_server.log 2>&1 &
echo "💎 TRANSFORMACE DOKONČENA. Všechny stránky jsou nyní elegantní a responzivní."
