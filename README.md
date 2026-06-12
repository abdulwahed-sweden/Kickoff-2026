# BUILD BRIEF — Kickoff Ambient Clock (for Claude Code)

**Audience:** Claude Code. Build this as a single self-contained file.
**Deliverable:** `kickoff-clock.html` — one HTML file, inline CSS + JS, no build
step, no dependencies, runs by double-clicking. Target device: a 27" iMac shown
fullscreen across a room.

---

## GOAL

A calm, **spacious**, dark "luxe" ambient screen that serves two jobs at once:

1. A large **amber family clock** (12-hour, e.g. `5:47 PM`) readable from far away.
2. The **next World Cup 2026 match** countdown (prominent) plus the **match
   after it** (smaller, but fully legible) — both with **full country names**
   and flags.

The previous version felt cramped and had faint, tiny, half-hidden text. This
rebuild must fix exactly that. Priorities, in order: **breathing room → clarity
→ elegance**.

---

## NON-NEGOTIABLE RULES (the point of this rebuild)

1. **Generous spacing.** Lots of vertical air between the four zones (clock /
   place line / first match / next match). Aim for ~7–9% of viewport height as
   gaps. Never let elements crowd. When unsure, add more space.
2. **Nothing faint, nothing tiny, nothing half-hidden.** Every text element must
   be clearly readable. Minimum effective weight 500; labels 600. No opacity
   tricks below ~0.7. The smallest text on screen (the "NEXT" match line) must
   still be comfortably readable from a sofa.
3. **Full country names, always.** Write `Brazil`, `Morocco`, `Haiti`,
   `Scotland` — never trigrams like BRA/MAR. This applies to BOTH matches. The
   trigram-only approach was unclear and is banned here.
4. **All English.** Every label and name in English. (No localization in this
   build.)
5. **First match prominent, second match smaller but clear.** The next match
   gets the big countdown + large flags + big names. The match after it sits
   below in a subtle rounded container: smaller flags and names, full names,
   plus its local kickoff time. Smaller — but not faint.

---

## LAYOUT (top to bottom, centred, lots of air)

```
  KICKOFF (top-left)                         SAT 13 JUN (top-right)

                    5:47 PM            ← amber glowing clock, hero
               STOCKHOLM · CEST        ← place + tz, clear weight-600

                  (big gap)

     [flag] Brazil      12 : 48      Morocco [flag]   ← first match
                        MIN  SEC                         big flags + names

                  (big gap)

     [ NEXT  [flag] Haiti  vs  Scotland [flag]   03:00 ]  ← rounded pill,
                                                            smaller, still clear
```

- Clock is the visual hero. Place/timezone line directly under it.
- First match: flags ~6vw tall, names ~17px weight-700, countdown digits huge.
- Next match: a `rgba(255,255,255,.04)` rounded container, flags ~3vw, names
  ~16px weight-700, a muted `vs`, and the local kickoff time at the end.

---

## VISUAL SYSTEM (dark luxe)

- **Background:** radial gradient, lighter centre → near-black edges:
  `radial-gradient(130% 100% at 50% 26%, #181A1F 0%, #0C0D10 60%, #070708 100%)`.
- **Clock amber:** `#FFB23E` with glow `text-shadow:0 0 40px rgba(255,150,40,.4)`.
  Chosen for long-distance legibility on dark.
- **Text:** primary `#EDEAE0`; secondary `#D8D4C8`; labels `#9A968B` (this is the
  _floor_ — don't go dimmer for anything that carries meaning); the colon and
  `vs` may use `#5A564C` since they're punctuation, not information.
- **Accent:** vermilion `#FF6A3D` — the seconds digits and the "OFF" in the
  wordmark only.
- **Flags:** real flag look; here use inline SVG placeholders keyed by trigram,
  but render the NAME in text. Flag tile: 2px light ring on the first match,
  1.5px on the next-match pill, radius 3–5px.
- **Type:** Archivo (Google Fonts `@import`, but degrade gracefully to
  system-ui if offline). Headline weights 800–900, tabular-nums on all numbers.
- **Geometry:** soft, near-square. Radius 5–8px. No pills for buttons (the
  next-match container is a gentle rounded card, that's fine). No blurred drop
  shadows except the clock glow. No gradients besides the background.
- **Motion:** keep it calm. Only a 1s tick. Optional 1.2s pulse on a LIVE badge.
  Respect `prefers-reduced-motion`.

---

## BEHAVIOUR

- **Clock:** live, updates every second. 12-hour with `AM/PM`. Show seconds
  small after the minutes. Auto-detect timezone via
  `Intl.DateTimeFormat().resolvedOptions().timeZone`; show the city + short tz
  name (e.g. "STOCKHOLM · CEST"). Date top-right.
- **Countdown:** runs against the client clock. Show MIN:SEC always; if the
  match is more than an hour away, also show DAYS/HRS to the left at a smaller
  size (but still clearly readable — not faint). Seconds digits in vermilion.
- **Auto-advance:** keep a `FIXTURES` array (UTC kickoff times). Always count
  down to the next fixture whose kickoff is still ahead (keep showing it during
  a +2h "LIVE NOW" window, then roll to the next). The "NEXT" pill shows the
  fixture immediately after the current one, with its local kickoff time.
- **LIVE state:** at kickoff, replace the countdown with a vermilion `LIVE NOW`
  badge (white text, gentle pulse), and show both full team names above it.
- **Fullscreen:** press **F** or double-click toggles
  `requestFullscreen()`. Hide the cursor (`cursor:none`).
- **Timezone:** all fixture times are stored in UTC and converted to the
  viewer's local time via `toLocaleString` — never hardcode local times.

---

## REAL FIXTURES TO SEED (WC26, kickoff in UTC)

Source: published WC26 GMT schedule. Verify against FIFA.com near kickoff.

```js
const FIXTURES = [
  {
    home: 'Qatar',
    away: 'Switzerland',
    hc: 'QAT',
    ac: 'SUI',
    kickoffUTC: '2026-06-13T19:00:00Z',
  },
  {
    home: 'Brazil',
    away: 'Morocco',
    hc: 'BRA',
    ac: 'MAR',
    kickoffUTC: '2026-06-13T22:00:00Z',
  },
  {
    home: 'Haiti',
    away: 'Scotland',
    hc: 'HAI',
    ac: 'SCO',
    kickoffUTC: '2026-06-14T01:00:00Z',
  },
  {
    home: 'Australia',
    away: 'Türkiye',
    hc: 'AUS',
    ac: 'TUR',
    kickoffUTC: '2026-06-14T04:00:00Z',
  },
  {
    home: 'Germany',
    away: 'Curaçao',
    hc: 'GER',
    ac: 'CUW',
    kickoffUTC: '2026-06-14T17:00:00Z',
  },
  {
    home: 'Netherlands',
    away: 'Japan',
    hc: 'NED',
    ac: 'JPN',
    kickoffUTC: '2026-06-14T20:00:00Z',
  },
  {
    home: 'Sweden',
    away: 'Tunisia',
    hc: 'SWE',
    ac: 'TUN',
    kickoffUTC: '2026-06-15T02:00:00Z',
  },
  {
    home: 'Spain',
    away: 'Cape Verde',
    hc: 'ESP',
    ac: 'CPV',
    kickoffUTC: '2026-06-15T16:00:00Z',
  },
]
```

Provide a `FLAGS` map of simple inline SVGs keyed by trigram (Brazil, Morocco,
Haiti, Scotland, Qatar, Switzerland, Australia, Türkiye, Germany, Curaçao,
Netherlands, Japan, Sweden, Tunisia, Spain, Cape Verde). Leave a clear comment
showing how to swap an entry for `<img src="flags/bra.png">` later.

---

## CONFIG BLOCK (put at top of script, well-commented)

```js
const CLOCK_TYPE = '12h' // '12h' → 5:47 PM   |   '24h' → 17:47
const SHOW_SECONDS = true
const LIVE_WINDOW_MIN = 120 // keep showing a match as LIVE for this long
```

Also expose the clock colour as a CSS var `--clock` so it's a one-line change.

---

## ACCEPTANCE CHECKLIST (Claude Code: verify before finishing)

- [ ] Four zones with visibly generous gaps; nothing crowded.
- [ ] No text below readable size; no opacity under ~0.7 on meaningful text.
- [ ] Full country names on BOTH matches; zero trigram-only labels on screen.
- [ ] Clock is amber, glowing, 12-hour, updates every second.
- [ ] Countdown auto-advances through FIXTURES; LIVE badge at kickoff.
- [ ] Times converted from UTC to local; timezone label correct.
- [ ] Press F / double-click toggles fullscreen; cursor hidden.
- [ ] Single file, opens by double-click, works offline if font fails to load.
- [ ] Scales cleanly from a laptop screen up to a 27" iMac.

Build it, open it, and confirm the layout breathes. If a zone looks tight, add
space — err on the side of too much air.
