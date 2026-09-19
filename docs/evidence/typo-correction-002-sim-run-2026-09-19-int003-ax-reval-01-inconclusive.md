# Run Receipt — INT-003 AX-harness attempt 01 (inconclusive)

## Receipt identity

| Field | Value |
|---|---|
| Run ID | `TC2-SIM-20260919-175102-INT003-AX-REVAL-01` |
| Status | `Inconclusive / invalid for INT-003; retry requires a new Run ID` |
| Evidence grade | `Executor-recorded failure-boundary receipt` |
| Authorization | [`AUTH-TYPO-CORRECTION-002-INT003-AX-HARNESS-REVALIDATION-001`](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-AX-HARNESS-REVALIDATION-001.md) |
| Assignment | [`TYPO-CORRECTION-002-PARENT-REVALIDATION-002`](../assignments/typo-correction-002-parent-revalidation-002.md) |
| Target | iPhone 17 Pro Max / iOS 27.0 Simulator, UDID `06C5BC3E-7599-4761-A1A2-71DAEA991474` |
| Host | Messages, `+1 (888) 555-1212` |

This receipt preserves the failed attempt and does not claim an INT-003 result. It does not alter the sidecar bounded Pass or close any parent Gate.

## Bound build identity

- Combined parent implementation plus PR #140 AX production changes; no new product logic was authored for this attempt.
- DerivedData: `/tmp/universe-keyboard-typo-correction-002-int003-ax-derived/Build/Products/Debug-iphonesimulator/Universe Keyboard.app`.
- Main executable SHA-256: `903328dbef69e1adba5be240a856f7279f8771bfb1ef945f33fcb4ca6d6423fc`.
- Keyboard executable SHA-256: `5a45906aafc3c8ee42db7cc256c225671abc62d1c27892c07a15ccb5149df6e5`.
- Main debug dylib SHA-256: `113338d1d867ba33fab319a303599746d5513342002f7aa9b378773d1ed8280f`.
- Keyboard debug dylib SHA-256: `07210559b724548f00d8ebcfcdc2fdbcdb18c9e7f6a445d9a0573e87b0be110c`.
- Combined tracked source/test diff SHA-256: `7df4fe1a6bed9c4d8600fa4ccd6bbe96adf85705ce7aa46b3b0ea847c84d319d`.
- Runtime provenance SHA-256: `b6c9a74a747b35997cc4dc67c651443b7dfd610f50fd290f9076760de7865c54`.

## What was verified before the attempt

- The AX tree showed the keyboard switcher label `Universe Keyboard`.
- Independent `q`, `w` and `e` key targets were visible and hittable.
- No host text API, `typeText`, pasteboard, `documentContext` or `setMarkedText` was used.

## Failure boundary

An external XcodeBuildMCP batch sent 22 real AX tap actions with a planned 80 ms post-delay and a final 400 ms delay. One key mapping in the executor action list was incorrect: the position intended for `q` referenced the visible `a` key. The resulting composition therefore did not match the authorized synthetic sequence and cannot be used for INT-003 semantics.

The post-batch AX snapshot also exposed `English (Australia)` as the active next-keyboard value rather than the previously verified `Universe Keyboard` identity. This means the completed action set cannot be treated as a stable Universe Keyboard capture, even though the batch tool reported all 22 UI actions as delivered.

The attempt therefore does not establish the 180 ms cadence, stale-work cancellation, or a valid Universe Keyboard-only timeline. It is not a product failure claim.

## Content-free diagnostic summary

The retained extension artifact contained 219 JSONL records from `2026-09-19T10:01:22Z–10:02:06Z`:

| Event code | Count | Sequence range |
|---|---:|---:|
| `candidate.visibility_changed` | 59 | 2–219 |
| `touch.terminal` | 44 | 7–207 |
| `rime.owner.published` | 22 | 9–208 |
| `ui.applied` | 22 | 10–209 |
| `typo_correction.sidecar_query` | 70 | 50–218 |
| `typo_correction.query_route` | 1 | 6–6 |
| `presentation.appeared` | 1 | 1–1 |

The counts demonstrate activity but do not prove the intended stimulus identity or cadence. Raw input and candidate text are not reproduced here.

## Retained raw artifacts

Raw artifacts were copied additively to:

`/private/tmp/universe-keyboard-typo-correction-002-TC2-SIM-20260919-175102-INT003-AX-REVAL-01-inconclusive-raw`

| Artifact | Size | SHA-256 |
|---|---:|---|
| `keyboard_extension.jsonl` | 130938 bytes | `c92850dfb3c4274f07288e32a965f5a5b9c77ac0828195bba16e38ff93f79810` |
| `main_app.jsonl` | 1742 bytes | `21cb01b5aac91c882b1c5d224f87bf908cfd21e4cd4bb67d277d3030a97704be` |
| `rime-runtime-provenance.json` | 13099 bytes | `b6c9a74a747b35997cc4dc67c651443b7dfd610f50fd290f9076760de7865c54` |

## Disposition

- This Run is retained as an explicit inconclusive/invalid attempt.
- The consumed Authorization must not be reused for a retry.
- A new Authorization and new Run ID are required before the XCTest-internal AX cadence harness is run.
- INT-003, QA-001, paired performance, Product, Quality, Release and parent closure remain open.
