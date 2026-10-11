# Quality Review: TC2-SIM-20260922-183859-QA001-REVAL-08

**Reviewer:** Quality, Performance & Release reviewer role (read-only). Executed by Grok (iOS开发大师) under Human Authorization after Architecture Pass-with-conditions. **Multi-role residual:** the same agent was capture Executor and Architecture executor; this review is limited to independent completeness checks against retained artifacts.
**Date / timezone:** `2026-09-22 Asia/Shanghai`
**Mode:** Strictly read-only. No Simulator operation, rebuild, reinstall, recapture, source edit, Gate, or Assignment Close.

| Bound | Identity |
|---|---|
| Run ID | `TC2-SIM-20260922-183859-QA001-REVAL-08` |
| Run Receipt | [`typo-correction-002-sim-run-2026-09-22-qa001-reval-08-target-observed.md`](../evidence/typo-correction-002-sim-run-2026-09-22-qa001-reval-08-target-observed.md) |
| Capture Authorization | [`AUTH-TYPO-CORRECTION-002-QA001-REVALIDATION-08-FRESH-PACKAGE-001`](../authorizations/AUTH-TYPO-CORRECTION-002-QA001-REVALIDATION-08-FRESH-PACKAGE-001.md) |
| Architecture Authorization | [`AUTH-TYPO-CORRECTION-002-QA001-REVALIDATION-08-ARCHITECTURE-001`](../authorizations/AUTH-TYPO-CORRECTION-002-QA001-REVALIDATION-08-ARCHITECTURE-001.md) |
| Quality Authorization | [`AUTH-TYPO-CORRECTION-002-QA001-REVALIDATION-08-QUALITY-001`](../authorizations/AUTH-TYPO-CORRECTION-002-QA001-REVALIDATION-08-QUALITY-001.md) |
| Architecture review | [`typo-correction-002-sim-run-2026-09-22-qa001-reval-08-architecture-review.md`](typo-correction-002-sim-run-2026-09-22-qa001-reval-08-architecture-review.md) |
| Child Assignment | [`TYPO-CORRECTION-002-QA001-REVALIDATION-08-FRESH-PACKAGE-001`](../assignments/typo-correction-002-qa001-revalidation-08-fresh-package-001.md) |
| Parent | [`TYPO-CORRECTION-002`](../assignments/typo-correction-002.md) — Active |
| Raw artifacts | `/private/tmp/typo-correction-002-sim-runs/TC2-SIM-20260922-183859-QA001-REVAL-08/raw/` |

## Verdict

**Pass with conditions** for **evidence completeness** of the reval-08 observation slice.

Quality accepts the Architecture **Pass with conditions** for the evidence boundary and independently corroborates package/raw hashes and the tip-capability explanation for missing `rime-runtime-provenance.json`. The named-target claim（「我们今天去公园」visible, selectable, position 2）remains **Human-attested**; Quality does not upgrade it to automation-attested candidate-text proof.

For this Assignment’s Exit Criteria (fresh package + Human visibility/selectability attestation + non-claims), the evidence set is **complete enough** under the stated conditions. This is **not** a Quality Gate, Product Gate, or Assignment Close.

## Review method

- Independently recomputed SHA-256 for four package binaries and eight retained raw files.
- Confirmed absence of `keyboard_extension.jsonl` and `rime-runtime-provenance.json` in retained raw.
- Confirmed install tip `e1b28ae` lacks `RimeRuntimeProvenance.swift` (git cat-file).
- Compared results to the Run Receipt and Architecture review.
- Did not operate Simulator, rebuild, reinstall, OCR the screenshot, or infer candidate text.

## Independent SHA-256 reconciliation

Package binaries match the receipt and Architecture review:

| Member | SHA-256 |
|---|---|
| App executable | `927bfcbbb7e75a55dc045c6863e0cd1e6a4a9f55348464740ee0d0a709ca4273` |
| App debug dylib | `5229565e7fd6757149bdf009d277c7f07b499cfaae0096b20c4ed54e9b90ec37` |
| Keyboard executable | `22539e904e18f2d91b17b575fe1eb96b90022f40c0c8afb9360660a55298d41a` |
| Keyboard debug dylib | `f35d92acb06a4b36c5886071b89bbe5005640e23bca7f78c86b120a08093fd5a` |

Raw artifacts match the receipt table (`package-identity.txt`, yaml/json receipts, `qa001-post-observation.png`).

## Completeness reconciliation

| Evidence element | Quality disposition |
|---|---|
| Fresh install tip `e1b28ae…` / CI binding A recorded | Complete |
| New Run ID + new package hashes ≠ reval-07 | Complete (independently re-hashed) |
| Simulator UDID / Messages host / phrase binding | Complete in receipt |
| Forbidden same-package reuse avoided | Complete |
| Ice environment identity | Complete **via App Group Ice preference keys** (Architecture-accepted tip writer gap); **not** via on-disk provenance receipt |
| Exact phrase entry via real keyboard | Executor-protocol + Human-attested; **not** journal-reverified (no JSONL) |
| Target visible + selectable + position 2 | **Human-attested only**; screenshot hashed, not used for text identity |
| Sidecar route / touch counts | **Absent** (no `keyboard_extension.jsonl`) — accepted as residual, not a completeness failure for this Assignment’s Exit Criteria |
| Explicit non-claims | Present in receipt and Architecture review |
| Architecture review | Present; Pass with conditions — accepted as prerequisite |

## Evidence grade

`Executor-recorded + Human candidate observation`, with independent hash re-verification and Architecture boundary review. Still **not** automated candidate-text proof and **not** content-free journal proof of input/route.

## Residuals

| ID | Disposition |
|---|---|
| QR-QA08-01 | Accept AR-QA08-01 multi-role residual; Human may request a different-agent Quality re-review if stronger independence is required |
| QR-QA08-02 | Accept AR-QA08-02: no JSONL — no independent touch/sidecar reconciliation; do not invent route Pass |
| QR-QA08-03 | Accept AR-QA08-03: tip `e1b28ae` writer gap; App Group Ice prefs are the environment binding |
| QR-QA08-04 | Accept AR-QA08-04: position/selectability not machine-verified |
| QR-QA08-05 | Architecture docs commit `5e471f7` is local ahead of origin until a separate push AUTH; does not affect observation completeness |

## Non-claims

- No Quality / Product / Release Gate Pass.
- No INT-003, paired-performance, or 180 ms conclusion.
- No selection / post-selection interaction Pass (not-run under capture AUTH).
- No Assignment Close, parent Close, undraft/merge of PR #145, or restore of `RimeRuntimeProvenance` on main.
- No claim of on-disk provenance receipt ID parity with reval-07.

## Handoff

Product Lead may authorize **Close** of child [`TYPO-CORRECTION-002-QA001-REVALIDATION-08-FRESH-PACKAGE-001`](../assignments/typo-correction-002-qa001-revalidation-08-fresh-package-001.md) with explicit acceptance of QR-QA08-01..05, and/or authorize commit/push of this Quality package onto draft PR #145. Parent `TYPO-CORRECTION-002` remains Active.
