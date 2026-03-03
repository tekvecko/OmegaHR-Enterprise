#!/data/data/com.termux/files/usr/bin/bash
set -e

PROJECT_DIR="/data/data/com.termux/files/home/OmegaPlatinum_PROD"
cd $PROJECT_DIR/templates

echo "🧹 Odstraňuji nepotřebné (osiřelé) šablony..."

# Seznam souborů k odstranění (podle výsledků auditu)
GARBAGE=(
    "dashboard.html"
    "candidate_detail.html"
    "employee_dashboard.html"
    "review_data.html"
    "reports.html"
    "docs.html"
    "settings.html"
    "users.html"
    "employee.html"
    "audit.html"
)

mkdir -p ../archive/templates_backup
for f in "${GARBAGE[@]}"; do
    if [ -f "$f" ]; then
        mv "$f" ../archive/templates_backup/
        echo "  [MOV] $f -> archive/"
    fi
done

echo "✅ Čištění dokončeno. Systém je nyní 'Lean & Mean'."
echo "🚀 Spouštím finální ověřovací Audit..."
cd ..
./OMEGA_INTEGRITY_AUDITOR.sh
