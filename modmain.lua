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
    Asset( "ATLAS", "images/names_gold_lykio.xml" )
}

AddMinimapAtlas("images/map_icons/lykio.xml")

local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS


-- Require perks


--Require skill trees


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

-- This is for debugging purposes
local function DebugPrint(...)
    print("[Lykio Debug]", ...)
end

-- Add mod character to mod character list. Also specify a gender. Possible genders are MALE, FEMALE, ROBOT, NEUTRAL, and PLURAL.
AddModCharacter("lykio", GLOBAL.CHARACTER_GENDERS.PLURAL, skin_modes)

-- HUD Integration for Runic Power
local function AddRunicPowerToHUD(self, owner)
    DebugPrint("Attempting to add RunicPower to HUD")
    
    -- Only add for Lykio characters
    if owner.prefab ~= "lykio" then 
        DebugPrint("Not Lykio character, skipping HUD addition")
        return 
    end
    
    DebugPrint("Loading RunicPowerWidget")
    local RunicPowerWidget = require "widgets/runicpowerwidget"
    
    DebugPrint("Creating RunicPower widget")
    self.runicpower = self.status:AddChild(RunicPowerWidget(owner))
    
    DebugPrint("Setting RunicPower position")
    self.runicpower:SetPosition(-100, -100)
    
    if owner.components.runicpower then
        DebugPrint("Initializing RunicPower values")
        local max = owner.components.runicpower:GetMax()
        local current = owner.components.runicpower:GetCurrent()
        DebugPrint("Max:", max, "Current:", current)
        self.runicpower:SetMax(max)
        self.runicpower:SetValue(current)
    else
        DebugPrint("WARNING: No runicpower component found on owner")
    end
end

-- Alternative approach - using AddPlayerPostInit
AddPlayerPostInit(function(inst)
    DebugPrint("PlayerPostInit called for", inst.prefab)
    if inst.prefab == "lykio" then
        DebugPrint("Setting up delayed HUD initialization for Lykio")
        inst:DoTaskInTime(0.1, function()
            if inst.HUD and inst.HUD.controls then
                DebugPrint("HUD exists, adding RunicPower")
                AddRunicPowerToHUD(inst.HUD.controls, inst)
            else
                DebugPrint("ERROR: HUD or controls not found")
            end
        end)
    end
end)

-- Handle HUD updates when runic power changes
local function OnRunicPowerChanged(inst, current, old_current)
    DebugPrint("RunicPower changed from", old_current, "to", current)
    if inst.HUD and inst.HUD.controls and inst.HUD.controls.runicpower then
        DebugPrint("Updating RunicPower display")
        inst.HUD.controls.runicpower:SetValue(current)
    else
        DebugPrint("ERROR: Cannot update RunicPower display - missing HUD components")
    end
end

local function OnMaxRunicPowerChanged(inst, max, old_max)
    DebugPrint("Max RunicPower changed from", old_max, "to", max)
    if inst.HUD and inst.HUD.controls and inst.HUD.controls.runicpower then
        DebugPrint("Updating max RunicPower display")
        inst.HUD.controls.runicpower:SetMax(max)
    else
        DebugPrint("ERROR: Cannot update max RunicPower display - missing HUD components")
    end
end

-- Hook into runic power component initialization
AddComponentPostInit("runicpower", function(self)
    DebugPrint("Initializing RunicPower component")
    local old_ctor = self._ctor
    self._ctor = function(self, inst)
        DebugPrint("Running RunicPower constructor for", inst.prefab)
        old_ctor(self, inst)
        
        DebugPrint("Setting up RunicPower callbacks")
        self.onrunicpowerchange = OnRunicPowerChanged
        self.onmaxrunicpowerchange = OnMaxRunicPowerChanged
    end
end)