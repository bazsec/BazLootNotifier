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
        locked      = true,
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
        lock = {
            desc = "Lock the anchor frame",
            handler = function()
                addon:SetLockState(true)
                addon:Print("Frame locked.")
            end,
        },
        unlock = {
            desc = "Unlock the anchor frame (drag to move)",
            handler = function()
                addon:SetLockState(false)
                addon:Print("Frame unlocked. Drag to move.")
            end,
        },
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
        icon = 133784,
    },

    onReady = function(self)
        self:CreateAnchorFrame()
        self:ApplySettings()
    end,
})

-- db compatibility proxy
local dbProxy = {}
local profileProxy = setmetatable({}, {
    __index = function(_, key)
        local sv = _G["BazLootNotifierDB"]
        if not sv then return nil end
        local profileName = BazCore:GetActiveProfile(ADDON_NAME)
        local profile = sv.profiles and sv.profiles[profileName]
        if profile then return profile[key] end
        return nil
    end,
    __newindex = function(_, key, value)
        local sv = _G["BazLootNotifierDB"]
        if not sv then return end
        local profileName = BazCore:GetActiveProfile(ADDON_NAME)
        if not sv.profiles then sv.profiles = {} end
        if not sv.profiles[profileName] then sv.profiles[profileName] = {} end
        sv.profiles[profileName][key] = value
    end,
})
dbProxy.profile = profileProxy
addon.db = dbProxy

---------------------------------------------------------------------------
-- Settings helpers
---------------------------------------------------------------------------

function addon:GetSetting(key)
    return self.db.profile[key]
end

function addon:SetSetting(key, value)
    self.db.profile[key] = value
end

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
    local f = CreateFrame("Frame", "BLN_Anchor", UIParent, "BackdropTemplate")
    f:SetSize(S.ICON_SIZE + S.PADDING * 2 + S.MAX_TEXT_W, S.ICON_SIZE + S.PADDING * 2)
    f:SetClampedToScreen(true)
    f:SetMovable(true)
    f:SetUserPlaced(false)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")

    local bg = f:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.02, 0.02, 0.02, 1.0)
    f._bg = bg

    local label = f:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    label:SetPoint("CENTER")
    label:SetText("BazLootNotifier Anchor")
    f.Label = label

    f:SetScript("OnDragStart", function(frame)
        if not self:GetSetting("locked") then frame:StartMoving() end
    end)

    f:SetScript("OnDragStop", function(frame)
        frame:StopMovingOrSizing()
        local fx, fy = frame:GetCenter()
        if not fx or not fy then return end
        local fs, us = frame:GetEffectiveScale(), UIParent:GetEffectiveScale()
        local ux, uy = UIParent:GetCenter()
        local dx = math.floor(fx - (ux * us / fs) + 0.5)
        local dy = math.floor(fy - (uy * us / fs) + 0.5)
        self:SetSetting("position", { x = dx, y = dy })
        self:ApplyAnchorPosition()
    end)

    self.Anchor = f
    return f
end

function addon:ApplyAnchorPosition()
    if not self.Anchor then return end
    self.Anchor:ClearAllPoints()
    local pos = self:GetSetting("position") or { x = 0, y = 150 }
    self.Anchor:SetPoint("CENTER", UIParent, "CENTER", pos.x, pos.y)
end

function addon:ApplyAnchorScale()
    if not self.Anchor then return end
    local scale = math.max(0.5, math.min(2.0, self:GetSetting("scale") or 1.0))
    self.Anchor:SetScale(scale)
end

function addon:ApplyLockState()
    if not self.Anchor then return end
    local locked = self:GetSetting("locked") ~= false
    self.Anchor:EnableMouse(not locked)
    self.Anchor._bg:SetShown(not locked)
    self.Anchor.Label:SetShown(not locked)
end

function addon:SetLockState(locked)
    self:SetSetting("locked", locked)
    self:ApplyLockState()
end

function addon:ApplySettings()
    if not self.Anchor then return end
    self:ApplyAnchorPosition()
    self:ApplyAnchorScale()
    self:ApplyLockState()
end

function addon:ResetPosition()
    self:SetSetting("position", { x = 0, y = 150 })
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

local function GetOptionsTable()
    return {
        name = "BazLootNotifier",
        subtitle = "Animated loot popups",
        type = "group",
        args = {
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
            locked = {
                order = 11,
                type = "toggle",
                name = "Lock Frame",
                desc = "Prevent the anchor from being dragged",
                get = function() return addon:GetSetting("locked") ~= false end,
                set = function(_, val) addon:SetLockState(val) end,
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
    BazCore:RegisterOptionsTable(ADDON_NAME, GetOptionsTable)
    BazCore:AddToSettings(ADDON_NAME, "BazLootNotifier")

    -- Profiles
    BazCore:RegisterOptionsTable(ADDON_NAME .. "-Profiles", function()
        return BazCore:GetProfileOptionsTable(ADDON_NAME)
    end)
    BazCore:AddToSettings(ADDON_NAME .. "-Profiles", "Profiles", ADDON_NAME)
end
