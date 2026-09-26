# INT-003 query count and cost measurement plan

Status: **P0 design complete; execution not authorized**. Owning [Assignment](../assignments/typo-correction-002-int003-query-cost-measurement-001.md) remains Active. The [P0 AUTH](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-MEASUREMENT-PLAN-001.md) is Consumed. This plan does not set a query budget or accept the [Product residual](../product-decisions/TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001-PRODUCT-RESIDUAL.md).

## Decision question

The [existing assessment](../evidence/typo-correction-002-int003-query-cost-assessment-2026-09-26.md) established 359 real facade calls over 12 Debug Simulator operations, 26–32 calls per operation. It cannot tell which calls yielded candidates, which entered a ready RIME sidecar, or how much actual work occurred beyond its journal brackets. The next evidence must answer:

1. How many calls belong to Stage 1 contextual/legacy hypotheses versus Stage 2, and how many return zero or nonzero candidates?
2. For those classes, is the correction sidecar ready, and how much time is spent in the installed query facade/RIME boundary versus yielded turns and UI application?
3. Does enabling the measurement itself change the ordinary key path, operation count, latency or memory enough to invalidate a comparison?

These questions support a later Product choice about query total/usefulness. They do not imply that the current 8-attempt Stage 2 budget caps Stage 1 or that `query_succeeded` means a nonempty result.

## Source and minimal observation boundary

- [`TypoCorrectionRecallCoordinator`](../../Keyboard/Controllers/TypoCorrectionRecallCoordinator.swift) owns debounce, operation ordinal, fence and each `owner.correctionCandidates` call. Existing `query_begin/outcome` markers bracket the facade plus driver and journal work; they are not isolated RIME CPU time.
- [`TypoCorrectionRecallDriver`](../../Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionRecallMaterial.swift) owns Stage 1 queue and Stage 2 ledger. Its current `.query` event exposes a suggestion without a stage tag. Stage classification therefore needs a reviewed, content-free driver-to-coordinator signal or an equivalent bounded counter; it cannot be inferred reliably from existing JSONL order alone.
- The installed [`sidecar owner`](../../Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionSidecarOwner.swift) delegates through a query facade. The production [`RimeEngineImpl` adapter](../../Packages/RimeBridge/Sources/RimeBridge/RimeEngineImpl+CorrectionQuery.swift) reaches [`RimeSessionManager`](../../Packages/RimeBridge/Sources/RimeBridgeObjC/RimeSessionManager.m), where unavailable correction-session readiness can produce an empty result. A coordinator-level zero count does not distinguish that early return from a ready sidecar with no candidates. Any readiness distinction needs an approved, privacy-safe observation at the owning bridge boundary; do not expose the raw engine or create a second RIME route.

The P1 design review should choose the smallest signal path that preserves Main-App-owned deployment, Swift 6 isolation and one sidecar query writer. Review [ADR 0004](../architecture/decisions/0004-rime-runtime-session-model.md) before any session or threading change. No synchronous file write, JSON encoding, host text, composition, hypothesis string, candidate text or fingerprint enters the key path or retained report. Keep bounded numeric counters/timestamps in memory and emit only finite, content-free aggregates outside the measured critical section. Record diagnostic overhead separately with the same binary/configuration when feasible; never present Debug high-fidelity journal timing as Release-like cost.

## Proposed measurement fields and checks

| Unit | Content-free fields | What it answers | Check before use |
|---|---|---|---|
| Operation | local operation ordinal, route class, cold/warm arm, stage totals, completed/discarded state | Number of operations and censoring | Exactly one terminal classification per started operation; no cross-process join |
| Query | Stage 1/2, candidate-count bucket `0`/`1–3`, ready/unavailable/unknown sidecar class, facade elapsed bucket | Fan-out, useful returns and observed boundary cost | One begin/outcome per attempted call; no text, candidate identity or stable user fingerprint |
| UI/key path | synthetic case ID, key-event count, operation-to-refresh span, main-thread stall and memory aggregate | Whether correction work affects interaction | Same fixture and environment; instrumentation off/on overhead compared before Product use |
| Environment | exact source/build and installed payload, device/OS, host/field type, schema/Lua/simplification, Full Access, thermal/power/debugger state | Comparability and provenance | Freeze before input; invalidate run on build/install/config drift |

`ready/unavailable/unknown` is a required semantic distinction for interpreting zero-result calls; `unknown` is preserved if the bridge cannot expose readiness safely. The design must not relabel `unknown` as ready. Candidate counts are bounded integers only; no candidate contents or per-hypothesis identifiers are retained. Any added diagnostic code requires a separate source-scope AUTH and appropriate Architecture review before implementation.

## Evidence sequence and comparison rules

1. **P1 feasibility and implementation (separate AUTH):** freeze exact source, allowed Swift/ObjC/test paths and intended event semantics. Review threading, route ownership and data/privacy boundaries. If code is approved, run `xcrun swift-format lint --strict --configuration .swift-format` before any Swift commit/push and the applicable source/test quality gates. Verify counting against deterministic Stage 1/2, empty/ready/unavailable and cancel/fence cases. Record observer overhead and classify any remaining `unknown`.
2. **P2 Simulator diagnostic (separate Capture AUTH):** use the designated iPhone 17 Pro Max / iOS 27 Simulator by exact UDID if still available. Freeze the run ID and installed build, synthetic fixture, schema/access/host state and journal path before input. Preserve and hash dynamic JSONL outside the repository before inspection. Pair counts/timings by process, appearance and operation. This can validate signal semantics; it remains Debug/Simulator evidence.
3. **Later Release-like Product evidence (separate decision and device AUTH):** if Product wants an acceptability or numeric budget conclusion, follow [`PERFORMANCE_BASELINE`](../PERFORMANCE_BASELINE.md) and the [Human-operated evidence profile](../kos/universe-keyboard-human-operated-evidence-profile.md): exact installed App/Extension/dynamic-payload manifest, command side-effect ledger, independent readiness review, one default Human round, same device/OS/host/schema/access state, cold and warm repeated runs, median/worst/sample count, memory/main-thread stall observations, and an independently reviewed evidence package. Use synthetic input only. A physical third-party keyboard run uses Human typing; no coordinate-driven XCTest or Computer Use typing.

No fixed number of calls or milliseconds is a pass threshold in this plan. A later Product decision may set a budget only after reviewed comparable evidence. The earlier `<180 ms` hard pass bar was removed solely for the follow-up query-density diagnosis; the runtime debounce and historical Capture facts remain unchanged.

## Stop, output and handoff

Stop P1/P2 before execution if a distinct AUTH is not consumed, a required role/field is `UNKNOWN`, a reviewer disputes diagnostic semantics, the exact environment changes, instrumentation records sensitive material or adds synchronous hot-path persistence, or the Human readiness/round budget fails. Preserve raw artifacts outside the repository and publish only hashes and aggregates.

P0 output is this decision-ready plan. P1 would output a reviewed, validated diagnostic implementation and overhead receipt. P2 would output exact-run count/usefulness/timing evidence with explicit Debug limitations. A later Product/Quality package may decide whether to accept, reduce or redesign query fan-out. None of those outputs automatically passes Product/QA-001 Gate, closes the parent, accepts an ADR, or authorizes TestFlight/Release.
