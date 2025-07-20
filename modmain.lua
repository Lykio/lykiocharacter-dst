local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS
local TUNING = GLOBAL.TUNING

-- This is for debugging purposes
local function DebugPrint(...)
    print("[Lykio Debug]", ...)
end

DebugPrint("modmain.lua start")

GLOBAL.package.loaded["components/runicpower"] = nil

PrefabFiles = {
	"lykio",
    "lykio_none",
}

Assets = {
    -- For Runic Power
    Asset("ANIM", "anim/status_meter.zip"),
    Asset("ATLAS", "images/status_icons/runicpowericon.xml"),
    Asset("IMAGE", "images/status_icons/runicpowericon.tex"),

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

AddMinimapAtlas("images/map_icons/lykio.xml")
modimport("scripts/components/runicpower")

-- Lykio's stats
TUNING.Lykio_HEALTH = 145
TUNING.Lykio_HUNGER = 265
TUNING.Lykio_SANITY = 120
TUNING.Lykio_SANITYDRAIN = 1.0

TUNING.Lykio_DAMAGE = 1
TUNING.Lykio_SPEED = 1.0
TUNING.LYKIO_NIGHTVISION = true

TUNING.Lykio_WINTER_INSULATION = 1
TUNING.Lykio_SUMMER_INSULATION = 1
TUNING.Lykio_WETNESS_INSULATION = 1

TUNING.Lykio_RunicPower = 100
TUNING.Lykio_RunicPowerRegen = 1
TUNING.Lykio_RunicPowerRegenPeriod = 10

TUNING.RUNICPOWER_SMALL = 3
TUNING.RUNICPOWER_SMALLMED = 5
TUNING.RUNICPOWER_MED = 10
TUNING.RUNICPOWER_LARGE = 20
TUNING.RUNICPOWER_HUGE = 75

-- Eater settings
GLOBAL.FOODTYPE.SOUL = "SOUL"
TUNING.Lykio_FOOD_FAVORITE = "nightmarefuel"
TUNING.Lykio_FOOD_SPOILED_IGNORE = false
TUNING.Lykio_FOOD_PREFERENCE = { GLOBAL.FOODGROUP.RAW }
TUNING.Lykio_FOOD_TOLERANCE = { GLOBAL.FOODGROUP.OMNI }
TUNING.Lykio_STOMACH_STRONG = true

-- Buff staves durabilities
TUNING.Lykio_FIRESTAFF_USES = math.floor(TUNING.FIRESTAFF_USES * 2.5)
TUNING.Lykio_ICESTAFF_USES = math.floor(TUNING.ICESTAFF_USES * 2.5)
TUNING.Lykio_TELESTAFF_USES = math.floor(TUNING.TELESTAFF_USES * 2.5)

-- The character select screen lines
STRINGS.CHARACTER_TITLES.Lykio = "The Fallen Aesir Demoness"
STRINGS.CHARACTER_NAMES.Lykio = "Lykio"
STRINGS.SKIN_NAMES.Lykio_none = "Lykio"
STRINGS.CHARACTER_DESCRIPTIONS.Lykio = "*Feeds on souls to survive.\n*Attuned to fire, ice and death.\n*Hungers endlessly, sanity frays quickly."
STRINGS.CHARACTER_QUOTES.Lykio = "\"Once, I only feared the chill of winter.. and the careless death it brings.\""
STRINGS.CHARACTER_SURVIVABILITY.Lykio = "Likely"

-- Custom speech strings
STRINGS.CHARACTERS.Lykio = require "speech_lykio"

-- The skins shown in the cycle view window on the character select screen.
-- A good place to see what you can put in here is in skinutils.lua, in the function GetSkinModes
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

local function MakeSoulEdible(inst)
    if not inst.components.edible then
        inst:AddComponent("edible")
        inst:AddTag(GLOBAL.FOODTYPE.SOUL)
        if inst:HasTag("NOEAT") then inst:RemoveTag("NOEAT") end
    end

    if inst.prefab == "nightmarefuel" then
        DebugPrint("Making soul edible for", inst.prefab)
        inst.components.edible.foodtype = GLOBAL.FOODTYPE.SOUL
        inst.components.edible.healthvalue = TUNING.HEALING_LARGE
        inst.components.edible.hungervalue = TUNING.CALORIES_HUGE
        inst.components.edible.sanityvalue = TUNING.SANITY_LARGE
        return
    end

    if inst.prefab == "horrorfuel" then
        DebugPrint("Making soul edible for", inst.prefab)
        inst.components.edible.foodtype = GLOBAL.FOODTYPE.SOUL
        inst.components.edible.healthvalue = TUNING.HEALING_LARGE * 1.33
        inst.components.edible.hungervalue = TUNING.CALORIES_HUGE * 1.33
        inst.components.edible.sanityvalue = TUNING.SANITY_LARGE * 1.33
        return
    end
end

AddPrefabPostInit("nightmarefuel", MakeSoulEdible)
AddPrefabPostInit("horrorfuel", MakeSoulEdible)

--AddReplicableComponent("runicpower")

-- Add mod character to mod character list. Also specify a gender. Possible genders are MALE, FEMALE, ROBOT, NEUTRAL, and PLURAL.
DebugPrint("modmain.lua loaded")
AddModCharacter("lykio", "PLURAL", skin_modes)
