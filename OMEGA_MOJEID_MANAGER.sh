#!/data/data/com.termux/files/usr/bin/bash
set -e

PROJ="/data/data/com.termux/files/home/OmegaPlatinum_PROD"
CORE="$PROJ/omega_core.py"

echo "🔐 Implementuji GDPR MojeID Management modul..."

# 1. ROZŠÍŘENÍ BACKENDU O SPRÁVU IDENTIT
python3 << 'PYEOF'
import os
path = "/data/data/com.termux/files/home/OmegaPlatinum_PROD/omega_core.py"
with open(path, 'r') as f: content = f.read()

mojeid_admin_logic = """
@app.route('/admin/identities')
def manage_identities():
    if not session.get('logged_in') or session.get('role') != 'SUPERADMIN':
        return redirect(url_for('login'))
    users = query_db("SELECT token, name, full_name_mojeid, is_verified, mojeid_sub FROM candidates")
    return render_template('admin_identities.html', users=users)

@app.route('/admin/reset_identity/<token>')
def reset_identity(token):
    if not session.get('logged_in') or session.get('role') != 'SUPERADMIN':
        return redirect(url_for('login'))
    
    # GDPR PURGE: Smazání citlivých dat a unikátního MojeID klíče
    query_db(\"\"\"
        UPDATE candidates 
        SET is_verified = 0, 
            mojeid_sub = NULL, 
            full_name_mojeid = NULL, 
            address_mojeid = NULL, 
            birthdate_mojeid = NULL,
            onboarding_status = 'RE-VERIFICATION_REQUIRED'
        WHERE token = ?
    \"\"\", (token,))
    
    log_action(session.get('user'), "GDPR_PURGE", f"Identity linkage removed for {token}. Sensitive data erased.")
    return redirect(url_for('manage_identities'))
"""

if "@app.route('/admin/identities')" not in content:
    content = content.replace("if __name__ == '__main__':", mojeid_admin_logic + "\nif __name__ == '__main__':")
    with open(path, 'w') as f: f.write(content)
PYEOF

# 2. TVORBA ŠABLONY PRO SPRÁVU IDENTIT (Enterprise Ivory Style)
cat > "$PROJ/templates/admin_identities.html" << 'HOF'
<!DOCTYPE html>
<html lang="cs">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Omega | Identity Management</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root { --p: #0062cc; --bg: #f8f9fa; --txt: #2c3e50; --b: #dee2e6; --danger: #dc3545; }
        body { font-family: 'Inter', sans-serif; background: var(--bg); color: var(--txt); margin: 0; padding: 20px; }
        .nav { background: #fff; border-bottom: 2px solid var(--p); padding: 15px 20px; display: flex; justify-content: space-between; margin: -20px -20px 20px -20px; }
        .card { background: #fff; border: 1px solid var(--b); border-radius: 12px; padding: 20px; box-shadow: 0 4px 6px rgba(0,0,0,0.03); }
        .btn { padding: 8px 15px; border-radius: 6px; text-decoration: none; border: 1px solid var(--b); font-size: 0.85rem; cursor: pointer; display: inline-flex; align-items: center; gap: 5px; }
        .btn-danger { color: var(--danger); border-color: #f5c6cb; background: #f8d7da; }
        .status-badge { padding: 4px 10px; border-radius: 20px; font-size: 0.75rem; font-weight: bold; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { padding: 15px; text-align: left; border-bottom: 1px solid var(--b); }
        .gdpr-note { font-size: 0.8rem; color: #6c757d; margin-top: 15px; font-style: italic; }
    </style>
</head>
<body>
    <div class="nav">
        <div style="font-weight:900; color:var(--p);">OMEGA | IDENTITY ADMIN</div>
        <a href="/" class="btn">Zpět</a>
    </div>
    <div class="card">
        <h2><i class="fa-solid fa-id-card-clip"></i> Správa propojení MojeID</h2>
        <p>Zde můžete spravovat vazby mezi interními účty a digitální identitou. Smazání vazby vynutí nové přihlášení kandidáta.</p>
        
        <table>
            <thead>
                <tr>
                    <th>Zaměstnanec</th>
                    <th>Status MojeID</th>
                    <th>Identifikátor (SUB)</th>
                    <th>Akce</th>
                </tr>
            </thead>
            <tbody>
                {% for u in users %}
                <tr>
                    <td><strong>{{ u.name }}</strong><br><small>{{ u.token }}</small></td>
                    <td>
                        {% if u.is_verified %}
                        <span class="status-badge" style="background: #d4edda; color: #155724;">OVĚŘENO</span>
                        {% else %}
                        <span class="status-badge" style="background: #fff3cd; color: #856404;">NEOVĚŘENO</span>
                        {% endif %}
                    </td>
                    <td><code>{{ u.mojeid_sub or 'Není propojeno' }}</code></td>
                    <td>
                        {% if u.mojeid_sub %}
                        <a href="/admin/reset_identity/{{ u.token }}" class="btn btn-danger" onclick="return confirm('GDPR VAROVÁNÍ: Tato akce nenávratně smaže vazbu na MojeID a citlivé údaje. Zaměstnanec se bude muset znovu ověřit. Pokračovat?')">
                            <i class="fa-solid fa-eraser"></i> Zapomenout identitu
                        </a>
                        {% endif %}
                    </td>
                </tr>
                {% endfor %}
            </tbody>
        </table>
        <div class="gdpr-note">V souladu s GDPR (článek 17) tato funkce zajišťuje právo na výmaz citlivých identifikačních údajů z externích zdrojů.</div>
    </div>
</body>
</html>
HOF

echo "🚀 Restartuji systém s Identity Managerem..."
pkill -f "omega_core.py" || true
nohup python3 "$CORE" > "$PROJ/dev_server.log" 2>&1 &

echo "--------------------------------------------------"
echo "💎 MODUL MOJEID MANAGEMENT AKTIVOVÁN."
echo "URL pro správu: http://127.0.0.1:8080/admin/identities"
echo "--------------------------------------------------"
