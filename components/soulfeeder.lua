local SOUL_FEED_RADIUS = 10

local SoulFeeder = Class(function(self, inst, cooldown, health, hunger, sanity)
    self.inst = inst
    self.last_feed_time = 0

    self.cooldown = cooldown or 0

    self.health = health or 5
    self.hunger = hunger or 3
    self.sanity = sanity or 3
    self.sanity_locked = false
    self.bonus = 3

    self.death_listener = TheWorld:ListenForEvent("entity_death", function(world, data) self:OnEntityDeath(data) end)
end)

function SoulFeeder:Feed(insane)
    if self.inst.components.health ~= nil and not insane then
        self.inst.components.health:DoDelta(self.health, false, "soulfeed") -- no bonus, no insanity
    else
        self.inst.components.health:DoDelta(self.health + self.bonus, false, "soulfeed") -- bonus, insane
    end

    if self.inst.components.hunger ~= nil and not insane then
        self.inst.components.hunger:DoDelta(self.hunger) -- no bonus, no insanity
    else
        self.inst.components.hunger:DoDelta(self.hunger + self.bonus) -- bonus, insane
    end
    
    if self.inst.components.sanity ~= nil then
        local current_sanity = self.inst.components.sanity:GetCurrent()

        -- If sanity locked 
        if self.sanity_locked then 
            if current_sanity <= 0 then
                self.sanity_locked = false -- unlocked at 0 sanity
            else
                return -- blocked while locked
            end
        end

        -- Feed
        if not insane then
            self.inst.components.sanity:DoDelta(self.sanity)  -- no bonus, no insanity
        else
            self.inst.components.sanity:DoDelta(self.sanity + self.bonus) -- bonus, insane
        end

        -- If not insane unlock sanity
        if not insane then
            self.sanity_locked = false
        end

        -- If insane and sanity is locked, lock sanity
        if insane and not self.sanity_locked then
            self.sanity_locked = true -- lock sanity if insane
        end 

        -- Unlocked sanity check
        if not self.sanity_locked and not insane then
            self.inst.components.sanity:DoDelta(self.sanity)  -- no bonus, no insanity
        elseif not self.sanity_locked and insane then
            self.inst.components.sanity:DoDelta(self.sanity + self.bonus) -- bonus, insane
        elseif current_sanity <= 30 then
            self.sanity_locked = true
        end 
    else
        
    end
end

function SoulFeeder:OnEntityDeath(data)
    if not data or not data.inst then return end

    local dying_entity = data.inst

    -- Check tags: only proceed if entity is player or creature
    if not (dying_entity:HasTag("player") or dying_entity:HasTag("character") or dying_entity:HasTag("creature")) then
        return
    end

    -- Check cooldown
    local current_time = GetTime()
    if current_time - self.last_feed_time < self.cooldown then
        return
    end

    -- Range calculated to 10m~
    local x, y, z = self.inst.Transform:GetWorldPosition()
    local dx, dy, dz = dying_entity.Transform:GetWorldPosition()

    local dist_sq = (x - dx)^2 + (y - dy)^2 + (z - dz)^2
    if dist_sq <= SOUL_FEED_RADIUS * SOUL_FEED_RADIUS then
        self.Feed(self, self.inst.components.sanity:GetCurrent() <= 30)
        SpawnPrefab("sparks"):AttachTo(self.inst.entity)

        self.last_feed_time = current_time
    end
end

function SoulFeeder:OnRemoveFromEntity()
    if self.death_listener ~= nil then
        self.death_listener:Remove()
        self.death_listener = nil
    end
end

return SoulFeeder
