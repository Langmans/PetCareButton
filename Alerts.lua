local ADDON_NAME, ns = ...

-- The toasts, and what the addon learns from failed casts.
--
--   - dead:  the pet died (the button's state driver reports "dead"), or a cast showed that it is
--            dead while no pet was out. Also again when combat starts with the pet still dead.
--   - nopet: combat starts without a pet, and the pet is not known to be dead.
--   - low:   the pet's health drops to the /pcb low percentage. It toasts again only after the
--            health went back above it. Forever may hide health in combat (a secret value);
--            then nothing is decided until it can be read again.
-- A toast goes away by itself once its problem is solved: a living pet takes away dead and nopet,
-- health above the line takes away low.
--
-- Learning from casts, for the case the state driver cannot see (the body was gone before the
-- button was pressed, or the pet died while this character was logged out):
--   - Call Pet failing while no pet is out, or the error "Your pet is dead", means the pet is
--     dead. Outside combat the button switches to Revive Pet at once; in combat it cannot, so the
--     toast says to hold Shift, and the switch follows when combat ends.
--   - Revive Pet failing straight away, without its cast having started, means there is no dead
--     pet to revive: the button goes back to Call Pet (outside combat).

local L = ns.L

-- Per alert: the spell it points to, and the locale keys of its title and reason.
---@type table<PetCareButtonAlertKey, {spell: number, title: string, reason: string}>
local ALERTS = {
    dead = { spell = ns.REVIVE_PET, title = "TOAST_DEAD", reason = "REASON_DEAD" },
    nopet = { spell = ns.CALL_PET, title = "TOAST_NOPET", reason = "REASON_NOPET" },
    low = { spell = ns.MEND_PET, title = "TOAST_LOW", reason = "REASON_LOW" },
}

-- The names the client's "Your pet is dead" error may have among the global strings. Unknown
-- names are nil and skipped.
local PET_DEAD_ERRORS = { "ERR_PET_SPELL_DEAD", "PETTAME_DEAD" }

---The line that says how to press the button: its key binding, or the macro.
---@return string
function ns.PressHint()
    local key = GetBindingKey("CLICK PetCareButton:LeftButton")
    if key then return ns.Format("HINT_KEY", GetBindingText(key)) end
    return L.HINT_MACRO
end

---The toast for an alert.
---@param key PetCareButtonAlertKey
---@param reason string? instead of the alert's own reason
---@param percent number? the pet's health, for low
---@return PetCareButtonToastInfo
function ns.AlertToast(key, reason, percent)
    local alert = ALERTS[key]
    local _, icon = ns.SpellInfo(alert.spell)
    return {
        key = key,
        title = percent and ns.Format(alert.title, percent) or L[alert.title],
        name = ns.SpellName(alert.spell),
        icon = icon,
        reason = reason or L[alert.reason],
        hint = ns.PressHint(),
    }
end

-- Whether the low toast was given and the health has not been above the line since.
local lowShown = false

---Toasts or takes away the low alert, from the pet's health.
function ns.CheckHealth()
    local db = ns.db
    if db.low == 0 or not UnitExists("pet") or UnitIsDead("pet") then
        if lowShown then ns.DropToast("low") end
        lowShown = false
        return
    end
    local health, max = UnitHealth("pet"), UnitHealthMax("pet")
    if not canaccessvalue(health) or not canaccessvalue(max) or max <= 0 then return end
    local percent = math.floor(health / max * 100)
    if percent > db.low then
        if lowShown then ns.DropToast("low") end
        lowShown = false
    elseif not lowShown then
        lowShown = true
        ns.Debug("low: " .. percent .. "%")
        ns.ShowToast(ns.AlertToast("low", nil, percent))
    end
end

-- Set when a cast showed in combat that the pet is dead; the button switches once combat ends,
-- unless a living pet showed up in the meantime.
local deadAfterCombat = false

---The state driver reported a new state: "dead", "alive" or "none".
---@param state string
local function OnPetState(state)
    ns.Debug("pet: " .. state)
    if state == "dead" then
        ns.CheckHealth()
        if ns.db.died then ns.ShowToast(ns.AlertToast("dead")) end
    elseif state == "alive" then
        deadAfterCombat = false
        ns.DropToast("dead")
        ns.DropToast("nopet")
        ns.CheckHealth()
    end
end

---@param _ Frame the header
---@param name string
---@param value GameValue
local function onHeaderAttribute(_, name, value)
    if name == "state-pet" and type(value) == "string" then OnPetState(value) end
end
ns.header:HookScript("OnAttributeChanged", onHeaderAttribute)

---A cast showed that the pet is dead.
---@param why string for the debug trace
local function LearnedDead(why)
    if UnitExists("pet") or ns.PetDead() then return end
    ns.Debug("pet is dead: " .. why)
    local switched = ns.SetPetDead(true)
    deadAfterCombat = not switched
    if ns.db.died then ns.ShowToast(ns.AlertToast("dead", switched and L.REASON_LEARNED or L.REASON_LEARNED_COMBAT)) end
end

---A cast showed that there is no dead pet to revive.
local function LearnedNotDead()
    if UnitExists("pet") or not ns.PetDead() then return end
    if ns.SetPetDead(false) then ns.Print(L.REVIVE_FAILED) end
end

---Whether an error message is the client's "Your pet is dead".
---@param message string
---@return boolean
local function IsPetDeadError(message)
    for _, name in ipairs(PET_DEAD_ERRORS) do
        if _G[name] == message then return true end
    end
    return false
end

-- The Revive Pet casts that started, by cast GUID: a failure of one of those is an interrupted
-- cast, not a missing pet.
---@type table<string, true>
local reviveCasts = {}

-- Events: one method per event on this frame, named after the event and called with the event's
-- own arguments. Only ADDON_LOADED is registered up front; it registers the rest once the saved
-- settings are there. PLAYER_LOGOUT strips the default values from them before the client saves
-- them.
--
-- Only a hunter has these spells. On any other class the addon stays loaded (the addon list is
-- account-wide, so disabling it here would disable it for the hunters too) but sets up nothing
-- past PLAYER_LOGOUT, while /pcb and the options panel keep working.
local frame = CreateFrame("Frame")

-- Set when the addon loaded in combat (a /reload mid-fight): the button is set up after it.
local setupAfterCombat = false

---@param name string the addon that finished loading
function frame:ADDON_LOADED(name)
    if name ~= ADDON_NAME then return end
    self:UnregisterEvent("ADDON_LOADED")
    ns.LoadSettings()
    self:RegisterEvent("PLAYER_LOGOUT")
    local _, class = UnitClass("player")
    ---@type boolean
    ns.isHunter = class == "HUNTER"
    if not ns.isHunter then return end
    for _, event in ipairs({ "PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED", "UI_ERROR_MESSAGE" }) do
        self:RegisterEvent(event)
    end
    self:RegisterUnitEvent("UNIT_SPELLCAST_START", "player")
    self:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", "player")
    self:RegisterUnitEvent("UNIT_HEALTH", "pet")
    self:RegisterUnitEvent("UNIT_MAXHEALTH", "pet")
    ns.StartMacro()
    if InCombatLockdown() then
        setupAfterCombat = true
    else
        ns.SetupButton()
    end
end

function frame:PLAYER_LOGOUT()
    ns.StripDefaults()
end

-- Combat starts: the moment a missing pet costs something.
function frame:PLAYER_REGEN_DISABLED()
    if UnitExists("pet") then return end
    local db = ns.db
    if ns.PetDead() then
        if db.died then ns.ShowToast(ns.AlertToast("dead")) end
    elseif db.nopet then
        ns.ShowToast(ns.AlertToast("nopet"))
    end
end

-- Combat ends: what had to wait for it.
function frame:PLAYER_REGEN_ENABLED()
    if setupAfterCombat then
        setupAfterCombat = false
        ns.SetupButton()
    end
    if deadAfterCombat then
        deadAfterCombat = false
        if not UnitExists("pet") then ns.SetPetDead(true) end
    end
end

---@param _ number the error's type
---@param message GameValue
function frame:UI_ERROR_MESSAGE(_, message)
    if type(message) ~= "string" or not ns.Readable(message) then return end
    if IsPetDeadError(message) then
        LearnedDead("error " .. message)
    elseif not UnitExists("pet") then
        -- Without a pet every error is traced, so the name of an unknown "pet is dead" string
        -- can be found from the debug lines.
        ns.Debug("error without a pet: " .. message)
    end
end

---@param _ string the unit, always "player"
---@param castGUID GameValue
---@param spellID GameValue
function frame:UNIT_SPELLCAST_START(_, castGUID, spellID)
    if spellID == ns.REVIVE_PET and type(castGUID) == "string" and ns.Readable(castGUID) then
        reviveCasts[castGUID] = true
    end
end

---@param _ string the unit, always "player"
---@param castGUID GameValue
---@param spellID GameValue
function frame:UNIT_SPELLCAST_FAILED(_, castGUID, spellID)
    if not ns.Readable(spellID) or not ns.Readable(castGUID) then return end
    if spellID == ns.CALL_PET then
        -- Mounted, Call Pet fails for that reason instead.
        if not IsMounted() then LearnedDead("Call Pet failed") end
    elseif spellID == ns.REVIVE_PET and type(castGUID) == "string" then
        if reviveCasts[castGUID] then
            reviveCasts[castGUID] = nil
        else
            LearnedNotDead()
        end
    end
end

---@param _ string the unit, always "pet"
function frame:UNIT_HEALTH(_)
    ns.CheckHealth()
end
frame.UNIT_MAXHEALTH = frame.UNIT_HEALTH

---@param self Frame
---@param event string
---@param ... any the event's own arguments
local function onEvent(self, event, ...)
    self[event](self, ...)
end
frame:SetScript("OnEvent", onEvent)
frame:RegisterEvent("ADDON_LOADED")
