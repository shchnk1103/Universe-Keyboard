# Product Authorization: KEYBOARD-WAKE-DIAGNOSTIC-RUNTIME-RECORD-API-001 Implementation

**Lifecycle:** Authorized for bounded local implementation
**Authority:** Human Product Owner / Product Lead
**Decision date:** 2026-09-29 Asia/Shanghai
**Target:** [Runtime Record API Assignment](../assignments/keyboard-wake-diagnostic-runtime-record-api-001.md)

## Decision source

The Human Product Owner instructed in the current task: “授权该 Assignment”. The same instruction authorized opening a new worktree if exclusive writer ownership could not be established in the existing one.

## Authorized work

Implement the accepted Runtime Record API Assignment in `Packages/KeyboardCore`:

- Add the three reviewed typed v4 submission methods and the minimum version-aware event construction, encoding, and journal-append support in the Assignment's production files.
- Preserve the v3/v4 writer-version invariant, immutable v3 history, closed Proposal 0.4 payloads, content-free privacy boundary, and bounded asynchronous ingress.
- Add focused KeyboardCore tests in isolated test files using temporary journal storage. The existing modified `DiagnosticEventTests.swift` and `DiagnosticsJournalTests.swift` are protected inputs and must not be edited.
- Run the Assignment-required strict Swift formatting and KeyboardCore package suite against the exact implementation candidate.

The implementation work is isolated in the newly created managed worktree at `/Users/doubleshy0n/.codex/worktrees/runtime-record-api-impl/Universe Keyboard`, based on `9eb83158e49218c1e8f75dbe7dd9e0390db81409`. Its source/test baseline and copied Reader dependency are recorded in the [fresh-worktree identity receipt](../reviews/keyboard-wake-diagnostic-runtime-record-api-001-fresh-worktree-baseline-2026-09-29.md).

## Boundaries

This authorization does not add Extension call sites, enable production v4 event emission, change the Main App consumer, alter keyboard behavior, instrument RimeBridge, perform Simulator/device work, install an app, or run a manual reproduction. It does not authorize commit, push, pull request, merge, Product/Quality Gate, Release, paired-build rollout, or parent Assignment closure. A future Extension producer remains subject to its separate paired-build Assignment.

The network-isolated environment could not query `origin/main`; this implementation is therefore bound to the exact reviewed local baseline above. Any later mainline movement requires impact analysis and fresh validation before publication.
