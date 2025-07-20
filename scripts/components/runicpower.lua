local Badge = require "widgets/badge"
local net = GLOBAL.net_shortint

-- This is for debugging purposes
local function DebugPrint(...)
    print("[RunicPower Debug]", ...)
end

---@class RunicPower extends Component
local RunicPower = Class(function(self, inst)
    DebugPrint("Initializing RunicPower component")
    self.inst = inst
    self.max = 100 -- base maximum RP
    self.current = 50 -- start at half
    self.regen_rate = 1 -- RP per period
    self.regen_period = 10 -- Seconds between regen
    self.regen_task = nil -- Regeneration task
    self.absorb_enabled = false
    self.badge = nil

    --[[self._max = net(inst.GUID, "runicpower._max", "maxdirty")
    self._current = net(inst.GUID, "runicpower._current", "currentdirty")
    self._regen_rate = net(inst.GUID, "runicpower._regen_rate", "regendirty")
    self._regen_period = net(inst.GUID, "runicpower._regen_period", "perioddirty")
    self._regen_task = net(inst.GUID, "runicpower._regen_task", "regentaskdirty")
    self._absorb_enabled = net(inst.GUID, "runicpower._absorb_enabled", "absorbenableddirty")

    self._max:set(self.max)
    self._current:set(self.current)
    self._regen_rate:set(self.regen_rate)
    self._regen_period:set(self.regen_period)
    self._regen_task:set(self.regen_task)
    self._absorb_enabled:set(self.absorb_enabled)--]]


    if not TheWorld.ismastersim then
        -- Wait for hud to be ready
        inst:DoTaskInTime(0.5, function()
            self:CreateBadge()
        end)

        -- Listen for hud changes
        inst:ListenForEvent("gaincontrol", function()
            DebugPrint("Gained control, updating badge")
            self:CreateBadge()
        end)
    end
end)

---@param self RunicPower
function RunicPower:CreateBadge()
    DebugPrint("Attempting to create badge")
    if self.badge then
        DebugPrint("badge already exists, skipping creation")
        return
    end

    if not (self.inst.HUD and self.inst.HUD.controls and self.inst.HUD.controls.status) then
        DebugPrint("ERROR: HUD controls not found")
        return
    end

    DebugPrint("Creating runic power badge")
    self.badge = self.inst.HUD.controls.status:AddChild(Badge(
        "status_meter",
        self.inst,
        {0.5, 0.8, 1, 1}, -- blue tint
        "images/status_icons/runicpowericon.xml", -- custom icon
        "runicpowericon.tex", -- custom icon texture
        true, -- not circular
        false -- use normal bg
    ))
    if not self.badge then
        DebugPrint("ERROR: Failed to create badge")
        return
    end

    -- Set up initial state
    self.badge:SetPosition(-80, -130)  -- Below sanity badge
    self.badge:SetPercent(self:GetPercent())

    DebugPrint("badge created successfully")
end

---@param self RunicPower
function RunicPower:UpdateDisplay()
    if TheWorld.ismastersim then return end
    DebugPrint("Updating display - Current:", self.current, "Max:", self.max)
    
    -- Update bar fill amount
    self.badge:SetPercent(self:GetPercent())
end

---@param self RunicPower
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

---@param self RunicPower
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

---@param self RunicPower
function RunicPower:StartRegen()
    DebugPrint("Starting regeneration")
    if self.regen_task ~= nil then self:StopRegen() end

    self.regen_task = self.inst:DoPeriodicTask(self.regen_period, function()
        DebugPrint("Regenerating runic power")
        self:DoDelta(self.regen_rate, false, "regen")
    end)
end

---@param self RunicPower
function RunicPower:StopRegen()
    if self.regen_task then
        DebugPrint("Stopping regeneration")
        self.regen_task:Cancel()
        self.regen_task = nil
    end
end

---@param self RunicPower
function RunicPower:SetMax(amt)
    DebugPrint("Setting max runic power from", self.max, "to", amt)
    self.max = math.max(0, amt)

    if self.current > self.max then
        DebugPrint("Adjusting current value to match new max")
        self.current = self.max
        
        -- Update badge
        if self.badge then
            DebugPrint("Updating badge after max change")
            self:UpdateDisplay()
        end
    end
end

---@param self RunicPower
function RunicPower:GetMax()
    return self.max
end

---@param self RunicPower
function RunicPower:SetCurrent(amt)
    DebugPrint("Setting current runic power to ", amt)
    self.current = math.max(0, math.min(self.max, amt))

    -- Update badge
    if not TheWorld.ismastersim and self.badge then
        DebugPrint("Updating badge after max change")
        self.badge:UpdateDisplay()
    end
end

---@param self RunicPower
function RunicPower:GetCurrent()
    return self.current
end

---@param self RunicPower
function RunicPower:GetPercent()
    return self.max > 0 and self.current / self.max or 0
end

---@param self RunicPower
function RunicPower:DoDelta(amt, overtime, cause)
    if amt == 0 then
        DebugPrint("DoDelta called with zero amount, skipping")
        return
    end

    DebugPrint("DoDelta called - Amount:", amt, "Overtime:", overtime, "Cause:", cause)
    local old_current = self.current
    self.current = math.max(0, math.min(self.max, self.current + amt))
    DebugPrint("Value changed from", old_current, "to", self.current)

    -- Update badge
    if self.current ~= old_current then
        if not TheWorld.ismastersim then
            self:UpdateDisplay()
        end
    end

    return self.current - old_current
end

---@param self RunicPower
function RunicPower:CanSpend(amt)
    DebugPrint("Checking if can spend", amt, "current:", self.current)
    return self.current >= amt
end

---@param self RunicPower
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


---@param self RunicPower
function RunicPower:SetRegenRate(rate)
    DebugPrint("Setting regeneration rate to:", rate)
    self.regen_rate = rate
end

---@param self RunicPower
function RunicPower:GetRegenRate()
    DebugPrint("Getting regeneration rate:", self.regen_rate)
    return self.regen_rate
end

---@param self RunicPower
function RunicPower:SetRegenPeriod(period)
    self.regen_period = period
    DebugPrint("Setting regeneration period to:", period)
    -- Restart regen with new period
    if self.regen_task then
        self:StartRegen()
    end
end

---@param self RunicPower
function RunicPower:GetRegenPeriod()
    DebugPrint("Getting regeneration period:", self.regen_period)
    return self.regen_period
end

-- Enable/disable absorb mechanics for talents
---@param self RunicPower
function RunicPower:SetAbsorbEnabled(enabled)
    DebugPrint("Setting absorb enabled to:", enabled)
    self.absorb_enabled = enabled
end

---@param self RunicPower
function RunicPower:IsAbsorbEnabled()
    return self.absorb_enabled
end

---@param self RunicPower
function RunicPower:OnRemoveEntity()
    DebugPrint("Removing RunicPower component")
    self:StopRegen()

    if self.badge then
        self.badge:Kill()
        self.badge = nil
    end
end

return RunicPower