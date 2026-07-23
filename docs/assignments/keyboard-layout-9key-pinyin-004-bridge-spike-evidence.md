# KEYBOARD-LAYOUT-9KEY-PINYIN-004 — RimeBridge Pinned-Runtime Spike Evidence

**Date:** 2026-07-22 Asia/Shanghai  
**Executor:** Grok 4.5  
**Assignment:** KEYBOARD-LAYOUT-9KEY-PINYIN-004  
**ADR:** 0023  
**Purpose:** Prove Core-generated exact raws are accepted by pinned T9 librime without unexpected host commit. Bridge does **not** generate full Path catalogs.

## Runtime

| Field | Value |
|---|---|
| librime | `1.16.1` |
| schema | `t9` |
| Simulator | `platform=iOS Simulator,id=06C5BC3E-7599-4761-A1A2-71DAEA991474` |
| Evidence dir | `evidence/keyboard-layout-9key-pinyin-004-spike/20260722-221130/` |
| Shared runtime | `…/runtime/shared` (copied from KEYBOARD-LAYOUT-9KEY-001 spike fixture) |
| Worktree | dirty (UK_T9_SPIKE_ALLOW_DIRTY=1) |
| HEAD | `101b88919d5387d3d49c61fe20b2116f5365367e` |

## Commands

### Baseline harness (historical precise-path spike)

```bash
UK_T9_SPIKE_ALLOW_DIRTY=1 \
UK_T9_PINYIN_SPIKE_ASSIGNMENT=KEYBOARD-LAYOUT-9KEY-PINYIN-004 \
UK_T9_PINYIN_SPIKE_ADR=docs/architecture/decisions/0023-t9-complete-local-path-catalog-and-atomic-presentation.md \
UK_T9_PINYIN_SPIKE_EVIDENCE_DIR="$PWD/evidence/keyboard-layout-9key-pinyin-004-spike/20260722-221130" \
bash scripts/run_t9_pinyin_selection_spike.sh
```

Result: **PASSED** — `testPrecisePinyinPathRefinementOnPinnedLibrime`  
Summary: `T9_PINYIN_SPIKE_RESULT passed=true librime=1.16.1 schema=t9 … authorizedSuffixes=g|h …`

### 004 exact-raw cases (plan-required)

```bash
export UK_RIME_T9_SPIKE_SHARED_DIR=…/runtime/shared
export UK_RIME_T9_SPIKE_USER_DIR=…/runtime/user
export TEST_RUNNER_UK_RIME_T9_SPIKE_SHARED_DIR="$UK_RIME_T9_SPIKE_SHARED_DIR"
export TEST_RUNNER_UK_RIME_T9_SPIKE_USER_DIR="$UK_RIME_T9_SPIKE_USER_DIR"
export SIMCTL_CHILD_UK_RIME_T9_SPIKE_SHARED_DIR="$UK_RIME_T9_SPIKE_SHARED_DIR"
export SIMCTL_CHILD_UK_RIME_T9_SPIKE_USER_DIR="$UK_RIME_T9_SPIKE_USER_DIR"

xcodebuild test \
  -project "Universe Keyboard.xcodeproj" \
  -scheme RimeBridgeTests \
  -destination "platform=iOS Simulator,id=06C5BC3E-7599-4761-A1A2-71DAEA991474" \
  -derivedDataPath …/DerivedData \
  -only-testing:RimeBridgeTests/RimeT9PinyinSelectionSpikeTests/test004CatalogExactRawAcceptanceOnPinnedLibrime
```

Result: **PASSED** (0.411s)

Machine summary:

```
T9_004_RAW_SPIKE passed=true cases=8
28: raw=28 candidates=9 commit=∅ okExact=true okNoCommit=true okCandidates=true
b8: raw=b8 candidates=9 commit=∅ okExact=true okNoCommit=true okCandidates=true
cu: raw=cu candidates=9 commit=∅ okExact=true okNoCommit=true okCandidates=true
94: raw=94 candidates=9 commit=∅ okExact=true okNoCommit=true okCandidates=true
zi: raw=zi candidates=9 commit=∅ okExact=true okNoCommit=true okCandidates=true
qiu'53: raw=qiu'53 candidates=9 commit=∅ okExact=true okNoCommit=true okCandidates=true
qiul: raw=qiul candidates=9 commit=∅ okExact=true okNoCommit=true okCandidates=true
94→zi: raw=zi candidates=9 commit=∅
```

## Interpretation

| Raw | Exact raw | No unexpected commit | Candidates non-empty |
|---|---|---|---|
| `28` | yes | yes | yes (9) |
| `b8` | yes | yes | yes (9) |
| `cu` | yes | yes | yes (9) |
| `94` | yes | yes | yes (9) |
| `zi` | yes | yes | yes (9) |
| `qiu'53` | yes | yes | yes (9) |
| `qiul` | yes | yes | yes (9) |

**Conclusion for Gate entry:** Bridge accepts the exact raw forms Core generates for 004 Path selection and recovery. This does **not** replace Human Product Gate.

## Logs

- `evidence/…/spike-result.md`
- `evidence/…/logs/xcodebuild-t9-pinyin-spike.log`
- `evidence/…/logs/xcodebuild-t9-004-raw-spike.log`
