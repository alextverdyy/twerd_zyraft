---
name: zmk-zyraft-macros
description: ZMK macro behavior reference for the Zyraft keyboard. Covers macro definition, activation modes (tap/press/release), parameterized macros, wait/tap timing, and common patterns. Load when adding/modifying macros.
---

## Concept
A macro executes a sequence of behavior invocations. Macros support tap (press+release), press-only, release-only, pause-for-release, timing controls, and parameters.

## Basic Macro (zero parameters)
```c
ZMK_BEHAVIOR(my_macro, macro,
    compatible = "zmk,behavior-macro";
    #binding-cells = <0>;
    wait-ms = <10>;
    tap-ms = <10>;
    bindings = <&macro_tap &kp H &kp E &kp Y>;
)
// Usage: &my_macro  → types "hey"
```

Or using the convenience macro:
```c
ZMK_MACRO(my_macro,
    wait-ms = <10>;
    tap-ms = <10>;
    bindings = <&kp H &kp E &kp Y>;
)
```

## Activation Modes
These controls change how subsequent bindings are activated:

| Control | Action |
|---------|--------|
| `&macro_tap` | Press THEN release each behavior in the binding |
| `&macro_press` | Press only (hold down) |
| `&macro_release` | Release only |

```c
// Hold Shift, tap Z-M-K, release Shift → types "ZMK"
bindings
    = <&macro_press &kp LSHFT>
    , <&macro_tap &kp Z &kp M &kp K>
    , <&macro_release &kp LSHFT>
    ;
```

## Pause for Release
Split macro execution into "on press" and "on release" parts:

```c
bindings
    = <&macro_press &mo 1 &kp LSHFT>    // on press: hold layer 1 + shift
    , <&macro_pause_for_release>         // ← wait here
    , <&macro_release &mo 1 &kp LSHFT>  // on release: release both
    ;
```

## Timing
| Property | Purpose | Default |
|----------|---------|---------|
| `wait-ms` | Delay between each binding in the list | `CONFIG_ZMK_MACRO_DEFAULT_WAIT_MS` (usually 10-30ms) |
| `tap-ms` | How long a tap mode holds the key before release | `CONFIG_ZMK_MACRO_DEFAULT_TAP_MS` (usually 10-30ms) |

For instant sequences/shortcuts:
```c
wait-ms = <0>;
tap-ms = <5>;
```

## Parameterized Macros
### One parameter (`macro-one-param`)
```c
ZMK_BEHAVIOR(my_one_param, macro_one_param,
    compatible = "zmk,behavior-macro-one-param";
    #binding-cells = <1>;
    wait-ms = <100>;
    tap-ms = <5>;
    bindings = <&kp LC(W)>, <&macro_param_1to1>, <&kp MACRO_PLACEHOLDER>;
)
// &my_one_param H  →  Ctrl+W then H
```

### Parameter controls
| Control | What it does |
|---------|-------------|
| `&macro_param_1to1` | Pass macro param 1 → next behavior's param 1 |
| `&macro_param_1to2` | Pass macro param 1 → next behavior's param 2 |
| `&macro_param_2to1` | Pass macro param 2 → next behavior's param 1 |
| `&macro_param_2to2` | Pass macro param 2 → next behavior's param 2 |

Use `MACRO_PLACEHOLDER` as a dummy value (alias for 0) - it gets replaced at runtime.

## Zyraft macro example (`config/keymap/behaviors.dtsi`)

### Sticky Shift + Leader macro
Chains sticky shift with leader key:
```c
ZMK_MACRO(leader_sft,
    bindings = <&sk LSHFT &leader>;
)
```

## Validation Checklist
When adding/modifying a macro:
- [ ] `compatible` matches param count: `macro` (0), `macro-one-param` (1), `macro-two-param` (2)
- [ ] `#binding-cells` matches compatible
- [ ] wait-ms and tap-ms set correctly for the sequence speed (0 and 5 for custom fast macros)
- [ ] `&macro_pause_for_release` only once per macro
- [ ] parameter macros: `MACRO_PLACEHOLDER` used for replaced values
- [ ] no duplicate behavior names
