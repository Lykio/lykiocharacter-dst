local DeathsEmbrace = Class(function(self, inst)
    self.inst = inst
    self.active = false

    -- Store original values for revert
    self.base_max_health = inst.components.health.maxhealth

    -- Periodic check for activation/deactivation
    self.check_task = inst:DoPeriodicTask(1, function() self:CheckSanity() end)
end)

function DeathsEmbrace:CheckSanity()
    local sanity = self.inst.components.sanity
    if sanity == nil then return end

    local current_sanity = sanity:GetCurrent()

    if current_sanity <= 30 then
        if not self.active then
            self:Activate()
        end
    else
        if self.active then
            self:Deactivate()
        end
    end
end

function DeathsEmbrace:Activate()
    self.active = true

    -- +15% move speed
    if self.inst.components.locomotor then
        self.inst.components.locomotor:SetExternalSpeedMultiplier(self.inst, "deaths_embrace_speed", 1.15)
    end

    -- +20% damage
    if self.inst.components.combat then
        self.inst.components.combat.externaldamagemultipliers:SetModifier(self.inst, 1.2, "deaths_embrace_dmg")
    end

    -- -25 max HP
    if self.inst.components.health then
        self.inst.components.health:SetMaxHealth(self.base_max_health - 25)
    end

    -- Soul Feeder synergy: Increase restore values by +3 each if SoulFeeder exists
    if self.inst.components.soulfeeder then
        local sf = self.inst.components.soulfeeder
        sf:SetRestoreValues(sf.health_restore + 3, sf.hunger_restore + 3, sf.sanity_restore + 3)
    end
end

function DeathsEmbrace:Deactivate()
    self.active = false

    -- Remove speed buff
    if self.inst.components.locomotor then
        self.inst.components.locomotor:RemoveExternalSpeedMultiplier(self.inst, "deaths_embrace_speed")
    end

    -- Remove damage buff
    if self.inst.components.combat then
        self.inst.components.combat.externaldamagemultipliers:RemoveModifier(self.inst, "deaths_embrace_dmg")
    end

    -- Restore max HP
    if self.inst.components.health then
        self.inst.components.health:SetMaxHealth(self.base_max_health)
    end

    -- Revert SoulFeeder restore values if SoulFeeder exists
    if self.inst.components.soulfeeder then
        local sf = self.inst.components.soulfeeder
        sf:SetRestoreValues(sf.health_restore - 3, sf.hunger_restore - 3, sf.sanity_restore - 3)
    end
end

function DeathsEmbrace:OnRemoveFromEntity()
    if self.check_task then
        self.check_task:Cancel()
        self.check_task = nil
    end
end

return DeathsEmbrace