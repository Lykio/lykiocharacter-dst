local Badge = require "widgets/badge"

local RunicPower = Class(function(self, inst)
    self.inst = inst
    self.badge = nil

    inst:DoTaskInTime(0.5, function()
        if inst.HUD and inst.HUD.controls and inst.HUD.controls.status then
            self.badge = inst.HUD.controls.status:AddChild(Badge(
                "status_meter",
                inst,
                {0.5, 0.8, 1, 1},
                "images/status_icons/runicpowericon.xml",
                "runicpowericon.tex",
                true,
                false
            ))
            if self.badge then
                self.badge:SetPosition(-80, -130)
                -- You will update this percent from a netvar!
                self.badge:SetPercent(self:GetPercent())
            end
        end
    end)
end)

-- Example: Read a netvar (see below for netvar setup)
function RunicPower:GetPercent()
    local max = self.inst.replica.runicpower:GetMax() or 100
    local current = self.inst.replica.runicpower:GetCurrent() or 0
    return max > 0 and current / max or 0
end

return RunicPower