---
name: zmk-zyraft-devices
description: ZMK device configuration reference for the Zyraft keyboard. Covers Kconfig options (conf files), west.yml manifests, build.yaml matrix, and zmk-helpers module. Load when changing device-level config.
---

## Device Configuration Files
The configuration is managed by:
- `config/boards/shields/zyraft/zyraft_left.conf` (Left peripheral)
- `config/boards/shields/zyraft/zyraft_right.conf` (Right peripheral)
- `config/boards/shields/zyraft/zyraft_dongle.conf` (Dongle with Prospector status screen)

Format for these files:
```
CONFIG_OPTION_NAME=y     # enable
CONFIG_OPTION_NAME=n     # disable
CONFIG_OPTION_NAME=<value>  # set value
```

### Common options
#### Sleep / Power
```c
CONFIG_ZMK_SLEEP=y/n                        // Enable deep sleep
CONFIG_ZMK_IDLE_SLEEP_TIMEOUT=<ms>          // Sleep timeout (e.g., 900000 = 15min)
```

#### Display
```c
CONFIG_ZMK_DISPLAY=y/n                      // Enable status screen
```

#### Bluetooth
```c
CONFIG_BT_CTLR_TX_PWR_PLUS_8=y/n            // +8dB transmit power (for dongle/peripheral range)
CONFIG_ZMK_BLE_PASSKEY_ENTRY=y/n             // BLE pairing passkey
CONFIG_ZMK_SPLIT_BLE_CENTRAL_BATTERY_LEVEL_FETCHING=y
CONFIG_ZMK_SPLIT_BLE_CENTRAL_BATTERY_LEVEL_PROXY=y
```

#### ZMK Studio
```c
CONFIG_ZMK_STUDIO=y/n                        // Enable ZMK Studio runtime keymap editing
```

## Zephyr Manifest (`config/west.yml`)
Controls which ZMK version and external modules/drivers are imported. The Zyraft setup relies on multiple external modules:

```yaml
manifest:
  remotes:
    - name: zmkfirmware
      url-base: https://github.com/zmkfirmware
    - name: urob
      url-base: https://github.com/urob
    - name: carrefinho
      url-base: https://github.com/carrefinho
    - name: dhruvinsh
      url-base: https://github.com/dhruvinsh
  projects:
    - name: zmk
      remote: zmkfirmware
      revision: main
      import: app/west.yml
    - name: zmk-helpers
      remote: urob
      revision: main
    - name: zmk-unicode
      remote: urob
      revision: main
    - name: zmk-auto-layer
      remote: urob
      revision: main
    - name: zmk-adaptive-key
      remote: urob
      revision: main
    - name: zmk-leader-key
      remote: urob
      revision: main
    - name: zmk-tri-state
      remote: dhruvinsh
      revision: main
    - name: prospector-zmk-module
      remote: carrefinho
      revision: feat/new-status-screens
  self:
    path: config
```

### urob helper modules
Included from `config/keymap/definitions.dtsi`:
```c
#include <behaviors/num_word.dtsi> // Requires zmk-auto-layer
#include <behaviors/unicode.dtsi> // Requires zmk-unicode
#include <zmk-helpers/helper.h> // Requires zmk-helpers
```

## Build Matrix (`build.yaml`)
Located in the root of the workspace. It specifies the boards, shields, and build targets:

```yaml
include:
  # Settings reset for nice!nano peripherals
  - board: nice_nano//zmk
    shield: settings_reset
    artifact-name: settings_reset
  # Settings reset for the XIAO BLE dongle
  - board: xiao_ble//zmk
    shield: settings_reset
    artifact-name: settings_reset_xiao
  # Dongle with Prospector screen and ZMK Studio
  - board: xiao_ble//zmk
    shield: zyraft_dongle prospector_adapter
    artifact-name: zyraft_dongle
    snippet: studio-rpc-usb-uart
  # Fallback dongle without ZMK Studio
  - board: xiao_ble//zmk
    shield: zyraft_dongle prospector_adapter
    artifact-name: zyraft_dongle_nostudio
  # Left peripheral
  - board: nice_nano//zmk
    shield: zyraft_left
    artifact-name: zyraft_left
  # Right peripheral
  - board: nice_nano//zmk
    shield: zyraft_right
    artifact-name: zyraft_right
```

### Targets
- `nice_nano//zmk` + `settings_reset`: clear nice!nano settings/BLE bonds.
- `xiao_ble//zmk` + `settings_reset`: clear XIAO dongle settings/BLE bonds.
- `xiao_ble//zmk` + `zyraft_dongle prospector_adapter`: The central dongle receiver.
- `nice_nano//zmk` + `zyraft_left` / `zyraft_right`: Left/right split keyboard halves.

## Validation Checklist
When changing device config:
- [ ] `.conf` files: CONFIG_ syntax correct (`=y`/`=n`/`=<value>`)
- [ ] `.conf` files: no conflicting options
- [ ] `west.yml`: revision/branch exists for all remotes
- [ ] `build.yaml`: valid YAML, matching board/shield configs
- [ ] shield names match actual directories under `config/boards/shields/`
- [ ] if enabling Studio: snippet + cmake-args/configs added for central side (`zyraft_dongle`)
- [ ] no changes to files inside `zmk-helpers/` or other imported modules (managed by West)
