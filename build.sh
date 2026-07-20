#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WEST="${WEST:-${SCRIPT_DIR}/.venv/bin/west}"
ZMK_APP="${SCRIPT_DIR}/zmk/app"
CONFIG_ABS="${SCRIPT_DIR}/config"
FIRMWARE_DIR="${SCRIPT_DIR}/firmware"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log()  { printf "%b▸%b %s\n" "$GREEN" "$NC" "$*"; }
warn() { printf "%b▸%b %s\n" "$YELLOW" "$NC" "$*"; }
err()  { printf "%b▸%b %s\n" "$RED" "$NC" "$*" >&2; }

usage() {
    cat <<'EOF'
Usage: ./build.sh [target]

Targets:
  all                 Build every firmware target (default)
  left                Build the left nice!nano peripheral
  right               Build the right nice!nano peripheral
  dongle              Build the XIAO dongle with ZMK Studio
  dongle-nostudio     Build the XIAO dongle without ZMK Studio
  reset               Build both settings-reset firmwares
  reset-nice-nano     Build settings reset for nice!nano
  reset-xiao          Build settings reset for XIAO BLE
  clean               Remove generated build directories
  help                Show this help
EOF
}

ensure_west() {
    if [[ ! -x "$WEST" ]]; then
        err "West not found at $WEST"
        err "Run: python3 -m venv .venv && .venv/bin/python -m pip install west"
        exit 1
    fi
}

build_target() {
    local name="$1"
    local board="$2"
    local shield="$3"
    local snippet="${4:-}"
    local build_dir="${SCRIPT_DIR}/build/${name}"
    local -a west_args=(-b "$board")

    if [[ -n "$snippet" ]]; then
        west_args+=(-S "$snippet")
    fi

    mkdir -p "$FIRMWARE_DIR"
    log "Building ${name} (${board} / ${shield})..."

    "$WEST" build \
        -s "$ZMK_APP" \
        -d "$build_dir" \
        "${west_args[@]}" \
        -- \
        -DSHIELD="$shield" \
        -DZMK_CONFIG="$CONFIG_ABS"

    if [[ -f "${build_dir}/zephyr/zmk.uf2" ]]; then
        cp "${build_dir}/zephyr/zmk.uf2" "${FIRMWARE_DIR}/${name}.uf2"
        log "${name} -> firmware/${name}.uf2"
    elif [[ -f "${build_dir}/zephyr/zmk.bin" ]]; then
        cp "${build_dir}/zephyr/zmk.bin" "${FIRMWARE_DIR}/${name}.bin"
        log "${name} -> firmware/${name}.bin"
    else
        warn "${name} built, but no .uf2 or .bin was produced"
    fi
}

build_reset_nice_nano() {
    build_target "settings_reset" "nice_nano//zmk" "settings_reset"
}

build_reset_xiao() {
    build_target "settings_reset_xiao" "xiao_ble//zmk" "settings_reset"
}

build_dongle() {
    build_target "zyraft_dongle" "xiao_ble//zmk" "zyraft_dongle prospector_adapter" "studio-rpc-usb-uart"
}

build_dongle_nostudio() {
    build_target "zyraft_dongle_nostudio" "xiao_ble//zmk" "zyraft_dongle prospector_adapter"
}

build_left() {
    build_target "zyraft_left" "nice_nano//zmk" "zyraft_left"
}

build_right() {
    build_target "zyraft_right" "nice_nano//zmk" "zyraft_right"
}

build_all() {
    build_reset_nice_nano
    build_reset_xiao
    build_dongle
    build_dongle_nostudio
    build_left
    build_right
    log "All firmware targets built successfully."
}

target="${1:-all}"

case "$target" in
    help|-h|--help)
        usage
        ;;
    clean)
        rm -rf "${SCRIPT_DIR}/build"
        log "Removed build/."
        ;;
    all)
        ensure_west
        build_all
        ;;
    left)
        ensure_west
        build_left
        ;;
    right)
        ensure_west
        build_right
        ;;
    dongle)
        ensure_west
        build_dongle
        ;;
    dongle-nostudio)
        ensure_west
        build_dongle_nostudio
        ;;
    reset)
        ensure_west
        build_reset_nice_nano
        build_reset_xiao
        ;;
    reset-nice-nano)
        ensure_west
        build_reset_nice_nano
        ;;
    reset-xiao)
        ensure_west
        build_reset_xiao
        ;;
    *)
        err "Unknown target: $target"
        usage >&2
        exit 1
        ;;
esac
