-- BazLootNotifier Popup
-- Frame pool, popup creation, animation

local addon = BazCore:GetAddon("BazLootNotifier")

local GetTime = GetTime
local PlaySound = PlaySound
local SOUNDKIT = SOUNDKIT
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local tremove = tremove

addon._pool = { active = {}, inactive = {} }
local activePopupsByKey = {}

---------------------------------------------------------------------------
-- Popup Frame Pool
---------------------------------------------------------------------------

local function ResetPopup(frame)
    frame:Hide()
    if frame.popupKey and activePopupsByKey then
        activePopupsByKey[frame.popupKey] = nil
    end
    frame.ItemLink = nil
    frame.popupKey = nil
    frame:ClearAllPoints()
    if addon.Anchor then
        frame:SetPoint("BOTTOM", addon.Anchor, "BOTTOM", 0, 0)
    end
end

local function CreatePopupFrame()
    local S = addon.STYLE
    local frame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    frame:SetSize(S.ICON_SIZE + S.PADDING * 2 + S.MAX_TEXT_W, S.ICON_SIZE + S.PADDING * 2)
    frame:SetClampedToScreen(true)
    frame:SetFrameStrata("HIGH")

    frame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 24,
        insets = { left = 5, right = 5, top = 5, bottom = 5 },
    })
    frame:SetBackdropColor(0.05, 0.05, 0.05, 0.9)

    frame.Icon = frame:CreateTexture(nil, "ARTWORK")
    frame.Icon:SetSize(S.ICON_SIZE - 12, S.ICON_SIZE - 12)
    frame.Icon:SetPoint("LEFT", frame, "LEFT", 12, 0)

    frame.Title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.Title:SetPoint("TOPLEFT", frame.Icon, "TOPRIGHT", 10, 0)
    frame.Title:SetPoint("RIGHT", frame, "RIGHT", -12, 0)
    frame.Title:SetJustifyH("LEFT")
    frame.Title:SetWordWrap(false)
    frame.Title:SetTextColor(1, 0.82, 0)

    frame.Text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    frame.Text:SetPoint("TOPLEFT", frame.Title, "BOTTOMLEFT", 0, -2)
    frame.Text:SetPoint("RIGHT", frame, "RIGHT", -12, 0)
    frame.Text:SetJustifyH("LEFT")
    frame.Text:SetWordWrap(true)
    frame.Text:SetMaxLines(2)

    frame:SetScript("OnShow", function()
        -- In cursor mode, don't inherit anchor scale (position is in screen space)
        if not frame.useCursorAnchor and addon.Anchor then
            frame:SetScale(addon.Anchor:GetScale())
        end
    end)

    ResetPopup(frame)
    return frame
end

local function AcquirePopup()
    local frame = tremove(addon._pool.inactive)
    if not frame then frame = CreatePopupFrame() end
    table.insert(addon._pool.active, frame)
    frame:Show()
    return frame
end

local function ReleasePopup(frame)
    for i, f in ipairs(addon._pool.active) do
        if f == frame then
            table.remove(addon._pool.active, i)
            break
        end
    end
    ResetPopup(frame)
    table.insert(addon._pool.inactive, frame)
end

---------------------------------------------------------------------------
-- Popup Content
---------------------------------------------------------------------------

local function SetPopupContent(frame, titleText, textValue, texture, quality, quantity)
    frame.Icon:SetTexture(texture or addon.MEDIA.QUESTION_MARK)
    frame.Title:SetText(titleText or "You receive")

    local name = textValue or "Unknown Item"
    if quantity and quantity > 1 then
        name = name .. (" x%d"):format(quantity)
    end

    local r, g, b = 1, 1, 1
    if quality and type(quality) == "number" and quality >= 0 then
        r, g, b = GetItemQualityColor(quality)
    end

    frame.Text:SetText(name)
    frame.Text:SetTextColor(r, g, b)
    frame:SetBackdropColor(0.05, 0.05, 0.05, 0.9)
    frame:SetBackdropBorderColor(r, g, b, 1)
end

local function FetchItemInfoAsync(itemLink, cb)
    local name, _, quality, _, _, _, _, _, _, texture = GetItemInfo(itemLink)
    if name and texture then
        cb(texture, quality)
        return
    end
    cb(addon.MEDIA.QUESTION_MARK, 1)
    local listener = CreateFrame("Frame")
    listener:RegisterEvent("GET_ITEM_INFO_RECEIVED")
    listener:SetScript("OnEvent", function(_, _, itemID, success)
        if not success then return end
        local fetchedLink = select(2, GetItemInfo(itemID))
        if fetchedLink == itemLink then
            local _, _, q, _, _, _, _, _, _, tex = GetItemInfo(itemLink)
            cb(tex or addon.MEDIA.QUESTION_MARK, q or 1)
            listener:UnregisterAllEvents()
        end
    end)
end

---------------------------------------------------------------------------
-- Animation
---------------------------------------------------------------------------

local function Popup_OnUpdate(self, elapsed)
    local t = GetTime() - self.animStartTime
    local S = addon.STYLE

    local slideDur = S.SLIDE_TIME
    local display = self.animDisplayTime
    local fadeDur = self.animFadeTime
    local totalTime = self.animTotalTime
    local yOffset = self.animYOffset

    -- Pop animation
    if addon:GetSetting("enablePop") then
        local baseScale = addon:GetSetting("scale") or 1.0
        local popTime = S.POP_TIME
        if t <= popTime then
            local p = t / popTime
            local s
            if p < 0.5 then
                s = 0.8 + (p * 2) * (S.POP_SCALE_MAX - 0.8)
            else
                s = S.POP_SCALE_MAX - ((p - 0.5) * 2) * (S.POP_SCALE_MAX - 1.0)
            end
            self:SetScale(s * baseScale)
        else
            self:SetScale(baseScale)
        end
    end

    -- Get anchor position in the popup's own coordinate space
    local anchorX, anchorY
    if self.useCursorAnchor then
        local cx, cy = GetCursorPosition()
        local effectiveScale = self:GetEffectiveScale()
        anchorX = cx / effectiveScale
        anchorY = cy / effectiveScale
    end

    -- Cursor mode: small offset above cursor, no big slide
    local cursorOffY = 30

    if t <= slideDur then
        local p = t / slideDur
        self:SetAlpha(p)
        if self.useCursorAnchor then
            self:SetPoint("CENTER", UIParent, "BOTTOMLEFT", anchorX, anchorY + cursorOffY + yOffset)
        else
            self:SetPoint("BOTTOM", addon.Anchor, "BOTTOM", 0, yOffset + (p * S.SLIDE_OFFSET_Y))
        end
    elseif t <= slideDur + display then
        self:SetAlpha(1)
        if self.useCursorAnchor then
            self:SetPoint("CENTER", UIParent, "BOTTOMLEFT", anchorX, anchorY + cursorOffY + yOffset)
        else
            self:SetPoint("BOTTOM", addon.Anchor, "BOTTOM", 0, yOffset + S.SLIDE_OFFSET_Y)
        end
    elseif t <= totalTime then
        local p = (t - slideDur - display) / fadeDur
        self:SetAlpha(1 - p)
        if self.useCursorAnchor then
            self:SetPoint("CENTER", UIParent, "BOTTOMLEFT", anchorX, anchorY + cursorOffY + yOffset + (p * 20))
        else
            self:SetPoint("BOTTOM", addon.Anchor, "BOTTOM", 0, yOffset + S.SLIDE_OFFSET_Y + (p * 20))
        end
    else
        self:SetAlpha(0)
        self:SetScript("OnUpdate", nil)
        ReleasePopup(self)
        addon:RepositionActivePopups()
    end
end

---------------------------------------------------------------------------
-- Public API
---------------------------------------------------------------------------

function addon:UpdateOrCreatePopup(key, title, itemLink, texture, quality, quantity)
    -- If a popup with this key is already visible, update it in place
    if key and activePopupsByKey[key] then
        local f = activePopupsByKey[key]
        if f:IsShown() then
            SetPopupContent(f, title, itemLink, texture, quality, quantity)
            -- Restart animation (repop)
            f.animStartTime = GetTime()
            if self:GetSetting("playSound") then
                PlaySound(SOUNDKIT.UI_EPICLOOT_TOAST or 31578)
            end
            return
        else
            activePopupsByKey[key] = nil
        end
    end

    self:CreateLootPopup(title, itemLink, texture, quality, quantity, key)
end

function addon:CreateLootPopup(title, itemLink, texture, quality, quantity, popupKey)
    if not self.Anchor then self:CreateAnchorFrame() end
    local f = AcquirePopup()
    f.ItemLink = itemLink
    f.popupKey = popupKey

    if popupKey then
        activePopupsByKey[popupKey] = f
    end

    if self:GetSetting("playSound") then
        PlaySound(SOUNDKIT.UI_EPICLOOT_TOAST or 31578)
    end

    local display = self:GetSetting("displayTime") or 1.5
    local fadeDur = self:GetSetting("fadeTime") or 0.6
    local slideDur = self.STYLE.SLIDE_TIME

    f:ClearAllPoints()

    -- Anchor to cursor or fixed anchor
    if self:GetSetting("anchorToCursor") then
        f.useCursorAnchor = true
        local popupScale = self:GetSetting("scale") or 1.0
        f:SetScale(popupScale)
        local cx, cy = GetCursorPosition()
        local effectiveScale = popupScale * UIParent:GetEffectiveScale()
        f:SetPoint("CENTER", UIParent, "BOTTOMLEFT", cx / effectiveScale, cy / effectiveScale + 50)
    else
        f.useCursorAnchor = false
        f:SetPoint("BOTTOM", self.Anchor, "BOTTOM", 0, 0)
    end

    f:SetAlpha(0)
    f:Show()

    f.animStartTime = GetTime()
    f.animDisplayTime = display
    f.animFadeTime = fadeDur
    f.animTotalTime = slideDur + display + fadeDur
    f.animYOffset = 0

    f:SetScript("OnUpdate", Popup_OnUpdate)

    if (not texture or not quality) and itemLink then
        FetchItemInfoAsync(itemLink, function(tex, qual)
            SetPopupContent(f, title, itemLink, tex, qual, quantity)
        end)
    else
        SetPopupContent(f, title, itemLink, texture, quality, quantity)
    end

    self:RepositionActivePopups()
end

function addon:RepositionActivePopups()
    local S = self.STYLE
    local spacing = S.ICON_SIZE + S.PADDING * 2 + 10
    local count = #self._pool.active
    for i, frame in ipairs(self._pool.active) do
        if frame:IsShown() then
            frame.animYOffset = spacing * (count - i)
        end
    end
end
