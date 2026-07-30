# Quality Review: T9-RESPONSIVE-PIPELINE-001 / Spike-P1-3

**Review type:** Independent Quality  
**Bound SHA:** `45c426f879ac376e9c99fc069d8ee236b9908ee9`  
**Conclusion:** `Fail`  
**Findings:** `P0=0, P1=1, P2=1, P3=1`

## Independent validation

- Spike focused: `5 / 5 passed`, about `0.201s`; controlled-stall case about
  `0.190s`.
- KeyboardCore: `821 / 821 passed`.
- iOS 27 Simulator KeyboardCore build with complete strict concurrency,
  warnings visible and warnings-as-errors: succeeded with zero warnings/errors.
- `git diff 3273057..45c426f --check`: PASS.
- No `@unchecked Sendable`, `nonisolated(unsafe)`, frozen input content in
  Spike source/test/evidence, or production wiring.

## P1 — engine/thread destruction is not fail-safe

The reviewed implementation requires every caller to remember `shutdown()`.
All tests do so, which hides the case where the owner handle disappears and
the thread-local engine remains permanently alive.

Required remediation:

- automatic, idempotent stop fallback;
- omitted-shutdown thread/engine destruction test;
- explicit-shutdown destruction-on-owner-thread test;
- bounded wait only; no hot-path blocking.

## P2 — 150 ms proof wording exceeds implementation

The reviewed test blocks `beforeEngineCall`, then runs Fake
`engine.processKey`. It proves an owner-thread stall does not block MainActor,
but not that Fake `processKey` itself is blocked. Move the controlled block into
the Fake engine or narrow the evidence language.

## P3 — fixed 50 ms assertion is not a Product SLO

The semaphore establishes concurrent owner blockage. A fixed wall-clock limit
may be noisy on overloaded CI. Keep it explicitly experimental, not Product or
Release policy; prefer event ordering as the primary proof.

## Verdict

Quality **Fail** at `45c426f` because one P1 prevents complete lifecycle proof.
No real-librime, device, jetsam, ADR acceptance or Product Gate conclusion is
made.
