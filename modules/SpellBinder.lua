--[[
    ElvUI_SpellBinder
    Copyright (C) Nîne-Shu'halo, All rights reserved.
]]--

-- ElvUI
local E, L, V, P, G = unpack(ElvUI) -- Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local SB = E:NewModule("SpellBinder", "AceHook-3.0", "AceEvent-3.0", "AceTimer-3.0")
local C = E:GetModule("SpellBinder_Config")

local addonName, addon = ...
local CCFrames = {}
local HCFrames = {}

local TooltipFrames = ClickCastFrames or {}

local GroupHeader = CreateFrame("Frame", addonName .. "HeaderFrame", UIParent,
    "SecureHandlerBaseTemplate, SecureHandlerAttributeTemplate")

local ButtonMap = {
    ["LeftButton"] = "Left",
    ["RightButton"] = "Right",
    ["MiddleButton"] = "Middle",
    ["Button4"] = "Button4",
    ["Button5"] = "Button5",
    ["Button6"] = "Button6",
    ["Button7"] = "Button7",
    ["Button8"] = "Button8",
    ["Button9"] = "Button9",
    ["Button10"] = "Button10",
    ["Button11"] = "Button11",
    ["Button12"] = "Button12",
    ["Button13"] = "Button13",
    ["Button14"] = "Button14",
    ["Button15"] = "Button15",
}

local ButtonToButtonAttribute = {
    ["LeftButton"] = "type1",
    ["RightButton"] = "type2",
    ["MiddleButton"] = "type3",
    ["Button4"] = "type4",
    ["Button5"] = "type5",
    ["Button6"] = "type6",
    ["Button7"] = "type7",
    ["Button8"] = "type8",
    ["Button9"] = "type9",
    ["Button10"] = "type10",
    ["Button11"] = "type11",
    ["Button12"] = "type12",
    ["Button13"] = "type13",
    ["Button14"] = "type14",
    ["Button15"] = "type15",
}

local ButtonToSpellAttribute = {
    ["type1"] = "spell1",
    ["type2"] = "spell2",
    ["type3"] = "spell3",
    ["type4"] = "spell4",
    ["type5"] = "spell5",
    ["type6"] = "spell6",
    ["type7"] = "spell7",
    ["type8"] = "spell8",
    ["typ9"] = "spell9",
    ["type10"] = "spell10",
    ["type11"] = "spell11",
    ["type12"] = "spell12",
    ["type13"] = "spell13",
    ["type14"] = "spell14",
    ["type15"] = "spell15",
}

local ButtonOrder = { "LeftButton", "MiddleButton", "RightButton", "Button4", "Button5" }

function SB:ShouldPutSpellInTooltip(spell, btext)
    local alt = IsAltKeyDown()
    local shift = IsShiftKeyDown()
    local ctrl = IsControlKeyDown()

    -- Break up the binding string into constituants
    local bpart, binding = "", btext
    local bAlt, bCtrl, bShift, bButton = false, false, false, ""
    local count = 0
    while string.find(binding, "+", 0, true) do
        bpart, binding = strsplit("+", binding, 2)
        if bpart == "Alt" then bAlt = true
        elseif bpart == "Ctrl" then bCtrl = true
        elseif bpart == "Shift" then bShift = true end
    end
    bButton = binding

    if (alt ~= bAlt) or (shift ~= bShift) or (ctrl ~= bCtrl) then return nil end

    local usable, nomana = IsUsableSpell(spell)
    -- Forbearance causes a false / false return for Lay on Hands.  It really shouldn't...
    if (usable == false) and (nomana == false) then return nil end

    return bButton
end

function SB:GetAttributeString(binding)
        -- Break up the binding string into constituants
    local bpart
    local alt, ctrl, shift, button = false, false, false, ""
    local count = 0
    while string.find(binding, "+", 0, true) do
        bpart, binding = strsplit("+", binding, 2)
        if bpart == "Alt" then alt = true
        elseif bpart == "Ctrl" then ctrl = true
        elseif bpart == "Shift" then shift = true end
        count = count + 1
        if count >= 5 then break end
    end
    button = ButtonToButtonAttribute[binding]

    local fmt = "%s%s%s"
    local prefix = fmt:format(
        (alt == true and "alt-" or ""),
        (ctrl == true and "ctrl-" or ""),
        (shift == true and "shift-" or ""))
    return prefix, button
end

local TooltipUpdateTimer = nil
function SB:SB_OnTooltipSetUnit(t)
    if not E.db.SpellBinder.SpellBinderEnabled then return end
    if not E.db.SpellBinder.ModifyTooltips then return end

    if not TooltipUpdateTimer then
        TooltipUpdateTimer = self:ScheduleRepeatingTimer("UpdateTooltip", 0.1)
    end

    local hoverFrame = GetMouseFocus()
    if not addon:TableContains(TooltipFrames, hoverFrame) then return end

    local ttLines = {}

    --for k, v in pairs(E.db.SpellBinder.ActiveBindings) do
    for _, v in pairs(addon.ActiveBindingsTable) do
        local button = SB:ShouldPutSpellInTooltip(v.ability, v.binding)
        if button then
            -- Get spell cooldown info
            local start, duration, _, _ = GetSpellCooldown(v.ability)
            local lColor = {0.2, 0.2, 0.2}
            local rColor = {0.5, 0.2, 0.8}

            local leftText = ButtonMap[button]..": "..v.ability
            -- TODO: Handle Costs other than mana
            if start > 0 and duration > 0 then
                -- Spell is on cooldown, append cooldown to left text
                lColor[1] = 0.8
                local cd = start + duration - GetTime()
                if (cd > 5) then
                    cd = cd - (cd % 1) -- bad rounding.  Don't care
                else
                    cd = string.format("%.2f", cd)
                end

                leftText = leftText .. " (" .. cd .. "s)"
            else
                lColor[2] = 0.8
            end

            -- Get spell costs
            local costs = GetSpellPowerCost(v.ability)

            local rightText
            if costs[1] and costs[1].cost then
                local costString = string.format("%5s Mana", tostring(costs[1].cost))
                rightText = "-" .. costString
            end

            leftText = string.format("%-20s", leftText)

            ttLines[button] = {}
            ttLines[button].lefttext = leftText or "";
            ttLines[button].lcolor = lColor;
            ttLines[button].righttext = rightText or "";
            ttLines[button].rcolor = rColor;
            --GameTooltip:AddDoubleLine(leftText, rightText, color[1], color[2], color[3], 0.5,0.2,0.8)
        end
    end

    for _, v in ipairs(ButtonOrder) do
        for i, j in pairs(ttLines) do
            if i == v then
                local lc = j.lcolor
                local rc = j.rcolor
                GameTooltip:AddDoubleLine(j.lefttext, j.righttext, lc[1], lc[2], lc[3], rc[1], rc[2], rc[3])
                do break end
            end
        end
    end
end

--------- ACTUAL CLICK CASTING STUFF ----------

function SB:UpdateRegisteredClicks(button)
    local direction = "AnyUp"

    if button then
        button:RegisterForClicks(direction)
        button:EnableMouseWheel(true)
        return
    end

    for button in pairs(CCFrames) do
        button:RegisterForClicks(direction)
        button:EnableMouseWheel(true)
    end

    for button in pairs(hcframes) do
        button:RegisterForClicks(direction)
        button:EnableMouseWheel(true)
    end
end

function SB:GetClickAttributes()
    local add = {
        "local setupButton = self:GetFrameRef('sbsetup_button')",
        "local button = setupButton or self"
    }
    local rem = {
        "local setupButton = self:GetFrameRef('sbsetup_button')",
        "local button = setupButton or self"
    }

    -- Apply all currently active bindings
    --for k, v in pairs(E.db.SpellBinder.ActiveBindings) do
    for k, v in pairs(addon.ActiveBindingsTable) do
        local prefix, button = SB:GetAttributeString(v.binding)
        local spellAttr = ButtonToSpellAttribute[button]

        if v.type == "spell" then
            if prefix == "" and button == "type1" then
                rem[#rem + 1] = "button:SetAttribute('type1', 'target')"
                rem[#rem + 1] = "button:SetAttribute('spell1', 'nil')"
            elseif prefix == "" and button == "type2" then
                rem[#rem + 1] = "button:SetAttribute('type2', 'togglemenu')"
                rem[#rem + 1] = "button:SetAttribute('spell2', 'nil')"
            else
                rem[#rem + 1] = "button:SetAttribute('" .. prefix .. button .. "', 'nil')"
                rem[#rem + 1] = "button:SetAttribute('" .. prefix .. spellAttr .. "', 'nil')"
            end

            add[#add + 1] = "button:SetAttribute('" .. prefix .. button .. "', 'spell')"
            add[#add + 1] = "button:SetAttribute('" .. prefix .. spellAttr .. "', '" .. v.ability .. "')"
        elseif v.type == "command" then
            if k == "ASSIST" then
                add[#add + 1] = "button:SetAttribute('" .. prefix .. button .. "', 'assist')"
                rem[#rem + 1] = "button:SetAttribute('" .. prefix .. button .. "', 'nil')"
            elseif k == "FOCUS" then
                add[#add + 1] = "button:SetAttribute('" .. prefix .. button .. "', 'focus')"
                rem[#rem + 1] = "button:SetAttribute('" .. prefix .. button .. "', 'nil')"
            elseif k == "TARGET" then
                add[#add + 1] = "button:SetAttribute('" .. prefix .. button .. "', 'target')"
                rem[#rem + 1] = "button:SetAttribute('type1', 'target')"
            elseif k == "MENU" then
                add[#add + 1] = "button:SetAttribute('" .. prefix .. button .. "', 'togglemenu')"
                rem[#rem + 1] = "button:SetAttribute('type2', 'togglemenu')"
            end
        end
    end

    return table.concat(add, "\n"), table.concat(rem, "\n")
end

function addon:UpdateAllAttributes()
    if not E.db.SpellBinder.SpellBinderEnabled then return end

    -- Remove all currently active bindings
    addon:DisableClicks()

    -- Set up new clicks
    local setup, remove = SB:GetClickAttributes()
    GroupHeader:SetAttribute("setup_clicks", setup)
    GroupHeader:SetAttribute("remove_clicks", remove)

    addon:EnableClicks()
end

function SB:RegisterFrame(button)
    CCFrames[button] = true

    SB:UpdateRegisteredClicks(button)

    -- TODO:  Figure these out
    --GroupHeader:WrapScript(button, "OnEnter", GroupHeader:GetAttribute("setup_onenter"))
    --GroupHeader:WrapScript(button, "OnLeave", GroupHeader:GetAttribute("setup_onleave"))

    if E.db.SpellBinder.SpellBinderEnabled then
        GroupHeader:SetFrameRef("sbsetup_button", button)
        GroupHeader:Execute(GroupHeader:GetAttribute("setup_clicks"), button)
    end
end

function SB:UnregisterFrame(button)
    GroupHeader:SetFrameRef("sbsetup_button", button)
    GroupHeader:Execute(GroupHeader:GetAttribute("remove_clicks"), button)

    CCFrames[button] = nil
end

function addon:EnableClicks()
    for k, v in pairs(CCFrames) do
        if v ~= nil and v ~= false then
            GroupHeader:SetFrameRef("sbsetup_button", k)
            GroupHeader:Execute(GroupHeader:GetAttribute("setup_clicks"), k)
        end
    end
end

function addon:DisableClicks()
    for k, v in pairs(CCFrames) do
        if v ~= nil and v ~= false then
            GroupHeader:SetFrameRef("sbsetup_button", k)
            GroupHeader:Execute(GroupHeader:GetAttribute("remove_clicks"), k)
        end
    end
end

--------- MAIN ----------

function SB:UpdateBindingTables()
    C:UpdateActiveBindings()
    C:UpdateHealingSpellSelect()
    C:UpdateOtherSpellSelect()
    C:UpdateItemTable()
end

function SB:OnPlayerEnterWorld()
    local _, englishClass, _ = UnitClass("player")
    addon.PlayerClass = englishClass or "None"

    if E.db.SpellBinder.SpecBasedBindings then
        local currentSpec = GetSpecialization()
        local _, playerSpec = GetSpecializationInfo(currentSpec)
        addon.PlayerSpec = playerSpec or "None"
        if E.db.SpellBinder.ActiveSpecBindings[playerSpec] == nil then
            E.db.SpellBinder.ActiveSpecBindings[playerSpec] = {}
        end
        addon.ActiveBindingsTable = E.db.SpellBinder.ActiveSpecBindings[playerSpec]
    end

    --C_Timer.After(10, function() SB:UpdateBindingTables() end)
    SB:UpdateBindingTables()
    addon:DisableClicks()
    local setup, remove = SB:GetClickAttributes()
    GroupHeader:SetAttribute("setup_clicks", setup)
    GroupHeader:SetAttribute("remove_clicks", remove)
    addon:EnableClicks()
end

function SB:OnPlayerLevelUp()
    SB:UpdateBindingTables()
end

function SB:OnPlayerSpecializationChanged()
    addon.ActiveBindingsTable = E.db.SpellBinder.ActiveBindings
    if E.db.SpellBinder.SpecBasedBindings then
        local currentSpec = GetSpecialization()
        local _, playerSpec = GetSpecializationInfo(currentSpec)
        addon.PlayerSpec = playerSpec or "None"
        if E.db.SpellBinder.ActiveSpecBindings[playerSpec] == nil then
            E.db.SpellBinder.ActiveSpecBindings[playerSpec] = {}
        end
        addon.ActiveBindingsTable = E.db.SpellBinder.ActiveSpecBindings[playerSpec]
    end

    SB:UpdateBindingTables()
    addon:DisableClicks()
    local setup, remove = SB:GetClickAttributes()
    GroupHeader:SetAttribute("setup_clicks", setup)
    GroupHeader:SetAttribute("remove_clicks", remove)
    addon:EnableClicks()
end

function SB:OnPlayerInventoryChanged()
    -- TODO: Update items available for binding
end

function SB:UpdateTooltip(_, key)
    if UnitExists("mouseover") then
        GameTooltip:SetUnit('mouseover')
    end
end


function SB:Initialize()
    C:InsertOptions()

    if addon.ActiveBindingsTable == nil then
        addon.ActiveBindingsTable = E.db.SpellBinder.ActiveBindings
    end

    local setup, remove = SB:GetClickAttributes()
    GroupHeader:SetAttribute("setup_clicks", setup)
    GroupHeader:SetAttribute("remove_clicks", remove)

    local oldClickCastFrames = ClickCastFrames
    ClickCastFrames = setmetatable({}, {__newindex = function(_, k, _)
        if v == nil or v == false then
            SB:UnregisterFrame(k)
        else
            SB:RegisterFrame(k)
        end
    end})

    if oldClickCastFrames then
        for frame, options in pairs(oldClickCastFrames) do
            self:RegisterFrame(frame, options)
        end
    end
    addon:EnableBlizzardFrames()

    self:RegisterEvent("MODIFIER_STATE_CHANGED", "UpdateTooltip"); -- event, key, state
    self:RegisterEvent("PLAYER_LOGIN", "OnPlayerEnterWorld");
    self:RegisterEvent("PLAYER_LEVEL_UP", "OnPlayerLevelUp");
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnPlayerEnterWorld");
    self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", "OnPlayerSpecializationChanged");
    self:RegisterEvent("UNIT_INVENTORY_CHANGED", "OnPlayerInventoryChanged");

    self:SecureHookScript(GameTooltip, 'OnTooltipSetUnit', 'SB_OnTooltipSetUnit')
    self:SecureHookScript(GameTooltip, 'OnHide', function()
        self:CancelTimer(TooltipUpdateTimer)
        TooltipUpdateTimer = nil
    end)

    addon:RegisterMessage("SPEC_CHANGED", function() SB:OnPlayerSpecializationChanged() end)
end

E:RegisterModule(SB:GetName())
