#!/data/data/com.termux/files/usr/bin/bash
set -e

# Inicializace, pokud to ještě není git repozitář
if [ ! -d ".git" ]; then
    echo "⚙️ Inicializuji nový Git repozitář..."
    git init
    git config user.name "OmegaHR System"
    git config user.email "omega@localhost"
fi

# Kontrola vzdáleného repozitáře (origin)
if ! git remote | grep -q "^origin$"; then
    if [ -z "$REPO_URL" ]; then
        echo "❌ Error: REPO_URL chybí."
        exit 1
    fi
    git remote add origin "$REPO_URL"
    echo "🔗 Propojeno s: $REPO_URL"
fi

echo "📦 Připravuji soubory..."
git add .

# Zkontrolujeme, jestli jsou vůbec nějaké změny k uložení
if ! git diff-index --quiet HEAD -- 2>/dev/null; then
    git commit -m "Automated state backup: $(date +'%Y-%m-%d %H:%M:%S')"
    echo "🚀 Odesílám na GitHub..."
    git branch -M main
    git push -u origin main
    echo "✅ Záloha úspěšně nahrána!"
else
    echo "✅ Pracovní adresář je čistý, žádné nové změny k odeslání."
fi
