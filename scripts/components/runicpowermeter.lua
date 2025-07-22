require "math"

-- This is for debugging purposes
local function DebugPrint(...)
    print("[RunicPower Debug]", ...)
end

local function SetReplicaRPMax(self, max)
    self.inst.replica.rpmeter:SetMax(max)
end

local function SetReplicaRPCurrent(self, current)
    self.inst.replica.rpmeter:SetCurrent(current)
end

local RunicPowerMeter = Class(function(self, inst)
    self.inst = inst
    self.max = TUNING.LYKIO.RUNICPOWER.STATS.MAX.DEFAULT
    self.current = TUNING.LYKIO.RUNICPOWER.STATS.CURRENT.DEFAULT
    self.initialspawn = true
    self.regen = TUNING.LYKIO.RUNICPOWER.STATS.REGEN.DEFAULT
    self.regen_period = TUNING.LYKIO.RUNICPOWER.STATS.REGEN.PERIOD.DEFAULT
    self.regen_task = nil
end)

function RunicPowerMeter:OnSave()
    AddDeconstructRecipe {
        _current = self.current,
        _max = self.max,
        _regen_task = self.regen_task
    }
end

function RunicPowerMeter:OnLoad(data)
    if data._current ~= nil then
        self.inst:DoTaskInTime(1, function()
            self:SetCurrent(data._current)
        end)
    end

    if data._max ~= nil then
        self.inst:DoTaskInTime(1, function()
            self:SetMax(data._max)
        end)
    end

    if data._regen_task ~= nil then
        self.inst:DoTaskInTime(1, function()
            self:SetRegenTask(data._regen_task)
        end)
    end
end

function RunicPowerMeter:SetMax(max)
    SetReplicaRPMax(self, max)
    self.max = max
end

function RunicPowerMeter:GetMax()
    return self.max
end

function RunicPowerMeter:SetCurrent(amt)
    if amt <= self:GetMax() then
        self.current = amt
        SetReplicaRPCurrent(self, amt)
    else
        self.current = self:GetMax()
        SetReplicaRPCurrent(self, self:GetMax())
    end
end

function RunicPowerMeter:GetCurrent()
    return self.current
end

function RunicPowerMeter:DoDelta(delta, overtime, cause)
    DebugPrint("RunicPowerMeter:DoDelta", delta, "overtime:", overtime, "cause:", cause)

    if self.redirect ~= nil then
        self.redirect(self.inst, delta, overtime)
        return
    end

    delta = tonumber(delta)
    local old = self.current
    self.current = math.clamp(self.current + delta, 0, self.max)

    self.inst:PushEvent("rpmeterdelta", { oldpercent = old / self.max, newpercent = self.current / self.max, overtime = overtime, delta = self.current - old})

    local val = self.current
    SetReplicaRPCurrent(self, val)
end

function RunicPowerMeter:GetPercent()
    return self.current / self.max
end

function RunicPowerMeter:SetPercent(percent, overtime)
    local old = self.current
    self.current = percent * self.max
    self.inst:PushEvent("rpmeterdelta", { oldpercent = old / self.max, newpercent = percent, overtime = overtime})
end

function RunicPowerMeter:StopRegen()
    if self.regen_task ~= nil then
        self.regen_task:Cancel()
        self.regen_task = nil
    else
        DebugPrint("RunicPowerMeter:StopRegen called but no regen task is running")
    end
end

function RunicPowerMeter:StartRegen(amt, period, interruptcur)
    if interruptcur ~= false then
        self:StopRegen()
    end

    self.regen.rate = amt or TUNING.LYKIO.RUNICPOWER.STATS.REGEN.DEFAULT
    self.regen.period = period or TUNING.LYKIO.RUNICPOWER.STATS.REGEN.PERIOD.DEFAULT

    if self.regen_task == nil then
        self.regen_task = self.inst:DoPeriodicTask(self.regen.period, (function () self:DoDelta(self.regen.rate, true, "regen") end), nil, self)
    end
end

function RunicPowerMeter:SpendRP(amt, cause)
    if amt <= 0 then return false end

    if self.current >= amt then
        self:DoDelta(-amt, false, cause)
        return true
    else
        DebugPrint("Not enough Runic Power to spend on", cause, "for", amt, "current:", self.current)
        return false
    end
end

function RunicPowerMeter:SetRate(rate)
    self.regen_rate = rate or TUNING.LYKIO.RUNICPOWER.STATS.REGEN.DEFAULT
end

function RunicPowerMeter:GetRate()
    return self.regen_rate
end

function RunicPowerMeter:SetPeriod(period)
    self.regen_period = period or TUNING.LYKIO.RUNICPOWER.STATS.REGEN.PERIOD.DEFAULT
end

function RunicPowerMeter:GetPeriod()
    return self.regen_period
end

function RunicPowerMeter:GetTask()
    return self.regen_task
end

function RunicPowerMeter:OnRemoveEntity()
    self:StopRegen()
    self.regen_task:Cancel()
    self.regen_task = nil
end

return RunicPowerMeter