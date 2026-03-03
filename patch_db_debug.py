import re

with open('omega_core.py', 'r', encoding='utf-8') as f:
    code = f.read()

# Najdeme kód, který ukládá kandidáta a přidáme tam print cesty
debug_write = """
    import os
    abs_db = os.path.abspath('db')
    print(f"DEBUG: Zapisuji do DB -> {abs_db}/{token}.json")
    with open(f'db/{token}.json', 'w', encoding='utf-8') as f:
"""
# Nahradíme standardní open pro zápis kandidáta
code = re.sub(r"with open\(f'db/\{token\}\.json', 'w', encoding='utf-8'\) as f:", debug_write, code)

with open('omega_core.py', 'w', encoding='utf-8') as f:
    f.write(code)
print("✅ Debug logování zápisu aktivováno.")
