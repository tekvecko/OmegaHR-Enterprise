#!/data/data/com.termux/files/usr/bin/bash
set -e

PROJ="/data/data/com.termux/files/home/OmegaPlatinum_PROD"
TPL="$PROJ/templates"

echo "💎 Zahajuji finální harmonizaci všech modulů..."

# --- 1. DASHBOARD (index.html) ---
cat > "$TPL/index.html" << 'HOF'
{% extends 'layout.html' %}
{% block content %}
<div class="page-anim">
    <h1><i class="fa-solid fa-gauge-high"></i> Command Center</h1>
    <div class="grid">
        <div class="card">
            <h3><i class="fa-solid fa-users"></i> Operátoři</h3>
            <p style="font-size: 2.5rem; font-weight: 800;">{{ employees|length }}</p>
            <p>Aktivní subjekty v systému.</p>
        </div>
        <div class="card">
            <h3><i class="fa-solid fa-coins"></i> Náklady</h3>
            {% set total = namespace(v=0) %}{% for e in employees %}{% set total.v = total.v + (e.salary_base|int or 0) %}{% endfor %}
            <p style="font-size: 2.5rem; font-weight: 800; color: var(--accent);">{{ total.v }} CZK</p>
            <p>Měsíční brutto budget.</p>
        </div>
        <div class="card">
            <h3><i class="fa-solid fa-microchip"></i> Hardware</h3>
            <p style="font-size: 2.5rem; font-weight: 800;">{{ assets|length }}</p>
            <p>Položek v evidenci logistiky.</p>
        </div>
    </div>
</div>
{% endblock %}
HOF

# --- 2. HR AGENDA (agenda.html) ---
cat > "$TPL/agenda.html" << 'HOF'
{% extends 'layout.html' %}
{% block content %}
<h1><i class="fa-solid fa-user-plus"></i> HR Agenda</h1>
<div class="grid">
    {% for e in employees %}
    <div class="card">
        <div style="display:flex; justify-content:space-between;">
            <h3>{{ e.name }}</h3>
            <span class="badge" style="background:rgba(0,210,255,0.2); color:white; padding:5px 10px; border-radius:10px;">{{ e.token }}</span>
        </div>
        <hr style="margin:15px 0; border:0; border-top:1px solid rgba(255,255,255,0.1);">
        <form action="/api/update_agenda/{{ e.token }}" method="POST">
            <label style="font-size:0.7rem;">TYP SMLOUVY</label>
            <select name="contract_type" style="background:rgba(255,255,255,0.1); color:white; border:1px solid var(--glass-border); padding:8px; width:100%; border-radius:10px; margin-bottom:10px;">
                <option value="HPP" {% if e.contract_type == 'HPP' %}selected{% endif %}>HPP (Zaměstnanec)</option>
                <option value="ICO" {% if e.contract_type == 'ICO' %}selected{% endif %}>IČO (Kontraktor)</option>
            </select>
            <label style="font-size:0.7rem;">DATUM NÁSTUPU</label>
            <input type="date" name="start_date" value="{{ e.start_date }}" style="background:rgba(255,255,255,0.1); color:white; border:1px solid var(--glass-border); padding:8px; width:100%; border-radius:10px; margin-bottom:15px;">
            <button type="submit" class="btn" style="width:100%;">AKTUALIZOVAT</button>
        </form>
    </div>
    {% endfor %}
</div>
{% endblock %}
HOF

# --- 3. SKLAD (assets.html) ---
cat > "$TPL/assets.html" << 'HOF'
{% extends 'layout.html' %}
{% block content %}
<h1><i class="fa-solid fa-boxes-stacked"></i> Logistika</h1>
<div class="card">
    <div class="table-wrapper">
        <table>
            <thead>
                <tr><th>ID</th><th>ZAŘÍZENÍ</th><th>STATUS</th><th>DRŽITEL</th><th>AKCE</th></tr>
            </thead>
            <tbody>
                {% for a in assets %}
                <tr>
                    <td><code>#{{ a.id }}</code></td>
                    <td><strong>{{ a.name }}</strong></td>
                    <td>{{ a.status }}</td>
                    <td>{{ a.owner_token or "SKLADEM" }}</td>
                    <td>
                        {% if a.owner_token %}
                        <a href="/api/unassign_asset/{{ a.id }}" style="color:#ff8a8a; text-decoration:none;"><i class="fa-solid fa-arrow-rotate-left"></i> Uvolnit</a>
                        {% endif %}
                    </td>
                </tr>
                {% endfor %}
            </tbody>
        </table>
    </div>
</div>
{% endblock %}
HOF

# --- 4. FINANCE (finance_admin.html) ---
cat > "$TPL/finance_admin.html" << 'HOF'
{% extends 'layout.html' %}
{% block content %}
<h1><i class="fa-solid fa-coins"></i> Finanční Analytika</h1>
<div class="card">
    <div class="table-wrapper">
        <table>
            <thead>
                <tr><th>OPERÁTOR</th><th>BRUTTO</th><th>NETTO (EST.)</th><th>COSTS</th></tr>
            </thead>
            <tbody>
                {% for s in stats %}
                <tr>
                    <td><strong>{{ s.name }}</strong></td>
                    <td>{{ s.brutto }} CZK</td>
                    <td style="color:#00d2ff;">{{ s.netto|round(2) }} CZK</td>
                    <td style="font-weight:bold;">{{ s.cost|round(2) }} CZK</td>
                </tr>
                {% endfor %}
            </tbody>
        </table>
    </div>
    <div style="text-align:right; margin-top:20px; font-size:1.5rem; font-weight:900;">
        CELKEM: {{ total|round(2) }} CZK
    </div>
</div>
{% endblock %}
HOF

# --- 5. AUDIT (audit.html) ---
cat > "$TPL/audit.html" << 'HOF'
{% extends 'layout.html' %}
{% block content %}
<h1><i class="fa-solid fa-fingerprint"></i> Audit Trail</h1>
<div class="card" style="background: rgba(15,23,42,0.9); color:#00d2ff; font-family:monospace; font-size:0.85rem;">
    <div style="max-height:600px; overflow-y:auto; padding:10px;">
        {% for log in logs %}
        <div style="margin-bottom:8px; border-bottom:1px solid rgba(255,255,255,0.05); padding-bottom:4px;">
            <span style="color:#64748b;">[{{ log.timestamp }}]</span> 
            <span style="color:#fff;">{{ log.user }}</span> 
            <i class="fa-solid fa-caret-right" style="font-size:0.6rem; margin:0 5px;"></i> 
            <span style="color:var(--accent);">{{ log.action }}</span>: {{ log.details }}
        </div>
        {% endfor %}
    </div>
</div>
{% endblock %}
HOF

# --- 6. GDPR & IDENTITIES (admin_identities.html) ---
cat > "$TPL/admin_identities.html" << 'HOF'
{% extends 'layout.html' %}
{% block content %}
<h1><i class="fa-solid fa-shield-halved"></i> MojeID & GDPR</h1>
<div class="grid">
    {% for u in users %}
    <div class="card">
        <h3>{{ u.name }}</h3>
        <p style="font-size:0.8rem; opacity:0.7;">TOKEN: {{ u.token }}</p>
        <p style="margin:10px 0;">Status: <strong>{{ "VERIFIED" if u.is_verified else "UNVERIFIED" }}</strong></p>
        <div style="display:flex; gap:10px;">
            <a href="/my_data/{{ u.token }}" class="btn" style="flex:1; background:rgba(255,255,255,0.1); font-size:0.7rem;">EXPORT GDPR</a>
            <a href="/admin/reset_identity/{{ u.token }}" class="btn" style="flex:1; background:#ff4d4d; font-size:0.7rem;">RESET</a>
        </div>
    </div>
    {% endfor %}
</div>
{% endblock %}
HOF

echo "🧹 Čistím redundantní a staré soubory..."
rm -f "$TPL/base.html" "$TPL/users.html" "$TPL/analytics.html" "$TPL/candidate.html"

echo "🚀 Restartuji sjednocené impérium..."
pkill -f "omega_core.py" || true
nohup python3 "$PROJ/omega_core.py" > "$PROJ/dev_server.log" 2>&1 &

echo "--------------------------------------------------"
echo "💎 HARMONIZACE DOKONČENA."
echo "Všechny páteřní moduly jsou nyní 100% skleněné a unifikované."
echo "Zkuste nyní: http://127.0.0.1:8080"
echo "--------------------------------------------------"
