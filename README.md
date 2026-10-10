# Pet Care Button

One key for your hunter pet: **Mend Pet** while it lives, **Revive Pet**
when it is dead, **Call Pet** when it is not out. The usual macro for this
is

```
#showtooltip
/cast [mod:shift][@pet,dead] Revive Pet; [@pet,nodead] Mend Pet; Call Pet
```

and it has one hole: once your dead pet's body is gone, the game no longer
sees a dead pet, the macro picks Call Pet, and you get "Your pet is dead".
So you hold Shift. This addon's button remembers that your pet died, also
in combat and after a relog, and casts Revive Pet until your pet lives
again.

It also shows a toast, in the style of
[Pet Autocast Check](https://github.com/Langmans/PetAutocastCheck), when:

- **your pet dies** (and again at the pull while it is still dead);
- **combat starts without a pet**;
- **your pet's health drops** to 40% (adjustable, or off).

Each toast names the spell the button will cast and the key to press, and
goes away by itself once that is solved.

## Using it

Pick one:

- **A key binding**: Esc > Options > Keybindings > AddOns > Pet Care Button
  > "Mend, revive or call pet".
- **A macro** on your action bar: the first time you log in on a hunter, the
  addon makes one named `PetCare` for that character (among the account-wide
  macros only when the character's are full). Drag it from the macro window
  (`/macro`) onto a bar. It is made only that once: delete it and it stays
  gone, and `/pcb macro` makes it again. It holds:

  ```
  #showtooltip [@pet,dead] Revive Pet; [nopet] Call Pet; Mend Pet
  /click PetCareButton
  ```

  Its icon follows the button: while your pet counts as dead the first line
  becomes `#showtooltip [@pet,exists,nodead] Mend Pet; Revive Pet`, so it
  shows Revive Pet also once the body is gone. The addon rewrites only that
  first line, outside combat; lines you add below it stay, and if you remove
  the `#showtooltip` line the addon leaves the macro alone. If your pet dies
  in combat, the icon catches up when combat ends (the button itself is
  right all along).

Shift still forces Revive Pet and Ctrl forces Call Pet, for the rare case
the button is wrong in combat (see below).

### When the button learns your pet is dead

- It sees your pet die: from then on, without a living pet, it casts Revive
  Pet. That works in combat too.
- Call Pet fails, or the game says "Your pet is dead": the pet died where
  the button could not see it (logged out, out of range). Outside combat the
  button switches to Revive Pet at once. In combat it cannot switch (no addon
  can change a button in combat); the toast says to hold Shift, and the
  switch follows when combat ends.
- Revive Pet fails straight away (not interrupted): there is no dead pet,
  so it goes back to Call Pet.
- `/pcb revive` and `/pcb call` set it by hand.

## Install

By hand:

1. Download the zip from
   [GitHub](https://github.com/Langmans/PetCareButton) (Code > Download
   ZIP).
2. Unzip it into your WoW client's `Interface\AddOns` and rename the folder
   to `PetCareButton`, so that you get
   `Interface\AddOns\PetCareButton\PetCareButton.toc`.
3. Restart the game, or `/reload` if it was running, and check that
   "PetCareButton" is enabled in the AddOns list on the character screen.

Made for WoW: Forever (1.60).

## Settings

Open the panel with `/pcb config`, or through Esc > Options > AddOns > Pet
Care Button. It has checkboxes for the dead and no-pet toasts, sliders for
the low-health line, how long a toast stays and how big it is, the sound,
a debug trace, and buttons to make the macro and show a test toast.

The settings are saved for the whole account; whether your pet counts as
dead is saved per character. The same settings are chat commands too
(`/petcarebutton` works as well):

- `/pcb` shows what the button does now, the settings and the commands.
- `/pcb config` (or `/pcb options`) opens the panel.
- `/pcb macro` makes the `PetCare` macro for this character again (outside
  combat).
- `/pcb revive` / `/pcb call`: without a pet, cast Revive Pet / Call Pet
  (outside combat).
- `/pcb died on|off` and `/pcb nopet on|off` switch those toasts.
- `/pcb low <0-90>` sets the health percentage for the Mend Pet toast; 0
  switches it off (default 40).
- `/pcb test [dead|nopet|low]` shows that toast. Nothing else happens.
- `/pcb duration <seconds>` (default 6) and `/pcb scale <0.3-3>` (default
  1).
- `/pcb sound family|warning|off`: your pet's call (default), the raid
  warning, or nothing. The dead-pet toast plays the raid warning with
  `family` too; its attack call would be out of place.
- `/pcb reset` puts the toast back in its standard spot.
- `/pcb debug` switches the debug trace on or off.

The toast stays for 6 seconds, then fades. Hover over it to keep it up,
right-click to close it, drag it to move it.

## Languages

The toasts, the panel and the chat messages follow your game's language:
English, German, French, Spanish, Korean and Russian. Other languages get
English. Spell names in the macro and on the toasts come from the game
itself. Commands and the debug trace are English.

## Reporting a problem

If the button casts the wrong spell, or a toast is wrong:

1. Type `/pcb debug`.
2. Do what went wrong again.
3. Copy the chat lines into an
   [issue on GitHub](https://github.com/Langmans/PetCareButton/issues).

## License

MIT, see [LICENSE](https://github.com/Langmans/PetCareButton/blob/main/LICENSE).

---

## Technical documentation

The rest of this file is for people who want to change the addon.

### Files

In `.toc` order; all share the addon namespace `ns`.

- `Locales\*.lua` — one file per locale with its `strings`. `enUS.lua` loads
  first and creates `ns.Locales`.
- `Locale.lua` — picks the client's locale; `ns.L`, `ns.Format`.
- `Core.lua` — the saved settings (`ns.DEFAULTS`, `ns.db`, `ns.char`,
  `ns.LoadSettings`, `ns.StripDefaults`), `ns.Print`, `ns.Debug`,
  `ns.Readable`, and the lookups that differ between clients: `ns.SpellInfo`
  and `ns.PetFamilyID`.
- `Toast.lua` — the toast frame (`ns.ShowToast`, `ns.DropToast`,
  `ns.HideToast`), the same as Pet Autocast Check's.
- `Button.lua` — the secure button `PetCareButton` and its header
  (`ns.SetupButton`, `ns.SetPetDead`, `ns.PetDead`, `ns.MacroText`), and the
  key binding's names.
- `Macro.lua` — the `PetCare` macro: `ns.TooltipLine`, `ns.MacroBody`,
  `ns.UpdatedBody`, `ns.CreatePetMacro` and `ns.UpdateMacro`, which keeps
  its `#showtooltip` line in step with the button.
- `Alerts.lua` — the toasts (`ns.AlertToast`, `ns.CheckHealth`), learning
  from failed casts, and the event frame (one method per event).
- `Commands.lua` — `/pcb`: one function per subcommand in a `Commands`
  table; anything unknown shows the status line.
- `Options.lua` — the panel in the game's settings (`ns.OpenOptions`).
- `Bindings.xml` — the `CLICK PetCareButton:LeftButton` binding. The client
  loads it from the addon folder by itself; it is not in the `.toc`.
- `annotations\` — editor-only types (`---@meta`). Not in the `.toc`;
  `.wowluarc.json` gives the folder to WoW Lua LS as a library, and
  `.pkgmeta` leaves it out of the zip.

Saved: `PetCareButtonDB` (account) holds `duration`, `scale`, `sound`,
`died`, `nopet`, `low`, `debug` and `pos`, only where they differ from the
default. `PetCareButtonCharDB` (character) holds `petDead` and `macroMade`.

### How the button works

An addon cannot cast, and in combat it cannot change a secure button. The
choice is therefore made entirely by secure code:

- `PetCareButton` is a `SecureActionButtonTemplate` button of type `macro`.
  Its `macrotext` is one of two texts, both built from the client's spell
  names (`ns.MacroText`):
  - pet not known dead:
    `/cast [mod:shift][@pet,dead] Revive Pet; [mod:ctrl][nopet] Call Pet; Mend Pet`
  - pet known dead:
    `/cast [mod:ctrl] Call Pet; [mod:shift][@pet,dead][nopet] Revive Pet; Mend Pet`
- A `SecureHandlerStateTemplate` header carries the state driver
  `[@pet,dead] dead; [@pet,exists] alive; none`. Its `_onstate-pet` snippet
  sets the header's `petdead` attribute on `dead`, clears it on `alive`, and
  leaves it on `none` (no pet unit), then runs the `apply` snippet, which
  copies the matching text onto the button through a frame ref. All of this
  runs in combat.
- Outside combat, `ns.SetPetDead` sets `petdead` and runs `apply`; this is
  how the saved value, failed casts and `/pcb revive|call` reach the button.
- A hook on the header's `OnAttributeChanged` mirrors `petdead` into
  `PetCareButtonCharDB` (also when a snippet set it in combat), and another
  feeds `state-pet` to the toasts.
- The button is registered for `AnyUp` and `AnyDown` with `useOnKeyDown`
  false, so it acts on the release: a `/click` from a macro arrives as a
  release, and with `ActionButtonUseKeyDown` on a button waiting for the
  press would never fire from a macro.
- Everything that touches the secure frames happens in `ns.SetupButton`, on
  `ADDON_LOADED`, or after combat when the addon loaded in combat.

### How the macro keeps up

- `ns.CreatePetMacro` makes the macro per character while
  `GetNumMacros()`'s character count is under `MAX_CHARACTER_MACROS` (from
  `Constants.MacroConsts`, 30 on Forever; 18 when the client has no such
  constant), otherwise account-wide while there is room.
- Made by itself on the first `UPDATE_MACROS` outside combat (the client
  fires it once the macros are loaded) while `PetCareButtonCharDB.macroMade`
  is unset; any outcome sets it, so it happens once per character.
- `ns.UpdateMacro` reads the body with `GetMacroInfo`, and when its first
  line starts with `#showtooltip` (any case) puts `ns.TooltipLine` for
  `ns.PetDead()` in its place (`ns.UpdatedBody`), keeping the rest. A changed
  body is written with `EditMacro(index, nil, nil, body)`. It runs on every
  `petdead` change (a hook on the header) and on `UPDATE_MACROS`; in combat
  it registers `PLAYER_REGEN_ENABLED` and runs then. The body comparison
  keeps the `UPDATE_MACROS` from its own edit from doing anything.
- Only hunters register `UPDATE_MACROS` (`ns.StartMacro` on `ADDON_LOADED`),
  so another class never makes or rewrites a shared account macro.

### How the alerts work

- `dead` toasts when the driver reports `dead`, and at
  `PLAYER_REGEN_DISABLED` while no pet is out and the pet counts as dead.
- `nopet` toasts at `PLAYER_REGEN_DISABLED` without a pet otherwise.
- `low` follows `UNIT_HEALTH`/`UNIT_MAXHEALTH` for the pet: it toasts at or
  under `low` percent, once, and again only after the health went back
  above. A value `canaccessvalue` refuses (Forever hides some values in
  combat) decides nothing.
- A living pet (`alive`) takes away `dead` and `nopet`.
- The `dead` toast carries `sound = "warning"`, so `Toast.lua` plays the raid
  warning (SoundKit 8959) instead of the family's aggro sound, unless sound
  is off.
- Failed casts: `UNIT_SPELLCAST_FAILED` for Call Pet (883) without a pet and
  not mounted, or a `UI_ERROR_MESSAGE` equal to `ERR_PET_SPELL_DEAD` or
  `PETTAME_DEAD`, marks the pet dead. `UNIT_SPELLCAST_FAILED` for Revive Pet
  (982) whose cast GUID never had a `UNIT_SPELLCAST_START` marks it alive.
  Without a pet, every other error message goes to the debug trace, so an
  unknown name for the "pet is dead" text can be found.

### Development

Needs Node.js. `npm install` once, then:

- `npm test` — runs `tests/*.test.lua` against a simulated WoW client
  (`tests/wow.lua`) in fengari and prints line coverage per file. The
  simulation evaluates the macro conditions the addon uses and runs its
  secure snippets in an environment with only `self` and their arguments;
  in combat it blocks insecure attribute changes on protected frames and
  records them in `client.blocked`, so tests can check none were tried.
- `npm run lint` — StyLua formatting check, then WoW Lua LS diagnostics.
- `npm run format` — formats all Lua with StyLua.
- `npm run check` — lint, then tests.

Both coverages are held at 100%: a full `npm test` fails below 100% line
coverage, and `npm run lint` fails below 100% WoW Lua LS type coverage.

Releases: pushing a tag runs `.github/workflows/release.yml`, which runs
`npm run check` and then BigWigsMods/packager. Add a `CHANGELOG.md` section
(and set `## Version:` in the `.toc`) before tagging.

To play with it while working on it, give the client's AddOns folder a git
worktree of its own on a local branch:

```bash
git branch live main
```

```bash
git worktree add "<WoW>/Interface/AddOns/PetCareButton" live
```

`live` stays local. To give the game a newer version, fast-forward it to
`main`, then `/reload` in the game:

```bash
git -C "<WoW>/Interface/AddOns/PetCareButton" merge --ff-only main
```

What the simulation cannot show — whether `/click` from a macro fires the
button, which global string is "Your pet is dead", and whether pet health is
secret in combat — is what DevProbes' PetRevive probe and the debug trace are
for.
