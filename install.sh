#!/bin/bash
set -e

echo "=== VAPT Automation Installer ==="
echo ""

# --- Step 1: OS check ---
if ! grep -qi "kali" /etc/os-release; then
  echo "WARNING: This script is built and tested for Kali Linux only."
  echo "Running on a different distro may fail at the tool-install step."
  read -p "Continue anyway? (y/N): " confirm
  [[ "$confirm" =~ ^[Yy]$ ]] || exit 1
fi

sudo apt update && sudo apt upgrade -y
sudo apt install -y curl unzip git build-essential python3 python3-venv python3-pip jq

# --- Step 2: Hardware detection ---
RAM_GB=$(free -g | awk '/^Mem:/{print $2}')
CPU_CORES=$(nproc)

echo ""
echo "Detected: ${RAM_GB}GB RAM, ${CPU_CORES} CPU cores"

if [ "$RAM_GB" -lt 8 ]; then
  RECOMMENDED="qwen2.5-coder:3b"
elif [ "$RAM_GB" -lt 16 ]; then
  RECOMMENDED="qwen2.5-coder:7b"
else
  RECOMMENDED="qwen2.5-coder:14b"
fi

echo "Recommended model for your system: $RECOMMENDED"
echo ""
echo "Options:"
echo "  1) $RECOMMENDED (recommended for your system)"
echo "  2) qwen2.5-coder:3b  (lightest, fastest, weakest reasoning)"
echo "  3) qwen2.5-coder:7b  (balanced)"
echo "  4) qwen2.5-coder:14b (strongest reasoning, needs 16GB+ RAM)"
echo "  5) Enter a custom model name"
read -p "Choice [1]: " model_choice

case "$model_choice" in
  2) MODEL="qwen2.5-coder:3b" ;;
  3) MODEL="qwen2.5-coder:7b" ;;
  4) MODEL="qwen2.5-coder:14b" ;;
  5) read -p "Enter model name: " MODEL ;;
  *) MODEL="$RECOMMENDED" ;;
esac

echo "Using model: $MODEL"

# --- Step 3: Install opencode ---
echo ""
echo "Installing opencode..."
curl -fsSL https://opencode.ai/install | bash
export PATH="$HOME/.opencode/bin:$PATH"
echo 'export PATH="$HOME/.opencode/bin:$PATH"' >> ~/.bashrc

# --- Step 4: Install Ollama and pull the chosen model ---
echo ""
echo "Installing Ollama..."
curl -fsSL https://ollama.com/install.sh | sh
sudo systemctl enable ollama
sudo systemctl start ollama
sleep 2
ollama pull "$MODEL"

# --- Step 5: Configure opencode to use Ollama ---
mkdir -p ~/.config/opencode
cat > ~/.config/opencode/opencode.json << EOF
{
  "\$schema": "https://opencode.ai/config.json",
  "provider": {
    "ollama": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Ollama (local)",
      "options": { "baseURL": "http://localhost:11434/v1" },
      "models": { "$MODEL": { "name": "$MODEL" } }
    }
  }
}
EOF

# --- Step 6: Clone and set up HexStrike AI ---
echo ""
echo "Cloning HexStrike AI..."
git clone https://github.com/0x4m4/hexstrike-ai.git
cd hexstrike-ai
python3 -m venv hexstrike-env
source hexstrike-env/bin/activate
pip3 install -r requirements.txt
pip3 install selenium beautifulsoup4 mitmproxy webdriver-manager
deactivate
cd ..

# --- Step 7: Check for underlying security tools ---
echo ""
echo "Checking for required security tools..."
MISSING=()
for t in nmap masscan rustscan amass subfinder nuclei fierce dnsenum autorecon \
         theharvester responder netexec enum4linux-ng gobuster feroxbuster dirsearch \
         ffuf dirb httpx katana nikto sqlmap wpscan arjun paramspider dalfox wafw00f \
         hydra john hashcat medusa patator crackmapexec evil-winrm; do
  command -v "$t" >/dev/null 2>&1 || MISSING+=("$t")
done

if [ ${#MISSING[@]} -gt 0 ]; then
  echo "Missing tools: ${MISSING[*]}"
  read -p "Attempt to install these via apt now? (y/N): " install_confirm
  if [[ "$install_confirm" =~ ^[Yy]$ ]]; then
    sudo apt install -y "${MISSING[@]}" || echo "Some tools failed to install — see doubts/01-kali-mirror-corruption.md and install manually."
  fi
fi

sudo apt install -y chromium chromium-driver firefox-esr

# --- Step 8: Set up folder structure ---
echo ""
echo "Setting up folder structure..."
mkdir -p scans scope .opencode/agent
cp -n agents/*.md .opencode/agent/ 2>/dev/null
[ -f scope/pentest-engagement.md ] || cp scope/pentest-engagement.example.md scope/pentest-engagement.md
[ -f scope/bugbounty-program.md ] || cp scope/bugbounty-program.example.md scope/bugbounty-program.md

chmod +x start.sh stop.sh

echo ""
echo "=== Install complete ==="
echo "Next: edit scope/pentest-engagement.md or scope/bugbounty-program.md with your real details,"
echo "then run ./start.sh to begin."
