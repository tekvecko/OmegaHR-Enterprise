#!/data/data/com.termux/files/usr/bin/bash
set -e

PROJ="/data/data/com.termux/files/home/OmegaPlatinum_PROD"
DB="$PROJ/omega_database.db"

# Generování náhodného tokenu pro test
TEST_TOKEN=$(python3 -c "import uuid; print(str(uuid.uuid4())[:8])")
TEST_NAME="Testovací Kandidát"

echo "🛰️ Generuji Onboarding Link pro novou éru..."

python3 << PYEOF
import sqlite3
db_path = "$DB"
conn = sqlite3.connect(db_path)
c = conn.cursor()
c.execute("INSERT INTO candidates (token, name, status, is_verified) VALUES (?, ?, 'new', 0)", ("$TEST_TOKEN", "$TEST_NAME"))
conn.commit()
conn.close()
PYEOF

echo "--------------------------------------------------"
echo -e "💎 TESTOVACÍ ODKAZ VYGENEROVÁN:"
echo -e "\033[0;32mhttp://127.0.0.1:8080/welcome/$TEST_TOKEN\033[0m"
echo "--------------------------------------------------"
echo "Tento odkaz zkopíruj do prohlížeče ve svém mobilu/PC."
echo "Uvidíš nový světlý Welcome Portal a možnost simulace registrace."
echo "--------------------------------------------------"
