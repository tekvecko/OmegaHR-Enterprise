import re
path = "omega_core.py"
with open(path, 'r', encoding='utf-8') as f:
    code = f.read()

# Vložíme zápis debug souboru hned na začátek funkce hr_lifecycle
debug_trigger = """
@app.route('/hr/lifecycle/<token>', methods=['POST'])
def hr_lifecycle(token):
    with open('DEBUG_HIT.txt', 'a') as f:
        f.write(f"Hit for {token} with data {request.form}\\n")
"""
code = re.sub(r"@app\.route\('/hr/lifecycle/.*?def hr_lifecycle\(token\):", debug_trigger, code, flags=re.DOTALL)

with open(path, 'w', encoding='utf-8') as f:
    f.write(code)
