#!/data/data/com.termux/files/usr/bin/bash
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_PATH="/data/data/com.termux/files/home/storage/downloads/OMEGA_BACKUPS"
PROJECT_DIR="/data/data/com.termux/files/home/OmegaPlatinum_PROD"

echo "📦 Vytvářím snapshot systému OMEGA..."
tar -czf $BACKUP_PATH/OMEGA_SNAP_$TIMESTAMP.tar.gz -C $PROJECT_DIR omega_database.db contracts/ static/qr/
echo "✅ Snapshot uložen: OMEGA_SNAP_$TIMESTAMP.tar.gz"
