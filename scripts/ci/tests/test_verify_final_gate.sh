#!/usr/bin/env bash
set -euo pipefail

script="scripts/ci/verify_final_gate.sh"

expect_failure() {
  if bash "$script" "$@" >/dev/null 2>&1; then
    echo "expected final gate failure for: $*" >&2
    exit 1
  fi
}

# full: every heavy job succeeded
bash "$script" success success true success success success success success >/dev/null

# docs_only: every heavy job skipped
bash "$script" success success false skipped skipped skipped skipped skipped >/dev/null

expect_failure failure success true success success success success success
expect_failure success failure true success success success success success
expect_failure success success "" success success success success success

# full path cannot accept skip/failure/cancel/missing on any heavy job
expect_failure success success true skipped success success success success
expect_failure success success true success failure success success success
expect_failure success success true success success cancelled success success
expect_failure success success true success success success success
expect_failure success success true success success success success skipped

# docs_only cannot accept success/failure/missing on any heavy job
expect_failure success success false success skipped skipped skipped skipped
expect_failure success success false skipped skipped failure skipped skipped
expect_failure success success false skipped skipped skipped skipped
expect_failure success success false skipped skipped skipped skipped success

# legacy four-argument calling convention is no longer a valid matrix
expect_failure success success success true

echo "PASS final gate result matrix"
