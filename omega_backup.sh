#!/data/data/com.termux/files/usr/bin/bash
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
cp /data/data/com.termux/files/home/OmegaPlatinum_PROD/omega_database.db /data/data/com.termux/files/home/OmegaPlatinum_PROD/backups/backup_$TIMESTAMP.db
echo "[$(date)] Backup completed: backup_$TIMESTAMP.db" >> /data/data/com.termux/files/home/OmegaPlatinum_PROD/backups/log.txt
# Udržovat pouze posledních 10 záloh
ls -t /data/data/com.termux/files/home/OmegaPlatinum_PROD/backups/backup_*.db | tail -n +11 | xargs rm -f -- 2>/dev/null || true
