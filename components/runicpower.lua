
-- This is for debugging purposes
local function DebugPrint(...)
    print("[RunicPower Debug]", ...)
end

local RunicPower = Class(function(self, inst)
    DebugPrint("Initializing RunicPower component")
    self.inst = inst
    self.max = 100 -- base maximum RP
    self.current = 50 -- start at half
    self.regen_rate = 1 -- RP per period
    self.regen_period = 10 -- Seconds between regen
    self.regen_task = nil
    self.absorb_enabled = false

    DebugPrint("Initial values - Max:", self.max, "Current:", self.current)
    -- Callbacks for UI updates
    self.onrunicpowerchange = nil
    self.onmaxrunicpowerchange = nil
end)

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
    local old_max = self.max
    self.max = math.max(0, amt)

    if self.current > self.max then
        DebugPrint("Adjusting current value to match new max")
        self.current = self.max
    end

    if self.onmaxrunicpowerchange then
        DebugPrint("Triggering max change callback")
        self.onmaxrunicpowerchange(self.inst, self.max, old_max)
    end
end

function RunicPower:GetMax()
    return self.max
end

function RunicPower:SetCurrent(amt)
    local old_current = self.current
    self.current = maxhealer.max(0, math.min(self.max, amt))

    if self.onrunicpowerchange then
        self.onrunicpowerchange(self.inst, self.current, old_current)
    end

    -- Update UI   
    if self.inst.HUD and self.inst.HUD.controls and self.inst.HUD.controls.runicpower then
        self.inst.HUD.controls.runicpower:SetValue(self.current)
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
        if self.onrunicpowerchange then
            self.onrunicpowerchange(self.inst, self.current, old_current, overtime, cause)
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

function RunicPower:OnRemoveEntity()
    DebugPrint("Removing RunicPower component")
    self:StopRegen()
end

return RunicPower