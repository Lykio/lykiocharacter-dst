local RunicPowerMeter = Class(function(self, inst)
    self.inst = inst

    if TheWorld.ismastersim then
        self.classified = inst.player_classified
    elseif self.classified == nil and inst.player_classified ~= nil then
        self:AttachClassified(inst.player_classified)
    end
end)

function RunicPowerMeter:OnRemoveFromEntity()
    if self.classified ~= nil then
        if TheWorld.ismastersim then
            self.classified = nil
        else
            self.inst:RemoveEvenCallback("onremove", self.ondetachclassified, self.classified)
            self:DetachClassified()
        end
    end
end

--RunicPowerMeter.OnRemoveFromEntity = RunicPowerMeter.OnRemoveFromEntity

function RunicPowerMeter:AttachClassified(classified)
    self.classified = classified
    self.ondetachclassified = function() self:DetachClassified() end
    self.inst:ListenForEvent("onremove", self.ondetachclassified, classified)
end

function RunicPowerMeter:DetachClassified()
    self.classified = nil
    self.ondetachclassified = nil
end

local function Set(netvar, value)
    netvar:set(value)
end

function RunicPowerMeter:SetCurrent(current)
    Set(self.inst["current"], current)
end

function RunicPowerMeter:SetMax(max)
    Set(self.inst["max"], max)
end

function RunicPowerMeter:GetCurrent()
    if self.inst.components.runicpowermeter ~= nil then
        return self.inst.components.runicpowermeter:GetCurrent()
    else
        return self.inst["current"]:value()
    end
end

function RunicPowerMeter:GetMax()
    if self.inst.components.runicpowermeter ~= nil then
        return self.inst.components.runicpowermeter:GetMax()
    else
        return self.inst["max"]:value()
    end
end

function RunicPowerMeter:GetPercent()
    if self.inst.components.runicpowermeter ~= nil then
        return self.inst.components.runicpowermeter:GetPercent()
    else
        return self.inst["current"]:value() / self.inst["max"]:value()
    end
end

return RunicPowerMeter