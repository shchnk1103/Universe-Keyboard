# KEYBOARD-LAYOUT-9KEY-PINYIN-004 — Implementation Evidence

**Date:** 2026-07-22 Asia/Shanghai  
**Executor:** Grok 4.5  
**Assignment:** [`keyboard-layout-9key-pinyin-004.md`](keyboard-layout-9key-pinyin-004.md)  
**Plan:** [`../plans/keyboard-layout-9key-pinyin-004-complete-path-catalog-and-atomic-sync-plan.md`](../plans/keyboard-layout-9key-pinyin-004-complete-path-catalog-and-atomic-sync-plan.md)  
**Product Gate:** **NOT CLAIMED** — Human iPhone 13 Pro validation still required.  
**Codex review handoff:** [`keyboard-layout-9key-pinyin-004-codex-review-handoff.md`](keyboard-layout-9key-pinyin-004-codex-review-handoff.md)  
**First Codex conclusions:** [`keyboard-layout-9key-pinyin-004-codex-review-conclusions.md`](keyboard-layout-9key-pinyin-004-codex-review-conclusions.md) (**Reject / Fail**)  
**Remediation after conclusions:** [`keyboard-layout-9key-pinyin-004-codex-review-remediation.md`](keyboard-layout-9key-pinyin-004-codex-review-remediation.md)

## Catalog provenance

| Field | Value |
|---|---|
| Source | `Keyboard/Resources/luna_pinyin.dict.yaml` |
| Source version | `0.12.20120711` |
| SHA-256 | `971baa1f38a42d3d82f858b5bbdcad6482371f8d93a2f5d5c4ab341046419e3b` |
| Unique legal syllables | `417` (418 raw tokens minus filtered `xx`) |
| Generator | `scripts/generate_t9_pinyin_syllable_catalog.py` (version `2`) |
| License note | [`docs/architecture/t9-pinyin-syllable-catalog.md`](../architecture/t9-pinyin-syllable-catalog.md) |
| Generated Swift | `Packages/KeyboardCore/Sources/KeyboardCore/T9PinyinSyllableCatalog.generated.swift` |
| License note | In-repo RIME dictionary data; file header attributes Rime / community dictionary lineage. No network download at generate or runtime. |

Regenerate:

```bash
python3 scripts/generate_t9_pinyin_syllable_catalog.py
```

Generator fails closed if legal syllable count ≠ 417.

## What changed (allowlist summary)

### Governance

- `docs/product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-004-authorization.md`
- `docs/architecture/decisions/0023-t9-complete-local-path-catalog-and-atomic-presentation.md`
- `docs/assignments/keyboard-layout-9key-pinyin-004.md`
- `docs/assignments/keyboard-layout-9key-pinyin-004-implementation-evidence.md` (this file)
- `docs/assignments/keyboard-layout-9key-pinyin-003.md` — marked Human Product Gate failed; superseded by 004 (not rewritten as pass)
- `docs/KNOWLEDGE_INDEX.md` — 004 registration

### Core

- `T9PinyinSyllableCatalog.generated.swift` — compile-time index
- `T9PinyinLocalPathCatalog.swift` — Path kinds, ranking, snapshot type, local Path builder
- `T9PinyinPath.swift` — Path state fields (`issuedPathIDs`, `lockedLetterPrefix`, `provisionalPathID`); progressive replacement apostrophe rules
- `KeyboardController+T9PinyinPath.swift` — catalog-backed Path rebuild; prefix lock vs complete/single-digit advance; no Path `candidateWindow` discovery
- `KeyboardController+PartialCommit.swift` — nested remainder uses catalog; provisional Path projection ordering
- `T9PreeditResolver.swift` — optional provisional full-coverage Path projection
- Tests: `T9PinyinCatalogTests.swift`, updated `T9PinyinPathTests.swift`, `FakeRimeEngine.resetCallCounts()`

### UI

- `Keyboard/Views/T9PinyinPathBarView.swift` — horizontal `UICollectionView`, full Path set, ≥44pt cells, kind/selected VoiceOver
- `Keyboard/Controllers/KeyboardViewController+T9PinyinPath.swift` — revision-aware refresh; issuance authorization

## Behavioral contract implemented

1. Ordinary T9 digit → one `processKey`; Path logic extra RIME call count **0** (asserted for `28`).
2. Path legality from local catalog; RIME comments rank only.
3. `28 → bu/cu/a/b/c`; `94` retains `xi/yi/zi` without comment completeness.
4. Multi-digit letter prefix (`b` on `28`) locks without advancing; single-digit progressive letter may confirm/advance.
5. Host composition projection rejects internal digits (existing boundary retained).
6. 26-key / `usesT9InputSemantics == false` does not publish Path catalog state.

## Targeted test commands and results

Working directory: `Packages/KeyboardCore`

```bash
swift test --filter 'T9PinyinCatalogTests|T9PinyinCatalogControllerTests|T9HostPreeditSafetyTests|T9PinyinPathTests|KeyboardLayoutAndT9RuntimeTests|PartialCommitControllerTests'
```

| Suite | Result (post Codex remediation) |
|---|---|
| `T9PinyinCatalogTests` | **8/8 pass** |
| `T9PinyinCatalogControllerTests` | **3/3 pass** |
| `T9HostPreeditSafetyTests` | **6/6 pass** |
| `T9PinyinPathTests` | **49/49 pass** |
| `KeyboardLayoutAndT9RuntimeTests` | **14/14 pass** |
| `PartialCommitControllerTests` | **39/39 pass** |
| **Total** | **119/119 pass** |

See remediation doc for mapping to each Codex finding.

## RIME call-count evidence

From `T9PinyinCatalogControllerTests`:

- Digits `2` then `8`: `processKeyCallCount == 2`, `candidateWindowCallCount == 0`
- Prefix `b` on `28`: `replaceInputCallCount == 1`, `candidateWindowCallCount == 0`

## 26-key isolation evidence

- `testUsesT9FalseDoesNotLoadCatalogPaths` — letter input with `usesT9InputSemantics == false` keeps empty Path state
- `KeyboardLayoutAndT9RuntimeTests` green

## Tests not run (and why)

- Full `KeyboardCore` suite beyond the filters above — plan constraint: targeted only
- RimeBridge live spike on device/simulator pinned T9 runtime — not executed in this session (no device bridge run requested beyond Core fakes)
- Keyboard UIKit host app UI tests / Simulator UI tests — not run
- Full Xcode app build for device — not run
- Human Product Gate — **not run**

## Human Product Gate matrix (iPhone 13 Pro · 备忘录)

| # | Step | Result (Human) |
|---|---|---|
| 1 | Single nine-key press → only one visible letter | [x] |
| 2 | Input `28` → Path `bu/cu/a/b/c`; candidates compatible | [x] |
| 3 | Tap `b` → Path/candidates/marked text narrow together | [x] |
| 4 | Long `deizhaoyishengwenyixia`; at `yi` can scroll to `zi` | [x] |
| 5 | `qingweifandaowozuili` → select qing/wei/fan/dao → 请喂饭到 → Path moves to remainder | **FAIL** (first attempt + 2026-07-22 retest: A/B/C all still Fail; Phase 0 has no production fix yet) |
| 6 | `toutoumaiqiule` → 偷偷买 → qiu → 球 → Delete → Delete (`qiule` then `qiul`); Path stays | [x] |
| 7 | No internal digits in host field throughout | [x] |
| 8 | Switch 26-key: type/select/delete/space/return unchanged | [x] |

### Gate 5 failure detail (first Human attempt — do not erase)

- **B:** 单字「请」后 Path 清空/错位（必现）
- **C:** 误触 JKL → Delete → 继续输入出现 `qing wei fan fan`、Path 回首焦点（必现）
- **A:** 用户未单独勾选；自动化 FakeRime 纯数字 remainder 下 A 为 Pass
- Overall Human Product Gate: **not passed**

### Gate 5 remediation (append-only)

| Field | Value |
|---|---|
| Plan | [`../plans/keyboard-layout-9key-pinyin-004-gate5-path-partial-delete-fix-plan.md`](../plans/keyboard-layout-9key-pinyin-004-gate5-path-partial-delete-fix-plan.md) |
| Evidence | [`keyboard-layout-9key-pinyin-004-gate5-remediation-evidence.md`](keyboard-layout-9key-pinyin-004-gate5-remediation-evidence.md) |
| Phase 0 (first) | B red + weak C green — Codex Reject/Fail |
| Phase 0 (remediation) | **Done** — DEBUG `GATE5_TRACE`; B slot-rebase root cause; strict mixed raw; C scripted fan-fan/first-focus RED; aliases removed; file-hash inventory |
| Phase 1+ fix | Not started (await Codex Phase 0 re-approval) |
| Human retest | **PENDING** |

## Documentation follow-ups after Product Gate

- Update `CHANGELOG.md` only when Product accepts
- Update `KEYBOARD_LAYOUT.md` Path section for catalog authority
- Update input-pipeline / ARCHITECTURE_TIMELINE after Gate
- Independent Architecture Review + Quality Review still required before `Closed`

## Explicit non-claims (at this file’s original freeze)

- Does **not** claim full 004 Human Product Gate pass against entire exit matrix
- Does **not** claim Gate 5 product fix complete *(superseded for residual-B — see below)*
- Does **not** claim full-suite green *(later residual-B freeze: KeyboardCore 712/1 skip/0 fail)*
- Does **not** push, commit, or open PR (per plan unless user authorizes) *(historical; #27/#28 later authorized and merged)*

---

## Superseding append — Gate 5 residual landings (2026-07-23)

| Item | Status |
|---|---|
| PR #27 | MERGED — catalog + H5 residual |
| H5 residual Human | Pass (A/B/C) |
| Residual-B Path-ledger cursor | Human device **Pass**; PD Accepted; PR [#28](https://github.com/shchnk1103/Universe-Keyboard/pull/28) **MERGED** `f84a00d` |
| Evidence | remediation §21–§31 (A1 dual full-cover closeout in §31) |
| Still open | provisional-only C `XCTSkip`; formal 004 Assignment `Closed` optional |
| Full 004 Product Gate | **Not** claimed solely by residual-B |
