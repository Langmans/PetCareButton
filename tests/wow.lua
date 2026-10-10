-- A simulated WoW client: just the API this addon touches, with every value a
-- test may want to vary exposed on the client object. NewClient() resets all
-- globals and loads the addon files in .toc order into a fresh namespace, so
-- tests never share state.
--
-- The secure side is simulated too, closely enough to run the addon's own
-- snippets: macro conditions are evaluated (only those the addon uses),
-- state drivers report changes through `state-*` attributes, snippets run
-- in an environment that has nothing but `self` (a frame handle) and their
-- arguments, and in combat an insecure SetAttribute on a protected frame is
-- blocked and recorded in client.blocked, as the real client blocks it.

-- The spells the simulated client knows, per locale: id -> { name, icon }.
local SPELLS = {
    enUS = {
        [136] = { "Mend Pet", 132179 },
        [982] = { "Revive Pet", 132163 },
        [883] = { "Call Pet", 132161 },
    },
    deDE = {
        [136] = { "Tier heilen", 132179 },
        [982] = { "Tier wiederbeleben", 132163 },
        [883] = { "Tier rufen", 132161 },
    },
}

-- What a hidden value looks like to the addon: only issecretvalue tells it apart.
SECRET = setmetatable({}, {
    __tostring = function()
        return "<secret>"
    end,
})

---@param opts {locale: string?, class: string?, savedDB: table?, savedChar: table?, oldSpellAPI: boolean?, noSpellAPI: boolean?, noTextureAPI: boolean?, noMasks: boolean?, oldCheckButton: boolean?, oldSlider: boolean?, metadata: table?, noAddOnsAPI: boolean?, inCombat: boolean?, noPet: boolean?}?
function NewClient(opts)
    opts = opts or {}
    -- opts.locale: the client's language. Spell names exist here for enUS and deDE; any other
    -- locale reads the English ones.
    local locale = opts.locale or "enUS"
    local spells = SPELLS[locale] or SPELLS.enUS
    function GetLocale()
        return locale
    end
    local client = {
        time = 100,
        timers = {},
        frames = {},
        printed = {},
        sounds = {},
        -- The active pet: health, max health and whether it is dead; nil when there is no pet
        -- unit (none summoned, or a dead one whose body is gone). opts.noPet starts without.
        pet = not opts.noPet and { health = 100, max = 100, dead = false } or nil,
        -- Modifier keys held: { shift = true, ctrl = true }.
        mods = {},
        mounted = false,
        mouseOver = false,
        -- Insecure SetAttribute/Execute calls the client blocked in combat.
        blocked = {},
        -- Key bindings: action -> key.
        bindings = {},
        -- The account-wide and this character's macros: { name, icon, body }. Indexes run as in
        -- the client: account macros from 1, character macros from MAX_ACCOUNT_MACROS + 1.
        macros = {},
        charMacros = {},
        drivers = {},
        inCombat = opts.inCombat == true,
    }

    function UnitClass()
        local classFile = opts.class or "HUNTER"
        return classFile, classFile
    end
    function UnitExists(unit)
        return unit == "player" or (unit == "pet" and client.pet ~= nil)
    end
    function UnitIsDead(unit)
        return unit == "pet" and client.pet ~= nil and client.pet.dead
    end
    -- client.healthSecret: health is hidden, as Forever may hide it in combat.
    function UnitHealth(unit)
        if unit ~= "pet" or not client.pet then return 0 end
        if client.healthSecret then return SECRET end
        return client.pet.health
    end
    function UnitHealthMax(unit)
        if unit ~= "pet" or not client.pet then return 0 end
        return client.pet.max
    end
    function IsMounted()
        return client.mounted
    end
    -- client.familyID: the pet's CreatureFamily ID (2 = cat by default).
    client.familyID = 2
    function UnitCreatureFamily(unit)
        if unit ~= "pet" or not client.pet then return nil end
        return "Cat", client.familyID
    end
    -- client.sounds: { file = FileDataID } for a sound file, { id = SoundKit ID } for a kit.
    function PlaySoundFile(file, channel)
        client.sounds[#client.sounds + 1] = { file = file, channel = channel }
    end
    function PlaySound(id, channel)
        client.sounds[#client.sounds + 1] = { id = id, channel = channel }
    end
    function print(text)
        client.printed[#client.printed + 1] = text
    end
    issecretvalue = function(value)
        return value == SECRET
    end
    canaccessvalue = function(value)
        return value ~= SECRET
    end
    -- The client's "Your pet is dead" error, under the name the addon checks first.
    ERR_PET_SPELL_DEAD = "Your pet is dead."
    PETTAME_DEAD = nil

    -- Spell lookups: C_Spell on newer clients, GetSpellInfo with opts.oldSpellAPI, neither with
    -- opts.noSpellAPI.
    local function getName(id)
        local s = spells[id]
        return s and s[1]
    end
    local function getTexture(id)
        local s = spells[id]
        return s and s[2]
    end
    C_Spell, GetSpellInfo = nil, nil
    if opts.oldSpellAPI then
        function GetSpellInfo(id)
            local s = spells[id]
            if s then return s[1], nil, s[2] end
        end
    elseif not opts.noSpellAPI then
        C_Spell = { GetSpellName = getName, GetSpellTexture = not opts.noTextureAPI and getTexture or nil }
    end

    C_Timer = {
        After = function(seconds, callback)
            client.timers[#client.timers + 1] = { at = client.time + seconds, callback = callback }
        end,
    }

    function GetBindingKey(action)
        return client.bindings[action]
    end
    function GetBindingText(key)
        return "<" .. key .. ">"
    end

    -- opts.noMacroConsts: a client without Constants.MacroConsts, where the addon's own limits
    -- (120 account, 18 character) apply.
    local MAX_ACCOUNT, MAX_CHARACTER = 120, opts.noMacroConsts and 18 or 30
    Constants = not opts.noMacroConsts
            and { MacroConsts = { MAX_ACCOUNT_MACROS = MAX_ACCOUNT, MAX_CHARACTER_MACROS = MAX_CHARACTER } }
        or nil
    ---The macro at a client index, or nil.
    local function macroAt(index)
        if index > MAX_ACCOUNT then return client.charMacros[index - MAX_ACCOUNT] end
        return client.macros[index]
    end
    function GetMacroIndexByName(name)
        for i, macro in ipairs(client.macros) do
            if macro.name == name then return i end
        end
        for i, macro in ipairs(client.charMacros) do
            if macro.name == name then return MAX_ACCOUNT + i end
        end
        return 0
    end
    function GetNumMacros()
        return #client.macros, #client.charMacros
    end
    function GetMacroInfo(index)
        local macro = macroAt(index)
        if macro then return macro.name, macro.icon, macro.body end
    end
    -- client.macroEdits counts the edits, so tests can see an edit that changed nothing was skipped.
    client.macroEdits = 0
    function CreateMacro(name, icon, body, perCharacter)
        assert(not client.inCombat, "macros are not made in combat")
        local list = perCharacter and client.charMacros or client.macros
        assert(#list < (perCharacter and MAX_CHARACTER or MAX_ACCOUNT), "no free macro slot")
        list[#list + 1] = { name = name, icon = icon, body = body }
        return perCharacter and MAX_ACCOUNT + #list or #list
    end
    function EditMacro(index, name, icon, body)
        if client.inCombat then
            client.blocked[#client.blocked + 1] = "EditMacro"
            return
        end
        local macro = assert(macroAt(index), "no macro at " .. index)
        macro.name, macro.icon, macro.body = name or macro.name, icon or macro.icon, body or macro.body
        client.macroEdits = client.macroEdits + 1
        client:fire("UPDATE_MACROS")
        return index
    end
    ---This character's PetCare macro's body, or the account one's, or nil.
    function client:macroBody()
        local index = GetMacroIndexByName("PetCare")
        return index > 0 and macroAt(index).body or nil
    end

    -- Macro conditions, as far as the addon uses them: [@pet], dead, exists, nopet, mod:shift,
    -- mod:ctrl. Brackets are alternatives, commas inside one all have to hold.
    local function conditionHolds(group)
        local target = "player"
        local holds = true
        for condition in group:gmatch("[^,]+") do
            condition = condition:match("^%s*(.-)%s*$")
            if condition == "@pet" then
                target = "pet"
            elseif condition == "dead" then
                holds = holds and UnitIsDead(target)
            elseif condition == "exists" then
                holds = holds and UnitExists(target)
            elseif condition == "nopet" then
                holds = holds and not UnitExists("pet")
            elseif condition == "mod:shift" or condition == "mod:ctrl" then
                holds = holds and client.mods[condition:sub(5)] == true
            else
                error("unknown macro condition " .. condition)
            end
        end
        return holds
    end
    ---What SecureCmdOptionParse answers for `options`: the value of the first clause whose
    ---conditions hold, or nil.
    function client:evaluate(options)
        for clause in options:gmatch("[^;]+") do
            local conditions, value = clause:match("^%s*(%[.*%])%s*(.-)%s*$")
            if not conditions then return clause:match("^%s*(.-)%s*$") end
            for group in conditions:gmatch("%[(.-)%]") do
                if conditionHolds(group) then return value end
            end
        end
        return nil
    end

    -- Layout calls only matter to the real UI; they do nothing here. A region keeps what tests
    -- read back: text, texture, alpha, scale, shown state, points, font and attributes.
    local function noop() end
    local Region = {}
    -- Methods the addon tests for before calling them stay absent unless defined.
    -- So do parentKeys, which are fields rather than methods.
    local OPTIONAL =
        { CreateMaskTexture = true, Text = true, text = true, Low = true, High = true, SetObeyStepOnDrag = true }
    Region.__index = function(_, key)
        if OPTIONAL[key] then return Region[key] end
        return Region[key] or noop
    end
    function Region:SetText(text)
        self.text = text
    end
    function Region:GetText()
        return self.text
    end
    function Region:SetTexture(texture)
        self.texture = texture
    end
    function Region:SetAlpha(alpha)
        self.alpha = alpha
    end
    function Region:SetScale(scale)
        self.scale = scale
    end
    function Region:SetWidth(width)
        self.width = width
    end
    function Region:SetSize(width, height)
        self.width, self.height = width, height
    end
    function Region:Show()
        self.shown = true
    end
    function Region:Hide()
        self.shown = false
    end
    function Region:IsShown()
        return self.shown
    end
    function Region:ClearAllPoints()
        self.points = {}
    end
    function Region:SetPoint(point, relativeTo, relativePoint, x, y)
        self.points[#self.points + 1] = { point, relativeTo, relativePoint, x, y }
    end
    function Region:GetPoint(index)
        local p = self.points[index]
        return p[1], p[2], p[3], p[4], p[5]
    end
    function Region:GetFont()
        return self.fontPath or "Fonts\\FRIZQT__.TTF", self.fontSize or 12, self.fontFlags
    end
    function Region:SetFont(path, size, flags)
        self.fontPath, self.fontSize, self.fontFlags = path, size, flags
    end

    local function newRegion(fields)
        fields = fields or { shown = true }
        fields.points = {}
        return setmetatable(fields, Region)
    end

    function Region:CreateTexture()
        return newRegion()
    end
    client.fontStrings = {}
    function Region:CreateFontString()
        local region = newRegion()
        client.fontStrings[#client.fontStrings + 1] = region
        return region
    end
    if not opts.noMasks then
        function Region:CreateMaskTexture()
            return newRegion()
        end
    end
    function Region:RegisterEvent(event)
        self.events[event] = true
    end
    -- A unit event is delivered only for its unit.
    function Region:RegisterUnitEvent(event, unit)
        self.events[event] = unit
    end
    function Region:UnregisterEvent(event)
        self.events[event] = nil
    end
    function Region:SetScript(script, handler)
        self.scripts[script] = handler
    end
    function Region:HookScript(script, handler)
        self.hooks[script] = self.hooks[script] or {}
        table.insert(self.hooks[script], handler)
    end
    function Region:IsMouseOver()
        return client.mouseOver
    end
    function Region:StopMovingOrSizing()
        -- The real client leaves the frame anchored where it was dropped.
        self.points = { { "TOPLEFT", nil, "BOTTOMLEFT", 300, 700 } }
    end

    -- How deep we are in restricted (secure) code; insecure code is at 0.
    local restricted = 0
    local runSnippet

    ---Sets an attribute as the client does: blocked in combat for insecure code on a protected
    ---frame; a state-* attribute on a state handler runs its _onstate-* snippet; then the
    ---OnAttributeChanged hooks run.
    local function setAttribute(frame, name, value)
        if frame.protected and client.inCombat and restricted == 0 then
            client.blocked[#client.blocked + 1] = name
            return
        end
        frame.attributes[name] = value
        local stateID = name:match("^state%-(.+)$")
        if frame.stateHandler and stateID then
            local snippet = frame.attributes["_onstate-" .. stateID]
            if snippet then runSnippet(frame, snippet, { stateid = stateID, newstate = value }) end
        end
        for _, hook in ipairs(frame.hooks.OnAttributeChanged or {}) do
            hook(frame, name, value)
        end
    end
    function Region:SetAttribute(name, value)
        setAttribute(self, name, value)
    end
    function Region:GetAttribute(name)
        return self.attributes[name]
    end

    ---A frame as restricted code sees it.
    local function handle(frame)
        return {
            GetAttribute = function(_, name)
                return frame.attributes[name]
            end,
            SetAttribute = function(_, name, value)
                assert(not name:match("^_"), "restricted code cannot set _ attributes")
                setAttribute(frame, name, value)
            end,
            RunAttribute = function(_, name)
                runSnippet(frame, frame.attributes[name], {})
            end,
            GetFrameRef = function(_, label)
                return handle(assert(frame.refs[label], "no frame ref " .. label))
            end,
        }
    end
    function runSnippet(frame, body, args)
        local env = { self = handle(frame) }
        for key, value in pairs(args) do
            env[key] = value
        end
        local chunk = assert(load(body, "=snippet", "t", env))
        restricted = restricted + 1
        chunk()
        restricted = restricted - 1
    end

    function SecureHandlerSetFrameRef(frame, label, ref)
        if client.inCombat then
            client.blocked[#client.blocked + 1] = "SetFrameRef"
            return
        end
        frame.refs[label] = ref
    end
    function SecureHandlerExecute(frame, body)
        if client.inCombat then
            client.blocked[#client.blocked + 1] = "Execute"
            return
        end
        runSnippet(frame, body, {})
    end
    function RegisterStateDriver(frame, state, values)
        assert(not client.inCombat, "a state driver is registered outside combat")
        client.drivers[#client.drivers + 1] = { frame = frame, state = state, values = values }
        client:updateDrivers()
    end

    ---Re-evaluates every state driver, as the client does a few times a second.
    function client:updateDrivers()
        for _, driver in ipairs(self.drivers) do
            local value = self:evaluate(driver.values)
            local attribute = "state-" .. driver.state
            if driver.frame.attributes[attribute] ~= value then
                restricted = restricted + 1
                setAttribute(driver.frame, attribute, value)
                restricted = restricted - 1
            end
        end
        return self
    end

    function CreateFrame(kind, name, parent, template)
        local frame = newRegion({
            kind = kind,
            parent = parent,
            template = template,
            events = {},
            scripts = {},
            hooks = {},
            attributes = {},
            refs = {},
            shown = true,
        })
        template = template or ""
        frame.protected = template:find("Secure") ~= nil
        frame.stateHandler = template:find("SecureHandlerStateTemplate") ~= nil
        client.frames[#client.frames + 1] = frame
        if name then _G[name] = frame end
        if kind == "Button" then
            function frame:RegisterForClicks(...)
                self.clicks = { ... }
            end
        end
        -- Like UICheckButtonTemplate: a checked state and its label as the Text parentKey, or as
        -- `text` on older clients (opts.oldCheckButton).
        if kind == "CheckButton" then
            local label = newRegion()
            if opts.oldCheckButton then
                frame.text = label
            else
                frame.Text = label
            end
            function frame:SetChecked(checked)
                self.checked = checked and true or false
            end
            -- Some clients answer 1/nil rather than true/false.
            function frame:GetChecked()
                return self.checked and 1 or nil
            end
        end
        -- Like OptionsSliderTemplate: its labels as parentKeys, or with opts.oldSlider only as
        -- global names ($parentText, ...) and without SetObeyStepOnDrag. SetValue reports a
        -- change through OnValueChanged, as the client does.
        if kind == "Slider" then
            local text, low, high = newRegion(), newRegion(), newRegion()
            if opts.oldSlider then
                _G[name .. "Text"], _G[name .. "Low"], _G[name .. "High"] = text, low, high
            else
                frame.Text, frame.Low, frame.High = text, low, high
                function frame:SetObeyStepOnDrag(obey)
                    self.obeyStep = obey
                end
            end
            function frame:SetValue(value)
                if value == self.value then return end
                self.value = value
                if self.scripts.OnValueChanged then self.scripts.OnValueChanged(self, value) end
            end
        end
        return frame
    end
    UIParent = newRegion()

    -- The .toc's "## Key: value" lines (handed over by run.mjs), plus opts.metadata on top:
    -- through C_AddOns, or the global on older clients (opts.noAddOnsAPI).
    local function getMetadata(name, key)
        if name ~= "PetCareButton" then return nil end
        if opts.metadata and opts.metadata[key] ~= nil then return opts.metadata[key] or nil end
        return TOC_METADATA[key]
    end
    if opts.noAddOnsAPI then
        C_AddOns, GetAddOnMetadata = nil, getMetadata
    else
        C_AddOns, GetAddOnMetadata = { GetAddOnMetadata = getMetadata }, nil
    end

    function InCombatLockdown()
        return client.inCombat == true
    end
    -- The settings window: client.categories holds what was registered, client.opened the IDs
    -- of the categories opened.
    client.categories, client.opened = {}, {}
    Settings = {
        RegisterCanvasLayoutCategory = function(frame, name)
            local category = { frame = frame, name = name }
            function category:GetID()
                return self.name
            end
            return category
        end,
        RegisterAddOnCategory = function(category)
            client.categories[#client.categories + 1] = category
        end,
        OpenToCategory = function(id)
            client.opened[#client.opened + 1] = id
        end,
    }

    SlashCmdList = {}
    PetCareButtonDB = opts.savedDB
    PetCareButtonCharDB = opts.savedChar

    local ns = {}
    for _, file in ipairs(TOC_FILES) do
        local chunk = assert(loadfile(ROOT .. "/" .. file))
        chunk("PetCareButton", ns)
    end
    client.ns = ns
    client.toast = ns.toast
    client.button = ns.button
    client.header = ns.header

    ---Delivers an event to every frame registered for it; a unit event only to frames
    ---registered for its unit (the first argument).
    function client:fire(event, ...)
        local unit = ...
        for _, frame in ipairs(self.frames) do
            local registered = frame.events[event]
            if registered and (registered == true or registered == unit) and frame.scripts.OnEvent then
                frame.scripts.OnEvent(frame, event, ...)
            end
        end
        return self
    end

    ---Moves the clock on and runs the C_Timer callbacks that came due.
    function client:advance(seconds)
        self.time = self.time + seconds
        local due = {}
        for i = #self.timers, 1, -1 do
            if self.timers[i].at <= self.time then table.insert(due, 1, table.remove(self.timers, i)) end
        end
        for _, timer in ipairs(due) do
            timer.callback()
        end
        return self
    end

    ---What the client does at login: ADDON_LOADED for each addon.
    function client:login()
        self:fire("ADDON_LOADED", "SomeOtherAddon")
        return self:fire("ADDON_LOADED", "PetCareButton")
    end

    ---The spell pressing the button casts now, with the modifier keys in `mods`; nil when the
    ---macro picks nothing.
    function client:press(mods)
        local button = self.button
        if button.attributes.type == nil then return nil end
        assert(button.attributes.type == "macro", "the button runs a macro")
        assert(button.attributes.useOnKeyDown == false, "the button acts on release, as /click sends it")
        local text = button.attributes.macrotext
        if not text then return nil end
        local options = assert(text:match("^/cast (.*)$"), "the macro is one /cast line")
        self.mods = mods or {}
        local spell = self:evaluate(options)
        self.mods = {}
        return spell
    end

    ---The pet dies; its body stays for now.
    function client:petDies()
        self.pet.dead, self.pet.health = true, 0
        self:updateDrivers()
        return self:fire("UNIT_HEALTH", "pet")
    end

    ---No pet unit any more: the dead body is gone, or the pet was dismissed.
    function client:petGone()
        self.pet = nil
        return self:updateDrivers()
    end

    ---A living pet at full health: summoned or revived.
    function client:petBack()
        self.pet = { health = 100, max = 100, dead = false }
        self:updateDrivers()
        return self:fire("UNIT_HEALTH", "pet")
    end

    ---The pet's health changes to `health` (of 100).
    function client:petHealth(health)
        self.pet.health = health
        return self:fire("UNIT_HEALTH", "pet")
    end

    function client:enterCombat()
        self.inCombat = true
        return self:fire("PLAYER_REGEN_DISABLED")
    end

    function client:leaveCombat()
        self.inCombat = false
        return self:fire("PLAYER_REGEN_ENABLED")
    end

    ---A cast of `spellID` starts; castGUID defaults to "Cast-1".
    function client:castStarts(spellID, castGUID)
        return self:fire("UNIT_SPELLCAST_START", "player", castGUID or "Cast-1", spellID)
    end

    ---A cast of `spellID` fails; castGUID defaults to "Cast-1".
    function client:castFails(spellID, castGUID)
        return self:fire("UNIT_SPELLCAST_FAILED", "player", castGUID or "Cast-1", spellID)
    end

    ---The red error text in the middle of the screen.
    function client:uiError(message)
        return self:fire("UI_ERROR_MESSAGE", 51, message)
    end

    ---Runs the toast's OnUpdate for `seconds`, in frames of `step`. Like the client, a hidden
    ---frame gets no more updates.
    function client:animate(seconds, step)
        step = step or 0.05
        local elapsed = 0
        while elapsed < seconds - 1e-9 and self.toast.shown and self.toast.scripts.OnUpdate do
            self.toast.scripts.OnUpdate(self.toast, step)
            elapsed = elapsed + step
        end
        return self
    end

    function client:slash(message)
        SlashCmdList.PETCAREBUTTON(message)
        return self
    end

    function client:printedContains(text)
        for _, line in ipairs(self.printed) do
            if line:find(text, 1, true) then return true end
        end
        return false
    end

    ---The title of the toast that is up, or nil.
    function client:toastTitle()
        if not self.toast.shown then return nil end
        return self.toast.Title.text
    end

    return client
end

function Saved()
    return PetCareButtonDB
end

function SavedChar()
    return PetCareButtonCharDB
end

MEND, REVIVE, CALL = 136, 982, 883
