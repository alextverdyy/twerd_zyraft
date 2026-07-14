#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────
#  Zyraft firmware build script
#  Usage:
#    ./build.sh                   Build all targets
#    ./build.sh left              Build only the left peripheral
#    ./build.sh right             Build only the right peripheral
#    ./build.sh dongle            Build the dongle (with ZMK Studio)
#    ./build.sh dongle-nostudio   Build the dongle (without ZMK Studio)
#    ./build.sh reset             Build only the settings-reset firmware
#    ./build.sh clean             Remove all build directories
# ─────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WEST="${SCRIPT_DIR}/.venv/bin/west"
ZMK_APP="zmk/app"
CONFIG="${SCRIPT_DIR}/config"

# Resolve to absolute path for west
CONFIG_ABS="$(cd "$CONFIG" && pwd)"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log()  { echo -e "${GREEN}▸${NC} $*"; }
warn() { echo -e "${YELLOW}▸${NC} $*"; }
err()  { echo -e "${RED}▸${NC} $*" >&2; }

cd "$SCRIPT_DIR"

# ── Ensure west & venv are available ─────────────────────────
if [[ ! -x "$WEST" ]]; then
    err "West not found at $WEST"
    err "Run: python3 -m venv .venv && .venv/bin/pip install west && west update"
    exit 1
fi

# ── Clean ────────────────────────────────────────────────────
if [[ "${1:-}" == "clean" ]]; then
    log "Removing build directories..."
    rm -rf build/
    log "Done."
    exit 0
fi

# ── Build helpers ────────────────────────────────────────────
build_target() {
    local name="$1"
    local board="$2"
    local shield="$3"
    local extra_args="${4:-}"

    local build_dir="build/${name}"

    log "Building ${name} (${board} / ${shield})..."

    local west_args="-b ${board}"
    if [[ -n "$extra_args" ]]; then
        west_args="${west_args} ${extra_args}"
    fi

    eval "$WEST build" \
        -s "$ZMK_APP" \
        -d "$build_dir" \
        ${west_args} \
        -- -DSHIELD=\""${shield}"\" \
        -DZMK_CONFIG="$CONFIG_ABS"

    # Find and report output
    if [[ -f "${build_dir}/zephyr/zmk.uf2" ]]; then
        log "✓ ${name} → ${build_dir}/zephyr/zmk.uf2"
    elif [[ -f "${build_dir}/zephyr/zmk.bin" ]]; then
        log "✓ ${name} → ${build_dir}/zephyr/zmk.bin"
    else
        warn "${name} built but no .uf2 or .bin found"
    fi
}

# ── Target definitions ───────────────────────────────────────
build_reset() {
    build_target "settings_reset" "nice_nano//zmk" "settings_reset"
}

build_dongle() {
    build_target "zyraft_dongle" "xiao_ble//zmk" "zyraft_dongle prospector_adapter" "-S studio-rpc-usb-uart"
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

# ── Dispatch ─────────────────────────────────────────────────
target="${1:-all}"

case "$target" in
    reset)            build_reset ;;
    dongle)           build_dongle ;;
    dongle-nostudio)  build_dongle_nostudio ;;
    left)             build_left ;;
    right)            build_right ;;
    all)
        log "Building all targets..."
        build_reset
        build_dongle
        build_dongle_nostudio
        build_left
        build_right
        echo
        log "All builds complete! Firmware files:"
        ls -lh build/*/zephyr/zmk.uf2 2>/dev/null || true
        ;;
    *)
        err "Unknown target: $target"
        echo "Usage: $0 [all|left|right|dongle|dongle-nostudio|reset|clean]"
        exit 1
        ;;
esac
