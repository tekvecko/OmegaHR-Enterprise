import os
path = "omega_core.py"
with open(path, 'r', encoding='utf-8') as f:
    code = f.read()

# Oprava cest pro Ubuntu environment
base = "/data/data/com.termux/files/home/OmegaPlatinum_PROD/db"
code = code.replace("db/", f"{base}/")

with open(path, 'w', encoding='utf-8') as f:
    f.write(code)
