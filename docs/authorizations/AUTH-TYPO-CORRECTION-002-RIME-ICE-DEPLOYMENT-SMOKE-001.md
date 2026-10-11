# Authorization: AUTH-TYPO-CORRECTION-002-RIME-ICE-DEPLOYMENT-SMOKE-001

## Current Status

| Field | Value |
|---|---|
| **Status** | `consumed` |
| **Assignment** | [`TYPO-CORRECTION-002-PARENT-REVALIDATION-002`](../assignments/typo-correction-002-parent-revalidation-002.md) |
| **Issuer** | Human Product Owner / Product Lead, current Codex task, `2026-09-20 Asia/Shanghai` |
| **Consumer** | Current Codex Coordinator / Environment Executor with Human Product Owner as Device Operator |
| **Purpose** | 在当前已安装 Simulator 包上进行一次受控的 `rime_ice` 雾凇部署 smoke |
| **Run ID** | `TC2-SIM-20260920-RIME-ICE-SMOKE-01` |
| **Precondition receipt** | [`Simulator App Group/signing reconciliation`](../evidence/typo-correction-002-simulator-app-group-signing-reconciliation-2026-09-20.md) |

## Exact execution identity

| Field | Value |
|---|---|
| Worktree | `/private/tmp/universe-keyboard-typo-correction-002-parent-revalidation-003` |
| Branch | `codex/typo-correction-002-parent-revalidation-003` |
| Code/source snapshot | `3f9f2652b03279a99537639f4382b48bb58548ca` |
| Installed package | `/private/tmp/universe-keyboard-typo-correction-002-parent-revalidation-003-signed-app-derived/Build/Products/Debug-iphonesimulator/Universe Keyboard.app` |
| App executable SHA-256 | `9f1c360daccd157144830fdcc92b9f4a02dd32ed9aa84e9c7ecab503b8d3af04` |
| Keyboard executable SHA-256 | `2bfd0a0a00da2d0e014054ce32bd70fd6ea61f7d4388825dcbe6e368dd46a353` |
| Bundle IDs | `com.DoubleShy0N.Universe-Keyboard` / `com.DoubleShy0N.Universe-Keyboard.Keyboard` |
| Target | iPhone 17 Pro Max / iOS 27.0 Simulator / `06C5BC3E-7599-4761-A1A2-71DAEA991474` |
| Host for later QA | Messages / `+1 (888) 555-1212` — **not used in this smoke** |
| RIME target | `rime_ice` / artifact `rime-ice-20260630-675d23b0` / upstream `6810e8916d160498620a16fef2135956fecbd485` |
| Expected archive SHA-256 | `675d23b070be00e1b800f9a6db033ef98f4493cd5b568ed8aa3b3541769c46ac` |
| Expected installed-content SHA-256 | Must be read again after this smoke; prior value is not reused as current proof |

No rebuild or reinstall is permitted under this Authorization. Any package,
source, Simulator, schema, device or process-identity change stops this smoke
and requires a new Run ID and Authorization.

## Allowed actions

- Human operator may use the current main-app UI to select the pinned 雾凇/
  `rime_ice` scheme and press its download/deploy/retry control once.
- The app may perform its already-authorized pinned-source download, archive
  verification, extraction and Main-App-owned RIME deployment.
- The Coordinator may read the app-owned diagnostic journal, deployment
  phases, App Group provenance and post-operation settings without reading raw
  user input or candidate text.
- The Coordinator may record one smoke evidence receipt and consume this
  Authorization after the result and non-claims are complete.

## Human procedure and pause point

Before any click, the Coordinator must confirm that the current installed app
still matches the exact package identity above. Then the Human Product Owner
should:

1. In the open Universe Keyboard main app, tap the current **输入方案** row
   (currently showing `朙月拼音`).
2. Select **雾凇拼音 / 雾凇** (`rime_ice`). If the row already shows a retry
   action, use that single retry instead.
3. Wait for the operation to finish and report the exact final UI message or
   visible state. Do not open Messages, switch keyboards, type text or select
   any candidate in this smoke.

After the first deployment result, stop. A repeated click is not permitted
without a new Authorization.

## Pass and stop conditions

The smoke can be recorded as a bounded setup pass only if the app reports a
successful deployment and the fresh app-owned evidence binds `rime_ice`, the
expected archive identity, installed-content identity, the current App Group
and a successful deployment terminal phase. This is not QA-001 evidence.

Stop as `inconclusive` if the UI result is missing, the diagnostic window is
not fresh, the App Group or package identity cannot be read, the expected
archive/content identity differs, or the operation reaches a deployment error.
If the same “网络错误：App Group 不可用” message appears again, record it as a
fresh runtime observation; do not infer that the Xcode project lacks the group
and do not retry repeatedly.

## Explicit exclusions

- No Messages input, manual typing, candidate selection, QA-001, INT-003,
  paired performance or 180 ms measurement.
- No sidecar observability conclusion; this smoke only establishes deployment
  preconditions for a later separately authorized lane.
- No source, test, entitlement, signing-setting, schema or vendor changes.
- No commit, push, pull request, merge, TestFlight, Release, Product/Quality
  Gate or Assignment closure.

## Consumption receipt

- Evidence: [`RIME Ice deployment smoke receipt`](../evidence/typo-correction-002-sim-run-2026-09-20-rime-ice-deployment-smoke-01.md)
- Consumed: `2026-09-20T20:51:34+08:00`
- Result: bounded pass for the RIME deployment precondition. The UI showed
  雾凇 as current and deployed; the fresh runtime receipt, App Group
  preferences and deployment terminal log agree on `rime_ice`, the pinned
  artifact identity, successful deployment and matching installed-content
  digest.
- Independent digest check: 70/70 admitted files present, zero per-file
  mismatches, recomputed content SHA matched the receipt.
- Remaining detail: the pinned archive SHA is carried by the fresh runtime
  receipt, but this smoke did not separately export and re-hash the downloaded
  archive file.
- Non-claims: no Messages input, sidecar conclusion, INT-003, QA-001,
  paired-performance, Product/Quality/Release Gate or Assignment closure.
- No new QA or performance Run may reuse this Run ID.
