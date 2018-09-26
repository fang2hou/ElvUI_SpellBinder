--[[-------------------------------------------------------------------------
-- BlizzardFrames.lua
--
-- This file contains the definitions of the blizzard frame integration
-- options. These settings will not apply until the user interface is
-- reloaded.
--
-- Events registered:
--   * ADDON_LOADED - To watch for loading of the ArenaUI
--
-- This file has been shamelessly taken from Clique.  All credit to the
-- author/maintainer of that addon.
-------------------------------------------------------------------------]]--

local addonName, addon = ...

ClickCastFrames = ClickCastFrames or {}

--[[---------------------------------------------------------------------------
--  Blizzard Frame integration code
---------------------------------------------------------------------------]]--
local function enable(frame)
    if type(frame) == "string" then
        local frameName = frame
        frame = _G[frameName]
        if not frame then
            print("SpellBinder: error registering frame: " .. tostring(frameName))
        end
    end

    -- don't try to register anything that isn't "buttonish"
    if frame and not frame.RegisterForClicks then
        return
    end

    -- skip the nameplates, they're TEHBROKEN
    if frame and frame.GetName and frame:GetName():match("^NamePlate") then
        return
    end

    ClickCastFrames[frame] = true
end

function addon:Enable_BlizzCompactUnitFrames()
   --[[ if not addon.settings.blizzframes.compactraid then
        return
    end]]

    hooksecurefunc("CompactUnitFrame_SetUpFrame", function(frame, ...)
        -- For the moment we cannot handle 'forbidden' frames
        if frame.IsForbidden and frame:IsForbidden() then
            return
        end

        local name = frame and frame.GetName and frame:GetName()
        for i = 1, 3 do
            local buff = _G[name .. "Buff" .. i]
            local debuff = _G[name .. "Debuff" .. i]
            local dispel = _G[name .. "DispelDebuff" .. i]
			local statusIcon = _G[name .. "CenterStatusIcon" .. i]

            if buff then enable(buff) end
            if debuff then enable(debuff) end
            if dispel then enable(dispel) end
			if statusIcon then enable(statusIcon) end
        end
        enable(frame)
    end)
end

function addon:Enable_BlizzArenaFrames()
    --[[if not addon.settings.blizzframes.arena then
        return
    end]]

    local frames = {
        "ArenaEnemyFrame1",
        "ArenaEnemyFrame2",
        "ArenaEnemyFrame3",
        "ArenaEnemyFrame4",
        "ArenaEnemyFrame5",
    }
    for _, frame in ipairs(frames) do
        enable(frame)
    end
end

function addon:Enable_BlizzSelfFrames()
    local frames = {
        "PlayerFrame",
        "PetFrame",
        "TargetFrame",
        "TargetFrameToT",
        "FocusFrame",
        "FocusFrameToT",
    }
    for _, frame in ipairs(frames) do
        --if addon.settings.blizzframes[frame] then
            enable(frame)
        --end
    end
end

function addon:Enable_BlizzPartyFrames()
    --[[if not addon.settings.blizzframes.party then
        return
    end]]

    local frames = {
        "PartyMemberFrame1",
		"PartyMemberFrame2",
		"PartyMemberFrame3",
		"PartyMemberFrame4",
        --"PartyMemberFrame5",
		"PartyMemberFrame1PetFrame",
		"PartyMemberFrame2PetFrame",
		"PartyMemberFrame3PetFrame",
        "PartyMemberFrame4PetFrame",
        --"PartyMemberFrame5PetFrame",
    }
    for _, frame in ipairs(frames) do
        enable(frame)
    end
end

function addon:Enable_BlizzBossFrames()
    --[[if not addon.settings.blizzframes.boss then
        return
    end]]

    local frames = {
        "Boss1TargetFrame",
        "Boss2TargetFrame",
        "Boss3TargetFrame",
        "Boss4TargetFrame",
    }
    for idx, frame in ipairs(frames) do
        enable(frame)
    end
end

function addon:EnableBlizzardFrames()
    addon:Enable_BlizzCompactUnitFrames()
    addon:Enable_BlizzSelfFrames()
    addon:Enable_BlizzPartyFrames()
    addon:Enable_BlizzBossFrames()

    local waitForAddon = {}

    if IsAddOnLoaded("Blizzard_ArenaUI") then
        addon:Enable_BlizzArenaFrames()
    else
        waitForAddon["Blizzard_ArenaUI"] = "Enable_BlizzArenaFrames"
    end

    if next(waitForAddon) then
        local frame = CreateFrame("Frame")
        frame:RegisterEvent("ADDON_LOADED")
        frame:SetScript("OnEvent", function(frame, event, ...)
            if waitForAddon[...] then
                self[waitForAddon[...]](self)
            end
        end)

        if not next(waitForAddon) then
            frame:UnregisterEvent("ADDON_LOADED")
            frame:SetScript("OnEvent", nil)
        end
    end
end
