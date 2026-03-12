# MuteClock

A minimal cooldown tracker for vanilla WoW (1.12 / TurtleWoW). Shows a single coloured dot on your screen. Hover it to see which of your characters can craft Arcanite, Mooncloth, and Cured Rugged Hide — and which are still on cooldown.

---

## Installation

1. Download or clone this repository
2. Place the `MuteClock` folder into `<WoW folder>\Interface\AddOns\`
3. The folder **must** be named `MuteClock`
4. Log in or `/reload`

---

## First-time setup

Open the relevant trade skill window on each character you want to track (Alchemy, Tailoring, Leatherworking). MuteClock reads the cooldown state at that point and remembers it. Do this once per character and they'll always appear in the list.

---

## The dot

The dot sits at the top-centre of your screen by default.

| Colour | Meaning |
|--------|---------|
| Grey   | No cooldown data recorded yet |
| Green  | At least one craft is ready |
| Yellow | Nothing ready, but something expires within 4 hours |
| Red    | Everything is on a long cooldown |

- **Shift+drag** to reposition
- **Ctrl+right-click** to open config
- With **SmartIcon** enabled, the dot swaps to the actual item icon when something is ready

---

## Tooltip

Hover the dot for the full breakdown. Each character is listed with their craft status.

- **Ready** — available to craft right now
- **1d 4h 30m** — time remaining on cooldown

**Show ready time** adds a local clock timestamp alongside the countdown — e.g. `1d 4h  Thu 14:30` — so you can plan without doing the mental arithmetic.

**Group by craft type** reorganises the tooltip to list all characters under each craft heading instead of all crafts under each character.

---

## Tracked crafts

| Craft | Profession | Cooldown |
|-------|-----------|----------|
| Transmute: Arcanite | Alchemy | 48 hours |
| Mooncloth | Tailoring | 4 days |
| Cure Rugged Hide | Leatherworking | 3.5 days |

---

## Config

Open with **Ctrl+right-click** on the dot, or `/muteclock config`.

| Option | Description |
|--------|-------------|
| Track all characters | Show cooldowns from all your alts, not just the current character |
| Chat alert on expiry | Sends a chat message and plays a sound when a cooldown expires |
| Group tooltip by craft | See all Mooncloth entries together, etc. |
| Show ready time | Adds a local clock timestamp to each cooldown line |
| Dot size | Resize the dot (4–32px) |
| SmartIcon | When something is ready, replace the dot with that craft's item icon. Prefers the current character's available crafts. Priority: Arcanite > Mooncloth > Cured Rugged Hide |
| Hide dot | Hides the dot entirely — use `/muteclock show` to get it back |
| Tooltip X / Y | Nudge the tooltip position relative to the dot |

---

## Slash commands

| Command | Description |
|---------|-------------|
| `/muteclock` | Show command list |
| `/muteclock config` | Open config window |
| `/muteclock reset` | Restore all settings to defaults (cooldown data kept) |
| `/muteclock show` | Unhide the dot |

---

## Notes

- Cooldown data is stored per character in `SavedVariables`. It persists across sessions and is shared between the same account's characters on the same realm.
- Characters you have never logged in and opened a trade skill window on will not appear in the list — there is no way to know their profession state without doing so at least once.
- Compatible with WoW 1.12 (Vanilla / TurtleWoW).
