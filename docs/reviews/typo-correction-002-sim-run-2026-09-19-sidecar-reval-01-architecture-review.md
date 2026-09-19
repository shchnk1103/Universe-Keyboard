# Architecture Review: TC2-SIM-20260919-171730-SIDECAR-REVAL-01

**Reviewer:** Independent Architecture & Knowledge Steward (not the capture Executor)
**Date / timezone:** `2026-09-19 Asia/Shanghai`
**Mode:** Read-only. No Simulator re-run, no code change, no commit, no publication, no Gate close.

| Bound | Identity |
|---|---|
| Run ID | `TC2-SIM-20260919-171730-SIDECAR-REVAL-01` |
| Run Receipt | [`typo-correction-002-sim-run-2026-09-19-sidecar-reval-01.md`](../evidence/typo-correction-002-sim-run-2026-09-19-sidecar-reval-01.md) |
| Authorization | [`AUTH-TYPO-CORRECTION-002-SIDECAR-OBSERVABILITY-REVALIDATION-001`](../authorizations/AUTH-TYPO-CORRECTION-002-SIDECAR-OBSERVABILITY-REVALIDATION-001.md) |
| Continuation Assignment | [`TYPO-CORRECTION-002-PARENT-REVALIDATION-002`](../assignments/typo-correction-002-parent-revalidation-002.md) |
| Parent Assignment | [`TYPO-CORRECTION-002`](../assignments/typo-correction-002.md) |
| Raw artifacts | `/private/tmp/universe-keyboard-typo-correction-002-TC2-SIM-20260919-171730-SIDECAR-REVAL-01-raw` |

This review consumes the sidecar-observability lane for **Architecture disposition only**. It does not consume INT-003, QA-001, or paired-performance Authorizations.

## Verdict

**Bounded Pass** for the sidecar-observability lane.

Independent re-hash and JSONL parse of the retained raw artifacts corroborate the Run Receipt on: exact `rime_ice` provenance, 70 `real_rime_sidecar` records, stable live vs sidecar session identities, and an earlier `route=unavailable` startup event that is **not** merged into the completed window.

This is **not** an unconditional Pass. Conditions and non-claims are below. It is **not** a Product / Quality / parent Gate.

## Independent checks (this review)

Raw SHA-256 values were recomputed and match the receipt:

| Artifact | SHA-256 (this review) |
|---|---|
| `diagnostics-control.json` | `3a8307d8a06aaebf2b60c2051a9f9dfd2338e381a553d96b53483b68df960ed9` |
| `keyboard_extension.jsonl` | `7a9737a31bc5df8960eea5a175b632f40a16a97c65f8873a8e486d09c0fb456c` |
| `main_app.jsonl` | `847a9a8dd38d48b01274d3558a4ade62eb7b009252aca943ebb4992801854b84` |
| `rime-runtime-provenance.json` | `b6c9a74a747b35997cc4dc67c651443b7dfd610f50fd290f9076760de7865c54` |

JSONL was summarized by field names and numeric bounds only. No raw pinyin, candidate text, or host text is copied here.

### 1. Exact `rime_ice` provenance — Pass

`rime-runtime-provenance.json` independently shows:

- `activeSchemaID` / `schemeID` = `rime_ice`
- `source=downloaded`, `sourceVariantID=nju`
- artifact `rime-ice-20260630-675d23b0`, version `2026.06.30`
- archive SHA-256 `675d23b070be00e1b800f9a6db033ef98f4493cd5b568ed8aa3b3541769c46ac`
- installed-content SHA-256 `2e906d14853255cd0eba534e2b40791008c2cee65fa5a6e50b40bbd159cb6c26`
- receipt ID `078F7EA2-F9CA-4033-B7DD-48BE636BEB38`
- `librimeVersion=1.16.1`, `luaAvailable=true`, `luaRuntimeSmokePassed=true`, `runtimeSmokePassed=true`
- staged identity `rime-ice-20260630-plan2-post2`, post-processing `rime-ice-post-2`
- upstream revision `6810e8916d160498620a16fef2135956fecbd485`

This is a real deployed Ice provenance object, not a unit-test fixture name and not an inferred schema from candidate counts. Main-App “雾凇拼音 / 已就绪” remains Executor-attested UI glance; Architecture treats the App Group file as the binding proof.

`generatedAt=2026-09-19T03:57:37Z` is earlier than the query window. That is acceptable: the 70 sidecar records bind the same `provenanceReceiptID`.

### 2. Seventy `real_rime_sidecar` records — Pass

From `keyboard_extension.jsonl` (218 lines total):

- `code=typo_correction.sidecar_query` count = **70**
- nested `typoCorrectionPayload.sidecarQuery._0.diagnostic.route` = `real_rime_sidecar` for all 70
- `schemaID=rime_ice`, `outcome=returned`, `resultCount=3`, `limit=3` for all 70
- `elapsedMilliseconds` range **1–6**
- `inputLength` range **8–22** (length only)
- `sequence` 59–352, **70 unique** values
- `utcTimestamp` window `2026-09-19T09:22:41Z`–`2026-09-19T09:22:48Z`
- all 70 `origin=keyboard_extension`
- `provenanceReceiptID` = `078F7EA2-F9CA-4033-B7DD-48BE636BEB38` on all 70 (matches provenance file)

The diagnostic object has no text/pinyin/candidate/host keys. That satisfies the content-free route contract in AUTH required evidence items 3–4.

Density (70 queries in ~7 s while `inputLength` grows 8→22) is consistent with per-keystroke sidecar probes during typing. Architecture does **not** interpret elapsed 1–6 ms as a performance budget.

### 3. Live-session stability — Pass (bounded)

Literal fields are not named `liveSessionStable`. Observed facts:

- `liveSessionIDBefore` = `liveSessionIDAfter` = **`4671774424`** on all 70
- `liveSessionValidBefore` = `liveSessionValidAfter` = **true** on all 70
- `sidecarSessionIDBefore` = `sidecarSessionIDAfter` = **`4901230360`** on all 70
- live ID **≠** sidecar ID

The receipt’s phrase `liveSessionStable=true` is a valid **derived** summary of ID equality + valid flags, not a missing wire field. Distinct sidecar vs live IDs support ADR 0015 isolation (sidecar query must not mutate the live session). This review does not inspect live composition bytes (forbidden and not present).

### 4. Startup `route=unavailable` — Pass (correctly retained)

Exactly one `typo_correction.query_route` event:

- `utcTimestamp=2026-09-19T09:22:36Z`
- `localSequence=6`
- `queryRoute._0.route=unavailable`

It precedes the sidecar window by ~5 s and is **not** counted among the 70 `real_rime_sidecar` records. Architecture agrees with the Executor: this is engine-not-ready lifecycle, not evidence that the later direct route failed, and must not be silently rewritten to `real_rime_sidecar`.

### 5. Sufficiency for bounded sidecar observability — Yes, with residuals

AUTH required evidence 1–5:

| Requirement | Disposition |
|---|---|
| Signed package SHA-256 | **Executor-recorded** on the receipt; this review did **not** re-hash the live Simulator install binaries. Residual `SR-01`. |
| App Group provenance file | **Independently verified** via retained copy + matching SHA-256. `simctl get_app_container` failure is a tool limitation, not App Group absence, given the host-path copy. |
| Direct `real_rime_sidecar` + bounds | **Independently verified** (70/70). |
| Live session identity unchanged | **Independently verified** (IDs + valid flags). |
| Immutable receipt + raw SHA-256 | **Independently verified**. |

Assignment rule “candidate presence alone is not route proof” is met: the route is a diagnostic field on `sidecar_query`, not inferred from `candidate.visibility_changed` (58 of those events exist and were not used as route proof).

Human Full Access / keyboard-selection setup remains Executor-attested (`SR-02`).

## Residuals

| ID | Owner | Disposition | Pointer |
|---|---|---|---|
| `SR-01` | Quality | Package executable/dylib SHA-256 not rehashed from the live install in this Architecture pass | Receipt “Package identity”; DerivedData path on the receipt |
| `SR-02` | Quality / Human | Keyboard selection, Full Access, and high-fidelity mode are Executor-attested, not independently observed here | Receipt “Device and human setup” |
| `SR-03` | Architecture | Receipt field `liveSessionStable` is derived; wire fields are `liveSessionValid*` + ID equality | This review §3 |
| `SR-04` | Quality | `simctl get_app_container` CoreSimulatorService drop retained as tool limitation | AUTH Capture Facts; Receipt §Exact RIME provenance |
| Startup `unavailable` | Architecture | **accept** as lifecycle, not a sidecar-route failure | jsonl `localSequence=6` at `09:22:36Z` |

None of these residuals block a **bounded** sidecar-observability Pass. They block upgrading the lane to Device-attested, Product Gate, or “always-ready from first key”.

## Non-claims

- Not INT-003 (no cadence / cancellation analysis).
- Not QA-001 (no target-candidate visibility or selection).
- Not paired performance / Release budget (elapsed 1–6 ms is diagnostic bound only).
- Not Product Gate, Quality Gate, TestFlight, Release, merge, or parent/child Assignment Close.
- Not proof that every keystroke after cold start is `real_rime_sidecar` (startup `unavailable` remains).
- Not proof against `FakeCandidateProvider` by absence of that type name in this file; the positive proof is `real_rime_sidecar` + Ice provenance receipt binding.
- Child testability/accessibility PR #140 is out of this lane.

## Handoff

Independent Quality may consume this Architecture disposition together with the Run Receipt for a **sidecar-lane** verdict only. INT-003, QA-001, and paired-performance still require their own Authorizations and fresh Run IDs. Product Lead decides any parent Gate separately.
