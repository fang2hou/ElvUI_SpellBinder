--[[
    ElvUI_SpellBinder
    Copyright (C) Nîne-Shu'halo, All rights reserved.
]]--

-- ElvUI
local E, L, V, P, G = unpack(ElvUI) -- Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local SB = E:NewModule("SpellBinder", "AceHook-3.0", "AceEvent-3.0")
local C = E:GetModule("SpellBinder_Config")

local ButtonMap = {
    ["LeftButton"] = "Left",
    ["RightButton"] = "Right",
    ["MiddleButton"] = "Middle",
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

function SB:ShouldPutSpellInTooltip(k, v)
    local alt = IsAltKeyDown()
    local shift = IsShiftKeyDown()
    local ctrl =  IsControlKeyDown()

    -- Break up the binding string into constituants
    local bpart, binding = "", k
    local bAlt, bCtrl, bShift, bButton = false, false, false, ""
    local count = 0
    while string.find(binding, "+", 0, true) do
        bpart, binding = strsplit("+", binding, 2)
        if bpart == "Alt" then bAlt = true
        elseif bpart == "Ctrl" then bCtrl = true
        elseif bpart == "Shift" then bShift = true end
        count = count + 1
        if count >= 5 then break end
    end
    bButton = binding

    --if (not shift and bShift) and (not alt and bAlt) and (not ctrl and bCtrl) then print("return 1")return end
    if (alt and not bAlt) or (bAlt and not alt) then return nil end
    if (shift and not bShift) or (bShift and not shift) then return nil end
    if (ctrl and not bCtrl) or (bCtrl and not ctrl) then return nil end

    local usable, nomana = IsUsableSpell(v)
    if (usable == false) and (nomana == false) then return nil end

    return bButton
end

function SB:SB_OnTooltipSetUnit(...)
    if not E.db.SpellBinder.SpellBinderEnabled then return end

    local frameName = "ElvUF"
    if (GetMouseFocus():GetName():sub(1, #frameName) ~= frameName) then return end

    for k, v in pairs(E.db.SpellBinder.ActiveBindings) do
        local button = SB:ShouldPutSpellInTooltip(k, v)
        if button then
            print(button.." "..v)
            -- Get spell cooldown info
            local start, duration, _, _ = GetSpellCooldown(v)
            local color = {0, 0, 0}

            local leftText = ButtonMap[button]..": "..v
            -- TODO: Handle Costs other than mana
            if start > 0 and duration > 0 then
                -- Spell is on cooldown, append cooldown to left text
                color[1] = 1
                local cd = start + duration - GetTime()
                cd = cd - (cd % 1) -- bad rounding.  Don't care
                leftText = leftText .. " (" .. tostring(cd) .. "s)"
            else
                color[2] = 1
            end

            -- Get spell costs
            local costs = GetSpellPowerCost(v)

            local rightText
            if costs[1] and costs[1].cost then
                local costString = string.format("%5s Mana", tostring(costs[1].cost))
                rightText = "-" .. costString
            end

            leftText = string.format("%-30s", leftText)
            GameTooltip:AddDoubleLine(leftText, rightText, color[1], color[2], color[3], 0,0,1)
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
    E.private.SpellBinder.PlayerClass = englishClass
    --C_Timer.After(10, function() SB:UpdateBindingTables() end)
    SB:UpdateBindingTables()
end

function SB:OnPlayerLevelUp()
    SB:UpdateBindingTables()
end

function SB:OnPlayerSpecializationChanged()
    SB:UpdateBindingTables()
end

function SB:OnPlayerInventoryChanged()
    -- TODO: Update items available for binding
end

function SB:ModifierStateChanged(_, key)
    if UnitExists("mouseover") then
        GameTooltip:SetUnit('mouseover')
    end
end

function SB:Initialize()
    C:InsertOptions()
    self:RegisterEvent("MODIFIER_STATE_CHANGED", "ModifierStateChanged"); -- event, key, state

    self:RegisterEvent("PLAYER_LOGIN", "OnPlayerEnterWorld");
    self:RegisterEvent("PLAYER_LEVEL_UP", "OnPlayerLevelUp");
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnPlayerEnterWorld");
    self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", "OnPlayerSpecializationChanged");
    self:RegisterEvent("UNIT_INVENTORY_CHANGED", "OnPlayerInventoryChanged");

    self:SecureHookScript(GameTooltip, 'OnTooltipSetUnit', 'SB_OnTooltipSetUnit')
end

E:RegisterModule(SB:GetName())
