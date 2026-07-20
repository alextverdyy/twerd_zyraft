# Build and flash

## Fresh local setup

```bash
python3 -m venv .venv
.venv/bin/python -m pip install -r requirements-dev.txt
.venv/bin/west init -l config
.venv/bin/west update
.venv/bin/west packages pip --install
```

West reconstructs the ignored ZMK, Zephyr, and module directories from `config/west.yml`. The `west packages` step installs the Python packages required by Zephyr's build scripts.

## Build targets

```bash
./build.sh help
./build.sh all
./build.sh left
./build.sh right
./build.sh dongle
./build.sh dongle-nostudio
./build.sh reset
./build.sh reset-nice-nano
./build.sh reset-xiao
```

| Target | Board / shield | Output |
|---|---|---|
| `left` | nice!nano / `zyraft_left` | `firmware/zyraft_left.uf2` |
| `right` | nice!nano / `zyraft_right` | `firmware/zyraft_right.uf2` |
| `dongle` | XIAO BLE / `zyraft_dongle prospector_adapter` | `firmware/zyraft_dongle.uf2` |
| `dongle-nostudio` | XIAO BLE / same shields | `firmware/zyraft_dongle_nostudio.uf2` |
| `reset-nice-nano` | nice!nano / `settings_reset` | `firmware/settings_reset.uf2` |
| `reset-xiao` | XIAO BLE / `settings_reset` | `firmware/settings_reset_xiao.uf2` |

`all` builds every row. `reset` builds both reset images.

## Normal flashing

Flash normal updates in this order:

```text
1. zyraft_dongle.uf2  -> XIAO BLE dongle
2. zyraft_left.uf2    -> left nice!nano
3. zyraft_right.uf2   -> right nice!nano
```

Enter the board's UF2 bootloader, mount the exposed drive, and copy the corresponding file. Button sequences depend on the controller and bootloader version, so use the controller's documented bootloader procedure.

## Settings reset

Reset firmware is only for stale Bluetooth pairings or corrupted settings. It is not required for normal keymap updates.

1. Flash `settings_reset_xiao.uf2` to the dongle.
2. Flash `settings_reset.uf2` to each affected nice!nano peripheral.
3. Flash the normal dongle, left, and right firmware again.
4. Pair the split again.

## ZMK Studio

`zyraft_dongle.uf2` includes the `studio-rpc-usb-uart` snippet and enables ZMK Studio. Use `zyraft_dongle_nostudio.uf2` when Studio or its extra memory use is not needed.

The dongle uses the Prospector display and defaults to macOS shortcuts. The SYS layer can select Windows, macOS, or Linux independently of the Bluetooth profile.

## Regenerate diagrams

```bash
PYTHON=.venv/bin/python ./scripts/draw-keymap.sh
PYTHON=.venv/bin/python ./scripts/draw-keymap.sh --check
```

The first command updates tracked YAML/SVG files. The second fails when generated documentation does not match the keymap source.
