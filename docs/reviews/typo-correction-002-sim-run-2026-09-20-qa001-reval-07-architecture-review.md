# Architecture Review: TC2-SIM-20260920-224421-QA001-REVAL-07

**Reviewer:** Independent Architecture & Knowledge Steward (not the capture Executor)
**Date / timezone:** `2026-09-20 Asia/Shanghai`
**Mode:** Read-only. No Simulator re-run, no code change, no commit, no publication, no Gate close.

| Bound | Identity |
|---|---|
| Run ID | `TC2-SIM-20260920-224421-QA001-REVAL-07` |
| Run Receipt | [`typo-correction-002-sim-run-2026-09-20-qa001-reval-07-inconclusive.md`](../evidence/typo-correction-002-sim-run-2026-09-20-qa001-reval-07-inconclusive.md) |
| Capture Authorization | [`AUTH-TYPO-CORRECTION-002-QA001-REVALIDATION-006.md`](../authorizations/AUTH-TYPO-CORRECTION-002-QA001-REVALIDATION-006.md) |
| Architecture Authorization | [`AUTH-TYPO-CORRECTION-002-QA001-REVALIDATION-07-ARCHITECTURE-001.md`](../authorizations/AUTH-TYPO-CORRECTION-002-QA001-REVALIDATION-07-ARCHITECTURE-001.md) |
| Continuation Assignment | [`TYPO-CORRECTION-002-PARENT-REVALIDATION-002`](../assignments/typo-correction-002-parent-revalidation-002.md) |
| Parent Assignment | [`TYPO-CORRECTION-002`](../assignments/typo-correction-002.md) |
| Raw artifacts | `/private/tmp/typo-correction-002-sim-runs/TC2-SIM-20260920-224421-QA001-REVAL-07/raw/` |

This review consumes the Architecture Authorization for **evidence-boundary
disposition only**. It does not consume INT-003, paired-performance, Product,
Quality or Release authority, and it does not upgrade `TC2-CASE-QA-001`.

## Verdict

**Bounded Pass** for the QA-001 revalidation 07 evidence boundary.

Independent re-hash and JSONL parse of the retained raw artifacts corroborate
the Run Receipt on: exact package/RIME provenance continuity, reset-to-formal
sequence boundary, 22 owner/UI updates with 44 `touch.terminal` events, 70
`real_rime_sidecar` queries on `rime_ice`, and a visible candidate bar. The
case result remains **inconclusive** because the named target candidate is
Human-attested as absent. This review cannot prove that the target existed or
did not exist in the candidate list, and it cannot be used as a product-failure
or recovery-Pass claim.

## Independent checks (this review)

Raw SHA-256 values were recomputed and match the receipt:

| Artifact | SHA-256 (this review) |
|---|---|
| `keyboard_extension.jsonl` | `3a9e85a3f6c32cb49a74d9a610c6e72ada56c8ba258c231e0229a3882f1394b0` |
| `qa001-screenshot.jpg` | `019925d642b89bee659a332ece3d936ab1930a7915d7120c3206fe2abb340229` |
| `rime-runtime-provenance.json` | `771adec0e83414bf1e204c5b253c1b23d1cbe5fce5c93a8f223c7e5811e4d9a1` |

JSONL was summarized by field names and numeric bounds only. No raw pinyin,
candidate text or host text is copied here. The screenshot was hashed only and
was not used as candidate-text identity.

### 1. Exact `rime_ice` provenance — Pass

`rime-runtime-provenance.json` independently shows:

- `activeSchemaID` / `schemeID` = `rime_ice`
- `source=downloaded`, `sourceVariantID=nju`
- artifact `rime-ice-20260630-675d23b0`
- archive SHA-256 `675d23b070be00e1b800f9a6db033ef98f4493cd5b568ed8aa3b3541769c46ac`
- installed-content SHA-256 `2e906d14853255cd0eba534e2b40791008c2cee65fa5a6e50b40bbd159cb6c26`
- receipt ID `67A0C52E-A975-47C8-9C09-4ADA1320DF87`
- `librimeVersion=1.16.1`, `luaAvailable=true`, `luaRuntimeSmokePassed=true`, `runtimeSmokePassed=true`

This matches the accepted deployment-smoke identity. It is a real deployed Ice
provenance object, not a fixture name and not an inferred schema from candidate
counts. This review does not re-export the downloaded archive.

### 2. Formal segment continuity — Pass

`keyboard_extension.jsonl` contains 516 valid records. The formal segment is
`localSequence` 304–516: 213 contiguous unique sequences, no gaps and no
duplicates, `2026-09-20T14:47:14Z` through `14:47:27Z`, one process
`5CC03041-4BAA-46A1-912C-77357E4FD052`.

The capture Authorization records sequences 301–303 as the reset checkpoint
and sequence 304 as the formal start. Architecture accepts that documented
reset boundary; it does not treat pre-304 events as this Run's input evidence.

### 3. Exact-input boundary — Pass (bounded)

Event counts in sequences 304–516:

| Event code | Count |
|---|---:|
| `touch.terminal` | 44 |
| `rime.owner.published` | 22 |
| `ui.applied` | 22 |
| `candidate.visibility_changed` | 55 |
| `typo_correction.sidecar_query` | 70 |

44 terminal touches and 22 owner/UI updates are consistent with 22 letter
taps. The 22-letter composition itself is Executor-recorded from the Messages
snapshot plus Human report; diagnostics remain content-free and only supply
the length/update boundary.

### 4. Real sidecar route — Pass

All 70 `typo_correction.sidecar_query` records in the formal segment have:

- `route=real_rime_sidecar`
- `schemaID=rime_ice`
- `outcome=returned`, `resultCount=3`, `limit=3`
- `provenanceReceiptID=67A0C52E-A975-47C8-9C09-4ADA1320DF87`
- `inputLength` range 8–22
- `elapsedMilliseconds` range 1–3
- `liveSessionIDBefore=liveSessionIDAfter=4447326552` and both valid flags true
- sidecar session ID `4736627288`, distinct from the live session ID

The 1–3 ms values are internal query observations only. They are not an
end-to-end, 180 ms or paired-performance conclusion.

### 5. Candidate UI vs target-candidate identity — Pass with residual

Sequence 516 is `candidate.visibility_changed` with candidate bar visible, 8
visible cells and revision 94. That supports a bounded “candidate UI active”
sub-claim.

Diagnostics contain no candidate-text field. The named target
`我们今天去公园` is therefore **Human-attested as not observed**. Architecture
cannot independently prove absence or presence of that string, and cannot
explain why it was not observed. Selection and interaction checks were not
run because the selection precondition was unmet.

## Residuals

| ID | Disposition |
|---|---|
| AR-QA07-01 | Target-candidate absence is Human-attested, not device-attested automation. Accepted as a hard identity residual; it keeps the case inconclusive. |
| AR-QA07-02 | Capture Authorization filename is `REVALIDATION-006`, while the bound Run ID is `REVAL-07`. The Authorization body binds this Run; Architecture treats this as a naming leftover, not an identity conflict. |
| AR-QA07-03 | Package binaries were not re-hashed in this review. Continuity relies on the receipt's pre-capture package/provenance binding and the matching runtime receipt. |

## Non-claims

- No target-candidate recovery Pass.
- No general product failure, recall/ranking failure or schema defect.
- No INT-003 cadence, cancellation or 180 ms conclusion.
- No paired-performance or end-to-end latency conclusion.
- No selection, Delete/Space/Return/paging/Partial Commit interaction conclusion.
- No Product Gate, Quality Gate, TestFlight, Release, merge or parent Close.

## Handoff

Quality may consume its own Authorization against the same frozen artifacts.
Product Lead owns any residual decision for this inconclusive QA-001 case.
Any later capture requires a fresh Authorization and Run ID.
