--[[
    ElvUI_SpellBinder
    Copyright (C) Nîne-Shu'halo, All rights reserved.
]]--

local E, L, V, P, G = unpack(ElvUI) -- Engine, Locales, PrivateDB, ProfileDB, GlobalDB

V.SpellBinder = {}
V.SpellBinder.HealingSpells = {
    ["PALADIN"] = {
        ["BEACON_OF_VIRTUE"] = "Beacon of Virtue",
        ["FLASH_OF_LIGHT"] = "Flash of Light",
        ["HOLY_LIGHT"] = "Holy Light",
        ["HOLY_SHOCK"] = "Holy Shock",
        ["LAY_ON_HANDS"] = "Lay on Hands",
        ["LIGHT_OF_DAWN"] = "Light of Dawn",
        ["LIGHT_OF_THE_PROTECTOR"] = "Light of the Protector",
        ["HAND_OF_THE_PROTECTOR"] = "Hand of the Protector",
        ["LIGHT_OF_THE_MARTYR"] = "Light of the Martyr"
    },
    ["PRIEST"] = {
        ["FLASH_HEAL"] = "Flash Heal",
        ["PENANCE"] = "Penance",
        ["SHADOW_MEND"] = "Shadow Mend",
        ["HOLY_NOVA"] = "Holy Nova",
        ["POWER_WORD_RADIANCE"] = "Power Word: Radiance",
        ["RENEW"] = "Renew",
        ["HEAL"] = "Heal",
        ["HOLY_WORD_SERENITY"] = "Holy Word: Serenity",
        ["PRAYER_OF_MENDING"] = "Prayer of Mending",
        ["PRAYER_OF_HEALING"] = "Prayer of Healing",
        ["HOLY_WORD_SANCTIFY"] = "Holy Word: Sanctify",
        ["DESPERATE_PRAYER"] = "Desperate Prayer",
        ["DIVINE_HYMN"] = "Divine Hymn",
    },
    ["SHAMAN"] = {
        ["CHAIN_HEAL"] = "Chain Heal",
        ["HEALING_RAIN"] = "Healing Rain",
        ["HEALING_SURGE"] = "Healing Surge",
        ["HEALING_TIDE_TOTEM"] = "Healing Tide Totem",
        ["HEALING_WAVE"] = "Healing Wave",
        ["RIPTIDE"] = "Riptide",
        ["SPIRIT_LINK_TOTEM"] = "Spirit Link Totem",

    },
    ["RACIAL"] = {
        ["GIFT_OF_THE_NAARU"] = "Gift of the Naaru",
    },
}

V.SpellBinder.OtherSpells = {
    ["PALADIN"] = {
        ["ABSOLUTION"] = "Absolution",
        ["BLESSING_OF_FREEDOM"] = "Blessing of Freedom",
        ["BLESSING_OF_PROTECTION"] = "Blessing of Protection",
        ["BLESSING_OF_SACRIFICE"] = "Blessing of Sacrifice",
        ["CLEANSE"] = "Cleanse",
        ["DIVINE_PROTECTION"] = "Divine Protection",
        ["DIVINE_SHIELD"] = "Divine Shield",
        ["REDEMPTION"] = "Redemption"
    },
    ["PRIEST"] = {
        ["MIND_VISION"] = "Mind Vision",
        ["POWER_WORD_SHIELD"] = "Power Word: Shield",
        ["POWER_WORD_FORTITUDE"] = "Power Word: Fortitude",
        ["POWER_WORD_BARRIER"] = "Power Word: Barrier",
        ["PURIFY"] = "Purify",
        ["RESURRECTION"] = "Resurrection",
        ["DESPERATE_PRAYER"] = "Desperate Prayer",
        ["PAIN_SUPPRESSION"] = "Pain Suppression",
        ["LEAP_OF_FAITH"] = "Leap of Faith",
        ["MASS_RESURRECTION"] = "Mass Resurrection",
        ["RESURRECTION"] = "Resurrection",
        ["FADE"] = "Fade",
        ["PSYCHIC_SCREAM"] = "Psychic Scream",
        ["MASS_DISPEL"] = "Mass Dispel",
        ["GUARDIAN_SPIRIT"] = "Guardian Spirit",
        ["SYMBOL_OF_HOPE"] = "Symbol of Hope",
        ["RAPTURE"] = "Rapture",
    },
    ["SHAMAN"] = {
        ["ANCESTRAL_SPIRIT"] = "Ancestral Spirit",
        ["ANCESTRAL_VISION"] = "Ancestral Vision",
        ["ASTRAL_SHIFT"] = "Astral Shift",
        ["PURIFY_SPIRIT"] = "Purify Spirit",
        ["WATER_WALKING"] = "Water Walking",
    },
    ["RACIAL"] = {
        ["STONEFORM"] = "Stoneform",
        ["ESCAPE_ARTIST"] = "Escape Artist",
        ["EVERY_MAN_FOR_HIMSELF"] = "Every Man for Himself",
        ["SHADOW_MELD"] = "Shadow Meld",
        ["DARKFLIGHT"] = "Darkflight",
        ["TWO_FORMS"] = "Two Forms",
        ["RUNNING_WILD"] = "Running Wild",
        ["SPATIAL_RIFT"] = "Spatial Rift",
        ["FIREBLOOD"] = "Fireblood",
        ["MOLE_MACHINE"] = "Mole Machine",
        ["BLOOD_FURY"] = "Blood Fury",
        ["WAR_STOME"] = "War Stomp",
        ["BERSERKING"] = "Berserking",
        ["WILL_OF_THE_FORSAKEN"] = "Will of the Forsaken",
        ["ARCANE_TORRENT"] = "Arcane Torrent",
        ["ROCKET_JUMP"] = "Rocket Jump",
        ["BULL_RUSH"] = "Bull Rush",
        ["CANTRIPS"] = "Cantrips",
        ["ANCESTRAL_CALL"] = "Ancestral Call",
        ["SYMPATHETIC_VIGOR"] = "Sympathetic Vigor",
        ["FORGE_OF_LIGHT"] = "Forge of Light",
    },
}

V.SpellBinder.Items = { }
