# Quality Review: TC2-SIM-20260919-171730-SIDECAR-REVAL-01

**Reviewer:** Independent Quality, Performance & Release Maintainer (not the capture Executor; not the Architecture reviewer)
**Date / timezone:** `2026-09-19 Asia/Shanghai`
**Mode:** Read-only. No rebuild, reinstall, recapture, code change, commit, publication, or Gate close.

| Bound | Identity |
|---|---|
| Run ID | `TC2-SIM-20260919-171730-SIDECAR-REVAL-01` |
| Authorization (this review) | [`AUTH-TYPO-CORRECTION-002-SIDECAR-OBSERVABILITY-QUALITY-001`](../authorizations/AUTH-TYPO-CORRECTION-002-SIDECAR-OBSERVABILITY-QUALITY-001.md) |
| Capture AUTH | [`AUTH-TYPO-CORRECTION-002-SIDECAR-OBSERVABILITY-REVALIDATION-001`](../authorizations/AUTH-TYPO-CORRECTION-002-SIDECAR-OBSERVABILITY-REVALIDATION-001.md) |
| Run Receipt | [`typo-correction-002-sim-run-2026-09-19-sidecar-reval-01.md`](../evidence/typo-correction-002-sim-run-2026-09-19-sidecar-reval-01.md) |
| Architecture | [`architecture-review`](typo-correction-002-sim-run-2026-09-19-sidecar-reval-01-architecture-review.md) — Bounded Pass |
| Continuation Assignment | [`TYPO-CORRECTION-002-PARENT-REVALIDATION-002`](../assignments/typo-correction-002-parent-revalidation-002.md) — remains Active |

## Verdict

**Bounded Pass** for the sidecar-observability lane only.

Quality independently re-hashed the retained raw files, the DerivedData Debug package, and the live Simulator install; all four package SHA-256 values match the Run Receipt. JSONL recount is 70 `real_rime_sidecar` records. Architecture’s bounded Pass is accepted.

This is **not** a Quality Gate for the parent, **not** INT-003 / QA-001 / paired performance, and **not** Assignment Close.

## Independent checks

### Raw artifacts

Recomputed SHA-256 match the receipt and Architecture table:

| Artifact | SHA-256 |
|---|---|
| `diagnostics-control.json` | `3a8307d8a06aaebf2b60c2051a9f9dfd2338e381a553d96b53483b68df960ed9` |
| `keyboard_extension.jsonl` | `7a9737a31bc5df8960eea5a175b632f40a16a97c65f8873a8e486d09c0fb456c` |
| `main_app.jsonl` | `847a9a8dd38d48b01274d3558a4ade62eb7b009252aca943ebb4992801854b84` |
| `rime-runtime-provenance.json` | `b6c9a74a747b35997cc4dc67c651443b7dfd610f50fd290f9076760de7865c54` |

JSONL: 218 lines; `typo_correction.sidecar_query` with `route=real_rime_sidecar` = **70**; `typo_correction.query_route` = **1**. No `FakeCandidateProvider` string in the extension log. Summaries used field names and numeric bounds only.

Live App Group provenance at
`…/AppGroup/97142D9B-ED12-4FFE-8C3A-58F175731B4F/Rime/user/rime-runtime-provenance.json`
still hashes to `b6c9a74a747b35997cc4dc67c651443b7dfd610f50fd290f9076760de7865c54`.

### Architecture verdict

Quality **accepts** Architecture **Bounded Pass** for this lane. No disagreement on: Ice provenance binding, 70 direct sidecar records, live vs sidecar session isolation, or retaining startup `unavailable` as lifecycle.

Elapsed 1–6 ms remains a diagnostic bound, not a performance conclusion.

## SR-01 … SR-04 disposition

| ID | Architecture handoff | Quality disposition |
|---|---|---|
| **SR-01** Package SHA-256 not rehashed from install | Owner: Quality | **Closed for this lane.** DerivedData and live Simulator install binaries were hashed this review (read-only; no rebuild). All four match the receipt: main `6b5dbc62…72072`, Keyboard `cff9029d…f9190`, main dylib `b5463856…a1fa`, Keyboard dylib `15900c7d…2ef0d`. Paths: `/tmp/universe-keyboard-typo-correction-002-parent-revalidation-002-derived/…/Universe Keyboard.app` and live container `8822A66F-10E2-495D-A497-B946D6353EDF`. |
| **SR-02** Keyboard / Full Access / high-fidelity setup | Owner: Quality / Human | **Accept as Executor-attested; remains residual.** Quality did not re-observe the Human setup (no recapture). Diagnostics `origin=keyboard_extension` plus Ice provenance are enough for **bounded** observability; they do **not** upgrade Human setup to Device-attested. |
| **SR-03** `liveSessionStable` is derived | Architecture | **Accept.** Wire fields `liveSessionValidBefore/After=true` and ID equality (`4671774424` live, `4901230360` sidecar) were already independently parsed. No extra residual for Quality. |
| **SR-04** `simctl get_app_container` drop | Owner: Quality | **Accept as historical tool limitation; App Group presence independently recovered.** This Quality pass: `simctl get_app_container … groups` returned `group.com.DoubleShy0N.Universe-Keyboard` → `97142D9B-…175731B4F`, and host-path provenance SHA matches. The capture-time CoreSimulatorService drop is not reclassified as App Group absence. |

Startup `unavailable` at `09:22:36Z` / `localSequence=6`: Quality **accepts** Architecture’s lifecycle disposition. It is not a later-route failure.

## Residuals retained after this review

| ID | Owner | Disposition | Blocks |
|---|---|---|---|
| **SR-02** | Human / Quality | Executor-attested setup; not independently observed | Device-attested / “Human setup proven” claims |
| Startup `unavailable` | Architecture (accepted) | Lifecycle before engine ready | “Every keystroke from cold start is `real_rime_sidecar`” |
| Elapsed 1–6 ms | Quality | Diagnostic bound only | Paired performance / Release budget |

SR-01 and SR-03 do **not** remain open for this bounded lane.

## Non-claims

- Not INT-003 (no 180 ms cadence or cancellation).
- Not QA-001 (no target-candidate visibility or selection).
- Not paired performance.
- Not Product Gate, Quality Gate for the parent, TestFlight, Release, merge, or parent/child Assignment Close.
- Not a conclusion that sidecar is available from the first key after process start.

## Handoff

Sidecar-observability lane now has Executor receipt + Architecture Bounded Pass + Quality Bounded Pass. Product Lead may accept this **lane** separately. INT-003, QA-001, and paired-performance Authorizations remain unconsumed and need fresh Run IDs.
