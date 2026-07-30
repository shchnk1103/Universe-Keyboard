#!/usr/bin/env bash
# T9-RESPONSIVE-PIPELINE-001 R4-B — real librime thread-affine owner proof.
# Copies an isolated RIME runtime, runs RimeBridgeTests.ThreadAffineRimeRealEngineTests
# on iOS Simulator, and writes content-free evidence.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

STAMP="$(date +%Y%m%d-%H%M%S)"
EVIDENCE_DIR="${UK_R4B_EVIDENCE_DIR:-$ROOT_DIR/docs/evidence/r4b-runtime/$STAMP}"
RUNTIME_ROOT="$EVIDENCE_DIR/runtime"
SHARED_DIR="$RUNTIME_ROOT/shared"
USER_DIR="$RUNTIME_ROOT/user"
LOG_DIR="$EVIDENCE_DIR/logs"
RESULT_FILE="$EVIDENCE_DIR/r4b-result.md"
DERIVED_DATA="${UK_R4B_DERIVED_DATA:-$EVIDENCE_DIR/DerivedData}"

# Prefer a known Simulator App Group shared tree when present; allow override.
SOURCE_SHARED_DEFAULT=""
for candidate in \
  "/Users/doubleshy0n/Library/Developer/CoreSimulator/Devices/06C5BC3E-7599-4761-A1A2-71DAEA991474/data/Containers/Shared/AppGroup/1C5D999C-6054-4B27-80A7-2079FC0B9D3F/Rime/shared" \
  "/Users/doubleshy0n/Library/Developer/CoreSimulator/Devices/06C5BC3E-7599-4761-A1A2-71DAEA991474/data/Containers/Shared/AppGroup/357A63AB-6D07-4573-B289-698E573655C1/Rime/shared"
do
  if [[ -f "$candidate/rime_ice.schema.yaml" ]]; then
    SOURCE_SHARED_DEFAULT="$candidate"
    break
  fi
done
SOURCE_SHARED="${UK_R4B_SOURCE_SHARED:-${UK_T9_SPIKE_SOURCE_SHARED:-$SOURCE_SHARED_DEFAULT}}"

# Prefer iPhone 17 Pro on iOS 26.5 when available.
DESTINATION="${UK_R4B_DESTINATION:-platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5}"

mkdir -p "$SHARED_DIR" "$USER_DIR" "$LOG_DIR"

fail() {
  local message="$1"
  {
    echo "# R4-B Real Engine Result"
    echo
    echo "- Status: **FAILED**"
    echo "- Timestamp: $(date '+%Y-%m-%d %H:%M:%S %Z')"
    echo "- Reason: $message"
    echo "- Evidence dir: \`$EVIDENCE_DIR\`"
  } >"$RESULT_FILE"
  echo "ERROR: $message" >&2
  exit 1
}

if [[ -z "$SOURCE_SHARED" || ! -d "$SOURCE_SHARED" ]]; then
  fail "Source shared RIME runtime not found. Set UK_R4B_SOURCE_SHARED."
fi
if [[ ! -f "$SOURCE_SHARED/rime_ice.schema.yaml" ]]; then
  fail "Source runtime lacks rime_ice.schema.yaml"
fi

echo "==> Evidence: $EVIDENCE_DIR"
echo "==> Copying isolated runtime from: $SOURCE_SHARED"

rsync -a \
  --exclude 'build/' \
  --exclude 'logs/' \
  --exclude '*.userdb/' \
  --exclude '*.userdb' \
  "$SOURCE_SHARED/" "$SHARED_DIR/"

cat >"$USER_DIR/installation.yaml" <<'EOF'
distribution_code_name: "UniverseKeyboardR4B"
distribution_name: "Universe Keyboard R4-B"
distribution_version: "0.0.0-r4b"
installation_id: "uk-r4b"
EOF

export UK_RIME_T9_SPIKE_SHARED_DIR="$SHARED_DIR"
export UK_RIME_T9_SPIKE_USER_DIR="$USER_DIR"
export TEST_RUNNER_UK_RIME_T9_SPIKE_SHARED_DIR="$SHARED_DIR"
export TEST_RUNNER_UK_RIME_T9_SPIKE_USER_DIR="$USER_DIR"
export SIMCTL_CHILD_UK_RIME_T9_SPIKE_SHARED_DIR="$SHARED_DIR"
export SIMCTL_CHILD_UK_RIME_T9_SPIKE_USER_DIR="$USER_DIR"
export UK_RIME_R4B_SHARED_DIR="$SHARED_DIR"
export UK_RIME_R4B_USER_DIR="$USER_DIR"
export SIMCTL_CHILD_UK_RIME_R4B_SHARED_DIR="$SHARED_DIR"
export SIMCTL_CHILD_UK_RIME_R4B_USER_DIR="$USER_DIR"

echo "==> xcodebuild RimeBridgeTests / ThreadAffineRimeRealEngineTests"
set +e
xcodebuild test \
  -project "Universe Keyboard.xcodeproj" \
  -scheme RimeBridgeTests \
  -destination "$DESTINATION" \
  -derivedDataPath "$DERIVED_DATA" \
  -only-testing:RimeBridgeTests/ThreadAffineRimeRealEngineTests \
  2>&1 | tee "$LOG_DIR/xcodebuild-r4b.log"
XC_STATUS=${PIPESTATUS[0]}
set -e

XCODEBUILD_LOG_SHA="$(shasum -a 256 "$LOG_DIR/xcodebuild-r4b.log" | awk '{print $1}')"
PASS_LINE="$(rg -n "R4B_REAL_ENGINE_RESULT passed=true" "$LOG_DIR/xcodebuild-r4b.log" || true)"
TEST_PASS="$(rg -n "testRealEngineBootstrapCreatesAndCallsOffMainThroughOwner.? passed" "$LOG_DIR/xcodebuild-r4b.log" || true)"
GATE_PASS="$(rg -n "testGateOffDefaultUnchangedByR4BBootstrapPresence.? passed" "$LOG_DIR/xcodebuild-r4b.log" || true)"
SUITE_PASS="$(rg -n "\\*\\* TEST SUCCEEDED \\*\\*|Test Suite 'ThreadAffineRimeRealEngineTests' passed" "$LOG_DIR/xcodebuild-r4b.log" || true)"
SKIP_LINE="$(rg -n "R4-B runtime|Set UK_RIME" "$LOG_DIR/xcodebuild-r4b.log" || true)"

STATUS="FAILED"
if [[ $XC_STATUS -eq 0 && -n "$PASS_LINE" && -n "$SUITE_PASS" ]]; then
  STATUS="PASSED"
elif [[ $XC_STATUS -eq 0 && -n "$TEST_PASS" && -n "$GATE_PASS" ]]; then
  STATUS="PASSED"
elif [[ $XC_STATUS -eq 0 && -n "$SKIP_LINE" && -z "$PASS_LINE" ]]; then
  STATUS="SKIPPED_NO_FIXTURE"
fi

{
  echo "# R4-B Real Engine Result"
  echo
  echo "- Status: **$STATUS**"
  echo "- Timestamp: $(date '+%Y-%m-%d %H:%M:%S %Z')"
  echo "- xcodebuild exit: $XC_STATUS"
  echo "- Destination: \`$DESTINATION\`"
  echo "- Isolated shared: \`$SHARED_DIR\`"
  echo "- Isolated user: \`$USER_DIR\`"
  echo "- Full log: \`$LOG_DIR/xcodebuild-r4b.log\`"
  echo "- Full log SHA-256: \`$XCODEBUILD_LOG_SHA\`"
  echo
  echo "## Machine summary"
  echo
  if [[ -n "$PASS_LINE" ]]; then
    echo '```'
    echo "$PASS_LINE"
    echo '```'
  else
    echo "_No R4B_REAL_ENGINE_RESULT passed=true line found._"
  fi
  echo
  echo "## XCTest excerpt"
  echo
  echo '```'
  if [[ -n "$TEST_PASS" || -n "$GATE_PASS" ]]; then
    echo "$TEST_PASS"
    echo "$GATE_PASS"
  else
    rg -n "ThreadAffineRimeRealEngine|error:|failed|FAILED|passed|skipped" "$LOG_DIR/xcodebuild-r4b.log" | tail -n 80 || true
  fi
  echo '```'
} >"$RESULT_FILE"

echo "==> Result written to $RESULT_FILE"
if [[ "$STATUS" != "PASSED" ]]; then
  exit 1
fi
