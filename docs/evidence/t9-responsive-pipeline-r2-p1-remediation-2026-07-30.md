# T9-RESPONSIVE-PIPELINE-001 R2 P1 remediation evidence

| Field | Value |
|---|---|
| Date | 2026-07-30 Asia/Shanghai |
| Addresses | Arch R2 P1-1 dual-entry; Arch/Quality P1 publish→UI; visibility owner path |
| Not fixed (by design residual) | Arch P1-3 off-MainActor librime (Swift 6 + no `@unchecked Sendable`) |

## Changes

1. **`ResponsiveRimeEngineBridge`** — when gate on, installed as `controller.rimeEngine` so Delete / select / Path / reset / recover / page / candidateWindow all enter the same coordinator pipeline (flush-before-read for windows).
2. **`performOrderedNow` / `flushPending`** — drain **entire** pending queue before returning so pending processKey cannot be overtaken by Delete.
3. **`onResponsivePresentationNeeded`** — after deferred snapshot apply, fire `KeyboardEffect` (composition + T9 paths); Extension wires `syncUI(with:)` in bootstrap.
4. **Visibility** — suspend/resume/reset go through coordinator flush + owner; abandon still bumps epoch.
5. **Tests** — bridge delete-after-pending keys; presentation bridge; gate off unwraps underlying engine.

## Verification

```bash
cd Packages/KeyboardCore && swift test --filter ResponsiveRime
# 33 tests, 0 failures

cd Packages/KeyboardCore && swift test
# (full suite after remediation)
```

## Non-claims

Not Product Gate; not ADR 0025 Accept; not off-main librime; keep gate default off.
