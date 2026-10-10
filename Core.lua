local _, ns = ...

-- Shared helpers and the saved settings. Loaded after Locale.lua (ns.Print needs ns.L) and before
-- every module that uses them.
--
-- Globals this file writes: PetCareButtonDB and PetCareButtonCharDB, the SavedVariables from the
-- .toc. The WoW Lua LS only knows them when it reads the .toc, so .wowluarc.json lists them under
-- globals.write as well. The types of the settings are in annotations\PetCareButton.lua.

-- Saved account-wide. The saved file keeps only what the player changed: ns.db reads a missing
-- value from here through a metatable, and StripDefaults removes values equal to their default
-- at logout. A default changed in a later version so reaches everyone who never changed it.
-- pos has no default: without it the toast sits in its standard spot.

---@type table<string, true>
ns.SOUND_MODES = { family = true, warning = true, off = true }

---@type PetCareButtonSettings
ns.DEFAULTS = {
    duration = 6, -- /pcb duration <seconds>
    scale = 1, -- /pcb scale <0.3-3>
    sound = "family", -- /pcb sound family|warning|off
    died = true, -- /pcb died on|off
    nopet = true, -- /pcb nopet on|off
    low = 40, -- /pcb low <0-90>, 0 is off
    debug = false, -- /pcb debug
}

---The settings: the defaults until LoadSettings replaces them with the saved table on
---ADDON_LOADED. Nothing writes to them before then (no command or event runs that early).
---@type PetCareButtonSettings
ns.db = ns.DEFAULTS

---Saved per character: whether this character's pet is dead, so the button still knows after a
---relog, when the dead pet is no unit the macro conditions can see, and whether the PetCare macro
---was made once already. Filled on ADDON_LOADED.
---@type PetCareButtonCharSettings
ns.char = { petDead = false, macroMade = false }

---Whether this character is a hunter; set on ADDON_LOADED.
ns.isHunter = false

---@param message string
function ns.Print(message)
    print("|cffabd473" .. ns.L.CHAT_PREFIX .. "|r " .. message)
end

---/pcb debug traces what the addon sees in chat: the pet's state and what was decided.
---@param message string
function ns.Debug(message)
    if ns.db.debug then ns.Print("|cff88ccff[debug]|r " .. message) end
end

---Spell name and icon across client generations: C_Spell on newer clients, GetSpellInfo on
---older ones.
---@param id number
---@return string? name
---@return (number|string)? icon
function ns.SpellInfo(id)
    if C_Spell and C_Spell.GetSpellName then
        return C_Spell.GetSpellName(id), C_Spell.GetSpellTexture and C_Spell.GetSpellTexture(id)
    end
    if GetSpellInfo then
        local name, _, icon = GetSpellInfo(id)
        return name, icon
    end
    return nil, nil
end

---The active pet's CreatureFamily ID (1 wolf, 2 cat, ...), the same on every client language;
---nil without a pet.
---@return number?
function ns.PetFamilyID()
    if not UnitExists("pet") then return nil end
    local _, familyID = UnitCreatureFamily("pet")
    return tonumber(familyID)
end

---A value the addon may read: not secret (Forever hides some values in combat).
---@param v GameValue
---@return boolean
function ns.Readable(v)
    return not (issecretvalue and issecretvalue(v))
end

---A dragged position as saved: { point, relativePoint, x, y }, or nil when anything is off.
---@param saved GameValue
---@return [string, string, number, number]?
local function cleanPos(saved)
    if type(saved) ~= "table" then return nil end
    ---@type GameValue, GameValue, GameValue, GameValue
    local point, relativePoint, x, y = saved[1], saved[2], saved[3], saved[4]
    if type(point) ~= "string" or type(relativePoint) ~= "string" then return nil end
    if type(x) ~= "number" or type(y) ~= "number" then return nil end
    return { point, relativePoint, x, y }
end

---Creates or repairs the saved settings and makes them ns.db and ns.char. Called on
---ADDON_LOADED, when the client has filled in the saved tables.
function ns.LoadSettings()
    if type(PetCareButtonDB) ~= "table" then PetCareButtonDB = {} end
    ---@type PetCareButtonSettings
    local db = PetCareButtonDB
    -- A broken value is dropped, so the default shows through.
    for key, default in pairs(ns.DEFAULTS) do
        if db[key] ~= nil and type(db[key]) ~= type(default) then db[key] = nil end
    end
    -- A string that is no sound mode is dropped as well; rawset, since the field may hold only a
    -- mode once loaded, and nil here just lets the default show through.
    if db.sound ~= nil and not ns.SOUND_MODES[db.sound] then rawset(db, "sound", nil) end
    setmetatable(db, { __index = ns.DEFAULTS })
    -- Numbers are put back in range: whole seconds from 1, a scale from 0.3 to 3, a whole
    -- percentage from 0 to 90.
    db.duration = math.max(1, math.floor(db.duration))
    db.scale = math.min(3, math.max(0.3, db.scale))
    db.low = math.min(90, math.max(0, math.floor(db.low)))
    db.pos = cleanPos(db.pos)
    ---@type PetCareButtonSettings
    ns.db = db

    if type(PetCareButtonCharDB) ~= "table" then PetCareButtonCharDB = {} end
    ---@type PetCareButtonCharSettings
    local char = PetCareButtonCharDB
    char.petDead = char.petDead == true
    char.macroMade = char.macroMade == true
    ns.char = char
end

---Removes the settings that equal their default, so the saved file keeps only what the player
---changed. Called on PLAYER_LOGOUT, just before the client writes the file; ns.db keeps working
---through its metatable.
function ns.StripDefaults()
    for key, default in pairs(ns.DEFAULTS) do
        if rawget(ns.db, key) == default then ns.db[key] = nil end
    end
end
