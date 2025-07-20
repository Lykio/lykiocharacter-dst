local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS

local MakePlayerCharacter = require "prefabs/player_common"

---@type RunicPower
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
	"tier1",
    "tier2"
}

--nightvision colorcubes
local NIGHTVISION_COLOURCUBES =
{
  night = "images/colour_cubes/purple_moon_cc.tex",
	full_moon = "images/colour_cubes/purple_moon_cc.tex"
}

local function seasoncheck(inst)
	if TheWorld.state.isautumn then
		NIGHTVISION_COLOURCUBES =
		{
			day = "images/colour_cubes/day05_cc.tex",
			dusk = "images/colour_cubes/dusk03_cc.tex",
			night = "images/colour_cubes/purple_moon_cc.tex",
			full_moon = "images/colour_cubes/purple_moon_cc.tex"
		}
	elseif TheWorld.state.iswinter then
		NIGHTVISION_COLOURCUBES =
		{
			day = "images/colour_cubes/snow_cc.tex",
			dusk = "images/colour_cubes/snowdusk_cc.tex",
			night = "images/colour_cubes/purple_moon_cc.tex",
			full_moon = "images/colour_cubes/purple_moon_cc.tex"
		}
	elseif TheWorld.state.isspring then
		NIGHTVISION_COLOURCUBES =
		{
			day = "images/colour_cubes/spring_day_cc.tex",
			dusk = "images/colour_cubes/spring_dusk_cc.tex",
			night = "images/colour_cubes/purple_moon_cc.tex",
			full_moon = "images/colour_cubes/purple_moon_cc.tex"
		}
	elseif TheWorld.state.issummer then
		NIGHTVISION_COLOURCUBES =
		{
			day = "images/colour_cubes/summer_day_cc.tex",
			dusk = "images/colour_cubes/summer_dusk_cc.tex",
			night = "images/colour_cubes/purple_moon_cc.tex",
			full_moon = "images/colour_cubes/purple_moon_cc.tex"
		}
	end
end

-- Your character's stats
TUNING.Lykio_HEALTH = 145
TUNING.Lykio_HUNGER = 265
TUNING.Lykio_SANITY = 120
TUNING.Lykio_SANITYDRAIN = 1.0

TUNING.Lykio_DAMAGE = 1
TUNING.Lykio_SPEED = 1.0
TUNING.LYKIO.NIGHTVISION = true

TUNING.Lykio_WINTER_INSULATION = 1
TUNING.Lykio_SUMMER_INSULATION = 1
TUNING.Lykio_WETNESS_INSULATION = 1

TUNING.Lykio_RunicPower = 100
TUNING.Lykio_RunicPowerRegen = 1
TUNING.Lykio_RunicPowerRegenPeriod = 10

-- Eater settings
TUNING.Lykio_FOOD_FAVORITE = "nightmarefuel"
TUNING.Lykio_FOOD_SPOILED_IGNORE = false
TUNING.Lykio_FOOD_PREFERENCE = { FOODGROUP.RAW }
TUNING.Lykio_FOOD_TOLERANCE = { FOODGROUP.OMNI }
TUNING.Lykio_STOMACH_STRONG = true


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

-- Slow down temperature adaptation
---@param inst EntityScript
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

-- Handle hunger modifications TODO : Configuring
---@param inst EntityScript
local function ApplyHungerModifications(inst)
    DebugPrint("Applying hunger modifications")
    if inst.components.hunger then
        DebugPrint("Hunger component found")
    else
        DebugPrint("ERROR: No hunger component found")
    end
end

-- Configuring favoritefood
---@param inst EntityScript
local function ConfigureEater(inst)
    DebugPrint("Configuring eater")
    if inst.components.eater then
        inst.components.eater:SetFavoriteFood(TUNING.Lykio_FOOD_FAVORITE)
        inst:AddTag(TUNING.Lykio_FOOD_FAVORITE.."_eater")
        DebugPrint("Favorite food set to", TUNING.Lykio_FOOD_FAVORITE)

        inst.components.eater.soul.foodtype = "soul"
        inst.components.eater.soul.healthvalue = TUNING.HEALING_MED
        inst.components.eater.soul.hungervalue = TUNING.CALORIES_HUGE
        inst.components.eater.soul.sanityvalue = TUNING.SANITY_MED

        inst.components.eater.caneat = {
            inst.components.eater.soul.foodtype,
            FOODTYPE.RAW,
            FOODTYPE.MEAT,
            FOODTYPE.VEGGIE,
            FOODTYPE.BERRY
        }

        inst.components.eater.preferseating = {
            inst.components.eater.soul.foodtype,
            FOODTYPE.MEAT
        }

        inst.components.eater:SetRefusesSpoiledFood(TUNING.Lykio_FOOD_SPOILED_IGNORE)
        inst.components.eater:SetStrongStomach(TUNING.Lykio_STOMACH_STRONG)

        inst.components.eater:SetOnEatFn(function (eater, food)
            if food.prefab == TUNING.Lykio_FOOD_FAVORITE then
                eater.components.health:DoDelta(TUNING.HEALING_MED, false, "lykio_eat_favorite")
                eater.components.hunger:DoDelta(TUNING.CALORIES_HUGE, false, "lykio_eat_favorite")
                eater.components.sanity:DoDelta(TUNING.SANITY_MED, false, "lykio_eat_favorite")
                RP:DoDelta(20, false, "lykio_eat_favorite")
                return true
            end
        end)
    else
        DebugPrint("ERROR: No eater component found")
    end
end

-- Handle night vision
---@param inst EntityScript
local function applynightvision(inst)
	if TUNING.NIGHTVISION == 1 then
		if inst.components.playervision then
			if inst.nightvision:value() then
				seasoncheck(inst)
				inst.components.playervision:SetCustomCCTable(NIGHTVISION_COLOURCUBES)
				inst.components.playervision:ForceNightVision(true)
			else
				inst.components.playervision:ForceNightVision(false)
			end
		end
	end
end

---@param inst EntityScript
local function registernightvisionlistener(inst)
	inst:ListenForEvent("nightvisiondirty", applynightvision)
end

---@param inst EntityScript
local function initializenightvision(inst)
	if TUNING.NIGHTVISION == 1 then
		inst.nightvision = net_bool(inst.GUID, "player.nightvision", "nightvisiondirty")
		inst.nightvision:set(false)
		inst:DoTaskInTime(0, registernightvisionlistener)
	end
end

---@param inst EntityScript
local function checkphase(inst)
	if inst.task1 ~= nil then
		inst.task1:Cancel()
		inst.task1 = nil
	end
	if inst:HasTag("playerghost") == false and TUNING.NIGHTVISION == 1 then
		if TheWorld:HasTag("cave") then
			inst.components.playervision:SetCustomCCTable(NIGHTVISION_COLOURCUBES)
			inst.components.playervision:ForceNightVision(true)
			initializenightvision(inst)
			inst.nightvision:set(true)
		elseif TheWorld.state.phase == "day" then
			inst.nightvision:set(false)
		elseif TheWorld.state.phase == "dusk" then
			inst.nightvision:set(false)
		elseif TheWorld.state.phase == "night" then
			inst.components.playervision:SetCustomCCTable(NIGHTVISION_COLOURCUBES)
			inst.components.playervision:ForceNightVision(true)
			inst.nightvision:set(true)

		end
	end
end

-- Handle runic power system
---@param inst RunicPower
local function SetupRunicPower(inst)
    DebugPrint("Setting up runic power system")
    
    if not inst.components.runicpower then
        DebugPrint("Adding runic power component")
        inst:AddComponent("runicpower")
    end
    
    RP = inst.components.runicpower
    if RP then
        DebugPrint("Configuring runic power values")
        RP:SetMax(TUNING.Lykio_RunicPower)
        RP:SetCurrent(TUNING.Lykio_RunicPower / 2)
        RP:SetRegenRate(TUNING.Lykio_RunicPowerRegen)
        RP:SetRegenPeriod(TUNING.Lykio_RunicPowerRegenPeriod)
        
        DebugPrint("Starting runic power regeneration")
        RP:StartRegen()
    else
        DebugPrint("ERROR: Failed to set up runic power component")
    end
end

-- When the character is revived from human
---@param inst EntityScript
local function onbecamehuman(inst)
    DebugPrint("Character became human")
    if RP ~= nil then RP:StartRegen() end
    inst.components.locomotor:SetExternalSpeedMultiplier(inst, "Lykio_speed_mod", 1)

    taskNightVision = inst:DoPeriodicTask(0.25, checkphase)

    inst:ListenForEvent("death", function()
        taskNightVision:Cancel()
        taskNightVision = nil
    end)
end

-- When the character is revived from ghost
---@param inst EntityScript
local function onbecameghost(inst)
    DebugPrint("Character became ghost")
    inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "Lykio_speed_mod")

    if RP ~= nil then
        DebugPrint("Stopping runic power regeneration on ghost")
        RP:SetCurrent(0)
        RP:StopRegen()
    end
end

-- When loading or spawning the character
---@param inst EntityScript
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

---@param inst EntityScript
local function calculateFinalStats(inst)
    DebugPrint("Setting up character stats")
    inst.components.health:SetMaxHealth(TUNING.Lykio_HEALTH)
    inst.components.hunger:SetMax(TUNING.Lykio_HUNGER)
    inst.components.sanity:SetMax(TUNING.Lykio_SANITY)
    
    DebugPrint("Setting up combat and hunger rates")
    inst.components.combat.damagemultiplier = 1
    inst.components.hunger.hungerrate = 1 * TUNING.WILSON_HUNGER_RATE
end

-- This initializes for both the server and client. Tags can be added here.
local common_postinit = function(inst)
    DebugPrint("Applying character modifications")
    inst:AddTag("lykio")

    DebugPrint("Setting up character properties")
    ApplyTemperatureResilience(inst)
    ApplyHungerModifications(inst)
    ConfigureEater(inst)
    initializenightvision(inst)

    DebugPrint("Setting up runic power")
    SetupRunicPower(inst)

	-- Minimap icon
	inst.MiniMapEntity:SetIcon( "lykio.tex" )
end

-- This initializes for the server only. Components are added here.
local master_postinit = function(inst)
    DebugPrint("Starting master initialization")
    if TUNING.NIGHTVISION == 1 then
        inst:WatchWorldState("phase", checkphase)
    end
    
    DebugPrint("Setting up inventory")
    inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default
    
    DebugPrint("Calculating final stats")
    calculateFinalStats(inst)

    DebugPrint("Setting up save/load handlers")
    inst.OnLoad = onload
    inst.OnNewSpawn = onload
    
    DebugPrint("Master initialization complete")
end

return MakePlayerCharacter("lykio", prefabs, assets, common_postinit, master_postinit, start_inv_F)
