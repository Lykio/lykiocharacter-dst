local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS
local net_shortint = GLOBAL.net_shortint

GLOBAL.DEV_MODE = GetModConfigData("dev_mode")
GLOBAL.LYKIO_SKILL_TREE = GetModConfigData("enable_skilltrees")
GLOBAL.LYKIO_NIGHTVISION = GetModConfigData("enable_nightvision")
GLOBAL.LYKIO_EATER = GetModConfigData("enable_eater_lykio")
GLOBAL.LYKIO_RUNICPOWER_AND_SPELLS = GetModConfigData("enable_runic_power_and_spells")

if GLOBAL.LYKIO_SKILL_TREE == nil then return else GLOBAL.LYKIO_SKILL_TREE = false end
if GLOBAL.LYKIO_NIGHTVISION == nil then return else GLOBAL.LYKIO_NIGHTVISION = false end
if GLOBAL.LYKIO_EATER == nil then return else GLOBAL.LYKIO_EATER = false end
if GLOBAL.LYKIO_RUNICPOWER_AND_SPELLS == nil then return else GLOBAL.LYKIO_RUNICPOWER_AND_SPELLS = false end

local function DebugPrint(...)
    if GLOBAL.DEV_MODE then print("[Lykio Debug]", ...) else return end
end

DebugPrint("modmain.lua start")

local function MakeSoulEdible(inst)
    if not inst.components.edible then
        inst:AddComponent("edible")
        inst:AddTag(GLOBAL.FOODTYPE.SOUL)
        inst.components.edible.foodtype = GLOBAL.FOODTYPE.SOUL
        inst.components.edible.healthvalue = 0
        inst.components.edible.hungervalue = 0
        inst.components.edible.sanityvalue = 0
        if inst:HasTag("NOEAT") then inst:RemoveTag("NOEAT") end
    end
end

PrefabFiles = {
	"lykio",
    "lykio_none",
    --"lykio_feral",
}

Assets = {
    -- GLOBALS
    Asset("SCRIPT", "scripts/tuning_lykio.lua"),
    Asset("SCRIPT", "scripts/strings_lykio.lua"),

    -- For Art
    Asset( "IMAGE", "images/saveslot_portraits/lykio.tex" ),
    Asset( "ATLAS", "images/saveslot_portraits/lykio.xml" ),

    Asset( "IMAGE", "images/selectscreen_portraits/lykio.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/lykio.xml" ),

    Asset( "IMAGE", "images/selectscreen_portraits/lykio_silho.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/lykio_silho.xml" ),

    Asset( "IMAGE", "bigportraits/lykio.tex" ),
    Asset( "ATLAS", "bigportraits/lykio.xml" ),

	Asset( "IMAGE", "images/map_icons/lykio.tex" ),
	Asset( "ATLAS", "images/map_icons/lykio.xml" ),

	Asset( "IMAGE", "images/avatars/avatar_lykio.tex" ),
    Asset( "ATLAS", "images/avatars/avatar_lykio.xml" ),

	Asset( "IMAGE", "images/avatars/avatar_ghost_lykio.tex" ),
    Asset( "ATLAS", "images/avatars/avatar_ghost_lykio.xml" ),

	Asset( "IMAGE", "images/avatars/self_inspect_lykio.tex" ),
    Asset( "ATLAS", "images/avatars/self_inspect_lykio.xml" ),

	Asset( "IMAGE", "images/names_lykio.tex" ),
    Asset( "ATLAS", "images/names_lykio.xml" ),

	Asset( "IMAGE", "images/names_gold_lykio.tex" ),
    Asset( "ATLAS", "images/names_gold_lykio.xml" )
}

if GLOBAL.DEV_MODE then
    DebugPrint("Development Mode is enabled, adding commands")
    table.insert(Assets, Asset("SCRIPT", "scripts/commands_lykio.lua"))
    require("commands_lykio")
else
    DebugPrint("Development Mode is disabled, not adding commands")
end

if GLOBAL.LYKIO_EATER then
    DebugPrint("Lykio Eater enabled, adding eaterlykio components and assets")
    table.insert(Assets, Asset("SCRIPT", "scripts/components/eaterlykio.lua"))

    modimport("scripts/components/eaterlykio")
    AddPrefabPostInit("nightmarefuel", MakeSoulEdible)
    AddPrefabPostInit("horrorfuel", MakeSoulEdible)
else
    DebugPrint("Lykio Eater is disabled, not adding eaterlykio components")
end

if GLOBAL.LYKIO_RUNICPOWER_AND_SPELLS then
    DebugPrint("Lykio Runic Power and Spells enabled, adding runicpower components and assets")
    table.insert(Assets, Asset("ANIM", "anim/runicpowericon.zip"))
    table.insert(Assets, Asset("IMAGE", "images/runicpowericon.tex"))
    table.insert(Assets, Asset("ATLAS", "images/runicpowericon.xml"))
    table.insert(Assets, Asset("SCRIPT", "scripts/components/runicpowermeter.lua"))
    table.insert(Assets, Asset("SCRIPT", "scripts/components/runicpowermeter_replica.lua"))
    table.insert(Assets, Asset("SCRIPT", "scripts/widgets/rpbadge.lua"))

    modimport("scripts/components/runicpowermeter")
    AddReplicableComponent("runicpowermeter")
    AddClassPostConstruct("widgets/statusdisplays", function(self)
        if self.owner:HasTag("lykio") then
            local rpbadge = require "widgets/rpbadge"
            DebugPrint("Adding Runic Power Meter to status displays")
            self.rpbadge = self:AddChild(rpbadge(self.owner, "status_health", "status_health"))
            self.rpbadge:SetPosition(40, -550, -80)
            self.rpbadge:SetScale(1.2, 1.2, 1.2)
        else
            DebugPrint("Owner does not have the 'lykio' tag, not adding Runic Power")
        end
    end)
    AddPrefabPostInit("player_classified", function(inst)
        inst._max = net_shortint(inst.GUID, "runicpower._max", "runicpower_maxdirty")
        inst._current = net_shortint(inst.GUID, "runicpower._current", "runicpower_currentdirty")
    end)
else
    DebugPrint("Lykio Runic Power and Spells is disabled, not adding runicpower components")
end

if GLOBAL.LYKIO_RUNICPOWER_AND_SPELLS and GLOBAL.LYKIO_SKILL_TREE then
    DebugPrint("Lykio Skill Tree and Runic Power enabled, adding skill tree components and assets")
    table.insert(Assets, Asset("SCRIPT", "scripts/components/lykio_skilltree.lua"))

    modimport("scripts/components/lykio_skilltree")
else
    DebugPrint("Lykio Skill Tree or Runic Power is disabled, not adding skill tree components")
end


local skin_modes = {
    {
        type = "ghost_skin",
        anim_bank = "ghost",
        idle_anim = "idle",
        scale = 0.65,
        offset = { 0, -25 }
    },
    {
        type = "lykio_feral",
        anim_bank = "ghost",
        idle_anim = "idle",
        scale = 0.75,
        offset = { 0, -25 }
    },
}

require("tuning_lykio")
require("strings_lykio")
AddMinimapAtlas("images/map_icons/lykio.xml")
AddModCharacter("lykio", "PLURAL", skin_modes)
DebugPrint("modmain.lua loaded")