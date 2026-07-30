# T9-AUTO-ANCHOR-001-S22 — implementation + B2→B3 exploratory evidence — 2026-07-30

## Scope and authority

- Assignment:
  [`T9-AUTO-ANCHOR-001-S22`](../assignments/t9-auto-anchor-001-s22-stronger-controller-bounding.md)
- Parent:
  [`T9-AUTO-ANCHOR-001`](../assignments/t9-auto-anchor-001.md)
- Product Decision (design + implementation auth):
  [`PD-T9-AUTO-ANCHOR-001`](../product-decisions/T9-AUTO-ANCHOR-001-authorization.md)
- Architecture:
  [`ADR 0024`](../architecture/decisions/0024-t9-auto-anchor-shadow-observation-boundary.md) §17–20
- Implementation commit:
  `459908dfa9de578369255781680f6773cbf1bcb0`
- Predecessor S2.1 matrix:
  [`t9-auto-anchor-s21-exploratory-a1b2-2026-07-30.md`](t9-auto-anchor-s21-exploratory-a1b2-2026-07-30.md)

This record covers automated Layer-1/2 evidence and one Human exploratory
**B2 → B3** pair. It is **not** Product Gate, Release enablement, a fixed-cadence
benchmark or a public performance claim.

## Implementation summary

| Item | Detail |
|---|---|
| Feature | Third cumulative rolling auto-anchor (attempt 3, +2 syllables) |
| Gate | `isTripleRollingT9AutoAnchorEnabled` / compile flag `T9_AUTO_ANCHOR_TRIPLE_ROLLING_PREFLIGHT_ENABLED` |
| Nesting | Requires A1 preflight enable + B2 rolling; ordinary Release all off |
| Safety | Same fail-closed / Path-Partial-Delete / prior-mixed restore family as S2.1 |

### Layer 1 — KeyboardCore

```text
swift test --package-path Packages/KeyboardCore --filter T9ReversibleAutoAnchorTests
# 37/37 passed (includes triple accept, B2 isolation, third-reject restore)

swift test --package-path Packages/KeyboardCore
# 772/772 passed
```

### Layer 2 — pinned real-RIME (Simulator)

- Destination: iOS 27.0 iPhone 17 Pro Max Simulator
  `06C5BC3E-7599-4761-A1A2-71DAEA991474`
- Scheme: `RimeBridgeTests` / Debug / warnings-as-errors
- Isolated fixture:
  `UK_RIME_T9_SPIKE_SHARED_DIR=/private/tmp/universe-keyboard-s22-rime-matrix.THFNV2/shared`
  `UK_RIME_T9_SPIKE_USER_DIR=/private/tmp/universe-keyboard-s22-rime-matrix.THFNV2/user`
  (+ `TEST_RUNNER_*` and `SIMCTL_CHILD_*` forms)
- Test:
  `RimeT9AutoAnchorRetryMatrixTests/testRollingControllerFrozenA0A1B2B3Matrix`
- Result: **passed** (~50.5 s), 0 failures

| Arm | actions | sessions | replaceInput | accepts (physical action:attempt) |
|---|---:|---:|---:|---|
| A0 | 38 | 1 | 0 | — |
| A1 | 38 | 1 | 1 | 18:1 |
| B2 | 38 | 1 | 2 | 18:1 → 20:2 (attempt2 ≤23) |
| B3 | 38 | 1 | 3 | 18:1 → 20:2 → **22:3** (attempt3 ≤28) |

xcresult (held local):
`/private/tmp/universe-keyboard-s22-rimebridge-matrix-run/Logs/Test/Test-RimeBridgeTests-2026.07.30_20-14-08-+0800.xcresult`

## Layer 3 — Human B2→B3 exploratory pair

### Device Run Header

| Field | Value |
|---|---|
| Device | iPhone 13 Pro `DoubleShy0N` / `iPhone14,2` |
| UDID | `00008110-000A08440198801E` |
| OS | iOS 27.0 (`24A5390f`) |
| Host | Reminders, new empty title per arm |
| Layout | Universe Keyboard Chinese nine-key |
| Schema | `luna_pinyin` (runtime) |
| Fixture | `jintiandetianqihenbucuowomenchuquwanba` (38 keys) |
| Interaction | no Path / candidates / Space / Delete / Return mid-arm |
| Source | `459908d` for both arms |

### Arm identities (Release, replacement install)

| Arm | Swift conditions | Extension SHA256 |
|---|---|---|
| B2 | `DEVICE_PREFLIGHT` + `ENABLED` + `ROLLING` | `c4238c727e2611564fd6d6b3b9c71ca622161dbca70ffc31c65acb728e7d7644` |
| B3 | B2 + `TRIPLE_ROLLING` | `51f623ad456b6902307c68739feacdb4f9d5870bd363cc96496fe1b3688375c1` |

DerivedData roots (held local):

- B2: `/private/tmp/universe-keyboard-s22-b2-manual-459908d`
- B3: `/private/tmp/universe-keyboard-s22-b3-manual-459908d`

### Invalid B3 attempts (discarded)

1. Mid-composition clear after attempt3 (~event 24); `sessionStable=false`.
2. Retype with only **37** contiguous events (missing event 38) — mechanism showed
   3 accepts but arm incomplete under contract.

These do not enter direction scoring.

### Valid B2 arm

| Field | Value |
|---|---|
| Session | `4373546648`, stable |
| Accepts | 2 @ physical event **18**, **21** (≤23) |
| Commits | 0; cands=12 |
| ≥100 ms events | **4** — e16=182.0, e25=132.4, e33=165.2, e35=121.8 |
| Worst | **182.0 ms** |
| Subjective | Still stuttery; no special improvement |

### Valid B3 arm

| Field | Value |
|---|---|
| Session | `4414667928`, stable |
| Accepts | 3 @ physical event **18**, **21**, **24** (≤28) |
| Commits | 0; cands=12; `T9ARM actions=38 sessionStable=true` |
| ≥100 ms events | **3** — e16=178.8, e33=120.0, e35=117.5 |
| Worst | **178.8 ms** |
| Subjective | Still some stutter |

event=39 extra key after arm close excluded from the window.

### Direction gate (B3 relative to paired B2)

Rule: reduce count of events with total ≥100 ms **and** do not increase worst.

| Metric | B2 | B3 | Result |
|---|---:|---:|---|
| ≥100 ms count | 4 | 3 | reduced |
| Worst total | 182.0 | 178.8 | not increased |
| **Direction** | | | **PASS** |

Paired slow-site notes:

| Event | B2 | B3 | Note |
|---:|---:|---:|---|
| 16 | 182.0 | 178.8 | Pre-first-anchor spike remains |
| 25 | 132.4 | **62.7** | Dropped below 100 ms after third anchor |
| 33 | 165.2 | 120.0 | Still ≥100, reduced |
| 35 | 121.8 | 117.5 | Still ≥100 |

## Ordinary Release restoration

After the pair, ordinary gate-off Release from the same source tree was
replacement-installed:

- DerivedData: `/private/tmp/universe-keyboard-s22-ordinary-459908d`
- Extension SHA256:
  `117ee163b67a60cde44fd32533655e5262580fb7687f68fd6e6d22d54b109aaa`
- `T9DEVICE_*` strings: none

## Synthesis

| Layer | Outcome |
|---|---|
| Mechanism (Layer 1–2 + valid B3) | **PASS** — third accept fires on-contract |
| Exploratory direction (one B2→B3 pair) | **PASS** — ≥100 ms 4→3, worst not up |
| Product north star | **Not met** — three ≥100 ms RIME spikes remain; Human still feels stutter |
| vs S2.1 | Extra dose mainly compresses **mid-string (e25-class)** spikes; **e16** and **late 33/35** remain |

## Explicit non-claims

- Not Product Gate / Release default enablement / user setting.
- Not a multi-pair robust direction claim (single exploratory pair).
- Not proof that further automatic attempts alone will clear pre-anchor e16.
- Not reopening Lua/force_gc as primary remedy.

## Remaining / routing (closed 2026-07-30)

Product accepted the KOS recommendation (“按推荐执行”):

1. **S2.2 closed for default expansion** — no attempt 4+ without a new PD.
2. **Next knife = S2.3 earlier first-anchor** (design only) targeting residual
   pre-first-anchor **e16-class** spikes; see
   [`../assignments/t9-auto-anchor-001-s23-earlier-first-anchor.md`](../assignments/t9-auto-anchor-001-s23-earlier-first-anchor.md).
3. Optional Architecture/Quality implementation review of `459908d` remains
   available and non-blocking for S2.3 design.
