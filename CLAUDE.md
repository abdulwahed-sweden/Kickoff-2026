# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this project is

A single self-contained HTML file — the **Kickoff Ambient Clock**: a calm, dark
"luxe" ambient screen for a 27" iMac shown fullscreen across a room. It displays
a large amber 12-hour clock plus a countdown to the next World Cup 2026 match
(with full country names and flags) and a smaller "NEXT" match below it.

No build step, no dependencies, no package manager. The deliverable runs by
double-clicking the HTML file in a browser. Fonts load from Google Fonts
(Archivo) but must degrade to `system-ui` if offline.

## Commands

There is no build/lint/test tooling. To work on it:

```bash
open kickoff-clock.html                 # macOS: open the live app in the browser
```

Iterate by editing the file and reloading the browser. Verify against the
**ACCEPTANCE CHECKLIST** at the bottom of `README.md` before finishing any change.
To sanity-check the pure JS logic (fixture rollover, countdown math) without a
browser, extract the `<script>` body and exercise it under `node -e` — see how it
was done when the dynamic version was built.

## The two files — read this first

`README.md` is the authoritative **build brief**: it specifies the fully dynamic
single-file app. The repo contains two HTML files:

- **`kickoff-clock.html`** — the **working dynamic app** (the README deliverable).
  Live clock, auto-detected timezone, the `FIXTURES` array that the countdown
  auto-advances through, `LIVE NOW` badge, F/double-click fullscreen, the
  `CLOCK_TYPE` / `SHOW_SECONDS` / `LIVE_WINDOW_MIN` config block, and a 16-entry
  `FLAGS` inline-SVG map. **This is the file to edit for behavior changes.**
- **`kickoff_dark_spacious_clear.html`** — the original **static visual mockup**
  (inline-styled markup, hardcoded `5:47 PM` / `12:48` / `Brazil`–`Morocco`, no
  JavaScript). Kept as the design reference that proved out spacing, color, and
  typography. The dynamic app reuses its design tokens and flag SVGs.

The flag SVGs in `kickoff-clock.html` are simplified placeholders. A few
(Australia, Türkiye, Tunisia, Cape Verde) are rough approximations meant to be
swapped for real images via the documented `<img src="flags/xxx.png">` path in
the `FLAGS` map comment.

## Design constraints that are the whole point (from README)

These were explicit corrections to a previous cramped/faint version — do not
regress them:

- **Generous spacing.** ~7–9% of viewport height between the four zones (clock /
  place line / first match / next match). When unsure, add more air.
- **Nothing faint, tiny, or half-hidden.** Min weight 500 (labels 600); no
  opacity below ~0.7 on meaningful text. `#9A968B` is the dimmest a *meaningful*
  label may go; only punctuation (the `:` and `vs`, color `#5A564C`) goes dimmer.
- **Full country names always** on BOTH matches (`Brazil`, not `BRA`). Trigrams
  are used only as internal keys (`hc`/`ac`, FLAGS map), never rendered.
- All English; first match prominent, second match smaller but clearly legible.

Color system: clock amber `#FFB23E` with glow; accent vermilion `#FF6A3D` (used
only for the seconds digits and the "OFF" in the KICKOFF wordmark); text
`#EDEAE0` / `#D8D4C8` / labels `#9A968B`. Background is the radial gradient in
the README. Expose the clock color as a CSS var `--clock`.

## Conventions

- **Single file, inline everything.** Keep CSS and JS inline in the one HTML
  file; do not introduce external assets, a build step, or dependencies.
- All fixture times are stored in **UTC** and converted to the viewer's local
  time at render — never hardcode local times.
- Flags are inline SVG placeholders keyed by trigram; leave a comment showing
  how to swap one for `<img src="flags/xxx.png">` later.
- Respect `prefers-reduced-motion`; keep motion to the 1s tick and an optional
  LIVE-badge pulse.
- Layout must scale cleanly from a laptop up to a 27" iMac (the mockup uses
  `clamp()` and `vw` units throughout — follow that pattern).
