# Zyraft keymap optimization plan (least-disruptive port from Totem)

## Context
- Old keyboard: Totem, 38 keys (external, not in this repo).
- New keyboard: Zyraft, 34 keys (`config/`).
- 4 fewer keys: two outer bottom pinky keys (TMUX left, TAB right) and one thumb per side (Totem = 3 thumbs/side, Zyraft = 2).
- Goal: make the new keymap match Totem muscle memory as closely as possible.

## Decisions (from user)
- Restore full symmetric GACS home-row mods.
- Keep SPACE on the rightmost left-thumb key (LH0) and BACKSPACE on the right thumb, matching prior habit.
- Restore the "smart" behaviors: MAGIC_SHIFT and num-word (SMART_NUM).
- ESC and SYM live on combos (exactly as Totem already does).

## Target base layer

Home row (restores Shift on F and J):
```
L:  Ctrl/A  Alt/S  Gui/D  Shift/F  G      R:  H  Shift/J  Gui/K  Alt/L  Ctrl/;
```

Thumbs (LH1 LH0 | RH0 RH1):
```
MAGIC-SHIFT   SPACE/NAV  |  RET/FN   BSPC/NUM
```
Space sits on LH0 (rightmost left-thumb key, nearest center); magic-shift on LH1 (leftmost).
Only difference from Totem: SYM moves off the thumb to its combo.

## Where the 4 lost keys/functions go
- ESC   -> combo LT3+LT2 (identical to Totem)
- SYM   -> combo RT3+RT4 (existing `magic_sym`)
- TMUX  -> combo LB4+LB3 (existing)
- TAB   -> combo LM3+LM2 (existing)
- num-word (SMART_NUM) -> new combo, proposed RB3+RB4

## Implementation steps (all in `config/`)
1. `zyraft.keymap` Base: `&lt NAV F` -> `&hml LSHFT F`; `&j_tab TAB J` -> `&hmr RSHFT J`.
2. `zyraft.keymap` Base thumbs: LH1 `LH1_BINDING` -> `MAGIC_SHIFT`; LH0 `&mt LSHFT SPACE` -> `&lt_spc NAV 0` (Space on rightmost left thumb). (RH0 `&lt FN RET` and RH1 `&lt NUM BSPC` already correct.)
3. `zyraft.keymap`: delete now-unused behaviors `esc_magic_hold`, `esc_magic`, `esc_sym`, `j_tab`, and the `LH1_BINDING` define. Keep `magic_sym`+combo, `swapper`, BT/OS macros.
4. `zyraft.keymap` NAV: remove duplicate `&swapper` (set RT4 and the RH0 thumb back to `___`); keep the single swapper at LT1.
5. `zyraft.keymap` Base comment header: fix labels (F=LSHFT, J=RSHFT, thumbs, and RB4 "SMART NUM" -> "q! morph") to match bindings.
6. `combos.dtsi`: add `ZMK_COMBO(numwd, &num_word NUM, RB3 RB4, DEF, COMBO_TERM_FAST, COMBO_IDLE_FAST)` to restore num-word.

## Verification
- grep for removed behaviors (`esc_sym|j_tab|esc_magic|LH1_BINDING`) -> no remaining references.
- Build firmware (GHA / west) to confirm it compiles (34-key layout, no undefined behaviors).
- Manual: Shift on F/J; space-hold=NAV; magic-shift tap=repeat/caps; BSPC tap + NUM hold; ESC/TAB/TMUX/SYM combos fire; num-word combo toggles.

## Risks / tradeoffs
- SYM is combo-only now (no thumb) — a real change from Totem, forced by 4 thumbs.
- num-word combo position (RB3+RB4) is a judgment call; easy to move if it misfires.
- Two Shift sources (home row + magic-shift thumb) — intentional, same as Totem.

