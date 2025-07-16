local D

local ORDERS = {{"runicdominion", {-214, 176}}}

local function BuildSkillsData(SkillTreeFns)
    local skills = {
        -- L1
        lykio_winters_bite = {
            title = "Winters Bite",
            desc = "Melee attacks slow targets by 20% for 1 second.",
            icon = "winters_bite.tex",
            pos = {-214, 176},
            group = "runicdominion",
            tags = {"ice", "combat", "melee"},
            onactivate = function(inst, fromload)
                inst.AddTag("Lykio_WintersBite")

                -- Add slow effect to combat
                local old_OnHitOther = inst.components.combat.onhitotherfn
                inst.components.combat.onhitotherfn = function(inst, other, damage)
                    if old_OnHitOther then
                        old_OnHitOther(inst, other, damage)
                    end
                    
                    -- Apply the slow effect
                    if other and other.components.locomotor then
                        other.components.locomotor:SetExternalSpeedMultiplier(inst, "Lykio_WintersBite", 0.8) -- 20% slower
                        other:DoTaskInTime(1, function()
                            if other.components.locomotor then
                                other.components.locomotor:RemoveExternalSpeedMultiplier(inst, "Lykio_WintersBite")
                            end
                        end)
                    end
                end
            end
        },

        -- L2
        lykio_winters_heart = {
            title = "Winters Heart",
            desc = "Gains +15 health and Death Addiction no longer affects sanity during winter.",
            icon = "winters_heart.tex",
            pos = {-214, 176-52},
            group = "runicdominion",
            tags = {"ice", "survival"},
            onactivate = function(inst, fromload)
                inst.components.health:DoDelta(inst.components.health.maxhealth + 15) -- Add 15 health
                inst:AddTag("Lykio_WintersHeart")

                -- Remove sanity penalty during winter
                local old_OnSeasonChange = inst.OnSeasonChange
                inst.OnSeasonChange = function(inst, season)
                    if old_OnSeasonChange then
                        old_OnSeasonChange(inst, season)
                    end

                    if season == "winter" then
                        inst:RemoveTag("Lykio_DeathAddictionSanityPenalty")
                    else
                        inst:AddTag("Lykio_DeathAddictionSanityPenalty")
                    end
                end
            end

        }
    }
    
end