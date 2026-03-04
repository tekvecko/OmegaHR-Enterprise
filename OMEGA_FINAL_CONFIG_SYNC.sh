#!/data/data/com.termux/files/usr/bin/bash
set -e

PROJ="/data/data/com.termux/files/home/OmegaPlatinum_PROD"
CONF="$PROJ/omega_config.json"

echo "🔄 Synchronizuji JSON schémata (Case-Sensitive Fix)..."

cat > "$CONF" << 'JSONEOF'
{
  "PROJECT_NAME": "Omega Platinum Enterprise",
  "VERSION": "7.1-PROD",
  "security": {
    "MASTER_KEY_HASH": "8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918",
    "MAX_LOGIN_ATTEMPTS": 5,
    "session_timeout_minutes": 60
  },
  "MOJEID": {
    "CLIENT_ID": "omega_client_prod",
    "CLIENT_SECRET": "secret_from_dam",
    "DISCOVERY_URL": "https://mojeid.cz/.well-known/openid-configuration"
  },
  "PATHS": {
    "CONTRACTS": "contracts/",
    "VAULT": "work_vault/",
    "FONTS": "fonts/System-Roboto.ttf"
  }
}
JSONEOF

echo "✅ Konfigurace synchronizována."
echo "🚀 Spouštím systém..."
cd $PROJ
python3 omega_core.py
