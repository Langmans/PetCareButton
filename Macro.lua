local _, ns = ...

-- The PetCare macro: `/click PetCareButton` with a #showtooltip line, so an action bar shows the
-- spell the button will cast. /pcb macro makes it per character, since whether the pet counts as
-- dead is per character too; only when the character macros are full does it go among the
-- account-wide ones.
--
-- The tooltip line follows the button. Macro conditions alone cannot see a dead pet whose body is
-- gone, so the line is rewritten whenever the button's `petdead` changes. Macros cannot be edited
-- in combat: a change there is written once combat ends. UPDATE_MACROS (the macros loaded at
-- login, or edited by hand) also brings the line up to date; a macro already right is left alone,
-- so the event our own edit fires changes nothing.

ns.MACRO_NAME = "PetCare"
-- INV_Misc_QuestionMark: the icon a macro gets when #showtooltip picks the spell's own.
local MACRO_ICON = 134400

local MACRO_CONSTS = Constants and Constants.MacroConsts
local MAX_ACCOUNT_MACROS = MACRO_CONSTS and MACRO_CONSTS.MAX_ACCOUNT_MACROS or 120
local MAX_CHARACTER_MACROS = MACRO_CONSTS and MACRO_CONSTS.MAX_CHARACTER_MACROS or 18

---The macro's text for how the button counts the pet: the tooltip shows what pressing it casts.
---@param petDead boolean
---@return string
function ns.MacroBody(petDead)
    local mend, revive, call = ns.SpellName(ns.MEND_PET), ns.SpellName(ns.REVIVE_PET), ns.SpellName(ns.CALL_PET)
    local tooltip
    if petDead then
        tooltip = ("[@pet,exists,nodead] %s; %s"):format(mend, revive)
    else
        tooltip = ("[@pet,dead] %s; [nopet] %s; %s"):format(revive, call, mend)
    end
    return "#showtooltip " .. tooltip .. "\n/click PetCareButton"
end

---Makes the macro: per character, or account-wide when the character macros are full.
---@return "character"|"account"|"exists"|"full"|"combat"
function ns.CreatePetMacro()
    if InCombatLockdown() then return "combat" end
    if GetMacroIndexByName(ns.MACRO_NAME) > 0 then return "exists" end
    local accountMacros, characterMacros = GetNumMacros()
    local perCharacter = characterMacros < MAX_CHARACTER_MACROS
    if not perCharacter and accountMacros >= MAX_ACCOUNT_MACROS then return "full" end
    CreateMacro(ns.MACRO_NAME, MACRO_ICON, ns.MacroBody(ns.PetDead()), perCharacter)
    return perCharacter and "character" or "account"
end

local frame = CreateFrame("Frame")

---Rewrites the macro's tooltip line when it no longer matches the button. In combat it waits for
---the end of combat. Only on hunters, so another class never rewrites a shared account macro.
function ns.UpdateMacro()
    if not ns.isHunter then return end
    if InCombatLockdown() then
        frame:RegisterEvent("PLAYER_REGEN_ENABLED")
        return
    end
    local index = GetMacroIndexByName(ns.MACRO_NAME)
    if index == 0 then return end
    local body = ns.MacroBody(ns.PetDead())
    local _, _, current = GetMacroInfo(index)
    if current == body then return end
    EditMacro(index, nil, nil, body)
    ns.Debug("macro updated")
end

---@param _ Frame the header
---@param name string
local function onHeaderAttribute(_, name)
    if name == "petdead" then ns.UpdateMacro() end
end
ns.header:HookScript("OnAttributeChanged", onHeaderAttribute)

-- Events: one method per event on this frame, named after the event.
function frame:PLAYER_REGEN_ENABLED()
    self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    ns.UpdateMacro()
end

frame.UPDATE_MACROS = ns.UpdateMacro

---@param self Frame
---@param event string
local function onEvent(self, event)
    self[event](self)
end
frame:SetScript("OnEvent", onEvent)
frame:RegisterEvent("UPDATE_MACROS")
