#!/data/data/com.termux/files/usr/bin/bash
set -e

cd /data/data/com.termux/files/home/OmegaPlatinum_PROD

echo "👤 Překlápím Kartu zaměstnance (candidate.html) do Enterprise designu..."
cat > templates/candidate.html << 'HTMLEOF'
{% extends "base.html" %}

{% block title %}Karta zaměstnance - OmegaHR{% endblock %}
{% block header %}Detail profilu{% endblock %}

{% block content %}
<div class="space-y-6">
    
    <div class="bg-white p-8 rounded-2xl shadow-sm border border-gray-100 flex flex-col md:flex-row justify-between items-start md:items-center gap-6 relative overflow-hidden">
        <div class="absolute top-0 right-0 w-32 h-32 bg-brand-gold/10 rounded-bl-full -z-0"></div>
        <div class="flex items-center gap-6 z-10">
            <div class="w-20 h-20 rounded-2xl bg-gray-900 flex items-center justify-center text-brand-gold font-black border-4 border-white shadow-xl text-3xl">
                {{ c.personal_data.name[0] if c.personal_data and c.personal_data.name else '?' }}
            </div>
            <div>
                <h2 class="text-3xl font-black text-gray-900 tracking-tight">{{ c.personal_data.name }} {{ c.personal_data.surname }}</h2>
                <div class="flex items-center gap-3 mt-2">
                    <span class="text-sm font-bold text-gray-500 uppercase tracking-widest"><i class="ri-briefcase-line"></i> {{ c.hr_data.position if c.hr_data else 'Bez pozice' }}</span>
                    <span class="text-gray-300">•</span>
                    {% if c.offboarding_status == 'terminated' %}
                        <span class="inline-flex items-center gap-1.5 bg-red-50 text-red-600 border border-red-200 px-3 py-1 rounded-full text-xs font-bold shadow-sm">
                            <span class="w-1.5 h-1.5 rounded-full bg-red-500"></span> Ukončeno
                        </span>
                    {% elif c.status == 'signed' %}
                        <span class="inline-flex items-center gap-1.5 bg-green-50 text-green-600 border border-green-200 px-3 py-1 rounded-full text-xs font-bold shadow-sm">
                            <span class="w-1.5 h-1.5 rounded-full bg-green-500"></span> Aktivní zaměstnanec
                        </span>
                    {% else %}
                        <span class="inline-flex items-center gap-1.5 bg-yellow-50 text-yellow-600 border border-yellow-200 px-3 py-1 rounded-full text-xs font-bold shadow-sm">
                            <span class="w-1.5 h-1.5 rounded-full bg-yellow-500"></span> Onboarding
                        </span>
                    {% endif %}
                </div>
            </div>
        </div>
        <div class="z-10">
            <a href="/" class="text-gray-500 bg-gray-100 hover:bg-gray-200 px-5 py-2.5 rounded-xl text-sm font-bold transition flex items-center gap-2 shadow-sm">
                <i class="ri-arrow-left-line"></i> Zpět na nástěnku
            </a>
        </div>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        
        <div class="bg-white p-6 rounded-2xl shadow-sm border border-gray-100">
            <h3 class="text-xs font-bold text-gray-400 uppercase tracking-widest mb-6 flex items-center gap-2 border-b border-gray-100 pb-4">
                <i class="ri-user-3-line text-lg text-gray-800"></i> Osobní informace
            </h3>
            <ul class="space-y-4">
                <li class="flex justify-between items-center"><span class="text-sm text-gray-500 font-bold">E-mail:</span> <span class="text-sm font-mono text-gray-900 bg-gray-50 px-3 py-1 rounded-lg border border-gray-200">{{ c.personal_data.email }}</span></li>
                <li class="flex justify-between items-center"><span class="text-sm text-gray-500 font-bold">Telefon:</span> <span class="text-sm text-gray-900">{{ c.personal_data.phone }}</span></li>
                <li class="flex justify-between items-center"><span class="text-sm text-gray-500 font-bold">Adresa:</span> <span class="text-sm text-gray-900 text-right">{{ c.personal_data.address }}</span></li>
                <li class="flex justify-between items-center"><span class="text-sm text-gray-500 font-bold">Datum nar.:</span> <span class="text-sm text-gray-900">{{ c.personal_data.birthdate }}</span></li>
            </ul>
        </div>

        <div class="bg-white p-6 rounded-2xl shadow-sm border border-gray-100">
            <h3 class="text-xs font-bold text-gray-400 uppercase tracking-widest mb-6 flex items-center gap-2 border-b border-gray-100 pb-4">
                <i class="ri-folder-user-line text-lg text-gray-800"></i> Firemní zařazení
            </h3>
            <ul class="space-y-4">
                <li class="flex justify-between items-center"><span class="text-sm text-gray-500 font-bold">Typ úvazku:</span> <span class="text-sm font-bold uppercase text-gray-900">{{ c.hr_data.contract_type if c.hr_data else 'N/A' }}</span></li>
                <li class="flex justify-between items-center"><span class="text-sm text-gray-500 font-bold">Oddělení:</span> <span class="text-sm text-gray-900">{{ c.hr_data.department if c.hr_data else 'N/A' }}</span></li>
                <li class="flex justify-between items-center"><span class="text-sm text-gray-500 font-bold">Aktuální mzda:</span> <span class="text-sm font-black text-brand-gold bg-gray-900 px-3 py-1 rounded-lg shadow-sm">{{ c.hr_data.salary if c.hr_data else '0' }} Kč</span></li>
                <li class="flex justify-between items-center"><span class="text-sm text-gray-500 font-bold">Nástup:</span> <span class="text-sm text-gray-900">{{ c.hr_data.start_date if c.hr_data else 'N/A' }}</span></li>
            </ul>
        </div>
    </div>

    <div class="bg-white p-6 rounded-2xl shadow-sm border border-gray-100">
        <h3 class="text-xs font-bold text-gray-400 uppercase tracking-widest mb-6 flex items-center gap-2 border-b border-gray-100 pb-4">
            <i class="ri-file-pdf-2-line text-lg text-gray-800"></i> Vygenerované dokumenty
        </h3>
        <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
            <a href="/download/{{ c.token }}_contract.pdf" target="_blank" class="flex flex-col items-center p-4 bg-gray-50 border border-gray-200 rounded-xl hover:bg-white hover:border-gray-300 hover:shadow-md transition group text-center">
                <i class="ri-file-text-fill text-3xl text-red-500 mb-2 group-hover:scale-110 transition"></i>
                <span class="text-xs font-bold text-gray-700">Pracovní smlouva</span>
            </a>
            <a href="/download/{{ c.token }}_nda.pdf" target="_blank" class="flex flex-col items-center p-4 bg-gray-50 border border-gray-200 rounded-xl hover:bg-white hover:border-gray-300 hover:shadow-md transition group text-center">
                <i class="ri-file-lock-fill text-3xl text-gray-700 mb-2 group-hover:scale-110 transition"></i>
                <span class="text-xs font-bold text-gray-700">Dohoda NDA</span>
            </a>
            <a href="/download/{{ c.token }}_handover.pdf" target="_blank" class="flex flex-col items-center p-4 bg-gray-50 border border-gray-200 rounded-xl hover:bg-white hover:border-gray-300 hover:shadow-md transition group text-center">
                <i class="ri-macbook-line text-3xl text-blue-500 mb-2 group-hover:scale-110 transition"></i>
                <span class="text-xs font-bold text-gray-700">Předávací protokol</span>
            </a>
            
            {% if c.hr_data and c.hr_data.get('salary_history') %}
            <a href="/download/{{ c.token }}_salary.pdf" target="_blank" class="flex flex-col items-center p-4 bg-gray-50 border border-gray-200 rounded-xl hover:bg-white hover:border-gray-300 hover:shadow-md transition group text-center">
                <i class="ri-money-dollar-circle-fill text-3xl text-green-500 mb-2 group-hover:scale-110 transition"></i>
                <span class="text-xs font-bold text-gray-700">Mzdový výměr</span>
            </a>
            {% endif %}
            
            {% if c.offboarding_status == 'terminated' %}
            <a href="/download/{{ c.token }}_{{ c.term_type }}.pdf" target="_blank" class="flex flex-col items-center p-4 bg-red-50 border border-red-200 rounded-xl hover:bg-white hover:border-red-300 hover:shadow-md transition group text-center">
                <i class="ri-file-damage-fill text-3xl text-red-600 mb-2 group-hover:scale-110 transition"></i>
                <span class="text-xs font-bold text-red-700">Ukončení poměru</span>
            </a>
            {% endif %}
        </div>
    </div>

    {% if c.status == 'signed' and c.offboarding_status != 'terminated' %}
    <div class="bg-white p-6 rounded-2xl shadow-sm border border-gray-100 bg-gradient-to-r from-gray-900 to-gray-800 text-white relative overflow-hidden">
        <h3 class="text-xs font-bold text-gray-400 uppercase tracking-widest mb-6 flex items-center gap-2 border-b border-gray-700 pb-4">
            <i class="ri-settings-4-line text-lg text-brand-gold"></i> Správa životního cyklu (HR Akce)
        </h3>
        <div class="flex flex-wrap gap-4">
            <button onclick="openModal('salaryModal')" class="bg-gray-800 border border-gray-600 hover:border-brand-gold hover:text-brand-gold px-5 py-3 rounded-xl text-sm font-bold transition flex items-center gap-2 shadow-sm">
                <i class="ri-money-czk-circle-line"></i> Změna platu
            </button>
            <button onclick="openModal('positionModal')" class="bg-gray-800 border border-gray-600 hover:border-brand-gold hover:text-brand-gold px-5 py-3 rounded-xl text-sm font-bold transition flex items-center gap-2 shadow-sm">
                <i class="ri-briefcase-4-line"></i> Změna pozice
            </button>
            <button onclick="openModal('offboardModal')" class="bg-red-500/20 text-red-400 border border-red-500/30 hover:bg-red-500 hover:text-white px-5 py-3 rounded-xl text-sm font-bold transition flex items-center gap-2 shadow-sm ml-auto">
                <i class="ri-user-unfollow-line"></i> Ukončit pracovní poměr
            </button>
        </div>
    </div>
    {% endif %}

</div>

<div id="salaryModal" class="hidden fixed inset-0 bg-gray-900/80 backdrop-blur-sm z-50 flex items-center justify-center p-4 transition-opacity">
    <div class="bg-white rounded-2xl w-full max-w-md overflow-hidden shadow-2xl transform transition-all">
        <div class="p-6 border-b border-gray-100 bg-gray-50 flex justify-between items-center">
            <h3 class="font-bold text-gray-900 text-lg flex items-center gap-2"><i class="ri-money-czk-circle-line text-green-500"></i> Nový mzdový výměr</h3>
            <button onclick="closeModal('salaryModal')" class="text-gray-400 hover:text-red-500 text-2xl leading-none">&times;</button>
        </div>
        <form action="/hr/lifecycle/{{ c.token }}" method="POST" class="p-6">
            <input type="hidden" name="action" value="salary">
            <label class="block text-xs font-bold text-gray-500 mb-2 uppercase">Nová hrubá mzda (Kč)</label>
            <input type="number" name="new_salary" class="w-full bg-gray-50 p-4 rounded-xl outline-none border border-gray-200 focus:border-brand-gold mb-6 font-black text-xl" placeholder="např. 65000" required>
            <div class="flex gap-3">
                <button type="button" onclick="closeModal('salaryModal')" class="flex-1 bg-gray-100 text-gray-600 font-bold py-3 rounded-xl hover:bg-gray-200 transition">Zrušit</button>
                <button type="submit" class="flex-1 bg-gray-900 text-brand-gold font-bold py-3 rounded-xl hover:bg-black shadow-lg shadow-gray-900/20 transition">Vystavit výměr</button>
            </div>
        </form>
    </div>
</div>

<div id="positionModal" class="hidden fixed inset-0 bg-gray-900/80 backdrop-blur-sm z-50 flex items-center justify-center p-4 transition-opacity">
    <div class="bg-white rounded-2xl w-full max-w-md overflow-hidden shadow-2xl transform transition-all">
        <div class="p-6 border-b border-gray-100 bg-gray-50 flex justify-between items-center">
            <h3 class="font-bold text-gray-900 text-lg flex items-center gap-2"><i class="ri-briefcase-4-line text-blue-500"></i> Dodatek ke smlouvě (Pozice)</h3>
            <button onclick="closeModal('positionModal')" class="text-gray-400 hover:text-red-500 text-2xl leading-none">&times;</button>
        </div>
        <form action="/hr/lifecycle/{{ c.token }}" method="POST" class="p-6">
            <input type="hidden" name="action" value="position">
            <label class="block text-xs font-bold text-gray-500 mb-2 uppercase">Nový název pozice</label>
            <input type="text" name="new_position" class="w-full bg-gray-50 p-4 rounded-xl outline-none border border-gray-200 focus:border-brand-gold mb-6 font-bold" placeholder="např. Senior Developer" required>
            <div class="flex gap-3">
                <button type="button" onclick="closeModal('positionModal')" class="flex-1 bg-gray-100 text-gray-600 font-bold py-3 rounded-xl hover:bg-gray-200 transition">Zrušit</button>
                <button type="submit" class="flex-1 bg-gray-900 text-brand-gold font-bold py-3 rounded-xl hover:bg-black shadow-lg shadow-gray-900/20 transition">Vystavit dodatek</button>
            </div>
        </form>
    </div>
</div>

<div id="offboardModal" class="hidden fixed inset-0 bg-red-900/80 backdrop-blur-sm z-50 flex items-center justify-center p-4 transition-opacity">
    <div class="bg-white rounded-2xl w-full max-w-md overflow-hidden shadow-2xl transform transition-all border-t-4 border-red-500">
        <div class="p-6 border-b border-gray-100 bg-red-50 flex justify-between items-center">
            <h3 class="font-bold text-red-700 text-lg flex items-center gap-2"><i class="ri-alert-line text-red-500"></i> Zahájit Offboarding</h3>
            <button onclick="closeModal('offboardModal')" class="text-red-400 hover:text-red-700 text-2xl leading-none">&times;</button>
        </div>
        <form action="/hr/offboard/{{ c.token }}" method="POST" class="p-6">
            <p class="text-sm text-gray-600 mb-6">Tato akce nevratně přesune zaměstnance do stavu "Ukončeno" a vygeneruje příslušné právní dokumenty.</p>
            <label class="block text-xs font-bold text-gray-500 mb-2 uppercase">Způsob ukončení</label>
            <select name="term_type" class="w-full bg-gray-50 p-4 rounded-xl outline-none border border-red-200 focus:border-red-500 mb-6 font-bold text-gray-800">
                <option value="termination_agreement">Dohoda o rozvázání poměru</option>
                <option value="termination_notice">Jednostranná výpověď</option>
            </select>
            <div class="flex gap-3">
                <button type="button" onclick="closeModal('offboardModal')" class="flex-1 bg-gray-100 text-gray-600 font-bold py-3 rounded-xl hover:bg-gray-200 transition">Zrušit</button>
                <button type="submit" class="flex-1 bg-red-600 text-white font-bold py-3 rounded-xl hover:bg-red-700 shadow-lg shadow-red-600/30 transition">Ukončit poměr</button>
            </div>
        </form>
    </div>
</div>

<script>
    function openModal(id) {
        document.getElementById(id).classList.remove('hidden');
    }
    function closeModal(id) {
        document.getElementById(id).classList.add('hidden');
    }
</script>
{% endblock %}
HTMLEOF

echo "🚀 Restartuji server s novým profilem zaměstnance..."
pkill -f python || true
./start.sh
