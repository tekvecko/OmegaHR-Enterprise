#!/data/data/com.termux/files/usr/bin/bash
set -e

PROJ="/data/data/com.termux/files/home/OmegaPlatinum_PROD"
TPL="$PROJ/templates"

echo "📱 Optimalizuji rozhraní pro mobilní zařízení a tablety..."

cat > "$TPL/layout.html" << 'HOF'
<!DOCTYPE html>
<html lang="cs">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>Omega | {{ title }}</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;800&display=swap" rel="stylesheet">
    <style>
        :root { --p: #0062cc; --bg: #f8f9fa; --sidebar: #1a1c1e; --text: #2c3e50; --border: #e2e8f0; --white: #ffffff; }
        
        body { font-family: 'Inter', sans-serif; background: var(--bg); color: var(--text); margin: 0; display: flex; height: 100vh; overflow: hidden; }

        /* Sidebar - Responzivní chování */
        .sidebar { width: 280px; background: var(--sidebar); color: white; display: flex; flex-direction: column; z-index: 1000; transition: transform 0.3s ease; }
        .sidebar-header { padding: 25px 20px; font-weight: 800; font-size: 1.2rem; color: var(--p); letter-spacing: 2px; border-bottom: 1px solid #333; display: flex; justify-content: space-between; align-items: center; }
        
        .nav-group { padding: 15px 0; flex: 1; overflow-y: auto; }
        .nav-item { padding: 12px 20px; color: #a0aec0; text-decoration: none; display: flex; align-items: center; gap: 12px; font-weight: 500; transition: 0.2s; border-left: 4px solid transparent; }
        .nav-item:hover { background: #2d3748; color: white; }
        .nav-item.active { background: #2d3748; color: white; border-left-color: var(--p); }

        /* Main Content */
        .content { flex: 1; overflow-y: auto; display: flex; flex-direction: column; width: 100%; position: relative; }
        .top-bar { height: 60px; background: var(--white); border-bottom: 1px solid var(--border); display: flex; align-items: center; justify-content: space-between; padding: 0 20px; flex-shrink: 0; }
        
        .menu-toggle { display: none; background: none; border: none; font-size: 1.5rem; color: var(--text); cursor: pointer; }

        .main-container { padding: 20px; max-width: 1200px; margin: 0 auto; width: 100%; box-sizing: border-box; }

        /* Karty a Tabulky */
        .card { background: var(--white); border: 1px solid var(--border); border-radius: 12px; padding: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.02); margin-bottom: 20px; overflow-x: auto; }
        
        .table-wrapper { width: 100%; overflow-x: auto; -webkit-overflow-scrolling: touch; }
        table { width: 100%; border-collapse: collapse; min-width: 600px; }
        th { text-align: left; padding: 12px; color: #718096; font-size: 0.75rem; border-bottom: 2px solid var(--border); text-transform: uppercase; }
        td { padding: 15px 12px; border-bottom: 1px solid var(--border); font-size: 0.9rem; }

        /* Adaptivní Grid */
        .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 20px; }

        /* MOBILE OVERRIDES */
        @media (max-width: 992px) {
            .sidebar { position: fixed; height: 100vh; transform: translateX(-100%); width: 250px; }
            .sidebar.active { transform: translateX(0); }
            .menu-toggle { display: block; }
            .top-bar { padding: 0 15px; }
            .main-container { padding: 15px; }
            .overlay { display: none; position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.5); z-index: 999; }
            .overlay.active { display: block; }
        }

        @media (max-width: 480px) {
            h1 { font-size: 1.4rem; }
            .card { padding: 15px; }
            .btn { width: 100%; justify-content: center; }
        }
    </style>
</head>
<body>
    <div class="overlay" id="overlay" onclick="toggleMenu()"></div>
    
    <div class="sidebar" id="sidebar">
        <div class="sidebar-header">
            <span><i class="fa-solid fa-gem"></i> OMEGA</span>
            <button class="menu-toggle" onclick="toggleMenu()" style="color:white;"><i class="fa-solid fa-xmark"></i></button>
        </div>
        <nav class="nav-group">
            <a href="/" class="nav-item {{ 'active' if request.path == '/' }}"><i class="fa-solid fa-gauge-high"></i> Dashboard</a>
            <a href="/agenda" class="nav-item {{ 'active' if request.path == '/agenda' }}"><i class="fa-solid fa-user-plus"></i> HR Agenda</a>
            <a href="/assets" class="nav-item {{ 'active' if request.path == '/assets' }}"><i class="fa-solid fa-boxes-stacked"></i> Logistika</a>
            <a href="/manage/contracts" class="nav-item {{ 'active' if request.path == '/manage/contracts' }}"><i class="fa-solid fa-file-contract"></i> Smlouvy</a>
            <a href="/admin/finance" class="nav-item {{ 'active' if request.path == '/admin/finance' }}"><i class="fa-solid fa-sack-dollar"></i> Finance</a>
            <a href="/manage/users" class="nav-item {{ 'active' if request.path == '/manage/users' }}"><i class="fa-solid fa-users-gear"></i> Účty</a>
            <a href="/admin/identities" class="nav-item {{ 'active' if request.path == '/admin/identities' }}"><i class="fa-solid fa-shield-halved"></i> GDPR</a>
            <a href="/audit" class="nav-item {{ 'active' if request.path == '/audit' }}"><i class="fa-solid fa-fingerprint"></i> Audit</a>
        </nav>
        <div class="sidebar-footer">
            <a href="/logout" class="nav-item" style="color: #fc8181;"><i class="fa-solid fa-power-off"></i> Odhlásit</a>
        </div>
    </div>

    <div class="content">
        <header class="top-bar">
            <button class="menu-toggle" onclick="toggleMenu()"><i class="fa-solid fa-bars"></i></button>
            <div style="font-weight: 600; color: var(--p);">{{ title }}</div>
            <div class="badge" style="background:#f1f5f9; padding: 5px 10px; border-radius: 8px; font-size: 0.8rem;">{{ session.user }}</div>
        </header>
        <main class="main-container">
            {% block content %}{% endblock %}
        </main>
    </div>

    <script>
        function toggleMenu() {
            document.getElementById('sidebar').classList.toggle('active');
            document.getElementById('overlay').classList.toggle('active');
        }
    </script>
</body>
</html>
HOF

echo "🚀 Restartuji systém s responzivním jádrem..."
pkill -f "omega_core.py" || true
nohup python3 "$PROJ/omega_core.py" > "$PROJ/dev_server.log" 2>&1 &

echo "--------------------------------------------------"
echo "💎 MOBILE-READY INTERFACE AKTIVOVÁN."
echo "Systém nyní automaticky detekuje šířku displeje."
echo "--------------------------------------------------"
