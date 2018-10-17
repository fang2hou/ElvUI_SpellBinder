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

local ButtonToAttribute = {
    ["type1"] = "1",
    ["type2"] = "2",
    ["type3"] = "3",
    ["type4"] = "4",
    ["type5"] = "5",
    ["type6"] = "6",
    ["type7"] = "7",
    ["type8"] = "8",
    ["type9"] = "9",
    ["type10"] = "10",
    ["type11"] = "11",
    ["type12"] = "12",
    ["type13"] = "13",
    ["type14"] = "14",
    ["type15"] = "15",
}

local ButtonOrder = { "LeftButton", "MiddleButton", "RightButton", "Button4", "Button5" }

function SB:ShouldPutSpellInTooltip(spell, btext, type)
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
    if (type == "spell") and (usable == false) and (nomana == false) then return nil end

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
        local button = SB:ShouldPutSpellInTooltip(v.ability, v.binding, v.type)
        if button then
            -- Get cooldown info
            local start, duration = 0, 0
            if v.type == "spell" then
                start, duration, _, _ = GetSpellCooldown(v.ability)
            elseif v.type == "item" then
                start, duration, _, _ = GetItemCooldown(addon.UsableItemMap[v.ability].id)
            end

            local lColor = E.db.SpellBinder.TTAbilityColor
            local rColor = E.db.SpellBinder.TTCostColor

            local leftText = ButtonMap[button]..": "..v.ability
            if start > 0 and duration > 0 then
                -- Spell is on cooldown, append cooldown to left text
                lColor = E.db.SpellBinder.TTAbilityCDColor
                local cd = start + duration - GetTime()
                if (cd > 5) then
                    cd = cd - (cd % 1) -- bad rounding.  Don't care
                else
                    cd = string.format("%.2f", cd)
                end

                leftText = leftText .. " (" .. cd .. "s)"
            end

            -- TODO: Handle Costs other than mana
            -- Get spell costs
            local costs = GetSpellPowerCost(v.ability)
            local rightText
            if v.type == "spell" and costs[1] then
                local cost = costs[1].cost
                if cost <= 0 then
                    cost = (UnitPower("player") * (costs[1].costPercent / 100))
                    cost = cost - (cost % 1)
                    cost = "~" .. tostring(cost)
                end

                local costString = string.format("%5s Mana", tostring(cost))
                rightText = "-" .. costString
            end

            leftText = string.format("%-20s", leftText)

            ttLines[button] = {}
            ttLines[button].lefttext = leftText or "";
            ttLines[button].lcolor = lColor;
            ttLines[button].righttext = rightText or "";
            ttLines[button].rcolor = rColor;
        end
    end

    for _, v in ipairs(ButtonOrder) do
        for i, j in pairs(ttLines) do
            if i == v then
                local lc = j.lcolor
                local rc = j.rcolor
                GameTooltip:AddDoubleLine(j.lefttext, j.righttext, lc.r, lc.g, lc.b, rc.r, rc.g, rc.b)
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

    for button in pairs(HCFrames) do
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
        local attr = ButtonToAttribute[button]

        if v.type == "spell" or v.type == "item" then
            if prefix == "" and button == "type1" then
                rem[#rem + 1] = "button:SetAttribute('type1', 'target')"
                rem[#rem + 1] = "button:SetAttribute('spell1', 'nil')"
            elseif prefix == "" and button == "type2" then
                rem[#rem + 1] = "button:SetAttribute('type2', 'togglemenu')"
                rem[#rem + 1] = "button:SetAttribute('spell2', 'nil')"
            else
                rem[#rem + 1] = "button:SetAttribute('" .. prefix .. button .. "', 'nil')"
                rem[#rem + 1] = "button:SetAttribute('" .. prefix .. v.type .. attr .. "', 'nil')"
            end

            rem[#rem + 1] = "button:SetAttribute('item', 'nil')"

            add[#add + 1] = "button:SetAttribute('" .. prefix .. button .. "', '" .. v.type .. "')"
            add[#add + 1] = "button:SetAttribute('" .. prefix .. v.type .. attr .. "', \"" .. v.ability .. "\")"
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
    addon:SetHeaderAttribute("setup_clicks", setup)
    addon:SetHeaderAttribute("remove_clicks", remove)

    addon:EnableClicks()
end

function SB:RegisterFrame(button)
    if InCombatLockdown() then return end

    CCFrames[button] = true
    HCFrames[button] = true

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
    if InCombatLockdown() then return end

    GroupHeader:SetFrameRef("sbsetup_button", button)
    GroupHeader:Execute(GroupHeader:GetAttribute("remove_clicks"), button)

    CCFrames[button] = nil
    HCFrames[button] = nil
end

function addon:SetHeaderAttribute(key, val)
    if InCombatLockdown() then return end

    GroupHeader:SetAttribute(key, val);
end

function addon:EnableClicks()
    if InCombatLockdown() then return end

    for k, v in pairs(CCFrames) do
        if v ~= nil and v ~= false then
            GroupHeader:SetFrameRef("sbsetup_button", k)
            GroupHeader:Execute(GroupHeader:GetAttribute("setup_clicks"), k)
        end
    end
end

function addon:DisableClicks()
    if InCombatLockdown() then return end

    for k, v in pairs(CCFrames) do
        if v ~= nil and v ~= false then
            GroupHeader:SetFrameRef("sbsetup_button", k)
            GroupHeader:Execute(GroupHeader:GetAttribute("remove_clicks"), k)
        end
    end
end

--------- MAIN ----------

function SB:UpdateBindingTables()
    C:UpdateHealingSpellSelect()
    C:UpdateOtherSpellSelect()
    C:UpdateItemSelect()
    C:UpdateActiveBindings()
end

function SB:OnInspectReady()
    local _, englishClass, _ = UnitClass("player")
    addon.PlayerClass = englishClass or "None"

    if E.db.SpellBinder.SpecBasedBindings then
        local currentSpec = GetSpecialization()
        local _, playerSpec = GetSpecializationInfo(currentSpec)
        addon.PlayerSpec = playerSpec or "None"
        if E.db.SpellBinder.ActiveSpecBindings[addon.PlayerClass] == nil then
            E.db.SpellBinder.ActiveSpecBindings[addon.PlayerClass] = {}
        end
        if E.db.SpellBinder.ActiveSpecBindings[addon.PlayerClass][playerSpec] == nil then
            E.db.SpellBinder.ActiveSpecBindings[addon.PlayerClass][playerSpec] = {}
        end
        addon.ActiveBindingsTable = E.db.SpellBinder.ActiveSpecBindings[addon.PlayerClass][playerSpec]
    end

    SB:UpdateBindingTables()
    addon:DisableClicks()
    local setup, remove = SB:GetClickAttributes()
    addon:SetHeaderAttribute("setup_clicks", setup);
    addon:SetHeaderAttribute("remove_clicks", remove);
    addon:EnableClicks()

    self:UnregisterEvent("INSPECT_READY");
end

function SB:OnPlayerEnterWorld()
    self:RegisterEvent("INSPECT_READY", "OnInspectReady");
    NotifyInspect("player")
end

function SB:OnPlayerLevelUp()
    C:UpdateHealingSpellSelect()
    C:UpdateOtherSpellSelect()
end

function SB:OnPlayerSpecializationChanged()
    addon.ActiveBindingsTable = E.db.SpellBinder.ActiveBindings
    if E.db.SpellBinder.SpecBasedBindings then
        local currentSpec = GetSpecialization()
        local _, playerSpec = GetSpecializationInfo(currentSpec)
        addon.PlayerSpec = playerSpec or "None"
        if E.db.SpellBinder.ActiveSpecBindings[addon.PlayerClass] == nil then
            E.db.SpellBinder.ActiveSpecBindings[addon.PlayerClass] = {}
        end
        if E.db.SpellBinder.ActiveSpecBindings[addon.PlayerClass][playerSpec] == nil then
            E.db.SpellBinder.ActiveSpecBindings[addon.PlayerClass][playerSpec] = {}
        end
        addon.ActiveBindingsTable = E.db.SpellBinder.ActiveSpecBindings[addon.PlayerClass][playerSpec]
    end

    SB:UpdateBindingTables()
    addon:DisableClicks()
    local setup, remove = SB:GetClickAttributes()
    addon:SetHeaderAttribute("setup_clicks", setup)
    addon:SetHeaderAttribute("remove_clicks", remove)
    addon:EnableClicks()
end

function SB:OnBagUpdate()
    C:UpdateItemSelect()
end

function SB:OnPlayerInventoryChanged()
    C:UpdateItemSelect()
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
    addon:SetHeaderAttribute("setup_clicks", setup)
    addon:SetHeaderAttribute("remove_clicks", remove)

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
    self:RegisterEvent("BAG_UPDATE", "OnBagUpdate");

    self:SecureHookScript(GameTooltip, 'OnTooltipSetUnit', 'SB_OnTooltipSetUnit')
    self:SecureHookScript(GameTooltip, 'OnHide', function()
        self:CancelTimer(TooltipUpdateTimer)
        TooltipUpdateTimer = nil
    end)

    addon:RegisterMessage("SPEC_CHANGED", function() SB:OnPlayerSpecializationChanged() end)
end

E:RegisterModule(SB:GetName())
