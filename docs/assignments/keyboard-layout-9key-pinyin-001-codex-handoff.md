# KEYBOARD-LAYOUT-9KEY-PINYIN-001 — Codex Implementation Review Handoff

Prepared by: Grok（🧠 Input Intelligence Maintainer / Executor）  
Handoff target: Codex（Architecture & Knowledge Steward + Quality, Performance & Release）  
Date / timezone: `2026-07-18 Asia/Shanghai`  
Branch: `feature/keyboard-layout-9key-pinyin-001`  
Base HEAD when work started (clean `main` snapshot): `44d42130bd8e2012bce7b4c034c4bc51a149dec3`  
Working tree: **dirty / uncommitted** — Human Product Owner forbade commit/push/PR until review. All implementation is local on this branch tip + unstaged files.

> Conversation is **not** repository truth. Use only the sources linked below.

---

## 1. Authority (KOS 2.0)

| Item | Source |
|---|---|
| Product Decision | [`PD-KEYBOARD-LAYOUT-9KEY-PINYIN-001`](../product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-001-authorization.md) |
| Assignment | [`keyboard-layout-9key-pinyin-001.md`](keyboard-layout-9key-pinyin-001.md) — lifecycle **`Active`** |
| Plan (non-authority scope input) | [`../plans/keyboard-layout-9key-pinyin-selection-implementation-plan.md`](../plans/keyboard-layout-9key-pinyin-selection-implementation-plan.md) |
| Architecture (base) | [ADR 0018](../architecture/decisions/0018-keyboard-layout-nine-key-and-t9-runtime.md) |
| Architecture (this feature) | [ADR 0020](../architecture/decisions/0020-t9-precise-pinyin-path-selection.md) — **Accepted for implementation after Spike; needs Architecture review before Product Gate** |
| Domain SoT | [`../KEYBOARD_LAYOUT.md`](../KEYBOARD_LAYOUT.md) |
| Input contract | [`../architecture/input-pipeline-and-marked-text.md`](../architecture/input-pipeline-and-marked-text.md) |
| Predecessors (closed) | `KEYBOARD-LAYOUT-9KEY-001`, `KEYBOARD-LAYOUT-9KEY-UI-001`（选拼音 residual → this Work Item） |

### Roles

| Role | Named |
|---|---|
| Domain Owner | Input Intelligence Maintainer |
| Executor | Grok |
| Architecture / Quality Reviewer | Codex |
| Product Approver | Product Lead |
| Human Dependency (device) | Human Product Owner — **unsatisfied** |

---

## 2. What was implemented (review scope)

### Product intent (one paragraph)

Chinese nine-key gains a **fixed-height precise pinyin path bar** above the Chinese candidate bar, plus a **选拼音** full path panel. Paths come from **Rime candidate comments**. Selecting a path is **composition refinement** via existing `RimeEngine.replaceInput` — **never** host-commits letters/digits/raw. No second candidate engine; no librime upgrade; no Extension deploy; no main-App settings toggle for V1.

### Code areas

| Layer | What changed |
|---|---|
| KeyboardCore | `T9PinyinPath` / `T9PinyinPathState` / `T9PinyinPathWindow` + `T9PinyinPathExtractor`; `KeyboardAction.selectT9PinyinPath`; `KeyboardEffect.t9PinyinPathsChanged`; `KeyboardController` path window/select/refresh/clear; `T9CompositionCommitPolicy` treats **valid mixed T9 raw** (letters/digits/`'`/space), not digit-only |
| RimeBridge tests | Real Spike `RimeT9PinyinSelectionSpikeTests` + runner `scripts/run_t9_pinyin_selection_spike.sh` |
| Keyboard Extension | Fixed 34pt path bar; height reservation; 选拼音 opens path panel; mutual exclusion vs candidate expansion; UIKit only presents/forwards |
| Docs | ADR 0020, KEYBOARD_LAYOUT, input pipeline, UI guide, RELEASE_CHECKLIST, CHANGELOG, Dashboard, Assignment |

### Explicit non-goals (must still hold)

- No librime / vendor upgrade  
- No main-App RIME deploy ownership change; no Extension deploy  
- No 26-key behavior change  
- No English nine-key / multi-tap / swipe letter  
- No parallel offline pinyin graph / second Chinese engine  
- No 颜表情 product content  
- No commit/push/PR in this package  

---

## 3. Spike gate (hard stop — **PASSED**)

| Field | Value |
|---|---|
| Result | **PASSED** |
| Summary (tracked) | [`keyboard-layout-9key-pinyin-001-spike-summary.md`](keyboard-layout-9key-pinyin-001-spike-summary.md) |
| Local archive (gitignored root `evidence/`) | `evidence/keyboard-layout-9key-pinyin-spike/20260718-201043/` |
| Runner | `UK_T9_SPIKE_ALLOW_DIRTY=1 bash scripts/run_t9_pinyin_selection_spike.sh` |
| Why dirty allowed | Human forbade commit; formal clean-HEAD archival deferred to publication |
| Source shared tree | Reused prior Spike isolated tree `evidence/keyboard-layout-9key-spike/20260716-195542/runtime/shared` (old NE1 App Group path missing) |
| Pinned librime | `1.16.1` (`rime-vendor-ios-1.16.1-lua.1`) |
| Schema | `t9` with `t9_processor` removed only |

### Machine summary (key facts)

```text
T9_PINYIN_SPIKE_RESULT passed=true
librime=1.16.1 schema=t9
comments6=o letterPath=o rawAfterLetter=o letterCandidateCount=4
comments64=ni|mi niPath=ni rawAfterNi=ni niCandidateCount=9
mixedRaw=ni4 mixedIsLetterDigit=true rawAfterDelete=ni
window6Count=4 window64Count=47
```

### Spike proves / residual

| Claim | Status |
|---|---|
| `replaceInput(letter)` sets raw, no `committedText` | Proven |
| Multi-key refine `64 → ni` | Proven |
| Mixed raw `ni4` + BackSpace | Proven |
| Candidate comments usable as paths | Proven (not always dense) |
| Key `6` always shows full `m/n/o` in top comments | **Not proven** — top window sparse (`o`); product fails closed + scans `candidateWindow` |
| Schema/vendor upgrade required | **False** — stop condition not hit |

---

## 4. Automated evidence (Executor-run)

| Check | Command / surface | Result |
|---|---|---|
| Real pinyin Spike | `scripts/run_t9_pinyin_selection_spike.sh` | **PASS** |
| KeyboardCore full | `cd Packages/KeyboardCore && swift test` | **601 passed** (includes `T9PinyinPathTests`) |
| Keyboard Extension Debug | `xcodebuild build -scheme Keyboard … CODE_SIGNING_ALLOWED=NO` | **BUILD SUCCEEDED** |
| Main App Debug | `xcodebuild build -scheme "Universe Keyboard" … CODE_SIGNING_ALLOWED=NO` | **BUILD SUCCEEDED** |
| Release + strict concurrency full matrix | — | **Not run** |
| Physical device Product Gate | — | **Not run** (Human Dependency) |

---

## 5. Architecture review checklist (Codex)

Please independently confirm or reject:

1. **ADR 0020** correctly extends (does not silently rewrite) ADR 0018, especially host-commit policy expansion from digit-only to valid mixed T9 raw.  
2. **Composition refinement** is not confused with candidate commit; failed `replaceInput` is transactional.  
3. **Path provenance** is comment-only; no parallel pinyin table; fail-closed on parse failure.  
4. **No `RimeEngine` protocol expansion**; only `replaceInput` + `candidateWindow`.  
5. **Deployment boundary** intact (ADR 0001/0018): Extension session-only.  
6. **State ownership**: business state in KeyboardCore; UIKit presentation-only.  
7. **Generation / stale window**: path panel drops or rebuilds when raw-input generation changes.  
8. **Mutual exclusion**: path expansion vs candidate expansion cannot both be active.  
9. **Height contract**: nine-key letters reserves 34pt path bar even when empty (no jump).  
10. **Typos**: mixed T9 raw still suppresses letter typo correction.

### Suggested code entry points

```text
Packages/KeyboardCore/Sources/KeyboardCore/T9PinyinPath.swift
Packages/KeyboardCore/Sources/KeyboardCore/T9PreeditResolver.swift   # T9CompositionCommitPolicy
Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+T9PinyinPath.swift
Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+PartialCommit.swift  # applyRimeOutputWithoutPartialCommit
Packages/RimeBridge/Tests/RimeBridgeTests/RimeT9PinyinSelectionSpikeTests.swift
Keyboard/Views/T9PinyinPathBarView.swift
Keyboard/Controllers/KeyboardViewController+T9PinyinPath.swift
Keyboard/Controllers/KeyboardViewController+Presentation.swift
Keyboard/Controllers/KeyboardViewController+CandidateDataSource.swift
docs/architecture/decisions/0020-t9-precise-pinyin-path-selection.md
```

### Suggested local review commands (optional)

```bash
cd "/Users/doubleshy0n/Dev/Universe Keyboard"
git status
git diff --stat
cd Packages/KeyboardCore && swift test --filter T9PinyinPathTests
# Real Spike (needs archived source tree or UK_T9_SPIKE_SOURCE_SHARED):
# UK_T9_SPIKE_ALLOW_DIRTY=1 bash scripts/run_t9_pinyin_selection_spike.sh
```

---

## 6. Quality review checklist (Codex)

1. Spike stop conditions evaluated honestly; UI did not proceed without PASS.  
2. KeyboardCore tests cover: comment parse/filter, compatibility, dedupe, mixed Space/Return/language, select success, reject rollback, typo suppress, commit clears paths.  
3. No raw-input host commit paths introduced for mixed forms.  
4. No hot-path deploy/network/file work.  
5. Builds: Keyboard + app Debug succeeded; Release matrix still open.  
6. Device matrix (Assignment / plan / RELEASE_CHECKLIST nine-key path bullets) remains **Human Dependency**.  
7. Documentation impact present and not contradictory to ADR 0018/0020.

---

## 7. Deviations from plan (must review)

| Deviation | Reason |
|---|---|
| Spike with `UK_T9_SPIKE_ALLOW_DIRTY=1` | No commit authorized; cannot satisfy clean-HEAD archival gate |
| Spike source = prior isolated shared tree | Configured NE1 App Group path missing on disk |
| Single-key `6` may not surface full `m/n/o` in top comments | Real librime/window behavior; fail-closed + window scan |
| Expansion mutual exclusion via `isPinyinPathExpanded` + existing `isCandidateExpanded` | Equivalent to planned modes; avoided large refactor |
| Release strict concurrency full matrix not run | Time/scope; call out as Quality open item |
| Work **uncommitted** | Explicit Human Product Owner constraint |

---

## 8. File inventory (working tree vs `44d4213`)

### Modified

- `CHANGELOG.md`
- `Keyboard/Controllers/KeyboardViewController.swift`
- `Keyboard/Controllers/KeyboardViewController+CandidateBar.swift`
- `Keyboard/Controllers/KeyboardViewController+CandidateDataSource.swift`
- `Keyboard/Controllers/KeyboardViewController+Layout.swift`
- `Keyboard/Controllers/KeyboardViewController+ModeActions.swift`
- `Keyboard/Controllers/KeyboardViewController+Presentation.swift`
- `Keyboard/Controllers/KeyboardViewController+Rows.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardAction.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+Candidates.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+PartialCommit.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardEffect.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardState.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/T9PreeditResolver.swift`
- `Packages/KeyboardCore/Tests/KeyboardCoreTests/FakeRimeEngine.swift`
- `docs/ENGINEERING_DASHBOARD.md`
- `docs/KEYBOARD_LAYOUT.md`
- `docs/KNOWLEDGE_INDEX.md`
- `docs/READING_MAPS.md`
- `docs/RELEASE_CHECKLIST.md`
- `docs/UI_STYLE_GUIDE.md`
- `docs/architecture/input-pipeline-and-marked-text.md`

### Added

- `Keyboard/Controllers/KeyboardViewController+T9PinyinPath.swift`
- `Keyboard/Views/T9PinyinPathBarView.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/T9PinyinPath.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+T9PinyinPath.swift`
- `Packages/KeyboardCore/Tests/KeyboardCoreTests/T9PinyinPathTests.swift`
- `Packages/RimeBridge/Tests/RimeBridgeTests/RimeT9PinyinSelectionSpikeTests.swift`
- `scripts/run_t9_pinyin_selection_spike.sh`
- `docs/architecture/decisions/0020-t9-precise-pinyin-path-selection.md`
- `docs/assignments/keyboard-layout-9key-pinyin-001.md`
- `docs/assignments/keyboard-layout-9key-pinyin-001-spike-summary.md`
- `docs/assignments/keyboard-layout-9key-pinyin-001-codex-handoff.md` (this file)
- `docs/plans/keyboard-layout-9key-pinyin-selection-implementation-plan.md`
- `docs/product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-001-authorization.md`

### Local-only (gitignored `evidence/`)

- `evidence/keyboard-layout-9key-pinyin-spike/20260718-201043/` — full Spike logs/runtime; transfer if Codex needs raw xcodebuild log

---

## 9. Requested Codex outputs

Please write an independent review record (suggested path if publishable):  
`docs/evidence/keyboard-layout-9key-pinyin-001-codex-implementation-review.md`  
or place under `docs/assignments/` if `docs/evidence/` ignore rules block new untracked files.

Requested conclusions (Architecture + Quality, separately if needed):

1. **Architecture:** Pass / Fail / Pass-with-findings on ADR 0020 + implementation boundaries.  
2. **Quality:** Pass / Fail / Pass-with-findings on Spike + automated evidence + residual risk.  
3. **Blocking P1 list** (if any) with required Executor fix before Product Gate.  
4. **Non-blocking residuals** acceptable for device gate.  
5. **Publication readiness:** whether Human may authorize commit/PR after fixes (still not Executor self-publish).  
6. **Product Gate:** still blocked on Human Dependency device matrix regardless of code Pass.

---

## 10. Executor self-check (not a Quality conclusion)

- [x] Assignment complete, no `UNKNOWN`, lifecycle `Active`  
- [x] Spike real librime, stop conditions not hit  
- [x] UI only after Spike PASS + ADR drafted  
- [x] No librime upgrade, no Extension deploy  
- [x] Business state in KeyboardCore  
- [x] KeyboardCore tests added and full package green  
- [x] Docs updated for behavior change  
- [ ] Clean-commit Spike re-archive  
- [ ] Release strict matrix  
- [ ] Physical device Product Gate  
- [ ] Codex Architecture/Quality independent conclusions  

**Handoff status:** Ready for Codex review. Executor stops for independent review.
