#!/data/data/com.termux/files/usr/bin/bash
set -e

cd /data/data/com.termux/files/home/OmegaPlatinum_PROD

echo "🧹 Cleaning up temporary template text files..."
rm -f salary_template.txt amendment_template.txt termination_agreement_template.txt termination_notice_template.txt

echo "📦 Committing Faze 3 & 4 to GitHub..."
git add .
git commit -m "feat: complete employee lifecycle, offboarding, RBAC and settings panel" || echo "No changes to commit."
git push origin main || echo "Push skipped or failed, check your network/token."

echo "✅ All data secured. Have a good night!"
