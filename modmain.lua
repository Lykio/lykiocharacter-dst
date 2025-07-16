-- Require perks
local SoulFeeder = require "components/soulfeeder"
local ElementalAffinity = require "components/elementalaffinity"
local DeathsEmbrace = require "components/deathsembrace"

--Require skill trees
local RunicDominion = require "scripts/prefabs/runicdominion_st"
local NecroticArts = require "scripts/prefabs/necroticarts_st"
local InferalPact = require "scripts/prefabs/inferalpack_st"

PrefabFiles = {
	"lykio",
    "lykio_none",
}

Assets = {

    Asset("SCRIPT", "scripts/prefabs/lykio.lua"),
    Asset("SCRIPT", "scripts/prefabs/lykio_none.lua"),
    Asset("SCRIPT", "scripts/prefabs/runicdominion_st.lua"),
    Asset("SCRIPT", "scripts/prefabs/necroticarts_st.lua"),
    Asset("SCRIPT", "scripts/prefabs/inferalpack_st.lua"),
    Asset("SCRIPT", "components/elementalaffinity.lua"),
    Asset("SCRIPT", "components/deathsembrace.lua"),
    Asset("SCRIPT", "components/soulfeeder.lua"),


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
    local RunicDominion = RunicDominion()
    local NecroticArts = NecroticArts()    
    local InferalPact = InferalPact()

    
    if RunicDominion then 
        local data = BuildSkillsData(RunicDominion)
        if data then 
        RunicDominion.CreateSkillTree("lykio", data.SKILLS)
        RunicDominion.SKILLTREE_ORDERS["lykio"] = data.ORDERS
        else
            print("RunicDominion data is nil, cannot create skill tree.")
        end
    end


    if NecroticArts then 
        local data = BuildSkillsData(NecroticArts)
        if data then 
        NecroticArts.CreateSkillTree("lykio", data.SKILLS)
        NecroticArts.SKILLTREE_ORDERS["lykio"] = data.ORDERS
        else
            print("NecroticArts data is nil, cannot create skill tree.")
        end
    end


    if InferalPact then 
        local data = BuildSkillsData(InferalPact)
        if data then 
        InferalPact.CreateSkillTree("lykio", data.SKILLS)
        InferalPact.SKILLTREE_ORDERS["lykio"] = data.ORDERS
        else
            print("InferalPact data is nil, cannot create skill tree.")
        end
    end

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
AddComponentPostInit("SoulFeeder",SoulFeeder)
AddComponentPostInit("ElementalAffinity", ElementalAffinity)
AddComponentPostInit("DeathsEmbrace", DeathsEmbrace)
--Add skill trees to the character
CreateLykioSkillTree()

-- Add mod character to mod character list. Also specify a gender. Possible genders are MALE, FEMALE, ROBOT, NEUTRAL, and PLURAL.
AddModCharacter("lykio", "NEUTRAL", skin_modes)
