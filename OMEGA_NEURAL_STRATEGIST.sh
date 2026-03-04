#!/data/data/com.termux/files/usr/bin/bash
set -e

# 1. INSTALACE AI BALÍČKŮ
pkg install -y python-pip
pip install google-generativeai

PROJ="/data/data/com.termux/files/home/OmegaPlatinum_PROD"
CORE="$PROJ/omega_core.py"
TPL="$PROJ/templates"

echo "🧠 Implementuji spojení s modelem Gemini 3..."

# 2. AKTUALIZACE JÁDRA - AI LOGIKA
python3 << 'PYEOF'
import os
path = "/data/data/com.termux/files/home/OmegaPlatinum_PROD/omega_core.py"
with open(path, 'r') as f: content = f.read()

ai_logic = """
import google.generativeai as genai

@app.route('/admin/ai_strategy')
def ai_strategy():
    if not session.get('logged_in'): return redirect(url_for('login'))
    
    # Sběr dat pro kontext modelu
    employees = query_db("SELECT * FROM candidates")
    assets = query_db("SELECT * FROM assets")
    
    # Příprava kontextu pro nejsilnější model
    context = f"Data Impéria: {len(employees)} zaměstnanců, {len(assets)} aktivních zařízení."
    
    api_key = os.getenv("API_KEY")
    if not api_key:
        return "Chyba: API_KEY není nastavena. Proveďte 'export API_KEY=vaše_hodnota'"
    
    genai.configure(api_key=api_key)
    # Volání nejsilnějšího dostupného modelu v roce 2026
    model = genai.GenerativeModel('gemini-3-ultra')
    
    response = model.generate_content(f"Jsi strategický poradce systému Omega Platinum. Analyzuj tento stav a navrhni 3 kroky pro optimalizaci: {context}")
    
    return render_template('ai_strategy.html', report=response.text)
"""

if "import google.generativeai" not in content:
    content = "import google.generativeai as genai\n" + content
    content = content.replace("if __name__ == '__main__':", ai_logic + "\nif __name__ == '__main__':")
    with open(path, 'w') as f: f.write(content)
PYEOF

# 3. TVORBA STRATEGICKÉ ŠABLONY (Glassmorphism)
cat > "$TPL/ai_strategy.html" << 'HOF'
{% extends 'layout.html' %}
{% block content %}
<div class="page-anim">
    <h1><i class="fa-solid fa-brain"></i> Neural Strategist (Gemini 3)</h1>
    <div class="card" style="background: rgba(0, 210, 255, 0.05); border: 1px solid var(--accent);">
        <h2 style="color: var(--accent);"><i class="fa-solid fa-microchip"></i> Analýza Impéria v reálném čase</h2>
        <div style="line-height: 1.8; margin-top: 20px; font-size: 1.1rem;">
            {{ report | replace('\n', '<br>') | safe }}
        </div>
    </div>
    <div style="margin-top: 20px; text-align: center;">
        <button onclick="location.reload()" class="btn btn-p"><i class="fa-solid fa-sync"></i> RE-GENEROVAT STRATEGII</button>
    </div>
</div>
{% endblock %}
HOF

# 4. PŘIDÁNÍ DO SIDEBARU
sed -i '/<a href="\/audit"/a \                <a href="/admin/ai_strategy" class="nav-item"><i class="fa-solid fa-brain"></i> AI Strategie</a>' "$TPL/layout.html"

echo "🚀 Restartuji systém s neuronovou nadstavbou..."
pkill -f "omega_core.py" || true
nohup python3 "$CORE" > "$PROJ/dev_server.log" 2>&1 &
echo "💎 AI STRATEGIST AKTIVOVÁN. Nejsilnější model Gemini 3 je nyní připojen."
