# M-06 decision brief: Extension wake-diagnostic writer version

**State:** Decision completed on 2026-09-30. The Human Product Owner accepted the v6 contract in the [Product Decision](../product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-WIRE-VERSION-RECONCILIATION-001-product-decision.md); ADR 0036 Addendum 002 is **Accepted; implementation pending** after Architecture R7 and Quality R5 **Pass with conditions**. The [wire-version reconciliation Assignment](../assignments/keyboard-wake-diagnostic-wire-version-reconciliation-001.md) is **Reviewed**. The paired-rollout Assignment remains **Assigned / Not Ready**; this decision does not authorize implementation or production emission. See the [M-02 state-sync receipt](../evidence/keyboard-wake-diagnostic-wire-version-reconciliation-001-adr-0036-addendum-002-state-sync-2026-09-30.md).

## Objective

Reconcile the persisted event-wire contract before the paired Extension rollout can enter Ready. At this brief's creation, the paired-rollout Assignment requested an Extension .v3 compatibility writer and a later .v4 promotion, while the reviewed compatibility-gate candidate preserved schema-v5 production events and kept wake-marker emission off. The accepted v6 decision recorded below supersedes that version path: retain the writer-v5 producer-off candidate and reserve writer v6 for a separately authorized marker-enabled promotion.

## Scope and effects

This requested slice is limited to Product/Architecture schema and Assignment disposition. It would clarify the wire version for future wake markers, reader-version support, preservation of existing v5 event behavior, test-fixture rules, and the conditions for a later paired production-emission candidate. It is decision/design work only; it has no current production or user-visible effect.

## Non-goals

- No source or test changes, build, Simulator action, installation, marker emission, manual Maps reproduction, or behavior change.
- No inference that a passing compatibility gate authorizes a production marker build.
- No silent downgrade of schema-v5 events, mixed per-code versions, relabeling, or in-place rewrite of retained journal data.

## Frozen facts

- Reviewed manifest r2 (`c75a75bd8ed180149a7bc8cb6c26a5fa5e4f5cbec122eede980f73a4d8cef835`) declares reader versions 3/4/5, production writer version 5, and no production v4 marker emission. All seven manifest source/test hashes still match in the paired-rollout worktree.
- The current candidate sets `DiagnosticEvent.schemaVersion = 5`; `DiagnosticsJournal.append` accepts only v5-writable events. V4-only marker payloads cannot be written as v5.
- The separately reviewed Runtime Record API evidence describes an explicit `.v3` / `.v4` writer selector, but its ten-file candidate (`abbe6154d52b5b4e23fcde32cea455f2de93d9a3a56356ef77e12486217f975c`) is based on older commit `9eb83158e49218c1e8f75dbe7dd9e0390db81409`, is not included in manifest r2, and its managed worktree is archived. The source bytes have not been revalidated or reconciled with schema v5 in this Entry pass.
- The current Extension uses the v5-only `.typoRecallQueryMeasured` event and related v5-only events (`Keyboard/Controllers/TypoCorrectionRecallCoordinator.swift:296-307, 344-356`; `DiagnosticEvent.swift:1146-1165`). Current same-candidate evidence does not show how selecting `.v3` or `.v4` for the Extension writer preserves these existing v5 diagnostics under ADR 0036's static-version rule.
- The paired-rollout Assignment (`91b78be7d7fafe6688487bbd9c77eed946af1f114ede9fd9dca80ec790fba253` before lifecycle-only updates) explicitly requests production `.v3` in its compatibility candidate and `.v4` in a later promotion.
- ADR 0036 adopts a single static wire version per writer build and forbids downgrading v4-only payloads.

## Decision requested (resolved by the recorded decision below)

**Recommended:** preserve schema-v5 production behavior, keep wake-marker production off, and authorize a separate document-only Product/Architecture schema reconciliation. That review should determine how a future single-version Extension writer can preserve existing v5-only diagnostics while adding wake markers, and define the reader support required for retained v3/v4/v5 history plus the future marker version. A forward schema version may be needed; the exact version is an Architecture/Product decision, and this brief does not preselect it. Then rebind or revise the paired-rollout Assignment and its reviews.

The other path—reusing schema v4 for production markers—would require Product to explicitly supersede the accepted v5-preservation contract and Architecture to re-review the static-version ADR consequences. The current Assignment and source do not authorize that downgrade.

## Decision recorded

The Human Product Owner selected the recommended forward v6 contract on 2026-09-30. ADR 0036 Addendum 002 records the accepted wire contract and was accepted after exact Architecture R7 and Quality R5 **Pass with conditions**. The separate writer-v5 compatibility candidate remains producer-off. The revised paired-rollout Assignment must complete current-scope role rebind, stage-specific authorization and Entry before any source work; v6 production marker emission, Simulator installation, Maps reproduction, Product/Quality Gate, Release and parent closure remain separately gated.

## Completion evidence

- A Product disposition and Architecture-reviewed protocol contract bound to exact document identities.
- Updated ADR/Proposal addendum and paired-rollout Assignment, or a recorded decision to retain the current producer-off state.
- Exact-scope role rebinds if the Assignment scope changes.
- No implementation claim until the revised Assignment's Entry criteria, implementation authorization, source ownership, and fresh Simulator reservation are satisfied.
