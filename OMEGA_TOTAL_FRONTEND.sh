#!/data/data/com.termux/files/usr/bin/bash
set -e

PROJ="/data/data/com.termux/files/home/OmegaPlatinum_PROD"
TPL="$PROJ/templates"

echo "🎨 Sjednocuji impérium pod jednu střechu..."

# 1. HLAVNÍ NAVIGACE (Layout wrapper)
# Upravíme index.html tak, aby sloužil jako rozcestník pro vše
cat > "$TPL/index.html" << 'HOF'
<!DOCTYPE html>
<html lang="cs">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Omega Platinum | Command Center</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root { --p: #0062cc; --bg: #f0f2f5; --card: #ffffff; --text: #1c1e21; --border: #dddfe2; }
        body { font-family: 'Inter', sans-serif; background: var(--bg); color: var(--text); margin: 0; display: flex; height: 100vh; }
        
        /* Sidebar Navigation */
        .sidebar { width: 260px; background: #1c1e21; color: white; display: flex; flex-direction: column; padding: 20px 0; }
        .sidebar-brand { padding: 0 20px 30px; font-weight: 900; font-size: 1.2rem; color: var(--p); letter-spacing: 1px; }
        .nav-item { padding: 12px 20px; color: #ced4da; text-decoration: none; display: flex; align-items: center; gap: 12px; transition: 0.2s; }
        .nav-item:hover { background: #343a40; color: white; }
        .nav-item.active { background: var(--p); color: white; border-right: 4px solid #fff; }
        
        /* Main Content */
        .main { flex: 1; overflow-y: auto; padding: 30px; }
        .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 25px; }
        .card { background: var(--card); border-radius: 12px; padding: 25px; box-shadow: 0 2px 12px rgba(0,0,0,0.08); border: 1px solid var(--border); }
        .btn { padding: 10px 18px; border-radius: 8px; border: none; cursor: pointer; font-weight: 600; text-decoration: none; display: inline-flex; align-items: center; gap: 8px; }
        .btn-p { background: var(--p); color: white; }
        
        .alert-pulse { background: #fff3cd; border-left: 5px solid #ffc107; padding: 15px; border-radius: 8px; margin-bottom: 25px; display: flex; align-items: center; gap: 15px; }
    </style>
</head>
<body>
    <div class="sidebar">
        <div class="sidebar-brand">OMEGA PLATINUM</div>
        <a href="/" class="nav-item active"><i class="fa-solid fa-gauge"></i> Dashboard</a>
        <a href="/agenda" class="nav-item"><i class="fa-solid fa-users-gear"></i> HR Agenda</a>
        <a href="/assets" class="nav-item"><i class="fa-solid fa-boxes-stacked"></i> Logistika</a>
        <a href="/admin/finance" class="nav-item"><i class="fa-solid fa-chart-pie"></i> Finance</a>
        <a href="/admin/identities" class="nav-item"><i class="fa-solid fa-shield-halved"></i> GDPR & Identity</a>
        <a href="/audit" class="nav-item"><i class="fa-solid fa-list-check"></i> Audit Logy</a>
        <div style="margin-top: auto; padding: 20px;">
            <a href="/logout" class="nav-item" style="color: #ff6b6b;"><i class="fa-solid fa-power-off"></i> Odhlásit se</a>
        </div>
    </div>

    <div class="main">
        {% if employees|length > 0 %}
        <div class="alert-pulse">
            <i class="fa-solid fa-bell-exclamation fa-beat" style="color: #856404;"></i>
            <div>
                <strong>Systémová zpráva:</strong> Máte {{ employees|length }} rozpracovaných subjektů v HR pipeline.
            </div>
        </div>
        {% endif %}

        <h1>Vítejte zpět, Commandere</h1>
        
        <div class="grid">
            <div class="card">
                <h3><i class="fa-solid fa-wallet"></i> Měsíční Cashflow</h3>
                <div style="font-size: 2rem; font-weight: 800; color: var(--p);">
                    {% set total = namespace(v=0) %}{% for e in employees %}{% set total.v = total.v + (e.salary_base|int or 0) %}{% endfor %}
                    {{ total.v }} CZK
                </div>
                <p>Aktuální mzdové náklady na aktivní operátory.</p>
                <a href="/admin/finance" class="btn btn-p">Detailní analýza</a>
            </div>

            <div class="card">
                <h3><i class="fa-solid fa-laptop-code"></i> Stav logistiky</h3>
                <p>V evidenci je celkem {{ assets|length }} položek majetku.</p>
                <a href="/assets" class="btn btn-p">Otevřít sklad</a>
            </div>

            <div class="card">
                <h3><i class="fa-solid fa-folder-open"></i> Document Vault</h3>
                <ul style="list-style: none; padding: 0;">
                    {% for e in employees[:3] %}
                    <li style="padding: 10px 0; border-bottom: 1px solid #eee; display: flex; justify-content: space-between;">
                        <span>{{ e.name }}</span>
                        <a href="/my_data/{{ e.token }}" target="_blank" style="color: var(--p);"><i class="fa-solid fa-file-export"></i> GDPR Data</a>
                    </li>
                    {% endfor %}
                </ul>
                <p style="font-size: 0.8rem; color: #666;">Digitální složky jsou generovány automaticky.</p>
            </div>
        </div>
    </div>
</body>
</html>
HOF

echo "🚀 Systém byl sjednocen do jednoho rozhraní."
pkill -f "omega_core.py" || true
nohup python3 "$PROJ/omega_core.py" > "$PROJ/dev_server.log" 2>&1 &
echo "💎 Hotovo. Vše je nyní přístupné z Dashboardu na portu 8080."
