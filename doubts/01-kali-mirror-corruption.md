## Symptom
`apt install` fails partway through with errors like:
"File has unexpected size (23995 != 1552860). Mirror sync in progress?"
Some packages download fine, others fail from the same command.

## Cause
Kali's mirror redirector (http.kali.org) routed the request to a specific mirror that was serving corrupted/truncated files, likely mid-sync on their end.

## Fix
Simply retry — the redirector often routes to a different, healthy mirror on the next attempt:

    sudo apt update && sudo apt install --fix-missing -y <package names>

If it keeps hitting the same bad mirror repeatedly, point apt at the main redirector explicitly instead of a pinned mirror:

    sudo sed -i 's|http://kali.download/kali|http://http.kali.org/kali|' /etc/apt/sources.list
    sudo apt update

## How to prevent it next time
Not really preventable — this is a transient upstream issue. Just retry with --fix-missing before assuming the package itself is broken.
