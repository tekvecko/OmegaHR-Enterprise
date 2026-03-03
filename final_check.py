import os
path = "omega_core.py"
with open(path, 'r') as f:
    code = f.read()
# Ujistíme se, že session nepotřebuje tajný klíč pro tento test
if "app.secret_key" not in code:
    code = "from flask import Flask, request, session, redirect, url_for, render_template\napp = Flask(__name__)\napp.secret_key='test'\n" + code
with open(path, 'w') as f:
    f.write(code)
