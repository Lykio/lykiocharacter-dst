local Widget = require "widgets.widget"
local Image = require "widgets.image"
local Text = require "widgets.text"
local UIAnim = require "widgets.uianim"

local function DebugPrint(...)
    print("[RunicPowerWidget Debug]", ...)
end

local RunicPowerWidget = Class(Widget, function(self, owner)
    DebugPrint("Initializing RunicPowerWidget")
    Widget._ctor(self, "RunicPowerWidget")

    DebugPrint("Setting up widget properties")
    self.owner = owner
    self.max = 100
    self.current = 0

    DebugPrint("Creating main container")
    self.container = self:AddChild(Widget("container"))

    DebugPrint("Creating background frame")
    self.frame = self.container:AddChild(Image("images/hud.xml", "craft_slot.tex"))
    self.frame:SetSize(120, 40)
    self.frame:SetTint(0.3, 0.3, 0.7, 0.8)

    DebugPrint("Creating bar background")
    self.bar_bg = self.container:AddChild(Image("images/hud.xml", "craft_slot.tex"))
    self.bar_bg:SetSize(100, 20)
    self.bar_bg:SetTint(0.1, 0.1, 0.2, 0.8)
    
    DebugPrint("Creating bar fill")
    self.bar_fill = self.container:AddChild(Image("images/hud.xml", "craft_slot.tex"))
    self.bar_fill:SetSize(100, 20)
    self.bar_fill:SetTint(0.4, 0.4, 1.0, 0.9)

    DebugPrint("Creating icon")
    self.icon = self.container:AddChild(Image("images/hud.xml", "sanity.tex"))
    self.icon:SetSize(24, 24)
    self.icon:SetPosition(-45, 0)
    self.icon:SetTint(0.4, 0.4, 1.0, 1.0)

    DebugPrint("Creating text display")
    self.text = self.container:AddChild(Text(NUMBERFONT, 28))
    self.text:SetPosition(0, -2)
    self.text:SetHAlign(ANCHOR_MIDDLE)

    self.pulse_task = nil
    DebugPrint("Performing initial display update")
    self:UpdateDisplay()
end)

function RunicPowerWidget:SetMax(max)
    DebugPrint("Setting max value to:", max)
    self.max = max
    self:UpdateDisplay()
end

function RunicPowerWidget:SetValue(current)
    DebugPrint("Setting current value to:", current)
    self.current = current
    self:UpdateDisplay()
end

function RunicPowerWidget:UpdateDisplay()
    DebugPrint("Updating display - Current:", self.current, "Max:", self.max)
    
    local percent = self.max > 0 and self.current / self.max or 0
    DebugPrint("Calculated percentage:", percent)
    
    local bar_width = 100 * percent
    DebugPrint("Setting bar width to:", bar_width)
    self.bar_fill:SetSize(bar_width, 20)
    
    DebugPrint("Updating text display")
    self.text:SetString(string.format("%d / %d", self.current, self.max))
    
    if percent < 0.25 then
        DebugPrint("Low power state - activating pulse")
        self.bar_fill:SetTint(1.0, 0.2, 0.2, 0.9)
        self:StartPulse()
    elseif percent < 0.5 then
        DebugPrint("Medium power state")
        self.bar_fill:SetTint(1.0, 0.6, 0.2, 0.9)
        self:StopPulse()
    else
        DebugPrint("High power state")
        self.bar_fill:SetTint(0.4, 0.4, 1.0, 0.9)
        self:StopPulse()
    end
    
    if percent >= 1.0 then
        DebugPrint("Full power state")
        self.bar_fill:SetTint(0.8, 0.8, 1.0, 1.0)
    end
end

function RunicPowerWidget:StartPulse()
    DebugPrint("Starting pulse effect")
    if self.pulse_task then 
        DebugPrint("Pulse already active")
        return 
    end
    
    local pulse_alpha = 0.5
    local pulse_dir = 1
    
    self.pulse_task = self.inst:DoPeriodicTask(0.1, function()
        pulse_alpha = pulse_alpha + (pulse_dir * 0.1)
        DebugPrint("Pulse alpha:", pulse_alpha)
        
        if pulse_alpha >= 1.0 then
            DebugPrint("Reversing pulse direction (high)")
            pulse_alpha = 1.0
            pulse_dir = -1
        elseif pulse_alpha <= 0.3 then
            DebugPrint("Reversing pulse direction (low)")
            pulse_alpha = 0.3
            pulse_dir = 1
        end
        
        self.bar_fill:SetTint(1.0, 0.2, 0.2, pulse_alpha)
    end)
end

function RunicPowerWidget:StopPulse()
    if self.pulse_task then
        DebugPrint("Stopping pulse effect")
        self.pulse_task:Cancel()
        self.pulse_task = nil
    end
end

function RunicPowerWidget:OnRemoveFromEntity()
    DebugPrint("Removing widget from entity")
    self:StopPulse()
end

return RunicPowerWidget