local _, ns = ...

-- The toast has the look of PetAbilityLearned's splash, itself after GnomeLevelUp's: a black
-- panel whose edges fade out, a round icon in a ring, and text with a soft glow made of offset
-- copies behind it. The ring and the title are in a warning red rather than gold.
--
-- Each toast belongs to a problem (its key, such as "dead"). One problem has at most one toast
-- up or waiting, and a problem that is solved takes its toast away (ns.DropToast).

local FRAME_WIDTH, FRAME_HEIGHT = 440, 236
local ICON_SIZE = 64
local RING_SIZE = ICON_SIZE + 6
local BG_OPACITY = 0.75
local BG_LAYERS = 28
local BG_FADE_FRACTION = 0.12 -- fade band per side, as a fraction of that side
local GLOW_ALPHA = 0.15
local GOLD = { 1, 0.82, 0.2 }
local WARNING_RED = { 1, 0.35, 0.25 }
local FALLBACK_ICON = "Interface\\Icons\\Ability_Hunter_BeastCall"
local CIRCLE_MASK = "Interface\\CharacterFrame\\TempPortraitAlphaMask"
-- SOUNDKIT.RAID_WARNING.
local WARNING_SOUND = 8959

-- The aggro sound of each pet family, by CreatureFamily ID (the second return of
-- UnitCreatureFamily, the same on every client language), as a FileDataID for PlaySoundFile: the
-- call a pet gives when it is sent to attack. The same table as PetAbilityLearned's; FileDataIDs
-- from the wago.tools community listfile, with the file names so they can be looked up again. No
-- aggro sound was found for Crocolisk (6), Scorpid (20) and Bat (24): those get the raid warning.
---@type table<number, number>
local FAMILY_SOUNDS = {
    [1] = 564215, -- Wolf: sound/creature/wolf/mwolfaggro1.ogg
    [2] = 562387, -- Cat: sound/creature/tiger/mtigeraggroa.ogg
    [3] = 561415, -- Spider: sound/creature/tarantula/mtarantulaaggroa.ogg
    [4] = 544959, -- Bear: sound/creature/bear/mbearaggroa.ogg
    [5] = 545134, -- Boar: sound/creature/boar/mwildboaraggro1.ogg
    [7] = 545937, -- Carrion Bird: sound/creature/carrion/mcarrionaggroa.ogg
    [8] = 546423, -- Crab: sound/creature/crab/crabaggro.ogg
    [9] = 550967, -- Gorilla: sound/creature/gorilla/gorillaaggroa.ogg
    [11] = 558877, -- Raptor: sound/creature/raptor/mraptoraggroa.ogg
    [12] = 561390, -- Tallstrider: sound/creature/tallstrider/tallstrideraggroa.ogg
    [21] = 559878, -- Turtle: sound/creature/seaturtle/seaturtleaggroa.ogg
    [25] = 552339, -- Hyena: sound/creature/hyena/hyenaaggroa.ogg
    [26] = 557977, -- Bird of Prey: sound/creature/owl/owlaggro.ogg
    [27] = 559967, -- Wind Serpent: sound/creature/serpent/serpentaggro.ogg
}

-- Intro timings, in seconds.
local BG_FADE = 0.25
local CONTENT_DELAY, CONTENT_FADE = 0.10, 0.30
local ICON_POP = 0.45
local FADE_OUT = 0.6

local frame = CreateFrame("Frame", "PetCareButtonToast", UIParent)
frame:SetSize(FRAME_WIDTH, FRAME_HEIGHT)
frame:SetFrameStrata("HIGH")
frame:SetClampedToScreen(true)
frame:EnableMouse(true)
frame:SetMovable(true)
frame:RegisterForDrag("LeftButton")
frame:Hide()
ns.toast = frame

---Puts the toast where it was dragged to, or in its standard spot above the centre.
local function PositionFrame()
    frame:ClearAllPoints()
    local pos = ns.db.pos
    if pos and pos[1] then
        frame:SetPoint(pos[1], UIParent, pos[2], pos[3], pos[4])
    else
        frame:SetPoint("CENTER", UIParent, "CENTER", 0, 160)
    end
end

frame:SetScript("OnDragStart", function(
    self --[[@as Frame]]
)
    self:StartMoving()
end)
frame:SetScript("OnDragStop", function(
    self --[[@as Frame]]
)
    self:StopMovingOrSizing()
    local point, _, relativePoint, x, y = self:GetPoint(1)
    local db = ns.db
    if point then db.pos = { point, relativePoint, x, y } end
end)

-- Background: stacked black layers, each inset a little further, so the panel is solid in the
-- middle and fades to nothing at the edges. Each layer's alpha is chosen so the stacked result
-- follows a smoothstep curve from edge to centre.
local bg = CreateFrame("Frame", nil, frame)
bg:SetAllPoints(frame)

---@param t number from 0 to 1
---@return number
local function SmoothStep(t)
    return t * t * (3 - 2 * t)
end

---Creates the background layers once.
local function BuildBackground()
    local fadeX, fadeY = FRAME_WIDTH * BG_FADE_FRACTION, FRAME_HEIGHT * BG_FADE_FRACTION
    local previous = 0
    for k = 1, BG_LAYERS do
        local layer = bg:CreateTexture(nil, "BACKGROUND")
        local insetX, insetY = fadeX * (k - 1) / BG_LAYERS, fadeY * (k - 1) / BG_LAYERS
        layer:SetPoint("TOPLEFT", bg, "TOPLEFT", insetX, -insetY)
        layer:SetPoint("BOTTOMRIGHT", bg, "BOTTOMRIGHT", -insetX, insetY)
        local target = BG_OPACITY * SmoothStep(k / BG_LAYERS)
        local alpha = math.max(0, 1 - (1 - target) / (1 - previous))
        layer:SetColorTexture(0, 0, 0, alpha)
        previous = target
    end
end
BuildBackground()

local content = CreateFrame("Frame", nil, frame)
content:SetAllPoints(frame)

local GLOW_DIRS = { { -1, 0 }, { 1, 0 }, { 0, -1 }, { 0, 1 }, { -1, -1 }, { 1, 1 }, { -1, 1 }, { 1, -1 } }

-- The methods of a PetCareButtonGlowText: a font string with eight faint copies around it.
local GlowTextMethods = {}

---Calls a FontString method with the same arguments on the text and all its copies.
---@param self PetCareButtonGlowText
---@param method string
---@param ... any the method's arguments
function GlowTextMethods:Set(method, ...)
    ---@type FontString[]
    local layers = self.layers
    for _, fs in ipairs(layers) do
        fs[method](fs, ...)
    end
end

---@param template string font object for the text
---@param radius number how far the copies sit from the text, in pixels
---@param size number? font size, when the template's is not the one wanted
---@return PetCareButtonGlowText
local function GlowText(template, radius, size)
    local main = content:CreateFontString(nil, "OVERLAY", template)
    ---@type FontString[]
    local layers = { main }
    for _, dir in ipairs(GLOW_DIRS) do
        local glow = content:CreateFontString(nil, "ARTWORK", template)
        glow:SetPoint("TOPLEFT", main, "TOPLEFT", dir[1] * radius, dir[2] * radius)
        glow:SetPoint("TOPRIGHT", main, "TOPRIGHT", dir[1] * radius, dir[2] * radius)
        glow:SetAlpha(GLOW_ALPHA)
        layers[#layers + 1] = glow
    end
    ---@type PetCareButtonGlowText
    local text = setmetatable({ main = main, layers = layers }, { __index = GlowTextMethods })
    if size then
        local path, _, flags = main:GetFont()
        text:Set("SetFont", path, size, flags or "")
    end
    text:Set("SetWidth", FRAME_WIDTH - 60)
    text:Set("SetJustifyH", "CENTER")
    return text
end

local ring = content:CreateTexture(nil, "ARTWORK", nil, 1)
ring:SetSize(RING_SIZE, RING_SIZE)
ring:SetPoint("TOP", content, "TOP", 0, -18)
ring:SetColorTexture(WARNING_RED[1], WARNING_RED[2], WARNING_RED[3], 1)

local icon = content:CreateTexture(nil, "ARTWORK", nil, 2)
icon:SetSize(ICON_SIZE, ICON_SIZE)
icon:SetPoint("CENTER", ring, "CENTER")
icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

if content.CreateMaskTexture then
    for _, tex in ipairs({ ring, icon }) do
        local mask = content:CreateMaskTexture()
        mask:SetAllPoints(tex)
        mask:SetTexture(CIRCLE_MASK, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        tex:AddMaskTexture(mask)
    end
end

local title = GlowText("GameFontNormalLarge", 2)
title.main:SetPoint("TOP", ring, "BOTTOM", 0, -10)
title:Set("SetTextColor", WARNING_RED[1], WARNING_RED[2], WARNING_RED[3])

local spellName = GlowText("GameFontNormalHuge", 3, 30)
spellName.main:SetPoint("TOP", title.main, "BOTTOM", 0, -8)
spellName:Set("SetTextColor", GOLD[1], GOLD[2], GOLD[3])

local reasonText = GlowText("GameFontHighlight", 1.5)
reasonText.main:SetPoint("TOP", spellName.main, "BOTTOM", 0, -10)

local hintText = GlowText("GameFontHighlightSmall", 1.5)
hintText.main:SetPoint("TOP", reasonText.main, "BOTTOM", 0, -8)
hintText:Set("SetTextColor", 0.8, 0.8, 0.8)

-- The visible parts as fields, the way a template's parentKeys would be.
frame.Icon, frame.Title, frame.Name = icon, title.main, spellName.main
frame.Reason, frame.Hint = reasonText.main, hintText.main

-- Intro and outro run on one OnUpdate clock so a new toast can restart them cleanly.

---@param p number from 0 to 1
---@return number
local function EaseOut(p)
    return 1 - (1 - p) * (1 - p)
end

---Overshoots a little before settling at 1: the icon's pop.
---@param p number from 0 to 1
---@return number
local function EaseOutBack(p)
    local c = 1.70158
    return 1 + (c + 1) * (p - 1) ^ 3 + c * (p - 1) ^ 2
end

---How far an animation that starts at `delay` and lasts `duration` is at time `t`, from 0 to 1.
---@param t number
---@param delay number
---@param duration number
---@return number
local function Progress(t, delay, duration)
    return math.max(0, math.min(1, (t - delay) / duration))
end

---Seconds since the toast was shown, when it starts to fade, and when the fade began.
---@type number, number, number?
local clock, fadeAt, fadeStart = 0, 0, nil
---The toast up now, nil when none is.
---@type PetCareButtonToastInfo?
local current

-- Toasts waiting while another is up; each shows when the one before it is gone.
---@type PetCareButtonToastInfo[]
local queue = {}
---@type fun(info: PetCareButtonToastInfo)
local Display

---Shows the next queued toast, if any; called whenever one is gone.
local function ShowNext()
    current = nil
    local info = table.remove(queue, 1)
    if info then Display(info) end
end

---@param _ Frame the toast
---@param elapsed number seconds since the previous frame
local function Animate(_, elapsed)
    clock = clock + elapsed
    bg:SetAlpha(EaseOut(Progress(clock, 0, BG_FADE)))
    content:SetAlpha(EaseOut(Progress(clock, CONTENT_DELAY, CONTENT_FADE)))
    local pop = EaseOutBack(Progress(clock, CONTENT_DELAY, ICON_POP))
    local size = math.max(1, RING_SIZE * (0.3 + 0.7 * pop))
    ring:SetSize(size, size)
    icon:SetSize(size - 6, size - 6)

    if not fadeStart and clock >= fadeAt then
        -- Hovering holds the toast so it can be read; it fades once the mouse leaves.
        if frame:IsMouseOver() then
            fadeAt = clock + 0.2
        else
            fadeStart = clock
        end
    end
    if fadeStart then
        local p = Progress(clock, fadeStart, FADE_OUT)
        frame:SetAlpha(1 - p)
        if p >= 1 then
            frame:Hide()
            ShowNext()
        end
    end
end

---Closes the toast at once, without the fade; the next queued one, if any, follows.
function ns.HideToast()
    frame:SetScript("OnUpdate", nil)
    frame:Hide()
    ShowNext()
end

frame:SetScript("OnMouseUp", function(
    _,
    button --[[@as string]]
)
    if button == "RightButton" then ns.HideToast() end
end)

---The sound for a toast, as the sound setting asks: the pet out's call, or the raid warning. A
---toast that asks for the warning (the dead pet's: its attack call would be out of place) gets
---the warning in family mode too.
---@param info PetCareButtonToastInfo
local function PlayToastSound(info)
    local mode = ns.db.sound
    if mode == "off" then return end
    local familyID = mode == "family" and info.sound ~= "warning" and ns.PetFamilyID()
    local familySound = familyID and FAMILY_SOUNDS[familyID]
    if familySound then
        PlaySoundFile(familySound, "Master")
    else
        PlaySound(WARNING_SOUND, "Master")
    end
end

---Fills the toast with `info` and starts it.
---@param info PetCareButtonToastInfo
function Display(info)
    local db = ns.db
    current = info
    icon:SetTexture(info.icon or FALLBACK_ICON)
    title:Set("SetText", info.title)
    spellName:Set("SetText", info.name or "?")
    reasonText:Set("SetText", info.reason or "")
    hintText:Set("SetText", info.hint or "")

    frame:SetScale(db.scale)
    PositionFrame()
    frame:SetAlpha(1)
    bg:SetAlpha(0)
    content:SetAlpha(0)
    clock, fadeStart = 0, nil
    fadeAt = db.duration
    frame:SetScript("OnUpdate", Animate)
    frame:Show()

    PlayToastSound(info)
end

---The position in the queue of the toast for `key`, or nil.
---@param key string
---@return number?
local function Queued(key)
    for i, info in ipairs(queue) do
        if info.key == key then return i end
    end
    return nil
end

---Shows a toast now, or after the one that is up. A problem whose toast is already up or waiting
---gets no second one.
---@param info PetCareButtonToastInfo
function ns.ShowToast(info)
    if (current and current.key == info.key) or Queued(info.key) then return end
    if current then
        queue[#queue + 1] = info
    else
        Display(info)
    end
end

---Takes away the toast for a problem that is solved: it fades out if it is up, and is dropped if
---it is waiting.
---@param key string
function ns.DropToast(key)
    local index = Queued(key)
    if index then table.remove(queue, index) end
    if current and current.key == key and not fadeStart then fadeStart = clock end
end
