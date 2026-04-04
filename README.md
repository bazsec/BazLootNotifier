<h1 align="center">BazLootNotifier</h1>

<p align="center">
  <strong>Animated loot popups for World of Warcraft</strong><br/>
  Rarity-colored notifications for items, currency, gold, reputation, XP, and more.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/WoW-12.0%20Midnight-blue" alt="WoW Version"/>
  <img src="https://img.shields.io/badge/License-GPL%20v2-green" alt="License"/>
  <img src="https://img.shields.io/badge/Version-007-orange" alt="Version"/>
</p>

---

## What is BazLootNotifier?

BazLootNotifier shows animated popup notifications when you loot items, earn currency, pick up gold, gain reputation, earn XP/honor, or level up skills. Popups are color-coded by item rarity, stack and fade smoothly, and can be positioned anywhere on screen.

---

## Features

- **Item loot popups** with rarity-colored borders and text
- **Currency notifications** (Flightstones, Resonance Crystals, etc.)
- **Gold notifications** (filtered to ignore vendor/mail/trade)
- **Reputation gains**
- **XP and Honor gains**
- **Skill level ups**
- **Pop animation** with scale overshoot
- **Sound on loot**
- **Configurable scale, display time, and fade time**
- **Minimum quality filter** (Poor through Legendary)
- **Per-filter toggles** — enable/disable each notification type
- **Lock/unlock anchor** — drag to position, lock to prevent movement
- **Hide Blizzard loot window** option
- **Profile support** — save different settings per character via BazCore

---

## Settings

Open via `/bln` or WoW Settings > AddOns > BazLootNotifier.

| Setting | Description |
|---------|-------------|
| Popup Scale | Size of notifications (0.5x - 2.5x) |
| Display Time | How long popups stay visible |
| Fade Time | How long the fade-out animation takes |
| Enable Animation | Toggle the pop-in scale effect |
| Play Sound | Toggle loot sound |
| Lock Frame | Prevent anchor from being dragged |
| Hide Blizzard Loot | Auto-close the default loot window |
| Minimum Quality | Filter items below this rarity |

---

## Slash Commands

| Command | Description |
|---------|-------------|
| `/bln` | Open settings |
| `/bln lock` | Lock the anchor frame |
| `/bln unlock` | Unlock (drag to reposition) |
| `/bln test` | Show a test popup |
| `/bln reset` | Reset position to center |

---

## Requirements

- **BazCore** — shared framework (install alongside this addon)

---

## License

BazLootNotifier is licensed under the [GNU General Public License v2](LICENSE) (GPL v2).

---

<p align="center">
  <sub>Built by <strong>Baz4k</strong></sub>
</p>
