#!/data/data/com.termux/files/usr/bin/bash
set -e

cd /data/data/com.termux/files/home/OmegaPlatinum_PROD

cat > patch_routes.py << 'PYEOF'
#!/data/data/com.termux/files/usr/bin/python
import re

print("🛡️ Přidávám ochranu proti smazaným a neexistujícím odkazům...")

with open('omega_core.py', 'r', encoding='utf-8') as f:
    core = f.read()

# Ošetření pádu v zaměstnaneckém portálu (/employee/<token>)
core = re.sub(
    r"([ \t]*)if c\['offboarding_status'\] == 'terminated':",
    r"\1if not c: return 'Záznam nenalezen nebo byl smazán.', 404\n\1if c.get('offboarding_status') == 'terminated':",
    core
)

# Obecné ošetření pro případné další routy
core = re.sub(
    r"([ \t]*)if c\['status'\]",
    r"\1if not c: return 'Záznam nenalezen nebo byl smazán.', 404\n\1if c.get('status')",
    core
)

with open('omega_core.py', 'w', encoding='utf-8') as f:
    f.write(core)
print("✅ Aplikace nyní bezpečně ustojí kliknutí na neplatný token.")
PYEOF

chmod +x patch_routes.py
/data/data/com.termux/files/usr/bin/python patch_routes.py
rm patch_routes.py

echo "🚀 Restartuji odolnější server..."
pkill -f python || true
./start.sh
