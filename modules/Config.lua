--[[
    ElvUI_SpellBinder
    Copyright (C) Nîne-Shu'halo, All rights reserved.
]]--

local E, L, V, P, G = unpack(ElvUI) -- Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local ACR = LibStub("AceConfigRegistry-3.0")
local C = E:NewModule("SpellBinder_Config", "AceHook-3.0", "AceEvent-3.0", "AceTimer-3.0")
local EP = LibStub("LibElvUIPlugin-1.0")

local addonName, addon = ...

-- defaults
P["SpellBinder"] = {
	["SpecBasedBindings"] = false,
	["SpellBinderEnabled"] = true,
    ["ModifyTooltips"] = true,
    ["ActiveBindings"] = { },
    ["ActiveSpecBindings"] = { },
    ["TTAbilityColor"] = {
        ["r"] = 0.2,
        ["g"] = 0.8,
        ["b"] = 0.2
    },
    ["TTAbilityCDColor"] = {
        ["r"] = 0.8,
        ["g"] = 0.2,
        ["b"] = 0.2
    },
    ["TTCostColor"] = {
        ["r"] = 0.5,
        ["g"] = 0.2,
        ["b"] = 0.8
    },
}

V["SpellBinder"] = { }

local ActiveBindingsArgs = {}
local GlobalActiveBindingsArgs = {}
local SelectedHelpfulAbility = ""
local SelectedHarmfulAbility = ""
local SelectedCommand = "ASSIST"
local SelectedItem = ""
local SelectedRacial = ""
local UsableSpells = {
	["Helpful"] = {},
	["Harmful"] = {},
}
local UsableRacials = {} 
local UsableItems = {} 

ElvUI_SpellBinderGlobalDB = { 
	["GlobalBindings"] = {}, 
} 
local UsableCommands = {
    ["ASSIST"] = L["Assist"],
    ["FOCUS"] = L["Focus"],
    ["MENU"] = L["Menu"],
    ["TARGET"] = L["Target"]
}

local EquipmentSlots = {
    "HeadSlot", "NeckSlot", "ShoulderSlot", "BackSlot", "ChestSlot",
    "ShirtSlot", "TabardSlot", "WristSlot", "HandsSlot", "WaistSlot",
    "LegsSlot", "FeetSlot", "Finger0Slot", "Finger1Slot",
    "Trinket0Slot", "Trinket1Slot", "MainHandSlot", "SecondaryHandSlot",
}

addon.PlayerClass = ""
addon.PlayerSpec = ""
addon.ActiveBindingsTable = {}
addon.UsableItemMap = {}

E.PopupDialogs["RESET_SB_DATA"] = {
    text = L["Accepting this will reset all of your SpellBinder data. Are you sure?"],
    button1 = ACCEPT,
    button2 = CANCEL,
    OnAccept = function()
        C:PurgeTables(true)
        C:UpdateSpellSelect()
        C:UpdateRacialSelect()
        C:UpdateItemSelect()
        ACR:NotifyChange("ElvUI")
    end,
    timeout = 0,
    whileDead = 1,
    hideOnEscape = false,
}

E.PopupDialogs["RESET_GLOBAL_SB_DATA"] = {
    text = L["Accepting this will reset all of your SpellBinder global data. Are you sure?"],
    button1 = ACCEPT,
    button2 = CANCEL,
    OnAccept = function()
        C:PurgeGlobalTables(true)
        C:UpdateItemSelect()
        ACR:NotifyChange("ElvUI")
    end,
    timeout = 0,
    whileDead = 1,
    hideOnEscape = false,
}

function C:PurgeTables(purgeAll)
    -- These tables should always start empty
    UsableSpells.Helpful = table.wipe(UsableSpells.Helpful)
    UsableSpells.Harmful = table.wipe(UsableSpells.Harmful)

    ActiveBindingsArgs = table.wipe(ActiveBindingsArgs)
    if (purgeAll) then
        E.db.SpellBinder.ActiveBindings = table.wipe(E.db.SpellBinder.ActiveBindings)
        E.db.SpellBinder.ActiveSpecBindings = table.wipe(E.db.SpellBinder.ActiveSpecBindings)
    end
end

function C:PurgeGlobalTables(purgeAll)
    -- These tables should always start empty
	GlobalActiveBindingsArgs = table.wipe(GlobalActiveBindingsArgs)
    if (purgeAll) then
        ElvUI_SpellBinderGlobalDB.GlobalBindings = table.wipe(ElvUI_SpellBinderGlobalDB.GlobalBindings)
    end
end


function C:SetIfUsable(table, key, spell)
    local usable, nomana = IsUsableSpell(spell)
    if usable or nomana then table[key] = spell end
end

function C:ShouldListSpell(spellIndex, spellID)
	local spellName, _, spellID = GetSpellBookItemName(spellIndex, BOOKTYPE_SPELL)
	if addon.Blacklist[spellID] ~= nil then return nil end
	if IsPassiveSpell(spellIndex, BOOKTYPE_SPELL) then return nil end

	return spellID
end

function C:ListSpell(spellIndex)
	local spellName, _, spellID = GetSpellBookItemName(spellIndex, BOOKTYPE_SPELL)

	if addon:IsHarmfulSpell(spellIndex) == true then
		UsableSpells.Harmful[spellID] = spellName		
	elseif addon:IsHelpfulSpell(spellIndex) == true then
		UsableSpells.Helpful[spellID] = spellName
	else
		 local msg = "ElvUI_SpellBinder: " .. spellName .. " ["..spellID.."] is not flagged as helpful or harmful.  Ignoring!"
		 UIErrorsFrame:AddMessage(msg, 1.0, 0.5, 0.0, ChatTypeInfo["SYSTEM"], 5)
		 DEFAULT_CHAT_FRAME:AddMessage(msg, 1.0, 0.5, 0.0, ChatTypeInfo["SYSTEM"])
	end
end

function C:ProcessFlyout(flyoutID)
	local _, _, numSlots, isKnown = GetFlyoutInfo(flyoutID)
	for flyoutSlot = 1, numSlots do
		local spellID, _, isKnown = GetFlyoutSlotInfo(flyoutID, flyoutSlot)
		local spellIndex = FindSpellBookSlotBySpellID(spellID)
		if isKnown then C:ListSpell(spellIndex) end
	end
end

function C:ProcessSpell(spellIndex)
	local spellID = C:ShouldListSpell(spellIndex)
	local slotType, special = GetSpellBookItemInfo(spellIndex, BOOKTYPE_SPELL)
	
	if not spellID and slotType ~= "FLYOUT" then return end

	if slotType == "FLYOUT" then C:ProcessFlyout(special)
	else C:ListSpell(spellIndex) end
end

function C:ProcessSpellBookTab(tabIndex)
	local _, _, offset, numSpells, _, isOffSpec = GetSpellTabInfo(tabIndex)
	if (isOffSpec ~= 0) then return end

	local spellIndex = 1
	for spellIndex = (offset + 1), (offset + numSpells) do
		C:ProcessSpell(spellIndex)
		spellIndex = spellIndex + 1
	end
end

function C:UpdateSpellSelect()
    -- Clear all target table data
    UsableSpells.Helpful = table.wipe(UsableSpells.Helpful)
    UsableSpells.Harmful = table.wipe(UsableSpells.Harmful)

	local tabIndex = 1
	for tabIndex = 1, GetNumSpellTabs() do 
		C:ProcessSpellBookTab(tabIndex) 
		tabIndex = tabIndex + 1
	end

	E.Options.args.SpellBinder.args.bindingsGroup.args.helpfulSpells.values = UsableSpells.Helpful
	E.Options.args.SpellBinder.args.bindingsGroup.args.harmfulSpells.values = UsableSpells.Harmful
    local a = addon:TableKeysToSortedArray(UsableSpells.Helpful)
    local b = addon:TableKeysToSortedArray(UsableSpells.Harmful)

    SelectedHelpfulAbility = a[1]
    SelectedHarmfulAbility = b[1]

    ACR:NotifyChange("ElvUI")
end

function C:UpdateRacialSelect() 
    -- Clear all target table data
    UsableRacials = table.wipe(UsableRacials)

    table.foreach(addon.Racials, function(k, v) C:SetIfUsable(UsableRacials, k, v) end)

    E.Options.args.SpellBinder.args.globalBindingsGroup.args.racials.values = UsableRacials
    local a = addon:TableKeysToSortedArray(UsableRacials)

    SelectedRacial = a[1]

    ACR:NotifyChange("ElvUI")
end

function C:ProcessItem(bag, slot, itemID)
    if not itemID then return end

    local itemName = GetItemInfo(itemID)
    local sName, sID, sRank = GetItemSpell(itemID)
    if sName ~= nil then
        local iNameKey = itemName:gsub("%s+", "_")
        iNameKey = itemName:gsub("'", "")
        iNameKey = strupper(iNameKey)
        UsableItems[iNameKey] = itemName
        addon.UsableItemMap[itemName] = {}
        addon.UsableItemMap[itemName].key = iNameKey
        addon.UsableItemMap[itemName].bag = bag
        addon.UsableItemMap[itemName].slot = slot
        addon.UsableItemMap[itemName].id = itemID
    end
end

function C:ProcessBag(bag)
    for slot=1, GetContainerNumSlots(bag) do
        local itemID = GetContainerItemID(bag, slot)
        C:ProcessItem(bag, slot, itemID)
    end
end

function C:UpdateItemSelect()
    UsableItems = table.wipe(UsableItems)
    addon.UsableItemMap = table.wipe(addon.UsableItemMap)

    -- Find all the usable items in the player's bags
    for bag=0, NUM_BAG_SLOTS do C:ProcessBag(bag) end

    -- Find all the usable items in the player's gear
    for _, v in pairs(EquipmentSlots) do
        local slotID = GetInventorySlotInfo(v)
        local itemID = GetInventoryItemID("player", slotID)
        C:ProcessItem(nil, slotID, itemID)
    end

    E.Options.args.SpellBinder.args.bindingsGroup.args.items.values = UsableItems
    E.Options.args.SpellBinder.args.globalBindingsGroup.args.items.values = UsableItems
    local a = addon:TableKeysToSortedArray(UsableItems)

    SelectedItem = a[1]
    ACR:NotifyChange("ElvUI")
end

function C:CreateSpellBinding(binding) 
	local spellText, nameColor, bindingID = "", "", ""

	if binding.harmful then nameColor = "|c00CC3333"
	else nameColor = "|c0033CC33" end

	local usable, nomana = IsUsableSpell(binding.ability)
	if not usable and not nomana then 
		bindingID = "Inactive_" .. binding.ability 
		nameColor = "|c00636363"
		return bindingID, nameColor, spellText
	end

	local _, _, _, _, _, _, spellID = GetSpellInfo(binding.ability)
	local spellIndex = FindSpellBookSlotBySpellID(spellID)	
	if spellIndex then spellText = addon:GetSpellText(spellIndex, BOOKTYPE_SPELL, "spell") end
		
	if spellID then
		bindingID = "spell_"..spellID
	else
		bindingID = "Inactive_" .. binding.ability
	end

	return bindingID, nameColor, spellText
end

function C:CreateItemBinding(binding)
	local itemText, nameColor, bindingID = "", "", ""

	if addon.UsableItemMap[binding.ability] == nil then
		bindingID = "Inactive_" .. binding.ability 
		nameColor = "|c00636363"
		return bindingID, nameColor, itemText
	end

	if binding.harmful then nameColor = "|c00CC3333"
	else nameColor = "|c0033CC33" end

	local item = addon.UsableItemMap[binding.ability]
	itemText = addon:GetSpellText(item.bag, item.slot, "item")
	bindingID = "item_".. addon.UsableItemMap[binding.ability].id

	return bindingID, nameColor, itemText
end

function C:UpdateActiveBindingsGroup(key, binding, global)
    local spellText = ""
    local bindingID = ""
	local nameColor = "|c0033CC33"

	if  global == nil then global = false end

    if binding.type == "spell" then
		bindingID, nameColor, spellText = C:CreateSpellBinding(binding)
    elseif binding.type == "item" then
		bindingID, nameColor, spellText = C:CreateItemBinding(binding)
    elseif binding.type == "command" then
        bindingID = binding.ability
    end

	local bindingsTable = addon.ActiveBindingsTable
	local bindingsArgs = ActiveBindingsArgs
	if global == true then
		bindingsTable = ElvUI_SpellBinderGlobalDB.GlobalBindings
		bindingsArgs = GlobalActiveBindingsArgs
	end

    bindingsArgs[bindingID] = {
        order = 0,
        type = "group",
        name = nameColor .. binding.ability .. "|r" .. " |c00FFFFFF(" .. binding.binding .. ")|r",
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
                name = L["Bound to: " .. binding.binding],
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
                    bindingsTable[key] = nil
                    bindingsArgs[bindingID] = nil
                    ACR:NotifyChange("ElvUI")
                    addon:UpdateAllAttributes()
                end,
                disabled = function() return not E:GetModule("SpellBinder") end,
            },
        },
    }
	if global == true then
		E.Options.args.SpellBinder.args.globalBindingsGroup.args.activeBindings.args = GlobalActiveBindingsArgs
	else
		E.Options.args.SpellBinder.args.bindingsGroup.args.activeBindings.args = ActiveBindingsArgs
	end
    ACR:NotifyChange("ElvUI")
end

function C:UpdateActiveBindings()
    E.private.SpellBinder.ActiveBindingsArgs = table.wipe(ActiveBindingsArgs)
    E.private.SpellBinder.GlobalActiveBindingsArgs = table.wipe(GlobalActiveBindingsArgs)

    for k, v in pairs(addon.ActiveBindingsTable) do
		if v.harmful == nil then v.harmful = false end
        C:UpdateActiveBindingsGroup(k, v, false)
    end

	if ElvUI_SpellBinderGlobalDB.GlobalBindings ~= nil then
		for k, v in pairs(ElvUI_SpellBinderGlobalDB.GlobalBindings) do
			if v.harmful == nil then v.harmful = false end
			C:UpdateActiveBindingsGroup(k, v, true)
		end
	end
    ACR:NotifyChange("ElvUI")
end

function C:BindAbility(table, selected, type, harmful, global)
    if selected == nil or selected == "" then
        UIErrorsFrame:AddMessage("Error: No ability selected", 1.0, 0.5, 0.0, ChatTypeInfo["SYSTEM"], 5)
        return
    end

	local bindingsTable = addon.ActiveBindingsTable
	if global ~= nil and global == true then
		bindingsTable = ElvUI_SpellBinderGlobalDB.GlobalBindings
	end

    local text = addon:GetBinding()

	if ElvUI_SpellBinderGlobalDB.GlobalBindings ~= nil then
		for _, v in pairs(ElvUI_SpellBinderGlobalDB.GlobalBindings) do
			 if v.binding == text and (v.harmful == harmful or v.type ~= "spell") then
				 local msg = "ElvUI_SpellBinder: " .. v.ability .. " is already globally bound to " .. text
				 UIErrorsFrame:AddMessage(msg, 1.0, 0.5, 0.0, ChatTypeInfo["SYSTEM"], 5)
				 DEFAULT_CHAT_FRAME:AddMessage(msg, 1.0, 0.5, 0.0, ChatTypeInfo["SYSTEM"])
				 return
			end
		end
	end

    for _, v in pairs(addon.ActiveBindingsTable) do
         if v.binding == text and (v.harmful == harmful or v.type ~= "spell") then
             local msg = "ElvUI_SpellBinder: " .. v.ability .. " is already bound to " .. text
             UIErrorsFrame:AddMessage(msg, 1.0, 0.5, 0.0, ChatTypeInfo["SYSTEM"], 5)
             DEFAULT_CHAT_FRAME:AddMessage(msg, 1.0, 0.5, 0.0, ChatTypeInfo["SYSTEM"])
             return
        end
    end

    bindingsTable[selected] = nil
    bindingsTable[selected] = {}
    bindingsTable[selected].ability = table[selected]
    bindingsTable[selected].binding = text
    bindingsTable[selected].type = type
    bindingsTable[selected].harmful = harmful
    C:UpdateActiveBindingsGroup(selected, bindingsTable[selected], global)

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
                    generalHeader = {
                        order = 0,
                        type = "header",
                        name = "General"
                    },
                    enable = {
                        order = 1,
                        type = "toggle",
                        name = L["Enable"],
                        get = function(info) return E.db.SpellBinder.SpellBinderEnabled end,
                        set = function(info, value) E.db.SpellBinder.SpellBinderEnabled = value
                            if value == true then
                                addon:EnableClicks()
                            else
                                addon:DisableClicks()
                            end
                        end
                    },
                    SpecBasedBindings = {
                        order = 2,
                        type = "toggle",
                        name = L["Spec Based Bindings"],
                        desc = "Swap profiles based on talent specialization",
                        get = function(info) return E.db.SpellBinder.SpecBasedBindings end,
                        set = function(info, value)
                            local oldValue = E.db.SpellBinder.SpecBasedBindings
                            E.db.SpellBinder.SpecBasedBindings = value
                            if oldValue ~= nil then
                                addon:FireMessage("SPEC_CHANGED")
                            end
                        end,
                    },
                    modifyTooltips = {
                        order = 2,
                        type = "toggle",
                        name = L["Modify Tooltips"],
                        desc = "Insert binding information into Unit tooltips",
                        get = function(info) return E.db.SpellBinder.ModifyTooltips end,
                        set = function(info, value) E.db.SpellBinder.ModifyTooltips = value end,
                    },
                    spacer1 = {
                        order = 3,
                        type = "description",
                        name = ""
                    },
                    colorHeader = {
                        order = 4,
                        type = "header",
                        name = "Colors"
                    },
                    abilityColor = {
                        order = 5,
                        type = "color",
                        name = L["Ability Color"],
                        desc = "Change the color of your abilities in the tooltip",
                        hasAlpha = false,
                        get = function()
                            local colorTable = E.db.SpellBinder.TTAbilityColor
                            return colorTable.r, colorTable.g, colorTable.b, false
                        end,
                        set = function(_, r, g, b, _)
                            local colorTable = E.db.SpellBinder.TTAbilityColor
                            colorTable.r = r
                            colorTable.g = g
                            colorTable.b = b
                        end
                    },
                    abilityCDColor = {
                        order = 6,
                        type = "color",
                        name = L["Ability Cooldown Color"],
                        desc = "Change the color of your abilities in the tooltip when they're on cooldown",
                        hasAlpha = false,
                        get = function()
                            local colorTable = E.db.SpellBinder.TTAbilityCDColor
                            return colorTable.r, colorTable.g, colorTable.b, false
                        end,
                        set = function(_, r, g, b, _)
                            local colorTable = E.db.SpellBinder.TTAbilityCDColor
                            colorTable.r = r
                            colorTable.g = g
                            colorTable.b = b
                        end
                    },
                    costColor = {
                        order = 7,
                        type = "color",
                        name = L["Ability Cost Color"],
                        desc = "Change the color of your ability's resource in the tooltip",
                        hasAlpha = false,
                        get = function()
                            local colorTable = E.db.SpellBinder.TTCostColor
                            return colorTable.r, colorTable.g, colorTable.b, false
                        end,
                        set = function(_, r, g, b, _)
                            local colorTable = E.db.SpellBinder.TTCostColor
                            colorTable.r = r
                            colorTable.g = g
                            colorTable.b = b
                        end
                    },
                    spacer2 = {
                        order = 8,
                        type = "description",
                        name = ""
                    },
                    spacer3 = {
                        order = 9,
                        type = "description",
                        name = ""
                    },
                    resetColors = {
                        order = 10,
                        type = "execute",
                        name = L["Reset Colors"],
                        buttonElvUI = true,
                        func = function()
                            local c = E.db.SpellBinder.TTAbilityColor
                            c.r = 0.2
                            c.g = 0.8
                            c.b = 0.2

                            c = E.db.SpellBinder.TTAbilityCDColor
                            c.r = 0.8
                            c.g = 0.2
                            c.b = 0.2

                            c = E.db.SpellBinder.TTCostColor
                            c.r = 0.5
                            c.g = 0.2
                            c.b = 0.8

                            ACR:NotifyChange("ElvUI")
                        end,
                        disabled = function() return not E:GetModule("SpellBinder"); end,
                    },
				},
			},
			globalBindingsGroup = {
                order = 3,
                type = "group",
                name = L["Global Bindings"],
				childGroups = "tab",
                args = {
                    intro = {
                        order = 0,
                        type = "description",
                        name = L["Select the action to bind, then click \"Bind\" with the key combination you'd like to use\nThese bindings will apply to all characterrs"],
                    },
                    activeBindings = {
                        order = 3,
                        type = "group",
                        name = L["Active Global Bindings"],
                        args = GlobalActiveBindingsArgs,
                    },
					racials = {
                        order = 4,
                        type = "select",
                        name = "Racials",
                        desc = L["List of available racial abilities"],
                        get = function(info) return SelectedRacial end,
                        set = function(info, value) SelectedRacial = value end,
                        values = UsableRacials
                    },
                    RacialsBind = {
                        order = 5,
                        type = "execute",
                        name = L["Bind"],
                        buttonElvUI = true,
                        width = "half",
                        func = function()
                            C:BindAbility(UsableRacials, SelectedRacial, "spell", false, true)
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
                        values = UsableItems
                    },
                    itemsBind = {
                        order = 7,
                        type = "execute",
                        name = L["Bind"],
                        buttonElvUI = true,
                        width = "half",
                        func = function()
                            C:BindAbility(UsableItems, SelectedItem, "item", false, true)
                            addon:UpdateAllAttributes()
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
                        values = UsableCommands,
                    },
                    commandsBind = {
                        order = 9,
                        type = "execute",
                        name = L["Bind"],
                        buttonElvUI = true,
                        width = "half",
                        func = function()
                            C:BindAbility(UsableCommands, SelectedCommand, "command", false, true)
                            addon:UpdateAllAttributes()
                        end,
                        disabled = function() return not E:GetModule("SpellBinder"); end,
                    },
					spacer = {
                        order = 10,
                        type = "description",
                        name = ""
                    },
                    purgeButton = {
                        order = 11,
                        type = "execute",
                        name = L["Purge All Data"],
                        buttonElvUI = true,
                        func = function() E:StaticPopup_Show("RESET_GLOBAL_SB_DATA") end,
                        disabled = function() return not E:GetModule("SpellBinder"); end,
                    },
                },
			},
            bindingsGroup = {
                order = 4,
                type = "group",
                name = L["Bindings"],
				childGroups = "tab",
                args = {
                    intro = {
                        order = 0,
                        type = "description",
                        name = L["Select the action to bind, then click \"Bind\" with the key combination you'd like to use"],
                    },
                    helpfulSpells = {
                        order = 1,
                        type = "select",
                        name = "Helpful Spells",
                        desc = "List of helpful spells in your spellbook",
                        get = function(info) return SelectedHelpfulAbility end,
                        set = function(info, value) SelectedHelpfulAbility = value; end,
                        values = UsableSpells.Helpful
                    },
                    helpfulBind = {
                        order = 2,
                        type = "execute",
                        name = L["Bind"],
                        buttonElvUI = true,
                        width = "half",
                        func = function()
                            C:BindAbility(UsableSpells.Helpful, SelectedHelpfulAbility, "spell", false, false)
                            addon:UpdateAllAttributes()
                        end,
                        disabled = function() return not E:GetModule("SpellBinder"); end,
                    },
					harmfulSpells = {
                        order = 5,
                        type = "select",
                        name = "Harmful Spells",
                        desc = "List of harmful spells in your spellbook",
                        get = function(info) return SelectedHarmfulAbility end,
                        set = function(info, value) SelectedHarmfulAbility = value; end,
                        values = UsableSpells.Harmful
                    },
                    harmfulBind = {
                        order = 6,
                        type = "execute",
                        name = L["Bind"],
                        buttonElvUI = true,
                        width = "half",
                        func = function()
                            C:BindAbility(UsableSpells.Harmful, SelectedHarmfulAbility, "spell", true, false)
                            addon:UpdateAllAttributes()
                        end,
                        disabled = function() return not E:GetModule("SpellBinder"); end,
                    },
					items = {
                        order = 9,
                        type = "select",
                        name = "Items",
                        desc = L["List of available items"],
                        get = function(info) return SelectedItem end,
                        set = function(info, value) SelectedItem = value end,
                        values = UsableItems
                    },
                    itemsBind = {
                        order = 10,
                        type = "execute",
                        name = L["Bind"],
                        buttonElvUI = true,
                        width = "half",
                        func = function()
                            C:BindAbility(UsableItems, SelectedItem, "item", false, false)
                            addon:UpdateAllAttributes()
                        end,
                        disabled = function() return not E:GetModule("SpellBinder"); end,
                    },
                    commands = {
                        order = 11,
                        type = "select",
                        name = "Commands",
                        desc = L["List of available commands"],
                        get = function(info) return SelectedCommand end,
                        set = function(info, value) SelectedCommand = value end,
                        values = UsableCommands,
                    },
                    commandsBind = {
                        order = 12,
                        type = "execute",
                        name = L["Bind"],
                        buttonElvUI = true,
                        width = "half",
                        func = function()
                            C:BindAbility(UsableCommands, SelectedCommand, "command", false, false)
                            addon:UpdateAllAttributes()
                        end,
                        disabled = function() return not E:GetModule("SpellBinder"); end,
                    },
                    purgeButton = {
                        order = 13,
                        type = "execute",
                        name = L["Purge All Data"],
                        buttonElvUI = true,
                        func = function() E:StaticPopup_Show("RESET_SB_DATA") end,
                        disabled = function() return not E:GetModule("SpellBinder"); end,
                    },
					activeBindings = {
                        order = 14,
                        type = "group",
                        name = L["Active Bindings"],
                        childGroups = "tree",
                        args = ActiveBindingsArgs,
                    },
                },
			},
		},
    }
end

function C:Initialize()
	EP:RegisterPlugin(addonName, C.InsertOptions)
    C:PurgeTables()
    C:PurgeGlobalTables()
    addon.ActiveBindingsTable = E.db.SpellBinder.ActiveBindings
end

E:RegisterModule(C:GetName())
