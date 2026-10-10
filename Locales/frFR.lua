local _, ns = ...

ns.Locales.frFR = {
    strings = {
        TOAST_DEAD = "Votre familier est mort",
        TOAST_NOPET = "Vous n'avez pas de familier",
        TOAST_LOW = "Votre familier est à %d%% de vie",
        REASON_DEAD = "Le bouton lance Ressusciter le familier, même quand le corps a disparu.",
        REASON_NOPET = "Le combat a commencé sans votre familier.",
        REASON_LOW = "Le bouton lance Guérison du familier tant que votre familier vit.",
        REASON_LEARNED = "Appel du familier a échoué : le bouton lance Ressusciter le familier.",
        REASON_LEARNED_COMBAT = "Appel du familier a échoué. En combat le bouton ne peut pas changer : "
            .. "maintenez Maj pour Ressusciter le familier.",
        HINT_KEY = "Appuyez sur %s.",
        HINT_MACRO = "Utilisez votre macro /click PetCareButton (/pcb macro en crée une).",

        REVIVE_FAILED = "Ressusciter le familier a échoué, il n'y a donc pas de familier mort : "
            .. "le bouton lance de nouveau Appel du familier.",

        STATUS = "Sans familier, le bouton lance %s. Alertes : familier mort %s, pas de familier au combat %s, "
            .. "vie basse %s. Alerte pendant %d s à l'échelle %.2f, son %s, débogage %s. Commandes : %s",
        STATUS_ON = "activé",
        STATUS_OFF = "désactivé",
        MODE_REVIVE = "Ressusciter le familier",
        MODE_CALL = "Appel du familier",
        LOW_PERCENT = "à %d%%",
        SOUND_NAME_FAMILY = "cris du familier",
        SOUND_NAME_WARNING = "avertissement de raid",
        NOT_HUNTER = "Seuls les chasseurs ont Guérison, Ressusciter et Appel du familier ; "
            .. "le bouton ne fait rien sur ce personnage.",
        DIED_ON = "Une alerte quand votre familier meurt.",
        DIED_OFF = "Pas d'alerte quand votre familier meurt.",
        NOPET_ON = "Une alerte quand le combat commence sans familier.",
        NOPET_OFF = "Pas d'alerte quand le combat commence sans familier.",
        LOW_SET = "Une alerte quand votre familier tombe à %d%% de vie.",
        LOW_OFF = "Pas d'alerte de vie basse.",
        MODE_SET_REVIVE = "Votre familier compte comme mort : sans familier, le bouton lance Ressusciter le familier.",
        MODE_SET_CALL = "Votre familier compte comme vivant : sans familier, le bouton lance Appel du familier.",
        IN_COMBAT = "Pas en combat ; réessayez à la fin du combat.",
        MACRO_EXISTS = "Une macro nommée %s existe déjà.",
        MACRO_FULL = "Vos macros de personnage et de compte sont pleines.",
        MACRO_CREATED = "Macro %s créée pour ce personnage : faites-la glisser de la fenêtre des macros (/macro) "
            .. "vers une barre d'action.",
        MACRO_CREATED_ACCOUNT = "Macro %s créée parmi les macros de compte, celles de ce personnage étant pleines : "
            .. "faites-la glisser de la fenêtre des macros (/macro) vers une barre d'action.",
        SOUND_FAMILY = "Son : ceux de votre familier : son cri de mort quand il meurt, son cri de douleur quand sa vie "
            .. "est basse, sinon son cri d'attaque (l'avertissement de raid s'il n'en a pas).",
        SOUND_WARNING = "Son : l'avertissement de raid.",
        SOUND_OFF = "Son désactivé.",
        DURATION_SET = "Durée de l'alerte : %d secondes.",
        SCALE_SET = "Taille de l'alerte : %.2f.",
        POSITION_RESET = "Position de l'alerte réinitialisée.",
        DEBUG_ON = "Débogage activé.",
        DEBUG_OFF = "Débogage désactivé.",
        OPTIONS_AFTER_COMBAT = "En combat : les options s'ouvriront à la fin du combat.",

        BINDING_BUTTON = "Soigner, ressusciter ou appeler le familier",

        OPTION_ABOUT = "Version %s par %s, licence %s.",
        OPTION_WEBSITE = "Site web (Ctrl+C pour copier) :",
        OPTION_DESCRIPTION = "Un seul bouton pour votre familier : Guérison du familier tant qu'il vit, Ressusciter "
            .. "le familier quand il est mort, Appel du familier quand il n'est pas là. Il retient que votre "
            .. "familier est mort, même en combat et après une reconnexion : plus besoin de Maj quand le corps "
            .. "a disparu. Maj force toujours Ressusciter le familier, Ctrl force Appel du familier.\n\n"
            .. "Utilisez-le avec le raccourci (Échap > Options > Raccourcis > AddOns) ou avec une macro "
            .. "contenant /click PetCareButton. Faites glisser une alerte pour la déplacer, clic droit pour la "
            .. "fermer, survolez-la pour la garder. Tapez /pcb pour les commandes.",
        OPTION_SETTINGS = "Réglages",
        OPTION_DIED = "Alerte quand mon familier meurt",
        OPTION_DIED_NOTE = "Aussi quand un Appel du familier échoué montre qu'il est mort, et de nouveau au début du "
            .. "combat. Comme /pcb died on et off.",
        OPTION_NOPET = "Alerte quand le combat commence sans familier",
        OPTION_NOPET_NOTE = "Comme /pcb nopet on et off.",
        OPTION_SOUND = "Son",
        OPTION_SOUND_FAMILY = "Les cris de votre familier : mort, douleur, attaque (avertissement de raid s'il n'en a pas)",
        OPTION_SOUND_WARNING = "L'avertissement de raid",
        OPTION_SOUND_OFF = "Pas de son",
        OPTION_DEBUG = "Trace de débogage",
        OPTION_DEBUG_NOTE = "Écrit dans le chat ce que l'addon voit et décide. Comme /pcb debug.",
        OPTION_LOW = "Alerte à %d%% de vie du familier",
        OPTION_LOW_OFF = "Pas d'alerte de vie basse du familier",
        OPTION_DURATION = "L'alerte reste %d secondes",
        OPTION_SCALE = "Taille de l'alerte : %.2f",
        OPTION_MACRO = "Créer la macro",
        OPTION_TEST = "Afficher une alerte",
    },
}
