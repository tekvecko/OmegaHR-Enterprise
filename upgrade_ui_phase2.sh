#!/data/data/com.termux/files/usr/bin/bash
set -e

cd /data/data/com.termux/files/home/OmegaPlatinum_PROD

echo "🎨 Překlápím Nástěnku (dashboard.html) do Enterprise designu..."
cat > templates/dashboard.html << 'HTMLEOF'
{% extends "base.html" %}

{% block title %}Nástěnka - OmegaHR{% endblock %}
{% block header %}Přehled Zaměstnanců{% endblock %}

{% block content %}
<div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
    <div class="bg-white p-6 rounded-2xl shadow-sm border border-gray-100 flex items-center gap-5">
        <div class="w-14 h-14 bg-gray-900 text-brand-gold rounded-xl flex items-center justify-center text-2xl shadow-lg shadow-gray-900/20"><i class="ri-team-line"></i></div>
        <div>
            <p class="text-xs font-bold text-gray-500 uppercase tracking-wide">Celkem v evidenci</p>
            <h3 class="text-3xl font-black text-gray-800">{{ candidates|length }}</h3>
        </div>
    </div>
    <div class="bg-white p-6 rounded-2xl shadow-sm border border-gray-100 flex items-center gap-5">
        <div class="w-14 h-14 bg-green-50 text-green-500 rounded-xl flex items-center justify-center text-2xl"><i class="ri-user-follow-line"></i></div>
        <div>
            <p class="text-xs font-bold text-gray-500 uppercase tracking-wide">Aktivní zaměstnanci</p>
            <h3 class="text-3xl font-black text-gray-800">
                {{ candidates | selectattr('status', 'equalto', 'signed') | list | length }}
            </h3>
        </div>
    </div>
    <div class="bg-white p-6 rounded-2xl shadow-sm border border-gray-100 flex items-center gap-5">
        <div class="w-14 h-14 bg-yellow-50 text-yellow-600 rounded-xl flex items-center justify-center text-2xl"><i class="ri-file-edit-line"></i></div>
        <div>
            <p class="text-xs font-bold text-gray-500 uppercase tracking-wide">V řešení (Onboarding)</p>
            <h3 class="text-3xl font-black text-gray-800">
                {{ candidates | selectattr('status', 'equalto', 'pending') | list | length }}
            </h3>
        </div>
    </div>
</div>

<div class="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
    <div class="p-6 border-b border-gray-100 flex justify-between items-center bg-gray-50/50">
        <h2 class="text-lg font-bold text-gray-800">Adresář osob</h2>
        <a href="/new" class="bg-brand-gold text-gray-900 px-5 py-2.5 rounded-xl text-sm font-black hover:bg-yellow-500 transition shadow-lg shadow-yellow-500/30 flex items-center gap-2">
            <i class="ri-user-add-line"></i> Nový nástup
        </a>
    </div>
    <div class="overflow-x-auto">
        <table class="w-full text-left border-collapse">
            <thead>
                <tr class="bg-gray-50 text-xs text-gray-500 uppercase tracking-wider border-b border-gray-200">
                    <th class="p-5 font-bold">Zaměstnanec</th>
                    <th class="p-5 font-bold">Pozice / Oddělení</th>
                    <th class="p-5 font-bold">Stav</th>
                    <th class="p-5 font-bold text-right">Akce</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-100">
                {% for c in candidates %}
                <tr class="hover:bg-gray-50 transition group">
                    <td class="p-5">
                        <div class="flex items-center gap-4">
                            <div class="w-10 h-10 rounded-full bg-gray-100 flex items-center justify-center text-gray-500 font-black border border-gray-200">
                                {{ c.personal_data.name[0] if c.personal_data and c.personal_data.name else '?' }}
                            </div>
                            <div>
                                <p class="font-bold text-sm text-gray-900">{{ c.personal_data.name }} {{ c.personal_data.surname }}</p>
                                <p class="text-xs text-gray-500 font-mono mt-0.5">{{ c.personal_data.email }}</p>
                            </div>
                        </div>
                    </td>
                    <td class="p-5">
                        <p class="font-bold text-sm text-gray-700">{{ c.hr_data.position if c.hr_data else 'Nenastaveno' }}</p>
                        <p class="text-xs text-gray-500 mt-0.5">{{ c.hr_data.department if c.hr_data else 'Bez oddělení' }}</p>
                    </td>
                    <td class="p-5">
                        {% if c.offboarding_status == 'terminated' %}
                            <span class="inline-flex items-center gap-1.5 bg-red-50 text-red-600 border border-red-200 px-3 py-1 rounded-full text-xs font-bold shadow-sm">
                                <span class="w-1.5 h-1.5 rounded-full bg-red-500"></span> Ukončeno
                            </span>
                        {% elif c.status == 'active' or c.status == 'signed' %}
                            <span class="inline-flex items-center gap-1.5 bg-green-50 text-green-600 border border-green-200 px-3 py-1 rounded-full text-xs font-bold shadow-sm">
                                <span class="w-1.5 h-1.5 rounded-full bg-green-500"></span> Aktivní
                            </span>
                        {% else %}
                            <span class="inline-flex items-center gap-1.5 bg-yellow-50 text-yellow-600 border border-yellow-200 px-3 py-1 rounded-full text-xs font-bold shadow-sm">
                                <span class="w-1.5 h-1.5 rounded-full bg-yellow-500 animate-pulse"></span> Řeší se
                            </span>
                        {% endif %}
                    </td>
                    <td class="p-5 text-right">
                        <a href="/candidate/{{ c.token }}" class="text-gray-900 bg-gray-100 hover:bg-gray-200 hover:shadow-md px-4 py-2 rounded-lg text-sm font-bold transition inline-flex items-center gap-2">
                            Detail <i class="ri-arrow-right-s-line"></i>
                        </a>
                    </td>
                </tr>
                {% else %}
                <tr>
                    <td colspan="4" class="p-12 text-center text-gray-400">
                        <div class="text-5xl mb-4 text-gray-200"><i class="ri-inbox-2-line"></i></div>
                        <p class="font-bold text-gray-500 text-lg">Zatím tu nikoho nemáš.</p>
                        <p class="text-sm mt-1">Začni tím, že přidáš prvního zaměstnance pomocí tlačítka nahoře.</p>
                    </td>
                </tr>
                {% endfor %}
            </tbody>
        </table>
    </div>
</div>
{% endblock %}
HTMLEOF

echo "👥 Překlápím Správu Uživatelů (users.html) do Enterprise designu..."
cat > templates/users.html << 'HTMLEOF'
{% extends "base.html" %}

{% block title %}Správa Účtů - OmegaHR{% endblock %}
{% block header %}Uživatelé a Role{% endblock %}

{% block content %}
<div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
    
    <div class="lg:col-span-1">
        <div class="bg-white p-6 rounded-2xl shadow-sm border border-gray-100 sticky top-8">
            <div class="flex items-center gap-3 mb-6 pb-4 border-b border-gray-100">
                <div class="w-10 h-10 bg-gray-900 text-brand-gold rounded-xl flex items-center justify-center text-xl shadow-md"><i class="ri-user-add-line"></i></div>
                <div>
                    <h2 class="text-lg font-bold text-gray-800">Nový přístup</h2>
                    <p class="text-xs text-gray-500">Založení nového účtu</p>
                </div>
            </div>
            
            <form action="/admin/users" method="POST" class="space-y-5">
                <input type="hidden" name="action" value="add">
                <div>
                    <label class="block text-xs font-bold text-gray-500 mb-2 uppercase tracking-wide">Login (Jméno)</label>
                    <div class="relative">
                        <i class="ri-user-line absolute left-4 top-1/2 transform -translate-y-1/2 text-gray-400"></i>
                        <input type="text" name="username" required class="w-full bg-gray-50 pl-11 p-3.5 rounded-xl outline-none border border-gray-200 focus:border-gray-400 focus:bg-white transition text-sm font-bold text-gray-700">
                    </div>
                </div>
                <div>
                    <label class="block text-xs font-bold text-gray-500 mb-2 uppercase tracking-wide">Heslo</label>
                    <div class="relative">
                        <i class="ri-lock-line absolute left-4 top-1/2 transform -translate-y-1/2 text-gray-400"></i>
                        <input type="password" name="password" required class="w-full bg-gray-50 pl-11 p-3.5 rounded-xl outline-none border border-gray-200 focus:border-gray-400 focus:bg-white transition text-sm font-bold text-gray-700">
                    </div>
                </div>
                <div>
                    <label class="block text-xs font-bold text-gray-500 mb-2 uppercase tracking-wide">Oprávnění (Role)</label>
                    <select name="role" class="w-full bg-gray-50 p-3.5 rounded-xl outline-none border border-gray-200 focus:border-gray-400 focus:bg-white transition text-sm font-bold text-gray-700 appearance-none">
                        <option value="hr">HR Specialista (Jen zaměstnanci)</option>
                        <option value="admin">Administrátor (Plný přístup)</option>
                    </select>
                </div>
                <div class="pt-2">
                    <button type="submit" class="w-full bg-gray-900 text-white px-4 py-3.5 rounded-xl font-black hover:bg-black transition shadow-lg shadow-gray-900/20 flex items-center justify-center gap-2">
                        <i class="ri-add-line text-lg"></i> Vytvořit účet
                    </button>
                </div>
            </form>
        </div>
    </div>

    <div class="lg:col-span-2">
        <div class="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
            <div class="p-6 border-b border-gray-100 bg-gray-50/50 flex items-center justify-between">
                <h2 class="text-lg font-bold text-gray-800">Seznam aktivních účtů</h2>
                <span class="bg-blue-50 text-blue-600 px-3 py-1 rounded-full text-xs font-bold border border-blue-200">{{ users|length }} účtů</span>
            </div>
            <div class="p-6">
                <div class="grid grid-cols-1 gap-4">
                    {% for username, data in users.items() %}
                    <div class="flex items-center justify-between p-5 rounded-2xl border border-gray-100 hover:border-gray-300 hover:bg-gray-50/50 transition shadow-sm group">
                        <div class="flex items-center gap-5">
                            <div class="w-12 h-12 rounded-xl bg-white flex items-center justify-center text-gray-800 font-black border border-gray-200 text-lg shadow-sm">
                                {{ username[0]|upper }}
                            </div>
                            <div>
                                <p class="font-bold text-gray-900 text-base mb-0.5">{{ username }}</p>
                                {% if data.role == 'admin' %}
                                    <span class="text-[10px] font-black bg-red-100 text-red-600 px-2 py-0.5 rounded border border-red-200 uppercase tracking-widest">Admin</span>
                                {% else %}
                                    <span class="text-[10px] font-black bg-gray-200 text-gray-600 px-2 py-0.5 rounded border border-gray-300 uppercase tracking-widest">HR Spec</span>
                                {% endif %}
                            </div>
                        </div>
                        
                        {% if username != 'admin' %}
                        <form action="/admin/users" method="POST" onsubmit="return confirm('Opravdu nenávratně smazat účet {{ username }}?');">
                            <input type="hidden" name="action" value="delete">
                            <input type="hidden" name="username" value="{{ username }}">
                            <button type="submit" class="w-10 h-10 rounded-xl bg-white border border-gray-200 text-gray-400 hover:bg-red-50 hover:text-red-600 hover:border-red-200 flex items-center justify-center transition shadow-sm group-hover:opacity-100" title="Smazat uživatele">
                                <i class="ri-delete-bin-line text-lg"></i>
                            </button>
                        </form>
                        {% else %}
                        <div class="flex items-center gap-2">
                            <i class="ri-shield-star-line text-brand-gold text-xl" title="Hlavní administrátor"></i>
                        </div>
                        {% endif %}
                    </div>
                    {% endfor %}
                </div>
            </div>
        </div>
    </div>
    
</div>
{% endblock %}
HTMLEOF

echo "🚀 Aplikuji nový design..."
