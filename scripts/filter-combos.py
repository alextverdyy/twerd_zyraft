#!/usr/bin/env python3
"""Create focused keymap-drawer YAML files for combo documentation."""

from __future__ import annotations

import argparse
from pathlib import Path

import yaml

GROUPS = {
    "access": {"ESC", "MOUSE", "NUM WORD", "Sys"},
    "leader": {"TAB", "LEAD", "LEAD+S", "Ctl+S"},
    "clipboard": {"CUT", "COPY", "PASTE"},
    "editing-right": {"BSPC", "DEL", "(", ")", "<", ">", "[", "]", "{", "}", "SYM"},
    "symbols-left": {"@", "#", "$", "%", "`", "\\", "=", "~"},
    "symbols-right": {"^", "+", "*", "&", "_", "-", "/", "|"},
}


def tap_label(binding: object) -> str:
    if isinstance(binding, dict):
        return str(binding.get("t", ""))
    return str(binding)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("source", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("group", choices=tuple(GROUPS))
    args = parser.parse_args()

    data = yaml.safe_load(args.source.read_text())
    allowed = GROUPS[args.group]
    data["combos"] = [
        combo for combo in data.get("combos", []) if tap_label(combo.get("k")) in allowed
    ]
    args.output.write_text(yaml.safe_dump(data, sort_keys=False, allow_unicode=True))


if __name__ == "__main__":
    main()
