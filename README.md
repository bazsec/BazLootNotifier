> **Warning: Requires [BazCore](https://www.curseforge.com/wow/addons/bazcore).** If you use the CurseForge app, it will be installed automatically. Manual users must install BazCore separately.

# BazLootNotifier

![WoW](https://img.shields.io/badge/WoW-12.0_Midnight-blue) ![License](https://img.shields.io/badge/License-GPL_v2-green) ![Version](https://img.shields.io/github/v/tag/bazsec/BazLootNotifier?label=Version&color=orange) ![Status](https://img.shields.io/badge/Status-Maintenance-yellow)

> **Maintenance mode.** BazLootNotifier is no longer receiving new features. Its event coverage has been superseded by **[BazNotificationCenter](https://www.curseforge.com/wow/addons/baznotificationcenter)** (BNC), which provides a more comprehensive toast + history system covering loot, XP, reputation, currency, honor, achievements, rare spawns, professions, and more. **New installs are encouraged to use BNC.** BLN remains supported for existing users; install BNC alongside BLN and the built-in smart handoff routes each event category to the right addon so you never see duplicate popups. BLN will continue receiving compatibility fixes for new WoW patches.

Animated loot popups with rarity colors, scaling, and fade timing.

BazLootNotifier shows a stylish popup notification whenever you loot items, gain XP, earn reputation, receive currency, or craft profession items. Each popup is color-coded by rarity, smoothly animates in and out, and automatically stacks duplicate events into a single combined popup instead of flooding your screen.

***

## Features

*   **Animated popups** for loot, XP, reputation, currency, honor, and profession crafts
*   **Rarity color coding** - popups match item quality colors
*   **Popup clumping** - duplicate events merge into one combined popup (kill 4 mobs = one XP total, not four separate popups)
*   **Configurable scaling** and fade timing
*   **Smart BNC handoff** - when BazNotificationCenter is installed, BLN silently defers per-category to avoid duplicate notifications
*   **Taint-safe** — handles Midnight's stricter API correctly so popups never break the rest of your UI
*   **Profile support** via BazCore

***

## Slash Commands

| Command | Description |
| --- | --- |
| `/bln` | Open settings panel |
| `/bln test` | Show a test popup to preview animation, scale, and fade settings |
| `/bln reset` | Reset the popup anchor position |
| `/bazlootnotifier` | Alias for `/bln` |

***

## Compatibility

*   **WoW Version:** Retail 12.0 (Midnight)
*   **Taint-safe** — handles Midnight's stricter API correctly
*   **BazNotificationCenter:** Smart per-category handoff when BNC is installed

***

## Dependencies

**Required:**

*   [BazCore](https://www.curseforge.com/wow/addons/bazcore) - shared framework for Baz Suite addons

**Optional:**

*   [BazNotificationCenter](https://www.curseforge.com/wow/addons/baznotificationcenter) - BLN defers matching categories to BNC when installed

***

## Part of the Baz Suite

BazLootNotifier is part of the **Baz Suite** of addons, all built on the [BazCore](https://www.curseforge.com/wow/addons/bazcore) framework:

*   **[BazBars](https://www.curseforge.com/wow/addons/bazbars)** - Custom extra action bars
*   **[BazWidgetDrawers](https://www.curseforge.com/wow/addons/bazwidgetdrawers)** - Slide-out widget drawer
*   **[BazWidgets](https://www.curseforge.com/wow/addons/bazwidgets)** - Widget pack for BazWidgetDrawers
*   **[BazNotificationCenter](https://www.curseforge.com/wow/addons/baznotificationcenter)** - Toast notification system
*   **[BazLootNotifier](https://www.curseforge.com/wow/addons/bazlootnotifier)** - Animated loot popups
*   **[BazFlightZoom](https://www.curseforge.com/wow/addons/bazflightzoom)** - Auto zoom on flying mounts
*   **[BazMap](https://www.curseforge.com/wow/addons/bazmap)** - Resizable map and quest log window
*   **[BazMapPortals](https://www.curseforge.com/wow/addons/bazmapportals)** - Mage portal/teleport map pins

***

## License

BazLootNotifier is licensed under the **GNU General Public License v2** (GPL v2).
