# RESPONSIVE-DEFAULT-ON-001 — Evidence (2026-08-06)

**Assignment:** [`responsive-default-on-001.md`](../assignments/responsive-default-on-001.md)  
**Product Decision:** [`PD-RESPONSIVE-DEFAULT-ON-001`](../product-decisions/RESPONSIVE-DEFAULT-ON-001-authorization.md)  
**Date / timezone:** `2026-08-06 Asia/Shanghai`

## Product Gate claim (honest)

| Claim | Status |
|---|---|
| Ordinary Release **requests** dual-gate by default | **Implemented** (`productGateReleaseDefaultOn = true`) |
| Install fail-closed → ADR 0004 sync | **Preserved** (existing bootstrap) |
| Chinese 26-key + T9 L0 | **Inherited** ALL-LAYOUTS-001 |
| Numeric performance SLO | **Not claimed** |
| App Store submission | **Not claimed** (separate RELEASE work) |

## Code surface

| Location | Change |
|---|---|
| `ResponsiveRimePreflight.productGateReleaseDefaultOn` | `true` |
| `shouldArmDualGate(..., productDefaultOn:)` | Product Gate first |
| `KeyboardViewController+Bootstrap` | Passes Product Gate flag; comments updated |
| ADR 0025 §8 / ADR 0004 follow-up | Default-on language |

## Validation

```bash
swift test --package-path Packages/KeyboardCore --filter ResponsiveRimePreflight
swift test --package-path Packages/KeyboardCore
```

| Command | Result |
|---|---|
| Preflight + related focused filters | **Pass** (includes new Product Gate arming case) |
| Full KeyboardCore | **915 tests, 0 failures** |

## Prior evidence stack accepted by Product (not re-run)

- ADR 0025 Accepted; POST-ACCEPT; ALL-LAYOUTS-001  
- P2-PERF-02/03; CANARY-001 Stop/Retain; Rem-3 dual-gate direction  
- Formal R5 FAIL retained historical  

## Residuals (visible)

- Directional evidence only (no SLO)  
- CANARY process residuals  
- P2 UIKit debts; P3-D1 host hold  
