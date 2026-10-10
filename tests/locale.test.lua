-- Locale selection, the enUS fallback chain and the shape of every locale file.

local ALL_LOCALES = { "enUS", "deDE", "esES", "esMX", "frFR", "koKR", "ruRU" }

---The format directives in a string, in order, e.g. "%d%.2f%s". A literal %% is skipped.
local function formats(text)
    local found = {}
    for directive in text:gsub("%%%%", ""):gmatch("%%[%d%.]*[sdf]") do
        found[#found + 1] = directive
    end
    return table.concat(found)
end

test("an unknown client locale falls back to enUS", function()
    local ns = NewClient({ locale = "zhCN" }).ns
    eq(ns.LocaleCode, "enUS")
    eq(ns.L.TOAST_DEAD, "Your pet is dead")
end)

test("a translated string comes from the client's locale", function()
    local ns = NewClient({ locale = "deDE" }).ns
    eq(ns.LocaleCode, "deDE")
    eq(ns.Format("TOAST_LOW", 30), "Dein Begleiter hat 30% Gesundheit")
end)

test("esMX uses the Spanish strings", function()
    local ns = NewClient({ locale = "esMX" }).ns
    eq(ns.LocaleCode, "esMX")
    eq(ns.L.SOUND_OFF, "Sonido desactivado.")
end)

test("an untranslated string falls back to enUS", function()
    eq(NewClient({ locale = "deDE" }).ns.L.CHAT_PREFIX, "Pet Care Button:")
end)

test("a key missing from enUS returns the key instead of looping", function()
    eq(NewClient({ locale = "enUS" }).ns.L.NO_SUCH_KEY, "NO_SUCH_KEY")
    eq(NewClient({ locale = "frFR" }).ns.L.NO_SUCH_KEY, "NO_SUCH_KEY")
end)

test("every locale only has keys enUS has, with the same format directives", function()
    local ns = NewClient().ns
    local enUS = ns.Locales.enUS.strings
    for _, code in ipairs(ALL_LOCALES) do
        local locale = ns.Locales[code]
        ok(locale, code .. " exists")
        for key, text in pairs(locale.strings) do
            local english = rawget(enUS, key)
            ok(english, code .. "." .. key .. " is not an enUS key")
            eq(formats(text), formats(english), code .. "." .. key)
        end
    end
end)

test("every locale but enUS translates every string shown to the player", function()
    local ns = NewClient().ns
    local enUS = ns.Locales.enUS.strings
    -- The addon's name stays English everywhere.
    local untranslated = { CHAT_PREFIX = true, OPTIONS_TITLE = true }
    for _, code in ipairs(ALL_LOCALES) do
        local strings = ns.Locales[code].strings
        for key in pairs(enUS) do
            if code ~= "enUS" and not untranslated[key] then ok(rawget(strings, key), code .. " lacks " .. key) end
        end
    end
end)

test("the toast and the panel speak the client's language", function()
    local client = NewClient({ locale = "frFR" }):login()
    client:slash("test nopet")
    eq(client.toast.Reason.text, "Le combat a commencé sans votre familier.")
    eq(client.categories[1].name, "Pet Care Button", "the title is untranslated, so English")
    client:slash("sound off")
    ok(client:printedContains("Son désactivé."))
end)
