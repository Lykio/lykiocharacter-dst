local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS
local net_shortint = GLOBAL.net_shortint
local DEV_MODE = GetModConfigData("dev_mode")
GLOBAL.DEV_MODE = false

if DEV_MODE then
    GLOBAL.DEV_MODE = DEV_MODE
    GLOBAL.TheSim:SetSetting("misc", "console_enabled", true)
    GLOBAL.AddKeyDownHandler(GLOBAL.KEY_F5, function()
        GLOBAL.TheSim:SendServerCommand("lykio", "toggle_debug")
        print("[Lykio Debug] RELOADING MOD SCRIPTS...")
        if GLOBAL.TheNet:GetIsServer() then
            GLOBAL.c_reset()
        else
            GLOBAL.TheNet:SendRemoteExecute("c_reset()")
        end
    end)
    GLOBAL.AddKeyDownHandler(GLOBAL.KEY_F6, function()
        GLOBAL.DEBUGMODE = not GLOBAL.DEBUGMODE
        print("[Lykio Debug] Debug visualization:", GLOBAL.DEBUGMODE and "ON" or "OFF")
    end)
end

local function DebugPrint(...)
    if GLOBAL.DEBUGMODE then print("[Lykio Debug]", ...) end
end

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

    -- Eater
    Asset("SCRIPT", "scripts/components/eaterlykio.lua"),

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
modimport("scripts/components/eaterlykio")
require("tuning_lykio")

DebugPrint("modmain.lua start")

AddMinimapAtlas("images/map_icons/lykio.xml")


-- The character select screen lines
STRINGS.CHARACTER_TITLES.Lykio = "The Fallen Æsir Succubus"
STRINGS.CHARACTER_NAMES.Lykio = "Lykio"
STRINGS.SKIN_NAMES.Lykio_none = "Lykio"
STRINGS.CHARACTER_DESCRIPTIONS.Lykio = "*Skilled fox.\n*Born to fire, ice and death.\n*Hungers endlessly, sanity frays quickly."
STRINGS.CHARACTER_QUOTES.Lykio = "\"Once, I only feared the emptiness of winter..\""
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
end

AddReplicableComponent("runicpowermeter")

AddClassPostConstruct("widgets/statusdisplays", function(self)
    if self.owner:HasTag("lykio") then
        local rpbadge = require "widgets/rpbadge"
        DebugPrint("Adding Runic Power Meter to status displays")
        self.rpbadge = self:AddChild(rpbadge(self.owner, "status_health", "status_health"))
        self.rpbadge:SetPosition(40, -550, -80)
        self.rpbadge:SetScale(1.2, 1.2, 1.2)
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