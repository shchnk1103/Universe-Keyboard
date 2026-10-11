# Architecture review: TYPO-CORRECTION-002 runtime integration design

**Verdict:** `Conditional Accept` — the design direction may be revised, but it
does not authorize a controller/sidecar runtime implementation. Findings F-01
through F-03 are `fix` before a new implementation Authorization can be sought.

## Review identity and delivery reconciliation

| Field | Value |
|---|---|
| Reviewed design | [`runtime integration design`](../plans/typo-correction-002-runtime-integration-design-2026-09-21.md) |
| Design SHA-256 | `11fc5bf7dd921f5b21e019e6fab92952f8e4576afcf9c64c8a182c488efb4043` |
| Primary review authority | [`Architecture Authorization`](../authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-DESIGN-ARCHITECTURE-001.md), consumed |
| Delivery reconciliation | [`reconciliation Authorization`](../authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-DESIGN-ARCHITECTURE-RECONCILE-001.md), consumed |
| Evidence boundary | Two completed independent, read-only reviewer reports. The primary report was returned before its designated file was created; this record transcribes its verdict and finding dispositions without changing them. A second independent report is corroboration, not a replacement Product or Quality decision. |

The reviewed SHA-256 was independently matched by both reviewers. No reviewer
modified the design, source, tests, RIME state or device state.

## A–E review

### A. Single RIME owner and bypass boundary — Pass with conditions

The design correctly retains the live-composition/sidecar separation and rejects
`Task.detached`, direct raw-engine entry, a second RIME session and parallel query
lanes. This aligns with the current serialized MainActor and thread-affine owner
contracts.

Before implementation, the default `RimeEngineImpl` and thread-affine bridge
paths need one explicit adapter/epoch mapping. A second-stage call must not bypass
either existing owner.

### B. Marked text and commit boundary — Pass

The proposed result remains a display-only `TypoCorrectionSuggestion`. It
prohibits `insertText`, `setMarkedText`, clipboard use, direct candidate-bar
mutation and live RIME candidate selection. User selection through existing Core
finalization remains the sole host-commit path.

### C. Synchronous query, cancellation and stale fences — Conditional

The design correctly says that an already-started synchronous owner-facade call
cannot be retroactively cancelled and that its returned result needs a stale
fence. It does not yet establish how new input, page/mode, visibility or epoch
invalidation gets a MainActor turn between successive calls. Consequently,
“cancelled means no next query starts” is not yet an implementable contract.

### D. Core, UIKit, RimeBridge and diagnostics/privacy — Pass with conditions

Core remains the owner of `state.typoCorrection`; UIKit owns operation lifecycle
and candidate-bar refresh; RimeBridge owns real sidecar invocation. The plan
prohibits raw composition/corrected input/candidate text, host context, clipboard,
text hashes and durable GroupID mappings in routine telemetry.

The current Core method still combines hypothesis construction, synchronous query,
deduplication, ranking and state mutation. The revised design must define its
stage handoff and one conditional state-apply boundary. A routine operation
receipt must not reuse DEBUG decision tracing and must remain non-blocking.

### E. Performance and ADR boundary — Pass

The plan does not treat the 180 ms debounce or historical sidecar elapsed values
as a performance result. No new ADR is necessary while it preserves ADR 0004 /
0025 ownership. An ADR or amendment becomes required if a later proposal changes
the RIME owner/executor, adds a cross-executor async bridge, bypasses the existing
owner or changes session lifecycle.

## Reconciled findings

| ID | Severity | Disposition | Required design revision |
|---|---|---|---|
| F-01 | High | `fix` | Define an execution-yield/cancellation contract between synchronous queries: name the invalidation sources, establish when they can run, require a pre-query fence after that opportunity, and retain the post-return fence. |
| F-02 | Medium | `fix` | Define one adapter and comparable operation-epoch source for default `RimeEngineImpl` and thread-affine paths, including all invalidation events and no-bypass call entries. |
| F-03 | Medium | `fix` | Define stage-one/stage-two input and result handoff, cross-stage candidate deduplication/ranking, and exactly one conditional Core state-apply point. |
| F-04 | Low | `tech_debt` | Specify operation-receipt retention and privacy review in a later diagnostics/privacy Authorization. The existing plan already forbids DEBUG-trace reuse and text-bearing routine telemetry. |

## Residuals and non-claims

Coverage-deficit semantics, production budgets, real RIME behavior, QA-001,
INT-003, paired performance and user-visible candidate outcomes remain `UNKNOWN`.
This review ran no tests, builds, RIME calls, Simulator/device capture or new Run.
It makes no Quality/Product Gate, publication, commit, push, PR, merge, Release
or Assignment-Close claim.
