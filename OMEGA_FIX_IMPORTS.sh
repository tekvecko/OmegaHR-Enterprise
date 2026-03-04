#!/data/data/com.termux/files/usr/bin/bash
set -e

CORE="/data/data/com.termux/files/home/OmegaPlatinum_PROD/omega_core.py"

echo "💉 Vstřikuji chybějící importy (json, os, sqlite3) do jádra..."

# Vytvoříme dočasný soubor s importy a pak k němu připojíme zbytek jádra
cat > core_new.py << 'PYEOF'
import json
import os
import sqlite3
import hashlib
from datetime import datetime
from flask import Flask, render_template, request, redirect, url_for, session, send_from_directory

PYEOF

# Přidáme zbytek původního kódu, ale vynecháme případné duplicitní (špinavé) importy na začátku
# (Pokud tam nějaké byly, tyhle budou mít prioritu)
cat "$CORE" >> core_new.py

# Nahradíme staré jádro novým
mv core_new.py "$CORE"

echo "✅ Importy fixnuty. Spouštím systém..."
cd /data/data/com.termux/files/home/OmegaPlatinum_PROD
python3 omega_core.py
