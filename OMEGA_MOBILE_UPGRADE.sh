#!/data/data/com.termux/files/usr/bin/bash
set -e

PROJ="/data/data/com.termux/files/home/OmegaPlatinum_PROD"
TPL="$PROJ/templates"

echo "📱 Optimalizuji rozhraní pro mobilní zařízení a tablety..."

# Úprava layout.html s Media Queries
cat > "$TPL/layout.html" << 'HOF'
<!DOCTYPE html>
<html lang="cs">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>Omega Platinum | {{ title }}</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;800&display=swap" rel="stylesheet">
    <style>
        :root { --p: #0062cc; --bg: #f8f9fa; --sidebar: #1a1c1e; --text: #2c3e50; --border: #e2e8f0; --white: #ffffff; }
        body { font-family: 'Inter', sans-serif; background: var(--bg); color: var(--text); margin: 0; display: flex; height: 100vh; overflow: hidden; }
        
        /* Sidebar - Desktop Default */
        .sidebar { width: 280px; background: var(--sidebar); color: white; display: flex; flex-direction: column; transition: 0.3s; z-index: 1000; }
        .sidebar-header { padding: 30px 20px; font-weight: 800; font-size: 1.3rem; color: var(--p); letter-spacing: 2px; border-bottom: 1px solid #333; }
        .nav-group { padding: 20px 0; flex: 1; overflow-y: auto; }
        .nav-item { padding: 14px 25px; color: #a0aec0; text-decoration: none; display: flex; align-items: center; gap: 15px; font-weight: 500; transition: 0.2s; }
        .nav-item:hover { background: #2d3748; color: white; }
        .nav-item.active { background: var(--p); color: white; }

        /* Content Area */
        .content { flex: 1; overflow-y: auto; display: flex; flex-direction: column; width: 100%; }
        .top-bar { height: 60px; background: var(--white); border-bottom: 1px solid var(--border); display: flex; align-items: center; justify-content: space-between; padding: 0 20px; flex-shrink: 0; }
        .main-container { padding: 20px; max-width: 1200px; margin: 0 auto; width: 100%; box-sizing: border-box; }

        /* Responsive Breakpoints */
        @media (max-width: 1024px) {
            .sidebar { width: 80px; }
            .sidebar-header span, .nav-item span { display: none; }
            .nav-item { justify-content: center; padding: 20px; }
        }

        @media (max-width: 768px) {
            body { flex-direction: column; }
            .sidebar { width: 100%; height: auto; flex-direction: row; position: fixed; bottom: 0; border-top: 1px solid #333; }
            .sidebar-header { display: none; }
            .nav-group { display: flex; flex-direction: row; padding: 0; justify-content: space-around; width: 100%; }
            .nav-item { flex-direction: column; gap: 5px; font-size: 0.6rem; padding: 10px 5px; }
            .nav-item i { font-size: 1.2rem; }
            .content { padding-bottom: 70px; } /* Space for bottom nav */
            .top-bar { padding: 0 15px; }
            .main-container { padding: 15px; }
            .card { padding: 15px; }
            h1 { font-size: 1.4rem; }
            
            /* Table optimization for mobile */
            table, thead, tbody, th, td, tr { display: block; }
            thead tr { position: absolute; top: -9999px; left: -9999px; }
            tr { border: 1px solid var(--border); margin-bottom: 10px; border-radius: 8px; background: #fff; }
            td { border: none; position: relative; padding-left: 50%; text-align: right; border-bottom: 1px solid #eee; }
            td:before { position: absolute; left: 15px; width: 45%; text-align: left; font-weight: bold; content: attr(data-label); color: var(--p); }
        }

        /* Generic Components */
        .card { background: var(--white); border: 1px solid var(--border); border-radius: 12px; padding: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.02); margin-bottom: 20px; }
        .btn { padding: 10px 15px; border-radius: 8px; font-weight: 600; text-decoration: none; display: inline-flex; align-items: center; gap: 8px; border: none; font-size: 0.9rem; }
        .btn-p { background: var(--p); color: white; }
    </style>
</head>
<body>
    <div class="sidebar">
        <div class="sidebar-header"><i class="fa-solid fa-gem"></i> <span>OMEGA</span></div>
        <nav class="nav-group">
            <a href="/" class="nav-item"><i class="fa-solid fa-gauge-high"></i> <span>Dashboard</span></a>
            <a href="/agenda" class="nav-item"><i class="fa-solid fa-user-plus"></i> <span>Agenda</span></a>
            <a href="/assets" class="nav-item"><i class="fa-solid fa-box"></i> <span>Sklad</span></a>
            <a href="/admin/finance" class="nav-item"><i class="fa-solid fa-wallet"></i> <span>Finance</span></a>
            <a href="/manage/users" class="nav-item"><i class="fa-solid fa-users"></i> <span>Účty</span></a>
        </nav>
    </div>
    <div class="content">
        <header class="top-bar">
            <div style="font-weight: 800; color: var(--p); font-size: 0.9rem;">PLATINUM v18.0</div>
            <div class="badge">{{ session.user }}</div>
        </header>
        <main class="main-container">
            {% block content %}{% endblock %}
        </main>
    </div>
</body>
</html>
HOF

echo "🚀 Restartuji s mobilní optimalizací..."
pkill -f "omega_core.py" || true
nohup python3 "$PROJ/omega_core.py" > "$PROJ/dev_server.log" 2>&1 &
echo "💎 MOBILNÍ ROZHRANÍ AKTIVOVÁNO. Zkontroluj na tabletu nebo telefonu."
