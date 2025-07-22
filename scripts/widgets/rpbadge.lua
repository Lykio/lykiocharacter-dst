local Badge = require "widgets/badge"
local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"

Assets = {
    Asset("ANIM", "anim/status_health.zip"),
   
    Asset("ANIM", "anim/runicpowericon.zip"),
    Asset("ATLAS", "images/status_icons/runicpowericon.xml"),
    Asset("IMAGE", "images/status_icons/runicpowericon.tex"),
}

local function DebugPrint(...)
    print("[RunicPowerBadge Debug]", ...)
end

---@class RunicPowerBadge extends Badge
local RunicPowerBadge = Class(Badge, function(self, owner, bank, background_build)
    Badge._ctor(self, "rpmeter", bank, background_build)

    self.anim:GetAnimState():SetBank("status_health")
    self.anim:GetAnimState():SetBuild("status_health")
    self.anim:GetAnimState():PlayAnimation("idle")

    self.sanityarrow = self.underNumber:AddChild(UIAnim())
    self.sanityarrow:GetAnimState():SetBank("sanity_arrow")
    self.sanityarrow:GetAnimState():SetBuild("sanity_arrow")
    self.sanityarrow:SetClickable(false)
    self.arrowdir = nil

    self.rppulse = self:AddChild(UIAnim())
    self.rppulse:GetAnimState():SetBank("pulse")
    self.rppulse:GetAnimState():SetBuild("hunger_health_pulse")
    self.rppulse:MoveToBack()

    self.icon = self:AddChild(UIAnim())
    self.icon:GetAnimState():SetBank("runicpowericon")
    self.icon:GetAnimState():SetBuild("runicpowericon")
    self.icon:GetAnimState():PlayAnimation("icon")

    self:StartUpdating()
end)

function RunicPowerBadge:RPPulseGreen()
    self.rppulse:GetAnimState():SetMultColour(0, 1, 0 , 1) -- Green
    self.rppulse:GetAnimState():PlayAnimation("pulse")
end

function RunicPowerBadge:RPPulseRed()
    self.rppulse:GetAnimState():SetMultColour(1, 0, 0 , 1) -- Red
    self.rppulse:GetAnimState():PlayAnimation("pulse")
end

function RunicPowerBadge:SetPercent(val, max, current, maxrp)
    val = val or self.percent or TUNING.LYKIO.RUNICPOWER.STATS.MAX.DEFAULT / 2
    max = max or self.max or TUNING.LYKIO.RUNICPOWER.STATS.MAX.DEFAULT
    current = current or TUNING.LYKIO.RUNICPOWER.STATS.CURRENT.DEFAULT / 2
    maxrp = maxrp or TUNING.LYKIO.RUNICPOWER.STATS.MAX.DEFAULT

    Badge.SetPercent(self, val, max)
    self.num:SetString(math.ceil(current))

    if self.owner:HasTag("runicpower_increased") then
        self:RPPulseGreen()
    end

    if self.owner:HasTag("runicpower_decreased") then
        self:RPPulseRed()
    end

    self.percent = val
end

function RunicPowerBadge:OnUpdate(dt)
    if TheNet.IsServerPaused() then return end

    if self.owner.replica.rpmeter ~= nil then
        self:SetPercent(
            self.owner.replica.rpmeter:GetPercentRPC(),
            self.owner.replica.rpmeter:GetMaxRPC(),
            self.owner.replica.rpmeter:GetCurrentRPC(),
            self.owner.replica.rpmeter:GetMaxRPC()
        )
    end
    
    local anim = "neutral"

    
	if self.owner:HasTag("runicpower_increased") then
		anim = "arrow_loop_increase"
	elseif self.owner:HasTag("runicpower_increased_most") then
		anim = "arrow_loop_increase_most"
	elseif self.owner:HasTag("runicpower_decreased") then
		anim = "arrow_loop_decrease"
	else
		anim = "neutral"
	end

	if self.arrowdir ~= anim then
		self.arrowdir = anim
		self.sanityarrow:GetAnimState():PlayAnimation(anim, true)
	end
end