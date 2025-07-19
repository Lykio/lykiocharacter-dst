local RingMeter = require "widgets/ringmeter"

-- This is for debugging purposes
local function DebugPrint(...)
    print("[RunicPower Debug]", ...)
end

local RunicPowerMeter = Class(RingMeter, function(self, owner, max, current)
    DebugPrint("Initializing RunicPowerBadge")
    RingMeter._ctor(self, "RunicPowerBadge")

    DebugPrint("Setting up badge properties")
    self.owner = owner
    self.max = 100
    self.current = 0

    -- Create background
    self.bg = self:AddChild(Image("images/ui.xml", "status_bg.tex"))
    self.bg:SetSize(60, 60)
    
    -- Create icon
    self.icon = self:AddChild(Image("images/ui.xml", "health.tex"))
    self.icon:SetSize(40, 40)
    
    -- Create meter ring
    self.ring = self:AddChild(Image("images/ui.xml", "status_meter.tex"))
    self.ring:SetSize(65, 65)
    
    -- Create value text
    self.text = self:AddChild(Text(NUMBERFONT, 20, tostring(self.current_value)))
    self.text:SetPosition(0, -40)
    
    -- Start updating
    self:StartUpdating()
end)

local RunicPower = Class(function(self, inst)
    DebugPrint("Initializing RunicPower component")
    self.inst = inst
    self.max = 100 -- base maximum RP
    self.current = 50 -- start at half
    self.regen_rate = 1 -- RP per period
    self.regen_period = 10 -- Seconds between regen
    self.regen_task = nil -- Regeneration task
    self.absorb_enabled = false
    self.meter = nil

end)

function RunicPower:CreateMeter()
    if self.meter ~= nil then
        self.meter:Kill()
    end

    if not self.inst.HUD then return end

    DebugPrint("Creating runic power meter")
    self.meter = self.inst.HUD.controls.status:AddChild(RingMeter(self.inst))

    -- Position relative to other status elements
    self.meter:SetPosition(-40, -50)  -- Adjust these values to position under other status bars
    
    -- Set up initial state
    self.meter:GetAnimState():SetMultColour(0.4, 0.4, 1.1, 1.1)
    self.meter:StartTimer(self.max, self.current)
end

function RunicPowerMeter:UpdateDisplay()
    local current = self.owner.components.runicpower:GetCurrent()
    local max = self.owner.components.runicpower:GetMax()

    DebugPrint("Updating display - Current:", current, "Max:", max)
    
    local percent = max > 0 and current / max or 0
    DebugPrint("Calculated percentage:", percent)
    
    -- Update bar fill amount
    self.meter:StartTimer(max, current)
    
    -- Update number display
    self.text:SetString(string.format("%d", current))
end

function RunicPower:OnSave()
    DebugPrint("Saving RunicPower state")
    local data = {
        max = self.max,
        current = self.current,
        regen_rate = self.regen_rate,
        regen_period = self.regen_period,
        absorb_enabled = self.absorb_enabled
    }
    DebugPrint("Saved data:", data)
    return data
end

function RunicPower:OnLoad(data)
    DebugPrint("Loading RunicPower state")
    if data then
        DebugPrint("Loading data:", data)
        self.max = data.max or self.max
        self.current = data.current or self.current
        self.regen_rate = data.regen_rate or self.regen_rate
        self.regen_period = data.regen_period or self.regen_period
        self.absorb_enabled = data.absorb_enabled or self.absorb_enabled
        DebugPrint("Loaded values - Max:", self.max, "Current:", self.current)
    else
        DebugPrint("No data to load")
    end
end

function RunicPower:StartRegen()
    DebugPrint("Starting regeneration")
    self:StopRegen()
    self.regen_task = self.inst:DoPeriodicTask(self.regen_period, function()
        DebugPrint("Regenerating runic power")
        self:DoDelta(self.regen_rate, false, "regen")
    end)
end

function RunicPower:StopRegen()
    if self.regen_task then
        DebugPrint("Stopping regeneration")
        self.regen_task:Cancel()
        self.regen_task = nil
    end
end

function RunicPower:SetMax(amt)
    DebugPrint("Setting max runic power from", self.max, "to", amt)
    self.max = math.max(0, amt)

    if self.current > self.max then
        DebugPrint("Adjusting current value to match new max")
        self.current = self.max
        
        -- Update meter
        if self.meter then
            DebugPrint("Updating meter after max change")
            self:UpdateDisplay()
        end
    end
end

function RunicPower:GetMax()
    return self.max
end

function RunicPower:SetCurrent(amt)
    DebugPrint("Setting current runic power to ", amt)
    self.current = math.max(0, math.min(self.max, amt))

    -- Update meter
    if self.meter then
        DebugPrint("Updating meter after max change")
        self.meter:UpdateDisplay()
    end
end

function RunicPower:GetCurrent()
    return self.current
end

function RunicPower:GetPercent()
    return self.max > 0 and self.current / self.max or 0
end

function RunicPower:DoDelta(amt, overtime, cause)
    if amt == 0 then
        DebugPrint("DoDelta called with zero amount, skipping")
        return
    end

    DebugPrint("DoDelta called - Amount:", amt, "Overtime:", overtime, "Cause:", cause)
    local old_current = self.current
    self.current = math.max(0, math.min(self.max, self.current + amt))

    if self.current ~= old_current then
        DebugPrint("Value changed from", old_current, "to", self.current)

        -- Update meter
        if self.meter then
            DebugPrint("Updating meter after max change")
            self.meter:UpdateDisplay()
        end
    end

    return self.current - old_current
end

function RunicPower:CanSpend(amt)
    DebugPrint("Checking if can spend", amt, "current:", self.current)
    return self.current >= amt
end

function RunicPower:Spend(amt, cause)
    DebugPrint("Attempting to spend", amt, "runic power")
    if not self:CanSpend(amt) then
        DebugPrint("Cannot spend - insufficient runic power")
        return false
    end

    DebugPrint("Spending runic power")
    self:DoDelta(-amt, false, cause or "spell")

    return true
end


function RunicPower:SetRegenRate(rate)
    DebugPrint("Setting regeneration rate to:", rate)
    self.regen_rate = rate
end

function RunicPower:GetRegenRate()
    DebugPrint("Getting regeneration rate:", self.regen_rate)
    return self.regen_rate
end

function RunicPower:SetRegenPeriod(period)
    self.regen_period = period
    DebugPrint("Setting regeneration period to:", period)
    -- Restart regen with new period
    if self.regen_task then
        self:StartRegen()
    end
end

function RunicPower:GetRegenPeriod()
    DebugPrint("Getting regeneration period:", self.regen_period)
    return self.regen_period
end

-- Enable/disable absorb mechanics for talents
function RunicPower:SetAbsorbEnabled(enabled)
    DebugPrint("Setting absorb enabled to:", enabled)
    self.absorb_enabled = enabled
end

function RunicPower:IsAbsorbEnabled()
    return self.absorb_enabled
end

function RunicPower:OnRemoveEntity()
    DebugPrint("Removing RunicPower component")
    self:StopRegen()

    if self.meter then
        self.meter:Kill()
        self.meter = nil
    end
end

return RunicPower