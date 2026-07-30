# T9-RESPONSIVE-PIPELINE-001 R2 evidence

| Field | Value |
|---|---|
| Status | **Executor complete — independent Architecture/Quality review pending** |
| Date | 2026-07-30 Asia/Shanghai |
| Authorization | Human Product Owner R2 text (default-off serial owner + responsive key path) |
| Tip baseline before R2 | `5d5d837` (R1) |

## Delivered

| Path | Role |
|---|---|
| `SerialRimeSession.swift` | `SerialRimeSessionOwner` + `ResponsiveRimeSessionCoordinator` |
| `KeyboardController.swift` | `isResponsiveRimePipelineEnabled` (default false), coordinator rebuild, visibility epoch bump |
| `KeyboardController+RimeRecovery.swift` | Gate-on deferred `processKey` via `scheduleProcessKey` |
| `ResponsiveRimeR2CoordinatorTests.swift` | R2 gate / defer / order / epoch / fail-closed tests |

## Verification (Executor)

```bash
cd Packages/KeyboardCore && swift test --filter ResponsiveRime
# 30 tests, 0 failures (23 R1 pipeline + 7 R2 coordinator)

cd Packages/KeyboardCore && swift test
# 808 tests, 0 failures
```

## Isolation honesty

R2 does **not** move librime off MainActor. Swift 6 region isolation rejects
sending non-Sendable `RimeEngine` into a background actor without forbidden
`@unchecked Sendable` shuttling. R2 uses single-consumer MainActor ownership +
deferred drain so `handle` returns before `processKey` for the gated path.

## Non-claims

- Not Architecture Pass / Quality Pass / Product Gate
- Not ADR 0025 Accepted
- Not Release default-on
- Not full Path/Delete/select production rewiring for every call site (key path + owner APIs + tests; remaining call sites still use sync `rimeEngine` when gate off, and when gate on non-key paths largely remain sync on the same engine instance — residual for R3)
