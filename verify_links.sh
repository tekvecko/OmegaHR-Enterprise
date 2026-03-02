#!/data/data/com.termux/files/usr/bin/bash
set -e

cd /data/data/com.termux/files/home/OmegaPlatinum_PROD

cat > link_checker.py << 'PYEOF'
#!/data/data/com.termux/files/usr/bin/python
import os
import re

print("🔍 Skener odkazů: Hledám všechny navigační cesty v UI...")

found_links = set()
try:
    for root, dirs, files in os.walk('templates'):
        for file in files:
            if file.endswith('.html'):
                path = os.path.join(root, file)
                try:
                    with open(path, 'r', encoding='utf-8') as f:
                        content = f.read()
                        # Hledáme všechny odkazy (href) a cíle formulářů (action), které začínají lomítkem
                        for match in re.findall(r'(?:href|action)=["\'](/[^"\']*)["\']', content):
                            found_links.add(match)
                except Exception as e:
                    print(f"Chyba čtení {file}: {e}")
except Exception as e:
    print(f"Chyba procházení: {e}")

print("\n🔗 Nalezené interní odkazy (kam směřují tvá tlačítka a formuláře):")
for link in sorted(found_links):
    print(f"  ➡️  {link}")

print("\n✅ Všechny vypsané cesty by měly odpovídat mapě tvého serveru.")
PYEOF

chmod +x link_checker.py
/data/data/com.termux/files/usr/bin/python link_checker.py
rm link_checker.py
