--[[
    ElvUI_SpellBinder
    Copyright (C) Nîne-Shu'halo, All rights reserved.
]]--

local E, L, V, P, G = unpack(ElvUI) -- Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local ACR = LibStub("AceConfigRegistry-3.0-ElvUI")
local C = E:NewModule("SpellBinder_Config", "AceHook-3.0", "AceEvent-3.0", "AceTimer-3.0")
local EP = LibStub("LibElvUIPlugin-1.0")

local addonName, addon = ...

-- defaults
P["SpellBinder"] = {
	["SpecBasedBindings"] = false,
	["SpellBinderEnabled"] = true,
    ["ModifyTooltips"] = true,
    ["ActiveBindings"] = {}
}

V["SpellBinder"] = {
    ["ActiveBindings"] = {}
}

local SelectedHealAbility = ""
local SelectedOtherAbility = ""
local SelectedCommand = "ASSIST"
local SelectedItem = ""
local UsableHealingSpells = {}
local UsableOtherSpells = {}

addon.PlayerClass = ""

E.PopupDialogs["RESET_SB_DATA"] = {
    text = L["Accepting this will reset all of your SpellBinder data. Are you sure?"],
    button1 = ACCEPT,
    button2 = CANCEL,
    OnAccept = function()
        C:PurgeTables(true)
        C:UpdateHealingSpellSelect()
        C:UpdateOtherSpellSelect()
        C:UpdateItemTable()
        ACR:NotifyChange("ElvUI")
    end,
    timeout = 0,
    whileDead = 1,
    hideOnEscape = false,
}

function C:SetIfUsable(table, key, spell)
    local usable, nomana = IsUsableSpell(spell)
    if usable or nomana then table[key] = spell end
end

function C:PurgeTables(purgeAll)
    -- These tables should always start empty
    UsableHealingSpells = table.wipe(UsableHealingSpells)
    UsableOtherSpells = table.wipe(UsableOtherSpells)
    E.private.SpellBinder.ActiveBindings = table.wipe(E.private.SpellBinder.ActiveBindings)
    if (purgeAll) then
        E.db.SpellBinder.ActiveBindings = table.wipe(E.db.SpellBinder.ActiveBindings)
    end
end

function C:UpdateHealingSpellSelect()
    -- Clear all target table data
    UsableHealingSpells = table.wipe(UsableHealingSpells)

    -- Add spells to the target table if they're usable
    table.foreach(addon.HealingSpells[E.private.SpellBinder.PlayerClass],
        function(k, v) C:SetIfUsable(UsableHealingSpells, k, v) end)

    table.foreach(addon.HealingSpells["RACIAL"],
        function(k, v) C:SetIfUsable(UsableHealingSpells, k, v) end)

    E.Options.args.SpellBinder.args.bindingsGroup.args.healingSpells.values = UsableHealingSpells
    local a = addon.TableKeysToSortedArray(UsableHealingSpells)

    SelectedHealAbility = a[1]

    ACR:NotifyChange("ElvUI")
end

function C:UpdateOtherSpellSelect()
    -- Clear all target table data
    UsableOtherSpells = table.wipe(UsableOtherSpells)

    -- Add spells to the target table if they're usable
    table.foreach(addon.OtherSpells[E.private.SpellBinder.PlayerClass],
        function(k, v) C:SetIfUsable(UsableOtherSpells, k, v) end)

    table.foreach(addon.OtherSpells["RACIAL"],
        function(k, v) C:SetIfUsable(UsableOtherSpells, k, v) end)

    E.Options.args.SpellBinder.args.bindingsGroup.args.otherSpells.values = UsableOtherSpells
    local a = addon.TableKeysToSortedArray(UsableOtherSpells)

    SelectedOtherAbility = a[1]

    ACR:NotifyChange("ElvUI")
end

function C:UpdateCommandTable() end
function C:UpdateItemTable() end

function C:UpdateActiveBindingsGroup(ability, text)
    local i = 1
    local spellText = ""

    local usable, nomana = IsUsableSpell(ability)
    if not usable and not nomana then return end

    while true do
        local spellName = GetSpellBookItemName(i, BOOKTYPE_SPELL)
        if not spellName then do break end end

        if spellName == ability then spellText = addon.GetSpellText(i, BOOKTYPE_SPELL); end

        i = i + 1
    end

    local abilityIDString = ability:gsub("%s+", "")
    E.private.SpellBinder.ActiveBindings[abilityIDString] = {
        order = 0,
        type = "group",
        name = ability .. " (" .. text .. ")",
        args = {
            abilityDesc = {
                order = 1,
                type = "description",
                name = spellText,
                fontSize = "medium",
            },
            abilityBinding = {
                order = 2,
                type = "description",
                name = L["Bound to: " .. text],
                fontSize = "medium",
            },
            spacer = {
                order = 3,
                type = "description",
                name = "",
            },
            abilityDelete = {
                order = 4,
                type = "execute",
                name = L["Delete"],
                buttonElvUI = true,
                func = function()
                    E.db.SpellBinder.ActiveBindings[ability] = nil
                    E.private.SpellBinder.ActiveBindings[abilityIDString] = nil
                    ACR:NotifyChange("ElvUI")
                    addon:UpdateAllAttributes()
                end,
                disabled = function() return not E:GetModule("SpellBinder") end,
            },
        },
    }
    E.Options.args.SpellBinder.args.bindingsGroup.args.activeBindings.args = E.private.SpellBinder.ActiveBindings
    ACR:NotifyChange("ElvUI")
end

function C:UpdateActiveBindings()
    E.private.SpellBinder.ActiveBindings = table.wipe(E.private.SpellBinder.ActiveBindings)

    for key, value in pairs(E.db.SpellBinder.ActiveBindings) do
        C:UpdateActiveBindingsGroup(key, value)
    end

    ACR:NotifyChange("ElvUI")
end

function C:BindAbility(table, selected)
    if selected == nil or selected == "" then
        UIErrorsFrame:AddMessage("Error: No ability selected", 1.0, 0.5, 0.0, ChatTypeInfo["SYSTEM"], 0)
        return
    end

    local text = addon.GetBinding()
    -- TODO: Support items and commands

    --E.db.SpellBinder.ActiveBindings[table[E.private.SpellBinder.PlayerClass][selected]] = text
    E.db.SpellBinder.ActiveBindings[table[selected]] = text
    --C:UpdateActiveBindingsGroup(table[E.private.SpellBinder.PlayerClass][selected], text)
    C:UpdateActiveBindingsGroup(table[selected], text)

end

function C:InsertOptions()
	E.Options.args.SpellBinder = {
		type = "group",
		name = L["SpellBinder"],
        childGroups = "tab",
		get = function(info) return E.db.SpellBinder[ info[#info] ] end,
		set = function(info, value) E.db.SpellBinder[ info[#info] ] = value end,
		args = {
            intro = {
                order = 1,
                type = "description",
                name = L["SPELLBINDER_DESC"],
            },
			generalGroup = {
				order = 2,
				type = "group",
				name = L["General Options"],
				disabled = function() return not E:GetModule("SpellBinder"); end,
				args = {
                    enable = {
                        order = 1,
                        type = "toggle",
                        name = L["Enable"],
                        get = function(info) return E.db.SpellBinder.SpellBinderEnabled end,
                        set = function(info, value) E.db.SpellBinder.SpellBinderEnabled = value
                            if value == true then
                                addon.EnableClicks()
                            else
                                addon.DisableClicks()
                            end
                        end
                    },
                    SpecBasedBindings = {
                        order = 2,
                        type = "toggle",
                        name = L["Spec Based Bindings"],
                        desc = "Swap profiles based on talent specialization",
                        get = function(info) return E.db.SpellBinder.SpecBasedBindings end,
                        set = function(info, value) E.db.SpellBinder.SpecBasedBindings = value end,
                        disabled = true
                    },
                    modifyTooltips = {
                        order = 2,
                        type = "toggle",
                        name = L["Modify Tooltips"],
                        desc = "Insert binding information into Unit tooltips",
                        get = function(info) return E.db.SpellBinder.ModifyTooltips end,
                        set = function(info, value) E.db.SpellBinder.ModifyTooltips = value end,
                    },
				},
			},
            bindingsGroup = {
                order = 3,
                type = "group",
                name = L["Bindings"],
                args = {
                    intro = {
                        order = 0,
                        type = "description",
                        name = L["Select the action to bind, then click \"Bind\" with the key combination you'd like to use"],
                    },
                    healingSpells = {
                        order = 1,
                        type = "select",
                        name = "Healing Spells",
                        desc = "List of healing spells in your spellbook",
                        get = function(info) return SelectedHealAbility end,
                        set = function(info, value) SelectedHealAbility = value; end,
                        values = UsableHealingSpells
                    },
                    healingBind = {
                        order = 2,
                        type = "execute",
                        name = L["Bind"],
                        buttonElvUI = true,
                        width = "half",
                        func = function()
                            C:BindAbility(UsableHealingSpells, SelectedHealAbility)
                            addon:UpdateAllAttributes()
                        end,
                        disabled = function() return not E:GetModule("SpellBinder"); end,
                    },
                    activeBindings = {
                        order = 3,
                        type = "group",
                        name = L["Active Bindings"],
                        customWidth = 500,
                        childGroups = "tree",
                        args = E.private.SpellBinder.ActiveBindings,
                    },
                    otherSpells = {
                        order = 4,
                        type = "select",
                        name = "Other Spells",
                        desc = L["List of other spells in your spellbook"],
                        get = function(info) return SelectedOtherAbility end,
                        set = function(info, value) SelectedOtherAbility = value end,
                        values = UsableOtherSpells
                    },
                    otherBind = {
                        order = 5,
                        type = "execute",
                        name = L["Bind"],
                        buttonElvUI = true,
                        width = "half",
                        func = function()
                            C:BindAbility(UsableOtherSpells, SelectedOtherAbility)
                            addon:UpdateAllAttributes()
                        end,
                        disabled = function() return not E:GetModule("SpellBinder"); end,
                    },
                    items = {
                        order = 6,
                        type = "select",
                        name = "Items",
                        desc = L["List of available items"],
                        get = function(info) return SelectedItem end,
                        set = function(info, value) SelectedItem = value end,
                        values = addon.Items
                    },
                    itemsBind = {
                        order = 7,
                        type = "execute",
                        name = L["Bind"],
                        buttonElvUI = true,
                        width = "half",
                        func = function()
                            --C:BindAbility(UsableItems, SelectedItem)
                            --addon:UpdateAllAttributes()
                        end,
                        disabled = function() return not E:GetModule("SpellBinder"); end,
                    },
                    commands = {
                        order = 8,
                        type = "select",
                        name = "Commands",
                        desc = L["List of available commands"],
                        get = function(info) return SelectedCommand end,
                        set = function(info, value) SelectedCommand = value end,
                        values = {
                            ["ASSIST"] = "Assist",
                            ["FOCUS"] = "Focus",
                            ["MENU"] = "Menu",
                            ["TARGET"] = "Target"
                        },
                    },
                    commandsBind = {
                        order = 9,
                        type = "execute",
                        name = L["Bind"],
                        buttonElvUI = true,
                        width = "half",
                        func = function()
                            --C:BindAbility(UsableCommands, SelectedCommand)
                            --addon:UpdateAllAttributes()
                        end,
                        disabled = function() return not E:GetModule("SpellBinder"); end,
                    },
                    purgeButton = {
                        order = 101,
                        type = "execute",
                        name = L["Purge All Data"],
                        buttonElvUI = true,
                        func = function() E:StaticPopup_Show("RESET_SB_DATA") end,
                        disabled = function() return not E:GetModule("SpellBinder"); end,
                    },
                },
			},
		},
    }
end

function C:Initialize()
	EP:RegisterPlugin(addonName, C.InsertOptions)
    C:PurgeTables()
end

E:RegisterModule(C:GetName())
