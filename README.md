# MuteClock

Cooldown tracker for vanilla WoW (1.12 / TurtleWoW). Tracks Transmute: Arcanite, Mooncloth, and Cure Rugged Hide across all your alts, and optionally across other players who run the addon.

---

## Installation

1. Place the `MuteClock` folder into `<WoW folder>\Interface\AddOns\`
2. The folder must be named `MuteClock`
3. Log in or `/reload`

On first load a welcome tooltip appears. Click it away or wait 30 seconds.

---

## First-time setup

Open the relevant trade skill window on each character you want to track (Alchemy, Tailoring, Leatherworking). MuteClock reads and stores the cooldown state at that point. You only need to do this once per character.

---

## Tracked crafts

| Craft | Profession | Cooldown |
|---|---|---|
| Transmute: Arcanite | Alchemy | 48 hours |
| Mooncloth | Tailoring | 4 days |
| Cure Rugged Hide | Leatherworking | 3.5 days |

---

## Display modes

Choose how the indicator looks. Switch between them in the config window (Settings tab → Display Mode dropdown).

**Dot** — a single small square. Default size 16 px, resizable 4–32 px. Colour indicates status:

| Colour | Meaning |
|---|---|
| Grey | No cooldown data recorded yet |
| Green | At least one craft is ready |
| Yellow | Nothing ready; something expires within 4 hours |
| Red | Everything is on a long cooldown |

**Bar** — a compact vertical list showing one row per tracked craft. Each row has a coloured pip and a countdown.

**Mini-panel** — a small floating panel with craft abbreviations and their countdowns.

All three modes are draggable. Position is saved per character.

---

## The indicator

**Interacting with the dot/bar/mini-panel:**

| Input | Action |
|---|---|
| Hover | Show tooltip |
| Left-drag | Move the indicator |
| Right-click | Open context menu |
| Ctrl+click | Open config window |
| Shift+click | Toggle tooltip between My Cooldowns and Crafters views |

---

## Tooltip

Hover the indicator to see a full breakdown.

Two views are available. Toggle between them with Shift+click, or from the right-click context menu.

**My Cooldowns** — lists your own characters and their craft statuses. Ready crafts appear first. The header shows a count of how many are ready and how many are waiting.

**Crafters** — lists saved crafters (other players) and their statuses. See the Crafters section below.

**Tooltip options** (set in config):

- **Group by craft** — reorganises the My Cooldowns view to list all characters under each craft heading instead of all crafts under each character.
- **Show ready time** — adds a local clock timestamp to each cooldown line alongside the countdown, e.g. `1d 4h  Thu 14:30`.
- **Show overdue** — when a craft is ready, shows how long it has been sitting uncrafted, e.g. `Ready +2h 15m`.
- **Show last crafted** — appends a timestamp showing when the craft was last made.

---

## Icon mode

When a craft is ready, the dot can swap to show an item icon instead of a coloured square. Configure via the Icon Mode dropdown in Settings.

| Option | Behaviour |
|---|---|
| Dot only | Always shows the coloured dot; never swaps to an icon |
| Smart (auto) | Shows the icon of the best ready craft. Prefers the current character's crafts. Priority: Arcanite → Mooncloth → Rugged Hide |
| Arcanite / Mooncloth / Cure Rugged Hide | Always shows that craft's icon when anything is ready |

---

## Badge

Enable **Show badge** in Settings to overlay a small number on the indicator showing how many crafts are currently ready across all tracked characters and crafters.

- Gold: your own crafts only
- Cyan: crafter crafts only
- Mixed green: both

---

## Crafters

MuteClock can track cooldowns for other players who also run the addon. When you are in a party, raid, or guild with another MuteClock user, their cooldown data is exchanged automatically in the background.

Open the config window and go to the **Crafters tab**. It has two columns:

- **Left — Saved Crafters:** Players you have pinned. Their cooldowns appear in the Crafters tooltip view and the Planner. Click **−** to remove.
- **Right — Detected:** Players with MuteClock who are in your current group or guild. Click **+** to save them as a crafter.

Crafter data that has not been refreshed for more than 48 hours is marked with ⚠ (stale).

---

## Planner

Open the config window and go to the **Planner tab** for a full overview of every cooldown — your own alts and all saved crafters — sorted by time remaining, with ready crafts at the top. Updates live every 5 seconds while the window is open.

---

## Notifications

When a cooldown expires, MuteClock prints a message to chat and plays a sound. This fires once when the cooldown first reaches zero, and again each time you open the trade skill window on that character if the craft is still ready.

**Overdue reminders** — if a craft is ready and you have not made it, MuteClock can send periodic reminders. Set the interval in Settings (Off / Every 2h / Every 4h / Every 8h / Once a day).

Both the initial alert and overdue reminders can be disabled independently. Uncheck **Chat alert on expiry** in Settings to turn off all notifications.

---

## Config

Open with **Ctrl+click** on the indicator, right-click → Open Config, or `/muteclock config`.

The config window has three tabs: Planner (default), Crafters, and Settings.

**Settings tab options:**

| Option | Description |
|---|---|
| Track all characters | Show cooldowns from all your alts, not just the current character |
| Chat alert on expiry | Print a chat message and play a sound when a cooldown expires |
| Overdue reminder | Send a follow-up reminder at a set interval while a craft remains uncrafted |
| Group tooltip by craft | Group the My Cooldowns tooltip by craft type instead of by character |
| Show ready time | Add a local clock timestamp to each cooldown line |
| Show overdue | Show how long a ready craft has been waiting |
| Show last crafted | Show when each craft was last made |
| Show badge | Overlay a ready-count number on the indicator |
| Tooltip mode | Toggle default tooltip view between My Cooldowns and Crafters |
| Display mode | Dot, Bar, or Mini-panel |
| Icon mode | How the indicator behaves when something is ready (see Icon mode above) |
| Dot size | Resize the dot (4–32 px) — only relevant in Dot mode |
| Hide | Hide the indicator entirely. Use `/muteclock show` to restore it |

---

## Slash commands

| Command | Description |
|---|---|
| `/muteclock` | Print command list to chat |
| `/muteclock config` | Open config window |
| `/muteclock reset` | Restore all settings to defaults (cooldown data is kept) |
| `/muteclock show` | Unhide the indicator |
| `/muteclock status` | Print a one-line cooldown summary to chat |
| `/muteclock debug` | Print network state (channel, peers, payload) |

---

## Notes

- Cooldown data is stored in `SavedVariables` and persists across sessions. All characters on the same account and realm share the same saved data file, so alts you have opened trade skill windows on will always appear.
- Characters you have never opened a trade skill window on will not appear — there is no way to know their state otherwise.
- Crafter data is exchanged via addon messages while in a party, raid, or guild with another MuteClock user. It is not sent to strangers.
- Compatible with WoW 1.12 (Vanilla / TurtleWoW).
