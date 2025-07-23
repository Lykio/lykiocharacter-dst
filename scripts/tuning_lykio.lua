-- Tuning param
--local seg_time = 30
--local total_day_time = seg_time * 16

TUNING.LYKIO = {}

TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.LYKIO = {
    "nightmarefuel",
    "nightmarefuel",
    "horrorfuel"
}

---@enum TUNING.LYKIO.STATS
TUNING.LYKIO.STATS = {
    HEALTH = 145,
    HUNGER = 265,
    HUNGERRATE = 1.0, -- TODO : Adjust for skilltrees
    SANITY = 120,
    SANITYRATE = 1.33, -- TODO : Adjust for skilltrees

    DAMAGE = 1,
    SPEED = 1.0,
    NIGHTVISION = true,

    WINTER_INSULATION = 1.67,
    SUMMER_INSULATION = 0.67,
    WETNESS_INSULATION = 0.67
}

-- Adjust durability of items
---@enum TUNING.LYKIO.DURABILITY
TUNING.LYKIO.DURABILITY = {
    STAVES = {
        FIRESTAFF = math.floor(TUNING.FIRESTAFF_USES * 2.5),
        ICESTAFF = math.floor(TUNING.ICESTAFF_USES * 2.5),
        TELESTAFF = math.floor(TUNING.TELESTAFF_USES * 2.5),
    }

}

-- Eater settings
FOODTYPE.SOUL = "SOUL"
TUNING.LYKIO.FOOD_FAVORITE = "nightmarefuel"
TUNING.LYKIO.FOOD_SPOILED_IGNORE = false
TUNING.LYKIO.FOOD_DIET = {
        FOODTYPE.SOUL,
        FOODTYPE.RAW,
        FOODTYPE.MEAT,
        FOODTYPE.VEGGIE,
        FOODTYPE.MONSTER
    }
TUNING.LYKIO.FOOD_TOLERANCE = { FOODGROUP.OMNI }
TUNING.LYKIO.STOMACH_STRONG = true

-- RP TUNING TODO : Adjust for skilltrees
---@enum TUNING.LYKIO.RUNICPOWER
TUNING.LYKIO.RUNICPOWER = {
    -- RESTORE VALUES
    TINY = 1,
    SMALL = 3,
    SMALLMED = 5,
    MED = 10,
    LARGE = 20,
    HUGE = 50,

    STATS = {
        -- RP Maximums
        MAX = {
            DEFAULT_TINY = 50,
            DEFAULT = 100,
            DEFAULT_SMALL = 125,
            DEFAULT_MED = 150,
            DEFAULT_LARGE = 175,
            DEFAULT_HUGE = 250
        },

        -- RP Regen / Cooldown or period
        REGEN = {
            TINY = 1,
            MED = 5,
            LARGE = 15,
            HUGE = 25,
            PERIOD = {
                TINY = 10,
                MED = 12,
                LARGE = 15,
                HUGE = 30
            }
        }
    }
}
