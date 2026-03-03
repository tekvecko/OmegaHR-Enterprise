import re
path = "omega_core.py"
with open(path, 'r', encoding='utf-8') as f:
    code = f.read()

# Pokud v souboru chybí import Flask, přidáme ho (pro jistotu)
if "from flask import" not in code:
    code = "from flask import Flask, request, session, redirect, url_for, render_template\n" + code

# Vynucení spuštění na portu 8080
run_cmd = "app.run(host='0.0.0.0', port=8080)"
if "app.run" in code:
    code = re.sub(r"app\.run\(.*?\)", run_cmd, code)
else:
    code += f"\nif __name__ == '__main__':\n    {run_cmd}"

with open(path, 'w', encoding='utf-8') as f:
    f.write(code)
