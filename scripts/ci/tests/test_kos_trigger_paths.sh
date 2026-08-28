#!/usr/bin/env bash
set -euo pipefail

runner="scripts/ci/run_lightweight_checks.sh"

for required_path in \
  '".kos"' \
  '"docs/kos/UPGRADE_STATUS.md"' \
  '"docs/kos/upgrade-records"'
do
  if ! grep -Fq "$required_path" "$runner"; then
    echo "missing KOS governance trigger path: $required_path" >&2
    exit 1
  fi
done

echo "PASS KOS governance trigger paths"
