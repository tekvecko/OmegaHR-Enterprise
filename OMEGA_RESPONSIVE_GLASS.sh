#!/data/data/com.termux/files/usr/bin/bash
set -e

PROJ="/data/data/com.termux/files/home/OmegaPlatinum_PROD"
STATIC="$PROJ/static"
TPL="$PROJ/templates"

echo "📱 Optimalizuji fluidní rozhraní pro mobilní a tabletové jednotky..."

# 1. TOTAL RESPONSIVE CSS (Přepsání omega_style.css)
cat > "$STATIC/omega_style.css" << 'CSS'
:root {
    --glass: rgba(255, 255, 255, 0.7);
    --glass-dark: rgba(26, 28, 30, 0.9);
    --glass-border: rgba(255, 255, 255, 0.3);
    --p: #0062cc;
    --grad: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
}

* { 
    transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1), opacity 0.3s ease; 
    box-sizing: border-box;
}

body {
    margin: 0;
    font-family: 'Inter', system-ui, -apple-system, sans-serif;
    background: var(--grad);
    background-attachment: fixed;
    min-height: 100vh;
    display: flex;
    flex-direction: column; /* Default pro mobily */
    overflow-x: hidden;
}

/* 60FPS Akcelerace */
.main-content {
    animation: fadeIn 0.4s ease-out forwards;
    will-change: opacity, transform;
    padding: 15px;
    width: 100%;
}

@keyframes fadeIn {
    from { opacity: 0; transform: scale(0.98); }
    to { opacity: 1; transform: scale(1); }
}

/* --- ADAPTIVNÍ SIDEBAR (MOBILE FIRST) --- */
.sidebar {
    width: 100%;
    background: var(--glass-dark);
    backdrop-filter: blur(20px);
    -webkit-backdrop-filter: blur(20px);
    border-bottom: 1px solid rgba(255,255,255,0.1);
    padding: 10px 20px;
    display: flex;
    flex-direction: row;
    justify-content: space-between;
    align-items: center;
    position: sticky;
    top: 0;
    z-index: 9999;
}

.nav-links {
    display: none; /* Skryto na mobilu */
    position: absolute;
    top: 60px;
    left: 0;
    width: 100%;
    background: var(--glass-dark);
    flex-direction: column;
    padding: 20px;
}

.nav-links.active { display: flex; }

/* Desktop / Tablet Landscape (v21.0) */
@media (min-width: 1024px) {
    body { flex-direction: row; }
    .sidebar {
        width: 280px;
        height: 100vh;
        flex-direction: column;
        justify-content: flex-start;
        padding: 30px 0;
        border-bottom: none;
        border-right: 1px solid rgba(255,255,255,0.1);
    }
    .nav-links {
        display: flex;
        position: static;
        background: transparent;
        padding: 0;
    }
    .main-content { padding: 40px; }
    .menu-toggle { display: none; }
}

/* --- KARTY & GRID (RESPONSIVE) --- */
.grid {
    display: grid;
    gap: 20px;
    grid-template-columns: 1fr; /* Mobil: 1 sloupec */
}

@media (min-width: 640px) { .grid { grid-template-columns: repeat(2, 1fr); } } /* Tablet: 2 sloupce */
@media (min-width: 1200px) { .grid { grid-template-columns: repeat(3, 1fr); } } /* Desktop: 3+ sloupce */

.card {
    background: var(--glass);
    backdrop-filter: blur(12px);
    -webkit-backdrop-filter: blur(12px);
    border: 1px solid var(--glass-border);
    border-radius: 24px;
    padding: 20px;
    box-shadow: 0 8px 32px rgba(31, 38, 135, 0.08);
}

/* --- TABULKY (MOBILE OVERFLOW) --- */
.table-container {
    width: 100%;
    overflow-x: auto; /* Klíč pro mobily */
    border-radius: 15px;
}

table {
    width: 100%;
    border-collapse: separate;
    border-spacing: 0 8px;
    min-width: 500px; /* Zamezí smrštění na nečitelnost */
}

/* UX Tweak pro dotyk */
.btn {
    padding: 12px 24px;
    border-radius: 14px;
    font-weight: 600;
    cursor: pointer;
    touch-action: manipulation; /* Rychlejší reakce na mobilu */
}
CSS

# 2. UPRAVENÝ LAYOUT (S hamburger menu pro mobily)
cat > "$TPL/layout.html" << 'HOF'
<!DOCTYPE html>
<html lang="cs">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Omega | {{ title }}</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="/static/omega_style.css">
</head>
<body>
    <div class="sidebar">
        <div style="font-weight: 900; color: #00d2ff; font-size: 1.2rem;">
            <i class="fa-solid fa-gem"></i> OMEGA
        </div>
        <div class="menu-toggle" onclick="document.querySelector('.nav-links').classList.toggle('active')" style="color:white; cursor:pointer; font-size:1.5rem;">
            <i class="fa-solid fa-bars"></i>
        </div>
        <nav class="nav-links">
            <a href="/" class="nav-item"><i class="fa-solid fa-house"></i> Dashboard</a>
            <a href="/agenda" class="nav-item"><i class="fa-solid fa-users"></i> Agenda</a>
            <a href="/assets" class="nav-item"><i class="fa-solid fa-laptop"></i> Sklad</a>
            <a href="/manage/contracts" class="nav-item"><i class="fa-solid fa-file-contract"></i> Smlouvy</a>
            <a href="/admin/finance" class="nav-item"><i class="fa-solid fa-coins"></i> Finance</a>
            <a href="/admin/identities" class="nav-item"><i class="fa-solid fa-fingerprint"></i> MojeID</a>
            <a href="/logout" class="nav-item" style="color:#ff8a8a;"><i class="fa-solid fa-power-off"></i> Logout</a>
        </nav>
    </div>
    <div class="main-content">
        {% block content %}{% endblock %}
    </div>
</body>
</html>
HOF

echo "🚀 Restartuji s Total-Responsive Glass Engine..."
pkill -f "omega_core.py" || true
nohup python3 "$PROJ/omega_core.py" > "$PROJ/dev_server.log" 2>&1 &
echo "💎 RESPONZIVITA DOKONČENA. Systém nyní pluje na mobilu, tabletu i PC."
