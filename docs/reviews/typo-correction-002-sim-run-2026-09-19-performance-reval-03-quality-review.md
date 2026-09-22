# Quality Review: TC2-PERF-20260919-195848-REVAL-03

**Reviewer:** Independent Quality reviewer
**Date / timezone:** `2026-09-19 Asia/Shanghai`
**Mode:** Strictly read-only. No Simulator operation, rebuild, reinstall, schema deployment, recapture, source edit, receipt edit, or publication.

| Bound | Identity |
|---|---|
| Run ID | `TC2-PERF-20260919-195848-REVAL-03` |
| Run Receipt | [`typo-correction-002-sim-run-2026-09-19-performance-reval-03-inconclusive.md`](../evidence/typo-correction-002-sim-run-2026-09-19-performance-reval-03-inconclusive.md) |
| Capture Authorization | [`AUTH-TYPO-CORRECTION-002-PERFORMANCE-REVALIDATION-003.md`](../authorizations/AUTH-TYPO-CORRECTION-002-PERFORMANCE-REVALIDATION-003.md) |
| Architecture Authorization | [`AUTH-TYPO-CORRECTION-002-PERFORMANCE-REVALIDATION-003-ARCHITECTURE-001.md`](../authorizations/AUTH-TYPO-CORRECTION-002-PERFORMANCE-REVALIDATION-003-ARCHITECTURE-001.md) |
| Quality Authorization | [`AUTH-TYPO-CORRECTION-002-PERFORMANCE-REVALIDATION-003-QUALITY-001.md`](../authorizations/AUTH-TYPO-CORRECTION-002-PERFORMANCE-REVALIDATION-003-QUALITY-001.md) |
| Architecture review | [`typo-correction-002-sim-run-2026-09-19-performance-reval-03-architecture-review.md`](typo-correction-002-sim-run-2026-09-19-performance-reval-03-architecture-review.md) |
| Raw artifacts | `/private/tmp/typo-correction-002-sim-runs/TC2-PERF-20260919-195848-REVAL-03/raw/` |

## Verdict

**Bounded Pass — evidence reconciliation only.**

The receipt and Architecture review are internally consistent with the retained
raw artifacts. The paired-performance result remains **inconclusive / not
measurable** because BASELINE and TREATMENT used different
keyboard-extension process instances, which is a hard comparability break under
the bound Capture Authorization. This review does not upgrade the run to a
performance Pass and does not close any Gate or Assignment.

## Review method

- Independently recomputed SHA-256 for all seven retained artifacts.
- Parsed only JSONL structure, event codes, timestamps, local sequences,
  process IDs, sidecar route/session/provenance fields, and numeric bounds.
- Did not output or copy input text, candidate text, host text, or screenshot
  contents. The two screenshots were hashed only and were not opened.
- Compared the independent result with the exact Run Receipt and the bound
  Architecture review.
- Did not run the app, operate the Simulator, rebuild, reinstall, deploy a
  schema, or collect new data.

## Independent SHA-256 reconciliation

All seven hashes independently match the Run Receipt and Architecture review:

| Artifact | SHA-256 |
|---|---|
| `baseline-source-journal.jsonl` | `1ab5e5a0fca0c9899efba95e2c82c9fb9576e6251b0ddb971e8ed4fe5fbf5ddd` |
| `baseline-journal-slice.jsonl` | `497877063a1ada9e4f5a060117ee6240e5b34d07d2e472cf31593e1f38ab633f` |
| `baseline-screenshot.jpg` | `16802a2afdbc6ff8db26a363fda26c9dc54faec005ccff927587133b11e18d28` |
| `rime-runtime-provenance.json` | `b6c9a74a747b35997cc4dc67c651443b7dfd610f50fd290f9076760de7865c54` |
| `treatment-journal.jsonl` | `8d1d4ae75be515ba195ee77cc2b627aaff7428f47ba6cf3e542eb3244d5dd0a0` |
| `treatment-screenshot.jpg` | `8d2b28c871beda82f276328aee999e7ddd40b5c7e5c23983a1da97aa76f622a2` |
| `treatment-rime-runtime-provenance.json` | `b6c9a74a747b35997cc4dc67c651443b7dfd610f50fd290f9076760de7865c54` |

## Structural and event reconciliation

### BASELINE

`baseline-journal-slice.jsonl` contains 56 valid JSONL records with no parse
errors, covering `2026-09-19T12:13:19Z` through
`2026-09-19T12:13:23Z`, local sequences 142–197, and exactly one process:
`56964610-80B8-4A76-B3D2-7C5D0AECCD21`.

Event counts are:

| Event code | Count |
|---|---:|
| `touch.terminal` | 4 |
| `rime.owner.published` | 22 |
| `ui.applied` | 22 |
| `candidate.visibility_changed` | 8 |

The retained `baseline-source-journal.jsonl` contains 185 valid records and
the same BASELINE process. Its larger window is lineage evidence; the 56-record
slice is the arm-bound measurement input.

### TREATMENT

`treatment-journal.jsonl` contains 217 valid JSONL records with no parse
errors, covering `2026-09-19T12:18:49Z` through
`2026-09-19T12:19:05Z`, local sequences 1–217, and exactly one process:
`9E631FEE-5E7D-40A5-ABC8-411CD6B3A154`.

Event counts are:

| Event code | Count |
|---|---:|
| `presentation.appeared` | 1 |
| `touch.terminal` | 44 |
| `rime.owner.published` | 22 |
| `ui.applied` | 22 |
| `candidate.visibility_changed` | 57 |
| `typo_correction.query_route` | 1 |
| `typo_correction.sidecar_query` | 70 |

The one `typo_correction.query_route` event reports `route=unavailable` at
local sequence 6. It is a lifecycle observation before the direct sidecar
events and is not merged into the 70-query count.

## Direct sidecar observations

Independent parsing found exactly 70 `typo_correction.sidecar_query` records.
For all 70 records:

- route is `real_rime_sidecar`;
- outcome is `returned`;
- result count and limit are `3 / 3`;
- schema ID is `rime_ice`;
- `liveSessionIDBefore` equals `liveSessionIDAfter` and both validity fields
  are `true`;
- `sidecarSessionIDBefore` equals `sidecarSessionIDAfter` and is distinct
  from the live session ID;
- the provenance receipt ID is
  `078F7EA2-F9CA-4033-B7DD-48BE636BEB38`;
- elapsed time is bounded to **1–6 ms**;
- numeric input-length metadata is bounded to 8–22 characters. No input
  content was copied or emitted.

The live session ID is `4392416920` for all 70 records; the sidecar session ID
is `4458112856` for all 70 records. These are session-identity observations,
not an end-to-end latency measurement.

## RIME provenance reconciliation

The two provenance JSON objects are byte-identical by SHA-256 and independently
report the same bounded identity:

- active schema: `rime_ice`;
- artifact identity: `rime-ice-20260630-675d23b0`;
- archive SHA-256:
  `675d23b070be00e1b800f9a6db033ef98f4493cd5b568ed8aa3b3541769c46ac`;
- installed-content SHA-256:
  `2e906d14853255cd0eba534e2b40791008c2cee65fa5a6e50b40bbd159cb6c26`;
- runtime receipt ID: `078F7EA2-F9CA-4033-B7DD-48BE636BEB38`.

These values agree with both the Run Receipt and Architecture review.

## Quality findings

### Q-01 — Receipt and Architecture alignment: Pass

The seven artifact hashes, JSONL parse results, arm-local counts, process IDs,
route/session/provenance fields, and elapsed bounds all agree with the receipt
and Architecture review. No internal contradiction was found.

### Q-02 — Process mismatch: paired-performance blocked

BASELINE uses process
`56964610-80B8-4A76-B3D2-7C5D0AECCD21`; TREATMENT uses process
`9E631FEE-5E7D-40A5-ABC8-411CD6B3A154`. Under the Capture Authorization, this
is a hard comparability break. It can confound process initialization and
warm-state lifecycle with the contextual-correction setting. Therefore no
paired timing, delta, median, percentile, worst value, or budget conclusion
may be derived from this run.

This is a rule for this authorized experiment, not a universal claim that all
future performance experiments must use one process. A future experiment would
need its own Authorization and Run ID with an explicitly controlled comparison
design.

### Q-03 — Treatment-internal sidecar observation: Pass with boundary

The 70 `real_rime_sidecar` queries and 1–6 ms elapsed range are correctly
reported as treatment-arm internal observations. They do not repair the process
mismatch and must not be promoted to an end-to-end keyboard latency,
user-perceived delay, INT-003 result, or 180 ms Release budget.

### Q-04 — Non-claims and scope: Pass

The receipt and Architecture review correctly preserve the inconclusive
disposition and do not infer a candidate-recovery result, product regression,
or correction correctness from the absence of a selected candidate.

## Residuals

| ID | Disposition | Boundary |
|---|---|---|
| `QR-PR-01` | Accepted for this Run | Different keyboard-extension processes invalidate the pair. |
| `QR-PR-02` | Accepted as lifecycle evidence | One early `route=unavailable` event precedes later direct sidecar observations. |
| `QR-PR-03` | Accepted as bounded observation only | 1–6 ms is internal sidecar-query elapsed time, not end-to-end or Release performance. |
| `QR-PR-04` | Accepted as scope boundary | Debug/Simulator and human-operated cadence remain diagnostic evidence only. |
| `QR-PR-05` | Remains open outside this Run | Candidate visibility, QA-001, INT-003, and any Product conclusion are separate lanes. |

## Non-claims

- Not a valid paired-performance result and not evidence of a 180 ms budget.
- Not an end-to-end, user-perceived, cold-start, warm-start, or physical-device
  performance measurement.
- Not proof that contextual correction is slow, fast, correct, or incorrect.
- Not proof that every post-startup key used `real_rime_sidecar`.
- Not QA-001, INT-003, sidecar-observability closure, Product/Quality/Release
  Gate, TestFlight, Release, merge, or parent/child Assignment closure.
- Not authorization to rebuild, recapture, change code/schema, publish, or
  reuse the consumed performance Authorization.

## Disposition

The separate Quality Authorization is consumed by this review with the verdict
above. The capture and Architecture Authorizations remain governed by their
own records. The paired-performance lane remains **inconclusive**, and the
parent Assignment remains **Active**. Any future valid comparison requires a
new Authorization, a new Run ID, and a fresh provenance reconciliation.
