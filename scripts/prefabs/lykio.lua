local MakePlayerCharacter = require "prefabs/player_common"

-- This is for debugging purposes -------------------------------------------------
local function DebugPrint(...)
    print("[Lykio Character Debug]", ...)
end

local assets = {
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
    Asset("ANIM", "anim/lykio.zip")
}

local lykio_start_items = {
	"nightmarefuel",
	"nightmarefuel",
    "horrorfuel"
}

local prefabs = {
	"tier1",
    "tier2"
}

-- COLOURCUBES ---------------------------------------------------------------------
local NIGHTVISION_COLOURCUBES =
{
  night = "images/colour_cubes/purple_moon_cc.tex",
	full_moon = "images/colour_cubes/purple_moon_cc.tex"
}

local function seasoncheck(inst)
    DebugPrint("Configuring seasoncheck for night vision")
	if TheWorld.state.isautumn then
        DebugPrint("Configuring autumn night vision")
		NIGHTVISION_COLOURCUBES =
		{
			day = "images/colour_cubes/day05_cc.tex",
			dusk = "images/colour_cubes/dusk03_cc.tex",
			night = "images/colour_cubes/purple_moon_cc.tex",
			full_moon = "images/colour_cubes/purple_moon_cc.tex"
		}
	elseif TheWorld.state.iswinter then
        DebugPrint("Configuring winter night vision")
		NIGHTVISION_COLOURCUBES =
		{
			day = "images/colour_cubes/snow_cc.tex",
			dusk = "images/colour_cubes/snowdusk_cc.tex",
			night = "images/colour_cubes/purple_moon_cc.tex",
			full_moon = "images/colour_cubes/purple_moon_cc.tex"
		}
	elseif TheWorld.state.isspring then
        DebugPrint("Configuring spring night vision")
		NIGHTVISION_COLOURCUBES =
		{
			day = "images/colour_cubes/spring_day_cc.tex",
			dusk = "images/colour_cubes/spring_dusk_cc.tex",
			night = "images/colour_cubes/purple_moon_cc.tex",
			full_moon = "images/colour_cubes/purple_moon_cc.tex"
		}
	elseif TheWorld.state.issummer then
        DebugPrint("Configuring summer night vision")
		NIGHTVISION_COLOURCUBES =
		{
			day = "images/colour_cubes/summer_day_cc.tex",
			dusk = "images/colour_cubes/summer_dusk_cc.tex",
			night = "images/colour_cubes/purple_moon_cc.tex",
			full_moon = "images/colour_cubes/purple_moon_cc.tex"
		}
	end
end

-- Custom starting inventory ------------------------------------------------
TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.Lykio = lykio_start_items

local start_inv = {}
for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
    start_inv[string.lower(k)] = v.Lykio
end
local start_inv_F = FlattenTree(start_inv, true)

-- Slow down temperature adaptation ------------------------------------------------
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

-- Handle hunger modifications TODO : Configuring --------------------------------------
---@param inst EntityScript
local function ApplyHungerModifications(inst)
    DebugPrint("Applying hunger modifications")
    if inst.components.hunger then
        DebugPrint("Hunger component found")
    else
        DebugPrint("ERROR: No hunger component found")
    end
end

-- Configuring favoritefood -------------------------------------------------------------
---@param inst EntityScript
local function ConfigureEater(inst)
    local eater = inst.components.eater

    DebugPrint("Configuring eater")
    if eater then
        if inst.components.foodaffinity == nil then
            DebugPrint("Adding food affinity component")
            inst:AddComponent("foodaffinity")
        end

        inst.components.foodaffinity:AddFoodtypeAffinity(FOODTYPE.SOUL)
        inst:AddTag(FOODTYPE.SOUL.."_eater")
        inst:AddTag(TUNING.Lykio_FOOD_FAVORITE.."_eater")
        DebugPrint("Favorite food set to", TUNING.Lykio_FOOD_FAVORITE)

        eater:SetDiet({
            FOODTYPE.SOUL,
            FOODTYPE.RAW,
            FOODTYPE.MEAT,
            FOODTYPE.VEGGIE,
            FOODTYPE.MONSTER
        })

        eater:SetRefusesSpoiledFood(TUNING.Lykio_FOOD_SPOILED_IGNORE)
        eater:SetStrongStomach(TUNING.Lykio_STOMACH_STRONG)

        eater:SetOnEatFn(function (eater_inst, food)
            if food.components.edible and food.components.edible.foodtype == FOODTYPE.SOUL then
                DebugPrint("Updating eat function for", food.prefab)
                local rp = eater_inst.components.runicpower

                if rp then
                    if food.prefab == "horrorfuel" then
                        rp:DoDelta(TUNING.RUNICPOWER_HUGE, false, "eat_horrorfuel")
                        return true
                    end

                    rp:DoDelta(TUNING.RUNICPOWER_LARGE, false, "eat_soul")
                    return true
                end
            end
            return false
        end)
    else
        DebugPrint("ERROR: No eater component found")
    end
end

-- Handle night vision ------------------------------------------------------
---@param inst EntityScript
local function applynightvision(inst)
	if TUNING.Lykio_NIGHTVISION then
    DebugPrint("Configuring night vision listener")
		if inst.components.playervision then
			if inst.nightvision:value() then
				seasoncheck(inst)
				inst.components.playervision:SetCustomCCTable(NIGHTVISION_COLOURCUBES)
                DebugPrint("Setting night vision on")
				inst.components.playervision:ForceNightVision(true)
			else
                DebugPrint("Setting night vision off")
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
	if TUNING.Lykio_NIGHTVISION then
        DebugPrint("Initializing night vision")
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
	if inst:HasTag("playerghost") == false and TUNING.Lykio_NIGHTVISION then
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

-- Handle runic power system ----------------------------------------------------------
---@param inst RunicPower
local function SetupRunicPower(inst)
    DebugPrint("Setting up runic power system")
    
    if not inst.components.runicpower then
        DebugPrint("Adding runic power component")
        inst:AddComponent("runicpower")
    end
    
    local rp = inst.components.runicpower
    if rp then
        DebugPrint("Configuring runic power values")
        rp:SetMax(TUNING.Lykio_RunicPower)
        rp:SetCurrent(TUNING.Lykio_RunicPower / 2)
        rp:SetRegenRate(TUNING.Lykio_RunicPowerRegen)
        rp:SetRegenPeriod(TUNING.Lykio_RunicPowerRegenPeriod)
        
        DebugPrint("Starting runic power regeneration")
        rp:StartRegen()
    else
        DebugPrint("ERROR: Failed to set up runic power component")
    end
end

-- When the character is revived from human ---------------------------------------
---@param inst EntityScript
local function onbecamehuman(inst)
    local rp = inst.components.runicpower
    DebugPrint("Character became human")
    if rp ~= nil then rp:StartRegen() end
    inst.components.locomotor:SetExternalSpeedMultiplier(inst, "Lykio_speed_mod", 1)

    inst.taskNightVision = inst:DoPeriodicTask(0.25, checkphase)

    inst:ListenForEvent("death", function()
        DebugPrint("Stopping runic power regeneration on death")
        if rp ~= nil then rp:StopRegen() end
        inst.taskNightVision:Cancel()
        inst.taskNightVision = nil
    end)
end

-- When the character is revived from ghost --------------------------------------
---@param inst EntityScript
local function onbecameghost(inst)
    local rp = inst.components.runicpower
    DebugPrint("Character became ghost")
    inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "Lykio_speed_mod")

    if rp ~= nil then
        DebugPrint("Stopping runic power regeneration on ghost")
        rp:SetCurrent(0)
    end
end

-- When loading or spawning the character -------------------------------------------
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

-- This initializes for both the server and client. ----------------------------------
local common_postinit = function(inst)
    DebugPrint("Applying character modifications")
    inst:AddTag("lykio")

    DebugPrint("Setting up character properties")
    initializenightvision(inst)

    DebugPrint("Setting up runic power")
    SetupRunicPower(inst)

	-- Minimap icon
	inst.MiniMapEntity:SetIcon( "lykio.tex" )
end

-- This initializes for the server only. Components are added here. -------------------
local master_postinit = function(inst)
    DebugPrint("Starting master initialization")
    if TUNING.Lykio_NIGHTVISION then
        inst:WatchWorldState("phase", checkphase)
    end

    DebugPrint("Setting up inventory")
    inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default
    
    DebugPrint("Calculating final stats")
    calculateFinalStats(inst)

    DebugPrint("Setting up save/load handlers")
    inst.OnLoad = onload
    inst.OnNewSpawn = onload
    
    ApplyTemperatureResilience(inst)
    ApplyHungerModifications(inst)
    ConfigureEater(inst)
    
    DebugPrint("Master initialization complete")
end

return MakePlayerCharacter("lykio", prefabs, assets, common_postinit, master_postinit, start_inv_F)
