-- BazLootNotifier Events
-- Loot, currency, money, reputation, XP, honor, skill detection

local addon = BazCore:GetAddon("BazLootNotifier")

local GetItemInfo = GetItemInfo
local C_CurrencyInfo = C_CurrencyInfo
local tonumber = tonumber

---------------------------------------------------------------------------
-- Pattern builder for localized strings
---------------------------------------------------------------------------

local function ToPattern(str)
    str = str:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1")
    str = str:gsub("%%%%s", "(.+)")
    return str
end

-- Desecretize: string.format("%s", val) strips taint in Midnight
local function Desecret(val)
    if val == nil then return nil end
    local ok, result = pcall(string.format, "%s", val)
    if ok then return result end
    return nil
end

---------------------------------------------------------------------------
-- Accumulator: clump rapid-fire events into single popups
---------------------------------------------------------------------------

local CLUMP_WINDOW = 0.3 -- seconds to wait before firing
local accumulators = {} -- [key] = { total, icon, quality, timer, label, desc }

local function AccumulatePopup(key, label, desc, icon, quality, amount)
    if not accumulators[key] then
        accumulators[key] = { total = 0, icon = icon, quality = quality, label = label, desc = desc }
    end
    local acc = accumulators[key]
    acc.total = acc.total + amount

    -- Show/update immediately using the popup key system
    addon:UpdateOrCreatePopup(key, acc.label, acc.desc, acc.icon, acc.quality, acc.total)

    -- Extend the clump window — accumulator stays alive while events keep coming
    if acc.timer then acc.timer:Cancel() end
    acc.timer = C_Timer.NewTimer(CLUMP_WINDOW + (addon:GetSetting("displayTime") or 1.5) + (addon:GetSetting("fadeTime") or 0.6), function()
        accumulators[key] = nil
    end)
end

---------------------------------------------------------------------------
-- Event handlers
---------------------------------------------------------------------------

local function OnLoot(msg)
    if not addon:GetSetting("showItems") then return end
    msg = Desecret(msg)
    if not msg then return end

    -- Self-loot patterns
    local patternSelf = ToPattern(LOOT_ITEM_SELF or "You loot: %s")
    local patternPushed = ToPattern(LOOT_ITEM_PUSHED_SELF or "You receive item: %s")
    local patternSelfMulti = ToPattern(LOOT_ITEM_SELF_MULTIPLE or "You loot: %sx%d")
    local patternPushedMulti = ToPattern(LOOT_ITEM_PUSHED_SELF_MULTIPLE or "You receive item: %sx%d")

    local isSelfLoot = msg:find(patternSelf) or msg:find(patternPushed)
        or msg:find(patternSelfMulti) or msg:find(patternPushedMulti)

    -- Only My Loot filter
    if addon:GetSetting("onlyMyLoot") and not isSelfLoot then return end

    -- If not only-my-loot mode, still need an item link
    if not isSelfLoot and not msg:match("|Hitem:") then return end

    local itemLink = msg:match("|Hitem:%d+.-|h%[.-%]|h")
    if not itemLink then return end

    local quantity = tonumber(msg:match("x(%d+)")) or 1
    local name, _, quality, _, _, _, _, _, _, texture = GetItemInfo(itemLink)

    if not name then
        C_Timer.After(0.2, function()
            local _, _, q2, _, _, _, _, _, _, t2 = GetItemInfo(itemLink)
            local minQ = addon:GetSetting("minQuality") or 1
            if q2 and q2 < minQ then return end
            AccumulatePopup("item:" .. itemLink, "You receive", itemLink, t2, q2, quantity)
        end)
    else
        local minQ = addon:GetSetting("minQuality") or 1
        if quality and quality < minQ then return end
        AccumulatePopup("item:" .. itemLink, "You receive", itemLink, texture, quality, quantity)
    end
end

local function OnCurrency(msg)
    if not addon:GetSetting("showCurrency") then return end
    msg = Desecret(msg)
    if not msg then return end

    local currencyLink = msg:match("|Hcurrency:%d+.-|h%[.-%]|h")
    if not currencyLink then return end

    local quantity = tonumber(msg:match("x(%d+)")) or 1
    local info = C_CurrencyInfo.GetCurrencyInfoFromLink(currencyLink)

    if info and info.iconFileID then
        AccumulatePopup("currency:" .. currencyLink, "Currency", currencyLink, info.iconFileID, 1, quantity)
    else
        C_Timer.After(0.2, function()
            local retry = C_CurrencyInfo.GetCurrencyInfoFromLink(currencyLink)
            if retry and retry.iconFileID then
                AccumulatePopup("currency:" .. currencyLink, "Currency", currencyLink, retry.iconFileID, 1, quantity)
            end
        end)
    end
end

local lastMoney = nil

local function OnMoneyChanged()
    if not addon:GetSetting("showMoney") then return end

    local currentMoney = GetMoney()
    if not lastMoney then lastMoney = currentMoney; return end

    local diff = currentMoney - lastMoney
    lastMoney = currentMoney

    if diff > 0 then
        -- Filter vendor/mail/trade/auction
        if (MerchantFrame and MerchantFrame:IsShown()) or
           (MailFrame and MailFrame:IsShown()) or
           (TradeFrame and TradeFrame:IsShown()) or
           (AuctionHouseFrame and AuctionHouseFrame:IsShown()) then
            return
        end
        -- Money uses custom accumulator since we need formatted string
        if not accumulators["money"] then
            accumulators["money"] = { total = 0 }
        end
        accumulators["money"].total = accumulators["money"].total + diff
        if accumulators["money"].timer then accumulators["money"].timer:Cancel() end
        accumulators["money"].timer = C_Timer.NewTimer(CLUMP_WINDOW, function()
            local moneyStr = GetMoneyString(accumulators["money"].total)
            if moneyStr and moneyStr ~= "" and moneyStr ~= "0" then
                addon:CreateLootPopup("You loot", "|cffffff00" .. moneyStr .. "|r", 133784, 1, 1)
            end
            accumulators["money"] = nil
        end)
    end
end

local function OnReputation(msg)
    if not addon:GetSetting("showRep") then return end
    msg = Desecret(msg)
    if not msg then return end
    local faction, amount = msg:match("Your reputation with (.*) increased by (%d+)")
    if faction and amount then
        AccumulatePopup("rep:" .. faction, "Reputation", faction, 132096, 1, tonumber(amount))
    end
end

local function OnXP(msg)
    if not addon:GetSetting("showXP") then return end
    msg = Desecret(msg)
    if not msg then return end
    local amount = msg:match("gain (%d+) experience")
    if amount then
        AccumulatePopup("xp", "Experience", "XP Gain", 894556, 1, tonumber(amount))
    end
end

local function OnHonor(msg)
    if not addon:GetSetting("showXP") then return end
    msg = Desecret(msg)
    if not msg then return end
    local amount = msg:match("awarded (%d+) honor") or msg:match("gain (%d+) honor")
    if amount then
        AccumulatePopup("honor", "Honor", "Honor Gain", 132486, 1, tonumber(amount))
    end
end

local function OnSkill(msg)
    if not addon:GetSetting("showSkills") then return end
    msg = Desecret(msg)
    if not msg then return end
    local skill, value = msg:match("Your skill in (.*) has increased to (%d+)")
    if skill and value then
        addon:CreateLootPopup("Skill Up", skill, 136243, 1, tonumber(value))
    end
end

local function OnLootOpened()
    if addon:GetSetting("hideDefaultLoot") then
        if LootFrame and LootFrame:IsShown() then
            LootFrame:Hide()
        end
    end
end

---------------------------------------------------------------------------
-- Register events via BazCore
---------------------------------------------------------------------------

addon:On("CHAT_MSG_LOOT", function(_, msg) OnLoot(msg) end)
addon:On("CHAT_MSG_CURRENCY", function(_, msg) OnCurrency(msg) end)
addon:On("PLAYER_MONEY", function() OnMoneyChanged() end)
addon:On("CHAT_MSG_COMBAT_FACTION_CHANGE", function(_, msg) OnReputation(msg) end)
addon:On("CHAT_MSG_COMBAT_XP_GAIN", function(_, msg) OnXP(msg) end)
addon:On("CHAT_MSG_COMBAT_HONOR_GAIN", function(_, msg) OnHonor(msg) end)
addon:On("CHAT_MSG_SKILL", function(_, msg) OnSkill(msg) end)
addon:On("LOOT_OPENED", function() OnLootOpened() end)

-- Init money tracker on login
addon:On("PLAYER_LOGIN", function()
    lastMoney = GetMoney()
end)
