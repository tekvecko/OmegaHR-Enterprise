#!/data/data/com.termux/files/usr/bin/bash
set -e

PROJ="/data/data/com.termux/files/home/OmegaPlatinum_PROD"
TPL="$PROJ/templates"

echo "🎨 Sjednocuji vnitřní moduly (Sklad, Finance, Audit, Identity)..."

# 1. SKLAD & LOGISTIKA (Assets)
cat > "$TPL/assets.html" << 'HOF'
{% extends "layout.html" %}
{% block content %}
<div class="glass-header">
    <h1><i class="fa-solid fa-boxes-stacked"></i> Logistické centrum</h1>
</div>

<div class="card">
    <h2 style="margin-top:0;">Přidat nové zařízení</h2>
    <form action="/api/assign_asset" method="POST" class="grid" style="grid-template-columns: 1fr 1fr auto; gap:10px; align-items:end;">
        <div>
            <label style="font-size:0.8rem; color:#666;">ID Zařízení</label>
            <input type="number" name="asset_id" placeholder="ID" required>
        </div>
        <div>
            <label style="font-size:0.8rem; color:#666;">Přiřadit tokenu</label>
            <input type="text" name="token" placeholder="T-XXX">
        </div>
        <button type="submit" class="btn btn-p">Provést změnu</button>
    </form>
</div>

<div class="card">
    <div class="table-container">
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Název Hardware</th>
                    <th>Status</th>
                    <th>Aktuální držitel</th>
                    <th>Akce</th>
                </tr>
            </thead>
            <tbody>
                {% for a in assets %}
                <tr>
                    <td><code>#{{ a.id }}</code></td>
                    <td><strong>{{ a.name }}</strong></td>
                    <td><span class="badge" style="background: {{ '#48bb78' if a.status == 'IN_STOCK' else '#4299e1' }}; color:white; padding:4px 10px; border-radius:10px; font-size:0.7rem;">{{ a.status }}</span></td>
                    <td>{{ a.owner_token or "CENTRÁLNÍ SKLAD" }}</td>
                    <td>
                        {% if a.owner_token %}
                        <a href="/api/unassign_asset/{{ a.id }}" class="btn" style="color:#f56565; padding:5px;"><i class="fa-solid fa-rotate-left"></i> Uvolnit</a>
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

# 2. FINANCE (Modul C)
cat > "$TPL/finance_admin.html" << 'HOF'
{% extends "layout.html" %}
{% block content %}
<div class="glass-header">
    <h1><i class="fa-solid fa-chart-pie"></i> Finanční Analytika</h1>
</div>

<div class="grid" style="margin-bottom:30px;">
    <div class="card" style="border-left: 5px solid #48bb78;">
        <p style="color:#666; margin:0;">Celkové měsíční náklady (Superhrubá)</p>
        <h2 style="font-size:1.8rem; margin:10px 0;">{{ total|round(2) }} CZK</h2>
    </div>
</div>

<div class="card">
    <div class="table-container">
        <table>
            <thead>
                <tr>
                    <th>Operátor</th>
                    <th>Brutto Mzda</th>
                    <th>Čistá (Netto)</th>
                    <th>Náklady firmy</th>
                </tr>
            </thead>
            <tbody>
                {% for s in stats %}
                <tr>
                    <td><strong>{{ s.name }}</strong></td>
                    <td>{{ s.brutto }} CZK</td>
                    <td style="color:#2f855a;">{{ s.netto|round(2) }} CZK</td>
                    <td style="font-weight:bold;">{{ s.cost|round(2) }} CZK</td>
                </tr>
                {% endfor %}
            </tbody>
        </table>
    </div>
</div>
{% endblock %}
HOF

# 3. MOJEID & IDENTITY (Audit Log & GDPR)
cat > "$TPL/admin_identities.html" << 'HOF'
{% extends "layout.html" %}
{% block content %}
<div class="glass-header">
    <h1><i class="fa-solid fa-shield-halved"></i> Identity & GDPR</h1>
</div>

<div class="grid">
    {% for u in users %}
    <div class="card">
        <div style="display:flex; justify-content:space-between; align-items:center;">
            <h3>{{ u.name }}</h3>
            <i class="fa-solid fa-circle-check" style="color: {{ '#48bb78' if u.is_verified else '#cbd5e0' }};"></i>
        </div>
        <p style="font-size:0.8rem; color:#666; margin-bottom:15px;">MojeID Sub: <code>{{ u.mojeid_sub or "Nepropojeno" }}</code></p>
        <div style="display:flex; gap:10px;">
            <a href="/my_data/{{ u.token }}" target="_blank" class="btn" style="background:#edf2f7; flex:1; justify-content:center;"><i class="fa-solid fa-eye"></i> GDPR</a>
            <a href="/admin/reset_identity/{{ u.token }}" class="btn" style="background:#fff5f5; color:#c53030; flex:1; justify-content:center;"><i class="fa-solid fa-trash-can"></i> Reset</a>
        </div>
    </div>
    {% endfor %}
</div>
{% endblock %}
HOF

echo "🚀 Restartuji sjednocené moduly..."
pkill -f "omega_core.py" || true
nohup python3 "$PROJ/omega_core.py" > "$PROJ/dev_server.log" 2>&1 &
echo "💎 VŠECHNY STRÁNKY SJEDNOCENY."
