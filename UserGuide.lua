---------------------------------------------------------------------------
-- BazLootNotifier User Guide
---------------------------------------------------------------------------

if not BazCore or not BazCore.RegisterUserGuide then return end

BazCore:RegisterUserGuide("BazLootNotifier", {
    title = "BazLootNotifier",
    intro = "Animated loot popups with rarity colors, smart clumping, and configurable scaling. Now in maintenance mode — see the Welcome page for migration notes.",
    pages = {
        {
            title = "Welcome",
            blocks = {
                { type = "note", style = "warning", text = "|cffffd700Maintenance mode.|r BazLootNotifier is no longer receiving new features. Its event coverage has been superseded by |cffffd700BazNotificationCenter|r (BNC), which provides a more comprehensive toast + history system covering loot, XP, reputation, currency, honor, achievements, rare spawns, professions, and more. New installs are encouraged to use BNC instead. BLN remains supported for existing users — install BNC alongside BLN and the built-in smart handoff routes each event category to the right addon so you never see duplicate popups. BLN will continue receiving compatibility fixes for new WoW patches." },
                { type = "lead", text = "BazLootNotifier (BLN) shows a stylish popup whenever you loot items, gain XP, earn reputation, receive currency, or craft profession items. Each popup is color-coded by rarity, smoothly animates in and out, and stacks duplicate events into a single combined popup." },
                { type = "note", style = "tip", text = "Kill 4 mobs in a row? You get one XP popup with the total — not four separate popups stacking up." },
            },
        },
        {
            title = "What Triggers a Popup",
            blocks = {
                { type = "paragraph", text = "Every category can be toggled independently in settings." },
                { type = "table",
                  columns = { "Category", "Triggers" },
                  rows = {
                      { "Loot",        "Item drops with rarity color matching item quality" },
                      { "XP",          "Experience gains (clumped over a short window)" },
                      { "Reputation",  "Faction standing increases" },
                      { "Currency",    "Currency awarded by quests, rewards, etc." },
                      { "Honor",       "Honor gains in PvP" },
                      { "Professions", "Profession craft completions" },
                  },
                },
            },
        },
        {
            title = "Popup Clumping",
            blocks = {
                { type = "lead", text = "Duplicate events merge into one combined popup." },
                { type = "paragraph", text = "The window for clumping is short (a few seconds) so popups still feel responsive. Long-tail events get their own popup; bursty events combine." },
                { type = "note", style = "info", text = "This avoids the screen-flooding problem common with simpler loot announcers when grinding mobs or running through chest piles." },
            },
        },
        {
            title = "Visuals",
            blocks = {
                { type = "h3", text = "Scaling" },
                { type = "paragraph", text = "Adjust popup size to taste. Smaller for a less intrusive feel; larger for screen-shot-worthy moments." },
                { type = "h3", text = "Fade timing" },
                { type = "paragraph", text = "Configure how long popups stay on screen and how quickly they fade." },
                { type = "h3", text = "Rarity colors" },
                { type = "paragraph", text = "Item popups use Blizzard's standard rarity color scheme:" },
                { type = "list", items = {
                    "|cff9d9d9dGrey|r — poor",
                    "|cffffffffWhite|r — common",
                    "|cff1eff00Green|r — uncommon",
                    "|cff0070ddBlue|r — rare",
                    "|cffa335eePurple|r — epic",
                    "|cffff8000Orange|r — legendary",
                }},
            },
        },
        {
            title = "Smart BNC Handoff",
            blocks = {
                { type = "lead", text = "When BazNotificationCenter is installed alongside BLN, BLN automatically defers matching categories (Loot, Reputation, etc.) to BNC. You won't get duplicate popups — BNC's toast system takes over and BLN goes quiet for those categories." },
                { type = "note", style = "tip", text = "You can still mix and match per-category. Keep BLN's Loot popups but route everything else through BNC's toasts, or vice versa." },
            },
        },
        {
            title = "Slash Commands",
            blocks = {
                { type = "table",
                  columns = { "Command", "Effect" },
                  rows = {
                      { "/bln",              "Open the BazLootNotifier settings page" },
                      { "/bln test",         "Show a test popup so you can preview animation, scale, and fade settings" },
                      { "/bln reset",        "Reset the popup anchor position to the default" },
                      { "/bazlootnotifier",  "Alias for /bln — every subcommand works on either form" },
                  },
                },
            },
        },
    },
})
