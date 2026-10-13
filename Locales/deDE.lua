local _, ns = ...

ns.Locales.deDE = {
    strings = {
        TOAST_DEAD = "Dein Begleiter ist tot",
        TOAST_NOPET = "Du hast keinen Begleiter dabei",
        TOAST_LOW = "Dein Begleiter hat %d%% Gesundheit",
        REASON_DEAD = "Die Taste wirkt jetzt Tier wiederbeleben, auch wenn der Körper verschwunden ist.",
        REASON_NOPET = "Der Kampf hat ohne deinen Begleiter begonnen.",
        REASON_LOW = "Die Taste wirkt Tier heilen, solange dein Begleiter lebt.",
        REASON_LEARNED = "Tier rufen ist fehlgeschlagen: die Taste wirkt jetzt Tier wiederbeleben.",
        REASON_LEARNED_COMBAT = "Tier rufen ist fehlgeschlagen. Im Kampf kann die Taste nicht umschalten: "
            .. "halte Umschalt für Tier wiederbeleben.",
        HINT_KEY = "Drücke %s.",
        HINT_MACRO = "Drücke dein PetCare-Makro (/pcb macro erstellt eins).",

        REVIVE_FAILED = "Tier wiederbeleben ist fehlgeschlagen, es gibt also keinen toten Begleiter: "
            .. "die Taste wirkt wieder Tier rufen.",

        STATUS = "Ohne Begleiter wirkt die Taste %s. Anzeigen: Begleiter tot %s, kein Begleiter beim Pull %s, "
            .. "wenig Gesundheit %s. Anzeige für %d s mit Größe %.2f, Ton %s, Debug %s. Befehle: %s",
        STATUS_ON = "an",
        STATUS_OFF = "aus",
        MODE_REVIVE = "Tier wiederbeleben",
        MODE_CALL = "Tier rufen",
        LOW_PERCENT = "bei %d%%",
        SOUND_NAME_FAMILY = "Laute des Begleiters",
        SOUND_NAME_WARNING = "Schlachtzugswarnung",
        NOT_HUNTER = "Nur Jäger haben Tier heilen, Tier wiederbeleben und Tier rufen; "
            .. "auf diesem Charakter tut die Taste nichts.",
        DIED_ON = "Eine Anzeige, wenn dein Begleiter stirbt.",
        DIED_OFF = "Keine Anzeige, wenn dein Begleiter stirbt.",
        NOPET_ON = "Eine Anzeige, wenn der Kampf ohne Begleiter beginnt.",
        NOPET_OFF = "Keine Anzeige, wenn der Kampf ohne Begleiter beginnt.",
        LOW_SET = "Eine Anzeige, wenn dein Begleiter auf %d%% Gesundheit fällt.",
        LOW_OFF = "Keine Anzeige bei wenig Gesundheit.",
        MODE_SET_REVIVE = "Dein Begleiter gilt als tot: ohne Begleiter wirkt die Taste Tier wiederbeleben.",
        MODE_SET_CALL = "Dein Begleiter gilt als lebendig: ohne Begleiter wirkt die Taste Tier rufen.",
        IN_COMBAT = "Nicht im Kampf; versuche es nach dem Kampf erneut.",
        MACRO_EXISTS = "Es gibt schon ein Makro namens %s.",
        MACRO_FULL = "Deine charakterspezifischen und accountweiten Makros sind beide voll.",
        MACRO_CREATED = "Makro %s für diesen Charakter erstellt: zieh es aus dem Makrofenster (/macro) "
            .. "auf eine Aktionsleiste.",
        MACRO_CREATED_ACCOUNT = "Makro %s bei den accountweiten Makros erstellt, da die dieses Charakters voll "
            .. "sind: zieh es aus dem Makrofenster (/macro) auf eine Aktionsleiste.",
        SOUND_FAMILY = "Ton: die Laute deines Begleiters: sein Todeslaut, wenn er stirbt, sein Schmerzensschrei bei "
            .. "wenig Gesundheit, sonst sein Angriffsruf (ohne einen die Schlachtzugswarnung).",
        SOUND_WARNING = "Ton: die Schlachtzugswarnung.",
        SOUND_OFF = "Ton aus.",
        DURATION_SET = "Anzeigedauer: %d Sekunden.",
        SCALE_SET = "Anzeigegröße: %.2f.",
        POSITION_RESET = "Position der Anzeige zurückgesetzt.",
        DEBUG_ON = "Debug an.",
        DEBUG_OFF = "Debug aus.",
        OPTIONS_AFTER_COMBAT = "Im Kampf: die Optionen öffnen sich, wenn der Kampf endet.",

        BINDING_BUTTON = "Begleiter heilen, wiederbeleben oder rufen",

        OPTION_ABOUT = "Version %s von %s, Lizenz %s.",
        OPTION_WEBSITE = "Webseite (Strg+C zum Kopieren):",
        OPTION_DESCRIPTION = "Eine Taste für deinen Begleiter: Tier heilen, solange er lebt, Tier wiederbeleben, "
            .. "wenn er tot ist, Tier rufen, wenn er nicht da ist. Sie merkt sich, dass dein Begleiter "
            .. "gestorben ist, auch im Kampf und nach einem Relog, also brauchst du kein Umschalt mehr, wenn "
            .. "der Körper weg ist. Umschalt erzwingt weiterhin Tier wiederbeleben, Strg Tier rufen.\n\n"
            .. "Drück sie mit der Tastenbelegung (Esc > Optionen > Tastaturbelegung > AddOns) oder mit einem "
            .. "Makro von /pcb macro. Zieh eine Anzeige, um sie zu verschieben, Rechtsklick schließt "
            .. "sie, mit der Maus darüber bleibt sie stehen. Gib /pcb für die Befehle ein.",
        OPTION_SETTINGS = "Einstellungen",
        OPTION_DIED = "Anzeige, wenn mein Begleiter stirbt",
        OPTION_DIED_NOTE = "Auch wenn ein fehlgeschlagenes Tier rufen zeigt, dass er tot ist, und erneut beim Pull. "
            .. "Wie /pcb died on und off.",
        OPTION_NOPET = "Anzeige, wenn der Kampf ohne Begleiter beginnt",
        OPTION_NOPET_NOTE = "Wie /pcb nopet on und off.",
        OPTION_SOUND = "Ton",
        OPTION_SOUND_FAMILY = "Die Laute deines Begleiters: Todeslaut, Schmerzensschrei, Angriffsruf "
            .. "(ohne einen die Schlachtzugswarnung)",
        OPTION_SOUND_WARNING = "Die Schlachtzugswarnung",
        OPTION_SOUND_OFF = "Kein Ton",
        OPTION_DEBUG = "Debug-Ausgabe",
        OPTION_DEBUG_NOTE = "Schreibt in den Chat, was das Addon sieht und entscheidet. Wie /pcb debug.",
        OPTION_LOW = "Anzeige bei %d%% Gesundheit des Begleiters",
        OPTION_LOW_OFF = "Keine Anzeige bei wenig Gesundheit",
        OPTION_DURATION = "Anzeige bleibt %d Sekunden",
        OPTION_SCALE = "Anzeigegröße: %.2f",
        OPTION_MACRO = "Makro erstellen",
        OPTION_TEST = "Anzeige zeigen",
    },
}
