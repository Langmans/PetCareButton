local _, ns = ...

ns.Locales.koKR = {
    strings = {
        TOAST_DEAD = "소환수가 죽었습니다",
        TOAST_NOPET = "소환수가 없습니다",
        TOAST_LOW = "소환수 생명력 %d%%",
        REASON_DEAD = "이제 버튼이 동물 되살리기를 시전합니다. 시체가 사라진 뒤에도 마찬가지입니다.",
        REASON_NOPET = "소환수 없이 전투가 시작되었습니다.",
        REASON_LOW = "소환수가 살아 있는 동안 버튼이 동물 치료를 시전합니다.",
        REASON_LEARNED = "야수 부르기 실패: 이제 버튼이 동물 되살리기를 시전합니다.",
        REASON_LEARNED_COMBAT = "야수 부르기 실패. 전투 중에는 버튼을 바꿀 수 없습니다: "
            .. "Shift를 누른 채로 동물 되살리기를 쓰세요.",
        HINT_KEY = "%s 키를 누르세요.",
        HINT_MACRO = "/click PetCareButton 매크로를 누르세요 (/pcb macro로 만들 수 있습니다).",

        REVIVE_FAILED = "동물 되살리기 실패, 죽은 소환수가 없습니다: 버튼이 다시 야수 부르기를 시전합니다.",

        STATUS = "소환수가 없으면 버튼이 %s 시전. 알림: 소환수 죽음 %s, 전투 시작 시 소환수 없음 %s, "
            .. "낮은 생명력 %s. 알림 %d초, 크기 %.2f, 소리 %s, 디버그 %s. 명령어: %s",
        STATUS_ON = "켜짐",
        STATUS_OFF = "꺼짐",
        MODE_REVIVE = "동물 되살리기",
        MODE_CALL = "야수 부르기",
        LOW_PERCENT = "%d%%",
        SOUND_NAME_FAMILY = "소환수 울음소리",
        SOUND_NAME_WARNING = "공격대 경보",
        NOT_HUNTER = "동물 치료, 동물 되살리기, 야수 부르기는 사냥꾼만 가지고 있습니다. "
            .. "이 캐릭터에서는 버튼이 아무것도 하지 않습니다.",
        DIED_ON = "소환수가 죽으면 알림.",
        DIED_OFF = "소환수가 죽어도 알림 없음.",
        NOPET_ON = "소환수 없이 전투가 시작되면 알림.",
        NOPET_OFF = "소환수 없이 전투가 시작되어도 알림 없음.",
        LOW_SET = "소환수 생명력이 %d%%로 떨어지면 알림.",
        LOW_OFF = "낮은 생명력 알림 없음.",
        MODE_SET_REVIVE = "소환수를 죽은 것으로 봅니다: 소환수가 없으면 버튼이 동물 되살리기를 시전합니다.",
        MODE_SET_CALL = "소환수를 살아 있는 것으로 봅니다: 소환수가 없으면 버튼이 야수 부르기를 시전합니다.",
        IN_COMBAT = "전투 중에는 안 됩니다. 전투가 끝나면 다시 시도하세요.",
        MACRO_EXISTS = "%s 이름의 매크로가 이미 있습니다.",
        MACRO_FULL = "캐릭터 전용 매크로와 계정 공용 매크로가 모두 가득 찼습니다.",
        MACRO_CREATED = "이 캐릭터용 %s 매크로를 만들었습니다: 매크로 창(/macro)에서 행동 단축바로 끌어 놓으세요.",
        MACRO_CREATED_ACCOUNT = "이 캐릭터의 매크로가 가득 차서 계정 공용 매크로에 %s 매크로를 만들었습니다: "
            .. "매크로 창(/macro)에서 행동 단축바로 끌어 놓으세요.",
        SOUND_FAMILY = "소리: 공격 명령 때처럼 소환수의 울음소리 (없으면 공격대 경보).",
        SOUND_WARNING = "소리: 공격대 경보.",
        SOUND_OFF = "소리 꺼짐.",
        DURATION_SET = "알림 시간: %d초.",
        SCALE_SET = "알림 크기: %.2f.",
        POSITION_RESET = "알림 위치를 초기화했습니다.",
        DEBUG_ON = "디버그 켜짐.",
        DEBUG_OFF = "디버그 꺼짐.",
        OPTIONS_AFTER_COMBAT = "전투 중: 전투가 끝나면 설정이 열립니다.",

        BINDING_BUTTON = "소환수 치료, 되살리기 또는 부르기",

        OPTION_ABOUT = "버전 %s, 제작 %s, %s 라이선스.",
        OPTION_WEBSITE = "웹사이트 (Ctrl+C로 복사):",
        OPTION_DESCRIPTION = "소환수를 위한 버튼 하나: 살아 있으면 동물 치료, 죽었으면 동물 되살리기, 없으면 "
            .. "야수 부르기. 소환수가 죽었다는 것을 전투 중에도, 다시 접속한 뒤에도 기억하므로 시체가 "
            .. "사라진 뒤에 Shift가 더 이상 필요 없습니다. Shift는 여전히 동물 되살리기를, Ctrl은 야수 "
            .. "부르기를 강제합니다.\n\n"
            .. "단축키(Esc > 설정 > 단축키 > 애드온)나 /click PetCareButton 매크로로 누르세요. 알림을 끌어서 "
            .. "옮기고, 오른쪽 클릭으로 닫고, 마우스를 올려 유지할 수 있습니다. 명령어는 /pcb를 입력하세요.",
        OPTION_SETTINGS = "설정",
        OPTION_DIED = "소환수가 죽으면 알림",
        OPTION_DIED_NOTE = "실패한 야수 부르기로 죽은 것이 드러날 때와 전투 시작 때도 알립니다. "
            .. "/pcb died on, off와 같습니다.",
        OPTION_NOPET = "소환수 없이 전투가 시작되면 알림",
        OPTION_NOPET_NOTE = "/pcb nopet on, off와 같습니다.",
        OPTION_SOUND = "소리",
        OPTION_SOUND_FAMILY = "공격 명령 때처럼 소환수의 울음소리 (없으면 공격대 경보)",
        OPTION_SOUND_WARNING = "공격대 경보",
        OPTION_SOUND_OFF = "소리 없음",
        OPTION_DEBUG = "디버그 기록",
        OPTION_DEBUG_NOTE = "애드온이 보고 결정하는 것을 대화창에 출력합니다. /pcb debug와 같습니다.",
        OPTION_LOW = "소환수 생명력 %d%%에서 알림",
        OPTION_LOW_OFF = "낮은 소환수 생명력 알림 없음",
        OPTION_DURATION = "알림 유지 시간 %d초",
        OPTION_SCALE = "알림 크기: %.2f",
        OPTION_MACRO = "매크로 만들기",
        OPTION_TEST = "알림 보기",
    },
}
