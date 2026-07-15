---
name: zmk-zyraft-combos
description: ZMK combo behavior reference for the Zyraft keyboard. Covers combo definition, key positions (0-33), timeout, layer filtering, overlapping combos, and edge cases. Load when adding/modifying combos.
---

## Concept
A combo triggers a behavior when multiple keys are pressed simultaneously (within a timeout). Combos are defined outside the keymap node but compiled into the firmware.

## Basic Definition
```c
/ {
    combos {
        compatible = "zmk,combos";
        combo_my_name {
            timeout-ms = <50>;
            key-positions = <POS1 POS2>;
            bindings = <&kp ESC>;
            layers = <0 1>;      // optional: restrict to layers
        };
    };
};
```

**Note on node naming**: The `combo_` prefix is convention, not required. The node label (before `:`) becomes the reference name but combos are not referenced elsewhere - they trigger automatically when positions are pressed.

The keymap uses a simplified macro wrapper:

```c
ZMK_COMBO(name, binding, key-positions, layers);
```

This is a C macro (not a Devicetree node) that expands to a full combo node. Check the actual expansion in `zmk-helpers/helper.h` if available, otherwise it follows the pattern above.

| Parameter | Required | Description |
|-----------|----------|-------------|
| `timeout-ms` | No (default varies) | Time window for all keys to be pressed, in ms. Typically 30-50ms. |
| `key-positions` | Yes | Space-separated list of key positions (0-indexed). |
| `bindings` | Yes | Behavior to trigger (any ZMK behavior). |
| `layers` | No | Space-separated list of layers where combo is active. Omit = all layers. |
| `slow-release`| No | If set, combo release waits for ALL keys to release (default: release on ANY key release). |
| `require-prior-idle-ms` | No | Like hold-tap: if any key pressed within this time before combo, combo doesn't trigger. |

### Key positions
Positions are 0-indexed, matching the order keys appear in the keymap:

```
Position 0 = first key in first layer = LT4
Position 1 = second key = LT3
...
Position 33 = last key = RH1
```

For the Zyraft (34 keys), the order follows ZMK_LAYER row order:
```
Row 0: LT4(0) LT3(1) LT2(2) LT1(3) LT0(4) RT0(5) RT1(6) RT2(7) RT3(8) RT4(9)
Row 1: LM4(10) LM3(11) LM2(12) LM1(13) LM0(14) RM0(15) RM1(16) RM2(17) RM3(18) RM4(19)
Row 2: LB4(20) LB3(21) LB2(22) LB1(23) LB0(24) RB0(25) RB1(26) RB2(27) RB3(28) RB4(29)
Row 3: LH1(30) LH0(31) RH0(32) RH1(33)
```

### Layer filtering
Use the `layers` parameter to restrict combos to specific layers:

```c
// All layers except specified
layers = <0 1 2 3 4 5 6>;                 // explicit list
layers = <DEF NAV FN NUM SYS MOUSE SYM>; // using layer constants

// Zyraft-specific combo example
combo_magic_sym {
    timeout-ms = <COMBO_TERM_FAST>;
    key-positions = <RT3 RT4>;
    bindings = <&magic_sym SYM SYM>;
    layers = <DEF>;
};
```

### `slow-release`
By default, a combo releases its behavior as soon as ANY of its keys is released. With `slow-release`, the behavior stays held until ALL keys release.

```c
combo_my_combo {
    slow-release;
    ...
};
```

## Overlapping Combos
- Partially overlapping (`0 1` and `0 2`): supported
- Fully overlapping (`0 1` and `0 1 2`): supported
- ZMK handles ambiguity by triggering the combo with the most matching keys, or the first defined combo if equal.

## Behaviors in Combos
Any ZMK behavior can be used:
```c
bindings = <&kp ESC>;               // key press
bindings = <&mo 3>;                 // momentary layer
bindings = <&bt BT_SEL 0>;          // bluetooth
bindings = <&mt LSHIFT A>;          // mod-tap
bindings = <&my_custom_behavior>;   // custom behavior
bindings = <&macro_tap &kp H &kp I>; // macro
```

## Split Keyboard Caveat
Source-specific behaviors (reset, bootloader) triggered by a combo always execute on the CENTRAL side. If you need side-specific actions, use a different approach.

## Validation Checklist
When adding/modifying a combo:
- [ ] key positions exist on the keyboard (0-33 for Zyraft)
- [ ] positions are physically pressable simultaneously
- [ ] timeout-ms >= 30 (too fast = hard to trigger)
- [ ] layers list correct (or omitted for all layers)
- [ ] no collision with existing combo (same positions or overlapping causing ambiguity)
- [ ] behavior bindings correct syntax
- [ ] for source-specific behaviors: aware they execute on central side
