# Architecture Review: TC2-PERF-20260919-195848-REVAL-03

**Reviewer:** Independent Architecture & Knowledge Steward (not the capture Executor)
**Date / timezone:** `2026-09-19 Asia/Shanghai`
**Mode:** Read-only. No Simulator re-run, rebuild, reinstall, source edit, receipt edit, commit, publication, or Gate close.

| Bound | Identity |
|---|---|
| Run ID | `TC2-PERF-20260919-195848-REVAL-03` |
| Run Receipt | [`typo-correction-002-sim-run-2026-09-19-performance-reval-03-inconclusive.md`](../evidence/typo-correction-002-sim-run-2026-09-19-performance-reval-03-inconclusive.md) |
| Architecture Authorization | [`AUTH-TYPO-CORRECTION-002-PERFORMANCE-REVALIDATION-003-ARCHITECTURE-001.md`](../authorizations/AUTH-TYPO-CORRECTION-002-PERFORMANCE-REVALIDATION-003-ARCHITECTURE-001.md) |
| Capture Authorization | [`AUTH-TYPO-CORRECTION-002-PERFORMANCE-REVALIDATION-003.md`](../authorizations/AUTH-TYPO-CORRECTION-002-PERFORMANCE-REVALIDATION-003.md) |
| Continuation Assignment | [`TYPO-CORRECTION-002-PARENT-REVALIDATION-002`](../assignments/typo-correction-002-parent-revalidation-002.md) |
| Parent Assignment | [`TYPO-CORRECTION-002`](../assignments/typo-correction-002.md) |
| Raw artifacts | `/private/tmp/typo-correction-002-sim-runs/TC2-PERF-20260919-195848-REVAL-03/raw/` |

This review consumes the Architecture Authorization for this performance lane only. It does not consume the separate Quality Authorization and does not close any lane, Gate, or Assignment.

## Verdict

**Bounded Pass — the evidence boundary and inconclusive disposition are architecturally correct; no paired-performance conclusion is available.**

The raw artifacts corroborate the receipt's package/provenance identity, arm-local event counts, direct sidecar observations, and the two distinct keyboard-extension process IDs. Under the exact Capture Authorization, the process change is a hard comparability break: the authorization requires the same measurement conditions and states that a new diagnostic process after an arm begins invalidates the pair. Therefore the receipt correctly preserves `inconclusive` and must not report a timing comparison.

The process-ID rule is specific to this Authorization. It is not a universal claim that every performance experiment must use one process; here it is required to prevent cold/warm lifecycle state from being confounded with the sidecar setting.

## Review method

- Read the bound Run Receipt, Architecture Authorization, Capture Authorization, parent Assignment, and [`PERFORMANCE_BASELINE.md`](../PERFORMANCE_BASELINE.md).
- Recomputed SHA-256 for every retained raw artifact with `shasum -a 256`.
- Parsed only structural JSONL fields, event codes, timestamps, process IDs, session/provenance identifiers, routes, counts, and elapsed-time bounds.
- Did not copy or output input text, candidate text, host text, or screenshot contents. The two screenshots were hashed but not opened.
- No Simulator, build, install, schema deployment, or capture operation was performed.

## Independent raw-artifact reconciliation

All seven hashes below independently match the Run Receipt:

| Artifact | SHA-256 |
|---|---|
| `baseline-source-journal.jsonl` | `1ab5e5a0fca0c9899efba95e2c82c9fb9576e6251b0ddb971e8ed4fe5fbf5ddd` |
| `baseline-journal-slice.jsonl` | `497877063a1ada9e4f5a060117ee6240e5b34d07d2e472cf31593e1f38ab633f` |
| `baseline-screenshot.jpg` | `16802a2afdbc6ff8db26a363fda26c9dc54faec005ccff927587133b11e18d28` |
| `rime-runtime-provenance.json` | `b6c9a74a747b35997cc4dc67c651443b7dfd610f50fd290f9076760de7865c54` |
| `treatment-journal.jsonl` | `8d1d4ae75be515ba195ee77cc2b627aaff7428f47ba6cf3e542eb3244d5dd0a0` |
| `treatment-screenshot.jpg` | `8d2b28c871beda82f276328aee999e7ddd40b5c7e5c23983a1da97aa76f622a2` |
| `treatment-rime-runtime-provenance.json` | `b6c9a74a747b35997cc4dc67c651443b7dfd610f50fd290f9076760de7865c54` |

The two retained provenance files are byte-identical by digest and independently report the same active `rime_ice` schema, artifact identity, archive/install digests, and runtime receipt ID recorded by the receipt.

## Findings

### 1. BASELINE/TREATMENT comparability — not satisfied

| Check | BASELINE | TREATMENT | Architecture disposition |
|---|---|---|---|
| Package, device, host, schema and provenance identity | Same receipt-bound identity | Same receipt-bound identity | Comparable for identity |
| Contextual correction setting | Disabled | Enabled | Intended arm difference |
| Keyboard-extension process | `56964610-80B8-4A76-B3D2-7C5D0AECCD21` | `9E631FEE-5E7D-40A5-ABC8-411CD6B3A154` | **Hard comparability break under this Authorization** |
| Fresh product stream | 56 records: 4 touch, 22 RIME-owner, 22 UI-applied, 8 candidate-visibility | 217 records: 44 touch, 22 RIME-owner, 22 UI-applied, 57 candidate-visibility, 70 sidecar, 1 route, 1 presentation | Bounded arm observations only |

The baseline slice is a post-cutoff segment of the process that continued from the preceding capture. Treatment uses a different process and begins with a new process-local sequence. This can change initialization and warm-state conditions independently of the enabled setting. The Capture Authorization's process rule therefore applies, and the receipt's “pair invalid / no timing conclusion” disposition is correct.

### 2. Direct sidecar observation — bounded treatment-arm observation

Independent parsing of the treatment journal found exactly **70** `typo_correction.sidecar_query` events. For all 70:

- route = `real_rime_sidecar`;
- outcome = `returned`;
- result count / limit = `3 / 3`;
- schema ID = `rime_ice`;
- elapsed milliseconds range = **1–6 ms**;
- live session ID before/after is equal and valid;
- sidecar session ID before/after is equal and distinct from the live session ID;
- the provenance receipt ID matches the retained RIME provenance object.

These values prove the direct route and its bounded internal query observations for this treatment process. They do not measure touch-to-UI, end-to-end typing latency, user-perceived delay, or a Release budget. They cannot repair the arm-level process comparability break.

The treatment journal also contains one earlier `query_route=unavailable` lifecycle event at local sequence `6`; the first direct sidecar event occurs later at local sequence `49`. This is not a contradiction: the receipt's direct-route statement is scoped to the 70 sidecar events and does not claim that the route was available from the first process event.

### 3. Receipt claims and non-claims — preserved correctly

The receipt correctly retains:

- exact package, device, schema and RIME provenance identity as an identity sub-claim;
- separate BASELINE and TREATMENT arm observations;
- the 70 direct sidecar queries as descriptive treatment evidence;
- the different process IDs as the reason the pair is invalid;
- no paired-performance timing, median, worst value, or numeric budget;
- no QA-001, INT-003, Product, Quality, Release, merge, or Assignment closure conclusion.

The absence of a target candidate and the lack of candidate selection remain non-results for this performance lane. They are not converted into a product-failure claim.

## Residuals

| ID | Owner | Disposition | Boundary |
|---|---|---|---|
| `PR-01` | Quality / Performance | `accept` for this Run; a valid pair requires a new Authorization and Run ID | Different keyboard-extension processes invalidate the pair |
| `PR-02` | Architecture / Quality | `accept` as lifecycle evidence | One early `route=unavailable` event precedes later direct sidecar observations |
| `PR-03` | Quality / Performance | `accept` as bounded observation only | 1–6 ms is internal sidecar-query elapsed time, not end-to-end or Release performance |
| `PR-04` | Product / Quality | `accept` as scope boundary | Debug/Simulator and human-cadence evidence remain diagnostic only |

None of these dispositions upgrades the lane to a performance Pass or closes a Gate.

## Non-claims

- Not a valid paired-performance result and not evidence of a 180 ms budget.
- Not an end-to-end, user-perceived, cold-start, warm-start, or device performance measurement.
- Not proof that contextual correction is slow, fast, correct, or incorrect.
- Not QA-001, INT-003, sidecar-lane closure, Product/Quality/Release Gate, TestFlight, Release, merge, or parent/child Assignment closure.
- Not proof that every key after startup used `real_rime_sidecar`; the startup `unavailable` lifecycle event remains part of the treatment process boundary.

## Handoff

Independent Quality may review this Architecture disposition together with the exact Run Receipt and raw-artifact hashes under its separate Authorization. The parent Assignment remains Active; any future valid same-process or otherwise explicitly controlled pair requires a new Authorization, Run ID, and fresh package/provenance reconciliation.
