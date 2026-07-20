# Behaviors

## Home-row mods

The home row uses symmetric GACS modifiers:

```text
Ctrl/A  Alt/S  GUI/D  Shift/F  G  |  H  Shift/J  GUI/K  Alt/L  Ctrl/;
```

The hold-tap term is 280 ms. A key must have been idle for 150 ms before it can become a modifier. Holds trigger on release and only from the opposite hand or thumbs, reducing accidental modifiers during fast rolls.

## Thumb keys

| Position | Tap | Double/modified tap | Hold |
|---|---|---|---|
| LH1 | repeat after alpha, otherwise sticky Shift | with Shift: Caps Word | Shift |
| LH0 | Space | double: Escape | NAV |
| RH0 | Return | double: Tab | SYM |
| RH1 | Backspace | with Shift: Escape | NUM |

The main thumb hold-tap term is 200 ms with a 175 ms quick-tap window.

## Adaptive repeat and sticky Shift

LH1 inspects the previous key. If it was an alphabetic key within 1200 ms, tapping LH1 repeats that key. Otherwise, the tap becomes sticky Shift for the next key. Holding LH1 sends normal Shift.

## Caps Word

Press Shift while tapping LH1 to start Caps Word. Alphabetic keys remain shifted until an incompatible key or the cancellation binding ends the mode. This is intended for identifiers and single uppercase words without holding Shift.

## Number Word and sticky NUM

The number-word behavior activates NUM temporarily and exits when numeric input ends. The `M+?` bottom-row combo starts Number Word directly. The two inner thumbs invoke a tap dance: one tap starts Number Word; two taps make NUM sticky for the next key.

## Navigation tap and long-tap

| Tap | Hold |
|---|---|
| Left | Home |
| Right | End |
| Up | Ctrl+Home |
| Down | Ctrl+End |
| Backspace | Ctrl+Backspace |
| Delete | Ctrl+Delete |

The navigation keys use a 220 ms tap-preferred term. Ctrl is masked from the Home/End hold path so a separately held Ctrl does not accidentally turn line navigation into document navigation.

## OS-aware shortcuts

SYS selects Windows, macOS, or Linux. The `oskey` module then maps clipboard and application-switching behaviors to the current OS:

- Copy, cut, paste, undo, and redo use the platform-appropriate modifier.
- App switching holds Alt on Windows/Linux and Command on macOS.
- The dongle defaults to macOS after power-up.

Changing the OS selection does not change the Bluetooth profile. Profile and OS are separate controls on SYS.

## Smart mouse

The `E+R` combo uses a tri-state behavior to toggle Mouse. Movement uses acceleration and is tuned for a 3840×2160 display:

- normal Mouse layer: default speed
- NAV active: 3× pointer scale and 2× scroll scale
- FN active: 1/2 pointer and scroll scale

## Leaving modes

- `&to DEF` returns directly to Base and clears the active layer stack.
- `K_CANCEL` cancels Caps Word and automatic layers where assigned.
- Transparent keys fall through to the next active layer instead of sending no key.
