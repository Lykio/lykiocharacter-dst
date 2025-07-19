local MakePlayerCharacter = require "prefabs/player_common"
local RP = nil

-- This is for debugging purposes
local function DebugPrint(...)
    print("[Lykio Character Debug]", ...)
end

local assets = {
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
    Asset("ANIM", "anim/lykio.zip"),  -- Your character's custom animations
}

local lykio_start_items = {
	"nightmarefuel",
	"nightmarefuel"
}

local prefabs = {
    -- Tier 1
	"runicaxe",
	"runicpickaxe",
	"runicshovel",
    "runichammer",
    "runichoe",
    "runicspear",
    "runictunic",
    "runicworkbench",
    -- Tier 2
    "frostfirehatchet",
    "frostfirepike",
    "soulboundspade",
    "soulboundhammer",
    "runicclawblades",
    "necroticfangdagger",
    "runeboundarmor",
    "minorbifrost",
    "frozenruneband",
    -- Tier 3 TODO : Add more items
    "",
    -- Tier 4 TODO : Add more items
    ""
}

-- Your character's stats
TUNING.Lykio_HEALTH = 145
TUNING.Lykio_HUNGER = 265
TUNING.Lykio_SANITY = 120
TUNING.Lykio_RunicPower = 100
TUNING.Lykio_RunicPowerRegen = 1
TUNING.Lykio_RunicPowerRegenPeriod = 10
TUNING.Lykio_Speed = 1.0
TUNING.Lykio_SanityDrain = 1.0

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
        
        -- Add a throttle to debug prints
        local last_debug_time = 0
        local DEBUG_THROTTLE = 1 -- seconds between prints

        inst.components.hunger.DoDelta = function(self, delta, ...)
            local current_time = GetTime()
            if current_time - last_debug_time >= DEBUG_THROTTLE then
                DebugPrint("Original hunger delta:", delta)
                last_debug_time = current_time
            end
            
            if delta > 0 then
                local is_insane = inst.components.sanity:IsCrazy()
                DebugPrint("Is insane:", is_insane)
                
                local modifier = 1 -- TODO FIX THIS LMAO
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

-- Handle night vision TODO : This doesn't work
local function ApplyNightVision(inst)
    DebugPrint("Applying night vision")
    if not inst.components.playervision then
        DebugPrint("WARNING: No playervision component found")
        return
    end

    -- Add nightvision if it doesn't exist
    if inst.components.playervision ~= nil then
        inst.components.playervision:SetCustomCCTable("images/color_cubes/cc_meta.tex")
    end
end

-- Handle runic power system
local function SetupRunicPower(inst)
    DebugPrint("Setting up runic power system")
    
    if not inst.components.runicpower then
        DebugPrint("Adding runic power component")
        inst:AddComponent("runicpower")
    end
    
    RP = inst.components.runicpower
    if RP then
        DebugPrint("Configuring runic power values")
        RP:SetMax(100)
        RP:SetCurrent(50)
        RP:SetRegenRate(1)
        RP:SetRegenPeriod(10)
        
        DebugPrint("Starting runic power regeneration")
        RP:StartRegen()
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
    DebugPrint("Applying character modifications")
    inst:AddTag("lykio")

    DebugPrint("Setting up character properties")
    ApplyTemperatureResilience(inst)
    ApplyHungerModifications(inst)
    ApplyNightVision(inst)

    DebugPrint("Setting up runic power")
    SetupRunicPower(inst)
    if RP then
        DebugPrint("Runic power component found, setting up meter")
        RP:CreateMeter()
    else
        DebugPrint("ERROR: Runic power component not found")
    end

	-- Minimap icon
	inst.MiniMapEntity:SetIcon( "lykio.tex" )
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

    
    DebugPrint("Setting up save/load handlers")
    inst.OnLoad = onload
    inst.OnNewSpawn = onload
    
    DebugPrint("Master initialization complete")
end

return MakePlayerCharacter("lykio", prefabs, assets, common_postinit, master_postinit, start_inv_F)
