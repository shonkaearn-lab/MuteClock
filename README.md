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

Tracks long profession cooldowns across all your characters. A coloured dot on your screen tells you what's ready.

[Features](#features) · [Install](#install) · [Usage](#usage) · [Config](#config) · [Commands](#commands)

</div>

---

Transmute: Arcanite. Mooncloth. Cure Rugged Hide. These reset every few days and are easy to forget, especially across alts. MuteClock puts a small dot on your screen that changes colour when something is ready. Hover it for the full breakdown. That's it.

---

## Features

### The dot

A small coloured square. Drag it anywhere on screen.

| Colour | Meaning |
|--------|---------|
| 🟢 Green | At least one craft is ready |
| 🟡 Yellow | Something comes off cooldown within 4 hours |
| 🔴 Red | Everything is on a long cooldown |
| ⬛ Grey | No data yet. Open a trade skill window |

---

### Tooltip

Hover the dot to see every tracked craft and how long until it's ready.

```
Craft Cooldowns  2 ready  1 waiting

Arathorn
  Transmute: Arcanite    Ready  (+6h overdue)
  Mooncloth              14h 22m

Silvara
  Transmute: Arcanite    Ready
```

Can be grouped by character (default) or by craft type.

---

### Multi-character tracking

Cooldown data is stored per character in a shared SavedVariables file. Turn on "Track all characters" and every alt shows up in one tooltip without logging in to each one. Data updates whenever you open a trade skill window.

---

### SmartIcon

When a craft is ready, the dot can swap to show the actual item icon instead of a coloured square. If multiple are ready, it shows the highest priority one. Current character takes priority over alts.

---

### Chat notifications

When a cooldown expires you get a chat message and a sound. Works for all characters in scope, not just whoever you're logged in as.

```
MuteClock  Your Transmute: Arcanite is ready!
MuteClock  Silvara's Mooncloth is ready!  (+2h 15m)
```

---

### Minimap button

Optional. Replaces the floating dot with a button on the minimap border. Drag it around the edge to reposition.

---

### History tab

The config panel has a History tab with a timestamped log of every craft you've performed, across all characters.

---

## Install

1. Drop the `MuteClock` folder into `World of Warcraft/Interface/AddOns/`
2. The folder should look like this:
   ```
   MuteClock/
   ├── MuteClock.lua
   ├── MuteClock.xml
   └── MuteClock.toc
   ```
3. Log in. MuteClock prints `MuteClock loaded.` in chat to confirm.

---

## Usage

**First time:** open any trade skill window that has a tracked craft. MuteClock reads the cooldown from the game and starts tracking.

**Open config:** Ctrl + left-click the dot, or `/muteclock config`

**Move the dot:** left-click and drag. Position saves on release.

---

## Config

<details>
<summary><strong>TRACKING</strong></summary>
<br />

**Track all characters**
Show cooldowns from every character that has opened a tracked trade skill, not just the current one.

**Chat alert on expiry**
Posts to your default chat frame and plays a sound when a cooldown expires.

</details>

<details>
<summary><strong>DISPLAY</strong></summary>
<br />

**Group tooltip by craft type**
Groups rows by craft name instead of by character.

**Show ready time**
Shows the real clock time when a cooldown will expire. Only shown for cooldowns over 1 hour.

**Show overdue time**
When a craft has been sitting ready, shows by how much. e.g. `Ready  +6h 12m`

**Show last crafted time**
Appends the timestamp of the last craft to each tooltip row.

</details>

<details>
<summary><strong>INDICATOR</strong></summary>
<br />

**Dot size**
4px to 32px. Default 16px.

**SmartIcon**
Replaces the dot with the craft icon when something is ready.

**Ready count badge**
Shows a number on the indicator for how many crafts are ready.

**Use minimap button**
Switches to a minimap border button instead of a floating dot.

**Hide indicator**
Hides the dot. Use `/muteclock show` to bring it back.

</details>

---

## Commands

| Command | Action |
|---------|--------|
| `/muteclock` | List commands |
| `/muteclock config` | Open settings |
| `/muteclock reset` | Reset to defaults |
| `/muteclock show` | Unhide the dot |

---

## Tracked crafts

| Craft | Profession | Cooldown |
|-------|-----------|----------|
| Transmute: Arcanite | Alchemy | 48h |
| Mooncloth | Tailoring | 4 days |
| Cure Rugged Hide | Leatherworking | 3.5 days |

To add more, edit the `TRACKED_CRAFTS` table at the top of `MuteClock.lua`. The `key` must exactly match what `GetTradeSkillInfo()` returns for that recipe.

```lua
{ key = "Recipe Name", label = "Display Label", icon = "Interface\\Icons\\IconName" },
```

---

<div align="center">
For the player with four alts and a spreadsheet.
</div>
