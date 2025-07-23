local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS
local TUNING = GLOBAL.TUNING
local net_shortint = GLOBAL.net_shortint

PrefabFiles = {
	"lykio",
    "lykio_none",
}

Assets = {
    --For Runic Power
    Asset("ANIM", "anim/runicpowericon.zip"),
    Asset("IMAGE", "images/runicpowericon.tex"),
    Asset("ATLAS", "images/runicpowericon.xml"),

    Asset("SCRIPT", "scripts/components/runicpowermeter.lua"),
    Asset("SCRIPT", "scripts/components/runicpowermeter_replica.lua"),
    Asset("SCRIPT", "scripts/widgets/rpbadge.lua"),

    -- Tuning
    Asset("SCRIPT", "scripts/tuning_lykio.lua"),

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

modimport("scripts/components/runicpowermeter")
require("tuning_lykio")

-- This is for debugging purposes
local function DebugPrint(...)
    print("[Lykio Debug]", ...)
end

DebugPrint("modmain.lua start")

AddMinimapAtlas("images/map_icons/lykio.xml")


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

AddReplicableComponent("runicpowermeter")

AddClassPostConstruct("widgets/statusdisplays", function(self)
    if self.owner:HasTag("lykio") then
        local rpbadge = require "widgets/rpbadge"
        DebugPrint("Adding Runic Power Meter to status displays")
        self.rpbadge = self:AddChild(rpbadge(self.owner, "status_health", "status_health"))
        self.rpbadge:SetPosition(40, -550, 0)
    else
        DebugPrint("Owner does not have the 'lykio' tag, not adding Runic Power Meter")
    end
end)

AddPrefabPostInit("nightmarefuel", MakeSoulEdible)
AddPrefabPostInit("horrorfuel", MakeSoulEdible)
AddPrefabPostInit("player_classified", function(inst)
    inst._max = net_shortint(inst.GUID, "runicpower._max", "runicpower_maxdirty")
    inst._current = net_shortint(inst.GUID, "runicpower._current", "runicpower_currentdirty")
end)
AddModCharacter("lykio", "PLURAL", skin_modes)
DebugPrint("modmain.lua loaded")