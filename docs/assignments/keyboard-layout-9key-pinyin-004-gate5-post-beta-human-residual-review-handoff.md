# KEYBOARD-LAYOUT-9KEY-PINYIN-004 Gate 5 — Post-β Human Residual Review Handoff

**Date:** 2026-07-23 Asia/Shanghai  
**From:** Executor (Grok 4.5)  
**To:** independent 🏛️ Architecture & Knowledge Steward + 🧪 Quality Reviewer  
**KOS 2.0 basis:** Product Lead authority remains PD-004 / Gate5 PATH / Phase1-β; this package freezes **post-β residual hotfixes** after Human H5 Pass so review roles can re-enter without chat memory.

### Independence requirement

- Reviewers **must not** be the same agent turn that implemented the hotfixes.  
- Force: recompute hashes vs §27 inventory; re-run directed matrix; scan for forbidden slot-guess signals; compare to β-limited allowlist + residual scope below.  
- Chat is not evidence.

---

## 1. Why this handoff exists

| Stage | Status |
|---|---|
| Phase 1 β-limited | Architecture Accept + Quality Pass-with-findings ([review](keyboard-layout-9key-pinyin-004-gate5-phase1-beta-independent-review.md)) |
| Human residual bugs after β | Ghost JKL `5`, bare `qingwei`, short `da` Path desync, etc. |
| Executor hotfixes | §21–§26 in [remediation evidence](keyboard-layout-9key-pinyin-004-gate5-remediation-evidence.md) |
| Human H5-A/B/C | **Pass** (device, Product Owner) |
| Evidence freeze | §27 |
| This package | Request independent re-review of **post-β residual only** |

---

## 2. Review scope

### In scope

1. Core digit ledger SoT for unconfirmed multi-digit append/delete (`sourceDigits.count > 1`), including short `da→dao`.  
2. Long progressive ghost-typo peel (H5-A).  
3. Host display: reject illegal tails; **do not** drop remaining after Path select.  
4. Resync letterization (**two policies** — do not collapse wording):
   - `shortUnconfirmedResyncRaw` (ledger ≤3, no confirmed): **first** catalog/comment-order complete syllable that **full-covers** the ledger → letter raw; else pure digits. Does not invent slots / change `sourceDigits` length.
   - `refinedConfirmedPlusRemainingRaw` (has confirmed + remaining focus): **unique** full-cover complete only → letter remaining; ambiguous/long → `confirmed' + remainingDigits`. **Never** partial long-tail letterization.  
5. Directed automated matrix + Human H5 evidence linkage.  
6. Non-claims integrity (no full B / no full Human Gate / no commit claim).

### Out of scope (do not expand)

- Full B device unchanged-raw invent-slot  
- Catalog generation / ADR 0023 rewrite  
- UIKit redesign  
- 26-key behavior  
- RimeBridge production semantics beyond existing β passthrough  
- commit / push / PR authorization  

### Primary code surfaces

- `Packages/KeyboardCore/Sources/KeyboardCore/T9CompositionIdentity.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+T9PinyinPath.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+TextEditing.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+PartialCommit.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/T9PreeditResolver.swift`
- `Packages/KeyboardCore/Tests/KeyboardCoreTests/T9PinyinPathTests.swift`
- (baseline) `PartialCommitControllerTests.swift`

---

## 3. Human evidence (owner-confirmed)

| ID | Result | Note |
|---|---|---|
| H5-A | **Pass** | typo Delete + MNO + Path qing/wei/fan; no ghost JKL |
| H5-B | **Pass** | continuous full phrase Path select keeps tail |
| H5-C | **Pass** | Path `dao/dan/fan/da/fa/e/d/f` |

Source: Human Product Owner reports in-session + remediation §26.6 / §27.1.

---

## 4. Automated freeze command

```bash
cd Packages/KeyboardCore
swift test --filter 'Gate5|HumanStandalone|HumanQingweifanda|UnconfirmedT9Delete|VisibleT9Delete|AppendDelete|WholeUnresolved|InSentenceDa|DeleteToQi|PartialCommit'
```

**Executor freeze result:** `68 tests, 1 skip, 0 fail`  
**Skip:** provisional-only mixed-raw C residual (documented, not claimed fixed as full C).

---

## 5. Hash inventory (must match disk)

See remediation evidence **§27.3**. If any production hash differs, require Executor re-freeze before Accept.

---

## 6. Architecture questions (must answer)

1. Is Core `segmentSourceDigits` the correct SoT for unconfirmed multi-digit Delete/append under ADR 0023 / β-limited identity?  
2. Does `shortUnconfirmedResyncRaw` invent slots, or only pick **first** catalog-legal **full-cover** letter raw (≠ unique-only rule used by `refinedConfirmedPlusRemainingRaw`)?  
3. Does remaining-host projection after Path select still refuse illegal tails while never dropping legal remaining slots?  
4. Are partial long-tail letterizations (`9698454` → `wo'+…`) still forbidden?  
5. Is full B still honestly fail-closed / not claimed?

---

## 7. Quality questions (must answer)

1. Independent re-run of freeze filter: pass/skip/fail counts.  
2. Hash match §27.3.  
3. Forbidden scan: no `sel_start`/`caret`/`previewLen`/汉字数 as slot authority in identity map.  
4. Host digit safety asserts still present on audited paths.  
5. Residual SKIP still correctly labeled (not silently greenwashed).

---

## 8. Expected dispositions (guidance, not predetermined)

| Outcome | Meaning |
|---|---|
| **Accept / Pass-with-findings** | Post-β residual eligible for Product Lead to consider narrowed Gate language or commit auth |
| **Reject / Fail** | Return defects; Executor remediates; no commit |
| **Accept with residual debt** | Document remaining items (e.g. provisional-only C SKIP, full B) without claiming full Gate |

---

## 9. Explicit non-claims for reviewers to enforce

- Do **not** upgrade this package to “004 Human Product Gate Pass” unless Product Lead separately runs/accepts the full frozen Human matrix for 004 exit criteria.  
- Do **not** authorize commit/push/PR in the review record unless Product Lead already published that authorization.  
- Do **not** rewrite Phase 0.5/0.6 α history or claim engine-native B coverage.

---

## 10. Return path

After independent review file is written:

1. Link it from Assignment handoff + KNOWLEDGE_INDEX.  
2. Product Lead decides: residual B research / deprioritize / **commit authorization** / full Human Gate re-run.  
3. Executor does not self-close Assignment to `Closed`.

---

## Superseding note (2026-07-23 later same day)

Residual-B Path-ledger **cursor** was Product-confirmed, implemented, Human device **Pass**, and landed via PR [#28](https://github.com/shchnk1103/Universe-Keyboard/pull/28) (`f84a00d`). See [`PD-…-GATE5-RESIDUAL-B-PATH-LEDGER-PEEL`](../product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-004-gate5-residual-b-path-ledger-peel.md) and remediation §28–§30.

**Doc A1 closed** (handoff §3.4 + remediation §31): dual full-cover policy documented — short unconfirmed = first full-cover; confirmed+remaining = unique full-cover. Remaining parked debt: provisional-only C `XCTSkip`.
