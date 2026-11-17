#!/bin/bash

# VAPT Automation - Daily Startup Script
# Run this once per session to bring everything online.

# --- Fix X11 display access for browser automation (needed since HexStrike runs as root) ---
cp /home/kali/.Xauthority /root/.Xauthority 2>/dev/null
chown root:root /root/.Xauthority 2>/dev/null
export XAUTHORITY=/root/.Xauthority
export DISPLAY=:0.0
xhost +si:localuser:root 2>/dev/null

# --- Start Ollama ---
sudo systemctl start ollama
echo "Ollama started. Checking..."
sleep 2
curl -m 5 http://localhost:11434/api/tags && echo "Ollama OK"

# --- Start HexStrike server in its own terminal window ---
echo "Starting HexStrike server in new terminal..."
qterminal -e bash -c "export XAUTHORITY=/root/.Xauthority; export DISPLAY=:0.0; cd ./hexstrike-ai && source hexstrike-env/bin/activate && python3 hexstrike_server.py --port 8888; exec bash" &

sleep 3
curl -m 5 http://localhost:8888/health && echo "HexStrike OK"

# --- Choose mode ---
echo ""
echo "=== Which mode are you running today? ==="
echo "1) Client pentest  (agent: pentest-client)"
echo "2) Bug bounty      (agent: bugbounty — paste the program's policy text directly in chat)"
read -p "Choice [1/2]: " mode

if [ "$mode" = "2" ]; then
    echo "Launching opencode — tab to 'bugbounty' agent, then paste the program's scope policy text."
else
    nano scope/pentest-engagement.md
    echo "Launching opencode — tab to 'pentest-client' agent."
fi

echo ""
echo "Launching opencode..."
opencode
