# BazLootNotifier Changelog

## 014 - Unified Profiles
- Profiles now managed centrally in BazCore settings
- Removed per-addon Profiles subcategory

## 012 - Audit Fixes
- Removed manual profile proxy (now auto-wired by BazCore)
- Category changed to "Baz Suite"

## 011 - Midnight Taint Fix
- Added Desecret() helper using string.format to strip secret string taint
- All chat event handlers now desecret values before processing

## 010 - Popup Clumping
- Duplicate popups now merge into one — XP, currency, items, rep, honor accumulate
- Existing popup updates in-place with repop animation instead of spawning duplicates
- Kill 4 mobs at once = one XP popup showing the total, not four separate popups
- Same-item loot stacks into a single popup with combined quantity

## 009 - BazCore SafeString
- Switched to BazCore:SafeString() for taint handling

## 008 - Secret String Taint Fix
- Fixed chat message handlers crashing on Midnight secret string values
- Fixed position not persisting through reloads

## 007
- Anchor frame now uses BazCore Edit Mode framework
- Full Edit Mode integration: cyan/yellow overlays, grid snapping, settings popup
- All settings accessible from the Edit Mode popup (scale, timers, filters, etc.)
- Center-preserving scale (no more sliding when resizing)
- Removed manual lock/unlock — use Edit Mode to reposition
- Removed lock/unlock slash commands

## 006
- Updated addon icon to sack/bag icon

## 005
- Migrated to BazCore framework
- Added profile support (create, switch, copy, rename, delete profiles)
- Settings panel now uses BazCore OptionsPanel with clean layout
- Minimap button via BazCore shared button
- Updated Interface version to 120001 (Midnight)
- Removed deprecated API calls
- License changed to GPL v2
