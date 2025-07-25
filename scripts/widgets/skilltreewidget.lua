local OldBG = GetSkilltreeBG

---@class SkillTreeWidget extends Widget
function SkillTreeWidget(self, owner, useOldBG)
    self.inst = self
    self.owner = owner

    self.oldBG = useOldBG or OldBG
    self.bg = self:GetBG()
end

function SkillTreeWidget:GetBG()
    if not self.oldBG then
        return "images/lykio_skilltreebg.xml", "lykio_skilltreebg.tex"
    else
        return OldBG()
    end
end

return SkillTreeWidget