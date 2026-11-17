## Symptom
opencode shows: "Cannot connect to API: The socket connection was closed unexpectedly." Ollama appears to have silently died.

## Cause
A model too large for available VM RAM (e.g. qwen2.5-coder:14b on a 7.8GB RAM VM) gets OOM-killed by the kernel while loading or during inference. Check with:

    dmesg | grep -i "out of memory"
    free -h

## Fix
Drop to a smaller model that comfortably fits available RAM:

    ollama rm qwen2.5-coder:14b
    ollama pull qwen2.5-coder:7b

(or 3b on very constrained VMs). Restart Ollama cleanly:

    sudo systemctl restart ollama

Update opencode's model config (opencode.json, provider.ollama.models) to match.

## How to prevent it next time
Check `free -h` BEFORE pulling a model. Rough rule of thumb: the model's file size (from `ollama list` after pulling) plus ~2GB headroom for the OS/opencode/HexStrike should stay under your AVAILABLE RAM, not total RAM.
