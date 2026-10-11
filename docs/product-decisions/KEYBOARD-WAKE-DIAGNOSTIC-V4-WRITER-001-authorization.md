# Product Decision: KEYBOARD-WAKE-DIAGNOSTIC-V4-WRITER-001 — 接受 v4 持久化写入范围

> **S-03 — Superseded for current ADR status:** Human Architecture Authority and Product Lead conditionally accepted ADR 0036 on 2026-09-29; see [ADR-0036-ACCEPT](ADR-0036-ACCEPT-authorization.md). This earlier decision still governs the accepted product scope; statements below that ADR acceptance was pending describe the status when this decision was recorded.

**Decision ID:** `PD-KEYBOARD-WAKE-DIAGNOSTIC-V4-WRITER-001`
**Lifecycle status:** `Recorded — 产品范围已接受；ADR 与实现授权分离`
**Date / timezone:** `2026-09-29 Asia/Shanghai`
**Parent:** [KEYBOARD-WAKE-LIFECYCLE-DIAGNOSTICS-001](../assignments/keyboard-wake-lifecycle-diagnostics-001.md)
**Assignment:** [KEYBOARD-WAKE-DIAGNOSTIC-RUNTIME-RECORD-API-001](../assignments/keyboard-wake-diagnostic-runtime-record-api-001.md)
**Architecture:** [ADR 0036 — Accepted (Conditional) by separate decision](../architecture/decisions/0036-diagnostic-event-wire-v4-writer-compatibility.md)

## Authority

- **Product Approver:** Human Product Owner / Product Lead.
- **Decision source / date:** In-session instruction on 2026-09-29 Asia/Shanghai: “接受，可以按照你的建议继续”, responding to the recommendation to accept the v4 persisted writer scope and defer Extension call-site wiring to a separate paired-build rollout Assignment.
- **Assignment roles:** The Human Product Owner previously authorized role allocation according to KOS. The Runtime Record API Assignment records Input Intelligence Maintainer as Domain Owner; current Codex task as Executor; Architecture & Knowledge Steward and Quality, Performance & Release Maintainer as independent reviewers. Simulator/environment and manual reproduction dependencies are not applicable to this writer-only scope.

## Decision

The Human Product Owner accepts the bounded Runtime Record API writer scope for a v4-capable persisted event writer:

1. A v3 writer emits all newly written events as `schemaVersion = 3`.
2. A v4 writer emits all newly written events from that build as `schemaVersion = 4`, including events that reuse existing event codes.
3. Persisted v3 history stays `schemaVersion = 3`; no in-place rewrite or migration is part of this scope.
4. A v4-only code or payload must never be encoded as v3. A v3 writer must reject or omit it.
5. Extension call-site wiring and any event production remain deferred to a separate paired-build rollout Assignment, after the v4 reader/writer compatibility gate is satisfied.

This decision accepted the product scope and versioning direction only. ADR 0036 was accepted conditionally by the later [ADR-0036-ACCEPT decision](ADR-0036-ACCEPT-authorization.md). Neither decision authorizes source-code changes, implementation, tests, builds, Simulator/device operations, installation, v4 event emission, paired-build rollout, or the parent diagnostic reproduction. The repository instruction to discuss before writing code remains in effect.

## Scope

- Prepare and review the Runtime Record API Assignment, including the minimum `DiagnosticEvent` construction/encoding and journal-append support needed for the accepted v4 writer semantics.
- Continue to use the existing bounded asynchronous ingress; the hot path must not serialize, access preferences/files, wait for persistence, or perform synchronous I/O.
- Keep the three accepted Proposal 0.4 event/payload contracts closed, typed, content-free and unchanged.
- Keep Extension event call sites out of the Runtime Record API Assignment. Their future paired-build rollout needs a separate Assignment.

## Explicit boundaries

- This scope decision did not itself accept ADR 0036; its current **Accepted (Conditional)** status is recorded in the separate ADR acceptance decision.
- This decision does not alter the `Diagnostics/v1` journal layout, ownership, retention, locking, privacy, capture gates or Main App read behavior.
- This decision is not an implementation Authorization, Product Gate, Quality Gate, Release decision or root-cause finding.

## Related records

- [Schema Proposal 0.4](../plans/keyboard-wake-diagnostic-event-schema-proposal-001.md)
- [Runtime Record API Assignment](../assignments/keyboard-wake-diagnostic-runtime-record-api-001.md)
- [Deferred Extension Producer Assignment](../assignments/keyboard-wake-diagnostic-extension-producer-001.md)
- [ADR 0036](../architecture/decisions/0036-diagnostic-event-wire-v4-writer-compatibility.md)
- [ADR 0027](../architecture/decisions/0027-enterprise-local-diagnostic-observability.md)
