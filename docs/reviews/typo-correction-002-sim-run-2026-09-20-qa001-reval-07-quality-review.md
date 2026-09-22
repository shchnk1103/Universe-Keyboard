# Quality Review: TC2-SIM-20260920-224421-QA001-REVAL-07

**Reviewer:** Independent Quality, Performance & Release reviewer
**Date / timezone:** `2026-09-20 Asia/Shanghai`
**Mode:** Strictly read-only. No Simulator operation, rebuild, reinstall, schema deployment, recapture, source edit or publication.

| Bound | Identity |
|---|---|
| Run ID | `TC2-SIM-20260920-224421-QA001-REVAL-07` |
| Run Receipt | [`typo-correction-002-sim-run-2026-09-20-qa001-reval-07-inconclusive.md`](../evidence/typo-correction-002-sim-run-2026-09-20-qa001-reval-07-inconclusive.md) |
| Capture Authorization | [`AUTH-TYPO-CORRECTION-002-QA001-REVALIDATION-006.md`](../authorizations/AUTH-TYPO-CORRECTION-002-QA001-REVALIDATION-006.md) |
| Architecture Authorization | [`AUTH-TYPO-CORRECTION-002-QA001-REVALIDATION-07-ARCHITECTURE-001.md`](../authorizations/AUTH-TYPO-CORRECTION-002-QA001-REVALIDATION-07-ARCHITECTURE-001.md) |
| Quality Authorization | [`AUTH-TYPO-CORRECTION-002-QA001-REVALIDATION-07-QUALITY-001.md`](../authorizations/AUTH-TYPO-CORRECTION-002-QA001-REVALIDATION-07-QUALITY-001.md) |
| Architecture review | [`typo-correction-002-sim-run-2026-09-20-qa001-reval-07-architecture-review.md`](typo-correction-002-sim-run-2026-09-20-qa001-reval-07-architecture-review.md) |
| Raw artifacts | `/private/tmp/typo-correction-002-sim-runs/TC2-SIM-20260920-224421-QA001-REVAL-07/raw/` |

## Verdict

**Bounded Pass with conditions** for evidence completeness.

`TC2-CASE-QA-001` remains **Inconclusive**. Quality accepts the Architecture
bounded Pass for the evidence boundary and independently corroborates the
receipt's hashes, sequence aggregation and route/visibility sub-claims. The
named target candidate was not observed by the Human operator, so selection
and interaction checks did not run. This is not a Quality Gate, Release Gate
or product-failure conclusion.

## Review method

- Independently recomputed SHA-256 for the three retained artifacts.
- Parsed JSONL structure, event codes, timestamps, local sequences, process
  IDs, sidecar route/session/provenance fields and numeric bounds.
- Did not output or copy input text, candidate text, host text or screenshot
  contents. The screenshot was hashed only.
- Compared the independent result with the exact Run Receipt and the bound
  Architecture review.
- Did not run the app, operate the Simulator, rebuild, reinstall or collect
  new data.

## Independent SHA-256 reconciliation

All three hashes independently match the Run Receipt and Architecture review:

| Artifact | SHA-256 |
|---|---|
| `keyboard_extension.jsonl` | `3a9e85a3f6c32cb49a74d9a610c6e72ada56c8ba258c231e0229a3882f1394b0` |
| `qa001-screenshot.jpg` | `019925d642b89bee659a332ece3d936ab1930a7915d7120c3206fe2abb340229` |
| `rime-runtime-provenance.json` | `771adec0e83414bf1e204c5b253c1b23d1cbe5fce5c93a8f223c7e5811e4d9a1` |

## Structural and event reconciliation

The formal segment is sequences 304–516: 213 valid JSONL records, contiguous
and unique, `2026-09-20T14:47:14Z`–`14:47:27Z`, one keyboard process
`5CC03041-4BAA-46A1-912C-77357E4FD052`.

| Observation | Independent result |
|---|---|
| 22-letter composition | Receipt, Messages snapshot and Human report agree on `wimenjintianquhongyuan`; diagnostics themselves contain no composition text |
| `touch.terminal` / `rime.owner.published` / `ui.applied` | 44 / 22 / 22 |
| Sidecar queries | 70; all `real_rime_sidecar` / `rime_ice` / `returned` / `3 of 3` |
| Sidecar `inputLength` | 8 through 22 |
| Live session | ID `4447326552` valid and unchanged before/after every recorded query; sidecar session `4736627288` is distinct |
| Provenance receipt ID | `67A0C52E-A975-47C8-9C09-4ADA1320DF87` on all 70 queries and in the provenance file |
| Candidate visibility | 55 visibility events; sequence 516 shows bar visible, 8 cells, revision 94 |
| Human target observation | `我们今天去公园` not seen; Human-attested, not automation-attested |
| Selection / interaction | not-run because the target was not observed |

Quality does not infer candidate identity from content-free diagnostics.

## Evidence grade

`Executor-recorded + Human candidate observation`, strengthened by independent
raw-hash and sequence aggregation. This is still not automated candidate-text
proof and is not performance evidence.

The deployment-smoke bounded Pass remains a precondition only. It does not
cover this QA-001 case.

## Residuals

| ID | Disposition |
|---|---|
| QR-QA07-01 | Why the target candidate was not observed is UNKNOWN. Do not infer a product defect. |
| QR-QA07-02 | Sidecar elapsed 1–3 ms is an internal observation only; no end-to-end or 180 ms conclusion. |
| QR-QA07-03 | Capture AUTH `REVALIDATION-006` is consumed for this Run ID `REVAL-07`. A retry needs a new Authorization and Run ID. |
| QR-QA07-04 | Architecture residual AR-QA07-01 is accepted: target absence remains Human-attested. |

## Non-claims

- No Quality/Product/Release Gate Pass.
- No target-candidate recovery, selection or interaction-regression Pass.
- No INT-003, paired-performance, physical-device, VoiceOver or nine-key conclusion.
- No merge, TestFlight, Release or parent Assignment closure.

## Handoff

Product Lead owns the residual decision for this inconclusive QA-001 case.
Preserve revalidation 06 as the earlier input-mismatch attempt. Parent remains
Active. This review does not authorize another capture, publication or closure.
