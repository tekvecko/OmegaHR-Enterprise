#!/data/data/com.termux/files/usr/bin/bash
DATE=$(date +%Y-%m-%d_%H-%M)
mkdir -p backups
tar -czf backups/omega_backup_$DATE.tar.gz db/ settings.json
echo "📦 Záloha vytvořena: backups/omega_backup_$DATE.tar.gz"
