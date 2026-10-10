-- The toast: its animation, hold on hover, closing, moving, the queue and the sound.

local function showDead(client)
    client.ns.ShowToast(client.ns.AlertToast("dead"))
    return client
end

test("the toast fades in, stays for the duration, then fades out and hides", function()
    local client = showDead(NewClient():login())
    eq(client.toast.alpha, 1)
    client:animate(5.9)
    ok(client.toast.shown, "still up just before the duration")
    client:animate(0.3)
    ok(client.toast.alpha < 1, "fading")
    client:animate(1)
    eq(client.toast.shown, false)
end)

test("hovering holds the toast; leaving lets it fade", function()
    local client = showDead(NewClient():login())
    client.mouseOver = true
    client:animate(20)
    ok(client.toast.shown)
    eq(client.toast.alpha, 1)
    client.mouseOver = false
    client:animate(2)
    eq(client.toast.shown, false)
end)

test("right-click closes it and shows the next; other clicks do not", function()
    local client = showDead(NewClient():login())
    client.ns.ShowToast(client.ns.AlertToast("nopet"))
    client.toast.scripts.OnMouseUp(client.toast, "LeftButton")
    eq(client:toastTitle(), "Your pet is dead")
    client.toast.scripts.OnMouseUp(client.toast, "RightButton")
    eq(client:toastTitle(), "You have no pet out")
    client.toast.scripts.OnMouseUp(client.toast, "RightButton")
    eq(client.toast.shown, false)
    eq(client.toast.scripts.OnUpdate, nil)
end)

test("one alert gets one toast, up or waiting", function()
    local client = showDead(NewClient():login())
    showDead(client)
    client.ns.ShowToast(client.ns.AlertToast("nopet"))
    client.ns.ShowToast(client.ns.AlertToast("nopet"))
    client.ns.HideToast()
    eq(client:toastTitle(), "You have no pet out")
    client.ns.HideToast()
    eq(client.toast.shown, false)
end)

test("dropping a waiting toast removes it from the queue", function()
    local client = showDead(NewClient():login())
    client.ns.ShowToast(client.ns.AlertToast("nopet"))
    client.ns.DropToast("nopet")
    client.ns.HideToast()
    eq(client.toast.shown, false)
end)

test("dropping a toast that is already fading does not restart the fade", function()
    local client = showDead(NewClient():login())
    client:animate(6.3)
    local alpha = client.toast.alpha
    client.ns.DropToast("dead")
    client:animate(0.05)
    ok(client.toast.alpha < alpha)
end)

test("dragging moves it and the spot is remembered", function()
    local client = showDead(NewClient():login())
    eq(client.toast.points[1][1], "CENTER", "default spot")
    client.toast.scripts.OnDragStart(client.toast)
    client.toast.scripts.OnDragStop(client.toast)
    eq(Saved().pos[1], "TOPLEFT")
    eq(Saved().pos[3], 300)
    client.ns.HideToast()
    showDead(client)
    eq(client.toast.points[1][1], "TOPLEFT", "the next toast opens at the saved spot")
end)

test("scale, and a toast without a name, icon or lines", function()
    local client = NewClient({ savedDB = { scale = 1.5 } }):login()
    client.ns.ShowToast({ key = "x", title = "T" })
    eq(client.toast.scale, 1.5)
    eq(client.toast.Name.text, "?")
    eq(client.toast.Icon.texture, "Interface\\Icons\\Ability_Hunter_BeastCall")
    eq(client.toast.Reason.text, "")
    eq(client.toast.Hint.text, "")
end)

local function showNoPet(client)
    client.ns.ShowToast(client.ns.AlertToast("nopet"))
    return client
end

test("the sound is the pet's call, as when it is sent to attack", function()
    local client = showNoPet(NewClient():login())
    eq(client.sounds[1].file, 562387, "a cat's aggro sound")
    eq(client.sounds[1].channel, "Master")
end)

test("low health plays the pet's critical wound sound", function()
    local client = NewClient():login():petHealth(20)
    eq(client.sounds[1].file, 562395, "a cat's critical wound")
    client = NewClient():login()
    client.familyID = 25
    client:petHealth(20)
    eq(client.sounds[1].file, 552336, "a hyena has one")
    client = NewClient():login()
    client.familyID = 24
    client:petHealth(20)
    eq(client.sounds[1].id, 8959, "a bat has none: the raid warning")
end)

test("a dead pet's toast plays its death sound instead of its call", function()
    local client = showDead(NewClient():login())
    eq(client.sounds[1].file, 562391, "a cat's death sound")
    eq(client.sounds[1].channel, "Master")
    client = showDead(NewClient({ savedDB = { sound = "off" } }):login())
    eq(#client.sounds, 0, "sound off is still off")
    client = showDead(NewClient({ savedDB = { sound = "warning" } }):login())
    eq(client.sounds[1].id, 8959, "sound warning is still the warning")
end)

test("a family without a death sound, or a body already gone, plays the raid warning", function()
    local client = NewClient():login()
    client.familyID = 25
    showDead(client)
    eq(client.sounds[1].id, 8959, "a hyena")
    client.ns.HideToast()
    client.familyID = 2
    client.pet = nil
    showDead(client)
    eq(client.sounds[2].id, 8959)
end)

test("the pet dying plays its death sound", function()
    local client = NewClient():login():petDies()
    eq(client.sounds[1].file, 562391)
end)

test("a family without a call, or no pet, plays the raid warning", function()
    local client = NewClient():login()
    client.familyID = 24
    showNoPet(client)
    eq(client.sounds[1].id, 8959)
    client.ns.HideToast()
    client.pet = nil
    showNoPet(client)
    eq(client.sounds[2].id, 8959)
end)

test("sound warning always plays the raid warning, sound off nothing", function()
    local client = showNoPet(NewClient({ savedDB = { sound = "warning" } }):login())
    eq(client.sounds[1].id, 8959)
    client = showNoPet(NewClient({ savedDB = { sound = "off" } }):login())
    eq(#client.sounds, 0)
end)

test("a client without mask textures still shows the toast", function()
    local client = showDead(NewClient({ noMasks = true }):login())
    ok(client.toast.shown)
end)
