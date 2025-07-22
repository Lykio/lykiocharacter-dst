local MakePlayerCharacter = require "prefabs/player_common"
local rpbadge = require("widgets/rpbadge")


local Assets = {
    --common
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
    Asset("ANIM", "anim/lykio.zip"),
    --badge
    Asset("SCRIPT", "scripts/widgets/rpbadge.lua"),

    --nightvision
    Asset("IMAGE", "images/colour_cubes/purple_moon_cc.tex"),
    Asset("IMAGE", "images/colour_cubes/day05_cc.tex"),
    Asset("IMAGE", "images/colour_cubes/dusk03_cc.tex"),
    Asset("IMAGE", "images/colour_cubes/snow_cc.tex"),
    Asset("IMAGE", "images/colour_cubes/snowdusk_cc.tex"),
    Asset("IMAGE", "images/colour_cubes/spring_day_cc.tex"),
    Asset("IMAGE", "images/colour_cubes/spring_dusk_cc.tex"),
    Asset("IMAGE", "images/colour_cubes/summer_day_cc.tex"),
    Asset("IMAGE", "images/colour_cubes/summer_dusk_cc.tex"),
}

local prefabs = {
	"tier1",
    "tier2"
}

local function DebugPrint(...)
    print("[Lykio Character Debug]", ...)
end

local function getCubemaps()
    NIGHTVISION_COLOURCUBES = {
        night = "images/colour_cubes/purple_moon_cc.tex",
        full_moon = "images/colour_cubes/purple_moon_cc.tex"
    }

	if TheWorld.state.isautumn then
        DebugPrint("Autumn detected, using autumn cubemaps")
		return {
			day = "images/colour_cubes/day05_cc.tex",
			dusk = "images/colour_cubes/dusk03_cc.tex",
			night = NIGHTVISION_COLOURCUBES.night,
			full_moon = NIGHTVISION_COLOURCUBES.full_moon
		}
	elseif TheWorld.state.iswinter then
        DebugPrint("Winter detected, using winter cubemaps")
		return {
			day = "images/colour_cubes/snow_cc.tex",
			dusk = "images/colour_cubes/snowdusk_cc.tex",
			night = NIGHTVISION_COLOURCUBES.night,
			full_moon = NIGHTVISION_COLOURCUBES.full_moon
		}
	elseif TheWorld.state.isspring then
        DebugPrint("Spring detected, using spring cubemaps")
		return {
			day = "images/colour_cubes/spring_day_cc.tex",
			dusk = "images/colour_cubes/spring_dusk_cc.tex",
			night = NIGHTVISION_COLOURCUBES.night,
			full_moon = NIGHTVISION_COLOURCUBES.full_moon
		}
	elseif TheWorld.state.issummer then
        DebugPrint("Summer detected, using summer cubemaps")
		return {
			day = "images/colour_cubes/summer_day_cc.tex",
			dusk = "images/colour_cubes/summer_dusk_cc.tex",
			night = NIGHTVISION_COLOURCUBES.night,
			full_moon = NIGHTVISION_COLOURCUBES.full_moon
		}
	end

    return error("No cubemaps found for current world state")
end

-- Custom starting inventory ------------------------------------------------
local start_inv = TUNING.LYKIO.START_ITEMS

for k, v in pairs(TUNING.LYKIO.START_ITEMS) do
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
        inst.components.hunger.hungerrate = TUNING.LYKIO.STATS.HUNGERRATE
    else
        DebugPrint("ERROR: No hunger component found")
    end
end

-- Handle night vision ------------------------------------------------------
---@param inst EntityScript
local function SetForcedNightVision(inst, nightvision_on)
    DebugPrint("Setting forced night vision to:", nightvision_on)
    inst._forced_nightvision:set(nightvision_on)
    if inst.components.playervision ~= nil then
        inst.components.playervision:ForceNightVision(nightvision_on)
        inst.compoenents.playervision:SetCustomCCTable(getCubemaps())
    else
        inst.components.playervision:ForceNightVision(false)
        inst.compoenents.playervision:SetCustomCCTable(getCubemaps())
    end
end

---@param inst EntityScript
local function OnForcedNightVisionDirty(inst)
    if inst.components.playervision ~= nil then
        DebugPrint("Updating forced night vision for:", inst.prefab)
        inst.components.playervision:ForceNightVision(inst._forced_nightvision:value())
    end
end

-- When the character is revived from human ---------------------------------------
---@param inst EntityScript
local function onbecamehuman(inst)
    local rp = inst.components.runicpower
    DebugPrint("Character became human")
    if rp ~= nil then rp:StartRegen(false) end
    inst.components.locomotor:SetExternalSpeedMultiplier(inst, "Lykio_speed_mod", 1)

    inst:ListenForEvent("death", function()
        DebugPrint("Character died, reset runic power")
        if rp ~= nil then rp:SetCurrent(0) end
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
        rp:StopRegen()
    end
end

-- When loading or spawning the character -------------------------------------------
---@param inst EntityScript
local function onpreload(inst)
    DebugPrint("Preloading character")
    --- TODO : IMPL
end

---@param inst EntityScript
local function onload(inst, data)
    DebugPrint("Loading character state")
    
    if inst.components.runicpowermeter ~= nil then
        DebugPrint("Runic power component found")
        if data and data.rp_current then
            inst.components.runicpowermeter:SetCurrent(data.rp_current)
        end
        if data and data.rp_max then
            inst.components.runicpowermeter:SetMax(data.rp_max)
        end
        if data and data.rp_regen_task then
            inst.components.runicpowermeter:SetRegenTask(data.rp_regen_task.rate, data.rp_regen_task.period, false)
        end
    end

    if inst:HasTag("playerghost") then
        DebugPrint("Loading as ghost")
        onbecameghost(inst)
    else
        DebugPrint("Loading as human")
        onbecamehuman(inst)
    end
end

---@param inst EntityScript
local function onnewspawn(inst)
    if inst.components.runicpowermeter ~= nil then
        inst.components.runicpowermeter:SetCurrent(TUNING.LYKIO.RUNICPOWER.STATS.CURRENT.DEFAULT / 2)
        inst.components.runicpowermeter:SetMax(TUNING.LYKIO.RUNICPOWER.STATS.MAX.DEFAULT)
        inst.components.runicpowermeter:SetRegenTask(TUNING.LYKIO.RUNICPOWER.STATS.REGEN.DEFAULT, TUNING.LYKIO.RUNICPOWER.STATS.REGEN.PERIOD.DEFAULT, false)
        inst.components.runicpowermeter:SetRate(TUNING.LYKIO.RUNICPOWER.STATS.REGEN.RATE.DEFAULT)
        inst.components.runicpowermeter:SetPeriod(TUNING.LYKIO.RUNICPOWER.STATS.REGEN.PERIOD.DEFAULT)
        DebugPrint("New spawn: Setting runic power to default values")
    end
end

---@param inst EntityScript
local function onsave(inst, data)
    DebugPrint("Saving character state")
    if inst.components.runicpowermeter ~= nil then
        data.rp_current = inst.components.runicpowermeter:GetCurrent()
        data.rp_max = inst.components.runicpowermeter:GetMax()
        data.rp_regen_task = inst.components.runicpowermeter:GetRegenTask()
    end
end

local function AddRPMeter(inst)
    DebugPrint("Adding Runic Power Meter to character:", inst.prefab)
    inst["current"] = net_shortint(inst.GUID, "runicpowermeter.current", "runicpowermeter_currentdirty")
    inst["max"] = net_shortint(inst.GUID, "runicpowermeter.max", "runicpowermeter_maxdirty")
end

local function OnPlayerDeactivated(inst)
    DebugPrint("Player deactivated:", inst.prefab)
    inst:RemoveEventCallback("onremove", OnPlayerDeactivated)
    if not TheNet:IsDedicated() then
        inst:RemoveEventCallback("forced_nightvision_dirty", OnForcedNightVisionDirty)
    end
end

local function OnPlayerActivated(inst)
    DebugPrint("Player activated:", inst.prefab)
    inst:ListenForEvent("onremove", OnPlayerDeactivated)
    if not TheNet:IsDedicated() then
        inst:ListenForEvent("forced_nightvision_dirty", OnForcedNightVisionDirty)
        OnForcedNightVisionDirty(inst)
    end

    if inst.components.runicpowermeter ~= nil then
        inst.components.runicpowermeter:StartRegen(false)
    end
end

-- This initializes for both the server and client. ----------------------------------
local common_postinit = function(inst)
    DebugPrint("Applying character tags")
    inst:AddTag("lykio")
    inst:AddTag("nightvision")
    inst:AddTag("insomniac")
    inst:AddTag(FOODTYPE.SOUL.."_eater")
    inst:AddTag(TUNING.LYKIO.FOOD_FAVORITE.."_eater")

    inst._forced_nightvision = net_bool(inst.GUID, "wx78.forced_nightvision", "forced_nightvision_dirty")

    AddRPMeter(inst)

    DebugPrint("Setting up playerevents")
    inst:ListenForEvent("playeractivated", OnPlayerActivated)
    inst:ListenForEvent("playerdeactivated", OnPlayerDeactivated)

	-- Minimap icon
	inst.MiniMapEntity:SetIcon( "lykio.tex" )

    if not TheNet:IsDedicated() then
        inst.RunicPowerBadge = rpbadge
    end

    if not TheWorld.ismastersim then
        return inst
    end
end

-- This initializes for the server only. Components are added here. -------------------
local master_postinit = function(inst)
    DebugPrint("Starting master initialization")
    inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default
    
    DebugPrint("Setting up stats")
    inst.components.health:SetMaxHealth(TUNING.LYKIO.STATS.HEALTH)
    inst.components.hunger:SetMax(TUNING.LYKIO.STATS.HUNGER)
    inst.components.hunger.hungerrate = TUNING.LYKIO.STATS.HUNGERRATE * TUNING.WILSON_HUNGER_RATE
    inst.components.sanity:SetMax(TUNING.LYKIO.STATS.SANITY)
    inst.components.combat.damagemultiplier = TUNING.LYKIO.STATS.DAMAGE
    inst.components.locomotor:SetExternalSpeedMultiplier(inst, "Lykio_speed_mod", TUNING.LYKIO.STATS.SPEED)

    if not inst.components.runicpowermeter then
        inst:AddComponent("runicpowermeter")
    end

    DebugPrint("Setting up save/load handlers")
    inst.OnPreLoad = onpreload
    inst.OnLoad = onload
    inst.OnNewSpawn = onnewspawn
    inst.OnSave = onsave

    DebugPrint("Setting up forced night vision")
    inst.SetForcedNightVision = SetForcedNightVision
    
    DebugPrint("Setting up perks")
    ApplyTemperatureResilience(inst)
    ApplyHungerModifications(inst)
    
    local eater = inst.components.eater

    if eater ~= nil then
        if inst.components.foodaffinity == nil then
            DebugPrint("Adding food affinity component")
            inst:AddComponent("foodaffinity")
            inst.components.foodaffinity:AddFoodtypeAffinity(FOODTYPE.SOUL)
        else
            inst.components.foodaffinity:AddFoodtypeAffinity(FOODTYPE.SOUL)
        end

        DebugPrint("Setting up eater component for", inst.prefab)
        eater:SetDiet(TUNING.LYKIO.FOOD_DIET)
        eater:SetRefusesSpoiledFood(TUNING.LYKIO.FOOD_SPOILED_IGNORE)
        eater:SetStrongStomach(TUNING.LYKIO.STOMACH_STRONG)
        eater:SetOnEatFn(function (eater_inst, food)
                if food.components.edible and food.components.edible.foodtype == FOODTYPE.SOUL then
                    DebugPrint("Updating eat function for", food.prefab)

                    if inst.components.runicpowermeter then
                        if food.prefab == "horrorfuel" then
                            inst.components.runicpowermeter:DoDelta(TUNING.LYKIO.RUNICPOWER.HUGE, false, "eat_soul_large")
                            return true
                        end

                        inst.components.runicpowermeter:DoDelta(TUNING.LYKIO.RUNICPOWER.LARGE, false, "eat_soul")
                        return true
                    end
                end
                return false
        end)
    else
        DebugPrint("ERROR: No eater component found")
    end

    DebugPrint("Master initialization complete")
end

DebugPrint("Lykio character prefab loaded")
return MakePlayerCharacter("lykio", prefabs, Assets, common_postinit, master_postinit, start_inv_F)
