local MakePlayerCharacter = require "prefabs/player_common"
local RP = require "components/runicpower"

-- This is for debugging purposes
local function DebugPrint(...)
    print("[Lykio Character Debug]", ...)
end

local assets = {
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
}

local lykio_start_items = {
	"nightmarefuel",
	"nightmarefuel"
}

local prefabs = {
	"frozen_runeband",
	"minor_bifrost",
	"necrotic_fang_dagger"
}

-- Your character's stats
TUNING.Lykio_HEALTH = 145
TUNING.Lykio_HUNGER = 265
TUNING.Lykio_SANITY = 120

-- Buff staves durabilities
TUNING.Lykio_FIRESTAFF_USES = math.floor(TUNING.FIRESTAFF_USES * 2.5)
TUNING.Lykio_ICESTAFF_USES = math.floor(TUNING.ICESTAFF_USES * 2.5)
TUNING.Lykio_TELESTAFF_USES = math.floor(TUNING.TELESTAFF_USES * 2.5)

-- Custom starting inventory
TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.Lykio = lykio_start_items

local start_inv = {}
for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
    start_inv[string.lower(k)] = v.Lykio
end
local start_inv_F = FlattenTree(start_inv, true)

--[[
local function OnLoad(inst, data)
	if data then
		-- TODO: loading logic
		if data.is_feral_form then
			inst:AddTag("feralform")
		else
			inst:RemoveTag("feralform")
			data.is_feral_form = false
		end
	end
end

local function OnSave(inst, data)
	if data then
		if data.is_feral_form then
			data.is_feral_form = inst:HasTag("feralform")
		else
			data.is_feral_form = false
		end
	end
end
]]

-- Handle temperature adaptation
local function ApplyTemperatureResilience(inst)
    DebugPrint("Applying temperature resilience")
    if inst.components.temperature then
        DebugPrint("Temperature component found")
        local old_DoDelta = inst.components.temperature.DoDelta
        inst.components.temperature.DoDelta = function(self, delta, ...)
            DebugPrint("Temperature delta:", delta, "Modified delta:", delta * 0.5)
            return old_DoDelta(self, delta * 0.5, ...)
        end
    else
        DebugPrint("ERROR: No temperature component found")
    end
end

-- Handle hunger modifications
local function ApplyHungerModifications(inst)
    DebugPrint("Applying hunger modifications")
    if inst.components.hunger then
        DebugPrint("Hunger component found")
        local old_DoDelta = inst.components.hunger.DoDelta
        inst.components.hunger.DoDelta = function(self, delta, ...)
            DebugPrint("Original hunger delta:", delta)
            if delta > 0 then
                local is_insane = inst.components.sanity:IsCrazy()
                DebugPrint("Is insane:", is_insane)
                
                local modifier = is_insane and 0.33 or 0.67
                DebugPrint("Using modifier:", modifier)
                
                delta = delta * modifier
                DebugPrint("Modified hunger delta:", delta)
            end
            return old_DoDelta(self, delta, ...)
        end
    else
        DebugPrint("ERROR: No hunger component found")
    end
end

-- Handle night vision
local function ApplyNightVision(inst)
    -- This would need to be implemented with proper vision radius modifications
    -- For now, this is a placeholder
    inst.components.playervision:SetNightVision(true)
end

-- Handle runic power system
local function SetupRunicPower(inst)
    DebugPrint("Setting up runic power system")
    
    if not inst.components.runicpower then
        DebugPrint("Adding runic power component")
        inst:AddComponent("runicpower")
    end
    
    local runic_power = inst.components.runicpower
    if runic_power then
        DebugPrint("Configuring runic power values")
        runic_power:SetMax(100)
        runic_power:SetCurrent(50)
        runic_power:SetRegenRate(1)
        runic_power:SetRegenPeriod(10)
        
        DebugPrint("Starting runic power regeneration")
        runic_power:StartRegen()
        
        -- Set up callbacks
        DebugPrint("Setting up runic power callbacks")
        runic_power.onrunicpowerchange = function(inst, current, old_current)
            DebugPrint("Runic power changed:", old_current, "->", current)
            if inst.HUD and inst.HUD.controls and inst.HUD.controls.runicpower then
                inst.HUD.controls.runicpower:SetValue(current)
            end
        end
    else
        DebugPrint("ERROR: Failed to set up runic power component")
    end
end

-- When the character is revived from human
local function onbecamehuman(inst)
    DebugPrint("Character became human")
    inst.components.locomotor:SetExternalSpeedMultiplier(inst, "Lykio_speed_mod", 1)
end

-- When the character is revived from ghost
local function onbecameghost(inst)
    DebugPrint("Character became ghost")
    inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "Lykio_speed_mod")
end

-- When loading or spawning the character
local function onload(inst)
    DebugPrint("Loading character")
    inst:ListenForEvent("ms_respawnedfromghost", onbecamehuman)
    inst:ListenForEvent("ms_becameghost", onbecameghost)

    if inst:HasTag("playerghost") then
        DebugPrint("Initializing as ghost")
        onbecameghost(inst)
    else
        DebugPrint("Initializing as human")
        onbecamehuman(inst)
    end
end


-- This initializes for both the server and client. Tags can be added here.
local common_postinit = function(inst) 
	-- Minimap icon
	inst.MiniMapEntity:SetIcon( "Lykio.tex" )
end

-- This initializes for the server only. Components are added here.
local master_postinit = function(inst)
    DebugPrint("Starting master initialization")
    
    DebugPrint("Setting up inventory")
    inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default
    
    DebugPrint("Setting up character stats")
    inst.components.health:SetMaxHealth(TUNING.Lykio_HEALTH)
    inst.components.hunger:SetMax(TUNING.Lykio_HUNGER)
    inst.components.sanity:SetMax(TUNING.Lykio_SANITY)
    
    DebugPrint("Setting up combat and hunger rates")
    inst.components.combat.damagemultiplier = 1
    inst.components.hunger.hungerrate = 1 * TUNING.WILSON_HUNGER_RATE

    DebugPrint("Applying character modifications")
    ApplyTemperatureResilience(inst)
    ApplyHungerModifications(inst)
    ApplyNightVision(inst)

    DebugPrint("Setting up runic power")
    SetupRunicPower(inst)
    
    DebugPrint("Setting up save/load handlers")
    inst.OnSave = onsave
    inst.OnLoad = onload
    inst.OnNewSpawn = onload
    
    DebugPrint("Master initialization complete")
end

return MakePlayerCharacter("Lykio", prefabs, assets, common_postinit, master_postinit, start_inv_F)
