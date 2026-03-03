#!/data/data/com.termux/files/usr/bin/bash
if ! pgrep -f "omega_core.py" > /dev/null; then
    echo "⚠️ Omega Core neběží! Restartuji..."
    cd /data/data/com.termux/files/home/OmegaPlatinum_PROD && python3 omega_core.py > /dev/null 2>&1 &
fi
