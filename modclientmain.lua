local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS

GLOBAL.DEV_MODE = GetModConfigData("dev_mode")

if GLOBAL.DEV_MODE then
    local function SetupKeyHandlers()
        if TheInput then
            TheInput:SetupKeyHandler(KEY_F5, function()
                TheNet:SendRemoteExecute([[
                    if TheNet:GetIsServer() then
                        c_reset()
                    end
                ]])
                print("[Lykio Debug] RELOADING MOD SCRIPTS...")
            end)
            TheInput:SetupKeyHandler(KEY_F6, function()
                DEBUGMODE = not DEBUGMODE
                print("[Lykio Debug] Debug visualization:", DEBUGMODE and "ON" or "OFF")
            end)
        end
    end

    AddGamePostInit(SetupKeyHandlers)
else
    print("[Lykio Debug] Development mode disabled")
end

local function DebugPrint(...)
    if GLOBAL.DEV_MODE then print("[Lykio Debug]", ...) end
end

PrefabFiles = {
	--"lykio",
    "lykio_none",
    "lykio_feral"
}


Assets = {
    --For Runic Power
    Asset("ANIM", "anim/runicpowericon.zip"),
    Asset("IMAGE", "images/runicpowericon.tex"),
    Asset("ATLAS", "images/runicpowericon.xml"),

    -- GLOBALS
    Asset("SCRIPT", "scripts/strings_lykio"),
    Asset("SCRIPT", "scripts/strings_lykio.lua"),

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

GLOBAL.PREFAB_SKINS["lykio"] = {
    "lykio_none",
    --"lykio_feral"
}

AddMinimapAtlas("images/map_icons/lykio.xml")
AddModCharacter("lykio", "NEUTRAL")