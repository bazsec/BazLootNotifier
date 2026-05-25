# BazLootNotifier Changelog

## 015 - Smart-Defer to BazNotificationCenter
- When BNC is installed and has the matching module enabled, BLN silently stands down for that category
- Per-category handoff: loot → BNC.loot, reputation → BNC.reputation, XP → BNC.xp, profession creates → BNC.professions
- Other categories keep firing normally so nothing is lost if you only use part of BNC
- No configuration required — defer check happens at event time
