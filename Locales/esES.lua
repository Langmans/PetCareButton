local _, ns = ...

ns.Locales.esES = {
    strings = {
        TOAST_DEAD = "Tu mascota está muerta",
        TOAST_NOPET = "No tienes mascota",
        TOAST_LOW = "Tu mascota tiene un %d%% de salud",
        REASON_DEAD = "El botón lanza Revivir mascota ahora, también cuando el cuerpo ya no está.",
        REASON_NOPET = "El combate empezó sin tu mascota.",
        REASON_LOW = "El botón lanza Aliviar mascota mientras tu mascota vive.",
        REASON_LEARNED = "Llamar a mascota falló: el botón lanza Revivir mascota ahora.",
        REASON_LEARNED_COMBAT = "Llamar a mascota falló. En combate el botón no puede cambiar: "
            .. "mantén Mayús para Revivir mascota.",
        HINT_KEY = "Pulsa %s.",
        HINT_MACRO = "Pulsa tu macro /click PetCareButton (/pcb macro crea una).",

        REVIVE_FAILED = "Revivir mascota falló, así que no hay mascota muerta: el botón vuelve a lanzar Llamar a mascota.",

        STATUS = "Sin mascota el botón lanza %s. Avisos: mascota muerta %s, sin mascota al empezar %s, "
            .. "poca salud %s. Aviso durante %d s con tamaño %.2f, sonido %s, depuración %s. Comandos: %s",
        STATUS_ON = "activado",
        STATUS_OFF = "desactivado",
        MODE_REVIVE = "Revivir mascota",
        MODE_CALL = "Llamar a mascota",
        LOW_PERCENT = "al %d%%",
        SOUND_NAME_FAMILY = "sonidos de la mascota",
        SOUND_NAME_WARNING = "aviso de banda",
        NOT_HUNTER = "Solo los cazadores tienen Aliviar mascota, Revivir mascota y Llamar a mascota; "
            .. "el botón no hace nada con este personaje.",
        DIED_ON = "Un aviso cuando muere tu mascota.",
        DIED_OFF = "Sin aviso cuando muere tu mascota.",
        NOPET_ON = "Un aviso cuando el combate empieza sin mascota.",
        NOPET_OFF = "Sin aviso cuando el combate empieza sin mascota.",
        LOW_SET = "Un aviso cuando tu mascota baja al %d%% de salud.",
        LOW_OFF = "Sin aviso por poca salud.",
        MODE_SET_REVIVE = "Tu mascota cuenta como muerta: sin mascota el botón lanza Revivir mascota.",
        MODE_SET_CALL = "Tu mascota cuenta como viva: sin mascota el botón lanza Llamar a mascota.",
        IN_COMBAT = "No en combate; inténtalo de nuevo cuando termine.",
        MACRO_EXISTS = "Ya hay una macro llamada %s.",
        MACRO_FULL = "Tus macros de personaje y de cuenta están llenas.",
        MACRO_CREATED = "Macro %s creada para este personaje: arrástrala desde la ventana de macros (/macro) "
            .. "a una barra de acción.",
        MACRO_CREATED_ACCOUNT = "Macro %s creada entre las macros de cuenta, porque las de este personaje están "
            .. "llenas: arrástrala desde la ventana de macros (/macro) a una barra de acción.",
        SOUND_FAMILY = "Sonido: los de tu mascota: su sonido de muerte al morir, su grito de dolor con poca salud, "
            .. "si no su grito de ataque (el aviso de banda si no tiene).",
        SOUND_WARNING = "Sonido: el aviso de banda.",
        SOUND_OFF = "Sonido desactivado.",
        DURATION_SET = "Duración del aviso: %d segundos.",
        SCALE_SET = "Tamaño del aviso: %.2f.",
        POSITION_RESET = "Posición del aviso restablecida.",
        DEBUG_ON = "Depuración activada.",
        DEBUG_OFF = "Depuración desactivada.",
        OPTIONS_AFTER_COMBAT = "En combate: las opciones se abren cuando termine el combate.",

        BINDING_BUTTON = "Aliviar, revivir o llamar a la mascota",

        OPTION_ABOUT = "Versión %s de %s, licencia %s.",
        OPTION_WEBSITE = "Sitio web (Ctrl+C para copiar):",
        OPTION_DESCRIPTION = "Un botón para tu mascota: Aliviar mascota mientras vive, Revivir mascota cuando está "
            .. "muerta, Llamar a mascota cuando no está. Recuerda que tu mascota murió, también en combate y "
            .. "tras volver a conectar, así que ya no necesitas Mayús cuando el cuerpo desaparece. Mayús sigue "
            .. "forzando Revivir mascota, Ctrl fuerza Llamar a mascota.\n\n"
            .. "Púlsalo con el atajo (Esc > Opciones > Atajos de teclado > Accesorios) o con una macro con "
            .. "/click PetCareButton. Arrastra un aviso para moverlo, clic derecho para cerrarlo, pasa el "
            .. "ratón por encima para mantenerlo. Escribe /pcb para ver los comandos.",
        OPTION_SETTINGS = "Opciones",
        OPTION_DIED = "Aviso cuando muere mi mascota",
        OPTION_DIED_NOTE = "También cuando un Llamar a mascota fallido muestra que está muerta, y otra vez al "
            .. "empezar el combate. Igual que /pcb died on y off.",
        OPTION_NOPET = "Aviso cuando el combate empieza sin mascota",
        OPTION_NOPET_NOTE = "Igual que /pcb nopet on y off.",
        OPTION_SOUND = "Sonido",
        OPTION_SOUND_FAMILY = "Los sonidos de tu mascota: muerte, dolor, ataque (aviso de banda si no tiene)",
        OPTION_SOUND_WARNING = "El aviso de banda",
        OPTION_SOUND_OFF = "Sin sonido",
        OPTION_DEBUG = "Traza de depuración",
        OPTION_DEBUG_NOTE = "Escribe en el chat lo que el accesorio ve y decide. Igual que /pcb debug.",
        OPTION_LOW = "Aviso al %d%% de salud de la mascota",
        OPTION_LOW_OFF = "Sin aviso por poca salud de la mascota",
        OPTION_DURATION = "El aviso dura %d segundos",
        OPTION_SCALE = "Tamaño del aviso: %.2f",
        OPTION_MACRO = "Crear la macro",
        OPTION_TEST = "Mostrar un aviso",
    },
}

ns.Locales.esMX = ns.Locales.esES
