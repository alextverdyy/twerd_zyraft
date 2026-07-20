---
name: zmk-zyraft-core
description: Core context for ZMK Zyraft keyboard modification. Describes hardware, key positions, ZMK concepts, and modification workflow. Load first for any ZMK task.
---

## Hardware (constant)
- **Board**: nice_nano_v2 (left + right peripherals) & xiao_ble (dongle)
- **Shield**: Zyraft - split, wireless (BLE) with dongle support
- **Keys**: 34 total (17 per side)

## Key Position Naming (constant)
Zyraft has 5 columns x 3 rows + 2 thumb keys per side. This naming is set by `zmk-helpers/key-labels/34.h` and does not change.

```
Left:                                    Right:
LT4 LT3 LT2 LT1 LT0                      RT0 RT1 RT2 RT3 RT4
LM4 LM3 LM2 LM1 LM0                      RM0 RM1 RM2 RM3 RM4
LB4 LB3 LB2 LB1 LB0                      RB0 RB1 RB2 RB3 RB4
      LH1 LH0                                  RH0 RH1
```

Prefix: L/R = side, T/M/B/H = row (Top/Middle/Bottom/Thumb), suffix 0-4 = column (0 = index/thumb inner, 4 = pinky/thumb outer).

The keymap uses ZMK_LAYER() which follows this order for 34 keys:

```
// Row 1: left 5 cols then right 5 cols
LT4 LT3 LT2 LT1 LT0, RT0 RT1 RT2 RT3 RT4
// Row 2: left 5 cols then right 5 cols
LM4 LM3 LM2 LM1 LM0, RM0 RM1 RM2 RM3 RM4
// Row 3: left 5 cols then right 5 cols
LB4 LB3 LB2 LB1 LB0, RB0 RB1 RB2 RB3 RB4
// Row 4 (thumbs): left 2 then right 2
LH1 LH0, RH0 RH1
```

### Key Press (`&kp`)
Basic key output. Keycode is the HID usage.

```
&kp A          // press A
&kp LC(C)      // press Ctrl+C
&kp RA(US_CCED) // press AltGr+C for cedilla
```

Modifier wrapping: `LC(X)` = Left Ctrl+X, `LS(X)` = Left Shift+X, `LG(X)` = GUI+X, `LA(X)` = Alt+X. Combine: `LS(LA(N2))` = Shift+Alt+2.

### Hold-Tap
A key that does one thing on tap, another on hold.

```c
ZMK_BEHAVIOR(name, hold_tap,
    flavor = "balanced";      // how to resolve tap vs hold
    tapping-term-ms = <280>;   // max ms for a tap
    quick-tap-ms = <175>;      // rapid repeat threshold
    bindings = <HOLD>, <TAP>;
)
```

**Flavors:**
- `"balanced"` - default. If held past tapping-term, becomes hold. If released before, becomes tap.
- `"tap-preferred"` - favors tap. Hold must be very deliberate.
- `"hold-preferred"` - favors hold. Quick taps still work (via quick-tap-ms).

**Key parameters:**
- `tapping-term-ms`: max time for a tap. Hold beyond this = hold behavior.
- `quick-tap-ms`: when pressed again within this ms, force tap. Prevents accidental holds when typing fast.
- `require-prior-idle-ms`: if set, hold-tap resets after key release for this duration. Used in HRM.
- `hold-trigger-key-positions`: list of positions that trigger hold mode. Used with hold-trigger-on-release.
- `hold-trigger-on-release`: hold activates on release, not when tapping-term expires.

**Common patterns:**
```c
// Home-row mods are defined in config/keymap/behaviors.dtsi.
#define MAKE_HRM(NAME, HOLD, TAP, TRIGGER_POS) \
    ZMK_HOLD_TAP(NAME, bindings = <HOLD>, <TAP>; flavor = "balanced"; \
    tapping-term-ms = <280>; quick-tap-ms = <QUICK_TAP_MS>; \
    require-prior-idle-ms = <150>; hold-trigger-on-release; \
    hold-trigger-key-positions = <TRIGGER_POS>;)

MAKE_HRM(hml, &kp, &kp, KEYS_R THUMBS) // Left-hand HRMs.
MAKE_HRM(hmr, &kp, &kp, KEYS_L THUMBS) // Right-hand HRMs.
```

Usage in keymap:
```
&hml LCTRL A     // tap=A, hold=LCTRL
```

### Mod-Morph
A key that changes its output based on modifiers held.

```c
ZMK_BEHAVIOR(name, mod_morph,
    mods = <(MOD_LSFT|MOD_RSFT)>;   // which mods trigger morph
    bindings = <BASE>, <MORPHED>;    // base binding, shifted binding
    keep-mods = <...>;                // optional: keep mods in output
)
```

**Helper macro pattern** (from `config/keymap/behaviors.dtsi`):
```c
#define SIMPLE_MORPH(NAME, MOD, BINDING1, BINDING2) \
    ZMK_MOD_MORPH(NAME, mods = <(MOD_L##MOD | MOD_R##MOD)>; \
    bindings = <BINDING1>, <BINDING2>;)

// usage: tap=comma, shift+tap=semicolon, ctrl+shift+tap=<
SIMPLE_MORPH(comma_morph, SFT, &kp COMMA, &comma_inner_morph)
```

### Macro
Programmable sequences of key events.

```c
// Simple macro: type a sequence
ZMK_MACRO(my_macro,
    wait-ms = <10>;
    tap-ms = <10>;
    bindings = <&kp H &kp E &kp Y>;   // types "hey"
)
```

### Combo
Multiple keys pressed together trigger an action.

```c
ZMK_COMBO(name, binding, key-positions, layers);
```

### Layers
```c
#define DEF 0
#define NAV 1
#define FN 2
#define NUM 3
#define SYS 4
#define MOUSE 5
#define SYM 6
```

**Layer transitions:**
- `&mo N` - momentary layer N (hold to activate)
- `&to N` - go to layer N (toggle, not momentary)
- `&lt N BINDING` - layer-tap: tap=binding, hold=momentary layer N
- `&trans` - pass through to next active layer
- `&none` - no action, no pass-through

**Special value:** `___` = `&trans` (defined in `config/keymap/definitions.dtsi`). Use `&none` explicitly for a blocked position.

### Keycodes
- **Basic HID**: letters, numbers, symbols
- **Modifiers**: `LCTRL`, `LSHFT`, `LALT`, `LGUI`, `RCTRL`, `RSHIFT`, `RALT`, `RGUI`
- **Bluetooth**: `&bt BT_SEL 0-3`, `&bt BT_CLR`
- **Output**: `&out OUT_USB`, `&out OUT_BLE`

- `config/keymap/definitions.dtsi`: includes, layer IDs, global timing, and helper macros.
- `config/keymap/behaviors.dtsi`: hold-taps, mod-morphs, automatic layers, and aliases.
- `config/keymap/combos.dtsi`: all combo definitions.
- `config/keymap/leader.dtsi`: Unicode and device leader sequences.
- `config/keymap/mouse.dtsi`: pointer and scroll tuning.
- `config/keymap/os.dtsi`: OS-aware behaviors.

## Build System
- `build.yaml`: defines which board+shield combinations to build.
- `config/west.yml`: Zephyr module manifest.
- `config/boards/shields/zyraft/`: directory containing shield definitions.
- `.conf` files: `zyraft_left.conf`, `zyraft_right.conf`, and `zyraft_dongle.conf`.

## Workflow Protocol
When user asks for keyboard modification:

1. **Clarify** - what, which layers/OS, any constraints
2. **Read** - examine current files in `config/`
3. **Plan** - determine what needs to change (behavior, layer binding, combo, config)
4. **Propose** - show `git diff` output, explain each change
5. **Iterate** - user approves or requests changes
6. **Apply** - use edit/write to modify files
7. **Commit** - `git add -A && git commit -m "description"`
8. **Push** - `git push origin main` → triggers GHA build

- Always show git diff before applying
- Never modify `zmk-helpers/` (submodule)
- Keycodes via `&kp`, behaviors via `&name`, `&trans` = passthrough, `&none` = dead
- `___` = `&trans`; use `&none` explicitly for a dead binding

| Skill | Content | When to load |
|-------|---------|-------------|
| zmk-zyraft-hold-tap | Hold-tap deep reference: flavors, timing, HRM patterns | Hold-tap work |
| zmk-zyraft-mod-morph | Mod-morph deep reference: nesting, keep-mods | Mod-morph work |
| zmk-zyraft-macros | Macro types, param macros, tap/press/release | Macro work |
| zmk-zyraft-combos | Combo syntax, timing, layers, edge cases | Combo work |
| zmk-zyraft-layers | Layer transitions, conditional layers, reserved-ZMK Studio | Layer changes |
| zmk-zyraft-keycodes | HID usage table, special codes | Key reassignment |
| zmk-zyraft-devices | Kconfig options, west manifest, build matrix | Device config |

To load: `read /path/to/.agents/skills/zmk-zyraft-<name>/SKILL.md`
