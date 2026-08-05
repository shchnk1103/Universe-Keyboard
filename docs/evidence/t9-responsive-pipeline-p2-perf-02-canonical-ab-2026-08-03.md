# P2-PERF-02 Canonical-bound A/B — A/B evidence

Pair: `P2P02-CANONICAL-AB-20260803-001`
Arm: **A / gate-off sync baseline**
Status: **A/B runtime complete; ordinary-package restore and one-key smoke complete**
Date: 2026-08-03 Asia/Shanghai

## Run identity

| Field | Value |
|---|---|
| Run ID | `P2P02-CANONICAL-A-20260803-001` |
| Device-preflight token | `S6A-3E1F0F062F414CBFA571CEEA8E92F281` |
| Canonical fixture | `T9-RESP-PERF-39-V1` / `772b4bb30cb831d04550e8311a2f64e66aad4ab55c4597544f0cc9364f9d7286` / 39 actions |
| Runtime marker fixture | `T9RESP-R5P` |
| Fixture binding | Protocol-declared canonical fixture; runtime proves 39 ordered actions but does not contain raw input, so independent text reconstruction is intentionally unavailable |
| Source | HEAD `3585a540ba8389673acd49128d87040ac9619f27`; pre-run dirty count 91; tracked diff SHA `5f67fc561b8e2494c895a6176909fc2602dad4492f275eed839a36eda40c45be`; untracked-name SHA `e69a4b2b1f03c302816e78e7fbf53f74d492e3efe264bdc93aa2d7de47ac0afe` |
| Build | Release; `T9_AUTO_ANCHOR_DEVICE_PREFLIGHT` only; app executable SHA `aefb5a4d9d2acaea9d896f4c3edd5efaab349266de06107406868d957e041cf4`; Keyboard executable SHA `134b9930da8285989ab5a850ce467f609907756b7a203c20e507e4d13b2989fb` |
| Bundle | `com.DoubleShy0N.Universe-Keyboard`; Keyboard extension `com.DoubleShy0N.Universe-Keyboard.Keyboard`; minimum OS `26.4` |
| Toolchain | Xcode `27.0 (27A5228h)`; iPhoneOS SDK `27.0`; Swift `6.4` |
| Device | iPhone 13 Pro / `iPhone14,2`; UDID `00008110-000A08440198801E`; CoreDevice `DE65EBE1-463E-5EB4-9694-F6DCBFC04028`; iOS `27.0 (24A5390f)` |
| Install | App install database sequence `3752`; install JSON remains in `/private/tmp/P2P02-CANONICAL-A-install.json` |
| Host | Same opaque empty Reminders list protocol; host text not retained; Full Access `unavailable` |

## Content-free artifact

The Human supplied a 499-line / 74,747-byte latest-500 diagnostic export. It remains outside
the repository:

- source attachment SHA-256: `a8e587fcd3d6997a77598a9324605dd4b7a897465ac0d18fc348fad22b8d97a8`
- extracted A-token marker subset: 44 lines / 15,051 bytes
- extracted subset SHA-256: `e2c11130ab3522062ae636e19c707b8f32bd26414382fb18d715d34f889f12fc`
- extracted subset path: `/private/tmp/P2P02-CANONICAL-A-content-free.log`

Only marker-shaped lines were retained; the extracted subset passed the shared content-free
allow-list (`T9DEVICE`, `T9GEOM`, `T9RESP`, `T9SEG`, `T9ARM`, `SLOW RIME`). No raw input,
candidate text, host text or screenshot was copied into the repository.

## Runtime validation

| Check | Observed result |
|---|---|
| T9DEVICE | `marker=T9DEVICE_DISABLED`, `gate=off`, `measurement=on` |
| T9RESP PATH | `path=sync`, `dualGateRequested=0`, `dualGateActive=0` |
| Geometry | prepared + execution present; same digest `0fe7271efa9c61e1c56e543a64b482d5435b81456bbad5fe1fd3054f90cbc032` |
| T9SEG | 39 records; action/event exactly `1…39`; all `committed=false` |
| Session | native identity `5686340504`; valid before/after; stable across all 39 records |
| Content-free privacy scan | pass |
| Responsive ACCEPT/PUBLISH | not required for sync A and not observed |

### Latency summary from the 39 `T9SEG` records

| Segment | Median (ms) | Max (ms) |
|---|---:|---:|
| total | 14.5 | 181.8 |
| engine | — | 180.6 |
| rime | 7.3 | 180.4 |
| ui | 5.3 | 8.1 |
| pathLocal | 0.6 | 1.4 |
| preedit | 0.1 | 0.1 |
| pathUI | 4.7 | 7.2 |
| candidateUI | 0.3 | 0.5 |

Five of the 39 records had `rime >= 50ms`; this is an observed diagnostic count, not a
product SLO or release claim.

## Human report

- Input method: manual software keyboard, Universe Keyboard Chinese nine-key
- Missing keys: `no`
- Duplicate keys: `no`
- Candidate disappeared: `no`
- Keyboard exited: `no`
- Ordered completion: `reported complete`
- Stall score: **2/4**
- Stall note: subjective intermittent key stalls; no host text retained

## Interpretation boundary

This A arm is a complete gate-off runtime observation for the declared protocol. It is not an
A/B result, does not prove the canonical raw sequence from content-free logs, does not accept
ADR 0025, and does not authorize a default-on or Release path. B must use its own fresh token,
the same canonical fixture protocol, and the same device/host setup.

## B arm — thread-affine diagnostic comparison

| Field | Value |
|---|---|
| Run ID | `P2P02-CANONICAL-B-20260803-001` |
| Device-preflight token | `S6A-0644586F078C44AAA8DAA4E45F882E43` |
| Build | Release; `T9_AUTO_ANCHOR_DEVICE_PREFLIGHT` + `T9_RESPONSIVE_DEVICE_PREFLIGHT_ENABLED`; app executable SHA `4049cec026b36e389cf160c52d053edd0fed160cc1d298f35282ed60005dd89a`; Keyboard executable SHA `ebdda088e809c14b629d23d76df89860fc3ce391686cc907ee5e9d27c4a2da39` |
| Install | App install database sequence `3760`; install JSON remains in `/private/tmp/P2P02-CANONICAL-B-install.json` |
| Source attachment | 499 lines / 90,343 bytes; SHA-256 `4a31dbd9bb0402cbc989cef9dee792303bf6d764a55da8fa44e342602864a5db` |
| Extracted B marker subset | 202 lines / 38,739 bytes; SHA-256 `4a30a074376c2e84020c184a1feacae5720dbdf0e3c6ca625070463e95403b13`; `/private/tmp/P2P02-CANONICAL-B-content-free.log` |

### B path and lifecycle markers

| Check | Observed result |
|---|---|
| T9DEVICE | `marker=T9DEVICE_DISABLED`, `gate=off`, `measurement=on` (auto-anchor measurement gate only) |
| T9RESP PATH | `path=thread-affine`, `dualGateRequested=1`, `dualGateActive=1` |
| T9RESP READY | `bootstrap=config-only`, `session=owner-thread` |
| T9RESP ACCEPT | 39 records, revisions `1…39`, epoch `1` |
| T9RESP PUBLISH | 39 records, revisions `1…39`, epoch-bound and ordered; owner completion coverage `39/39` |
| T9RESP VISIBLE | 42 records: 37 engine snapshots plus 5 provisional snapshots; provisional duplicates are allowed shadow feedback |
| T9RESP PAINT | 37 records; revisions 16 and 33 have no separate paint because latest-only presentation may coalesce UI snapshots; this does not reduce owner PUBLISH coverage |
| T9SEG | 39 records; action/event exactly `1…39`; all `committed=false` |
| Session | native identity `4381352920`; valid before/after; stable across all 39 records |
| Geometry | prepared + execution present; per-arm digest `826fc9d3ca8586b1826b2b7b69625d62dd9ffe0dbfb5898cd3e538ee2b11acfc`; coordinates match A after removing token/digest identity fields |
| Content-free privacy scan | pass |

The geometry digest intentionally includes each run token, so A and B digests differ by design;
the tokenless screen/keyboard/slot shape is identical. This is recorded as an observation, not
as a cross-run digest equality claim.

### B latency summary

`T9SEG` measures the immediate accept/UI path in B; the owner/engine delay is represented by
`VISIBLE`/`PAINT` lag markers.

| Segment | Median (ms) | Max (ms) | Count |
|---|---:|---:|---:|
| T9SEG total | 0.3 | 0.7 | 39 |
| T9SEG engine | 0.1 | 0.4 | 39 |
| T9SEG UI | 0.2 | 0.4 | 39 |
| engine VISIBLE lag | 8.0 | 160.0 | 37 |
| provisional VISIBLE lag | 52.0 | 58.0 | 5 |
| PAINT lag | 8.0 | 160.0 | 37 |

This shows the intended separation in this run: MainActor acceptance stayed sub-millisecond in
the T9SEG samples while the slow engine result arrived asynchronously. It is an observed
diagnostic comparison, not a product SLO, release claim, or proof that all users/devices will
feel zero latency.

### B human report

- Input method: manual software keyboard, Universe Keyboard Chinese nine-key
- Missing keys: `no`
- Duplicate keys: `no`
- Candidate disappeared: `no`
- Keyboard exited: `no`
- Ordered completion: `reported complete`
- Stall score: **`0.5/4`**, raw Human rating retained without rounding
- Stall note: a very small perceptible pause remained; Human was unsure whether all stalls were gone

## A/B bounded observation

| Measure | A sync gate-off | B thread-affine diagnostic arm |
|---|---:|---:|
| Human integrity | all four `no` | all four `no` |
| Human stall score | `2/4` | `0.5/4` |
| Main/accept T9SEG total max | 181.8ms | 0.7ms |
| RIME/owner-observable max | RIME 180.4ms in the synchronous sample | engine VISIBLE lag 160.0ms; owner PUBLISH 39/39 |
| Runtime path | sync, dual gate 0/0 | thread-affine, dual gate 1/1, READY |

The direction is consistent with the hypothesis that off-main ownership removes the long
`process_key` call from the immediate key-accept path. The result remains bounded because the
canonical raw sequence is intentionally absent from logs, Full Access was not independently
observed, and provisional/presentation coalescing is visible.

## Ordinary-package restore

| Field | Value |
|---|---|
| Build | Release, same source snapshot; no `T9_*` compilation condition injected |
| App executable SHA-256 | `fde6743792f4441f58130ff689b255a547d21eb9b1e3b1d9b238a20f835654f1` |
| Keyboard executable SHA-256 | `612b4e0792ce4245ddb074c59148ec1a20c8ad10a1cee465fab3034db4c67845` |
| Install database sequence | `3768` |
| Install artifact | `/private/tmp/P2P02-CANONICAL-RESTORE-install.json` |
| Status | Installed; one-key Human smoke passed |

The restore package is ordinary and keeps the product path outside the A/B diagnostic gates.
No source, user settings, App Group logs, Reminders data, or device state was cleared.
