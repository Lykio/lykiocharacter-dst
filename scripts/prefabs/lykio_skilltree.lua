local SKILLTREE = STRINGS.LYKIO.SKILLTREE
local PANELS = SKILLTREE.PANELS
local TITLES_WILDS = SKILLTREE.WILDS.TITLES
local DESC_WILDS = SKILLTREE.WILDS.DESCRIPTIONS
local TITLES_SUCCUBISM = SKILLTREE.SUCCUBISM.TITLES
local DESC_SUCCUBISM = SKILLTREE.SUCCUBISM.DESCRIPTIONS
local TITLES_FATALISM = SKILLTREE.FATALISM.TITLES
local DESC_FATALISM = SKILLTREE.FATALISM.DESCRIPTIONS
local TITLES_ELEMENTALISM = SKILLTREE.ELEMENTALISM.TITLES
local DESC_ELEMENTALISM = SKILLTREE.ELEMENTALISM.DESCRIPTIONS

local ORIGIN = {x = 0, y = 0}
local OR_ROOT_WILDS = -62*2
local OR_ROOT_SUCCUBISM = -62*1
local OR_ROOT_FATALISM = 62*1
local OR_ROOT_ELEMENTALISM = 62*2
local SPACER_X = 62
local SPACER_Y = 30
local SEG_SIZE_X = 54
local SEG_SIZE_Y = 18



local ORDERS =
{
    {"wilds",           { -214+18   , 176 + 30 }},
    {"succubism",       { -62       , 176 + 30 }},
    {"fatalism",        { 66+18     , 176 + 30 }},
    {"elementalism",    { 204       , 176 + 30 }},
}

local function BuildSkillsData(SkillTreeFns)

    local skills =
    {
        -- Wilds --
        foxsinstinct = {
            title = TITLES_WILDS.FOXSINSTINCT,
            description = DESC_WILDS.FOXSINSTINCT,
            icon = "walter_woby_foraging",
            pos = {-62, 176},
            group = "wilds",
            tags = {"wilds"},
            root = true,
            connects = {
                "winterresilience",
            },
        },
        winterresilience = {
            title = TITLES_WILDS.WINTERRESILIENCE,
            description = DESC_WILDS.WINTERRESILIENCE,
            icon = "willow_controlled_burn_3",
            pos = {-62, 176-54},
            group = "wilds",
            tags = {"wilds"},
            connects = {
                "feraltransformation",
            },
        },
        feraltransformation = {
            title = TITLES_WILDS.FERALTRANSFORMATION,
            description = DESC_WILDS.FERALTRANSFORMATION,
            icon = "walter_woby_endurance",
            pos = {-62, 176-108},
            group = "wilds",
            tags = {"wilds"},
        },
        -- Succubism --
        soulfeeder = {
            title = TITLES_SUCCUBISM.SOULFEEDER,
            description = DESC_SUCCUBISM.SOULFEEDER,
            icon = "wilson_alchemy_1",
            pos = {-62, 176-162},
            group = "succubism",
            tags = {"succubism", "heal"},
            connects = {
                "sinfulallure",
            },
        },
        sinfulallure = {
            title = TITLES_SUCCUBISM.SINFULALLURE,
            description = DESC_SUCCUBISM.SINFULALLURE,
            icon = "wilson_alchemy_2",
            pos = {-62, 176-216},
            group = "succubism",
            tags = {"succubism"},
            connects = {
                "seductivedrain",
            },
        },
        seductivedrain = {
            title = TITLES_SUCCUBISM.SEDUCTIVEDRAIN,
            description = DESC_SUCCUBISM.SEDUCTIVEDRAIN,
            icon = "wilson_alchemy_3",
            pos = {-62, 176-270},
            group = "succubism",
            tags = {"succubism", "heal"},
            connects = {
                "netherconsumption",
                "frenziedfeast",
            },
        },
        netherconsumption = {
            title = TITLES_SUCCUBISM.NETHERCONSUMPTION,
            description = DESC_SUCCUBISM.NETHERCONSUMPTION,
            icon = "wilson_alchemy_1",
            pos = {-62, 176-324},
            group = "succubism",
            tags = {"succubism", "heal"},
            connects = {
                "soulgluttony"
            },
        },
        soulgluttony = {
            title = TITLES_SUCCUBISM.SOULGLUTTONY,
            description = DESC_SUCCUBISM.SOULGLUTTONY,
            icon = "wilson_alchemy_2",
            pos = {-62, 176-378},
            group = "succubism",
            tags = {"succubism", "heal"},
        },
        frenziedfeast = {
            title = TITLES_SUCCUBISM.FRENZIEDFEAST,
            description = DESC_SUCCUBISM.FRENZIEDFEAST,
            icon = "wilson_alchemy_3",
            pos = {-62, 176-432},
            group = "succubism",
            tags = {"succubism", "heal"},
            connects = {
                "predatoryapex"
            },
        },
        predatoryapex = {
            title = TITLES_SUCCUBISM.PREDATORYAPEX,
            description = DESC_SUCCUBISM.PREDATORYAPEX,
            icon = "wilson_alchemy_1",
            pos = {-62, 176-486},
            group = "succubism",
            tags = {"succubism"},
        },
        -- Fatalism --
        familiarity = {
            title = TITLES_FATALISM.FAMILIARITY,
            description = DESC_FATALISM.FAMILIARITY,
            icon = "wilson_alchemy_1",
            pos = {-62, 176-486},
            group = "fatalism",
            tags = {"fatalism"},
            connects = {
                "necroticresilience",
            },
        },
        necroticresilience = {
            title = TITLES_FATALISM.NECROTICRESILIENCE,
            description = DESC_FATALISM.NECROTICRESILIENCE,
            icon = "wilson_alchemy_1",
            pos = {-62, 176-486},
            group = "fatalism",
            tags = {"fatalism"},
            connects = {
                "deathsgrasp",
            }
        },
        deathsgrasp = {
            title = TITLES_FATALISM.DEATHSGRASP,
            description = DESC_FATALISM.DEATHSGRASP,
            icon = "wilson_alchemy_1",
            pos = {-62, 176-486},
            group = "fatalism",
            tags = {"fatalism"},
            connects = {
                "shadowstep",
                "deathincarnate",
            },
        },
        shadowstep = {
            title = TITLES_FATALISM.SHADOWSTEP,
            description = DESC_FATALISM.SHADOWSTEP,
            icon = "wilson_alchemy_1",
            pos = {-62, 176-486},
            group = "fatalism",
            tags = {"fatalism"},
            connects = {
                "deathincarnate",
            },
        },
        deathincarnate = {
            title = TITLES_FATALISM.DEATHINCARNATE,
            description = DESC_FATALISM.DEATHINCARNATE,
            icon = "wilson_alchemy_1",
            pos = {-62, 176-486},
            group = "fatalism",
            tags = {"fatalism"},
        },
        necroticempowerment = {
            title = TITLES_FATALISM.NECROTICEMPOWERMENT,
            description = DESC_FATALISM.NECROTICEMPOWERMENT,
            icon = "wilson_alchemy_1",
            pos = {-62, 176-486},
            group = "fatalism",
            tags = {"fatalism"},
            connects = {
                "unyeildingdomain",
            },
        },
        unyeildingdomain = {
            title = TITLES_FATALISM.UNYEILDINGDOMAIN,
            description = DESC_FATALISM.UNYEILDINGDOMAIN,
            icon = "wilson_alchemy_1",
            pos = {-62, 176-486},
            group = "fatalism",
            tags = {"fatalism"},
        },
        -- Elementalism
        runicattunement = {
            title = TITLES_ELEMENTALISM.RUNICATTUNEMENT,
            description = DESC_ELEMENTALISM.RUNICATTUNEMENT,
            icon = "wilson_alchemy_1",
            pos = {-62, 176-486},
            group = "elementalism",
            tags = {"elementalism"},
            connects = {
                "elementalharmony",
            },
        },
        elementalharmony = {
            title = TITLES_ELEMENTALISM.ELEMENTALHARMONY,
            description = DESC_ELEMENTALISM.ELEMENTALHARMONY,
            icon = "wilson_alchemy_1",
            pos = {-62, 176-486},
            group = "elementalism",
            tags = {"elementalism"},
            connects = {
                "hellishbite",
            },
        },
        hellishbite = {
            title = TITLES_ELEMENTALISM.HELLISHBITE,
            description = DESC_ELEMENTALISM.HELLISHBITE,
            icon = "wilson_alchemy_1",
            pos = {-62, 176-486},
            group = "elementalism",
            tags = {"elementalism"},
            connects = {
                "icyveins",
            },
        },
        icyveins = {
            title = TITLES_ELEMENTALISM.ICYVEINS,
            description = DESC_ELEMENTALISM.ICYVEINS,
            icon = "wilson_alchemy_1",
            pos = {-62, 176-486},
            group = "elementalism",
            tags = {"elementalism"},
            connects = {
                "elementalsurge",
            },
        },
        elementalsurge = {
            title = TITLES_ELEMENTALISM.ELEMENTALSURGE,
            description = DESC_ELEMENTALISM.ELEMENTALSURGE,
            icon = "wilson_alchemy_1",
            pos = {-62, 176-486},
            group = "elementalism",
            tags = {"elementalism"},
            connects = {
                "pyroblast",
                "glacialspike",
            },
        },
        pyroblast = {
            title = TITLES_ELEMENTALISM.PYROBLAST,
            description = DESC_ELEMENTALISM.PYROBLAST,
            icon = "wilson_alchemy_1",
            pos = {-62, 176-486},
            group = "elementalism",
            tags = {"elementalism"},
            connects = {
                "muspelcore",
            },
        },
        muspelcore = {
            title = TITLES_ELEMENTALISM.MUSPELCOR,
            description = DESC_ELEMENTALISM.MUSPELCOR,
            icon = "wilson_alchemy_1",
            pos = {-62, 176-486},
            group = "elementalism",
            tags = {"elementalism"},
        },
        glacialspike = {
            title = TITLES_ELEMENTALISM.GLACIALSPIKE,
            description = DESC_ELEMENTALISM.GLACIALSPIKE,
            icon = "wilson_alchemy_1",
            pos = {-62, 176-486},
            group = "elementalism",
            tags = {"elementalism"},
            connects = {
                "niflcore",
            },
        },
        niflcore = {
            title = TITLES_ELEMENTALISM.NIFLCORE,
            description = DESC_ELEMENTALISM.NIFLCORE,
            icon = "wilson_alchemy_1",
            pos = {-62, 176-486},
            group = "elementalism",
            tags = {"elementalism"},
        },
    }

    return {
        SKILLS = skills,
        ORDERS = ORDERS,
    }
end

return BuildSkillsData