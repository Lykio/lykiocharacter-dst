
local ElementalAffinity = Class(function(self, inst, sanity)
    self.inst = inst
    self.last_feed_time = 0

    self.fire_resist = 0.5
    self.ice_resist = 0.5

    inst:ListenForEvent("attacked", function(inst, data) self:OnAttacked(data) end)
end)

function ElementalAffinity:OnAttacked(data)
    if data and data.damage and data.attacker then
        if data.attacker:HasTag("fire") then 
            data.damage = data.damage * self.fire_resist
        elseif data.attacker:HasTag("ice") then
            data.damage = data.damage * self.ice_resist
        end
    end
end

function ElementalAffinity:CheckFireSanity()
    local x, y, z = self.inst.Transform:GetWorldPosition()
    local entities = TheSim:FindEntities(x, y, z, 10, nil, { "fire" })

    if #entities > 0 and self.inst.components.sanity then 
        self.inst.components.sanity:DoDelta(3)
    end
end