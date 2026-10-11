# Run Receipt — Direct real-RIME sidecar observability

## Receipt identity

| Field | Value |
|---|---|
| Run ID | `TC2-SIM-20260919-171730-SIDECAR-REVAL-01` |
| Captured at | `2026-09-19` / Asia/Shanghai; direct sidecar events observed `17:22:41–17:22:48` |
| Evidence grade | `Executor-recorded; pending independent Architecture and Quality review` |
| Run status | `Bounded sidecar observability evidence recorded` |
| Scope | Exact deployed `rime_ice` provenance plus content-free direct sidecar observability |
| Parent Assignment | [`TYPO-CORRECTION-002`](../assignments/typo-correction-002.md) |
| Continuation Assignment | [`TYPO-CORRECTION-002-PARENT-REVALIDATION-002`](../assignments/typo-correction-002-parent-revalidation-002.md) |
| Authorization | [`AUTH-TYPO-CORRECTION-002-SIDECAR-OBSERVABILITY-REVALIDATION-001`](../authorizations/AUTH-TYPO-CORRECTION-002-SIDECAR-OBSERVABILITY-REVALIDATION-001.md) |

This receipt records one bounded lane only. It does not close INT-003, QA-001, paired performance, a Product or Quality Gate, the parent Assignment, or any Release/merge decision.

## Execution identity

| Field | Bound value |
|---|---|
| Worktree | `/private/tmp/universe-keyboard-typo-correction-002-provenance-sidecar` |
| Branch | `codex/typo-correction-002-provenance-sidecar` |
| Worktree HEAD | `9eb83158e49218c1e8f75dbe7dd9e0390db81409` |
| `origin/main` context | `162b09fd58ba60538a944026b1902efa405c75aa`; no same-head claim |
| Tracked production/test diff SHA-256 | `c9225a435b833aa1c637c21bead8f85f1465d2b6d161c30a74b5789408c523be` |
| Untracked production/test content SHA-256 | `f0ad8759e22deedaa3d5424280c481b2625c550c29609cc70258e3590861ec9d` |
| Build/run method | XcodeBuildMCP `build_run_sim`; Debug package installed and launched |
| Derived-data output | `/tmp/universe-keyboard-typo-correction-002-parent-revalidation-002-derived/Build/Products/Debug-iphonesimulator/Universe Keyboard.app` |

### Package identity

| Artifact | SHA-256 |
|---|---|
| Main executable | `6b5dbc6230dda4ac30c6de62376f14279d82a370e88f59744087d7efb6072072` |
| Keyboard executable | `cff9029d5fe70ea5a77a51a60a9bc8788d33dacf2f859834a80c326a14df9190` |
| Main debug dylib | `b546385685794607950c0fce756dd0c1ec37e89f1cc96d89832f5a69ca90a1fa` |
| Keyboard debug dylib | `15900c7dedc80bd152181717c6d1ed45ea1c9876f08c7d9649ffdbb55722ef0d` |

## Device and human setup

- Simulator: iPhone 17 Pro Max / iOS 27.0.
- UDID: `06C5BC3E-7599-4761-A1A2-71DAEA991474`.
- Host: Messages, synthetic conversation `+1 (888) 555-1212`.
- Human setup: Universe Keyboard was selected, Full Access and the named high-fidelity diagnostics mode were enabled, and the pinyin sequence was entered through the visible Universe Keyboard keys.
- The draft was left unsent and paused after input. No host text was injected and no candidate was selected for this sidecar-only lane.
- No raw pinyin, candidate text, host text, pasteboard, `typeText`, `documentContext` or `setMarkedText` was retained or injected by the harness.

## Exact RIME provenance

The runtime provenance file was read from the designated Simulator App Group:

`AppGroup/97142D9B-ED12-4FFE-8C3A-58F175731B4F/Rime/user/rime-runtime-provenance.json`

| Field | Observed value |
|---|---|
| Provenance file SHA-256 | `b6c9a74a747b35997cc4dc67c651443b7dfd610f50fd290f9076760de7865c54` |
| Active schema | `rime_ice` |
| Artifact identity | `rime-ice-20260630-675d23b0` |
| Artifact version | `2026.06.30` |
| Archive SHA-256 | `675d23b070be00e1b800f9a6db033ef98f4493cd5b568ed8aa3b3541769c46ac` |
| Installed-content SHA-256 | `2e906d14853255cd0eba534e2b40791008c2cee65fa5a6e50b40bbd159cb6c26` |
| Provenance receipt ID | `078F7EA2-F9CA-4033-B7DD-48BE636BEB38` |
| Schema/source fields | `schemaVersion=1`, `schemeID=rime_ice`, `source=downloaded`, `sourceVariant=nju` |
| Upstream revision | `6810e8916d160498620a16fef2135956fecbd485` |
| Staged identity | `rime-ice-20260630-plan2-post2` |
| Staged content SHA-256 | `781f61ce95526bf117cc3316dde014b1ab8cd941be9ecbf0c975b2e7a9a57701` |
| Runtime fields | `librime=1.16.1`, `luaAvailable=true`, `luaRuntimeSmokePassed=true`, `runtimeSmokePassed=true` |
| Post-processing revision | `rime-ice-post-2` |

The Main-App runtime screen independently showed `输入方案 = 雾凇拼音` and `资源状态 = 已就绪`. A direct host-path inspection found the App Group and this provenance file. The parallel `xcrun simctl get_app_container` command lost its CoreSimulatorService connection; that tool limitation is retained and is not classified as App Group absence.

## Direct sidecar observability

The current extension diagnostics file contains 70 content-free direct sidecar records in the captured window. The records were summarized without retaining or exposing user text:

| Observation | Result |
|---|---|
| Event window | `2026-09-19T09:22:41Z–2026-09-19T09:22:48Z` (`17:22:41–17:22:48` local) |
| Unique diagnostic sequences | `70`; observed sequence range `59–352` |
| Route | `real_rime_sidecar` for all 70 records |
| Schema | `rime_ice` for all 70 records |
| Outcome | `returned` for all 70 records |
| Result bound | `resultCount=3` and `limit=3` for all 70 records |
| Elapsed bound | `1–6 ms` |
| Input bound | `inputLength=8–22`; raw input not retained |
| Provenance binding | All records carry receipt ID `078F7EA2-F9CA-4033-B7DD-48BE636BEB38` |
| Live-session validity | `liveSessionStable=true` for all 70 records |
| Live-session ID | `4671774424`, unchanged across the captured records |
| Sidecar-session ID | `4901230360`, unchanged across the captured records |

An earlier startup event at `2026-09-19T09:22:36Z` (`17:22:36` local, diagnostic sequence `6`) recorded `typo_correction.query_route` with route `unavailable` before the engine was ready. It is retained as a lifecycle limitation. The later 70 direct sidecar records are the completed capture window and are not silently merged with that startup state.

## Retained raw artifacts

Raw artifacts were copied additively to:

`/private/tmp/universe-keyboard-typo-correction-002-TC2-SIM-20260919-171730-SIDECAR-REVAL-01-raw`

| Artifact | Size | SHA-256 |
|---|---:|---|
| `diagnostics-control.json` | 41 bytes | `3a8307d8a06aaebf2b60c2051a9f9dfd2338e381a553d96b53483b68df960ed9` |
| `keyboard_extension.jsonl` | 130345 bytes | `7a9737a31bc5df8960eea5a175b632f40a16a97c65f8873a8e486d09c0fb456c` |
| `main_app.jsonl` | 2613 bytes | `847a9a8dd38d48b01274d3558a4ade62eb7b009252aca943ebb4992801854b84` |
| `rime-runtime-provenance.json` | 13099 bytes | `b6c9a74a747b35997cc4dc67c651443b7dfd610f50fd290f9076760de7865c54` |

The receipt records hashes and bounded summaries only; raw diagnostic lines are not copied into the repository or pasted into review text.

## Bounded interpretation

This lane provides a bounded positive observation for the provenance and direct sidecar-observability contract: the deployed schema/archive identity is readable, the later query records identify `real_rime_sidecar`, the result/outcome bounds are present, the provenance receipt is bound to those records, and the live session identity remains stable across the query window.

The initial `unavailable` route is an engine-startup lifecycle observation, not evidence that the later direct route failed. Independent Architecture review must decide whether this bounded evidence is sufficient for the sidecar lane; independent Quality review must consume the receipt without extending it into product behavior.

## Explicit non-claims

- No target candidate presence or selection was established.
- No INT-003 cadence or stale-work cancellation conclusion was established.
- No QA-001 candidate/interaction result was established.
- No paired baseline/treatment performance comparison was established.
- No Product, Quality, TestFlight, Release, merge or parent-Assignment conclusion was established.

## Handoff

The next authorized action is an independent Architecture review of this receipt, with special attention to the startup `unavailable` event, exact provenance binding and the content-free direct-route boundary. The INT-003, QA-001 and paired-performance Authorizations remain separate and unconsumed.
