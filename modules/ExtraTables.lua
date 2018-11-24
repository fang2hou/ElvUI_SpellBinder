--[[
    ElvUI_SpellBinder
    Copyright (C) Nîne-Shu'halo, All rights reserved.
]]--

local E, L, V, P, G = unpack(ElvUI) -- Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local addonName, addon = ...

addon.Blacklist = {
	[83958] = true,
	[125439] = true,
	[6603] = true,
}

addon.Racials = {
	["GIFT_OF_THE_NAARU"] = L["Gift of the Naaru"],
	["STONEFORM"] = L["Stoneform"],
	["ESCAPE_ARTIST"] = L["Escape Artist"],
	["EVERY_MAN_FOR_HIMSELF"] = L["Every Man for Himself"],
	["SHADOW_MELD"] = L["Shadow Meld"],
	["DARKFLIGHT"] = L["Darkflight"],
	["TWO_FORMS"] = L["Two Forms"],
	["RUNNING_WILD"] = L["Running Wild"],
	["SPATIAL_RIFT"] = L["Spatial Rift"],
	["FIREBLOOD"] = L["Fireblood"],
	["MOLE_MACHINE"] = L["Mole Machine"],
	["BLOOD_FURY"] = L["Blood Fury"],
	["WAR_STOME"] = L["War Stomp"],
	["BERSERKING"] = L["Berserking"],
	["WILL_OF_THE_FORSAKEN"] = L["Will of the Forsaken"],
	["ARCANE_TORRENT"] = L["Arcane Torrent"],
	["ROCKET_JUMP"] = L["Rocket Jump"],
	["BULL_RUSH"] = L["Bull Rush"],
	["CANTRIPS"] = L["Cantrips"],
	["ANCESTRAL_CALL"] = L["Ancestral Call"],
	["SYMPATHETIC_VIGOR"] = L["Sympathetic Vigor"],
	["FORGE_OF_LIGHT"] = L["Forge of Light"],
}
