#!/data/data/com.termux/files/usr/bin/bash
set -e

cd /data/data/com.termux/files/home/OmegaPlatinum_PROD

cat > find_404.py << 'PYEOF'
#!/data/data/com.termux/files/usr/bin/python
import os
import re

print("🔍 Spouštím hloubkový skener mrtvých odkazů...")

try:
    from omega_core import app
except Exception as e:
    print(f"❌ Nelze načíst aplikaci pro testování: {e}")
    exit(1)

app.config['TESTING'] = True
client = app.test_client()

found_links = set()

# Procházení šablon a hledání všech odkazů
for root, dirs, files in os.walk('templates'):
    for file in files:
        if file.endswith('.html'):
            path = os.path.join(root, file)
            try:
                with open(path, 'r', encoding='utf-8') as f:
                    content = f.read()
                    # Najde všechny href="/neco" nebo action="/neco"
                    for match in re.findall(r'(?:href|action)=["\'](/[^"\']*)["\']', content):
                        found_links.add((match, path))
            except Exception as e:
                print(f"Chyba při čtení {path}: {e}")

print(f"Nalezeno {len(found_links)} interních odkazů. Testuji dostupnost na serveru...\n")

dead_links = []

for original_link, source_file in sorted(found_links):
    # Nahradíme Jinja tagy {{ c.token }} nebo {% url_for %} testovacím stringem, 
    # aby Flask router nevyhazoval chybu na formát URL.
    test_url = re.sub(r'\{\{.*?\}\}', 'TEST_TOKEN', original_link)
    test_url = re.sub(r'\{%.*?%\}', 'TEST_TOKEN', test_url)
    
    # Simulace požadavku (GET i POST pro jistotu)
    response_get = client.get(test_url)
    response_post = client.post(test_url)
    
    # Pokud obě metody vrací 404, adresa s jistotou neexistuje
    if response_get.status_code == 404 and response_post.status_code == 404:
        dead_links.append((original_link, source_file))

if dead_links:
    print("❌ NALEZENY NEFUNKČNÍ ODKAZY (Vrací 404):")
    print("-" * 50)
    for link, source in dead_links:
        print(f"Mrtvý odkaz: {link}")
        print(f"Nachází se v: {source}")
        print("-" * 50)
    print("Tyto odkazy je potřeba v uvedených šablonách opravit (např. chybějící '/' nebo špatný název routy).")
else:
    print("✅ Skvělá zpráva! Všechny interní odkazy vedou na existující trasy. Žádná chyba 404 nebyla nalezena.")

PYEOF

chmod +x find_404.py
/data/data/com.termux/files/usr/bin/python find_404.py
rm find_404.py
