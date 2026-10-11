# Authorization: AUTH-TYPO-CORRECTION-002-TESTABILITY-ACCESSIBILITY-F02-REVALIDATION-001

## Bounded F-02 overlay-state touch-hit revalidation

### Current status

- Status: `consumed` — 采集授权已用尽；证据已绑定 child 对账收据。本收据不可再用于新的 Simulator 采集或发布。
- Target Assignment: `TYPO-CORRECTION-002-TESTABILITY-ACCESSIBILITY-F02-REVALIDATION-001`（**未 Closed**）。
- Parent Assignment: `TYPO-CORRECTION-002`（仍 Active）。
- Child implementation context: `TYPO-CORRECTION-002-TESTABILITY-ACCESSIBILITY-001`（**未 Closed**）。
- Disposition SoT: [`docs/evidence/typo-correction-002-testability-accessibility-f02-reconciliation.md`](../evidence/typo-correction-002-testability-accessibility-f02-reconciliation.md) 与 Architecture [`最终处置`](../reviews/typo-correction-002-testability-accessibility-f02-architecture-final.md)。Sidecar **不**另写 residual 表。
- Publication boundary: none. This authorization does not permit commit, push, PR, merge, release, or Assignment closure.

### KOS record

```yaml
record_id: AUTH-TYPO-CORRECTION-002-TESTABILITY-ACCESSIBILITY-F02-REVALIDATION-001
record_type: authorization
title: Authorize bounded F-02 overlay-state touch-hit revalidation
status: consumed
decision_source: Human Product Owner confirmation in the current task
decision_date: 2026-09-19
parent_assignment: TYPO-CORRECTION-002
target_assignment: TYPO-CORRECTION-002-TESTABILITY-ACCESSIBILITY-F02-REVALIDATION-001
authorization_action: revalidate_overlay_state_touch_hit_consistency
source_baseline: 9eb83158e49218c1e8f75dbe7dd9e0390db81409
executor: independent Quality runtime operated by Grok
run_id: allocate a new unique Run ID immediately before capture
consumption: consumed; capture complete; bound to child F-02/QR-01 receipt
```

### Authorized action

The Human Product Owner authorizes a fresh independent Quality runtime to perform a read-only, bounded comparison of the same visible keyboard key at the same screen coordinate with the existing Debug touch-range overlay in its available states.

The purpose is to verify the Architecture residual `F-02` / Quality residual `QR-01`: changing the existing diagnostic overlay state does not change the normal touch hit or introduce a second action path. The test must use the existing implementation and normal UI/hardware touch events. It must not add a toggle, test hook, logging path, or source change.

The intended overlay is the existing KEY-TOUCH-FILL diagnostic/debug overlay. If the executor cannot identify or switch its states without modifying code, it must stop and record `UNKNOWN` rather than inventing a new control.

### Frozen artifact binding

- Implementation worktree: `/private/tmp/universe-keyboard-typo-correction-002-testability-accessibility-001`.
- Branch: `codex/typo-correction-002-testability-accessibility-001`.
- Base commit: `9eb83158e49218c1e8f75dbe7dd9e0390db81409`.
- Worktree state: the uncommitted child implementation diff is allowed as the test subject; no additional file may change during this authorization.
- Designated Simulator: iPhone 17 Pro Max / iOS 27.0 / UDID `06C5BC3E-7599-4761-A1A2-71DAEA991474`.
- Run ID: must be newly allocated immediately before actual capture; do not reuse the prior AX harness Run ID or xcresult.
- Prior evidence is context only and does not satisfy this Authorization: the Quality AX xcresult proved key discoverability but did not toggle the overlay or perform the same-coordinate comparison.

### Scope

The executor may:

- freeze and hash the current worktree/diff before capture;
- identify the existing overlay states and operate only that existing control;
- select one deterministic visible alphabetic key, preferably `q`, and one fixed point inside its visible face;
- execute the same-coordinate touch in each available overlay state;
- inspect privacy-safe, operation-correlated touch diagnostics and existing UIKit action evidence;
- produce a new evidence receipt with the Run ID, exact identity, state transitions, raw artifact paths, and SHA-256 values;
- assign `QR-01` a bounded disposition for independent Architecture/Quality follow-up.

### Explicit exclusions

This authorization does not permit:

- source, test, project, configuration, schema, RIME, sidecar, candidate, debounce, cancellation, or deployment changes;
- adding a debug toggle, production accessibility surface, instrumentation, test-only hook, or second business action path;
- changing `KeyboardTouchRoutingCanvas`, `KeyTouchCellLayout`, hit formulas, key geometry, row spacing, or visual layout;
- `typeText`, host-text injection, pasteboard, `setMarkedText`, `documentContext`, private Simulator APIs, or synthetic fixtures;
- claims about RIME output, INT-003, QA-001, candidate quality, performance, nine-key AX, true-device VoiceOver, Product Gate, or parent closure;
- commit, push, PR, merge, release, tag, branch cleanup, or remote mutation.

### Required evidence

The handoff must include:

1. new Run ID and exact timestamp;
2. pre/post `git status --short`, changed-path manifest, and hashes for the frozen implementation files;
3. exact overlay states and how they were reached;
4. fixed coordinate or deterministic coordinate derivation and selected key identity;
5. per-state touch/action result and operation-correlated diagnostic evidence;
6. raw artifact paths and SHA-256 values;
7. no-injection and no-private-API statement;
8. `QR-01` disposition with owner and evidence pointer;
9. explicit non-claims for all excluded parent/product/device scopes.

### Stop conditions

The executor must stop and return `UNKNOWN` without editing code if:

- the existing overlay cannot be identified or toggled;
- the comparison requires adding source instrumentation or a new control;
- the only usable route is host-text injection, pasteboard, marked text, private Simulator API, or an unbounded coordinate injection;
- the overlay state changes layout or requires modifying the hit formula;
- evidence cannot be correlated to the current operation and state;
- worktree identity, baseline, reviewer independence, Simulator identity, or a new Run ID cannot be proven;
- the request expands beyond F-02/QR-01 evidence.

### Human instruction and authority boundary

This authorization is issued by the Human Product Owner acting as Product Lead, based on the confirmation in the current task on 2026-09-19 (Asia/Shanghai). It authorizes only read-only evidence revalidation. It does not authorize a fix, broader testability work, Product/Quality acceptance, publication, or parent closure.

The target Assignment remains `Assignment Pending` until the Quality executor acknowledges the scope, fresh-runtime requirement, frozen worktree, environment, and stop conditions. No work in `main` or the dirty parent sidecar is covered as an implementation workspace.

### Consumption and revalidation

- Issuer: Human Product Owner / Product Lead.
- Issued: 2026-09-19.
- Consumed by: F-02/QR-01 evidence capture already completed (Arm A `QR-F02-REVAL-20260919T071659Z-FC1AEA63`, Arm B `QR-F02-REVAL-20260919T073732Z-113A0BDB`); disposition owned by the child worktree receipt. Independent Architecture consumed this AUTH on 2026-09-19 after verifying the bound.
- Revalidation is required if the worktree, diff, overlay mechanism, Simulator/device, selected coordinate, evidence artifact, reviewer runtime, or Run ID changes.
- Any source change or publication action requires a separate Authorization.

### History

- 2026-09-19: created after Architecture and Quality returned `Pass with conditions`, bounded to F-02/QR-01 same-coordinate overlay-state touch evidence.
- 2026-09-19: **consumed** — capture used; child reconciliation receipt is residual SoT; sidecar Assignment remains not Closed.
