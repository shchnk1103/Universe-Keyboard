# T9-AUTO-ANCHOR-001-S23 — Human B3→B3e exploratory evidence — 2026-07-30

## Scope and authority

- Assignment:
  [`T9-AUTO-ANCHOR-001-S23`](../assignments/t9-auto-anchor-001-s23-earlier-first-anchor.md)
- Parent:
  [`T9-AUTO-ANCHOR-001`](../assignments/t9-auto-anchor-001.md)
- Product Decision:
  [`PD-T9-AUTO-ANCHOR-001`](../product-decisions/T9-AUTO-ANCHOR-001-authorization.md)
- Architecture:
  [`ADR 0024`](../architecture/decisions/0024-t9-auto-anchor-shadow-observation-boundary.md) §21–24
- Implementation commit:
  `0272a030e8a5b49112d681644dcd4aebf8263e6c` (docs pin `30e172b` tree for
  device builds)
- Automated predecessor:
  [`t9-auto-anchor-s23-implementation-2026-07-30.md`](t9-auto-anchor-s23-implementation-2026-07-30.md)
- S2.2 exploratory pair:
  [`t9-auto-anchor-s22-b2b3-2026-07-30.md`](t9-auto-anchor-s22-b2b3-2026-07-30.md)

This record covers one Human exploratory **B3 → B3e** pair. It is **not**
Product Gate, Release enablement, a multi-pair robust claim or a public
performance claim.

## Device Run Header

| Field | Value |
|---|---|
| Device | iPhone 13 Pro `DoubleShy0N` / `iPhone14,2` |
| UDID | `00008110-000A08440198801E` |
| OS | iOS 27.0 |
| Host | Reminders, new empty title per arm |
| Layout | Universe Keyboard Chinese nine-key |
| Schema | `luna_pinyin` (runtime) |
| Fixture | `jintiandetianqihenbucuowomenchuquwanba` (38 keys) |
| Interaction | no Path / candidates / Space / Delete / Return mid-arm |
| Source tree | `30e172b` (S2.3 implementation + evidence pin) |

### Arm identities (Release, replacement install)

| Arm | Swift conditions | Extension SHA256 |
|---|---|---|
| B3 | `DEVICE_PREFLIGHT` + `ENABLED` + `ROLLING` + `TRIPLE` | `0406593e24908e7722d80b3e02604ff9398d1fc94e45011c2b7a7e1440954c0b` |
| B3e | B3 + `EARLIER_FIRST` | `fe24d32debd281c0d31f72fab5b6b5c0ca1cb57e6526528911feba99a4773a01` |

DerivedData roots (held local):

- B3: `/private/tmp/universe-keyboard-s23-b3-manual-30e172b`
- B3e: `/private/tmp/universe-keyboard-s23-b3e-manual-30e172b`

## Valid B3 arm

| Field | Value |
|---|---|
| Session | `4678235096`, stable |
| Accepts | 3 @ physical event **18**, **21**, **24** (≤28) |
| Commits | 0; cands=12; `T9ARM actions=38 sessionStable=true` |
| ≥100 ms events | **3** — e16=188.1, e33=113.6, e35=115.1 |
| Worst | **188.1 ms** |
| e25 | 65.9 (&lt;100) |
| Subjective | Still stuttery |

event=39 after arm close excluded.

## Valid B3e arm

| Field | Value |
|---|---|
| Session | `4406775768`, stable |
| Accepts | 3 @ physical event **12**, **18**, **24** (attempt1 ≤15) |
| Commits | 0; cands=12; `T9ARM actions=38 sessionStable=true` |
| ≥100 ms events | **3** — e16=156.7, e33=121.9, e35=101.6 |
| Worst | **156.7 ms** |
| e25 | 66.8 (&lt;100) |
| Subjective | “好像只有一处地方有明显的卡顿了” |

event=39 after arm close excluded.

### Mechanism notes (B3e)

- Earlier-first **fired on contract**: first accept at physical **12**
  (`anchorSlots=7`, `unresolvedSlots=5`, two syllables).
- Rolling/triple still stacked: attempt2 @18, attempt3 @24.
- Overlap on attempt1 was **4/5** (still accepted under conservation).

## Direction gate (B3e relative to paired B3)

Rule: reduce count of events with total ≥100 ms **and** do not increase worst.

| Metric | B3 | B3e | Result |
|---|---:|---:|---|
| ≥100 ms count | 3 | 3 | **not reduced** |
| Worst total | 188.1 | 156.7 | not increased |
| **Direction** | | | **FAIL** |

Paired slow-site notes:

| Event | B3 | B3e | Note |
|---:|---:|---:|---|
| 16 | 188.1 | **156.7** | Still ≥100; magnitude improved ~17% but remains the dominant spike |
| 25 | 65.9 | 66.8 | Both &lt;100 (mid-string already controlled by B3 stack) |
| 33 | 113.6 | 121.9 | Still ≥100; slightly worse |
| 35 | 115.1 | 101.6 | Still ≥100; slightly better, still over bar |

Interpretation:

- **Mechanism knife worked** (first anchor moved from 18 → 12).
- **Product direction bar not met**: residual set still has **three** ≥100 ms
  RIME spikes; e16 remains pre-late but **post-first-anchor** under B3e (accept
  at 12, spike at 16 with rawLen=18 after mixed growth).
- Subjective improvement (one obvious hitch) matches e16 remaining the clear
  outlier while e33/e35 hover near the 100 ms edge.

## Ordinary Release restoration

After the pair, ordinary gate-off Release from the same source tree was
replacement-installed:

- DerivedData: `/private/tmp/universe-keyboard-s23-ordinary-30e172b`
- Extension SHA256:
  `5d4da4c462f31902f16056e0cd5ed9a33ef21bd0288452deb7f622dce5bcd8ee`
- `T9DEVICE_*` strings: none

## Synthesis

| Layer | Outcome |
|---|---|
| Mechanism (Layer 1–2 + valid B3e) | **PASS** — earlier first accept @12 on device |
| Exploratory direction (one B3→B3e pair) | **FAIL** — ≥100 ms count 3→3 |
| Product north star | **Not met** — residual RIME spikes remain; Human still feels hitch |
| vs S2.2 | Earlier floor moves anchor before old e16 window but does **not** remove a ≥100 event from the set |

## Explicit non-claims

- Not Product Gate / Release default enablement / user setting.
- Not a multi-pair robust direction claim.
- Not proof that further floor lowering or attempt 4 will clear e16/e33/e35.
- Not reopening Lua/force_gc as primary remedy.

## Remaining / Product routing inputs

1. Direction FAIL on frozen rule → **do not fish** for better cadence by retype.
2. Optional stop-fast questions for Product (not auto-executed):
   - accept magnitude-only improvement as soft signal and keep earlier-first as
     default-off base;
   - attack residual **post-early-anchor mid spikes** (e16-class after accept)
     and/or **late 33/35** with a new knife;
   - reopen schema/RIME residual track only with new evidence;
   - stop controller dose escalation (no attempt 4 by default).
