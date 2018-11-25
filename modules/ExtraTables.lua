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
	[75] = true,
	[1804] = true,
}

-- The following two tables are necessary since the WoW API is broken (I know, shocker, right?)
-- And doesn't flag any of these spells as either helpful or harmful.  Most of them I can understand
-- given the definition of IsHelpfulSpell() and IsHarmfulSpell(), but others, like Ancestral Spirit
-- and revive, are clearly helpful, yet return false from IsHelpfulSpell.  Pretty disgusting really...
addon.HelpfulWhitelist = {
	-- Druid
	[20484] = true,
	[50769] = true,
	[783] = true,
	[61336] = true,
	[155835] = true,
	[145205] = true,

	-- Shaman
	[2008] = true,
	[192058] = true,
	[2484] = true,
	[6196] = true,
	[5394] = true,
	[98008] = true,
	[8143] = true,
	[51485] = true,
	[198838] = true,
	[207399] = true,
	[157153] = true,
	
	-- Demon Hunter
	[196718] = true,

	-- Mage
	[212653] = true,
	[10059] = true,
	[11416] = true,
	[11419] = true,
	[32266] = true,
	[49360] = true,
	[33691] = true,
	[53142] = true,
	[88345] = true,
	[132620] = true,
	[176246] = true,
	[224871] = true,
	[281400] = true,
	[31687] = true,
	[116011] = true,

	-- Paladin
	[7328] = true,
	[259930] = true,
	[20473] = true,
	[114158] = true,
	[114165] = true,

	-- Hunter
	[883] = true,
	[982] = true,
	[6197] = true,
	[1543] = true,
	[83242] = true,
	[83243] = true,
	[83244] = true,
	[83245] = true,
	[199483] = true,

	-- Warrior

	-- Rogue
	[2823] = true,

	-- Priest
	[2006] = true,
	[120517] = true,
	[47540] = true, -- TODO:  Pennance should be both a helpful and harmful binding.  Fix it
	[110744] = true, -- TODO:  Divine Star should be both a helpful and harmful binding.  Fix it

	-- Warlock
	[697] = true,
	[698] = true,
	[691] = true,
	[688] = true,
	[712] = true,
	[29893] = true,
	[111771] = true,
	[30146] = true,
	[265187] = true,
	[264119] = true,
	[1122] = true,

	-- Monk
	[115178] = true,
	[119996] = true,
	[115315] = true,
	[198898] = true,
	[115313] = true,
	[198664] = true,
	[115098] = true, -- TODO:  Chi Wave should be both a helpful and harmful binding.  Fix it

	-- Death Knight
	[61999] = true,
}

addon.HarmfulWhitelist = {
	-- Druid
	[106830] = true,
	-- Shaman	
	[262395] = true,
	[210643] = true,
	[192222] = true,

	-- Demon Hunter
	[189110] = true,
	[204513] = true,
	[202140] = true,
	[207682] = true,
	[247454] = true,
	[198013] = true,
	[195072] = true,
	[204596] = true,
	[207684] = true,
	[202137] = true,
	[202138] = true,

	-- Mage
	[84714] = true,

	-- Paladin
	[115750] = true,
	[204019] = true,

	-- Hunter
	[187650] = true,
	[1462] = true,
	[109248] = true,
	[201430] = true,
	[162488] = true,

	-- Warrior
	[6544] = true,
	[262161] = true,

	-- Rogue
	[921] = true,
	[121411] = true,
	[195457] = true,
	[13877] = true,

	-- Priest
	[2096] = true,
	[48045] = true,

	-- Warlock
	[264130] = true, -- TODO:  Power Siphon should be both a helpful and harmful binding.  Fix it
	[267217] = true,

	-- Monk
	[115546] = true,
	[116844] = true,
	[123904] = true,
	[132578] = true,
	[101546] = true,

	-- Death Knight
	[279302] = true,
	[194913] = true,
}

addon.Racials = {
	["GIFT_OF_THE_NAARU"] = L["Gift of the Naaru"],
	["STONEFORM"] = L["Stoneform"],
	["ESCAPE_ARTIST"] = L["Escape Artist"],
	["EVERY_MAN_FOR_HIMSELF"] = L["Every Man for Himself"],
	["SHADOWMELD"] = L["Shadowmeld"],
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
