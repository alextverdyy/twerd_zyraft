#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PYTHON="${PYTHON:-python3}"
CHECK=false

if [[ "${1:-}" == "--check" ]]; then
    CHECK=true
elif [[ $# -gt 0 ]]; then
    printf 'Usage: %s [--check]\n' "$0" >&2
    exit 1
fi

if ! "$PYTHON" -m keymap_drawer --version >/dev/null 2>&1; then
    printf 'keymap-drawer is missing. Run: %s -m pip install -r requirements-dev.txt\n' "$PYTHON" >&2
    exit 1
fi

cd "$REPO_ROOT"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT
RENDER_DIR="$TMP_DIR/render"
mkdir -p "$RENDER_DIR/keymap-drawer" "$RENDER_DIR/docs/assets/keymap" "$RENDER_DIR/docs/assets/combos"

KEYMAP=("$PYTHON" -W ignore::DeprecationWarning -m keymap_drawer -c keymap_drawer.config.yaml)
LAYOUT=(-d config/boards/shields/zyraft/zyraft-layouts.dtsi -l zyraft_physical_layout)

"${KEYMAP[@]}" parse -z config/zyraft.keymap > "$RENDER_DIR/keymap-drawer/zyraft.yaml"

for layer in Base Nav Fn Num Sys Mouse Sym; do
    filename="${layer,,}.svg"
    "${KEYMAP[@]}" draw "${LAYOUT[@]}" --keys-only \
        -o "$RENDER_DIR/docs/assets/keymap/$filename" \
        "$RENDER_DIR/keymap-drawer/zyraft.yaml" --select-layers "$layer"
done

for group in access leader clipboard editing-right symbols-left symbols-right; do
    "$PYTHON" scripts/filter-combos.py \
        "$RENDER_DIR/keymap-drawer/zyraft.yaml" "$TMP_DIR/$group.yaml" "$group"
    "${KEYMAP[@]}" draw "${LAYOUT[@]}" --combos-only \
        -o "$RENDER_DIR/docs/assets/combos/$group.svg" \
        "$TMP_DIR/$group.yaml" --select-layers Base Nav Num
done

if $CHECK; then
    status=0
    for path in keymap-drawer/zyraft.yaml docs/assets/keymap docs/assets/combos; do
        if ! diff -ruN "$path" "$RENDER_DIR/$path"; then
            status=1
        fi
    done
    if ((status != 0)); then
        printf 'Generated keymap documentation is out of date. Run: ./scripts/draw-keymap.sh\n' >&2
        exit "$status"
    fi
    printf 'Generated keymap documentation is current.\n'
else
    mkdir -p keymap-drawer docs/assets
    cp "$RENDER_DIR/keymap-drawer/zyraft.yaml" keymap-drawer/zyraft.yaml
    rm -rf docs/assets/keymap docs/assets/combos
    cp -R "$RENDER_DIR/docs/assets/keymap" docs/assets/keymap
    cp -R "$RENDER_DIR/docs/assets/combos" docs/assets/combos
    printf 'Generated keymap-drawer/zyraft.yaml and focused SVG diagrams.\n'
fi
