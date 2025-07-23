require "math"

-- This is for debugging purposes
local function DebugPrint(...)
    print("[RunicPower Debug]", ...)
end

local function SetReplicaRPMax(self, max)
    DebugPrint("Setting replica RP max to:", max)
    self.inst.replica.runicpowermeter:SetMax(max)
end

local function SetReplicaRPCurrent(self, current)
    DebugPrint("Setting replica RP current to:", current)
    self.inst.replica.runicpowermeter:SetCurrent(current)
end

local function OnTaskTick(inst, self, period)
    self:DoDec(period)
end

local RunicPowerMeter = Class(function(self, inst)
    self.inst = inst
    self.max = TUNING.LYKIO.RUNICPOWER.STATS.MAX.DEFAULT
    self.current = TUNING.LYKIO.RUNICPOWER.STATS.MAX.DEFAULT / 2
    self.initialspawn = true
    self.regen = TUNING.LYKIO.RUNICPOWER.STATS.REGEN.TINY
    self.regen_period = TUNING.LYKIO.RUNICPOWER.STATS.REGEN.PERIOD.TINY
    self.regen_task = nil

    DebugPrint("DoPeriodicTask", self.regen_period)
    self.inst:DoPeriodicTask(self.regen_period, OnTaskTick, nil, self, self.regen_period)
end,
nil,
{
    max = SetReplicaRPMax,
    current = SetReplicaRPCurrent
})

function RunicPowerMeter:OnSave()
    return {
        _current = self.current,
        _max = self.max,
        _regen = self.regen,
        _regen_period = self.regen_period
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

    if data._regen and data._regen_period ~= nil then
        self:SetRate(data._regen)
        self:SetPeriod(data._regen_period)

        self:StartRegen(data._regen, data._regen_period, true)
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
    if amt <= self.max then
        self.current = amt
        SetReplicaRPCurrent(self, amt)
    else
        self.current = self.max
        SetReplicaRPCurrent(self, self.max)
    end
end

function RunicPowerMeter:GetCurrent()
    return self.current
end

function RunicPowerMeter:DoDelta(delta, overtime, cause)
    DebugPrint("RunicPowerMeter:DoDelta", delta, "overtime:", overtime, "cause:", cause)
    if delta ~= nil then
        delta = tonumber(delta)
    else
        DebugPrint("RunicPowerMeter:DoDelta inst with nil delta, defaulting to TUNING...TINY")
        delta = TUNING.LYKIO.RUNICPOWER.STATS.REGEN.TINY
    end

    if self.redirect ~= nil then
        self.redirect(self.inst, delta, overtime)
        return
    end

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
        DebugPrint("RunicPowerMeter:StopRegen called, cancelling regen task")
        self.regen_task:Cancel()
        self.regen_task = nil
    else
        DebugPrint("RunicPowerMeter:StopRegen called but no regen task is running")
    end
end

function RunicPowerMeter:StartRegen(rate, period, interruptcur)
    DebugPrint("RunicPowerMeter:StartRegen called with interruptcur:", interruptcur)
    if interruptcur then self:StopRegen() end
    if rate ~= nil then self.regen = rate end
    if period ~= nil then self.regen_period = period end

    if self.regen_task == nil then
        DebugPrint("Starting Runic Power regeneration task with regen/overtime/period:", self.regen, "/", true, "/", self.regen_period)
        self.regen_task = self.inst:DoPeriodicTask(self.regen_period, (function ()
                self:DoDelta(self.regen, true, "regen")
            end), nil, self)
    end
end

function RunicPowerMeter:DoDec(period)--[[
    if self.regen_task ~= nil then
        local amt = self.regen.rate * period
        self:DoDelta(-amt, true, "regen")
    else
        DebugPrint("RunicPowerMeter:DoDec called but no regen task is running")
    end--]]
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
    if rate == nil then return error("RunicPowerMeter:SetRate called with no rate!", 3) end
    self.regen = rate
end

function RunicPowerMeter:GetRate()
    return self.regen
end

function RunicPowerMeter:SetPeriod(period)
    if period == nil then return error("RunicPowerMeter:SetPeriod called with no period!") end
    self.regen_period = period
end

function RunicPowerMeter:GetPeriod()
    return self.regen_period
end

function RunicPowerMeter:GetRegenTask()
    return self.regen_task
end

function RunicPowerMeter:OnRemoveEntity()
    self:StopRegen()
end

return RunicPowerMeter