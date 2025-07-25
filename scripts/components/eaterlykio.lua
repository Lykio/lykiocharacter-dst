
local function DebugPrint(...)
    if DEV_MODE then print("[Lykio Eater Debug]", ...) end
end

local EaterLykio = Class(function(self, inst)
    DebugPrint("Creating EaterLykio component")
    self.inst = inst
    self.last_soul_eaten_time = nil
end)

local function IsSoulless(victim)
    return (victim:HasTag("shadow") or
        victim:HasTag("shadowcreature") or
        victim:HasTag("shadow_aligned") or
        victim:HasTag("nightmarecreature"))
end

local function IsSoulFood(food)
    DebugPrint("Checking if food is soul food:", food and food.prefab or "nil")
    return food and food.components.edible and food.components.edible.foodtype == FOODTYPE.SOUL
end

local function IsCrazy(inst)
    DebugPrint("Checking if player is crazy:", inst.components.sanity and inst.components.sanity:IsCrazy())
    return inst.components.sanity and inst.components.sanity:IsCrazy()
end

---@class EaterLykio extends Eater
function EaterLykio:OnEat(food)
    DebugPrint("OnEat called with food:", food and food.prefab or "nil")
    if not food or not food.components.edible then return end

    local inst = self.inst
    local rpm = inst.components.runicpowermeter
    local hunger = food.components.edible.hungervalue or 0
    local sanity = food.components.edible.sanityvalue or 0
    local health = food.components.edible.healthvalue or 0
    local is_soul = IsSoulFood(food)
    local is_crazy = IsCrazy(inst)

    local RUNICPOWER = TUNING.LYKIO.RUNICPOWER

    if is_soul then
        DebugPrint("Food is soul food, processing...")
        -- Soul foods give normal stats + RP
        if rpm then
            if food.prefab == "horrorfuel" then
                DebugPrint("Processing horrorfuel soul food for hunger/sanity/health/rp", TUNING.CALORIES_LARGE * 1.33, TUNING.SANITY_LARGE * 1.33, TUNING.HEALING_MED * 1.33, RUNICPOWER.HUGE * 1.33)
                inst.components.hunger:DoDelta(TUNING.CALORIES_LARGE * 1.33) -- 37.5 + 33%
                inst.components.sanity:DoDelta(TUNING.SANITY_LARGE * 1.33) -- 33 + 33%
                inst.components.health:DoDelta(TUNING.HEALING_MED * 1.33) -- 20 + 33%
                rpm:DoDelta(RUNICPOWER.HUGE * 1.33, false, "eat_soul_huge") -- 50
                return true
            end
            DebugPrint("Processing nightmarefuel soul food for hunger/sanity/health/rp", TUNING.CALORIES_MED, TUNING.SANITY_MED, TUNING.HEALING_MEDSMALL, RUNICPOWER.LARGE)
            inst.components.hunger:DoDelta(TUNING.CALORIES_MED) --25
            inst.components.sanity:DoDelta(TUNING.SANITY_MED) -- 15
            inst.components.health:DoDelta(TUNING.HEALING_MEDSMALL) -- 8
            rpm:DoDelta(RUNICPOWER.LARGE, false, "eat_soul") -- 20
            self.last_soul_eaten_time = GetTime()
            return true
        else
            -- Non-soul foods give 15% less stats, only 50% when insane, no RP
            local mult = is_crazy and 0.50 or 0.85
            DebugPrint("Processing non-soul food for hunger/sanity/health", hunger * mult, sanity * mult, health * mult)
            inst.components.hunger:DoDelta(hunger * mult)
            inst.components.sanity:DoDelta(sanity * mult)
            inst.components.health:DoDelta(health * mult)

            if math.random() < 0.2 and inst.components.talker then
                inst.components.talker:Say("Why do humans consume this muck..?")
                --TODO : Complaining strings
            end
            return true
        end
    end
end

-- TODO : Make this retroactively apply DoDelta with the skilltree
function EaterLykio:OnKill(data)
    local inst = self.inst
    local rpm = inst.components.runicpowermeter
    local victim = data and data.victim
    local RUNICPOWER = TUNING.LYKIO.RUNICPOWER

    if not victim then return end
    -- TODO : soul tag doesn't exist, reductively refuse shadow creatures - found tags "shadowcreature" & "shadow" & "shadow_aligned"
    if victim:HasTag("player") or not IsSoulless(victim) then
        DebugPrint("OnKill called, victim is a player or has soul tag:")
        inst.components.hunger:DoDelta(RUNICPOWER.TINY)
        inst.components.sanity:DoDelta(RUNICPOWER.TINY)
        inst.components.health:DoDelta(RUNICPOWER.TINY)
        if rpm then rpm:DoDelta(RUNICPOWER.TINY) end

        self.last_soul_eaten_time = GetTime()
    end
end

-- TODO : Make this retroactively tune sanityrate with the skilltree
function EaterLykio:GetCustomSanityRate()
    local sanity = self.inst.components.sanity
    local base = 0

    if sanity and self.sanity_rate_fn then
        base = sanity._old_custom_rate_fn(self.inst)
    end

    local now = GetTime()
    if self.last_soul_eaten_time and now - self.last_soul_eaten_time < TUNING.TOTAL_DAY_TIME*1.5 then -- 1.5 days
        return base
    else
        return base * 1.33 -- 33% more sanity drain
    end
end

return EaterLykio