-- The saved settings and the shared lookups.

test("a fresh install saves nothing but works on the defaults", function()
    local client = NewClient():login()
    eq(client.ns.db.duration, 6)
    eq(client.ns.db.sound, "family")
    eq(client.ns.db.low, 40)
    client:fire("PLAYER_LOGOUT")
    eq(next(Saved()), nil, "only changed values are kept")
end)

test("changed settings survive logout; values equal to the default are dropped", function()
    local client = NewClient({ savedDB = { died = false, duration = 6 } }):login()
    client:fire("PLAYER_LOGOUT")
    eq(Saved().died, false)
    eq(rawget(Saved(), "duration"), nil)
end)

test("a saved table that is no table is replaced", function()
    local client = NewClient({ savedDB = "broken" }):login()
    eq(type(Saved()), "table")
    eq(client.ns.db.scale, 1)
end)

test("broken values fall back to their defaults; numbers are put back in range", function()
    local client = NewClient({
        savedDB = { died = "yes", sound = "loud", duration = 0.5, scale = 7, low = 95.5, pos = "middle" },
    }):login()
    local db = client.ns.db
    eq(db.died, true)
    eq(db.sound, "family")
    eq(db.duration, 1)
    eq(db.scale, 3)
    eq(db.low, 90)
    eq(db.pos, nil)
    eq(NewClient({ savedDB = { low = -3 } }):login().ns.db.low, 0)
end)

test("a saved position is kept only when every part is right", function()
    local function pos(saved)
        return NewClient({ savedDB = { pos = saved } }):login().ns.db.pos
    end
    eq(pos({ "TOP", "TOP", 5, -5 })[3], 5)
    eq(pos({ 1, "TOP", 5, -5 }), nil)
    eq(pos({ "TOP", "TOP", "5", -5 }), nil)
end)

test("spell names and icons through C_Spell, GetSpellInfo or neither", function()
    local name, icon = NewClient().ns.SpellInfo(MEND)
    eq(name, "Mend Pet")
    eq(icon, 132179)
    name, icon = NewClient({ noTextureAPI = true }).ns.SpellInfo(MEND)
    eq(name, "Mend Pet")
    eq(icon, nil)
    name, icon = NewClient({ oldSpellAPI = true }).ns.SpellInfo(REVIVE)
    eq(name, "Revive Pet")
    eq(icon, 132163)
    name = NewClient({ noSpellAPI = true }).ns.SpellInfo(REVIVE)
    eq(name, nil)
end)

test("the pet's family, or nil without a pet", function()
    local client = NewClient()
    eq(client.ns.PetFamilyID(), 2)
    client.pet = nil
    eq(client.ns.PetFamilyID(), nil)
end)

test("debug lines only print with debug on", function()
    local client = NewClient():login()
    client.ns.Debug("hidden")
    eq(#client.printed, 0)
    client:slash("debug")
    client.ns.Debug("shown")
    ok(client:printedContains("[debug]|r shown"))
end)
