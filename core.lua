local T, C, L, G = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales

local addon, ns=...
config = ns.config

local font1, t = C["media"].uffont, C["media"].blank

-- UnitFrames

local padding = {LEFT = 4, RIGHT = -4}
local inverse = {LEFT = "RIGHT", RIGHT = "LEFT"}

local function ShortenValue(value)
    if (value >= 1e6) then
        return ('%.2fm'):format(value / 1e6):gsub('%.?0+([km])$', '%1')
    elseif (value >= 1e4) then
        return ('%.1fk'):format(value / 1e3):gsub('%.?0+([km])$', '%1')
    else
        return value
    end
end

oUFTukui.Tags.Events['health'] = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION"
oUFTukui.Tags.Methods['health'] = function(unit)
    local min, max = UnitHealth(unit), UnitHealthMax(unit)
    local status = not UnitIsConnected(unit) and 'Offline' or UnitIsGhost(unit) and 'Ghost' or UnitIsDead(unit) and 'Dead'

    if (status) then
        return status
    else
        return ('%s / %s'):format(ShortenValue(min), ShortenValue(max))
    end
end

oUFTukui.Tags.Events['power'] = "UNIT_POWER UNIT_MAXPOWER"
oUFTukui.Tags.Methods['power'] = function(unit)
    local min, max = UnitPower(unit), UnitPowerMax(unit)
    if (min > 0 and not UnitIsDeadOrGhost(unit)) then
        return ('%s / %s'):format(ShortenValue(min), ShortenValue(max))
    end
end

local function modUf(frame, dir)
    frame.Health.value:Kill()
    frame.Power.value:Kill()

    frame.Health:Height(19)
    frame.Power:Height(18)
    frame:Height(60)

    local function setText(text, name, value, dir, pre, post)
        text[name] = T.SetFontString(text, font1, 18)
        text[name]:Point(dir, text, dir, padding[dir], 0)
        frame:Tag(text[name], value)
    end

    setText(frame.Health, 'val', '[health]', dir)
    setText(frame.Health, 'per', '[perhp]%', inverse[dir])
    setText(frame.Power, 'val', '[power]', dir)
    setText(frame.Power, 'per', '[perpp]%', inverse[dir])
end

if (C ~= nil and C["unitframes"] ~= nil and C["unitframes"]["enable"]) then
    modUf(G.UnitFrames.Player, "LEFT")
    modUf(G.UnitFrames.Target, "RIGHT")

    if T.level ~= MAX_PLAYER_LEVEL then
        G.UnitFrames.Player.Experience:SetScript("OnLeave", function(self) self:SetAlpha(1) end)
        G.UnitFrames.Player.Experience:SetAlpha(1)
    end
end

-- Castbar

TukuiPlayerCastBar:SetFrameLevel(10)
TukuiPlayerCastBar_Panel:SetFrameLevel(5)
TukuiPlayerCastBar_Panel:SetTemplate(TukuiPlayerCastBar_Panel, t)

--- Chat

local function ModChat(frame)
    local chat = frame:GetName()
    G.Chat[chat]:SetMinResize(T.InfoLeftRightWidth + 1, 111 + 23 + 2)

    -- set the size of chat frames
    G.Chat[chat]:Size(T.InfoLeftRightWidth + 1, 111 + 23 + 2)
    -- tell wow that we are using new size
    SetChatWindowSavedDimensions(G.Chat[chat]:GetID(), T.Scale(T.InfoLeftRightWidth + 1), T.Scale(111 + 23 + 2))
    -- save new default position and dimension
    FCF_SavePositionAndDimensions(G.Chat[chat])

    _G[chat.."EditBox"]:ClearAllPoints()
    _G[chat.."EditBox"]:Point("TOPLEFT", G.Panels.DataTextLeft, 2, -2)
    _G[chat.."EditBox"]:Point("BOTTOMRIGHT", G.Panels.DataTextLeft, -2, 2)

    _G[chat.."EditBox"]:CreateBackdrop()
    _G[chat.."EditBox"].backdrop:ClearAllPoints()
    _G[chat.."EditBox"].backdrop:SetAllPoints(G.Panels.DataTextLeft)
    _G[chat.."EditBox"].backdrop:SetFrameStrata("LOW")
    _G[chat.."EditBox"].backdrop:SetFrameLevel(1)
end

local function ModTabs(bg, frame)
    frame:Kill()
end

local function SetupChat(self)
    ModTabs(G.Panels.LeftChatBackground, G.Panels.LeftChatTabsBackground)
    ModTabs(G.Panels.RightChatBackground, G.Panels.RightChatTabsBackground)

    for i = 1, NUM_CHAT_WINDOWS do
        local frame = _G[format("ChatFrame%s", i)]
        ModChat(frame)
    end

    G.Panels.LeftDataTextToActionBarLine:Kill()
    G.Panels.RightDataTextToActionBarLine:Kill()
end

if C["chat"].enable == true then
    local DeraenChat = CreateFrame("Frame", "DeraenChat")
    DeraenChat:RegisterEvent("ADDON_LOADED")
    DeraenChat:SetScript("OnEvent", function(self, event, addon)
        if addon == "Blizzard_CombatLog" then
            self:UnregisterEvent("ADDON_LOADED")
            SetupChat(self)
        end
    end)
end
