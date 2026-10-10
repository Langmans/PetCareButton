---@meta
-- Editor-only types for the addon's own tables: the saved settings, the toast and the alerts.
-- Not listed in the .toc, so the game never loads this file.

---The account-wide settings, ns.db (PetCareButtonDB). Every field but pos falls back to
---Core.lua's DEFAULTS through a metatable, so it always reads as a value.
---@class PetCareButtonSettings
---@field duration number whole seconds the toast stays before it fades, from 1 (/pcb duration)
---@field scale number from 0.3 to 3 (/pcb scale)
---@field sound PetCareButtonSoundMode (/pcb sound)
---@field died boolean toast when the pet dies or turns out to be dead (/pcb died)
---@field nopet boolean toast when combat starts without a pet (/pcb nopet)
---@field low number whole health percentage, 0 to 90, that toasts Mend Pet; 0 is off (/pcb low)
---@field debug boolean trace what the addon sees in chat (/pcb debug)
---@field pos [string, string, number, number]? point, relativePoint, x, y of a dragged toast

---The per-character settings, ns.char (PetCareButtonCharDB).
---@class PetCareButtonCharSettings
---@field petDead boolean whether the button counts this character's pet as dead
---@field macroMade boolean whether the PetCare macro was made (or offered) once for this character

---What making the PetCare macro came to (Macro.lua).
---@alias PetCareButtonMacroResult "character"|"account"|"exists"|"full"|"combat"

---What plays with the toast: the pet's own call (the raid warning for a family without one),
---always the raid warning, or nothing.
---@alias PetCareButtonSoundMode "family"|"warning"|"off"

---The alerts that toast (Alerts.lua).
---@alias PetCareButtonAlertKey "dead"|"nopet"|"low"

---A value the game hands over without a known type: from a SavedVariables file, an event
---argument or an API return.
---@alias GameValue string|number|boolean|table|nil

---What a toast shows (Toast.lua).
---@class PetCareButtonToastInfo
---@field key string the alert it is about (a PetCareButtonAlertKey, or "test:" and one); one toast per alert
---@field title string the line over the name, such as "Your pet died"
---@field name string? the spell the button casts for it
---@field icon (number|string)? texture; the Call Pet icon when nil
---@field reason string? what happened
---@field hint string? how to press the button
---@field sound "warning"? the raid warning even when the sound setting is the pet's call

---A font string with eight faint copies around it (Toast.lua); every setter goes to all nine
---through its Set method.
---@class PetCareButtonGlowText
---@field main FontString the readable text; the copies are anchored to it
---@field layers FontString[] the text and its copies
local GlowText = {}

---Calls a FontString method with the same arguments on the text and all its copies.
---@param method string
---@param ... any the method's arguments
function GlowText:Set(method, ...) end

---One entry of ns.Locales, from a file in Locales\.
---@class PetCareButtonLocale
---@field strings table<string, string>

---What Settings.RegisterCanvasLayoutCategory returns; the language server's stubs leave it
---untyped.
---@class PetCareButtonSettingsCategory
---@field GetID fun(self: PetCareButtonSettingsCategory): string|number
