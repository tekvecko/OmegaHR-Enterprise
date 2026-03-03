#!/data/data/com.termux/files/usr/bin/bash
set -e

cd /data/data/com.termux/files/home/OmegaPlatinum_PROD

echo "🎨 Vytvářím Master Layout (base.html)..."
cat > templates/base.html << 'HTMLEOF'
<!DOCTYPE html>
<html lang="cs">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{% block title %}OmegaHR Enterprise{% endblock %}</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">
</head>
<body class="bg-gray-50 font-sans text-gray-800 flex h-screen overflow-hidden">
    
    <aside class="w-64 bg-gray-900 text-white flex flex-col shadow-xl z-20">
        <div class="p-6 flex items-center gap-3 border-b border-gray-800">
            <div class="w-8 h-8 bg-brand-gold rounded-lg flex items-center justify-center text-gray-900 font-black shadow-lg shadow-yellow-500/20"><i class="ri-pulse-line"></i></div>
            <span class="text-xl font-black tracking-tight">OmegaHR</span>
        </div>
        
        <nav class="flex-1 px-4 py-6 space-y-2 overflow-y-auto">
            <p class="px-4 text-xs font-bold text-gray-500 uppercase tracking-wider mb-2">Hlavní menu</p>
            <a href="/" class="flex items-center gap-3 px-4 py-3 rounded-xl hover:bg-gray-800 text-gray-300 hover:text-white transition group">
                <i class="ri-dashboard-line text-lg group-hover:text-brand-gold transition"></i> <span class="font-bold text-sm">Nástěnka</span>
            </a>
            
            {% if session.get('role') == 'admin' %}
            <div class="pt-6 pb-2">
                <p class="px-4 text-xs font-bold text-gray-500 uppercase tracking-wider mb-2">Administrace</p>
            </div>
            <a href="/admin/users" class="flex items-center gap-3 px-4 py-3 rounded-xl hover:bg-gray-800 text-gray-300 hover:text-white transition group">
                <i class="ri-group-line text-lg group-hover:text-brand-gold transition"></i> <span class="font-bold text-sm">Správa Účtů</span>
            </a>
            <a href="/admin/settings" class="flex items-center gap-3 px-4 py-3 rounded-xl hover:bg-gray-800 text-gray-300 hover:text-white transition group">
                <i class="ri-settings-3-line text-lg group-hover:text-brand-gold transition"></i> <span class="font-bold text-sm">Nastavení Firmy</span>
            </a>
            {% endif %}
        </nav>
        
        <div class="p-4 border-t border-gray-800">
            <div class="bg-gray-800 rounded-xl p-4 mb-4 flex items-center gap-3 border border-gray-700">
                <div class="w-10 h-10 rounded-full bg-gray-700 flex items-center justify-center text-gray-300 font-bold">
                    {{ session.get('user', 'U')[0]|upper }}
                </div>
                <div>
                    <p class="text-sm font-bold text-white">{{ session.get('user', 'Uživatel') }}</p>
                    <p class="text-xs text-brand-gold font-bold uppercase">{{ session.get('role', 'hr') }}</p>
                </div>
            </div>
            <a href="/logout" class="flex items-center justify-center gap-2 w-full bg-red-500/10 text-red-500 hover:bg-red-500 hover:text-white px-4 py-3 rounded-xl font-bold transition text-sm">
                <i class="ri-logout-box-r-line"></i> Odhlásit se
            </a>
        </div>
    </aside>

    <main class="flex-1 flex flex-col h-screen overflow-hidden relative">
        <header class="h-20 bg-white border-b border-gray-200 flex items-center justify-between px-8 shrink-0 z-10 shadow-sm">
            <h1 class="text-2xl font-black text-gray-800">{% block header %}Přehled{% endblock %}</h1>
            <div class="flex items-center gap-4">
                <div class="relative">
                    <i class="ri-search-line absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400"></i>
                    <input type="text" placeholder="Hledat zaměstnance..." class="bg-gray-50 border border-gray-200 text-sm rounded-full pl-10 pr-4 py-2 outline-none focus:border-gray-400 focus:bg-white transition w-64">
                </div>
                <button class="w-10 h-10 rounded-full bg-gray-50 border border-gray-200 flex items-center justify-center text-gray-500 hover:text-gray-800 hover:bg-gray-100 transition relative">
                    <i class="ri-notification-3-line"></i>
                    <span class="absolute top-2 right-2 w-2 h-2 bg-red-500 rounded-full"></span>
                </button>
            </div>
        </header>
        
        <div class="flex-1 overflow-y-auto p-8 bg-gray-50">
            <div class="max-w-6xl mx-auto">
                {% block content %}{% endblock %}
            </div>
        </div>
    </main>
</body>
</html>
HTMLEOF

echo "⚙️ Překlápím Nastavení firmy do nového designu..."
cat > templates/settings.html << 'HTMLEOF'
{% extends "base.html" %}

{% block title %}Nastavení Firmy - OmegaHR{% endblock %}
{% block header %}Globální Nastavení{% endblock %}

{% block content %}
<div class="bg-white p-8 rounded-2xl shadow-sm border border-gray-100">
    <div class="flex items-center gap-4 mb-8 pb-6 border-b border-gray-100">
        <div class="w-12 h-12 bg-gray-50 rounded-xl flex items-center justify-center text-gray-600 text-2xl border border-gray-200">
            <i class="ri-building-4-line"></i>
        </div>
        <div>
            <h2 class="text-lg font-bold text-gray-800">Firemní identita</h2>
            <p class="text-sm text-gray-500">Údaje se automaticky propisují do pracovních smluv a NDA.</p>
        </div>
    </div>

    <form action="/admin/settings" method="POST" class="space-y-6">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
            <div>
                <label class="block text-xs font-bold text-gray-500 mb-2 uppercase tracking-wide">Název společnosti</label>
                <div class="relative">
                    <i class="ri-building-line absolute left-4 top-1/2 transform -translate-y-1/2 text-gray-400"></i>
                    <input type="text" name="company_name" value="{{ settings.company_name }}" required class="w-full bg-gray-50 pl-11 p-3.5 rounded-xl outline-none border border-gray-200 focus:border-gray-400 focus:bg-white transition text-sm font-bold text-gray-700">
                </div>
            </div>
            
            <div>
                <label class="block text-xs font-bold text-gray-500 mb-2 uppercase tracking-wide">IČO</label>
                <div class="relative">
                    <i class="ri-file-info-line absolute left-4 top-1/2 transform -translate-y-1/2 text-gray-400"></i>
                    <input type="text" name="company_id" value="{{ settings.company_id }}" class="w-full bg-gray-50 pl-11 p-3.5 rounded-xl outline-none border border-gray-200 focus:border-gray-400 focus:bg-white transition text-sm font-bold text-gray-700">
                </div>
            </div>
            
            <div class="md:col-span-2">
                <label class="block text-xs font-bold text-gray-500 mb-2 uppercase tracking-wide">Sídlo společnosti (Plná adresa)</label>
                <div class="relative">
                    <i class="ri-map-pin-line absolute left-4 top-1/2 transform -translate-y-1/2 text-gray-400"></i>
                    <input type="text" name="company_address" value="{{ settings.company_address }}" required class="w-full bg-gray-50 pl-11 p-3.5 rounded-xl outline-none border border-gray-200 focus:border-gray-400 focus:bg-white transition text-sm font-bold text-gray-700">
                </div>
            </div>
            
            <div class="md:col-span-2 pt-6 border-t border-gray-100">
                <label class="block text-xs font-bold text-gray-500 mb-2 uppercase tracking-wide">Base URL (MojeID Zrok adresa)</label>
                <div class="relative">
                    <i class="ri-link absolute left-4 top-1/2 transform -translate-y-1/2 text-gray-400"></i>
                    <input type="url" name="base_url" value="{{ settings.base_url }}" class="w-full bg-gray-50 pl-11 p-3.5 rounded-xl outline-none border border-gray-200 focus:border-gray-400 focus:bg-white transition text-sm text-gray-700" placeholder="https://...">
                </div>
                <p class="text-xs text-gray-400 mt-2 flex items-center gap-1"><i class="ri-information-line"></i> Adresa, na které běží tento systém. Bez lomítka na konci.</p>
            </div>
        </div>
        
        <div class="pt-6 mt-6 border-t border-gray-100 flex justify-end">
            <button type="submit" class="bg-gray-900 text-white px-8 py-3.5 rounded-xl font-bold hover:bg-black transition shadow-lg shadow-gray-900/20 flex items-center gap-2">
                <i class="ri-save-3-line"></i> Uložit nastavení
            </button>
        </div>
    </form>
</div>
{% endblock %}
HTMLEOF

echo "🚀 Restartuji systém s novým UI jádrem..."
pkill -f python || true
./start.sh
