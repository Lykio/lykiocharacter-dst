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
    local NIGHTVISION_COLOURCUBES = {
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
local start_inv = {}
for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
    DebugPrint("Adding item to starting inventory:", k, "->", v.LYKIO)
    start_inv[string.lower(k)] = v.LYKIO
end

local start_inv_F = FlattenTree(start_inv, true)
DebugPrint("Adding custom items to starting inventory:", start_inv_F)

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

-- Handle nightvision ------------------------------------------------------------------
---@param inst EntityScript
local function OnChangePhase(inst, phase)
    if TheNet:IsDedicated() then return end

    print("PHASE CHANGED EVENT FIRED:", phase) -- This should print
    local activated = (phase == "night") or (phase == "full_moon")

    DebugPrint("Checking night vision")

    if inst.components.playervision then
        DebugPrint("Player vision component found")

        inst.components.playervision:ForceNightVision(activated)

        if activated then
            DebugPrint("Night or full moon detected, enabling night vision")
            inst.components.playervision:SetCustomCCTable(getCubemaps())
        else
            DebugPrint("Daytime/evening detected, disabling night vision")
            inst.components.playervision:SetCustomCCTable(nil)
        end
    else
        DebugPrint("ERROR: No playervision component found, adding")
        inst:AddComponent("playervision")
    end
end

-- When the character is revived from human ---------------------------------------
---@param inst EntityScript
local function onbecamehuman(inst)
    local rpm = inst.components.runicpowermeter
    DebugPrint("Character became human")
    if rpm ~= nil then rpm:StartRegen(rpm:GetRate(), rpm:GetPeriod(), false) end
    inst.components.locomotor:SetExternalSpeedMultiplier(inst, "Lykio_speed_mod", 1)
    TheWorld:ListenForEvent("phasechanged", function(_, phase)
        OnChangePhase(inst, phase)
    end)

    OnChangePhase(inst, TheWorld.state.phase)

    inst:ListenForEvent("death", function()
        DebugPrint("Character died, reset runic power")
        if rpm ~= nil then rpm:SetCurrent(0) end
    end)
end

-- When the character is revived from ghost --------------------------------------
---@param inst EntityScript
local function onbecameghost(inst)
    local rp = inst.components.runicpower
    DebugPrint("Character became ghost")
    inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "Lykio_speed_mod")
    TheWorld:ListenForEvent("phasechanged", function(_, phase)
        OnChangePhase(inst, phase)
    end)
    OnChangePhase(inst, TheWorld.state.phase)

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

    if data then
        local rpm = inst.components.runicpowermeter
        if rpm ~= nil and data.runicpowermeter then
            DebugPrint("Runic power component found")
            rpm:OnLoad(data.runicpowermeter)
            DebugPrint("Runic power loaded with current:", rpm:GetCurrent(), "max:", rpm:GetMax(), "regen rate:", rpm:GetRate(), "regen period:", rpm:GetPeriod())
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
    DebugPrint("New spawn: Setting runic power to default values")
    local rpm = inst.components.runicpowermeter
    if rpm ~= nil then
        local stats = TUNING.LYKIO.RUNICPOWER.STATS
        rpm:SetCurrent(stats.MAX.DEFAULT / 2)
        rpm:SetMax(stats.MAX.DEFAULT)
        rpm:SetRate(stats.REGEN.TINY)
        rpm:SetPeriod(stats.REGEN.PERIOD.TINY)
    end
end

---@param inst EntityScript
local function onsave(inst, data)
    DebugPrint("Saving character state")
    local rpm = inst.components.runicpowermeter
    if rpm ~= nil then
        data.runicpowermeter = rpm:OnSave()
    end
end

local function AddRPMeter(inst)
    DebugPrint("Adding Runic Power Meter to character")
    inst["current"] = net_shortint(inst.GUID, "runicpowermeter.current", "runicpowermeter_currentdirty")
    inst["max"] = net_shortint(inst.GUID, "runicpowermeter.max", "runicpowermeter_maxdirty")
end

local function OnPlayerDeactivated(inst)
    DebugPrint("Player deactivated")
    inst:RemoveEventCallback("onremove", OnPlayerDeactivated)
    TheWorld:RemoveEventCallback("phasechanged", function(_, phase)
        OnChangePhase(inst, phase)
    end)
    OnChangePhase(inst, TheWorld.state.phase)
end

local function OnPlayerActivated(inst)
    DebugPrint("Player activated")
    inst:ListenForEvent("onremove", OnPlayerDeactivated)

    if TUNING.LYKIO.STATS.NIGHTVISION and not inst:HasTag("playerghost") then
        TheWorld:ListenForEvent("phasechanged", function(_, phase)
            OnChangePhase(inst, phase)
        end)
        
        OnChangePhase(inst, TheWorld.state.phase)
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

    AddRPMeter(inst)

    DebugPrint("Setting up playerevents")
    inst:ListenForEvent("playerdeactivated", OnPlayerDeactivated)
    inst:ListenForEvent("playeractivated", OnPlayerActivated)


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

        DebugPrint("Setting up eater component")
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
