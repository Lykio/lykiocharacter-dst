
-- Frozen Runeband item effect
local function ApplyFrozenRunebandEffect(inst)
    -- This would be called when the item is equipped
    if inst.components.runicpower then
        local old_rate = inst.components.runicpower:GetRegenRate()
        inst.components.runicpower:SetRegenRate(old_rate * 1.33)  -- 33% faster
    end
end

local function RemoveFrozenRunebandEffect(inst)
    -- This would be called when the item is unequipped
    if inst.components.runicpower then
        local current_rate = inst.components.runicpower:GetRegenRate()
        inst.components.runicpower:SetRegenRate(current_rate / 1.33)  -- Reset
    end
end