#!/data/data/com.termux/files/usr/bin/bash
set -e

cd /data/data/com.termux/files/home/OmegaPlatinum_PROD

echo "📝 Překlápím Náborový formulář (new.html) do Enterprise designu..."
cat > templates/new.html << 'HTMLEOF'
{% extends "base.html" %}

{% block title %}Nový nástup - OmegaHR{% endblock %}
{% block header %}Založení nového profilu{% endblock %}

{% block content %}
<form action="/new" method="POST" class="max-w-5xl mx-auto space-y-6">
    <div class="flex items-center justify-between mb-2">
        <div>
            <h2 class="text-xl font-black text-gray-900">Vyplňte údaje nového kolegy</h2>
            <p class="text-sm text-gray-500">Po uložení se automaticky vygeneruje Pracovní smlouva a NDA.</p>
        </div>
        <a href="/" class="text-gray-500 hover:text-gray-900 text-sm font-bold flex items-center gap-2 transition">
            <i class="ri-close-line text-lg"></i> Zrušit
        </a>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <div class="bg-white p-8 rounded-2xl shadow-sm border border-gray-100">
            <h3 class="text-xs font-bold text-gray-400 uppercase tracking-widest mb-6 flex items-center gap-2 border-b border-gray-100 pb-4">
                <i class="ri-user-smile-line text-lg text-brand-gold"></i> 1. Osobní údaje
            </h3>
            <div class="space-y-5">
                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <label class="block text-xs font-bold text-gray-500 mb-2 uppercase">Jméno</label>
                        <input type="text" name="name" required class="w-full bg-gray-50 p-3.5 rounded-xl outline-none border border-gray-200 focus:border-brand-gold focus:bg-white transition text-sm font-bold text-gray-700">
                    </div>
                    <div>
                        <label class="block text-xs font-bold text-gray-500 mb-2 uppercase">Příjmení</label>
                        <input type="text" name="surname" required class="w-full bg-gray-50 p-3.5 rounded-xl outline-none border border-gray-200 focus:border-brand-gold focus:bg-white transition text-sm font-bold text-gray-700">
                    </div>
                </div>
                <div>
                    <label class="block text-xs font-bold text-gray-500 mb-2 uppercase">Osobní E-mail</label>
                    <input type="email" name="email" required class="w-full bg-gray-50 p-3.5 rounded-xl outline-none border border-gray-200 focus:border-brand-gold focus:bg-white transition text-sm text-gray-700 font-mono">
                </div>
                <div>
                    <label class="block text-xs font-bold text-gray-500 mb-2 uppercase">Telefon</label>
                    <input type="text" name="phone" class="w-full bg-gray-50 p-3.5 rounded-xl outline-none border border-gray-200 focus:border-brand-gold focus:bg-white transition text-sm text-gray-700">
                </div>
                <div>
                    <label class="block text-xs font-bold text-gray-500 mb-2 uppercase">Datum narození</label>
                    <input type="text" name="birthdate" placeholder="DD.MM.YYYY" required class="w-full bg-gray-50 p-3.5 rounded-xl outline-none border border-gray-200 focus:border-brand-gold focus:bg-white transition text-sm text-gray-700">
                </div>
                <div>
                    <label class="block text-xs font-bold text-gray-500 mb-2 uppercase">Trvalé bydliště (Plná adresa)</label>
                    <input type="text" name="address" required class="w-full bg-gray-50 p-3.5 rounded-xl outline-none border border-gray-200 focus:border-brand-gold focus:bg-white transition text-sm text-gray-700">
                </div>
            </div>
        </div>

        <div class="bg-white p-8 rounded-2xl shadow-sm border border-gray-100">
            <h3 class="text-xs font-bold text-gray-400 uppercase tracking-widest mb-6 flex items-center gap-2 border-b border-gray-100 pb-4">
                <i class="ri-briefcase-line text-lg text-brand-gold"></i> 2. Pracovní zařazení
            </h3>
            <div class="space-y-5">
                <div>
                    <label class="block text-xs font-bold text-gray-500 mb-2 uppercase">Typ úvazku</label>
                    <select name="contract_type" class="w-full bg-gray-50 p-3.5 rounded-xl outline-none border border-gray-200 focus:border-brand-gold focus:bg-white transition text-sm font-bold text-gray-700 appearance-none">
                        <option value="HPP">HPP - Hlavní pracovní poměr</option>
                        <option value="DPP">DPP - Dohoda o provedení práce</option>
                        <option value="ICO">IČO - Kontraktor (B2B)</option>
                    </select>
                </div>
                <div>
                    <label class="block text-xs font-bold text-gray-500 mb-2 uppercase">Název pozice</label>
                    <input type="text" name="position" required class="w-full bg-gray-50 p-3.5 rounded-xl outline-none border border-gray-200 focus:border-brand-gold focus:bg-white transition text-sm font-bold text-gray-700">
                </div>
                <div>
                    <label class="block text-xs font-bold text-gray-500 mb-2 uppercase">Oddělení (Department)</label>
                    <input type="text" name="department" class="w-full bg-gray-50 p-3.5 rounded-xl outline-none border border-gray-200 focus:border-brand-gold focus:bg-white transition text-sm text-gray-700">
                </div>
                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <label class="block text-xs font-bold text-gray-500 mb-2 uppercase">Datum nástupu</label>
                        <input type="text" name="start_date" placeholder="DD.MM.YYYY" required class="w-full bg-gray-50 p-3.5 rounded-xl outline-none border border-gray-200 focus:border-brand-gold focus:bg-white transition text-sm text-gray-700">
                    </div>
                    <div>
                        <label class="block text-xs font-bold text-gray-500 mb-2 uppercase">Hrubá mzda (Kč)</label>
                        <input type="number" name="salary" required class="w-full bg-gray-50 p-3.5 rounded-xl outline-none border border-gray-200 focus:border-brand-gold focus:bg-white transition text-sm font-black text-gray-900">
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="bg-white p-6 rounded-2xl shadow-sm border border-gray-100 flex items-center justify-between sticky bottom-6 z-10">
        <p class="text-sm text-gray-500"><i class="ri-shield-check-line text-green-500"></i> Data jsou bezpečně uložena s 256-bit šifrováním.</p>
        <button type="submit" class="bg-gray-900 text-brand-gold px-8 py-4 rounded-xl font-black hover:bg-black transition shadow-xl shadow-gray-900/30 flex items-center gap-2">
            Založit profil a vygenerovat dokumenty <i class="ri-arrow-right-line"></i>
        </button>
    </div>
</form>
{% endblock %}
HTMLEOF

echo "👔 Překlápím Portál zaměstnance (employee.html) do izolovaného Self-Service designu..."
cat > templates/employee.html << 'HTMLEOF'
<!DOCTYPE html>
<html lang="cs">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Můj Profil - OmegaHR</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">
</head>
<body class="bg-gray-100 font-sans text-gray-800 min-h-screen flex flex-col">
    
    <header class="bg-gray-900 text-white shadow-md">
        <div class="max-w-6xl mx-auto px-6 h-20 flex items-center justify-between">
            <div class="flex items-center gap-3">
                <div class="w-10 h-10 bg-brand-gold rounded-lg flex items-center justify-center text-gray-900 font-black shadow-lg shadow-yellow-500/20"><i class="ri-user-smile-line text-xl"></i></div>
                <div>
                    <h1 class="font-black text-lg tracking-tight">Můj Portál</h1>
                    <p class="text-[10px] text-gray-400 uppercase tracking-widest">{{ comp.company_name if comp else 'OmegaHR' }}</p>
                </div>
            </div>
            <div class="flex items-center gap-4">
                <div class="text-right hidden md:block">
                    <p class="text-sm font-bold text-white">{{ c.personal_data.name }} {{ c.personal_data.surname }}</p>
                    <p class="text-xs text-brand-gold">{{ c.hr_data.position }}</p>
                </div>
                <div class="w-10 h-10 rounded-full bg-gray-800 border-2 border-gray-700 flex items-center justify-center font-bold">
                    {{ c.personal_data.name[0] }}
                </div>
            </div>
        </div>
    </header>

    <main class="flex-1 max-w-6xl mx-auto w-full px-6 py-10">
        
        <div class="bg-white rounded-3xl p-8 md:p-12 shadow-sm border border-gray-200 mb-8 relative overflow-hidden">
            <div class="absolute top-0 right-0 w-64 h-64 bg-brand-gold/5 rounded-bl-[100px] -z-0"></div>
            <div class="relative z-10">
                <h2 class="text-3xl md:text-4xl font-black text-gray-900 mb-4">Vítej, {{ c.personal_data.name }}! 👋</h2>
                <p class="text-gray-600 max-w-2xl text-lg">Tohle je tvůj osobní prostor. Zde najdeš všechny své podepsané dokumenty, směrnice a v budoucnu zde budeš moci žádat o dovolenou nebo hlásit sick days.</p>
                
                {% if c.status == 'pending' %}
                <div class="mt-8 inline-flex items-center gap-3 bg-yellow-50 border border-yellow-200 text-yellow-800 px-6 py-4 rounded-2xl shadow-sm">
                    <i class="ri-error-warning-fill text-2xl text-yellow-500"></i>
                    <div>
                        <p class="font-bold text-sm">Tvůj profil čeká na finální potvrzení</p>
                        <p class="text-xs text-yellow-700 mt-0.5">HR oddělení právě připravuje tvé dokumenty.</p>
                    </div>
                </div>
                {% endif %}
            </div>
        </div>

        <h3 class="text-xl font-black text-gray-800 mb-6 flex items-center gap-2"><i class="ri-folder-shield-2-line text-brand-gold"></i> Moje osobní složka</h3>
        
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div class="bg-white rounded-2xl p-6 shadow-sm border border-gray-200 flex flex-col">
                <div class="w-14 h-14 bg-red-50 text-red-500 rounded-xl flex items-center justify-center text-3xl mb-4"><i class="ri-file-text-line"></i></div>
                <h4 class="font-bold text-gray-900 text-lg mb-1">Pracovní smlouva</h4>
                <p class="text-sm text-gray-500 flex-1 mb-6">Finální podepsaná verze tvé pracovní smlouvy.</p>
                <a href="/download/{{ c.token }}_contract.pdf" target="_blank" class="w-full text-center bg-gray-50 hover:bg-gray-100 border border-gray-200 text-gray-700 font-bold py-3 rounded-xl transition flex items-center justify-center gap-2">
                    <i class="ri-download-2-line"></i> Stáhnout PDF
                </a>
            </div>

            <div class="bg-white rounded-2xl p-6 shadow-sm border border-gray-200 flex flex-col">
                <div class="w-14 h-14 bg-gray-50 text-gray-600 rounded-xl flex items-center justify-center text-3xl mb-4"><i class="ri-file-lock-line"></i></div>
                <h4 class="font-bold text-gray-900 text-lg mb-1">Dohoda o mlčenlivosti</h4>
                <p class="text-sm text-gray-500 flex-1 mb-6">Dokument NDA chránící firemní know-how.</p>
                <a href="/download/{{ c.token }}_nda.pdf" target="_blank" class="w-full text-center bg-gray-50 hover:bg-gray-100 border border-gray-200 text-gray-700 font-bold py-3 rounded-xl transition flex items-center justify-center gap-2">
                    <i class="ri-download-2-line"></i> Stáhnout PDF
                </a>
            </div>

            <div class="bg-white rounded-2xl p-6 shadow-sm border border-gray-200 flex flex-col">
                <div class="w-14 h-14 bg-blue-50 text-blue-500 rounded-xl flex items-center justify-center text-3xl mb-4"><i class="ri-macbook-line"></i></div>
                <h4 class="font-bold text-gray-900 text-lg mb-1">Předávací protokol</h4>
                <p class="text-sm text-gray-500 flex-1 mb-6">Soupis svěřeného majetku (Notebook, klíče).</p>
                <a href="/download/{{ c.token }}_handover.pdf" target="_blank" class="w-full text-center bg-gray-50 hover:bg-gray-100 border border-gray-200 text-gray-700 font-bold py-3 rounded-xl transition flex items-center justify-center gap-2">
                    <i class="ri-download-2-line"></i> Stáhnout PDF
                </a>
            </div>
        </div>

    </main>
    
    <footer class="text-center py-6 text-sm text-gray-400 font-bold">
        OmegaHR Self-Service &copy; 2024
    </footer>
</body>
</html>
HTMLEOF

echo "🚀 Restartuji server s hotovým Enterprise UI..."
pkill -f python || true
./start.sh
