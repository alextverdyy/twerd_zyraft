#!/usr/bin/env bash
set -euo pipefail

help_output="$(./build.sh help)"
for target in all left right dongle dongle-nostudio reset reset-nice-nano reset-xiao clean; do
    [[ "$help_output" == *"$target"* ]]
done

if ./build.sh definitely-not-a-target >/dev/null 2>&1; then
    echo "unknown target unexpectedly succeeded" >&2
    exit 1
fi
