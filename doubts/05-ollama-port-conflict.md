## Symptom
Running `ollama serve` manually gives:
"Error: listen tcp 127.0.0.1:11434: bind: address already in use"

## Cause
Ollama installs as a systemd service and starts automatically on boot/login. Running `ollama serve` manually afterward tries to bind the same port a second time, which fails since the systemd-managed instance already owns it.

## Fix
Don't start Ollama manually if it's already running as a service. Check first:

    systemctl status ollama

If it's active, you don't need to do anything else. To restart it cleanly (e.g. after a config change):

    sudo systemctl restart ollama

## How to prevent it next time
Always check `systemctl status ollama` before running `ollama serve` directly. This repo's start.sh only calls `sudo systemctl start ollama`, which is safe to run repeatedly — it won't error if already running.
