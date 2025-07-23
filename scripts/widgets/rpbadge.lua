local Badge = require "widgets/badge"
local UIAnim = require "widgets/uianim"
local Image = require "widgets/image"
local Text = require "widgets/text"

local function DebugPrint(...)
    print("[RunicPowerBadge Debug]", ...)
end

---@class RunicPowerBadge extends Badge
local RunicPowerBadge = Class(Badge, function(self, owner, bank, background_build)
    Badge._ctor(self, "status_meter", owner, { 70 / 255, 130 / 255, 180 / 255, 1 }, "status_meter")

    self:SetScale(1, 1, 1)

    DebugPrint("Creating Runic Power Badge")
    self.anim = self:AddChild(UIAnim())
    self.anim:GetAnimState():SetBank("status_meter")
    self.anim:GetAnimState():SetBuild("status_meter")
    self.anim:GetAnimState():PlayAnimation("anim")
    self.anim:GetAnimState():SetMultColour(0.5, 0.7, 1.0, 1) -- Light blue
    self.anim:SetClickable(false)

    self.frame = self.underNumber:AddChild(UIAnim())
    self.frame:GetAnimState():SetBank("status_meter")
    self.frame:GetAnimState():SetBuild("status_meter")
    self.frame:GetAnimState():PlayAnimation("frame")
    self.frame:SetClickable(false)

    self.sanityarrow = self.underNumber:AddChild(UIAnim())
    self.sanityarrow:GetAnimState():SetBank("sanity_arrow")
    self.sanityarrow:GetAnimState():SetBuild("sanity_arrow")
    self.sanityarrow:SetClickable(false)
    self.arrowdir = nil

    self.rppulse = self:AddChild(UIAnim())
    self.rppulse:GetAnimState():SetBank("pulse")
    self.rppulse:GetAnimState():SetBuild("hunger_health_pulse")
    self.rppulse:MoveToBack()
    self.rppulse:SetClickable(false)

    self.icon = self:AddChild(Image(
        "images/runicpowericon.xml",
        "runicpowericon.tex"
    ))
    self.icon:MoveToFront()
    self.icon:SetClickable(false)

    self.num = self:AddChild(Text(NUMBERFONT, 32))
    self.num:SetPosition(0, 0, 0)
    self.num:SetColour(1, 1, 1, 1)
    self.num:SetHAlign(ANCHOR_MIDDLE)
    self.num:SetVAlign(ANCHOR_MIDDLE)
    self.num:SetString("0")
    self.num:SetClickable(true)
    self.num:MoveToFront()
    self.num:SetScale(0.8, 0.8, 0.8)

    DebugPrint("Runic Power Badge created for", owner.prefab)
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
    if TheNet:IsServerPaused() then return end

    if self.owner.replica.runicpowermeter ~= nil then
        self.num:SetString(math.ceil(self.owner.replica.runicpowermeter:GetCurrent()))

        self:SetPercent(
            self.owner.replica.runicpowermeter:GetPercent(),
            self.owner.replica.runicpowermeter:GetMax(),
            self.owner.replica.runicpowermeter:GetCurrent(),
            self.owner.replica.runicpowermeter:GetMax()
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

return RunicPowerBadge