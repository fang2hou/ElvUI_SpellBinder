--[[
    ElvUI_SpellBinder
    Copyright (C) Nîne-Shu'halo, All rights reserved.
]]--

local E, L, V, P, G = unpack(ElvUI) -- Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local addonName, addon = ...

addon.HealingSpells = {
    ["PALADIN"] = {
        ["BEACON_OF_VIRTUE"] = L["Beacon of Virtue"],
        ["BEACON_OF_FAITH"] = L["Beacon of Faith"],
        ["BEACON_OF_LIGHT"] = L["Beacon of Light"],
        ["FLASH_OF_LIGHT"] = L["Flash of Light"],
        ["HOLY_LIGHT"] = L["Holy Light"],
        ["HOLY_SHOCK"] = L["Holy Shock"],
        ["LAY_ON_HANDS"] = L["Lay on Hands"],
        ["LIGHT_OF_DAWN"] = L["Light of Dawn"],
        ["LIGHT_OF_THE_PROTECTOR"] = L["Light of the Protector"],
        ["HAND_OF_THE_PROTECTOR"] = L["Hand of the Protector"],
        ["LIGHT_OF_THE_MARTYR"] = L["Light of the Martyr"],
        ["HOLY_RADIANCE"] = L["Holy Radiance"],
        ["HOLY_PRISM"] = L["Holy Prism"],
        ["WORD_OF_GLORY"] = L["Word of Glory"],
        ["DIVINE_LIGHT"] = L["Divine Light"],
        ["TYRS_DELIVERANCE"] = L["Tyr's Deliverance"],
        ["ETERNAL_FLAME"] = L["Eternal Flame"],
        ["BESTOW_FAITH"] = L["Bestow Faith"],
    },
    ["PRIEST"] = {
        ["FLASH_HEAL"] = L["Flash Heal"],
        ["PENANCE"] = L["Penance"],
        ["SHADOW_MEND"] = L["Shadow Mend"],
        ["HOLY_NOVA"] = L["Holy Nova"],
        ["POWER_WORD_RADIANCE"] = L["Power Word: Radiance"],
        ["RENEW"] = L["Renew"],
        ["HEAL"] = L["Heal"],
        ["HOLY_WORD_SERENITY"] = L["Holy Word: Serenity"],
        ["PRAYER_OF_MENDING"] = L["Prayer of Mending"],
        ["PRAYER_OF_HEALING"] = L["Prayer of Healing"],
        ["HOLY_WORD_SANCTIFY"] = L["Holy Word: Sanctify"],
        ["DESPERATE_PRAYER"] = L["Desperate Prayer"],
        ["DIVINE_HYMN"] = L["Divine Hymn"],
        ["BINDING_HEAL"] = L["Binding Heal"],
        ["CIRCLE_OF_HEALING"] = L["Circle of Healing"],
        ["GREATER_HEAL"] = L["Greater Heal"],
        ["CASCADE"] = L["Cascade"],
        ["DIVINE_STAR"] = L["Divine Star"],
        ["HALO"] = L["Halo"],
        ["SHADOW_COVENANT"] = L["Shadow Covenant"],
        ["BODY_AND_MIND"] = L["Body and Mind"],
    },
    ["SHAMAN"] = {
        ["CHAIN_HEAL"] = L["Chain Heal"],
        ["HEALING_RAIN"] = L["Healing Rain"],
        ["HEALING_SURGE"] = L["Healing Surge"],
        ["HEALING_TIDE_TOTEM"] = L["Healing Tide Totem"],
        ["HEALING_STREAM_TOTEM"] = L["Healing Stream Totem"],
        ["HEALING_WAVE"] = L["Healing Wave"],
        ["RIPTIDE"] = L["Riptide"],
        ["SPIRIT_LINK_TOTEM"] = L["Spirit Link Totem"],
        ["WELLSPRING"] = L["Wellspring"],
        ["UNLEASH_LIFE"] = L["Unleash Life"],
    },
    ["DRUID"] = {
        ["HEALING_TOUCH"] = L["Healing Touch"],
        ["LIFEBLOOM"] = L["Lifebloom"],
        ["REGROWTH"] = L["Regrowth"],
        ["REJUVENATION"] = L["Rejuvenation"],
        ["WILD_GROWTH"] = L["Wild Growth"],
        ["SWIFTMEND"] = L["Swiftmend"],
        ["TRANQUILITY"] = L["Tranquility"],
    },
    ["MONK"] = {
        ["SOOTHING_MIST"] = L["Soothing Mist"],
        ["ENVELOPING_MIST"] = L["Enveloping Mist"],
        ["RENEWING_MIST"] = L["Renewing Mist"],
        ["SURGING_MIST"] = L["Surging Mist"],
        ["REVIVAL"] = L["Revival"],
        ["UPLIFT"] = L["Uplift"],
        ["CHI_WAVE"] = L["Chi Wave"],
        ["ZEN_SPHERE"] = L["Zen Sphere"],
        ["CHI_BURST"] = L["Chi Burst"],
        ["CHI_EXPLOSION"] = L["Chi Explosion"],
        ["ESSENCE_FONT"] = L["Essence Font"],
    },
    ["WARRIOR"] = {
    },
    ["MAGE"] = {
    },
    ["HUNTER"] = {
        ["MEND_PET"] = L["Mend Pet"],
    },
    ["WARLOCK"] = {
        ["HEALTH_FUNNEL"] = L["Health Funnel"],
    },
	["DEMONHUNTER"] = {
	},
    ["RACIAL"] = {
        ["GIFT_OF_THE_NAARU"] = L["Gift of the Naaru"],
    },
}

addon.OtherSpells = {
    ["PALADIN"] = {
        ["ABSOLUTION"] = L["Absolution"],
        ["BLESSING_OF_FREEDOM"] = L["Blessing of Freedom"],
        ["BLESSING_OF_PROTECTION"] = L["Blessing of Protection"],
        ["BLESSING_OF_SACRIFICE"] = L["Blessing of Sacrifice"],
        ["CLEANSE"] = L["Cleanse"],
        ["CLEANSE_TOXIN"] = L["Cleanse Toxins"],
        ["DIVINE_PROTECTION"] = L["Divine Protection"],
        ["ARDENT_DEFENDER"] = L["Ardent Defender"],
        ["DIVINE_SHIELD"] = L["Divine Shield"],
        ["REDEMPTION"] = L["Redemption"],
    },
    ["PRIEST"] = {
        ["MIND_VISION"] = L["Mind Vision"],
        ["POWER_WORD_SHIELD"] = L["Power Word: Shield"],
        ["POWER_WORD_FORTITUDE"] = L["Power Word: Fortitude"],
        ["POWER_WORD_BARRIER"] = L["Power Word: Barrier"],
        ["PURIFY"] = L["Purify"],
        ["PURIFY_DISEASE"] = L["Purify Disease"],
        ["RESURRECTION"] = L["Resurrection"],
        ["PAIN_SUPPRESSION"] = L["Pain Suppression"],
        ["LEAP_OF_FAITH"] = L["Leap of Faith"],
        ["MASS_RESURRECTION"] = L["Mass Resurrection"],
        ["RESURRECTION"] = L["Resurrection"],
        ["FADE"] = L["Fade"],
        ["PSYCHIC_SCREAM"] = L["Psychic Scream"],
        ["MASS_DISPEL"] = L["Mass Dispel"],
        ["GUARDIAN_SPIRIT"] = L["Guardian Spirit"],
        ["SYMBOL_OF_HOPE"] = L["Symbol of Hope"],
        ["RAPTURE"] = L["Rapture"],
        ["LEVITATE"] = L["Levitate"],
        ["SPIRIT_SHELL"] = L["Spirit Shell"],
        ["SHINING_FORCE"] = L["Shining Force"],
        ["PAIN_SUPPRESSION"] = L["Pain Suppression"],
        ["POWER_INFUSION"] = L["Power Infusion"],
        ["VALPIRIC_EMBRACE"] = L["Vampiric Embrace"],
        ["CLARITY_OF_WILL"] = L["Clarity of Will"],
        ["APOTHEOSIS"] = L["Apotheosis"],
        ["SYMBOL_OF_HOPE"] = L["Symbol of Hope"],
    },
    ["SHAMAN"] = {
        ["ANCESTRAL_SPIRIT"] = L["Ancestral Spirit"],
        ["ANCESTRAL_VISION"] = L["Ancestral Vision"],
        ["ASTRAL_SHIFT"] = L["Astral Shift"],
        ["PURIFY_SPIRIT"] = L["Purify Spirit"],
        ["WATER_WALKING"] = L["Water Walking"],
        ["CLEANSE_SPIRIT"] = L["Cleanse Spirit"],
        ["PURIFY_SPIRIT"] = L["Purify Spirit"],
        ["CLOUDBURST_TOTEM"] = L["Cloudburst Totem"],
    },
    ["DRUID"] = {
        ["CENARION_WARD"] = L["Cenarion Ward"],
        ["REVIVE"] = L["Revive"],
        ["REBIRTH"] = L["Rebirth"],
        ["TREE_OF_LIFE"] = L["Tree of Life"],
        ["REVITALIZE"] = L["Revitalize"],
        ["REMOVE_CORRUPTION"] = L["Remove Corruption"],
        ["NATURES_CURE"] = L["Nature's Cure"],
    },
    ["MONK"] = {
        ["ZEN_MEDITATION"] = L["Zen Meditation"],
        ["LIFE_COCOON"] = L["Life Cocoon"],
        ["CHI_TORPEDO"] = L["Chi Torpedo"],
        ["REAWAKEN"] = L["Reawaken"],
        ["RESUSCITATE"] = L["Resuscitate"],
        ["DETOX"] = L["Detox"],
        ["THUNDER_FOCUS_TEA"] = L["Thunder Focus Tea"],
        ["DETONATE_CHI"] = L["Detonate Chi"],
    },
    ["WARRIOR"] = {
        ["INTERVENE"] = L["Intervene"],
    },
    ["MAGE"] = {
        ["REMOVE_CURSE"] = L["Remove Curse"],
    },
    ["HUNTER"] = {
    },
    ["WARLOCK"] = {
        ["LIFE_TAP"] = L["Life Tap"],
    },
	["DEMONHUNTER"] = {
		["DEMON_SPIKES"] = L["Demon Spikes"],
		["IMMOLATION_AURA"] = L["Immolation Aura"],
		["SOUL_BARRIER"] = L["Soul Barrier"],

	},
    ["RACIAL"] = {
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
    },
}
