# Installation Guide

## Before you start

This guide assumes a fresh Kali Linux machine (VM or bare metal). If you're not on Kali, stop here — this hasn't been tested elsewhere.

## Step 1 — Update your system

    sudo apt update && sudo apt upgrade -y
    sudo apt install -y curl unzip git build-essential python3 python3-venv python3-pip

## Step 2 — Run the installer

    chmod +x install.sh
    ./install.sh

This script will:
1. Confirm you're on Kali Linux (warns and asks for confirmation if not)
2. Check your available RAM and CPU cores
3. Recommend a local AI model size based on your hardware — you choose/confirm, nothing is forced
4. Install opencode
5. Install Ollama and pull your chosen model
6. Clone and set up HexStrike AI (in its own Python virtual environment)
7. Check for and help install the underlying security tools (nmap, sqlmap, ffuf, etc.)
8. Set up the folder structure (scans/, scope/, agents/)

## Step 3 — Copy the agent files into place

    mkdir -p .opencode/agent
    cp agents/*.md .opencode/agent/

## Step 4 — Fill in your scope

    cp scope/pentest-engagement.example.md scope/pentest-engagement.md
    cp scope/bugbounty-program.example.md scope/bugbounty-program.md

Edit these with YOUR actual engagement details before testing anything. For bug bounty use, you can also just paste the program's policy page text directly into the agent chat — it will extract and fill this file for you (then always double-check what it extracted against the real policy page).

## Step 5 — Daily use

    ./start.sh    # starts everything, asks which mode (pentest/bug bounty), launches opencode
    ./stop.sh     # cleanly stops everything when you're done

## Having issues?

Check the `doubts/` folder first — it covers real problems encountered during development: apt mirror failures, model crashes from insufficient RAM, agent-creation timeouts, and browser-automation display issues on Kali specifically.
