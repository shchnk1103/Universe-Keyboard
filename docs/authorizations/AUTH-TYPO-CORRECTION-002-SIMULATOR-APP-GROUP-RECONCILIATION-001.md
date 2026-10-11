# Authorization: AUTH-TYPO-CORRECTION-002-SIMULATOR-APP-GROUP-RECONCILIATION-001

## Current Status

| Field | Value |
|---|---|
| **Status** | `consumed` |
| **Assignment** | [`TYPO-CORRECTION-002-PARENT-REVALIDATION-002`](../assignments/typo-correction-002-parent-revalidation-002.md) |
| **Issuer** | Human Product Owner / Product Lead, current Codex task, `2026-09-20 Asia/Shanghai` |
| **Consumer** | Current Codex Coordinator / Documentation Maintainer |
| **Purpose** | 对 Simulator App Group / signing 事实与既有错误解释做 docs-only 对账 |
| **Reconciliation ID** | `TC2-SIM-20260920-APPGROUP-RECON-01` |

## Bound snapshot

| Field | Value |
|---|---|
| Worktree | `/private/tmp/universe-keyboard-typo-correction-002-parent-revalidation-003` |
| Branch | `codex/typo-correction-002-parent-revalidation-003` |
| Current HEAD | `0d6638fabdc6b3db8164b881464a9f96f16c8dce` |
| Current tree | `69b2302b3e154458e6446b56c24886ee2d7e2925` |
| Code/source snapshot used by the package | `3f9f2652b03279a99537639f4382b48bb58548ca`; later commits in this worktree are docs-only |
| Target | iPhone 17 Pro Max / iOS 27.0 Simulator / `06C5BC3E-7599-4761-A1A2-71DAEA991474` |
| Scheme / configuration | `Universe Keyboard` / `Debug` |
| Package profile | Simulator signing enabled; DerivedData `/private/tmp/universe-keyboard-typo-correction-002-parent-revalidation-003-signed-app-derived` |

## Allowed actions

- Read the project entitlement sources, build log, Simulator-specific `.xcent`, Mach-O entitlement sections, runtime log and current app UI snapshot.
- Write one docs-only reconciliation evidence receipt that distinguishes the earlier unsigned package from the current Simulator package.
- Add a short supersession note to the earlier signed-rebuild Authorization without deleting or rewriting its historical record.
- Add a bounded amendment/link to the parent Assignment and its `ACTIVE_WORK.md` mirror.
- Mark this Authorization consumed only after the evidence and links are internally consistent.

## Explicit exclusions

- No Swift, Objective-C, test, Xcode project, entitlement source, bundle identifier or signing-setting changes.
- No build, reinstall, schema change, RIME deployment retry, Simulator/device capture or new product Run ID.
- No manual UI action, QA-001, INT-003, paired performance, 180 ms conclusion or sidecar conclusion.
- No commit, push, pull request, merge, TestFlight, Release, Product/Quality Gate or Assignment closure.
- No conclusion about a physical-device Apple Development certificate or provisioning state.

## Exit conditions

- The record states that the first `CODE_SIGNING_ALLOWED=NO` package lacked the Simulator entitlement section.
- The current Simulator package is shown to contain the App Group in both App and Keyboard Mach-O entitlement sections, and its runtime log reaches the shared App Group RIME path.
- The misleading `networkError("App Group 不可用")` presentation path is linked to its source code without claiming a network failure.
- `rime_ice` deployment remains explicitly `not-run`; the next action is a separate fresh deployment-smoke Authorization and Run ID.

## Consumption receipt

- Evidence: [`Simulator App Group/signing reconciliation`](../evidence/typo-correction-002-simulator-app-group-signing-reconciliation-2026-09-20.md)
- Consumed: `2026-09-20T20:36:00+08:00`
- Result: Corrected the Simulator entitlement interpretation, linked the actual runtime App Group proof, and preserved the prior unsigned-package failure as historical evidence.
- Non-claims: no new build, install, deployment, device capture, QA result, Gate or closure.
