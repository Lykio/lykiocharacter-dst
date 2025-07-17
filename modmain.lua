-- Require perks


--Require skill trees


PrefabFiles = {
	"lykio",
    "lykio_none",
}

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
    Asset( "ATLAS", "images/names_gold_lykio.xml" ),
}

AddMinimapAtlas("images/map_icons/lykio.xml")

local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS

-- The character select screen lines
STRINGS.CHARACTER_TITLES.lykio = "The Fallen Aesir Demoness"
STRINGS.CHARACTER_NAMES.lykio = "Lykió"
STRINGS.CHARACTER_DESCRIPTIONS.lykio = "*Feeds on souls to survive.\n*Attuned to fire, ice and death.\n*Hungers endlessly, sanity frays quickly."
STRINGS.CHARACTER_QUOTES.lykio = "\"Once, I only feared the chill of winter.. and the careless death it brings.\""
STRINGS.CHARACTER_SURVIVABILITY.lykio = "Likely"

-- Custom speech strings
STRINGS.CHARACTERS.lykio = require "speech_lykio"

-- The character's name as appears in-game 
STRINGS.NAMES.lykio = "Lykió"
STRINGS.SKIN_NAMES.lykio_none = "Lykió"

-- Talent tree constructor
local function CreateLykioSkillTree()

end

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
}

-- constructor for LykioClass

-- Add perks to the character

--Add skill trees to the character
CreateLykioSkillTree()

-- Add mod character to mod character list. Also specify a gender. Possible genders are MALE, FEMALE, ROBOT, NEUTRAL, and PLURAL.
AddModCharacter("lykio", "NEUTRAL", skin_modes)
