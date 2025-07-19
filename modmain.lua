local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS

GLOBAL.package.loaded["widgets/runicpowerwidget"] = nil
GLOBAL.package.loaded["components/runicpower"] = nil

PrefabFiles = {
	"lykio",
    "lykio_none",
}

modimport("scripts/components/runicpower.lua")
modimport("scripts/widgets/runicpowerwidget.lua")

Assets = {
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

-- TODO : Require perks

-- TODO : Require skill trees

-- The character select screen lines
STRINGS.CHARACTER_TITLES.Lykio = "The Fallen Aesir Demoness"
STRINGS.CHARACTER_NAMES.Lykio = "Lykio"
STRINGS.SKIN_NAMES.Lykio_none = "Lykio"
STRINGS.CHARACTER_DESCRIPTIONS.Lykio = "*Feeds on souls to survive.\n*Attuned to fire, ice and death.\n*Hungers endlessly, sanity frays quickly."
STRINGS.CHARACTER_QUOTES.Lykio = "\"Once, I only feared the chill of winter.. and the careless death it brings.\""
STRINGS.CHARACTER_SURVIVABILITY.Lykio = "Likely"

-- Custom speech strings
STRINGS.CHARACTERS.Lykio = require "speech_lykio"

-- TODO : Talent tree constructor

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

-- TODO : constructor for LykioClass

-- TODO : Add perks to the character

-- TODO : Add skill trees to the character

-- This is for debugging purposes
local function DebugPrint(...)
    print("[Lykio Debug]", ...)
end


-- Add mod character to mod character list. Also specify a gender. Possible genders are MALE, FEMALE, ROBOT, NEUTRAL, and PLURAL.
AddModCharacter("lykio", "PLURAL", skin_modes)
