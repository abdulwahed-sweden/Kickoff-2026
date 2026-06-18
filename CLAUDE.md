# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this project is

A single self-contained HTML file — the **Kickoff Ambient Clock**: a calm, dark
"luxe" ambient screen for a 27" iMac shown fullscreen across a room, also
installed as the machine's **macOS screensaver**. It shows a large amber
**12-hour clock (AM/PM)** plus the next **World Cup 2026** match with its
**Stockholm kickoff date & time (24h)**, and a tiered **UPCOMING** list of the
matches after it (the immediate next in colour, the rest smaller and grayscale).

No build step, no dependencies, no package manager. It runs by double-clicking
the HTML file. Fonts load from Google Fonts (**Inter**) but degrade to
`system-ui` offline.

## The file

- **`kickoff-clock.html`** — the whole app (inline CSS + JS). **Edit this** for
  any change.
- **`README.md`** — the original build brief. Useful for intent and the design
  values, but the app has since evolved past it: the centre shows the **match
  date/time**, not a MIN:SEC countdown; the clock is **Inter**, not Archivo; the
  bottom is a **tiered upcoming list**, not a single "NEXT" pill; flags are
  **real raster PNGs**, not inline-SVG placeholders. When README and the code
  disagree, the code is current.
- **`GUIDE.md`** — a very-simple-English user guide (with `screenshot.png`).

There is no longer a separate static mockup file.

### Config block (top of the `<script>`)
`CLOCK_TYPE` (`'12h'`/`'24h'`), `SHOW_SECONDS`, `LIVE_WINDOW_MIN` (how long a
kicked-off match stays as `LIVE NOW`), `MATCH_TZ` (`'Europe/Stockholm'` — match
times always render here, independent of the clock), `UPCOMING_COUNT`. The clock
colour is the CSS var `--clock`.

`FIXTURES` holds the real WC2026 group-stage matches with kickoff in **UTC**;
times are converted to `MATCH_TZ` at render. Each fixture carries a 3-letter
`hc`/`ac` code mapped to an ISO-2 code in the `ISO` table for flags.

## Commands / verifying

No build/lint/test tooling.

```bash
open kickoff-clock.html        # open the live app in the default browser
```

- **Logic check without a browser:** extract the `<script>` body and run it under
  `node -e` / a `.cjs` file (used throughout history to verify fixture rollover,
  ISO coverage, TZ conversion). `Date`/`Intl` work in Node.
- **Pixel-perfect screenshot:** headless Chrome —
  `"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless=new
  --window-size=1600,900 --force-device-scale-factor=2 --virtual-time-budget=6000
  --screenshot=screenshot.png "file://$PWD/kickoff-clock.html"`.
  ⚠️ A Chrome screenshot is **not** a faithful test of the screensaver — see below.

## Flags — and the WKWebView gotcha (important)

Flags are **real raster PNGs** from flagcdn, one code path in `setFlag()`:
`https://flagcdn.com/h120/<iso>.png` with an `h240 ... 2x` srcset. On load error it
draws a neutral lettered tile (`.flag-fallback`) — never a blank box or wrong flag.

**Do not reintroduce remote SVG flags.** Monterey's **WKWebView** (the engine the
screensaver runs in) renders a remote **SVG inside `<img>` as a blank/garbled
box** — even though Chrome renders it perfectly. This is why an earlier
flagcdn-`.svg` version looked flawless in a headless-Chrome screenshot but showed
blank/wrong flags in the actual screensaver. Raster PNGs carry intrinsic
dimensions and render identically everywhere. Likewise avoid OS emoji flags (🇨🇦)
— they differ per OS. Scotland is `gb-sct` (flagcdn also supports `gb-eng`,
`gb-wls`).

**Always verify flag/layout changes in the real screensaver, not just a browser.**

**Verified 2026-06-18 (Chrome kiosk fullscreen):** all **48** flagcdn
`h120/<iso>.png` URLs the app references return HTTP `200`, and every flag renders
correctly — prominent match in full colour, dim UPCOMING rows correctly grayscaled,
**no fallback tiles, no blank/wrong flags.** The WKWebView gotcha above is
**screensaver-engine-specific**: when run as a Chrome kiosk (see
`run-fullscreen.command`) a headless-Chrome screenshot *is* a faithful test, since
the kiosk and headless use the same Chromium engine and the raster PNGs load
reliably. Re-run the URL check any time with:

```bash
grep -oE "[A-Z]{3}:'[a-z-]+'" kickoff-clock.html | grep -oE "'[a-z-]+'" | tr -d "'" \
  | sort -u | while IFS= read -r iso; do
      printf '%s %s\n' "$iso" \
        "$(curl -s --max-time 8 -o /dev/null -w '%{http_code}' "https://flagcdn.com/h120/$iso.png")"
    done
```

## Deployed as the macOS screensaver

Installed via **WebViewScreenSaver** (`~/Library/Screen Savers/WebViewScreenSaver.saver`),
which points at a **copy of the page baked into the saver bundle**:
`~/Library/Screen Savers/WebViewScreenSaver.saver/Contents/Resources/kickoff-clock.html`
(a bundle path is the only location the sandboxed engine can reliably read).

- **After editing `kickoff-clock.html`, you MUST re-sync the copy** or the
  screensaver shows the old version:
  `cp kickoff-clock.html "$HOME/Library/Screen Savers/WebViewScreenSaver.saver/Contents/Resources/kickoff-clock.html"`
- The saver reads its URL from per-host prefs in the **sandboxed
  `legacyScreenSaver` container** (domain `WebViewScreenSaver`, key
  `kScreenSaverURLList` → `kScreenSaverURL`/`kScreenSaverTime`) — writing the
  plain `defaults -currentHost` domain alone is **not** read by the sandboxed
  engine. Default module + idle time live in `com.apple.screensaver`
  (`-currentHost`), currently 120s.
- **Preview:** `/System/Library/CoreServices/ScreenSaverEngine.app/Contents/MacOS/ScreenSaverEngine`
  (move the mouse to exit). `killall cfprefsd` after pref changes.

## Design constraints (do not regress)

- **Generous, even vertical spacing** between the zones (clock+place / match /
  upcoming). Erring toward more air was an explicit, repeated request.
- **Nothing faint, tiny, or half-hidden.** `--label` (`#A7A296`) is the dimmest a
  *meaningful* label goes; only punctuation (`vs`, `--punct`) goes dimmer.
- **Full country names always** (`Brazil`, never `BRA`). Trigrams are internal
  keys only.
- **All English.** Clock is the hero; the prominent match in full colour, the
  upcoming rows progressively smaller and de-saturated ("fewer colours" toward
  the bottom).
- Colours: clock amber `--clock` `#FFB23E` (glow); vermilion `--accent` `#FF6A3D`
  (the prominent match time + the "OFF" in the wordmark). Timezone label shows
  **CET/CEST** via `tzAbbr()` (the browser's `GMT+2` is mapped from the offset).

## Conventions

- **Single file, inline everything.** No build step, no external assets except the
  flag CDN (with the lettered-tile fallback) and the Google-Fonts `@import`.
- Fixture times stored in **UTC**, rendered in `MATCH_TZ`; never hardcode local times.
- Respect `prefers-reduced-motion` (kills the LIVE pulse).
- Layout scales laptop → 27" iMac via `clamp()` + `vw`/`vh` units — follow that pattern.
