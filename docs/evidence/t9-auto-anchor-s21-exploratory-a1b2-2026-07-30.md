# T9-AUTO-ANCHOR-001-S21 exploratory A1→B2 physical pair — 2026-07-30

## Scope and authority

- Assignment:
  [`T9-AUTO-ANCHOR-001-S21`](../assignments/t9-auto-anchor-001-s21-rolling-design.md)
- Parent Assignment:
  [`T9-AUTO-ANCHOR-001`](../assignments/t9-auto-anchor-001.md)
- Product authorization:
  [`PD-T9-AUTO-ANCHOR-001`](../product-decisions/T9-AUTO-ANCHOR-001-authorization.md)
- Architecture boundary:
  [`ADR 0024`](../architecture/decisions/0024-t9-auto-anchor-shadow-observation-boundary.md)
- Automated implementation evidence:
  [`t9-auto-anchor-s21-implementation-2026-07-29.md`](t9-auto-anchor-s21-implementation-2026-07-29.md)
- Implementation source checkpoint (immutable for both arms):
  `90642c308bbece4f5330951ffa54925b0ae195c4`
- Design base:
  `c42cec2db3296e28a7cbcbd42471a4c7b005ea5e`

This is Layer-3 **exploratory** physical-device evidence for the manually entered
`A1`/`B2` arms, including the first exploratory pair and the optional
three-pair counterbalanced Human matrix. It is **not** Product Gate, Release
enablement, a fixed-cadence benchmark or a public performance claim.

Coordinate/XCTest/Computer Use typing into the third-party keyboard was not
used. The Human Product Owner typed the frozen fixture on the physical device.

## Device Run Header

| Field | Value |
|---|---|
| Device name | `DoubleShy0N` |
| Marketing name | iPhone 13 Pro |
| Product type | `iPhone14,2` |
| UDID | `00008110-000A08440198801E` |
| OS | iOS 27.0 (`24A5390f`) |
| Connection | wired, paired, Developer Mode enabled |
| Host app | Reminders (blank title each arm) |
| Layout | Universe Keyboard Chinese nine-key, software keyboard |
| RIME schema | `luna_pinyin` (bundled `Keyboard/Resources/default.yaml` / schema_id) |
| Full Access | Enabled for operational purposes (RIME session create + processKey succeeded on both arms; not re-probed via a separate entitlement API call mid-run) |
| Thermal / power | Not instrumented; ordinary handheld use, no declared thermal throttling observation |
| Fixture | `jintiandetianqihenbucuowomenchuquwanba` (38 letter-group keys) |
| Interaction | no Path, candidate, Space, Delete or Return during an arm |
| Source checkpoint | `90642c3` (full SHA above) |

## Arm identities

Both arms were built from the same source checkpoint as **Release** /
`generic/platform=iOS` with team `C33N6HTS9N`, arm64, and installed only by
replacement (`xcrun devicectl device install app`). No uninstall, container
erase, userdb reset or Reminders deletion was performed.

### A1 (single accepted S4 anchor)

- Swift conditions:
  `-DT9_AUTO_ANCHOR_DEVICE_PREFLIGHT -DT9_AUTO_ANCHOR_DEVICE_PREFLIGHT_ENABLED`
- DerivedData:
  `/private/tmp/universe-keyboard-s21-a1-manual-90642c3`
- App executable SHA256:
  `cc4fc6a9114f2fdbca38882229a05a243d45a3718fd97ccbfce14ce8ebd1fd7c`
- Extension executable SHA256:
  `e43d5a2f74480f2384dc301e87f011bb5f4d21f81e7fae3b1105c3a0e50ccd04`
- App / Extension UUID:
  `41D4DA3A-F545-3086-A265-9C55D0712D2C` /
  `9B390AFD-6DDF-384D-9A89-5AE8E4D0CB2E`
- Extension strings: `T9DEVICE_ENABLED` present; no `T9DEVICE_DISABLED`

### B2 (S2.1 rolling extension on top of A1)

- Swift conditions: A1 conditions plus
  `-DT9_AUTO_ANCHOR_ROLLING_PREFLIGHT_ENABLED`
- DerivedData:
  `/private/tmp/universe-keyboard-s21-b2-manual-90642c3`
- App executable SHA256:
  `d71c72057e63c0aa7ee4769997efbb73058c12304a139dc2dc9bb7991609589f`
- Extension executable SHA256:
  `fc1475e1defca3b5251c4056849ee20382571e71b1c3191bb398c2e2b9fa0022`
- App / Extension UUID:
  `73E720B9-3470-37AD-AB94-3BFB680A3676` /
  `7BE49CF8-1CED-3F5F-A115-972CA5D21854`
- Extension strings: `T9DEVICE_ENABLED` present; no `T9DEVICE_DISABLED`
- Extension hash differs from A1 (gate-only binary difference confirmed)

## Measurement notes

- Human path logs report `run=invalid` because no UITest run-token envelope was
  prepared. Comparison keys are **local `event` identity**, session id and
  content-free counters, not the run token.
- `T9GEOM … status=unavailable` is expected for Human manual input.
- `SLOW *` warnings use a low diagnostic threshold (~50 ms) and are not arm
  failure criteria.
- Comparison uses physical `event=1…38`. After accepted anchors, `rawLen` is
  longer than the physical key ordinal and must not be used as the pairing key.

## Pair 1 A1 observation

Human report: no missing/duplicate keys, candidates remained visible, keyboard
did not terminate; fast typing still felt clearly stalled.

Content-free App Performance export (held local; repository keeps aggregates):

| Field | Value |
|---|---|
| Export path (held local) | `/private/tmp/universe-keyboard-s21-a1-perf-export-2026-07-30.txt` |
| Export SHA256 | `2dff1dee934329299200e93ab1d4d3205429af0788815d27edeabfa8c94252d6` |
| Export size | 14886 bytes |
| Marker | `T9DEVICE_ENABLED` / `gate=on` |
| Session | `4385899096`, stable and valid for all 38 events |
| Commits | 0 |
| Candidates | 12 on every event |
| Paths after warm-up | 7 |
| T9AUTO | exactly **1** `status=accepted`, `attempt=1` |
| Bound physical action ordinal | accepted on the key that produced `T9SEG action=18` / `event=18` |
| Anchor | `anchorSlots=7`, `unresolvedSlots=11`, `applyMs≈1.43` |
| rawLen jump | event 17→18: 17→20 (only non-+1 step) |
| T9ARM | `actions=38 committed=0 sessionStable=true` |

One extra key after arm close (`event=39`, total 16.6 ms) was excluded from the
arm window. Pairing uses only `event=1…38`.

| Scope | n | total median | total p95 | total worst | ≥50 ms | ≥100 ms |
|---|---:|---:|---:|---:|---:|---:|
| All events | 38 | 9.95 ms | 156.5 ms | 175.9 ms | 5 | **4** |
| Continuous excl. first-key warm-up | 37 | 9.90 ms | 156.9 ms | 175.9 ms | 4 | **4** |

≥100 ms spikes (RIME ~99% of total):

| Event | Approx. fixture boundary | total | rime |
|---:|---|---:|---:|
| 16 | `…anqi` → `h` of `hen` | 155.3 | 153.8 |
| 25 | near `women` | 144.1 | 142.5 |
| 33 | near end of `chuqu` | **175.9** | 174.5 |
| 35 | into `wanba` | 163.1 | 161.8 |

## Pair 1 B2 observation

Human report: no missing/duplicate keys, candidates remained visible, keyboard
did not terminate; stalls felt slightly better than A1 but still noticeable.

| Field | Value |
|---|---|
| Export path (held local) | `/private/tmp/universe-keyboard-s21-b2-perf-export-2026-07-30.txt` |
| Export SHA256 | `425915161391d43cb16d189b7a7946369b7d5fc0384d3a7ab61d31fe7aa51bab` |
| Export size | 14607 bytes |
| Marker | `T9DEVICE_ENABLED` / `gate=on` |
| Session | `4453500696`, stable and valid for all 38 events |
| Commits | 0 |
| Candidates | 12 on every event |
| T9AUTO | exactly **2** `status=accepted` |
| Attempt 1 physical action ordinal | **18** (`T9SEG action=18` / `event=18`): `anchorSlots=7`, `unresolvedSlots=11`, `applyMs≈5.07` |
| Attempt 2 physical action ordinal | **20** (`T9SEG action=20` / `event=20`, ≤23 and after attempt 1): `anchorSlots=13`, `unresolvedSlots=7`, `applyMs≈2.46` |
| rawLen jumps | 17→20 at event 18; 21→24 at event 20 |
| T9ARM | `actions=38 committed=0 sessionStable=true` |
| Extra key after 38 | none observed |

| Scope | n | total median | total p95 | total worst | ≥50 ms | ≥100 ms |
|---|---:|---:|---:|---:|---:|---:|
| All events | 38 | 14.40 ms | 126.2 ms | 142.3 ms | 4 | **3** |
| Continuous excl. first-key warm-up | 37 | 14.40 ms | 126.8 ms | 142.3 ms | 3 | **3** |

≥100 ms spikes (RIME ~99% of total):

| Event | Approx. fixture boundary | total | rime |
|---:|---|---:|---:|
| 24 | later mid-string after second anchor | 136.6 | 135.3 |
| 32 | late string | **142.3** | 140.9 |
| 34 | late string | 124.4 | 123.1 |

## Direction gate (frozen experiment stop rule)

Rule from Assignment Layer 3: advance only when B2, relative to paired A1,
both **reduces** the count of events at or above `100 ms` and **does not
increase** the arm worst total. This is not a shipping SLO.

| Metric | A1 | B2 | Result |
|---|---:|---:|---|
| Events ≥100 ms (1…38) | 4 | 3 | reduced |
| Worst total | 175.9 ms | 142.3 ms | not increased |
| Continuous excl. e1 total sum | 945.8 ms | 857.1 ms | diagnostic only |
| Continuous excl. e1 RIME sum | 793.7 ms | 645.0 ms | diagnostic only |

**Direction decision: PASS.**

Spike positions moved rather than disappearing: A1's ≥100 ms set
`{16,25,33,35}` became B2's `{24,32,34}`. Per-event deltas where either arm is
slow show large reductions at A1 spike sites and new RIME-dominated spikes
later in B2. Residual stalls remain ~99% librime `processKey`.

## Integrity classification

| Arm | Valid? | Functional integrity | Notes |
|---|---|---|---|
| A1 | Yes | Pass | Extra post-arm key excluded |
| B2 | Yes | Pass | Two accepted transactions as contracted |

Subjective product judgment for pair 1: **directionally helpful / residual
stalls remain**. Not classified as product-goal complete.

## Ordinary Release restoration

After the pair, ordinary gate-off Release was rebuilt from the same source
checkpoint `90642c3` with **no** preflight Swift conditions and installed by
replacement.

- DerivedData:
  `/private/tmp/universe-keyboard-s21-ordinary-restore-90642c3`
- Bundle id / version / build:
  `com.DoubleShy0N.Universe-Keyboard` / `1.0` / `1`
- Extension executable SHA256:
  `99531a1fc2ce0ecf3fc1e154fcbe576559b4d9567fc895ddb6f32e706fb1251f`
- Extension string scan for `T9DEVICE_`: no matches
- Installation: `xcrun devicectl device install app` replacement on the same
  UDID; operator should fully dismiss Reminders once so the ordinary Extension
  process reloads.

## Three-pair counterbalanced Human matrix

Same freeze as pair 1: device, schema `luna_pinyin`, checkpoint `90642c3`,
Release artifacts (A1/B2 Extension SHA as above), Human method, fixture
`jintiandetianqihenbucuowomenchuquwanba`. Pair 1 is reused; only pair 2 and
pair 3 were newly typed. All six arms retained functional integrity (no
missing/duplicate keys, candidates present, keyboard stayed up) per Human
report and content-free logs. Extra keys after `T9ARM` (event 39) were excluded
from each arm window.

Direction rule (per pair, B2 relative to that pair's A1): reduce count of
events with total ≥100 ms **and** do not increase arm worst total.

| Pair | Order | A1 ≥100 / worst | B2 ≥100 / worst | B2 accepts | Direction |
|---:|---|---:|---:|---|---|
| 1 | A1→B2 | 4 / 175.9 ms | **3** / 142.3 ms | 2 @18,20 | **PASS** |
| 2 | B2→A1 | 4 / 184.9 ms | 4 / 179.7 ms | 2 @18,21 | **FAIL** (count) |
| 3 | A1→B2 | 4 / 187.7 ms | 4 / 170.8 ms | 2 @18,21 | **FAIL** (count) |

### Pair 2 detail (`B2→A1`)

| Arm | Session | ≥100 ms events | worst | Notes |
|---|---|---|---:|---|
| B2 | `5149852632` | 16,25,33,35 | 179.7 | Human: more stall than pair-1 B2 |
| A1 | `4369065816` | 16,25,33,35 | 184.9 | Human: similar to this B2; worse than pair-1 A1 |

Held-local export digests:

- Pair2 B2:
  `/private/tmp/universe-keyboard-s21-pair2-b2-perf-export-2026-07-30.txt`
  SHA256 `87f75d826204ad71901ee00bbc385d9970741c5ef13d4e824a9e87159513b507`
- Pair2 A1:
  `/private/tmp/universe-keyboard-s21-pair2-a1-perf-export-2026-07-30.txt`
  SHA256 `310f50082d22acce912f8219f3f97b1d0f234c7609f85477fda6a89e682278d4`

On every ≥100 ms site B2 was slightly lower than A1, but **no** ≥100 ms event
was eliminated, so the frozen count rule fails.

### Pair 3 detail (`A1→B2`)

| Arm | Session | ≥100 ms events | worst | Notes |
|---|---|---|---:|---|
| A1 | `4368118680` | 16,25,33,35 | 187.7 | action ordinals continued 93…; use `event` |
| B2 | `4415122264` | 16,25,33,35 | 170.8 | attempt2 @21; T9ARM `actions=38` |

Per-spike deltas (B2−A1): e16 −16.9, e25 −22.7, e33 −27.2, e35 −23.5 ms —
consistent mild softening, still four RIME-dominated spikes.

### Matrix synthesis

| Metric | Result |
|---|---|
| Direction PASS pairs | **1 / 3** |
| A1 ≥100 ms (all pairs) | always **4** |
| B2 ≥100 ms | 3, 4, 4 |
| B2 contract | always 2 accepts, attempt2 ≤23, stable session, 0 commit |
| Residual class | librime `processKey` ~99% of every ≥100 ms event |
| Classification | **directionally helpful at best / not robust / insufficient for product goal** |

Manual cadence and session heat remain confounds. Pair 1 alone overstates
stability; pairs 2–3 show the ≥100 ms **count** reduction does not reliably
reproduce. Softening of individual spikes without count reduction is real but
below the Assignment stop rule and far from a shipping claim.

After pair 3 B2, ordinary gate-off Release was again replacement-installed
from the same ordinary artifact identity recorded above
(Ext SHA256 `99531a1fc2ce0ecf3fc1e154fcbe576559b4d9567fc895ddb6f32e706fb1251f`).

## Explicit non-claims

- Not Product Gate / Release default enablement / user-facing setting change.
- Not a fixed-cadence microbenchmark; manual typing cadence remains a confound.
- Not authorization for a third automatic apply attempt or broader policy.
- Not proof that residual long-composition stalls are solved.

## Independent review (pair-1 package)

Architecture and Quality independently reviewed the initial pair-1 Layer-3
record (read-only). Documentary P2/P3 completeness items were closed before
matrix expansion:

| Reviewer | Verdict | P0 | P1 | P2 | P3 |
|---|---|---:|---:|---:|---:|
| Architecture & Knowledge Steward | **Pass** | 0 | 0 | closed | closed |
| Quality, Performance & Release Maintainer | **Pass** | 0 | 0 | closed | closed |

That review authorized the three-pair matrix. The completed matrix is recorded
here as Quality evidence for Product routing; it does **not** by itself re-open
implementation review or authorize Release.

## Remaining after this evidence

1. Product Lead decision: stop S2.1 mechanism investment at “not robust for
   product goal”, or authorize a **new** Assignment aimed at the residual
   RIME-dominated `processKey` class (not silent attempt-3 expansion).
2. Optional independent Quality/Architecture skim of the matrix tables if
   Product wants a second signature before routing.
3. Ordinary Release remains gate-off (restored).
