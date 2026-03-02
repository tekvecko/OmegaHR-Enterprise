#!/data/data/com.termux/files/usr/bin/bash
set -e
echo "Starting OmegaHR Enterprise..."
pkill -f python || true
python omega_core.py
