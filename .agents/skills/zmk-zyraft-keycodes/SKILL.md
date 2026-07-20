---
name: zmk-zyraft-keycodes
description: ZMK keycode reference for HID keyboard usages, modifiers, modifier functions, consumer codes, and custom key aliases/morphs on the Zyraft keyboard. Load when working with key assignments.
---

All keycodes are used with `&kp`:
```
&kp A          // press A
&kp LC(C)      // press Ctrl+C
&kp RA(N2)     // press AltGr+2
```

### Letters
```
A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
```

### Numbers (with shifted symbols)
```
N0  → 0  )
N1  → 1  !
N2  → 2  @
N3  → 3  #
N4  → 4  $
N5  → 5  %
N6  → 6  ^
N7  → 7  &
N8  → 8  *
N9  → 9  (
```

### Symbols
```
GRAVE   → ` ~
MINUS   → - _
EQUAL   → = +
LBKT    → [ {
RBKT    → ] }
BSLH    → \ |
SEMI    → ; :
SQT     → ' "
COMMA   → , <
DOT     → . >
FSLH    → / ?
```

### Separated shifted symbols
```
EXCL → !    AT  → @    HASH  → #
DLLR → $    STAR→ *    LPAR  → (
RPAR → )    CARET→ ^   AMPS  → &
PIPE → |    TILDE→ ~   PLUS  → +
UNDER→ _    COLON→ :   DQT   → "
LT   → <    GT   → >   QMARK → ?
LBRC → {    RBRC → }
```

### Control
```
ESC  TAB  RET/ENTER  BSPC/DEL  SPACE
INS  HOME END  PG_UP  PG_DN
UP   DOWN  LEFT  RIGHT
```

### Function keys
```
F1 F2 F3 F4 F5 F6 F7 F8 F9 F10 F11 F12
```

### Modifier keycodes
```
LCTRL   RCTRL
LSHIFT  RSHIFT
LALT    RALT
LGUI    RGUI
```

### Modifier wrapper functions
Combine a modifier with another keycode:

| Function | Equivalent | Example |
|----------|-----------|---------|
| `LC(key)` | LCTRL + key | `&kp LC(C)` = Ctrl+C |
| `LS(key)` | LSHIFT + key | `&kp LS(N1)` = Shift+1 = ! |
| `LA(key)` | LALT + key | `&kp LA(F4)` = Alt+F4 |
| `LG(key)` | LGUI + key | `&kp LG(TAB)` = Win+Tab |
| `RC(key)` | RCTRL + key | |
| `RS(key)` | RSHIFT + key | |
| `RA(key)` | RALT + key | `&kp RA(E)` = AltGr+E = € (US-Intl) |

### Modifier bitmask constants (for mod-morph)
```
MOD_LSFT  MOD_RSFT
MOD_LCTL  MOD_RCTL
MOD_LALT  MOD_RALT
MOD_LGUI  MOD_RGUI
```

## Consumer Keycodes (media)
```
C_VOL_UP   Volume Up
C_VOL_DN   Volume Down
C_MUTE     Mute
C_PP       Play/Pause
C_NEXT     Next Track
C_PREV     Previous Track
C_BRI_UP   Brightness Up
C_BRI_DN   Brightness Down
```

## Bluetooth, Output, Power
```
&bt BT_SEL 0       // select BT profile 0
&bt BT_CLR         // clear BT pairing
&out OUT_USB       // switch to USB output
&out OUT_BLE       // switch to BLE output
&ext_power EP_ON   // external power on
&ext_power EP_OFF  // external power off
&sys_reset         // reset MCU
&bootloader        // enter bootloader
&soft_off          // soft power off
```

## Custom aliases and behaviors

Current definitions live in `config/keymap/behaviors.dtsi`.

### Morphing keys
- `&comma_morph`: Tap = `,` | Shift+Tap = `;` | Ctrl+Shift+Tap = `<`
- `&dot_morph`: Tap = `.` | Shift+Tap = `:` | Ctrl+Shift+Tap = `>`
- `&qexcl`: Tap = `?` | Shift+Tap = `!`
- `&lpar_lt`: Tap = `(` | Shift+Tap = `<`
- `&rpar_gt`: Tap = `)` | Shift+Tap = `>`
- `&bs_esc`: Tap = Backspace | Shift+Tap = Escape

### Thumb hold-taps
- `&lt_spc NAV 0`: Tap = Space | double-tap = Escape | hold = Nav
- `&lt_ret SYM 0`: Tap = Return | double-tap = Tab | hold = Sym
- `&rh1_smart NUM 0`: Tap = Backspace | Shift+Tap = Escape | hold = Num
- `&magic_sym SYM SYM`: Tap = sticky Sym | hold = Sym
- `MAGIC_SHIFT`: Tap = adaptive repeat/sticky Shift | Shift+Tap = Caps Word | hold = Shift

### Custom Actions
- `CANCEL`: `&kp K_CANCEL` (Cancels caps-word & auto-layers)
- `DSK_PREV`: `&hmr LCTRL LG(LC(LEFT))` (Previous desktop)
- `DSK_NEXT`: `&hmr LALT LG(LC(RIGHT))` (Next desktop)
- `PIN_WIN`: `&kp LG(LC(LS(Q)))` (Pin window across desktops)
- `PIN_APP`: `&kp LG(LC(LS(A)))` (Pin application across desktops)
- `DSK_MGR`: `&kp LA(GRAVE)` (Desktop manager)
- `VOL_DOWN`: `&hmr RSHFT C_VOL_DN` (Volume down)

## Validation Checklist
When assigning a keycode:
- [ ] correct spelling (case-sensitive, e.g., `LCTRL` not `LCTRl`)
- [ ] modifier wrapper: `LC(C)` not `LCTRL_C`
- [ ] consumer codes use `C_` prefix (e.g., `C_VOL_UP`)
- [ ] for shifted symbols, use the explicit keycode (`EXCL` not `LS(N1)`)
- [ ] custom morphs/behaviors do NOT need `&kp` (they are invoked directly, e.g., `&comma_morph`)
- [ ] bluetooth, output, ext_power behaviors use `&` reference: `&bt BT_SEL 0`
