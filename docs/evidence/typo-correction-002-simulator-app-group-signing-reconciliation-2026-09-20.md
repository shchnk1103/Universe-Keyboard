# Evidence: Simulator App Group/signing reconciliation

> **Status:** Completed — docs-only reconciliation
>
> **Recorded:** `2026-09-20 Asia/Shanghai`
>
> **Evidence grade:** `Executor-recorded`
>
> **Important boundary:** This receipt corrects the interpretation of an
> existing Simulator package. It does not create a new Simulator Run, retry
> RIME Ice deployment, or establish any QA/Product/Quality/Release Gate.

## Identity

| Field | Value |
|---|---|
| Parent Assignment | [`TYPO-CORRECTION-002-PARENT-REVALIDATION-002`](../assignments/typo-correction-002-parent-revalidation-002.md) |
| Reconciliation Authorization | [`AUTH-TYPO-CORRECTION-002-SIMULATOR-APP-GROUP-RECONCILIATION-001`](../authorizations/AUTH-TYPO-CORRECTION-002-SIMULATOR-APP-GROUP-RECONCILIATION-001.md) |
| Reconciliation ID | `TC2-SIM-20260920-APPGROUP-RECON-01` |
| Worktree | `/private/tmp/universe-keyboard-typo-correction-002-parent-revalidation-003` |
| Branch | `codex/typo-correction-002-parent-revalidation-003` |
| Documentation HEAD at reconciliation | `0d6638fabdc6b3db8164b881464a9f96f16c8dce` |
| Documentation HEAD tree | `69b2302b3e154458e6446b56c24886ee2d7e2925` |
| Code/source snapshot used by the package | `3f9f2652b03279a99537639f4382b48bb58548ca` |
| Target | iPhone 17 Pro Max / iOS 27.0 Simulator / `06C5BC3E-7599-4761-A1A2-71DAEA991474` |
| Build | `Universe Keyboard` / Debug / iOS Simulator |
| Build log | `/Users/doubleshy0n/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/logs/build_run_sim_2026-09-20T12-08-08-987Z_pid16549_370a3513.log` |

The commits after the package's code snapshot added only the two prior
Authorization documents; no Swift, test, Xcode project or entitlement source
changed between `3f9f265` and the reconciliation HEAD.

## Claim outcomes

| Claim | Outcome | Evidence grade | Conflict / supersession |
|---|---|---|---|
| Both target entitlement source files name `group.com.DoubleShy0N.Universe-Keyboard` | `pass` | `Executor-recorded` | None known |
| The earlier `CODE_SIGNING_ALLOWED=NO` Simulator package lacked the Simulator entitlement section | `pass` | `Executor-recorded` | Superseded as the package used for QA; it remains invalid for evidence |
| The current Simulator package carries the App Group in the App and Keyboard Mach-O entitlement sections | `pass` | `Executor-recorded` | The normal `codesign` view is not a contrary Simulator result |
| The current App process reached the shared App Group RIME path | `pass` | `Executor-recorded` | Base runtime only; not RIME Ice deployment |
| `rime_ice` download/deployment and QA-001 input | `not-run` | `Executor-recorded` | Requires a fresh bounded Authorization and Run ID |

## What the source and package prove

### 1. Xcode project configuration is present

The following source files both contain the same App Group entitlement:

- `Universe Keyboard/Universe Keyboard.entitlements`
- `Keyboard/Keyboard.entitlements`

The build command used `CODE_SIGNING_ALLOWED=YES`,
`CODE_SIGN_STYLE=Automatic`, `DEVELOPMENT_TEAM=C33N6HTS9N`, and the correct
Simulator destination. Xcode generated both
`Universe Keyboard.app-Simulated.xcent` and `Keyboard.appex-Simulated.xcent`.

### 2. The first package was the wrong package for an App Group run

The earlier package was built with `CODE_SIGNING_ALLOWED=NO`:

| Item | Earlier unsigned package |
|---|---|
| App bundle identifier reported by `codesign` | `Universe Keyboard` |
| App executable SHA-256 | `3e807c29582855c41371e0cc02bfdee410b5c208d69c1e8e231c1ab7587c50d3` |
| Keyboard executable SHA-256 | `4565494c631c84b252c474d648635562bb0e439969cd7a03cded86d17cdea75b` |
| Mach-O `__TEXT,__entitlements` | Absent |
| Use for QA/RIME evidence | Prohibited; superseded |

That package could not establish the shared-container boundary. Its failure is
therefore consistent with `FileManager.containerURL(forSecurityApplicationGroupIdentifier:)`
returning `nil`.

### 3. The current Simulator package does contain the entitlement

The current package reported `com.DoubleShy0N.Universe-Keyboard` as its bundle
identifier. The normal local Simulator signature still reports
`Signature=adhoc`, `TeamIdentifier=not set`, and an empty normal
`codesign --entitlements` dictionary. That output is not the complete
Simulator entitlement view.

The Simulator-specific Mach-O sections were read directly:

```text
App:
  application-identifier = C33N6HTS9N.com.DoubleShy0N.Universe-Keyboard
  com.apple.security.application-groups = group.com.DoubleShy0N.Universe-Keyboard

Keyboard Extension:
  application-identifier = C33N6HTS9N.com.DoubleShy0N.Universe-Keyboard.Keyboard
  com.apple.security.application-groups = group.com.DoubleShy0N.Universe-Keyboard
```

The current package executable SHA-256 values are:

| Item | Current Simulator package |
|---|---|
| App executable | `9f1c360daccd157144830fdcc92b9f4a02dd32ed9aa84e9c7ecab503b8d3af04` |
| App debug dylib | `0b7983d92d44671111554795c1f4cbb840deb5e9e6d4b6db6bbfb9e17dcc6778` |
| Keyboard executable | `2bfd0a0a00da2d0e014054ce32bd70fd6ea61f7d4388825dcbe6e368dd46a353` |
| Keyboard debug dylib | `92f148f18d6bf0c2268af44326199afd397fc733d8a9a3bba396ad03d3f2a028` |
| App `*.app-Simulated.xcent` | `6610a8c02dfe5b877f5be595941b807a687c7838e2f4b54a80b4c6726b821a6c` |
| Keyboard `*.appex-Simulated.xcent` | `1b5eca79f033b12423739696ae50c8dfcd679ed6484803e2e340787aee149b7b` |

### 4. The current runtime reached the App Group path

The runtime log from the current signed Simulator package contains RIME file
loads below the Simulator shared App Group container, including:

- `Rime/user/build/default.yaml`
- `Rime/user/user.yaml`
- `Rime/user/build/luna_pinyin.schema.yaml`
- `Rime/shared/build/luna_pinyin.table.bin`

The current main-app UI snapshot simultaneously showed `资源状态 = 已就绪`
and `输入方案 = 朙月拼音`. This proves the App Group-backed built-in Luna
runtime was reachable. It does **not** prove that `rime_ice` was downloaded,
deployed, selected, or usable for the next QA capture.

## Why the UI said “网络错误：App Group 不可用”

There are two local error paths, neither is a network diagnosis:

1. [`RimeConfigManager+DeploymentResources.swift`](../../Packages/RimeBridge/Sources/RimeBridge/RimeConfigManager+DeploymentResources.swift) calls `containerURL(forSecurityApplicationGroupIdentifier:)` and throws when it returns `nil`.
2. [`SchemaArchiveInstaller.swift`](../../Universe%20Keyboard/Services/SchemaArchiveInstaller.swift) converts a missing container into `DownloadError.networkError("App Group 不可用")`.
3. [`SchemaManagerTypes.swift`](../../Universe%20Keyboard/Services/SchemaManagerTypes.swift) formats every `networkError` as `网络错误：…`.

Therefore the earlier message was a misleading presentation of a local
entitlement/container failure in the unsigned package. It was not evidence of
a failed mirror request or a bad download URL.

## Remaining residuals and next boundary

- `rime_ice` deployment is still `not-run` on the current package; no new Run
  ID was created by this reconciliation.
- `security find-identity` still reports no local Apple Development identity.
  That remains relevant to a physical-device build, but it is not a blocker
  for the Simulator-specific entitlement proof above.
- The earlier shell `simctl get_app_container` failure is retained as a
  CoreSimulatorService/tool-observation limitation; it is not classified as
  App Group absence because the app's own runtime reached the container.
- The old signed-rebuild Authorization remains non-reusable. Its original
  interpretation of the normal `codesign` output is superseded by this
  receipt; its historical stop record is retained.

The next legal action is a new bounded RIME Ice deployment-smoke Authorization
with a fresh Run ID. That action will pause for the human operator to retry the
雾凇 deployment in the current main app and will collect the app-owned runtime
diagnostics before any QA-001 capture is considered.

## Explicit non-claims

This receipt is not INT-003, QA-001, paired performance, sidecar
observability, Product/Quality/Release approval, commit, push, PR, merge,
TestFlight, Release or parent/child closure.
