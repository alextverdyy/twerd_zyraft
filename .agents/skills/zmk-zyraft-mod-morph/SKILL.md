---
name: zmk-zyraft-mod-morph
description: ZMK mod-morph behavior reference for the Zyraft keyboard. Covers single-modifier morphs, nested morphs, keep-mods, and multi-modifier conditions. Load when adding/modifying mod-morph behaviors.
---

## Concept
A mod-morph changes its output depending on which modifiers are held when the key is pressed.

```
Tap alone  → first binding
Tap while holding specified modifier(s) → second binding
```

## Basic Definition
```c
ZMK_BEHAVIOR(name, mod_morph,
    compatible = "zmk,behavior-mod-morph";
    #binding-cells = <0>;              // takes no keymap params
    bindings = <BASE>, <MORPHED>;      // normal, shifted
    mods = <(MOD_LSFT|MOD_RSFT)>;      // which mods trigger morph
)
// Usage: &name
```

### `mods` - trigger modifiers
Available modifier constants:

| Constant | Physical key |
|----------|--------------|
| `MOD_LSFT` | Left Shift |
| `MOD_RSFT` | Right Shift |
| `MOD_LCTL` | Left Control |
| `MOD_RCTL` | Right Control |
| `MOD_LALT` | Left Alt |
| `MOD_RALT` | Right Alt (AltGr) |
| `MOD_LGUI` | Left GUI (Win/Cmd) |
| `MOD_RGUI` | Right GUI (Win/Cmd) |

Combine with `|` (bitwise OR):
```c
mods = <(MOD_LSFT|MOD_RSFT)>;          // either shift
mods = <(MOD_LALT|MOD_RALT)>;          // either alt/altgr
```

### `keep-mods` - propagate modifiers
By default, when a morph triggers, the triggering modifier is NOT sent with the output. Use `keep-mods` to send specific modifiers along.

```c
// Shift+Backspace → Shift+Delete (if right shift held)
ZMK_MOD_MORPH(bs_del, bindings = <&kp BSPC>, <&kp DEL>;
    mods = <(MOD_LSFT|MOD_RSFT)>; keep-mods = <MOD_RSFT>;)
```

## Helper Macro Pattern (defined in base.keymap)
For simple single-modifier morphs, a C preprocessor macro reduces boilerplate:

```c
#define SIMPLE_MORPH(NAME, MOD, BINDING1, BINDING2) \
    ZMK_MOD_MORPH(NAME, mods = <(MOD_L##MOD | MOD_R##MOD)>; \
    bindings = <BINDING1>, <BINDING2>;)
```

## Nested Mod-Morphs (multi-modifier conditions)
You can't require multiple specific modifiers simultaneously with a single mod-morph. But you can NEST mod-morphs to create multi-level logic.

### Comma morph
```c
SIMPLE_MORPH(comma_morph, SFT, &kp COMMA, &comma_inner_morph)
SIMPLE_MORPH(comma_inner_morph, CTL, &kp SEMICOLON, &kp LESS_THAN)

// Result:
// Tap alone → comma (,)
// Shift hold → semicolon (;)
// Ctrl+Shift hold → less than (<)
```

### Dot morph
```c
SIMPLE_MORPH(dot_morph, SFT, &kp DOT, &dot_inner_morph)
SIMPLE_MORPH(dot_inner_morph, CTL, &kp COLON, &kp GREATER_THAN)

// Result:
// Tap alone → dot (.)
// Shift hold → colon (:)
// Ctrl+Shift hold → greater than (>)
```

## Zyraft Mod-Morph Examples (from base.keymap)
### Question/Exclamation Morph
```c
SIMPLE_MORPH(qexcl, SFT, &kp QMARK, &kp EXCL)
// Tap = ? | Shift+Tap = !
```

### Parentheses / Brackets Morphs
```c
SIMPLE_MORPH(lpar_lt, SFT, &kp LPAR, &kp LT) // Tap = ( | Shift+Tap = <
SIMPLE_MORPH(rpar_gt, SFT, &kp RPAR, &kp GT) // Tap = ) | Shift+Tap = >
```

### Space Morph
Morphs space to a macro `dot_spc` when holding Shift:
```c
SIMPLE_MORPH(spc_morph, SFT, &kp SPACE, &dot_spc)
```

## Validation Checklist
When adding/modifying a mod-morph:
- [ ] unique behavior name
- [ ] `#binding-cells = <0>` (unless nested with params)
- [ ] `mods` bitmask is correct: `(MOD_LALT|MOD_RALT)`
- [ ] `bindings` order: [base, morphed] - base is NO modifier, morphed is WITH modifier
- [ ] `keep-mods` set if modifier should pass through to output
- [ ] nested morphs: outer `#binding-cells = <0>`, inner referenced as `&inner_name` in binding
