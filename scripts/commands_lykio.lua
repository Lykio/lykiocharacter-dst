-- Commands only for dev mode for now probably
if not GLOBAL.DEV_MODE then return end

function c_setrpmcur(amt)
    if amt == nil then print("Put a number idiot") return end
    local player = ThePlayer
    if player ~= nil then
        local rpm = player.components.runicpowermeter
        if rpm ~= nil then
            rpm:SetCurrent(amt)
            print("Runic power set to:", amt)
        else
            print("Player rpm not found!")
        end
    end
end

function c_setrpmmax(amt)
    if amt == nil then print("Put a number idiot") return end
    local player = ThePlayer
    if player ~= nil then
        local rpm = player.components.runicpowermeter
        if rpm ~= nil then
            rpm:SetMax(amt)
            print("Runic power set to:", amt)
        else
            print("Player rpm not found!")
        end
    end
end

function c_rpmdodelta(amt, overtime, cause)
    if amt == nil then print("Put a number idiot") return end
    if overtime == nil then overtime = false end
    if cause == nil then cause = "console" end
    local player = ThePlayer
    if player ~= nil then
        local rpm = player.components.runicpowermeter
        if rpm ~= nil then
            rpm:DoDelta(amt, overtime, cause)
            print("Did", amt, " Runic power ")
        else
            print("Player rpm not found!")
        end
    end
end
