#!/data/data/com.termux/files/usr/bin/bash
set -e

TPL="/data/data/com.termux/files/home/OmegaPlatinum_PROD/templates"

echo "📱 Optimalizuji rozhraní pro mobilní zařízení a tablety..."

cat > "$TPL/layout.html" << 'HOF'
<!DOCTYPE html>
<html lang="cs">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>Omega | {{ title or 'Enterprise' }}</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;800&display=swap" rel="stylesheet">
    <style>
        :root { 
            --p: #0062cc; --bg: #f4f7f9; --sidebar: #1a1c1e; --text: #2d3748; 
            --border: #e2e8f0; --white: #ffffff; --shadow: 0 4px 6px -1px rgba(0,0,0,0.1);
        }

        * { box-sizing: border-box; -webkit-tap-highlight-color: transparent; }
        
        body { 
            font-family: 'Inter', sans-serif; background: var(--bg); color: var(--text); 
            margin: 0; display: flex; flex-direction: row; height: 100vh; overflow: hidden; 
        }

        /* Sidebar - Desktop */
        .sidebar { 
            width: 260px; background: var(--sidebar); color: white; 
            display: flex; flex-direction: column; z-index: 1000;
        }
        .sidebar-header { padding: 25px; font-weight: 800; font-size: 1.1rem; color: var(--p); border-bottom: 1px solid #2d3748; }
        .nav-group { flex: 1; overflow-y: auto; padding: 10px 0; }
        .nav-item { 
            padding: 12px 20px; color: #a0aec0; text-decoration: none; 
            display: flex; align-items: center; gap: 12px; transition: 0.2s; font-size: 0.9rem;
        }
        .nav-item:hover, .nav-item.active { background: #2d3748; color: white; }
        .nav-item.active { border-left: 4px solid var(--p); background: #2d3748; }

        /* Main Content */
        .content { flex: 1; display: flex; flex-direction: column; overflow: hidden; width: 100%; }
        .top-bar { 
            height: 60px; background: var(--white); border-bottom: 1px solid var(--border); 
            display: flex; align-items: center; justify-content: space-between; padding: 0 20px;
        }

        .main-container { 
            padding: 20px; overflow-y: auto; flex: 1; 
            -webkit-overflow-scrolling: touch;
        }

        /* Responsive Elements */
        .card { 
            background: var(--white); border-radius: 12px; padding: 20px; 
            box-shadow: var(--shadow); margin-bottom: 20px; border: 1px solid var(--border);
        }

        .table-wrapper { width: 100%; overflow-x: auto; margin-top: 10px; border-radius: 8px; border: 1px solid var(--border); }
        table { width: 100%; border-collapse: collapse; min-width: 600px; }
        th { background: #f8fafc; padding: 12px; text-align: left; font-size: 0.75rem; color: #64748b; text-transform: uppercase; }
        td { padding: 15px 12px; border-bottom: 1px solid var(--border); font-size: 0.9rem; background: white; }

        /* MOBILE STYLES (Phones) */
        @media (max-width: 768px) {
            body { flex-direction: column; }
            .sidebar { 
                width: 100%; height: auto; flex-direction: row; 
                position: fixed; bottom: 0; border-top: 1px solid #333; 
            }
            .sidebar-header { display: none; }
            .nav-group { display: flex; justify-content: space-around; padding: 5px 0; overflow: hidden; }
            .nav-item { flex-direction: column; gap: 4px; padding: 8px; font-size: 0.65rem; text-align: center; }
            .nav-item i { font-size: 1.1rem; }
            .content { padding-bottom: 60px; } /* Space for bottom nav */
            .top-bar { padding: 0 15px; }
            .main-container { padding: 15px; }
            h1 { font-size: 1.4rem; }
            .card { padding: 15px; }
        }

        /* TABLET STYLES */
        @media (min-width: 769px) and (max-width: 1024px) {
            .sidebar { width: 80px; }
            .sidebar-header span { display: none; }
            .nav-item span { display: none; }
            .nav-item { justify-content: center; padding: 15px; }
            .nav-item i { font-size: 1.4rem; }
        }
        
        .btn { 
            display: inline-flex; align-items: center; gap: 8px; padding: 10px 16px; 
            border-radius: 8px; font-weight: 600; text-decoration: none; font-size: 0.85rem;
            cursor: pointer; border: none; transition: 0.2s;
        }
        .btn-p { background: var(--p); color: white; }
    </style>
</head>
<body>
    <aside class="sidebar">
        <div class="sidebar-header"><i class="fa-solid fa-gem"></i> <span>OMEGA</span></div>
        <nav class="nav-group">
            <a href="/" class="nav-item"><i class="fa-solid fa-house"></i><span>Home</span></a>
            <a href="/agenda" class="nav-item"><i class="fa-solid fa-calendar-check"></i><span>Agenda</span></a>
            <a href="/assets" class="nav-item"><i class="fa-solid fa-laptop"></i><span>Sklad</span></a>
            <a href="/admin/finance" class="nav-item"><i class="fa-solid fa-chart-line"></i><span>Peníze</span></a>
            <a href="/manage/contracts" class="nav-item"><i class="fa-solid fa-file-signature"></i><span>Smlouvy</span></a>
            <a href="/manage/users" class="nav-item"><i class="fa-solid fa-user-gear"></i><span>Účty</span></a>
        </nav>
    </aside>
    <div class="content">
        <header class="top-bar">
            <div style="font-weight: 700; font-size: 0.9rem;">PLATINUM v18.0</div>
            <div class="user-info" style="font-size: 0.8rem; color: #64748b;">
                <i class="fa-solid fa-circle-user"></i> {{ session.user }}
            </div>
        </header>
        <main class="main-container">
            {% block content %}{% endblock %}
        </main>
    </div>
</body>
</html>
HOF

echo "🚀 Restartuji s unifikovaným responzivním designem..."
pkill -f "omega_core.py" || true
nohup python3 /data/data/com.termux/files/home/OmegaPlatinum_PROD/omega_core.py > /dev/null 2>&1 &
echo "💎 Rozhraní sjednoceno. Vyzkoušejte na tabletu nebo mobilu."
