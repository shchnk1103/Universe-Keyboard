# T9 responsive pipeline — P2 regression matrix evidence — 2026-08-01

**Work item:** `T9-RESPONSIVE-PIPELINE-001 / P2-Regression-Matrix-001`  
**Scope:** KeyboardCore regression contracts only; no production logic change in
this slice  
**Disposition:** **Bounded Pass with conditions** after independent Architecture
and Quality re-review; P2-EPC closed only at Core/Fake-host scope  
**Gates:** responsive + thread-affine dual gate remain default-off  
**Non-claims:** no real librime, Extension UI target, device, Release, jetsam,
ADR 0025 Accept or Product Gate result

## What this slice proves

1. While `provisionalAhead` is true, candidate, correction, candidate page up/down,
   direct Path, Path cycle and Space actions all fail closed. The test also keeps a
   Partial Commit checkpoint alive and verifies that neither Core state nor the
   Fake host's marked-text history changes.
2. After a settled L2, L1 appends only the pending dot to the stable host preedit;
   the last RIME output, T9 Path state, Partial Commit/typo state and Extension
   presentation callback count stay unchanged until L2 arrives.
3. A visibility abandon increments the owner epoch. After the blocked old work is
   released, the host `markedTextHistory` count does not increase at all; stale
   work is counted or purged by the owner.

## Automated evidence

| Command | Result |
|---|---|
| `swift test --package-path Packages/KeyboardCore --filter ResponsiveProvisional` | **19 tests, 0 failures** (2026-08-01) |
| three repaired-test filter (`ResponsiveProvisionalL1WireTests`) | **3 tests, 0 failures** (2026-08-01) |
| `swift test --package-path Packages/KeyboardCore` | **861 tests, 0 failures** (2026-08-01) |
| `bash scripts/ensure_rime_vendor.sh verify` | **11 RIME framework artifacts verified** |
| `git diff --check` | **passed** |

Focused tests added in
`Packages/KeyboardCore/Tests/KeyboardCoreTests/ResponsiveProvisionalCompositionTests.swift`:

- `testDualGateStaleActionMatrixFailsClosedWithoutStateMutation`
- `testDeferredL1LeavesSettledChromeSnapshotUntouched`
- `testAbandonEpochDropsDeferredHostWritesAndStaleResult`

## Remaining P2 debts

| Debt | Status / reason |
|---|---|
| Extension candidate bar/expanded prefetch no-op while ahead | **Open** — current `KeyboardTests` target depends on `KeyboardCore` only; no UIKit Extension test was added or implied by the SwiftPM result |
| Real-librime / device subjective latency, queue depth, memory/jetsam and Release evidence | **Open** — outside this test-only slice and requires separate Product authorization |

The Core action/stale-chrome and epoch/host-history portions are now represented by
focused regression contracts. The action test is intentionally a Core guard and
behavior proof rather than a per-method engine spy; that does not prove the
Extension prefetch entry point or real-device behavior. This evidence therefore
remains a bounded Core subset, not a Product Gate or release decision.

## Independent review disposition

- [Architecture review](../assignments/t9-responsive-pipeline-001-p2-regression-matrix-architecture-review.md): bounded Pass with conditions; initial P2-EPC gap identified.
- [Architecture re-review](../assignments/t9-responsive-pipeline-001-p2-regression-matrix-architecture-rereview.md): bounded Pass with conditions; P2-EPC closed at Core/Fake-host scope.
- [Quality review](../assignments/t9-responsive-pipeline-001-p2-regression-matrix-quality-review.md): bounded Pass with conditions; initial P2-EPC gap identified.
- [Quality re-review](../assignments/t9-responsive-pipeline-001-p2-regression-matrix-quality-rereview.md): bounded Pass with conditions; P2-EPC closed at Core/Fake-host scope.

Remaining P2: UIKit prefetch/real UI owner-call observation, and real librime/device/
performance/jetsam/Release evidence. Timing sleeps remain a P3 test-maintenance debt.

## Handoff

Stop at this bounded slice. Any production wiring, UI-target test dependency,
real-librime run, R6 or default-on decision requires a new Product Lead
authorization.
