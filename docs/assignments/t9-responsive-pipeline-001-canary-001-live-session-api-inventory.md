# Static Live-Session API Inventory: CANARY-001

Status: **Implementation diff statically revalidated — build/runtime revalidation remains required for E-Ready**

Collected: 2026-08-03 Asia/Shanghai

Owner: Task-level RIME Platform Executor `/root`; initial independent read-only
inventory by `/root/canary_api_audit`

Parent Assignment:
[`CANARY-001`](t9-responsive-pipeline-001-production-shaped-canary-001.md)

## Snapshot metadata

| Field | Value |
|---|---|
| Source HEAD | `3585a540ba8389673acd49128d87040ac9619f27` |
| Working tree | Dirty; 23 changed/untracked entries under `Keyboard`, `Packages/KeyboardCore`, `Packages/RimeBridge` |
| Relevant tracked-diff SHA-256 | `82a9cce83577e566e2412d2f2f313c18208a3c1c5134f39cfd5832c2c5ba3134` |
| Relevant untracked-name SHA-256 | `b59bf8ebfdb1b32316669e25f465d189db9c5cb02137de376fbfb50aaf7c39d2` |
| Method | `rg` discovery plus direct source inspection; no build, test, Simulator or device run |
| Device / OS | Not Applicable — static source inventory only |
| Evidence location | This document; file/line references below |
| Expiry | Any relevant source diff, RimeEngine API, gate/lifecycle design, ADR 0004/0025 or CANARY-001 phase change |

Line numbers describe this working-tree snapshot, not clean `HEAD`. This inventory
is discovery evidence, not proof that a path is safe or exhaustive.

## Baseline and canary owner shapes observed

- `KeyboardController` is MainActor-isolated:
  `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController.swift:3`.
- The visible Extension baseline creates `RimeEngineImpl` through
  `Keyboard/Controllers/KeyboardViewController+Bootstrap.swift:227-240`.
- `RimeEngineImpl` enters `RimeSessionManager/librime` at
  `Packages/RimeBridge/Sources/RimeBridge/RimeEngineImpl.swift:89-123`.
- The thread-affine owner keeps its engine local to the owner loop and executes
  its work enum there:
  `Packages/KeyboardCore/Sources/KeyboardCore/ThreadAffineRimeSpike.swift:537-655`.
- The real bootstrap creates the engine on the owner thread from config-only
  data:
  `Packages/RimeBridge/Sources/RimeBridge/ThreadAffineRimeEngineImplBootstrap.swift:30-37`.

These observations support the proposed owner shape. They do not prove safe
switching, complete API coverage or positive owner destruction.

## Protocol surface requiring classification

The `RimeEngine` protocol surface at
`Packages/KeyboardCore/Sources/KeyboardCore/RimeEngine.swift:9-75` includes:

- `processKey`
- local/global candidate selection and `candidateWindow`
- `deleteBackward`, `replaceInput`
- `resetSession`, `recoverSession`
- `suspendForVisibilityChange`, `resumeAfterVisibilityChange`
- `runtimeSelection`, `diagnosticSessionSnapshot`, runtime-selection callback
- `isComposing`, `pageUp`, `pageDown`

Every live implementation or façade path is `same-owner` or `fail-closed` in a
future canary. Protocol membership alone is not proof that all native bridge
entry points are covered.

## Controller call families

| Family | Current call locations | Required canary disposition |
|---|---|---|
| process/recovery | `KeyboardController+RimeRecovery.swift:39-178,421-455` | `same-owner` |
| Delete/fallback restore | `KeyboardController+TextEditing.swift:49-94,193-236,371-462` | `same-owner`; host delete remains MainActor only after composition authority clears |
| candidate select/page/reset | `KeyboardController+Candidates.swift:25-133,201` | ordered `same-owner`; invalid request is refused before owner mutation |
| T9 Path/cycle/replace | `KeyboardController+T9PinyinPath.swift:235,1191-2131` | mutation is ordered `same-owner`; derived reads consume immutable owner-published snapshots |
| Partial Commit/rebuild | `KeyboardController+PartialCommit.swift:274,446,804-1181` | `same-owner`; host effects MainActor after validated result |
| reversible auto-anchor | `KeyboardController+T9ReversibleAutoAnchor.swift:107-399` | suppressed/fail-closed in canary v1 before live-session access; focused contract test required |
| visibility/process lifecycle | `KeyboardController.swift:810-886`; invoked from `KeyboardViewController.swift:324-356` | coordinator control + positive owner/session terminal |

The controller surface must be treated as one closure. Moving only
`processKey` is insufficient.

The unique protocol-entry classification for canary v1 is:

| `RimeEngine` entry | Frozen disposition |
|---|---|
| `processKey` | ordered `same-owner`; implicit recreation remains owner-local and emits a new session-instance receipt |
| local/global `selectCandidate` | ordered `same-owner` |
| `candidateWindow` | immutable owner-published snapshot only; no live bridge call |
| `deleteBackward`, `replaceInput` | ordered `same-owner` |
| `resetSession`, `recoverSession` | ordered `same-owner` lifecycle work |
| `suspendForVisibilityChange`, `resumeAfterVisibilityChange` | coordinator command executed by the same owner |
| `runtimeSelection`, `diagnosticSessionSnapshot`, `isComposing` | immutable owner-published snapshot only |
| `onRuntimeSelectionChanged` | immutable callback value only; direct/indirect live-session access is prohibited |
| `pageUp`, `pageDown` | ordered `same-owner` |

The ObjC public `highlightCandidateOnCurrentPage`, `currentOutput` and
`commitComposition` entries are uniquely `fail-closed` for canary v1: they are
not exposed by the canary façade, direct Extension calls are rejected by static
scan/focused tests, and any internal-artifact invocation must stop before live
session access. Deployment/file/userdb APIs remain Main-App-only and unavailable
to the Extension canary.

## Must-resolve findings

### API-P1-01 — stop abandons accepted backlog without per-revision terminal

`ThreadAffineRimeSpike.swift:602-609` uses control-priority stop and
`abandonAllWork()`, recording only an aggregate `abandonedAtStopCount`.

Required disposition:

- explicit kill must drain accepted FIFO;
- ADR 0002 visibility may abandon, but each revision needs an
  `abandonedVisibility` terminal receipt;
- aggregate count alone is insufficient.

### API-P1-02 — ignored stop result is not positive destruction proof

- `ThreadAffineRimeSession.swift:294-300,308-314` ignores Bool results from
  owner stop/delivery waits and then clears the owner reference.
- `KeyboardController.swift:155-181` tears down and can rebuild mode around this
  coordinator.

Required disposition: timeout enters `FencedUnavailable`. Baseline creation
requires positive `ownerDestroyed`, `mailboxTerminal` and `deliveryDrained`
receipts.

### API-P1-03 — preflight fallback has a potential exclusive-switch gap

`KeyboardViewController+Bootstrap.swift:295-353` can try the dual-gate owner,
clear flags after failure and later reach baseline creation at
`KeyboardViewController+Bootstrap.swift:227-240`.

Required disposition: the unique mode coordinator must gate baseline creation
on positive absence/destruction of any canary session, not on cleared flags.

### API-P1-04 — candidate-window live-read hint can bypass the owner

- MainActor serial bridge drains and then directly calls its underlying live
  engine at `SerialRimeSession.swift:252-256`.
- Thread-affine bridge reads published snapshot candidates when no
  `chromeEngineHint` exists at `ThreadAffineRimeSession.swift:411-425`.
- Current installation does not pass the hint at
  `KeyboardController.swift:184-201`.

Required disposition: canary must never install a live `chromeEngineHint`.
Candidate windows use an owner query or immutable published snapshot only.

### API-P1-05 — typo-correction sidecar session is a second librime entry

- live query entry:
  `Packages/RimeBridge/Sources/RimeBridge/RimeEngineImpl+CorrectionQuery.swift:3-9`;
- sidecar create/schema:
  `Packages/RimeBridge/Sources/ObjCRimeBridge/RimeSessionManager.m:556-571`;
- baseline real-engine injection:
  `KeyboardViewController+Bootstrap.swift:236-237`;
- current dual-gate preflight substitutes a non-RIME provider:
  `KeyboardViewController+Bootstrap.swift:305-308`.

Required disposition: retain the provider-based `fail-closed` canary behavior,
or redesign the query to execute serially on the same owner. It cannot create a
parallel live sidecar session.

### API-P1-06 — processKey can implicitly recreate a session

`Packages/RimeBridge/Sources/ObjCRimeBridge/RimeSessionManager.m:198-218`
contains session recreation inside `processKey` recovery.

Required disposition: this implicit create path is owner-only in canary mode and
must produce the same lifecycle/session receipts as explicit recovery.

## Additional surfaces that cannot be assumed unreachable

The ObjC bridge exposes `highlightCandidateOnCurrentPage`, `currentOutput` and
`commitComposition` at
`Packages/RimeBridge/Sources/ObjCRimeBridge/include/RimeSessionManager.h:52-82`.
No non-test runtime caller was confirmed in this audit. Before implementation
`Ready`, static call-site/conditional-build analysis must classify each as:

- same-owner;
- explicitly unavailable in canary;
- or proven unreachable with a fail-closed compile/runtime boundary.

Runtime-selection callbacks and diagnostic reads also need immutable snapshot
delivery; a callback must not cause MainActor to touch the owner-local engine.

## Main-App runtime separation

- T9 smoke creates/selects/inputs/deletes/finalizes at
  `RimeT9SmokeProbe.swift:6-24`.
- Lua smoke directly uses `RimeSessionManager` at
  `RimeLuaRuntimeSmokeProbe.swift:38-89`.
- deployment invokes Lua smoke at `RimeDeploymentService.swift:80-87`.

These are separate App-process runtimes, not Extension canary session calls.
The evidence contract must prevent their markers/session identities from being
combined with an Extension run. Cross-process user-data locking and maintenance
overlap remain unproved by this static audit.

## Unresolved static-audit limits

- Process-global owner bookkeeping in `RimeSessionManager.m:539-554` is not a
  kill fence or destruction receipt.
- Current code does not prove that `waitUntilStopped`, delivery drain and native
  finalization form one positive terminal.
- The public ObjC entries above may have conditional/future callers not found by
  this snapshot.
- Cross-process Main-App smoke versus Extension canary user-data coordination is
  not validated.
- Current relevant source is ambient-dirty; no finding may be promoted to a
  clean implementation baseline without a frozen allowlist/fingerprint.

## I-Ready design-coverage criteria

This inventory provides sufficient design coverage for `I-Ready` only when:

1. the current snapshot fingerprints and exact maximum implementation allowlist
   are frozen while ambient worktree changes remain preserved;
2. every protocol/ObjC/session create/read/write/recovery/destroy entry is
   classified `same-owner`, `fail-closed` or proven unreachable through both a
   compile boundary and runtime fail-closed boundary;
3. all six API-P1 findings have an executable design/test mapping;
4. Architecture independently cross-reviews this inventory and its mappings;
5. no unreviewed live-session bypass, unsafe Sendability or parallel sidecar
   remains.

The frozen executable mappings are owned by Architecture design freeze §7. They
cover distinct drain/visibility abandonment, positive transition receipts,
exclusive baseline permits, snapshot-only candidates, non-RIME typo provider,
owner-only implicit recreation, fail-closed ObjC public entries and Main-App
evidence separation.

Final source/build fingerprints and an independent re-audit against the final
implementation diff belong to `E-Ready`; requiring them for `I-Ready` would be
circular. The `E-Ready` run header must also record whether Main-App deployment,
maintenance or smoke probes overlapped the Extension run; unknown or overlap
blocks single-owner evidence.
