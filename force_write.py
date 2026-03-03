import re
path = "omega_core.py"
with open(path, 'r', encoding='utf-8') as f:
    code = f.read()

# Vynutíme, aby log_action i lifecycle používaly absolutní cesty Ubuntu
ubuntu_db = "/data/data/com.termux/files/home/OmegaPlatinum_PROD/db"
code = code.replace('db/audit_log.json', f'{ubuntu_db}/audit_log.json')

# Oprava logiky zápisu - přidáme explicitní zavírání souborů
write_fix = f"""
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=4, ensure_ascii=False)
        f.flush()
        os.fsync(f.fileno())
"""
# Nahradíme standardní json.dump touto bezpečnou verzí
code = re.sub(r"with open\(path, 'w'.*?json\.dump\(data, f, indent=4\)", f"with open(path, 'w', encoding='utf-8') as f:{write_fix}", code, flags=re.DOTALL)

with open(path, 'w', encoding='utf-8') as f:
    f.write(code)
