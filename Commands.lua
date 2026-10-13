local _, ns = ...

-- /pcb and its subcommands. Commands: one function per subcommand, named after it (lower case)
-- and called with what was typed after it; the slash handler only splits the message and looks
-- the subcommand up. Anything it does not know shows the status line with the list of commands.
-- Settings are read from ns.db, which exists once the addon has loaded (before anyone can type).

local L, Print = ns.L, ns.Print

local COMMAND_LIST = table.concat({
    "/pcb macro",
    "/pcb revive",
    "/pcb call",
    "/pcb died on|off",
    "/pcb nopet on|off",
    "/pcb low <0-90>",
    "/pcb test [dead|nopet|low]",
    "/pcb duration <seconds>",
    "/pcb scale <0.3-3>",
    "/pcb sound family|warning|off",
    "/pcb reset",
    "/pcb config",
    "/pcb debug",
}, ", ") .. "."

---The first word of what was typed after the subcommand, lower case.
---@param rest string
---@return string
local function firstWord(rest)
    local lowered = rest:lower()
    return lowered:match("^%S*") or ""
end

---"on" -> true, "off" -> false, anything else nil.
---@param rest string
---@return boolean?
local function onOff(rest)
    local word = firstWord(rest)
    if word == "on" then return true end
    if word == "off" then return false end
    return nil
end

---@param on boolean
---@return string
local function onOffName(on)
    return on and L.STATUS_ON or L.STATUS_OFF
end

-- How each sound mode is named in the status line.
---@type table<PetCareButtonSoundMode, string>
local SOUND_NAMES = { family = L.SOUND_NAME_FAMILY, warning = L.SOUND_NAME_WARNING, off = L.STATUS_OFF }

---The current settings and the list of commands.
local function status()
    if not ns.isHunter then Print(L.NOT_HUNTER) end
    ---@type PetCareButtonSettings
    local db = ns.db
    Print(
        ns.Format(
            "STATUS",
            ns.PetDead() and L.MODE_REVIVE or L.MODE_CALL,
            onOffName(db.died),
            onOffName(db.nopet),
            db.low > 0 and ns.Format("LOW_PERCENT", db.low) or L.STATUS_OFF,
            db.duration,
            db.scale,
            SOUND_NAMES[db.sound],
            onOffName(db.debug),
            COMMAND_LIST
        )
    )
end

-- What /pcb sound takes: the mode names, and "on" for the default.
---@type table<string, PetCareButtonSoundMode>
local SOUND_WORDS = { family = "family", on = "family", warning = "warning", off = "off" }

-- What /pcb sound answers for each mode.
---@type table<PetCareButtonSoundMode, string>
local SOUND_SET = { family = L.SOUND_FAMILY, warning = L.SOUND_WARNING, off = L.SOUND_OFF }

-- What /pcb test takes.
---@type table<string, PetCareButtonAlertKey>
local TEST_KEYS = { dead = "dead", nopet = "nopet", low = "low" }

-- The on/off settings with a command of their own, and what each answers.
---@type table<string, [string, string]>
local SWITCHES = {
    died = { "DIED_ON", "DIED_OFF" },
    nopet = { "NOPET_ON", "NOPET_OFF" },
}

---@type table<string, fun(rest: string)>
local Commands = {}

---Sets one of SWITCHES from "on" or "off".
---@param key "died"|"nopet"
---@param rest string
local function Switch(key, rest)
    local on = onOff(rest)
    if on == nil then
        status()
        return
    end
    local db = ns.db
    db[key] = on
    local answers = SWITCHES[key]
    Print(L[on and answers[1] or answers[2]])
end

---/pcb died on|off
function Commands.died(rest)
    Switch("died", rest)
end

---/pcb nopet on|off
function Commands.nopet(rest)
    Switch("nopet", rest)
end

---/pcb low <0-90>: the health percentage that toasts Mend Pet; 0 switches it off.
function Commands.low(rest)
    local percent = tonumber(firstWord(rest))
    if not percent then return status() end
    local db = ns.db
    db.low = math.min(90, math.max(0, math.floor(percent)))
    Print(db.low > 0 and ns.Format("LOW_SET", db.low) or L.LOW_OFF)
    ns.CheckHealth()
end

---Sets what the button does without a pet, outside combat.
---@param dead boolean
---@param answer string
local function SetMode(dead, answer)
    if not ns.isHunter then
        Print(L.NOT_HUNTER)
    elseif ns.SetPetDead(dead) then
        Print(answer)
    else
        Print(L.IN_COMBAT)
    end
end

---/pcb revive: count the pet as dead, so the button casts Revive Pet without a pet.
function Commands.revive()
    SetMode(true, L.MODE_SET_REVIVE)
end

---/pcb call: count the pet as alive, so the button casts Call Pet without a pet.
function Commands.call()
    SetMode(false, L.MODE_SET_CALL)
end

---/pcb macro: makes the PetCare macro, outside combat.
function Commands.macro()
    Print(ns.MacroAnswer(ns.CreatePetMacro()))
end

---/pcb test [dead|nopet|low]: a toast only, whatever the pet is doing.
function Commands.test(rest)
    local key = TEST_KEYS[firstWord(rest)] or "dead"
    local info = ns.AlertToast(key, nil, key == "low" and ns.db.low or nil)
    -- Its own key, so a real toast for the same problem is not taken for this one.
    info.key = "test:" .. key
    ns.ShowToast(info)
end

---/pcb sound family|warning|off
function Commands.sound(rest)
    local mode = SOUND_WORDS[firstWord(rest)]
    if not mode then return status() end
    local db = ns.db
    db.sound = mode
    Print(SOUND_SET[mode])
end

---/pcb duration <seconds>: how long the toast stays before it fades, whole seconds from 1.
function Commands.duration(rest)
    local seconds = tonumber(firstWord(rest))
    if not seconds then return status() end
    local db = ns.db
    db.duration = math.max(1, math.floor(seconds))
    Print(ns.Format("DURATION_SET", db.duration))
end

---/pcb scale <0.3-3>
function Commands.scale(rest)
    local scale = tonumber(firstWord(rest))
    if not scale then return status() end
    local db = ns.db
    db.scale = math.min(3, math.max(0.3, scale))
    Print(ns.Format("SCALE_SET", db.scale))
end

function Commands.reset()
    local db = ns.db
    db.pos = nil
    Print(L.POSITION_RESET)
end

function Commands.config()
    ns.OpenOptions()
end
Commands.options = Commands.config

function Commands.debug()
    local db = ns.db
    db.debug = not db.debug
    Print(db.debug and L.DEBUG_ON or L.DEBUG_OFF)
end

SLASH_PETCAREBUTTON1 = "/pcb"
SLASH_PETCAREBUTTON2 = "/petcarebutton"
---@param message string? what was typed after /pcb
SlashCmdList.PETCAREBUTTON = function(message)
    local typed = message or ""
    local name, rest = typed:match("^%s*(%S*)%s*(.-)%s*$")
    local key = name or ""
    local command = Commands[key:lower()]
    if command then
        command(rest or "")
    else
        status()
    end
end
