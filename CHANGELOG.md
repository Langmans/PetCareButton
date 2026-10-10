# Changelog

## 1.0.0 - not released yet

- One key (a key binding, or a macro with `/click PetCareButton`) for Mend
  Pet, Revive Pet and Call Pet. It remembers that your pet died, also in
  combat, once the body is gone and after a relog, so you no longer hold
  Shift. Shift still forces Revive Pet, Ctrl forces Call Pet.
- A failed Call Pet, or "Your pet is dead", switches the button to Revive
  Pet; a Revive Pet that fails at once switches it back.
- Toasts when your pet dies, when combat starts without a pet, and when its
  health drops to 40% (`/pcb low`), each naming the spell and the key.
- `/pcb macro` makes the macro for this character (account-wide only when the
  character macros are full). Its icon follows the button, also once a dead
  pet's body is gone; after a death in combat it catches up when combat ends.
- `/pcb revive` and `/pcb call` set the button by hand.
- Options panel under Esc > Options > AddOns with all settings; `/pcb` lists
  the commands.
- English, German, French, Spanish, Korean and Russian.
