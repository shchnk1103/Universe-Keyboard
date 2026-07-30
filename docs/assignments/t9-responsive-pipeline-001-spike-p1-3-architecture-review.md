# Architecture Review: T9-RESPONSIVE-PIPELINE-001 / Spike-P1-3

**Review type:** Independent Architecture  
**Bound SHA:** `45c426f879ac376e9c99fc069d8ee236b9908ee9`  
**Conclusion:** `Fail`  
**Findings:** `P0=0, P1=1, P2=3, P3=1`  
**ADR 0025:** remains `Proposed`

## Scope

Read-only review of the Product-authorized thread-affine Fake proof. This review
does not Accept ADR 0025, authorize R4, claim Product Gate or change Release
defaults.

## Confirmed evidence

- No `@unchecked Sendable`.
- Fake engine factory is invoked on the dedicated thread.
- The returned engine is local to `runOwnerLoop`.
- MainActor accept does not call the engine.
- Process-key work executes FIFO and epoch/revision gates fail closed.
- Spike is disconnected from Controller, Extension and `RimeEngineImpl`.
- Independent focused run: `5 passed / 0 failed`.
- `git diff --check 45c426f^ 45c426f`: PASS.

## P1 — omitted shutdown orphans thread and engine

At the reviewed SHA, `.stop` can be submitted only by explicit `shutdown()`.
If the owner handle is released without that call, its thread remains blocked
in the mailbox, the thread-local engine never leaves `runOwnerLoop`, and no
remaining handle can request stop.

This blocks the Spike's creation/use/destruction proof. It has no Release
regression because the Spike is not wired. For R4, explicit visibility
suspend/finalize remains mandatory; a deinit fallback may be only a safety net.

Required remediation:

1. idempotent thread-safe `requestStop()`;
2. explicit `shutdown()` and non-blocking `deinit` fallback both invoke it;
3. omitted-shutdown regression;
4. lifecycle probe proving init/process/deinit use one owner thread;
5. clarify what the stopped barrier does and does not drain.

## P2 residuals

1. A Sendable factory protocol cannot by itself prove fresh/non-escaping real
   engine creation. R4 needs a concrete RimeBridge bootstrap from Sendable
   configuration values, not a shared engine factory.
2. Independent `Task { @MainActor ... }` deliveries have no explicit FIFO or
   terminal callback barrier. Revision rejection protects this narrow Spike,
   but R4 needs one ordered delivery channel and terminal acknowledgement.
3. The array mailbox is unbounded and uses `removeFirst`; epoch/stop barriers
   sit behind old backlog. Queue/jetsam and visibility policy remain R4
   blockers under the no-input-drop product rule.

## P3 — finding ID collision

ADR 0025 previously used “Architecture P1-3” for R1 epoch mapping, while the
current residual also used P1-3 for off-main ownership. Future references must
qualify them as `R1-P1-3-epoch` and `P1-3-off-main`.

## Verdict

Architecture **Fail** at `45c426f`; P1-3-off-main remains open. Repair only the
Spike lifecycle P1, retain P2 residuals honestly, then rerun independent
Architecture and Quality reviews.
