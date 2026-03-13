<div align="center">

<img src="https://img.shields.io/badge/TurtleWoW-1.12-c8a96e?style=flat-square&labelColor=1a1a1a" />
<img src="https://img.shields.io/badge/Vanilla_WoW-1.12.1-c8a96e?style=flat-square&labelColor=1a1a1a" />
<img src="https://img.shields.io/badge/license-MIT-4a9eff?style=flat-square&labelColor=1a1a1a" />

<br /><br />

```
╔═══════════════════════════════╗
║   M U T E C L O C K           ║
║   Craft Cooldown Tracker       ║
╚═══════════════════════════════╝
```

**A minimal, always-on cooldown tracker for profession crafts with long timers.**  
*Built for TurtleWoW / Vanilla 1.12.1*

[Features](#-features) · [Install](#-install) · [Usage](#-usage) · [Config](#-config) · [Commands](#-commands)

</div>

---

## The Problem It Solves

Transmute: Arcanite. Mooncloth. Cure Rugged Hide. These have **multi-day cooldowns** that are easy to forget. You either miss the reset window, or you're constantly logging alts to check. MuteClock puts a single coloured dot on your screen — always visible, always accurate — so you never forget again.

No bloat. No UI overhaul. Just a dot.

---

## ✦ Features

### The Indicator Dot
A small coloured square that lives anywhere on your screen. Its colour tells you everything at a glance:

| Colour | Meaning |
|--------|---------|
| 🟢 **Green** | One or more crafts are ready right now |
| 🟡 **Yellow** | Something comes off cooldown within 4 hours |
| 🔴 **Red** | All crafts are on long cooldowns |
| ⬛ **Grey** | No data yet — open a trade skill window |

Drag it anywhere. It remembers where you left it.

---

### The Tooltip
Hover the dot to see a full breakdown. Every tracked craft, every tracked character, with time remaining or ready status.

```
Craft Cooldowns  ✦ 2 ready  ✦ 1 waiting

Arathorn
  Transmute: Arcanite    Ready  (+6h overdue)
  Mooncloth              14h 22m
  
Silvara
  Transmute: Arcanite    Ready
```

The tooltip can be grouped **by character** (default) or **by craft type** — whichever makes more sense for how you play.

---

### Multi-Character Tracking
MuteClock stores cooldown data **per character**, all in the same SavedVariables file. Enable "Track all characters" and every alt's cooldowns show up in one place — without logging in to each one. Data is updated automatically every time you open a trade skill window on any character.

---

### SmartIcon Mode
When a cooldown is ready, the indicator dot can swap to show the **actual craft icon** instead of a coloured square. If multiple crafts are ready, it shows the highest-priority one (current character's crafts take priority over alts).

---

### Ready Badge
A small number overlaid on the indicator showing how many crafts are currently ready. Works with both the dot and the minimap button.

---

### Chat Notifications
When a cooldown expires, MuteClock posts a message to your chat frame and plays a sound. Works for all tracked characters in scope, not just your current one.

```
MuteClock  Silvara's Mooncloth is ready!
MuteClock  Your Transmute: Arcanite is ready!  (+2h 15m)
```

---

### Minimap Button
Prefer your indicator on the minimap? Enable the minimap button in settings. It replaces the floating dot, uses the standard minimap border ring, and can be **dragged around the edge** of the minimap to any position you like.

---

### Craft History
The **History tab** in the config panel shows a chronological log of every craft you've performed across all characters — time-stamped, colour-coded by character.

---

## ⬇ Install

1. Download and unzip
2. Drop the `MuteClock` folder into:
   ```
   World of Warcraft/Interface/AddOns/
   ```
3. The folder should contain:
   ```
   MuteClock/
   ├── MuteClock.lua
   ├── MuteClock.xml
   └── MuteClock.toc
   ```
4. Log in. Done.

> MuteClock prints `MuteClock loaded.` in chat on login to confirm it's active.

---

## ▶ Usage

### First Time
Open any trade skill window that contains a tracked craft. MuteClock reads the cooldown data from the game and starts tracking from that moment. The dot will change colour immediately.

### Opening the Config
Three ways:
- **Ctrl + Left-click** the indicator dot
- **Ctrl + Left-click** the minimap button
- Type `/muteclock config`

### Moving the Dot
**Left-click and drag** the dot anywhere on screen. Position is saved automatically on release.

---

## ⚙ Config

<details>
<summary><strong>TRACKING</strong></summary>

<br />

**Track all characters**  
Shows cooldowns from every character that has ever opened a tracked trade skill, not just whoever you're logged in as. Essential for multi-crafter setups.

**Chat alert on expiry**  
Posts a message to your default chat frame and plays `AuctionWindowOpen` sound when a cooldown expires.

</details>

<details>
<summary><strong>DISPLAY</strong></summary>

<br />

**Group tooltip by craft type**  
Reorganises the tooltip to group rows by craft name (Mooncloth, Transmute, etc.) rather than by character. Useful if you have many alts doing the same craft.

**Show ready time**  
Appends the real clock time when a cooldown will expire. e.g. `14h 22m  Thu 08:30`. Only shown for cooldowns longer than 1 hour.

**Show overdue time**  
When a craft has been ready but not yet performed, shows how overdue it is. e.g. `Ready  +6h 12m`. Useful guilt.

**Show last crafted time**  
Appends the timestamp of the last time each craft was performed, next to each tooltip row.

</details>

<details>
<summary><strong>INDICATOR</strong></summary>

<br />

**Dot Size**  
Slider from 4px to 32px. Default 16px.

**SmartIcon**  
Replaces the coloured dot with the actual craft icon when something is ready.

**Ready count badge**  
Overlays a number on the indicator showing how many crafts are ready right now.

**Use minimap button**  
Switches the indicator from a floating dot to a minimap border button. Drag it around the minimap edge to reposition.

**Hide indicator**  
Hides the dot entirely. Restore it with `/muteclock show`.

</details>

---

## ✦ Commands

| Command | What it does |
|---------|-------------|
| `/muteclock` | List all commands |
| `/muteclock config` | Open the settings panel |
| `/muteclock reset` | Reset all settings to defaults |
| `/muteclock show` | Unhide the indicator dot |

---

## Tracked Crafts

Out of the box, MuteClock tracks:

| Craft | Profession | Cooldown |
|-------|-----------|----------|
| Transmute: Arcanite | Alchemy | 48 hours |
| Mooncloth | Tailoring | 4 days |
| Cure Rugged Hide | Leatherworking | 3.5 days |

**Want to add more?** Open `MuteClock.lua` and add entries to the `TRACKED_CRAFTS` table at the top of the file. The `key` must exactly match what `GetTradeSkillInfo()` returns for that recipe.

```lua
{ key = "Your Recipe Name", label = "Display Label", icon = "Interface\\Icons\\YourIcon" },
```

---

## Data & Privacy

All data is stored locally in your WoW SavedVariables file (`WTF/Account/.../SavedVariables/MuteClock.lua`). Nothing is sent anywhere. Cooldown data persists across sessions and is shared between characters on the same account.

---

<div align="center">

Made for the kind of player who has four alts and a spreadsheet.

</div>
