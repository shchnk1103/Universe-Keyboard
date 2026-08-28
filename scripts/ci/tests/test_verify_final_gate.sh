#!/usr/bin/env bash
set -euo pipefail

script="scripts/ci/verify_final_gate.sh"

expect_failure() {
  if bash "$script" "$@" >/dev/null 2>&1; then
    echo "expected final gate failure for: $*" >&2
    exit 1
  fi
}

bash "$script" success success success true >/dev/null
bash "$script" success success skipped false >/dev/null
expect_failure failure success success true
expect_failure success failure success true
expect_failure success success skipped true
expect_failure success success success false
expect_failure success success skipped ""

echo "PASS final gate result matrix"
