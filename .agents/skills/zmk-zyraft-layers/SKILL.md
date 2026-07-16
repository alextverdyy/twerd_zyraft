---
name: zmk-zyraft-layers
description: ZMK layer behavior reference for the Zyraft keyboard. Covers momentary layer, toggle, to-layer, layer-tap, conditional layers, and layer management patterns. Load when adding/modifying layers.
---

Layers let you reuse the same physical keys for different functions. Multiple layers can be active simultaneously - higher number layers have priority. Layer 0 is the default (always active).

Layer numbers correspond to the order of `ZMK_LAYER()` / `ZMK_BASE_LAYER()` definitions in the keymap node.

## Predefined Layer Transitions
- **Momentary Layer (`&mo`)**: Layer active while key is held. `&mo 3`
- **Layer-Tap (`&lt`)**: Tap = key, hold = momentary layer. `&lt_spc NAV 0` (Tap = space_morph, hold = NAV layer).
- **To Layer (`&to`)**: Switch to layer, deactivate all others except base. `&to 0`
- **Toggle Layer (`&tog`)**: Toggle a layer on/off. `&tog 5` (Toggle MOUSE layer).

## Layer Stack
When multiple layers are active, the highest numbered layer takes priority:
- Layer 0 (base): always on
- Layer 1 is held with `&mo`: layers 0 + 1 active. Keys from layer 1 take priority. `&trans` on layer 1 passes through to layer 0.

## Zyraft Layer Constants
Defined in `base.keymap`:
```c
#define DEF 0
#define NAV 1
#define FN 2
#define NUM 3
#define SYS 4
#define MOUSE 5
#define SYM 6
```
This allows referring to layers by name: `&mo FN`, `&to DEF`, `&magic_sym SYM SYM`.

**When adding a layer between existing ones**, update ALL subsequent constants. When appending, just add the new one.

## Conditional Layers
Auto-activate a layer when specific other layers are all active. Defined in `base.keymap`:
```c
ZMK_CONDITIONAL_LAYER(sys, FN NUM, SYS) // FN + NUM --> SYS.
```
When both the `FN` (2) and `NUM` (3) layers are active, the `SYS` (4) layer activates automatically.

## Keymap Layout Reference
For `ZMK_BASE_LAYER()`, bindings follow this exact order (34 keys):

```
// Row 0 (top row)
LT4, LT3, LT2, LT1, LT0,     RT0, RT1, RT2, RT3, RT4
// Row 1 (middle row)
LM4, LM3, LM2, LM1, LM0,     RM0, RM1, RM2, RM3, RM4
// Row 2 (bottom row)
LB4, LB3, LB2, LB1, LB0,     RB0, RB1, RB2, RB3, RB4
// Row 3 (thumb cluster)
LH1, LH0,                    RH0, RH1
```

Thumb order is: left thumb outer-to-inner, right thumb inner-to-outer:
```
LH1 (left, outer) → LH0 (left, inner) → RH0 (right, inner) → RH1 (right, outer)
```

In the keymap definition:
```c
ZMK_BASE_LAYER(Base,
    &kp Q         &kp W         &kp E         &kp R         &kp T           , &kp Y         &kp U         &kp I         &kp O         &kp P         ,
    &hml LCTRL A  &hml LALT S   &hml LGUI D   &hml LSHFT F  &kp G           , &kp H         &hmr RSHFT J  &hmr LGUI K   &hmr RALT L   &hmr RCTRL SEMI,
    &kp Z         &kp X         &kp C         &kp V         &kp B           , &kp N         &kp M         &comma_morph  &dot_morph    &qexcl         ,
                                                LH1_BINDING   &lt_spc NAV 0   , &lt FN RET    &lt NUM BSPC
)
```
Where `LH1_BINDING` is defined as `&esc_magic 0 ESC`.

## Validation Checklist
When adding/modifying layers:
- [ ] `#define` constant added/updated correctly
- [ ] No layer index collisions (each layer has unique index)
- [ ] layer bindings follow correct 34-key order (LT4..LT0 RT0..RT4, LM4..LM0 RM0..RM4, LB4..LB0 RB0..RB4, LH1 LH0 RH0 RH1)
- [ ] `&trans` / `___` used for keys that should pass through to base layer
- [ ] `&none` / `XXX` used for keys that should block lower layers
- [ ] thumb keys in correct order (LH1 LH0 RH0 RH1)
- [ ] conditional layer configurations updated if layer indices change
- [ ] `&to` usage doesn't lock user out (always have a way back to base layer)
- [ ] new layer accessible from at least one parent layer or combo
