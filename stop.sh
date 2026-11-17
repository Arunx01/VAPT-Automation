#!/bin/bash

# VAPT Automation - Daily Shutdown Script

echo "Stopping HexStrike server..."
pkill -f hexstrike_server.py
sleep 1

echo "Stopping Ollama..."
sudo systemctl stop ollama

echo "Checking for leftover processes..."
pgrep -af "hexstrike_server.py|ollama" && echo "^ still running, check manually" || echo "All clear."
