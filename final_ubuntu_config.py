import re
path = "omega_core.py"
with open(path, 'r', encoding='utf-8') as f:
    code = f.read()

# Najdeme volání app.run a přepíšeme ho na port 8080
if "app.run" in code:
    code = re.sub(r"app\.run\(.*?\)", "app.run(host='127.0.0.1', port=8080)", code)
else:
    code += "\nif __name__ == '__main__':\n    app.run(host='127.0.0.1', port=8080)"

with open(path, 'w', encoding='utf-8') as f:
    f.write(code)
