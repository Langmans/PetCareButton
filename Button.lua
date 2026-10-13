local _, ns = ...

-- The secure button behind the key binding. An addon cannot cast a
-- spell itself, and in combat it cannot change what a button does either; only secure code can.
-- So the choice between Mend Pet, Revive Pet and Call Pet is made by macro conditions plus one
-- remembered fact, all inside the secure environment:
--
--   - A state driver watches `[@pet,dead] dead; [@pet,exists] alive; none`. Its snippet runs in
--     combat too. On "dead" it sets the header's `petdead` attribute, on "alive" it clears it,
--     and on "none" (no pet unit at all) it leaves it as it was. That is what the plain macro
--     cannot do: once a dead pet's body is gone, `[@pet,dead]` is false and `[nopet]` would pick
--     Call Pet, which fails with "Your pet is dead".
--   - The `apply` snippet gives the button one of two macro texts, by `petdead`. Both keep a way
--     out: Shift forces Revive Pet and Ctrl forces Call Pet, for when the remembered fact is
--     wrong in combat.
--
-- Outside combat the addon may set `petdead` itself (ns.SetPetDead): from the saved value at
-- login, when a cast failed and showed whether the pet is dead, and from /pcb revive and call.
-- `petdead` is mirrored into PetCareButtonCharDB, so a relog keeps it.
--
-- The button acts on the key's release (useOnKeyDown false); a key binding sends both. The
-- PetCare macro (Macro.lua) does not click this button: it carries the same /cast line itself.
-- The macro text is also what the macro writes, so the binding and the macro cast alike.

local L = ns.L

ns.MEND_PET, ns.REVIVE_PET, ns.CALL_PET = 136, 982, 883

-- The English names, for a client that cannot name the spell itself.
---@type table<number, string>
local FALLBACK_NAMES = { [136] = "Mend Pet", [982] = "Revive Pet", [883] = "Call Pet" }

---A spell's name as the client calls it, for macros and toasts.
---@param id number
---@return string
function ns.SpellName(id)
    return ns.SpellInfo(id) or FALLBACK_NAMES[id]
end

---The macro the button runs. Without a remembered death: Revive Pet on a dead pet that is still
---there, Call Pet without a pet, Mend Pet otherwise. With one: Revive Pet whenever there is no
---living pet.
---@param petDead boolean
---@return string
function ns.MacroText(petDead)
    local mend, revive, call = ns.SpellName(ns.MEND_PET), ns.SpellName(ns.REVIVE_PET), ns.SpellName(ns.CALL_PET)
    if petDead then return ("/cast [mod:ctrl] %s; [mod:shift][@pet,dead][nopet] %s; %s"):format(call, revive, mend) end
    return ("/cast [mod:shift][@pet,dead] %s; [mod:ctrl][nopet] %s; %s"):format(revive, call, mend)
end

-- What the state driver reports.
ns.PET_STATES = "[@pet,dead] dead; [@pet,exists] alive; none"

local button = CreateFrame("Button", "PetCareButton", UIParent, "SecureActionButtonTemplate")
ns.button = button

local header = CreateFrame("Frame", "PetCareButtonHeader", UIParent, "SecureHandlerStateTemplate")
ns.header = header

---Mirrors `petdead` into the per-character save, whoever set it (a snippet in combat as well).
---@param _ Frame the header
---@param name string
---@param value GameValue
local function onAttributeChanged(_, name, value)
    if name == "petdead" then ns.char.petDead = value == true end
end
header:HookScript("OnAttributeChanged", onAttributeChanged)

---Whether the button counts the pet as dead.
---@return boolean
function ns.PetDead()
    return header:GetAttribute("petdead") == true
end

---Gives the button and header their attributes, snippets and macro texts, and starts the state
---driver. Outside combat only, since all of it is blocked in combat: called on ADDON_LOADED, or
---once combat ends after a /reload in combat.
function ns.SetupButton()
    button:RegisterForClicks("AnyUp", "AnyDown")
    SecureHandlerSetFrameRef(header, "button", button)
    -- The snippets run in the restricted environment: `self` is the header, `newstate` the state.
    header:SetAttribute(
        "apply",
        [[
        local text = self:GetAttribute(self:GetAttribute("petdead") and "textDead" or "textAlive")
        self:GetFrameRef("button"):SetAttribute("macrotext", text)
    ]]
    )
    header:SetAttribute(
        "_onstate-pet",
        [[
        if newstate == "dead" then
            self:SetAttribute("petdead", true)
        elseif newstate == "alive" then
            self:SetAttribute("petdead", false)
        end
        self:RunAttribute("apply")
    ]]
    )
    button:SetAttribute("type", "macro")
    button:SetAttribute("useOnKeyDown", false)
    header:SetAttribute("textAlive", ns.MacroText(false))
    header:SetAttribute("textDead", ns.MacroText(true))
    header:SetAttribute("petdead", ns.char.petDead)
    SecureHandlerExecute(header, [[ self:RunAttribute("apply") ]])
    RegisterStateDriver(header, "pet", ns.PET_STATES)
    ns.Debug("button ready, pet counted as " .. (ns.PetDead() and "dead" or "not dead"))
end

---Tells the button whether the pet is dead. Outside combat only; returns false in combat, where
---the attribute cannot be set from here.
---@param dead boolean
---@return boolean
function ns.SetPetDead(dead)
    if InCombatLockdown() then return false end
    header:SetAttribute("petdead", dead)
    SecureHandlerExecute(header, [[ self:RunAttribute("apply") ]])
    ns.Debug("pet counted as " .. (dead and "dead" or "not dead"))
    return true
end

-- The key binding's names in Esc > Options > Keybindings (Bindings.xml).
BINDING_HEADER_PETCAREBUTTON = L.OPTIONS_TITLE
_G["BINDING_NAME_CLICK PetCareButton:LeftButton"] = L.BINDING_BUTTON
