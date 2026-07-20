---
name: zmk-zyraft-hold-tap
description: ZMK hold-tap behavior reference for the Zyraft keyboard. Covers mod-tap, layer-tap, custom hold-tap, flavors, timing parameters, HRM, and positional hold-tap. Load when adding/modifying hold-tap behaviors.
---

A hold-tap outputs one behavior when tapped (quick press-release) and another when held (pressed longer than a threshold). The two behaviors are called "hold" and "tap".

```c
ZMK_BEHAVIOR(name, hold_tap,
    compatible = "zmk,behavior-hold-tap";
    #binding-cells = <2>;          // takes 2 params: (hold_arg, tap_arg)
    flavor = "balanced";           // see flavors below
    tapping-term-ms = <200>;       // max ms for a tap
    bindings = <&kp>, <&kp>;      // hold behavior, tap behavior
)
// Usage: &name HOLD_PARAM TAP_PARAM
// Example: &ht LCTRL A  → hold=LCTRL, tap=A
```

### Predefined Behaviors
- **Mod-Tap (`&mt`)**: Built-in, configured hold-preferred by default. `&mt LSHIFT A`
- **Layer-Tap (`&lt`)**: Built-in, configured tap-preferred by default. `&lt 1 A`

Zyraft defines several custom hold-taps in `config/keymap/behaviors.dtsi`. The Return/Sym thumb is representative:
```c
ZMK_HOLD_TAP(lt_ret, bindings = <&mo>, <&rt_dance>;
    flavor = "balanced";
    tapping-term-ms = <200>;
    quick-tap-ms = <QUICK_TAP_MS>;)

ZMK_TAP_DANCE(rt_dance, bindings = <&kp RET>, <&kp TAB>;
    tapping-term-ms = <200>;)
```

Usage:
```c
&lt_ret SYM 0 // tap Return, double-tap Tab, hold Sym
```

## Flavors
Controls how the hold-tap decides between hold and tap when another key is pressed before tapping-term-ms expires.

| Flavor | Hold triggers when | Tap triggers when |
|--------|-------------------|-------------------|
| `hold-preferred` | tapping-term expires OR another key pressed | key released before tapping-term AND no other key pressed |
| `balanced` | tapping-term expires OR another key pressed AND released | key released before tapping-term, or key pressed but released before hold-tap release |
| `tap-preferred` | tapping-term expires (regardless of other keys) | key released before tapping-term |
| `tap-unless-interrupted` | another key pressed before tapping-term | all other cases (released before tapping-term with no interrupt) |

## Timing Parameters
### `tapping-term-ms`
How long (ms) a key must be held before it resolves to hold.
- HRM typical: 280ms
- Thumb hold-taps: 200ms

### `quick-tap-ms`
If you press the same hold-tap key again within this many ms, it always triggers tap. Useful for double-tap to repeat a key.
- Zyraft uses `QUICK_TAP_MS = 175` from `config/keymap/definitions.dtsi`.

### `require-prior-idle-ms`
If ANY non-modifier key was pressed within this many ms BEFORE the hold-tap, it resolves to tap immediately. Used in HRM.
- Zyraft HRM typical: 150ms

## Positional Hold-Taps (Home Row Mods)
Used for home-row mods to avoid accidental holds when typing same-hand rolls.

```c
#define MAKE_HRM(NAME, HOLD, TAP, TRIGGER_POS) \
    ZMK_HOLD_TAP(NAME, bindings = <HOLD>, <TAP>; flavor = "balanced"; \
    tapping-term-ms = <280>; quick-tap-ms = <QUICK_TAP_MS>; \
    require-prior-idle-ms = <150>; hold-trigger-on-release; \
    hold-trigger-key-positions = <TRIGGER_POS>;)

MAKE_HRM(hml, &kp, &kp, KEYS_R THUMBS) // Left-hand HRMs.
MAKE_HRM(hmr, &kp, &kp, KEYS_L THUMBS) // Right-hand HRMs.
```

### Thumbs redefinition in Zyraft
In `34.h`, `THUMBS` is defined as `THUMBS_L THUMBS_R` (LH0 LH1 RH0 RH1). For the Zyraft 34-key layout, it is redefined in `zyraft.keymap` to maintain correct order:
```c
#undef THUMBS
#define THUMBS LH1 LH0 RH0 RH1
```

### Key positions lists (from `34.h`):
- `KEYS_L`: All left-hand alpha keys (LT0..LT4, LM0..LM4, LB0..LB4)
- `KEYS_R`: All right-hand alpha keys (RT0..RT4, RM0..RM4, RB0..RB4)
- `THUMBS`: `LH1 LH0 RH0 RH1`

When `hml` (left hand mod) is held, it only triggers a modifier hold if the next key pressed is in `KEYS_R` or `THUMBS`. If it is a left-hand key, it resolves to a tap. This ensures fast typing doesn't accidentally trigger modifiers.

## Validation Checklist
When adding/modifying a hold-tap:
- [ ] unique behavior name (no collision)
- [ ] `#binding-cells = <2>` for 2-param usage
- [ ] flavor matches use case (HRM=balanced, mod=hold-preferred, layer=tap-preferred)
- [ ] tapping-term-ms appropriate (thumbs higher, home row mid)
- [ ] quick-tap-ms set to `QUICK_TAP_MS` (175) or a specific value
- [ ] hold-trigger-key-positions correct for side (left HRM = KEYS_R THUMBS)
- [ ] positional check ranges within 0-33 for Zyraft
