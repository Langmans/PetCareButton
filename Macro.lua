local _, ns = ...

-- The PetCare macro: `#showtooltip` and the button's own `/cast` line (ns.MacroText), written
-- straight into the macro the way Buffet writes its food macros. The macro casts by itself and
-- does not go through the secure button: a `/click` from a macro reaches the button as a press or
-- a release depending on how the macro was triggered, and the button acts on only one of the two.
-- It is made per character, since whether the pet counts as dead is per character too; only when
-- the character macros are full does it go among the account-wide ones.
--
-- Made once by itself: the first time a hunter's macros are loaded (UPDATE_MACROS) outside combat,
-- unless PetCareButtonCharDB says it was made (or offered) before. A macro deleted afterwards is
-- not made again; /pcb macro makes it by hand.
--
-- The cast line follows the button. Macro conditions alone cannot see a dead pet whose body is
-- gone, so the line is rewritten whenever the button's `petdead` changes. Only a macro whose first
-- line starts with #showtooltip is touched, and in it only the addon's own lines (its cast line,
-- or a `/click PetCareButton` from an earlier version): lines the player added stay, and a macro
-- whose first line is something else is left alone entirely. Macros cannot be edited in combat: a
-- change there is written once combat ends, so a pet that dies in combat and whose body vanishes
-- before combat ends gets Call Pet from the macro until then (Shift forces Revive Pet; the key
-- binding goes through the button and knows). UPDATE_MACROS (the macros loaded at login, or
-- edited by hand) also brings the macro up to date; a macro already right is left alone, so the
-- event our own edit fires changes nothing.
--
-- Only hunters listen (ns.StartMacro, from ADDON_LOADED), so another class never touches a shared
-- account macro.

ns.MACRO_NAME = "PetCare"
-- INV_Misc_QuestionMark: the icon a macro gets when #showtooltip picks the spell's own.
local MACRO_ICON = 134400

local MACRO_CONSTS = Constants and Constants.MacroConsts
local MAX_ACCOUNT_MACROS = MACRO_CONSTS and MACRO_CONSTS.MAX_ACCOUNT_MACROS or 120
local MAX_CHARACTER_MACROS = MACRO_CONSTS and MACRO_CONSTS.MAX_CHARACTER_MACROS or 18

-- The chat line for each outcome of ns.CreatePetMacro.
---@type table<PetCareButtonMacroResult, string>
local ANSWERS = {
    character = "MACRO_CREATED",
    account = "MACRO_CREATED_ACCOUNT",
    exists = "MACRO_EXISTS",
    full = "MACRO_FULL",
    combat = "IN_COMBAT",
}

-- A bare #showtooltip shows the spell the /cast line below it picks, so the icon always matches
-- what pressing the macro casts.
local TOOLTIP_LINE = "#showtooltip"

---A new macro's text.
---@param petDead boolean
---@return string
function ns.MacroBody(petDead)
    return TOOLTIP_LINE .. "\n" .. ns.MacroText(petDead)
end

---Whether a macro line is one the addon wrote: either cast line, or the `/click PetCareButton` of
---an earlier version.
---@param line string
---@return boolean
local function IsOwnLine(line)
    return line == ns.MacroText(false)
        or line == ns.MacroText(true)
        or line:lower():find("^/click petcarebutton") ~= nil
end

---The macro text with the addon's lines put in step with the button, or nil when the first line is
---no #showtooltip (the player took it out or wrote something else; that is left alone). Every
---other line stays as the player has it.
---@param body string
---@param petDead boolean
---@return string?
function ns.UpdatedBody(body, petDead)
    ---@type string[]
    local lines = {}
    for line in (body .. "\n"):gmatch("(.-)\n") do
        lines[#lines + 1] = line
    end
    if not lines[1]:lower():find("^#showtooltip") then return nil end
    lines[1] = TOOLTIP_LINE
    for i = 2, #lines do
        if IsOwnLine(lines[i]) then lines[i] = ns.MacroText(petDead) end
    end
    return table.concat(lines, "\n")
end

---Makes the macro: per character, or account-wide when the character macros are full. A macro
---made counts as made for this character, so it is never made by itself again.
---@return PetCareButtonMacroResult
function ns.CreatePetMacro()
    if InCombatLockdown() then return "combat" end
    if GetMacroIndexByName(ns.MACRO_NAME) > 0 then return "exists" end
    local accountMacros, characterMacros = GetNumMacros()
    local perCharacter = characterMacros < MAX_CHARACTER_MACROS
    if not perCharacter and accountMacros >= MAX_ACCOUNT_MACROS then return "full" end
    CreateMacro(ns.MACRO_NAME, MACRO_ICON, ns.MacroBody(ns.PetDead()), perCharacter)
    ns.char.macroMade = true
    return perCharacter and "character" or "account"
end

---The chat line for an outcome of ns.CreatePetMacro.
---@param result PetCareButtonMacroResult
---@return string
function ns.MacroAnswer(result)
    return ns.Format(ANSWERS[result], ns.MACRO_NAME)
end

local frame = CreateFrame("Frame")

---Rewrites the macro's cast line when it no longer matches the button. In combat it waits
---for the end of combat.
function ns.UpdateMacro()
    if not ns.isHunter then return end
    if InCombatLockdown() then
        frame:RegisterEvent("PLAYER_REGEN_ENABLED")
        return
    end
    local index = GetMacroIndexByName(ns.MACRO_NAME)
    if index == 0 then return end
    local _, _, current = GetMacroInfo(index)
    local body = ns.UpdatedBody(current or "", ns.PetDead())
    if not body or body == current then return end
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

-- The macros are loaded or changed: make the macro the one time, then bring it up to date.
function frame:UPDATE_MACROS()
    if not ns.char.macroMade and not InCombatLockdown() then
        local result = ns.CreatePetMacro()
        -- An existing macro, or full slots, also count: it is offered once and no more.
        ns.char.macroMade = true
        if result ~= "exists" then ns.Print(ns.MacroAnswer(result)) end
    end
    ns.UpdateMacro()
end

function frame:PLAYER_REGEN_ENABLED()
    self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    self:UPDATE_MACROS()
end

---@param self Frame
---@param event string
local function onEvent(self, event)
    self[event](self)
end
frame:SetScript("OnEvent", onEvent)

---Starts listening to the macros; called on ADDON_LOADED for a hunter.
function ns.StartMacro()
    frame:RegisterEvent("UPDATE_MACROS")
end
