---
name: zmk-zyraft-layers
description: ZMK layer behavior reference for the Zyraft keyboard. Covers momentary, toggle, to-layer, layer-tap, and the current seven-layer layout. Load when adding or modifying layers.
---

Layers reuse physical keys for different functions. Multiple layers can be active at once; the highest numbered active layer has priority. Layer 0 is the default and remains available beneath transparent bindings.

## Layer transitions

- `&mo N`: layer N is active while held.
- `&lt N BINDING`: tap sends the binding, hold activates N.
- `&to N`: switch to N and deactivate other non-default layers.
- `&tog N`: turn N on or off.
- `&sl N`: make N sticky for the next key.
- `&trans` / `___`: fall through to the next active layer.
- `&none`: block the position without falling through.

## Zyraft layer constants

Defined in `config/keymap/definitions.dtsi`:

```c
#define DEF 0
#define NAV 1
#define FN 2
#define NUM 3
#define SYS 4
#define MOUSE 5
#define SYM 6
```

When inserting a layer, update every subsequent constant. When appending, add one new unique number.

## Current access paths

| Layer | Access |
|---|---|
| Base | default; `&to DEF` returns here |
| Nav | hold the Space thumb (`&lt_spc NAV 0`) |
| Fn | toggle from the Nav right inner thumb |
| Num | hold the Backspace thumb (`&rh1_smart NUM 0`) or use Number Word |
| Sys | three-thumb combo; Fn also has a SYS toggle |
| Mouse | smart-mouse combo |
| Sym | hold the Return thumb (`&lt_ret SYM 0`) or use the `O+P` combo |

There is no conditional `FN + NUM -> SYS` layer in the current keymap.

## Key order

`ZYRAFT_LAYER()` takes eight groups in this exact order:

```text
left top, right top,
left home, right home,
left bottom, right bottom,
left thumbs, right thumbs
```

Physical positions:

```text
LT4 LT3 LT2 LT1 LT0 | RT0 RT1 RT2 RT3 RT4
LM4 LM3 LM2 LM1 LM0 | RM0 RM1 RM2 RM3 RM4
LB4 LB3 LB2 LB1 LB0 | RB0 RB1 RB2 RB3 RB4
          LH1 LH0   | RH0 RH1
```

Thumb order is left outer-to-inner, then right inner-to-outer: `LH1 LH0 RH0 RH1`.

Current Base example:

```c
ZYRAFT_LAYER(Base,
    /* left top */     &kp Q &kp W &kp E &kp R &kp T,
    /* right top */    &kp Y &kp U &kp I &kp O &kp P,
    /* left home */    &hml LCTRL A &hml LALT S &hml LGUI D &hml LSHFT F &kp G,
    /* right home */   &kp H &hmr RSHFT J &hmr LGUI K &hmr RALT L &hmr RCTRL SEMI,
    /* left bottom */  &kp Z &kp X &kp C &kp V &kp B,
    /* right bottom */ &kp N &kp M &comma_morph &dot_morph &qexcl,
    /* left thumbs */  MAGIC_SHIFT &lt_spc NAV 0,
    /* right thumbs */ &lt_ret SYM 0 &rh1_smart NUM 0
)
```

## Validation checklist

- [ ] Every layer constant has a unique index.
- [ ] `ZYRAFT_LAYER()` groups remain in physical order.
- [ ] Transparent and blocked keys use `___` and `&none` intentionally.
- [ ] Thumb order is `LH1 LH0 RH0 RH1`.
- [ ] Every new layer has an access path and a path back to Base.
- [ ] Generated diagrams pass `PYTHON=.venv/bin/python ./scripts/draw-keymap.sh --check`.
- [ ] Firmware builds after the change.
