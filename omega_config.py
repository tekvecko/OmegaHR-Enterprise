#!/data/data/com.termux/files/usr/bin/python
import os

SECRET_KEY = os.environ.get('OMEGA_SECRET', 'omega_production_secret_key_v7')
BASE_DIR = "/data/data/com.termux/files/home/OmegaPlatinum_PROD"
DB_PATH = os.path.join(BASE_DIR, "omega.db")
CONTRACTS_DIR = BASE_DIR
BASE_URL = os.environ.get('BASE_URL', "http://localhost:8080")

MOJEID_CLIENT_ID = os.environ.get("MOJEID_CLIENT_ID", "production_client_id_placeholder")
MOJEID_CLIENT_SECRET = os.environ.get("MOJEID_CLIENT_SECRET", "production_secret_placeholder")
MOJEID_METADATA_URL = "https://mojeid.cz/.well-known/openid-configuration"

BANKID_CLIENT_ID = os.environ.get("BANKID_CLIENT_ID", "demo")
BANKID_CLIENT_SECRET = os.environ.get("BANKID_CLIENT_SECRET", "demo")
BANKID_METADATA_URL = "https://oidc.sandbox.bankid.cz/.well-known/openid-configuration"
