> **Warning: Requires [BazCore](https://www.curseforge.com/wow/addons/bazcore).** If you use the CurseForge app, it will be installed automatically. Manual users must install BazCore separately.

# BazLootNotifier

![WoW](https://img.shields.io/badge/WoW-12.0_Midnight-blue) ![License](https://img.shields.io/badge/License-GPL_v2-green) ![Version](https://img.shields.io/github/v/tag/bazsec/BazLootNotifier?label=Version&color=orange)

Animated loot popups with rarity colors, scaling, and fade timing.

BazLootNotifier shows a stylish popup notification whenever you loot items, gain XP, earn reputation, receive currency, or craft profession items. Each popup is color-coded by rarity, smoothly animates in and out, and automatically stacks duplicate events into a single combined popup instead of flooding your screen.

***

## Features

*   **Animated popups** for loot, XP, reputation, currency, honor, and profession crafts
*   **Rarity color coding** - popups match item quality colors
*   **Popup clumping** - duplicate events merge into one combined popup (kill 4 mobs = one XP total, not four separate popups)
*   **Configurable scaling** and fade timing
*   **Smart BNC handoff** - when BazNotificationCenter is installed, BLN silently defers per-category to avoid duplicate notifications
*   **Midnight taint safe** - uses Desecret helper for secret string handling
*   **Profile support** via BazCore

***

## Compatibility

*   **WoW Version:** Retail 12.0 (Midnight)
*   **Midnight API Safe:** Secret string taint handled via desecret helper
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
