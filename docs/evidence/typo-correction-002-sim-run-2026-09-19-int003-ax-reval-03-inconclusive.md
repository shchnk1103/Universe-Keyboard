# TYPO-CORRECTION-002 Simulator Run Receipt — INT-003 AX retry 03

> **Run ID:** `TC2-SIM-20260919-181538-INT003-AX-REVAL-03`
>
> **Status:** `inconclusive — AX actions reached the keyboard, but the observed cadence did not meet <180 ms`
>
> **Evidence grade:** `Executor-recorded`

## Authority and identity

- Parent Assignment: [`TYPO-CORRECTION-002-PARENT-REVALIDATION-002`](../assignments/typo-correction-002-parent-revalidation-002.md)
- Bounded Authorization: [`AUTH-TYPO-CORRECTION-002-INT003-AX-HARNESS-REVALIDATION-003`](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-AX-HARNESS-REVALIDATION-003.md)
- Predecessor compile block: [`INT-003 AX retry 02 — compile blocked`](typo-correction-002-sim-run-2026-09-19-int003-ax-reval-02-compile-blocked.md)
- Worktree: `/private/tmp/universe-keyboard-typo-correction-002-provenance-sidecar`
- Branch: `codex/typo-correction-002-provenance-sidecar`
- Parent HEAD: `9eb83158e49218c1e8f75dbe7dd9e0390db81409`
- Testability production input: merged PR #140 at `162b09fd58ba60538a944026b1902efa405c75aa`
- Corrected tracked source/test diff SHA-256: `60b1e543154bc75dd2c03788fd6e0f37e6a02e98b1648f41913ea6c7abab36ce`
- Simulator: iPhone 17 Pro Max / iOS 27.0, UDID `06C5BC3E-7599-4761-A1A2-71DAEA991474`
- Host: Messages, conversation `+1 (888) 555-1212`
- Configuration: Debug, signed Simulator package
- Derived data: `/private/tmp/universe-keyboard-typo-correction-002-int003-ax-retry-03-derived`

## Build and harness result

- `build_run_sim`: succeeded in `41.9 s`; app installed and launched.
- Runtime UI snapshot after launch: input scheme `雾凇拼音`; resource status `已就绪`.
- Selected test: `UniverseKeyboardUITests/NativeExperienceKeyboardAutomationFeasibilityTests/testTypoCorrectionINT003ControlledAXCadence`
- XCTest result: `1 passed / 0 failed / 0 skipped`; selected test duration `66.555 s`.
- Harness activation and independent key-target preflight passed. The test invoked
  the existing AX element `tap()` action path for 22 fixed synthetic key
  elements. It did not use `typeText`, pasteboard, host text injection,
  `documentContext` or `setMarkedText`.
- The fixed fixture is not reproduced here; no raw input, candidate or host
  text is stored in this receipt.

## Package and RIME provenance

| Artifact | SHA-256 |
|---|---|
| Main executable | `d7f625a10f009d842164dfce6cba41748741bc185a3b8c66b035e8cca392d200` |
| Keyboard executable | `41982c94650ed22da45f82d37a009c340b7d7fdc82dbe550de40e130e0a21208` |
| Main debug dylib | `21366fa4ea81b15e99cea9def49b6b5100be205b89850546216fe603de670719` |
| Keyboard debug dylib | `665ae64a4d67ed1e42809a0dc6c9a613547d1342bd6e93e1ce18a99e65970e27` |
| Provenance file | `b6c9a74a747b35997cc4dc67c651443b7dfd610f50fd290f9076760de7865c54` |

The installed App Group provenance identifies:

| Field | Observed value |
|---|---|
| Active schema | `rime_ice` |
| Artifact identity | `rime-ice-20260630-675d23b0` |
| Artifact version | `2026.06.30` |
| Source / variant | `downloaded` / `nju` |
| Upstream revision | `6810e8916d160498620a16fef2135956fecbd485` |
| Archive SHA-256 | `675d23b070be00e1b800f9a6db033ef98f4493cd5b568ed8aa3b3541769c46ac` |
| Installed content SHA-256 | `2e906d14853255cd0eba534e2b40791008c2cee65fa5a6e50b40bbd159cb6c26` |
| Provenance receipt ID | `078F7EA2-F9CA-4033-B7DD-48BE636BEB38` |
| librime | `1.16.1` |
| Runtime / Lua smoke | `true` / `true` |

## Observed cadence

The harness requested an 80 ms inter-tap sleep and a 350 ms post-burst pause,
but the diagnostic journal is authoritative for actual delivery timing. It
recorded 22 key events using the `key_highlighted=true` terminal marker, with
21 adjacent intervals:

| Measure | Observed value |
|---|---:|
| Key events | 22 |
| Adjacent intervals | 21 |
| Minimum interval | `526.617583 ms` |
| Maximum interval | `880.752 ms` |
| Intervals below 180 ms | `0 / 21` |
| Intervals at or above 180 ms | `21 / 21` |
| Key-event window | `2026-09-19T10:22:30Z`–`2026-09-19T10:22:41Z` |

The `XCUIElement.tap()` calls therefore reached the product keyboard but did
not produce the required rapid stimulus. The planned sleep is not substituted
for the observed cadence.

## Diagnostic observations

- `rime.owner.published`: 22 records, revisions 1–22.
- `ui.applied`: 22 records, revisions 1–22.
- `typo_correction.sidecar_query`: 70 records from
  `2026-09-19T10:22:34Z` through `2026-09-19T10:22:42Z`.
- Every sidecar record reports `route=real_rime_sidecar`,
  `outcome=returned`, `schemaID=rime_ice`, `resultCount=3`, `limit=3`, and
  the bound provenance receipt ID.
- Sidecar elapsed time is `1–6 ms`; input-length markers cover `8–22`.
- Live session ID is stable before/after (`4424897240`) and valid on both
  sides; sidecar session ID is stable before/after (`4615727448`) and remains
  separate from the live session.
- One `typo_correction.query_route` record reports `route=unavailable` at
  local sequence 6 (`2026-09-19T10:22:02Z`), before the key-event window. It
  is retained as a startup/lifecycle observation and is not merged into the
  70 completed sidecar queries.
- The journal has no explicit stale-work cancellation marker. Because no
  adjacent interval was below 180 ms, the revision sequence is not evidence
  that rapid stale work was cancelled.

## Claim outcomes

| Claim | Outcome | Boundary |
|---|---|---|
| AX harness can select Universe Keyboard and reach independent key actions | `pass for harness sub-claim` | XCTest passed; 22 key events observed |
| Actual stimulus satisfies the INT-003 `<180 ms` condition | `not met` | 0/21 intervals below 180 ms |
| INT-003 stale-work cancellation | `inconclusive; not a formal pass` | No qualifying rapid stimulus and no explicit cancellation marker |
| Direct real-RIME sidecar observability | `bounded pass for this sub-claim` | 70 receipt-bound real-sidecar records |
| QA-001 target candidate visibility/selection | `not-run / not claimed` | No candidate or host text is persisted here |
| Paired performance | `not-run / not claimed` | Not a paired comparison |

## Preserved artifacts

Raw content-free artifacts are retained outside Git:

`/private/tmp/typo-correction-002-sim-runs/TC2-SIM-20260919-181538-INT003-AX-REVAL-03/raw/`

| File | SHA-256 |
|---|---|
| `keyboard_extension.jsonl` | `d57b6bbd4dec610860a96195a3174f798f80a584c6e4e15fa2c375930c414f11` |
| `main_app.jsonl` | `4d827a30554a3daeb01a81e0e6d30f32b9a57ccc42538c0724f660f3646dfe14` |
| `rime-runtime-provenance.json` | `b6c9a74a747b35997cc4dc67c651443b7dfd610f50fd290f9076760de7865c54` |

XCTest artifacts:

- Result bundle: `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-09-19T10-21-07-574Z_pid25092_751d502a.xcresult`
- Test log: `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/logs/test_sim_2026-09-19T10-21-07-574Z_pid25092_cc87f80c.log`

## Non-claims and next method

- This receipt does not close `TC2-CASE-INT-003`, `TC2-CASE-QA-001` or the
  paired-performance case.
- It does not establish a Product, Quality, TestFlight, Release, merge or
  Assignment decision.
- `XCUIElement.tap()` is proven usable for AX reachability, but its observed
  delivery cadence is too slow for the 180 ms contract in this environment.
- A future retry, if authorized, needs a lower-overhead method that still
  emits real touch events to the visible keyboard key controls; it must record
  actual diagnostic timestamps and must not use host-text injection,
  pasteboard or synthetic RIME fixtures. That future method receives a new
  Authorization and Run ID.
