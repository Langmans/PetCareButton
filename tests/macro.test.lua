-- The PetCare macro: where /pcb macro puts it, and its tooltip line following the button.

local ALIVE = "#showtooltip [@pet,dead] Revive Pet; [nopet] Call Pet; Mend Pet\n/click PetCareButton"
local DEAD = "#showtooltip [@pet,exists,nodead] Mend Pet; Revive Pet\n/click PetCareButton"

local function fill(list, count)
    for i = 1, count do
        list[i] = { name = "M" .. i }
    end
end

test("/pcb macro makes a character macro once", function()
    local client = NewClient():login():slash("macro")
    eq(#client.charMacros, 1)
    eq(#client.macros, 0)
    eq(client.charMacros[1].name, "PetCare")
    eq(client.charMacros[1].icon, 134400)
    eq(client.charMacros[1].body, ALIVE)
    ok(client:printedContains("Macro PetCare made for this character"))
    client:slash("macro")
    eq(#client.charMacros, 1)
    ok(client:printedContains("There is a macro named PetCare already."))
end)

test("with the character macros full it goes among the account ones", function()
    local client = NewClient():login()
    fill(client.charMacros, 30)
    client:slash("macro")
    eq(client.macros[1].name, "PetCare")
    ok(client:printedContains("made among the account-wide macros"))
end)

test("without the client's limits the addon's own (18 character macros) apply", function()
    local client = NewClient({ noMacroConsts = true }):login()
    fill(client.charMacros, 18)
    client:slash("macro")
    eq(client.macros[1].name, "PetCare")
end)

test("with both full, or in combat, nothing is made", function()
    local client = NewClient():login()
    fill(client.charMacros, 30)
    fill(client.macros, 120)
    client:slash("macro")
    ok(client:printedContains("both full"))
    client = NewClient():login():enterCombat():slash("macro")
    eq(#client.charMacros, 0)
    ok(client:printedContains("Not in combat"))
end)

test("a macro made while the pet counts as dead shows Revive Pet", function()
    local client = NewClient({ noPet = true, savedChar = { petDead = true } }):login():slash("macro")
    eq(client:macroBody(), DEAD)
end)

test("the tooltip line follows the button outside combat", function()
    local client = NewClient():login():slash("macro")
    client:petDies()
    eq(client:macroBody(), DEAD)
    client:petGone()
    eq(client:macroBody(), DEAD, "still Revive Pet once the body is gone")
    client:petBack()
    eq(client:macroBody(), ALIVE)
    client:slash("revive")
    eq(client:macroBody(), DEAD)
end)

test("in combat the macro waits; it is written once combat ends", function()
    local client = NewClient():login():slash("macro"):enterCombat()
    client:petDies():petGone()
    eq(client:macroBody(), ALIVE, "not edited in combat")
    eq(#client.blocked, 0, "and not tried")
    client:leaveCombat()
    eq(client:macroBody(), DEAD)
    client:fire("PLAYER_REGEN_ENABLED")
    eq(client:macroBody(), DEAD)
end)

test("a macro already right is not edited again", function()
    local client = NewClient():login():slash("macro")
    client:fire("UPDATE_MACROS")
    eq(client.macroEdits, 0)
    client:petDies()
    eq(client.macroEdits, 1, "its own UPDATE_MACROS changed nothing more")
end)

test("macros loaded after the addon are brought up to date", function()
    local client = NewClient({ noPet = true, savedChar = { petDead = true } }):login()
    client.charMacros[1] = { name = "PetCare", icon = 134400, body = ALIVE }
    client:fire("UPDATE_MACROS")
    eq(client:macroBody(), DEAD)
end)

test("without the macro, or on another class, nothing is edited", function()
    local client = NewClient():login():petDies()
    eq(client.macroEdits, 0)
    client = NewClient({ class = "MAGE" }):login()
    client.macros[1] = { name = "PetCare", icon = 134400, body = DEAD }
    client:fire("UPDATE_MACROS")
    eq(client.macros[1].body, DEAD)
end)

test("debug traces a macro edit", function()
    local client = NewClient({ savedDB = { debug = true } }):login():slash("macro"):petDies()
    ok(client:printedContains("macro updated"))
end)
