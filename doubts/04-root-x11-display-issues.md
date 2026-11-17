## Symptom
Chrome via Selenium: launches (taskbar icon appears) but window is never visible / nothing renders.
Firefox via Selenium or directly: "Running Firefox as root in a regular user's session is not supported. ($XAUTHORITY is /home/kali/.Xauthority which is owned by kali.)"

## Cause
Running browser automation as root while the actual desktop/X11 session belongs to a regular user (e.g. "kali"). Root doesn't own the display's auth file, so browsers either silently fail to render (Chrome) or explicitly refuse to start (Firefox, which checks for this directly).

## Fix
Give root its own copy of the auth file, owned by root, and point XAUTHORITY/DISPLAY at it:

    cp /home/kali/.Xauthority /root/.Xauthority
    chown root:root /root/.Xauthority
    export XAUTHORITY=/root/.Xauthority
    export DISPLAY=:0.0
    xhost +si:localuser:root

For Chrome specifically, also ensure these launch flags are present (fixes a separate but related crash — "Chrome instance exited"):

    --no-sandbox --disable-dev-shm-usage

## How to prevent it next time
This repo's start.sh already bakes this fix in automatically — it runs these commands every time you start the project, so you shouldn't need to think about this day to day. If you ever run commands manually outside start.sh, remember this fix needs to be re-applied in that shell.
