#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# Kickoff Ambient Clock — run FULLSCREEN in Chrome (kiosk mode).
#
# This is the SAFE way to show the clock on the iMac across the room. Unlike the
# macOS screensaver, the operating system stays fully responsive: you can always
# move the mouse, Cmd+Tab away, or quit — so there is NO hard-reboot / black-screen
# lock-up risk.
#
#   • Double-click this file to start.
#   • To EXIT fullscreen: press  Cmd + Q.
#   • The display is kept awake (caffeinate) so the clock never blanks.
#   • Uses its own isolated Chrome profile, so it won't touch your normal Chrome
#     windows, tabs, or history.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

HTML="$(cd "$(dirname "$0")" && pwd)/kickoff-clock.html"
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

if [ ! -x "$CHROME" ]; then
  echo "Google Chrome not found at: $CHROME"
  echo "Open kickoff-clock.html in any browser and press F for fullscreen instead."
  read -r -p "Press Return to close…" _
  exit 1
fi

# caffeinate -d keeps the DISPLAY awake and runs until Chrome quits.
exec caffeinate -d "$CHROME" \
  --user-data-dir="$HOME/.kickoff-clock-chrome" \
  --no-first-run --no-default-browser-check --disable-session-crashed-bubble \
  --kiosk --app="file://$HTML"
