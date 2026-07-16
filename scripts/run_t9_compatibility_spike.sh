#!/usr/bin/env bash
# KEYBOARD-LAYOUT-9KEY-001 — isolated T9 compatibility Spike runner.
# Copies a complete rime-ice runtime into a temporary tree, patches upstream
# t9.schema.yaml by removing unsupported t9_processor, deploys/tests with the
# repository-pinned librime via RimeBridgeTests, and archives evidence.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

STAMP="$(date +%Y%m%d-%H%M%S)"
EVIDENCE_DIR="${UK_T9_SPIKE_EVIDENCE_DIR:-$ROOT_DIR/evidence/keyboard-layout-9key-spike/$STAMP}"
RUNTIME_ROOT="$EVIDENCE_DIR/runtime"
SHARED_DIR="$RUNTIME_ROOT/shared"
USER_DIR="$RUNTIME_ROOT/user"
LOG_DIR="$EVIDENCE_DIR/logs"
RESULT_FILE="$EVIDENCE_DIR/spike-result.md"
PROVENANCE_FILE="$EVIDENCE_DIR/provenance.md"

SOURCE_SHARED_DEFAULT="/Users/doubleshy0n/Library/Developer/CoreSimulator/Devices/06C5BC3E-7599-4761-A1A2-71DAEA991474/data/Containers/Shared/AppGroup/357A63AB-6D07-4573-B289-698E573655C1/Rime/shared"
SOURCE_SHARED="${UK_T9_SPIKE_SOURCE_SHARED:-$SOURCE_SHARED_DEFAULT}"
UPSTREAM_T9_URL="${UK_T9_SPIKE_UPSTREAM_URL:-https://raw.githubusercontent.com/iDvel/rime-ice/main/t9.schema.yaml}"
DERIVED_DATA="${UK_T9_SPIKE_DERIVED_DATA:-$EVIDENCE_DIR/DerivedData}"
# Prefer the currently booted NE1/Simulator device used by prior rime_ice evidence.
DESTINATION="${UK_T9_SPIKE_DESTINATION:-platform=iOS Simulator,id=06C5BC3E-7599-4761-A1A2-71DAEA991474}"

mkdir -p "$SHARED_DIR" "$USER_DIR" "$LOG_DIR"

fail() {
  local message="$1"
  {
    echo "# T9 Compatibility Spike Result"
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
echo "==> Copying isolated runtime from source shared tree (read-only source)"

# Copy schema/dict/lua assets only. Avoid live userdb and logs from the source App Group.
rsync -a \
  --exclude 'build/' \
  --exclude 'logs/' \
  --exclude '*.userdb/' \
  --exclude '*.userdb' \
  "$SOURCE_SHARED/" "$SHARED_DIR/"

mkdir -p "$USER_DIR"
cat >"$USER_DIR/installation.yaml" <<'EOF'
distribution_code_name: "UniverseKeyboardT9Spike"
distribution_name: "Universe Keyboard T9 Spike"
distribution_version: "0.0.0-spike"
installation_id: "uk-t9-spike"
EOF

echo "==> Fetching upstream t9.schema.yaml for provenance"
UPSTREAM_PATH="$EVIDENCE_DIR/upstream-t9.schema.yaml"
if ! curl -fsSL "$UPSTREAM_T9_URL" -o "$UPSTREAM_PATH"; then
  fail "Unable to download upstream t9.schema.yaml from $UPSTREAM_T9_URL"
fi
UPSTREAM_SHA="$(shasum -a 256 "$UPSTREAM_PATH" | awk '{print $1}')"
UPSTREAM_VERSION="$(rg -n '^\s*version:' "$UPSTREAM_PATH" | head -1 | sed 's/.*version:[[:space:]]*//' | tr -d '"')"

# Prefer freshly downloaded upstream content for the experiment so the Spike is
# not silently tied to a previously modified installed file.
cp "$UPSTREAM_PATH" "$SHARED_DIR/t9.schema.yaml"

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
if removed == 0:
    raise SystemExit("expected to remove t9_processor line(s), found none")
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

# Drop compiled build products so deploy recompiles against the patched schema.
rm -rf "$SHARED_DIR/build" "$USER_DIR/build"

HARNESS_COMMIT="$(git rev-parse HEAD)"
HARNESS_BRANCH="$(git rev-parse --abbrev-ref HEAD)"

# P2 / provenance: entire tracked worktree must match HEAD so the recorded
# commit is the complete tested source snapshot. Local gitignored evidence
# output may remain dirty/untracked.
if ! git diff-index --quiet HEAD --; then
  git status --porcelain --untracked-files=no >"$LOG_DIR/dirty-tracked-worktree.txt" || true
  fail "Tracked worktree is dirty relative to HEAD; commit or stash all tracked changes before Spike archival (see $LOG_DIR/dirty-tracked-worktree.txt)"
fi
git status --porcelain --untracked-files=normal >"$LOG_DIR/git-status-porcelain.txt" || true
TRACKED_STATUS_SHA="$(shasum -a 256 "$LOG_DIR/git-status-porcelain.txt" | awk '{print $1}')"
# Also refuse untracked source under package/app trees that could affect the build.
UNTRACKED_SOURCE="$(git ls-files --others --exclude-standard -- \
  Packages scripts "Universe Keyboard" Keyboard UniverseKeyboardTests KeyboardTests 2>/dev/null || true)"
if [[ -n "$UNTRACKED_SOURCE" ]]; then
  printf '%s\n' "$UNTRACKED_SOURCE" >"$LOG_DIR/untracked-source-paths.txt"
  fail "Untracked source paths exist under Packages/scripts/app/test trees; commit or remove them before Spike archival"
fi

if [[ ! -f "$ROOT_DIR/Packages/RimeBridge/Tests/RimeBridgeTests/RimeT9CompatibilitySpikeTests.swift" ]]; then
  fail "Spike test file missing from worktree"
fi
# Ensure the recorded commit actually contains the harness when history is available.
if git cat-file -e "${HARNESS_COMMIT}:Packages/RimeBridge/Tests/RimeBridgeTests/RimeT9CompatibilitySpikeTests.swift" 2>/dev/null \
  && git cat-file -e "${HARNESS_COMMIT}:scripts/run_t9_compatibility_spike.sh" 2>/dev/null; then
  HARNESS_IN_COMMIT="yes"
else
  fail "HEAD commit ${HARNESS_COMMIT} does not contain both Spike XCTest and runner; commit harness before running Spike"
fi

echo "==> Verifying pinned RIME vendor presence (failure fails Spike)"
if [[ ! -x "$ROOT_DIR/scripts/ensure_rime_vendor.sh" ]]; then
  fail "scripts/ensure_rime_vendor.sh is missing or not executable"
fi
set +e
bash "$ROOT_DIR/scripts/ensure_rime_vendor.sh" verify 2>&1 | tee "$LOG_DIR/rime-vendor-verify.log"
VENDOR_STATUS=${PIPESTATUS[0]}
set -e
if [[ $VENDOR_STATUS -ne 0 ]]; then
  fail "Pinned RIME vendor verification failed with exit $VENDOR_STATUS (see $LOG_DIR/rime-vendor-verify.log)"
fi
VENDOR_LOG_SHA="$(shasum -a 256 "$LOG_DIR/rime-vendor-verify.log" | awk '{print $1}')"

echo "==> Running RimeBridge T9 Spike test on pinned iOS Simulator librime"
# Host export + TEST_RUNNER_/SIMCTL_CHILD_ variants so XCTest on Simulator can see the paths.
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
  -only-testing:RimeBridgeTests/RimeT9CompatibilitySpikeTests/testPinnedLibrimeCanSelectT9AndProcessDigitSequenceAfterRemovingUnsupportedProcessor \
  2>&1 | tee "$LOG_DIR/xcodebuild-t9-spike.log"
XC_STATUS=${PIPESTATUS[0]}
set -e

XCODEBUILD_LOG_SHA="$(shasum -a 256 "$LOG_DIR/xcodebuild-t9-spike.log" | awk '{print $1}')"
PASS_LINE="$(rg -n "T9_SPIKE_RESULT passed=true" "$LOG_DIR/xcodebuild-t9-spike.log" || true)"
TEST_PASSED_LINE="$(rg -n "Test Case '.-testPinnedLibrimeCanSelectT9AndProcessDigitSequenceAfterRemovingUnsupportedProcessor' passed" "$LOG_DIR/xcodebuild-t9-spike.log" || true)"
HAS_CANDIDATES="$(rg -n "candidateCount=[1-9]" "$LOG_DIR/xcodebuild-t9-spike.log" || true)"
# Reject empty preedit markers such as preeditAfter64= or preeditAfter64=nil
HAS_PREEDIT="$(rg -n "preeditAfter64=[^[:space:]]+" "$LOG_DIR/xcodebuild-t9-spike.log" | rg -v "preeditAfter64=nil" || true)"

if [[ $XC_STATUS -eq 0 && -n "$PASS_LINE" && -n "$HAS_CANDIDATES" && -n "$HAS_PREEDIT" ]]; then
  STATUS="PASSED"
else
  STATUS="FAILED"
fi

{
  echo "# T9 Spike Provenance"
  echo
  echo "- Timestamp: $(date '+%Y-%m-%d %H:%M:%S %Z')"
  echo "- Branch: $HARNESS_BRANCH"
  echo "- Harness commit (must contain Spike test + runner): \`$HARNESS_COMMIT\`"
  echo "- Harness present in commit: $HARNESS_IN_COMMIT"
  echo "- Tracked worktree clean relative to HEAD: yes"
  echo "- git status porcelain SHA-256: \`$TRACKED_STATUS_SHA\`"
  echo "- Upstream URL: $UPSTREAM_T9_URL"
  echo "- Upstream version field: ${UPSTREAM_VERSION:-unknown}"
  echo "- Upstream SHA-256: \`$UPSTREAM_SHA\`"
  echo "- Patched isolated schema SHA-256: \`$PATCHED_SHA\`"
  echo "- Patch: remove lines containing \`t9_processor\` only"
  echo "- Source shared runtime (read-only copy source): \`$SOURCE_SHARED\`"
  echo "- Isolated shared dir: \`$SHARED_DIR\`"
  echo "- Isolated user dir: \`$USER_DIR\`"
  echo "- Destination: \`$DESTINATION\`"
  echo "- Pinned vendor tag (from docs/architecture/rime-artifacts.md): \`rime-vendor-ios-1.16.1-lua.1\`"
  echo "- Vendor verify log SHA-256: \`$VENDOR_LOG_SHA\`"
  echo "- xcodebuild full log SHA-256: \`$XCODEBUILD_LOG_SHA\`"
  echo "- Vendor verify required: yes (non-zero exit fails Spike)"
  if [[ -f "$ROOT_DIR/config/rime-vendor-manifest.env" ]]; then
    echo "- Vendor manifest excerpt:"
    echo
    echo '```'
    sed -n '1,40p' "$ROOT_DIR/config/rime-vendor-manifest.env"
    echo '```'
  fi
} >"$PROVENANCE_FILE"

{
  echo "# T9 Compatibility Spike Result"
  echo
  echo "- Status: **$STATUS**"
  echo "- Timestamp: $(date '+%Y-%m-%d %H:%M:%S %Z')"
  echo "- xcodebuild exit: $XC_STATUS"
  echo "- Harness commit: \`$HARNESS_COMMIT\`"
  echo "- Evidence dir: \`$EVIDENCE_DIR\`"
  echo "- Provenance: \`$PROVENANCE_FILE\`"
  echo "- Full log: \`$LOG_DIR/xcodebuild-t9-spike.log\`"
  echo "- Full log SHA-256: \`$XCODEBUILD_LOG_SHA\`"
  echo "- Vendor verify log SHA-256: \`$VENDOR_LOG_SHA\`"
  echo "- Upstream schema SHA-256: \`$UPSTREAM_SHA\`"
  echo "- Patched schema SHA-256: \`$PATCHED_SHA\`"
  echo
  echo "## Required checks"
  echo
  echo "| Check | Result |"
  echo "|---|---|"
  echo "| Isolated temp deploy directory | yes (\`$RUNTIME_ROOT\`) |"
  echo "| Upstream t9.schema.yaml captured | yes (SHA-256 \`$UPSTREAM_SHA\`) |"
  echo "| Unsupported t9_processor removed | yes (patched SHA-256 \`$PATCHED_SHA\`) |"
  echo "| Vendor verify succeeded | yes (SHA-256 \`$VENDOR_LOG_SHA\`) |"
  echo "| Harness commit contains Spike test | $HARNESS_IN_COMMIT (\`$HARNESS_COMMIT\`) |"
  echo "| Pinned librime used via RimeBridgeTests | yes (scheme RimeBridgeTests) |"
  if [[ -n "$PASS_LINE" && -n "$HAS_CANDIDATES" ]]; then
    echo "| Schema selected + non-empty candidates + preedit + delete | see summary below |"
  else
    echo "| Schema selected + non-empty candidates + preedit + delete | **not proven** |"
  fi
  echo
  echo "## Machine summary line"
  echo
  if [[ -n "$PASS_LINE" ]]; then
    echo '```'
    echo "$PASS_LINE"
    echo '```'
  else
    echo "_No T9_SPIKE_RESULT passed=true line found._"
  fi
  echo
  echo "## XCTest verdict excerpt"
  echo
  echo '```'
  if [[ -n "$TEST_PASSED_LINE" ]]; then
    echo "$TEST_PASSED_LINE"
  else
    rg -n "T9CompatibilitySpike|error:|failed|FAILED|passed" "$LOG_DIR/xcodebuild-t9-spike.log" | tail -n 80 || true
  fi
  echo '```'
} >"$RESULT_FILE"

echo "==> Result written to $RESULT_FILE"
if [[ "$STATUS" != "PASSED" ]]; then
  exit 1
fi
