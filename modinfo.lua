-- This information tells other players more about the mod
name = "Lykio Frostpaw"
description = "An Æsir succubus for Don't Starve Together."
author = "Lykio"
version = "0.0.1" -- This is the version of the template. Change it to your own number.
folder_name = "lykio_dst"

-- This is the URL name of the mod's thread on the forum; the part after the ? and before the first & in the url
forumthread = "https://forums.kleientertainment.com/forums/topic/123456-lykio-frostpaw-a-demonic-aesir-for-dont-starve-together/"

-- This lets other players know if your mod is out of date, update it to match the current version in the game
api_version = 10

-- Compatible with Don't Starve Together
dst_compatible = true

-- Not compatible with Don't Starve
dont_starve_compatible = false
reign_of_giants_compatible = false
shipwrecked_compatible = false

-- Character mods are required by all clients
all_clients_require_mod = true

icon_atlas = "modicon.xml"
icon = "modicon.tex"

-- The mod's tags displayed on the server list
server_filter_tags = {
    "character",
    "furry",
    "magic",
    "shapeshifter"
}

configuration_options = {
    {
        name = "dev_mode",
        label = "Development Mode",
        options = {
            {description = "Enabled", data = true},
            {description = "Disabled", data = false}
        },
        default = false,
        hover = "Enable or disable debug messages and commands in the console."
    },
    {
        name = "enable_skilltrees",
        label = "Whether or not Lykio's Skill Tree is enabled. Requires Runic Power and Spells to be enabled.",
        options = {
            {description = "Enabled", data = true},
            {description = "Disabled", data = false}
        },
        default = true,
        hover = "Enable or disable skill trees."
    },
    {
        name = "enable_nightvision",
        label = "Enable Night Vision",
        options = {
            {description = "Enabled", data = true},
            {description = "Disabled", data = false}
        },
        default = true,
        hover = "Enable or disable night vision."
    },
    {
        name = "enable_eater_lykio",
        label = "Enable Eater Lykio",
        options = {
            {description = "Enabled", data = true},
            {description = "Disabled", data = false}
        },
        default = true,
        hover = "Enable or disable the custom foods and character related changes."
    },
{
        name = "enable_runic_power_and_spells",
        label = "Enable Runic Power and Spells",
        options = {
            {description = "Enabled", data = true},
            {description = "Disabled", data = false}
        },
        default = true,
        hover = "Enable or disable Runic Power and Spells."
    }
}
