local SoulFeeder = require "components/soulfeeder"
local ElementalAffinity = require "components/elementalaffinity"
local DeathsEmbrace = require "components.deathsembrace"    

PrefabFiles = {
	"lykio",
}

Assets = {
    Asset( "IMAGE", "images/saveslot_portraits/Lykio.tex" ),
    Asset( "ATLAS", "images/saveslot_portraits/Lykio.xml" ),

    Asset( "IMAGE", "images/selectscreen_portraits/Lykio.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/Lykio.xml" ),
	
    Asset( "IMAGE", "images/selectscreen_portraits/Lykio_silho.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/Lykio_silho.xml" ),

    Asset( "IMAGE", "bigportraits/Lykio.tex" ),
    Asset( "ATLAS", "bigportraits/Lykio.xml" ),
	
	Asset( "IMAGE", "images/map_icons/Lykio.tex" ),
	Asset( "ATLAS", "images/map_icons/Lykio.xml" ),
	
	Asset( "IMAGE", "images/avatars/avatar_Lykio.tex" ),
    Asset( "ATLAS", "images/avatars/avatar_Lykio.xml" ),
	
	Asset( "IMAGE", "images/avatars/avatar_ghost_Lykio.tex" ),
    Asset( "ATLAS", "images/avatars/avatar_ghost_Lykio.xml" ),
	
	Asset( "IMAGE", "images/avatars/self_inspect_Lykio.tex" ),
    Asset( "ATLAS", "images/avatars/self_inspect_Lykio.xml" ),
	
	Asset( "IMAGE", "images/names_Lykio.tex" ),
    Asset( "ATLAS", "images/names_Lykio.xml" ),
	
	Asset( "IMAGE", "images/names_gold_Lykio.tex" ),
    Asset( "ATLAS", "images/names_gold_Lykio.xml" ),
}

AddMinimapAtlas("images/map_icons/Lykio.xml")

local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS

-- The character select screen lines
STRINGS.CHARACTER_TITLES.Lykio = "The Fallen Aesir"
STRINGS.CHARACTER_NAMES.Lykio = "Lykió"
STRINGS.CHARACTER_DESCRIPTIONS.Lykio = "*Perk 1\n*Perk 2\n*Perk 3"
STRINGS.CHARACTER_QUOTES.Lykio = "\"Quote\""
STRINGS.CHARACTER_SURVIVABILITY.Lykio = "Likely"

-- Custom speech strings
STRINGS.CHARACTERS.Lykio = require "speech_Lykio"

-- The character's name as appears in-game 
STRINGS.NAMES.Lykio = "Lykió"
STRINGS.SKIN_NAMES.Lykio_none = "Lykió"

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

-- Add mod character to mod character list. Also specify a gender. Possible genders are MALE, FEMALE, ROBOT, NEUTRAL, and PLURAL.
AddModCharacter("Lykio", "NEUTRAL", skin_modes)
