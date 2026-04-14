-- BazLootNotifier Core
-- Addon registration via BazCore, settings, anchor frame

local ADDON_NAME = "BazLootNotifier"

local addon
addon = BazCore:RegisterAddon(ADDON_NAME, {
    title = "BazLootNotifier",
    savedVariable = "BazLootNotifierDB",
    profiles = true,
    defaults = {
        position    = { x = 0, y = 150 },
        scale       = 1.0,
        displayTime = 1.5,
        fadeTime    = 0.6,
        hideDefaultLoot = false,
        showItems   = true,
        showCurrency = true,
        showMoney   = true,
        showRep     = true,
        showXP      = false,
        showSkills  = false,
        minQuality  = 1,
        enablePop   = true,
        playSound   = true,
        anchorToCursor = false,
        onlyMyLoot  = true,
    },

    slash = { "/bln", "/bazlootnotifier" },
    commands = {
        test = {
            desc = "Show a test popup",
            handler = function()
                addon:TestPopup()
            end,
        },
        reset = {
            desc = "Reset position to center",
            handler = function()
                addon:ResetPosition()
                addon:Print("Position reset.")
            end,
        },
    },

    minimap = {
        label = "BazLootNotifier",
    },

    onReady = function(self)
        self:CreateAnchorFrame()
        self:ApplySettings()
    end,
})

-- addon.db is auto-wired by BazCore:CreateDBProxy() in RegisterAddon

---------------------------------------------------------------------------
-- Style constants
---------------------------------------------------------------------------

addon.STYLE = {
    ICON_SIZE       = 70,
    PADDING         = 6,
    MAX_TEXT_W      = 300,
    SLIDE_TIME      = 0.3,
    SLIDE_OFFSET_Y  = 40,
    POP_TIME        = 0.2,
    POP_SCALE_MAX   = 1.2,
}

addon.MEDIA = {
    QUESTION_MARK = "Interface\\Icons\\INV_Misc_QuestionMark",
}

---------------------------------------------------------------------------
-- Anchor Frame
---------------------------------------------------------------------------

function addon:CreateAnchorFrame()
    if self.Anchor then return self.Anchor end

    local S = self.STYLE
    local f = CreateFrame("Frame", "BLN_Anchor", UIParent)
    f:SetSize(S.ICON_SIZE + S.PADDING * 2 + S.MAX_TEXT_W, S.ICON_SIZE + S.PADDING * 2)
    f:SetClampedToScreen(true)

    self.Anchor = f
    self:ApplyAnchorPosition()
    self:ApplyAnchorScale()

    BazCore:RegisterEditModeFrame(f, {
        label = "BazLootNotifier",
        addonName = ADDON_NAME,
        positionKey = "position",
        defaultPosition = { x = 0, y = 150 },

        settings = {
            { type = "slider", key = "scale", label = "Popup Scale", section = "Appearance",
              min = 50, max = 250, step = 5,
              format = function(v) return math.floor(v + 0.5) .. "%" end,
              get = function() return (addon:GetSetting("scale") or 1.0) * 100 end,
              set = function(v)
                  addon:SetSetting("scale", v / 100)
                  addon:ApplyAnchorScale()
              end },
            { type = "slider", key = "displayTime", label = "Display Time", section = "Appearance",
              min = 3, max = 50, step = 1,
              format = function(v) return string.format("%.1fs", v / 10) end,
              get = function() return (addon:GetSetting("displayTime") or 1.5) * 10 end,
              set = function(v) addon:SetSetting("displayTime", v / 10) end },
            { type = "slider", key = "fadeTime", label = "Fade Time", section = "Appearance",
              min = 2, max = 50, step = 1,
              format = function(v) return string.format("%.1fs", v / 10) end,
              get = function() return (addon:GetSetting("fadeTime") or 0.6) * 10 end,
              set = function(v) addon:SetSetting("fadeTime", v / 10) end },
            { type = "checkbox", key = "enablePop", label = "Pop Animation", section = "Appearance",
              get = function() return addon:GetSetting("enablePop") ~= false end,
              set = function(v) addon:SetSetting("enablePop", v) end },
            { type = "checkbox", key = "playSound", label = "Play Sound", section = "Appearance",
              get = function() return addon:GetSetting("playSound") ~= false end,
              set = function(v) addon:SetSetting("playSound", v) end },
            { type = "nudge", section = "Appearance" },

            { type = "checkbox", key = "anchorToCursor", label = "Anchor to Cursor", section = "Behavior",
              get = function() return addon:GetSetting("anchorToCursor") or false end,
              set = function(v) addon:SetSetting("anchorToCursor", v) end },
            { type = "checkbox", key = "onlyMyLoot", label = "Only My Loot", section = "Behavior",
              get = function() return addon:GetSetting("onlyMyLoot") ~= false end,
              set = function(v) addon:SetSetting("onlyMyLoot", v) end },
            { type = "checkbox", key = "hideDefaultLoot", label = "Hide Blizzard Loot", section = "Behavior",
              get = function() return addon:GetSetting("hideDefaultLoot") or false end,
              set = function(v) addon:SetSetting("hideDefaultLoot", v) end },

            { type = "checkbox", key = "showItems", label = "Items", section = "Filters",
              get = function() return addon:GetSetting("showItems") ~= false end,
              set = function(v) addon:SetSetting("showItems", v) end },
            { type = "checkbox", key = "showCurrency", label = "Currency", section = "Filters",
              get = function() return addon:GetSetting("showCurrency") ~= false end,
              set = function(v) addon:SetSetting("showCurrency", v) end },
            { type = "checkbox", key = "showMoney", label = "Money", section = "Filters",
              get = function() return addon:GetSetting("showMoney") ~= false end,
              set = function(v) addon:SetSetting("showMoney", v) end },
            { type = "checkbox", key = "showRep", label = "Reputation", section = "Filters",
              get = function() return addon:GetSetting("showRep") ~= false end,
              set = function(v) addon:SetSetting("showRep", v) end },
            { type = "checkbox", key = "showXP", label = "XP / Honor", section = "Filters",
              get = function() return addon:GetSetting("showXP") or false end,
              set = function(v) addon:SetSetting("showXP", v) end },
            { type = "checkbox", key = "showSkills", label = "Skills", section = "Filters",
              get = function() return addon:GetSetting("showSkills") or false end,
              set = function(v) addon:SetSetting("showSkills", v) end },
            { type = "slider", key = "minQuality", label = "Min Quality", section = "Filters",
              min = 0, max = 5, step = 1,
              get = function() return addon:GetSetting("minQuality") or 1 end,
              set = function(v) addon:SetSetting("minQuality", v) end },
        },

        actions = {
            { label = "Reset Position", builtin = "resetPosition" },
            { label = "Preview Popup", onClick = function() addon:TestPopup() end },
        },
    })

    return f
end

function addon:ApplyAnchorPosition()
    if not self.Anchor then return end
    self.Anchor:ClearAllPoints()
    local pos = self:GetSetting("position")
    if pos and pos.x and pos.y then
        -- Position saved by EditMode as screen-pixel offset from UIParent center
        local ux, uy = UIParent:GetCenter()
        local ues = UIParent:GetEffectiveScale()
        local es = self.Anchor:GetEffectiveScale()
        self.Anchor:SetPoint("CENTER", UIParent, "BOTTOMLEFT", (pos.x + ux * ues) / es, (pos.y + uy * ues) / es)
    else
        -- Default position
        self.Anchor:SetPoint("CENTER", UIParent, "CENTER", 0, 150)
    end
end

function addon:ApplyAnchorScale()
    if not self.Anchor then return end
    local f = self.Anchor
    local scale = math.max(0.5, math.min(2.0, self:GetSetting("scale") or 1.0))

    local cx, cy = f:GetCenter()
    local oldScale = f:GetScale()
    if cx and cy then
        cx = cx * oldScale
        cy = cy * oldScale
    end

    f:SetScale(scale)

    if cx and cy then
        f:ClearAllPoints()
        f:SetPoint("CENTER", UIParent, "BOTTOMLEFT", cx / scale, cy / scale)
    end
end

function addon:ApplySettings()
    if not self.Anchor then return end
    self:ApplyAnchorPosition()
    self:ApplyAnchorScale()
end

function addon:ResetPosition()
    self:SetSetting("position", nil)
    self:ApplyAnchorPosition()
end

function addon:TestPopup()
    self:CreateLootPopup("Legendary Item!",
        "|cffa335ee|Hitem:19019::::::::70:66::::::|h[Thunderfury, Blessed Blade of the Windseeker]|h|r",
        135349, 5, 1)
end

---------------------------------------------------------------------------
-- Options (BazCore OptionsPanel)
---------------------------------------------------------------------------

local qualities = {
    [0] = "|cff9d9d9dPoor|r",
    [1] = "|cffffffffCommon|r",
    [2] = "|cff1eff00Uncommon|r",
    [3] = "|cff0070ddRare|r",
    [4] = "|cffa335eeEpic|r",
    [5] = "|cffff8000Legendary|r",
}

local function GetLandingPage()
    return BazCore:CreateLandingPage("BazLootNotifier", {
        subtitle = "Animated loot popups",
        description = "Animated loot popup notifications with rarity colors, scaling, and fade timing. " ..
            "Shows items, currency, gold, reputation, XP, and skill gains as sleek popup cards.",
        features = "Popups clump duplicate items and stack values. " ..
            "Rarity-colored borders match WoW item quality. " ..
            "Drag to reposition via Edit Mode. " ..
            "Filter by loot type (items, currency, gold, rep, XP, skills).",
        guide = {
            { "Positioning", "Enter Edit Mode to drag the popup anchor" },
            { "Filtering", "Open Settings to choose which loot types to show" },
            { "Preview", "Use |cff00ff00/bln test|r to see a sample popup" },
        },
        commands = {
            { "/bln", "Open settings" },
            { "/bln test", "Show a test popup" },
        },
    })
end

local function GetSettingsPage()
    return {
        name = "Settings",
        type = "group",
        args = {
            intro = {
                order = 0.1,
                type = "lead",
                text = "How loot, XP, rep, and currency popups look on screen. Per-category on/off lives further down.",
            },
            bncHandoffNote = {
                order = 0.2,
                type = "note",
                style = "info",
                text = "When BazNotificationCenter is installed, BLN automatically defers matching categories to BNC. You won't see duplicate popups.",
            },
            -- Appearance
            appearanceHeader = {
                order = 1,
                type = "header",
                name = "Appearance",
            },
            scale = {
                order = 2,
                type = "range",
                name = "Popup Scale",
                min = 0.5, max = 2.5, step = 0.05,
                get = function() return addon:GetSetting("scale") or 1.0 end,
                set = function(_, val)
                    addon:SetSetting("scale", val)
                    addon:ApplyAnchorScale()
                end,
            },
            displayTime = {
                order = 3,
                type = "range",
                name = "Display Time (sec)",
                min = 0.3, max = 5, step = 0.1,
                get = function() return addon:GetSetting("displayTime") or 1.5 end,
                set = function(_, val) addon:SetSetting("displayTime", val) end,
            },
            fadeTime = {
                order = 4,
                type = "range",
                name = "Fade Time (sec)",
                min = 0.2, max = 5, step = 0.1,
                get = function() return addon:GetSetting("fadeTime") or 0.6 end,
                set = function(_, val) addon:SetSetting("fadeTime", val) end,
            },
            enablePop = {
                order = 5,
                type = "toggle",
                name = "Enable Pop Animation",
                desc = "Animate popup scaling on appear",
                get = function() return addon:GetSetting("enablePop") ~= false end,
                set = function(_, val) addon:SetSetting("enablePop", val) end,
            },
            playSound = {
                order = 6,
                type = "toggle",
                name = "Play Sound",
                desc = "Play a sound when loot pops up",
                get = function() return addon:GetSetting("playSound") ~= false end,
                set = function(_, val) addon:SetSetting("playSound", val) end,
            },

            -- Behavior
            behaviorHeader = {
                order = 10,
                type = "header",
                name = "Behavior",
            },
            anchorToCursor = {
                order = 12,
                type = "toggle",
                name = "Anchor to Cursor",
                desc = "Popups appear at your mouse cursor instead of the fixed anchor position",
                get = function() return addon:GetSetting("anchorToCursor") or false end,
                set = function(_, val) addon:SetSetting("anchorToCursor", val) end,
            },
            onlyMyLoot = {
                order = 13,
                type = "toggle",
                name = "Only My Loot",
                desc = "Only show loot you pick up, not party member loot",
                get = function() return addon:GetSetting("onlyMyLoot") ~= false end,
                set = function(_, val) addon:SetSetting("onlyMyLoot", val) end,
            },
            hideDefaultLoot = {
                order = 14,
                type = "toggle",
                name = "Hide Blizzard Loot Window",
                desc = "Automatically close the default loot frame",
                get = function() return addon:GetSetting("hideDefaultLoot") or false end,
                set = function(_, val) addon:SetSetting("hideDefaultLoot", val) end,
            },

            -- Filters
            filterHeader = {
                order = 20,
                type = "header",
                name = "Loot Filters",
            },
            showItems = {
                order = 21,
                type = "toggle",
                name = "Items",
                get = function() return addon:GetSetting("showItems") ~= false end,
                set = function(_, val) addon:SetSetting("showItems", val) end,
            },
            showCurrency = {
                order = 22,
                type = "toggle",
                name = "Currency",
                get = function() return addon:GetSetting("showCurrency") ~= false end,
                set = function(_, val) addon:SetSetting("showCurrency", val) end,
            },
            showMoney = {
                order = 23,
                type = "toggle",
                name = "Money",
                get = function() return addon:GetSetting("showMoney") ~= false end,
                set = function(_, val) addon:SetSetting("showMoney", val) end,
            },
            showRep = {
                order = 24,
                type = "toggle",
                name = "Reputation",
                get = function() return addon:GetSetting("showRep") ~= false end,
                set = function(_, val) addon:SetSetting("showRep", val) end,
            },
            showXP = {
                order = 25,
                type = "toggle",
                name = "XP / Honor",
                get = function() return addon:GetSetting("showXP") or false end,
                set = function(_, val) addon:SetSetting("showXP", val) end,
            },
            showSkills = {
                order = 26,
                type = "toggle",
                name = "Skills",
                get = function() return addon:GetSetting("showSkills") or false end,
                set = function(_, val) addon:SetSetting("showSkills", val) end,
            },
            minQuality = {
                order = 27,
                type = "range",
                name = "Minimum Item Quality",
                min = 0, max = 5, step = 1,
                get = function() return addon:GetSetting("minQuality") or 1 end,
                set = function(_, val) addon:SetSetting("minQuality", val) end,
            },

            -- Actions
            actionsHeader = {
                order = 90,
                type = "header",
                name = "",
            },
            resetPos = {
                order = 91,
                type = "execute",
                name = "Reset Position",
                func = function() addon:ResetPosition(); addon:Print("Position reset.") end,
            },
            testPopup = {
                order = 92,
                type = "execute",
                name = "Preview Popup",
                func = function() addon:TestPopup() end,
            },
        },
    }
end

-- Register options after BazCore is ready
addon.config.onLoad = function(self)
    -- Landing page (main)
    BazCore:RegisterOptionsTable(ADDON_NAME, GetLandingPage)
    BazCore:AddToSettings(ADDON_NAME, "BazLootNotifier")

    -- Settings subcategory
    BazCore:RegisterOptionsTable(ADDON_NAME .. "-Settings", GetSettingsPage)
    BazCore:AddToSettings(ADDON_NAME .. "-Settings", "Settings", ADDON_NAME)
end
