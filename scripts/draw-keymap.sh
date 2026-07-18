#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
OUT_DIR="$REPO_ROOT/keymap-drawer"
VENV_PYTHON="$REPO_ROOT/.venv/bin/python"
KEYMAP="$VENV_PYTHON -m keymap_drawer"

cd "$REPO_ROOT"

if ! $VENV_PYTHON -m keymap_drawer --version &>/dev/null; then
    echo "Installing keymap-drawer into .venv..."
    $VENV_PYTHON -m pip install --quiet keymap-drawer
fi

mkdir -p "$OUT_DIR"

echo "Parsing keymap..."
$KEYMAP -c keymap_drawer.config.yaml parse -z config/zyraft.keymap > "$OUT_DIR/zyraft.yaml"

echo "Drawing keymap..."
$KEYMAP -c keymap_drawer.config.yaml draw \
    --ortho-layout '{"split":true,"rows":3,"columns":5,"thumbs":2}' \
    "$OUT_DIR/zyraft.yaml" > "$OUT_DIR/zyraft.svg"

echo "Done! Output: keymap-drawer/zyraft.svg"
