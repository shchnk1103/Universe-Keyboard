#!/usr/bin/env bash
# Real librime precise-pinyin Spike. Assignment/ADR/summary destinations are
# parameterized so a follow-up Work Item cannot overwrite a Closed task record.
# Prepares an isolated T9 runtime (compatible schema, no t9_processor), runs
# RimeT9PinyinSelectionSpikeTests on pinned librime, and archives evidence.
#
# Publication archival prefers a clean committed harness. Development may set
# UK_T9_SPIKE_ALLOW_DIRTY=1 when the Human Product Owner forbids commit until review.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

STAMP="$(date +%Y%m%d-%H%M%S)"
EVIDENCE_DIR="${UK_T9_PINYIN_SPIKE_EVIDENCE_DIR:-$ROOT_DIR/evidence/keyboard-layout-9key-pinyin-spike/$STAMP}"
RUNTIME_ROOT="$EVIDENCE_DIR/runtime"
SHARED_DIR="$RUNTIME_ROOT/shared"
USER_DIR="$RUNTIME_ROOT/user"
LOG_DIR="$EVIDENCE_DIR/logs"
RESULT_FILE="$EVIDENCE_DIR/spike-result.md"
PROVENANCE_FILE="$EVIDENCE_DIR/provenance.md"

# Prefer last known good isolated rime-ice+t9 tree from KEYBOARD-LAYOUT-9KEY-001 Spike.
SOURCE_SHARED_DEFAULT="$ROOT_DIR/evidence/keyboard-layout-9key-spike/20260716-195542/runtime/shared"
SOURCE_SHARED="${UK_T9_SPIKE_SOURCE_SHARED:-$SOURCE_SHARED_DEFAULT}"
UPSTREAM_T9_URL="${UK_T9_SPIKE_UPSTREAM_URL:-https://raw.githubusercontent.com/iDvel/rime-ice/main/t9.schema.yaml}"
DERIVED_DATA="${UK_T9_SPIKE_DERIVED_DATA:-$EVIDENCE_DIR/DerivedData}"
DESTINATION="${UK_T9_SPIKE_DESTINATION:-platform=iOS Simulator,id=06C5BC3E-7599-4761-A1A2-71DAEA991474}"
ALLOW_DIRTY="${UK_T9_SPIKE_ALLOW_DIRTY:-0}"
SPIKE_ASSIGNMENT="${UK_T9_PINYIN_SPIKE_ASSIGNMENT:-KEYBOARD-LAYOUT-9KEY-PINYIN-001}"
SPIKE_ADR="${UK_T9_PINYIN_SPIKE_ADR:-docs/architecture/decisions/0020-t9-precise-pinyin-path-selection.md}"
TRACKED_SUMMARY="${UK_T9_PINYIN_SPIKE_TRACKED_SUMMARY:-$ROOT_DIR/docs/assignments/keyboard-layout-9key-pinyin-001-spike-summary.md}"

mkdir -p "$SHARED_DIR" "$USER_DIR" "$LOG_DIR"

fail() {
  local message="$1"
  {
    echo "# T9 Precise Pinyin Selection Spike Result"
    echo
    echo "- Status: **FAILED**"
    echo "- Timestamp: $(date '+%Y-%m-%d %H:%M:%S %Z')"
    echo "- Reason: $message"
    echo "- Evidence dir: \`$EVIDENCE_DIR\`"
  } >"$RESULT_FILE"
  echo "ERROR: $message" >&2
  exit 1
}

if [[ ! -d "$SOURCE_SHARED" ]]; then
  fail "Source shared RIME runtime not found: $SOURCE_SHARED"
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

mkdir -p "$USER_DIR"
cat >"$USER_DIR/installation.yaml" <<'EOF'
distribution_code_name: "UniverseKeyboardT9PinyinSpike"
distribution_name: "Universe Keyboard T9 Pinyin Spike"
distribution_version: "0.0.0-spike"
installation_id: "uk-t9-pinyin-spike"
EOF

echo "==> Fetching upstream t9.schema.yaml for provenance (best effort)"
UPSTREAM_PATH="$EVIDENCE_DIR/upstream-t9.schema.yaml"
if curl -fsSL "$UPSTREAM_T9_URL" -o "$UPSTREAM_PATH"; then
  UPSTREAM_SHA="$(shasum -a 256 "$UPSTREAM_PATH" | awk '{print $1}')"
  UPSTREAM_VERSION="$(rg -n '^\s*version:' "$UPSTREAM_PATH" | head -1 | sed 's/.*version:[[:space:]]*//' | tr -d '"' || true)"
  cp "$UPSTREAM_PATH" "$SHARED_DIR/t9.schema.yaml"
else
  echo "WARN: upstream download failed; using source tree t9.schema.yaml" >&2
  cp "$SHARED_DIR/t9.schema.yaml" "$UPSTREAM_PATH" 2>/dev/null || true
  UPSTREAM_SHA="$(shasum -a 256 "$SHARED_DIR/t9.schema.yaml" | awk '{print $1}')"
  UPSTREAM_VERSION="source-copy"
fi

echo "==> Patching unsupported t9_processor out of isolated t9.schema.yaml"
python3 - <<'PY' "$SHARED_DIR/t9.schema.yaml"
from pathlib import Path
import sys
path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8")
lines = text.splitlines(keepends=True)
out = []
removed = 0
for line in lines:
    if "t9_processor" in line:
        removed += 1
        continue
    out.append(line)
# Source trees from prior Spikes may already be patched.
path.write_text("".join(out), encoding="utf-8")
print(f"removed_t9_processor_lines={removed}")
PY

PATCHED_SHA="$(shasum -a 256 "$SHARED_DIR/t9.schema.yaml" | awk '{print $1}')"
if rg -n "t9_processor" "$SHARED_DIR/t9.schema.yaml" >/dev/null; then
  fail "Patched schema still contains t9_processor"
fi

echo "==> Ensuring schema_list includes t9"
python3 - <<'PY' "$SHARED_DIR/default.yaml"
from pathlib import Path
import sys
path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8")
if "schema: t9" in text:
    print("schema_list already contains t9")
else:
    needle = "schema_list:\n"
    if needle not in text:
        raise SystemExit("default.yaml missing schema_list")
    insertion = (
        "schema_list:\n"
        "  - schema: t9\n"
        "    name: 中文九键\n"
    )
    path.write_text(text.replace(needle, insertion, 1), encoding="utf-8")
    print("inserted t9 into schema_list")
PY

rm -rf "$SHARED_DIR/build" "$USER_DIR/build"

HARNESS_COMMIT="$(git rev-parse HEAD)"
HARNESS_BRANCH="$(git rev-parse --abbrev-ref HEAD)"

if [[ "$ALLOW_DIRTY" != "1" ]]; then
  if ! git diff-index --quiet HEAD --; then
    git status --porcelain --untracked-files=no >"$LOG_DIR/dirty-tracked-worktree.txt" || true
    fail "Tracked worktree dirty; commit harness or set UK_T9_SPIKE_ALLOW_DIRTY=1 for pre-review runs"
  fi
else
  echo "WARN: UK_T9_SPIKE_ALLOW_DIRTY=1 — evidence is development-grade, not publication-locked to a clean commit" >&2
  git status --porcelain >"$LOG_DIR/git-status-porcelain-dirty-allowed.txt" || true
fi

if [[ ! -f "$ROOT_DIR/Packages/RimeBridge/Tests/RimeBridgeTests/RimeT9PinyinSelectionSpikeTests.swift" ]]; then
  fail "Pinyin Spike test file missing"
fi

echo "==> Verifying pinned RIME vendor"
bash "$ROOT_DIR/scripts/ensure_rime_vendor.sh" verify 2>&1 | tee "$LOG_DIR/rime-vendor-verify.log"
VENDOR_LOG_SHA="$(shasum -a 256 "$LOG_DIR/rime-vendor-verify.log" | awk '{print $1}')"

echo "==> Booting destination simulator if needed"
xcrun simctl boot 06C5BC3E-7599-4761-A1A2-71DAEA991474 2>/dev/null || true

export UK_RIME_T9_SPIKE_SHARED_DIR="$SHARED_DIR"
export UK_RIME_T9_SPIKE_USER_DIR="$USER_DIR"
export TEST_RUNNER_UK_RIME_T9_SPIKE_SHARED_DIR="$SHARED_DIR"
export TEST_RUNNER_UK_RIME_T9_SPIKE_USER_DIR="$USER_DIR"
export SIMCTL_CHILD_UK_RIME_T9_SPIKE_SHARED_DIR="$SHARED_DIR"
export SIMCTL_CHILD_UK_RIME_T9_SPIKE_USER_DIR="$USER_DIR"

set +e
xcodebuild test \
  -project "Universe Keyboard.xcodeproj" \
  -scheme RimeBridgeTests \
  -configuration Debug \
  -destination "$DESTINATION" \
  -derivedDataPath "$DERIVED_DATA" \
  -only-testing:RimeBridgeTests/RimeT9PinyinSelectionSpikeTests/testPrecisePinyinPathRefinementOnPinnedLibrime \
  2>&1 | tee "$LOG_DIR/xcodebuild-t9-pinyin-spike.log"
XC_STATUS=${PIPESTATUS[0]}
set -e

XCODEBUILD_LOG_SHA="$(shasum -a 256 "$LOG_DIR/xcodebuild-t9-pinyin-spike.log" | awk '{print $1}')"
PASS_LINE="$(rg -n "T9_PINYIN_SPIKE_RESULT passed=true" "$LOG_DIR/xcodebuild-t9-pinyin-spike.log" || true)"
TEST_PASSED_LINE="$(rg -n "testPrecisePinyinPathRefinementOnPinnedLibrime' passed" "$LOG_DIR/xcodebuild-t9-pinyin-spike.log" || true)"

if [[ $XC_STATUS -eq 0 && -n "$PASS_LINE" ]]; then
  STATUS="PASSED"
else
  STATUS="FAILED"
fi

{
  echo "# T9 Precise Pinyin Selection Spike Provenance"
  echo
  echo "- Timestamp: $(date '+%Y-%m-%d %H:%M:%S %Z')"
  echo "- Branch: $HARNESS_BRANCH"
  echo "- HEAD commit: \`$HARNESS_COMMIT\`"
  echo "- Dirty worktree allowed: $ALLOW_DIRTY"
  echo "- Assignment: $SPIKE_ASSIGNMENT"
  echo "- ADR: $SPIKE_ADR"
  echo "- Upstream URL: $UPSTREAM_T9_URL"
  echo "- Upstream version field: ${UPSTREAM_VERSION:-unknown}"
  echo "- Upstream/source schema SHA-256: \`$UPSTREAM_SHA\`"
  echo "- Patched isolated schema SHA-256: \`$PATCHED_SHA\`"
  echo "- Source shared runtime: \`$SOURCE_SHARED\`"
  echo "- Isolated shared dir: \`$SHARED_DIR\`"
  echo "- Destination: \`$DESTINATION\`"
  echo "- Pinned vendor tag: \`rime-vendor-ios-1.16.1-lua.1\`"
  echo "- Vendor verify log SHA-256: \`$VENDOR_LOG_SHA\`"
  echo "- xcodebuild log SHA-256: \`$XCODEBUILD_LOG_SHA\`"
} >"$PROVENANCE_FILE"

{
  echo "# T9 Precise Pinyin Selection Spike Result"
  echo
  echo "- Status: **$STATUS**"
  echo "- Timestamp: $(date '+%Y-%m-%d %H:%M:%S %Z')"
  echo "- xcodebuild exit: $XC_STATUS"
  echo "- HEAD commit: \`$HARNESS_COMMIT\`"
  echo "- Evidence dir: \`$EVIDENCE_DIR\`"
  echo "- Provenance: \`$PROVENANCE_FILE\`"
  echo "- Full log: \`$LOG_DIR/xcodebuild-t9-pinyin-spike.log\`"
  echo
  echo "## Machine summary"
  echo
  if [[ -n "$PASS_LINE" ]]; then
    echo '```'
    echo "$PASS_LINE"
    echo '```'
  else
    echo "_No T9_PINYIN_SPIKE_RESULT passed=true line found._"
  fi
  echo
  echo "## XCTest excerpt"
  echo
  echo '```'
  if [[ -n "$TEST_PASSED_LINE" ]]; then
    echo "$TEST_PASSED_LINE"
  else
    rg -n "PinyinSelectionSpike|error:|failed|FAILED|passed|T9_PINYIN" "$LOG_DIR/xcodebuild-t9-pinyin-spike.log" | tail -n 100 || true
  fi
  echo '```'
} >"$RESULT_FILE"

# Lightweight tracked summary for Domain Owner handoff (gitignored evidence stays local).
mkdir -p "$(dirname "$TRACKED_SUMMARY")"
{
  echo "# $SPIKE_ASSIGNMENT Spike Summary"
  echo
  echo "- Status: **$STATUS**"
  echo "- Local evidence: \`$EVIDENCE_DIR\`"
  echo "- Branch: \`$HARNESS_BRANCH\`"
  echo "- HEAD: \`$HARNESS_COMMIT\`"
  echo "- Dirty allowed: \`$ALLOW_DIRTY\`"
  echo "- Timestamp: $(date '+%Y-%m-%d %H:%M:%S %Z')"
  echo
  if [[ -n "$PASS_LINE" ]]; then
    echo "## Summary line"
    echo
    echo '```'
    # strip leading line numbers from rg -n
    echo "$PASS_LINE" | sed -E 's/^[0-9]+:(.*)file-match.*/\1/' | sed -E 's/^[0-9]+:(.*)$/\1/'
    echo '```'
  fi
} >"$TRACKED_SUMMARY"

echo "==> Result: $STATUS ($RESULT_FILE)"
if [[ "$STATUS" != "PASSED" ]]; then
  exit 1
fi
