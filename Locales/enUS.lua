local _, ns = ...

-- The fallback locale: every other locale falls back to these strings (see Locale.lua). This file
-- loads first, so it also creates the table the other locale files add themselves to.
-- Slash commands stay English in every locale; spell names come from the client and need nothing
-- here.
ns.Locales = {}
ns.Locales.enUS = {
    strings = {
        CHAT_PREFIX = "Pet Care Button:",

        -- The toast. TOAST_LOW gets the pet's health in percent; HINT_KEY the key binding.
        TOAST_DEAD = "Your pet is dead",
        TOAST_NOPET = "You have no pet out",
        TOAST_LOW = "Your pet is at %d%% health",
        REASON_DEAD = "The button casts Revive Pet now, also once the body is gone.",
        REASON_NOPET = "Combat started without your pet.",
        REASON_LOW = "The button casts Mend Pet while your pet lives.",
        REASON_LEARNED = "Call Pet failed: the button casts Revive Pet now.",
        REASON_LEARNED_COMBAT = "Call Pet failed. In combat the button cannot switch: hold Shift for Revive Pet.",
        HINT_KEY = "Press %s.",
        HINT_MACRO = "Press your /click PetCareButton macro (/pcb macro makes one).",

        -- Chat.
        REVIVE_FAILED = "Revive Pet failed, so there is no dead pet: the button casts Call Pet again.",

        -- /pcb. STATUS: what the button does without a pet (a MODE_*), the dead and no-pet toasts
        -- on/off, the low-health line (LOW_PERCENT or STATUS_OFF), the toast's duration in seconds
        -- and scale, sound (a SOUND_NAME_* or STATUS_OFF), debug on/off, the command list.
        STATUS = "Without a pet the button casts %s. Toasts: pet died %s, no pet at the pull %s, low health %s. "
            .. "Toast for %d s at scale %.2f, sound %s, debug %s. Commands: %s",
        STATUS_ON = "on",
        STATUS_OFF = "off",
        MODE_REVIVE = "Revive Pet",
        MODE_CALL = "Call Pet",
        LOW_PERCENT = "at %d%%",
        SOUND_NAME_FAMILY = "pet's call",
        SOUND_NAME_WARNING = "raid warning",
        NOT_HUNTER = "Only hunters have Mend Pet, Revive Pet and Call Pet; the button does nothing on this character.",
        DIED_ON = "A toast when your pet dies.",
        DIED_OFF = "No toast when your pet dies.",
        NOPET_ON = "A toast when combat starts without a pet.",
        NOPET_OFF = "No toast when combat starts without a pet.",
        LOW_SET = "A toast when your pet drops to %d%% health.",
        LOW_OFF = "No toast for low health.",
        MODE_SET_REVIVE = "Your pet counts as dead: without a pet the button casts Revive Pet.",
        MODE_SET_CALL = "Your pet counts as alive: without a pet the button casts Call Pet.",
        IN_COMBAT = "Not in combat; try again when it ends.",
        MACRO_EXISTS = "There is a macro named %s already.",
        MACRO_FULL = "Your character macros and account-wide macros are both full.",
        MACRO_CREATED = "Macro %s made for this character: drag it from the macro window (/macro) onto an action bar.",
        MACRO_CREATED_ACCOUNT = "Macro %s made among the account-wide macros, since this character's are full: "
            .. "drag it from the macro window (/macro) onto an action bar.",
        SOUND_FAMILY = "Sound: your pet's call, as when you send it to attack (the raid warning when it has none).",
        SOUND_WARNING = "Sound: the raid warning.",
        SOUND_OFF = "Sound off.",
        DURATION_SET = "Toast duration: %d seconds.",
        SCALE_SET = "Toast scale: %.2f.",
        POSITION_RESET = "Toast position reset.",
        DEBUG_ON = "Debug on.",
        DEBUG_OFF = "Debug off.",
        OPTIONS_AFTER_COMBAT = "In combat: the options open when combat ends.",

        -- Esc > Options > Keybindings.
        BINDING_BUTTON = "Mend, revive or call pet",

        -- The options panel (Options.lua).
        OPTIONS_TITLE = "Pet Care Button",
        -- Version, author and license from the .toc.
        OPTION_ABOUT = "Version %s by %s, %s license.",
        OPTION_WEBSITE = "Website (Ctrl+C to copy):",
        OPTION_DESCRIPTION = "One button for your pet: Mend Pet while it lives, Revive Pet when it is dead, "
            .. "Call Pet when it is not out. It remembers that your pet died, also in combat and after a "
            .. "relog, so you no longer need Shift once the body is gone. Shift still forces Revive Pet, "
            .. "Ctrl forces Call Pet.\n\n"
            .. "Press it with the key binding (Esc > Options > Keybindings > AddOns) or with a macro "
            .. "holding /click PetCareButton. Drag a toast to move it, right-click to close it, hover "
            .. "to keep it up. Type /pcb for the commands.",
        OPTION_SETTINGS = "Settings",
        OPTION_DIED = "Toast when my pet dies",
        OPTION_DIED_NOTE = "Also when a failed Call Pet shows that it is dead, and again at the pull. "
            .. "Same as /pcb died on and off.",
        OPTION_NOPET = "Toast when combat starts without a pet",
        OPTION_NOPET_NOTE = "Same as /pcb nopet on and off.",
        OPTION_SOUND = "Sound",
        OPTION_SOUND_FAMILY = "Your pet's call, as when you send it to attack (raid warning when it has none)",
        OPTION_SOUND_WARNING = "The raid warning",
        OPTION_SOUND_OFF = "No sound",
        OPTION_DEBUG = "Debug trace",
        OPTION_DEBUG_NOTE = "Print in chat what the addon sees and decides. Same as /pcb debug.",
        -- Slider titles: a whole percentage, whole seconds, a size like 1.25.
        OPTION_LOW = "Toast at %d%% pet health",
        OPTION_LOW_OFF = "No toast for low pet health",
        OPTION_DURATION = "Toast stays for %d seconds",
        OPTION_SCALE = "Toast size: %.2f",
        OPTION_MACRO = "Make the macro",
        OPTION_TEST = "Show a toast",
    },
}
