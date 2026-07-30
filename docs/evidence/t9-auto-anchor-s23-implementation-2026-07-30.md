# T9-AUTO-ANCHOR-001-S23 — implementation + automated evidence — 2026-07-30

## Scope and authority

- Assignment:
  [`T9-AUTO-ANCHOR-001-S23`](../assignments/t9-auto-anchor-001-s23-earlier-first-anchor.md)
- Parent:
  [`T9-AUTO-ANCHOR-001`](../assignments/t9-auto-anchor-001.md)
- Product Decision (design + implementation auth):
  [`PD-T9-AUTO-ANCHOR-001`](../product-decisions/T9-AUTO-ANCHOR-001-authorization.md)
- Architecture:
  [`ADR 0024`](../architecture/decisions/0024-t9-auto-anchor-shadow-observation-boundary.md) §21–24
- Implementation commit:
  `0272a030e8a5b49112d681644dcd4aebf8263e6c`
- Predecessor S2.2 evidence:
  [`t9-auto-anchor-s22-b2b3-2026-07-30.md`](t9-auto-anchor-s22-b2b3-2026-07-30.md)

This record covers implementation and automated Layer-1/2 evidence. It is
**not** Product Gate, Release enablement, a fixed-cadence benchmark or a public
performance claim. Human **B3 → B3e** exploratory direction remains open.

## Implementation summary

| Item | Detail |
|---|---|
| Feature | Earlier first-anchor floors for attempt 1 only |
| Config | `experimentalEarlierFirst`: `minimumSourceDigitCount = 12` (vs 18) |
| Syllable rule | Still exactly **2** complete catalog syllables |
| Gate | `isEarlierFirstT9AutoAnchorEnabled` / compile flag `T9_AUTO_ANCHOR_EARLIER_FIRST_PREFLIGHT_ENABLED` |
| Nesting | Requires A1 preflight enable; orthogonal to B2 rolling / B3 triple |
| Safety | Same fail-closed / Path-Partial-Delete family; no attempt 4 |

### Layer 1 — KeyboardCore

```text
swift test --package-path Packages/KeyboardCore --filter T9ReversibleAutoAnchorTests
# 43/43 passed (includes earlier floor 11/12, gate-off isolation, B3e stack ceiling)

swift test --package-path Packages/KeyboardCore
# 778/778 passed
```

### Layer 2 — pinned real-RIME (Simulator)

- Destination: iOS 27.0 iPhone 17 Pro Max Simulator
- Scheme: `RimeBridgeTests` / Debug / warnings-as-errors
- Isolated fixture:
  `UK_RIME_T9_SPIKE_SHARED_DIR=/private/tmp/universe-keyboard-s22-rime-matrix.THFNV2/shared`
  `UK_RIME_T9_SPIKE_USER_DIR=/private/tmp/universe-keyboard-s23-rime-matrix.86809/user`
  (+ `TEST_RUNNER_*` and `SIMCTL_CHILD_*` forms)
- Test:
  `RimeT9AutoAnchorRetryMatrixTests/testRollingControllerFrozenA0A1B2B3Matrix`
- Result: **passed** (~79.8 s), 0 failures, 0 skips

| Arm | actions | sessions | replaceInput | accepts (physical action:attempt) |
|---|---:|---:|---:|---|
| A0 | 38 | 1 | 0 | — |
| A1 | 38 | 1 | 1 | 18:1 |
| B2 | 38 | 1 | 2 | 18:1 → 20:2 |
| B3 | 38 | 1 | 3 | 18:1 → 20:2 → 22:3 |
| **A1e** | 38 | 1 | 1 | **12:1** (≤15) |
| **B2e** | 38 | 1 | 2 | **12:1** → 18:2 |
| **B3e** | 38 | 1 | 3 | **12:1** → 18:2 → 22:3 |

Record line (content-free):

```text
T9_S21_A0_A1_B2_B3_A1e_B2e_B3e arm=a0,...;arm=a1e,...action=12:attempt=1...;arm=b3e,...action=12:attempt=1|action=18:attempt=2|action=22:attempt=3...
```

xcresult (held local):
`/private/tmp/universe-keyboard-s23-rimebridge-matrix-run/Logs/Test/Test-RimeBridgeTests-2026.07.30_20-46-01-+0800.xcresult`

### Mechanism vs residual product hypothesis

| Check | Result |
|---|---|
| Earlier floor enables attempt 1 at physical 12 on frozen fixture | **PASS** |
| Two-syllable first-anchor retained | **PASS** |
| No attempt 4 | **PASS** |
| Rolling/triple still stack on earlier first accept | **PASS** (B2e/B3e) |
| Pre-first-anchor e16-class product direction on device | **Pending Human B3→B3e** |

## Layer 3 — Human B3→B3e (not yet run)

Required next per Assignment: same device freeze family as S2.2, exploratory
pair **B3 → B3e**, direction rule on ≥100 ms count + worst, arm validity with
B3e attempt1 physical ≤15.

## Explicit non-claims

- Not Product Gate / Release default enablement / user setting.
- Not a Human direction claim (automated only).
- Not proof that e16/e33/e35 will clear on device.
- Not reopening Lua/force_gc or authorizing one-syllable first-anchor.

## Remaining

1. Human exploratory **B3 → B3e** on physical device + content-free App logs.
2. Ordinary Release gate-off restoration after the pair.
3. Product routing after direction result (goal met / residual late spikes /
   stop / next knife).
