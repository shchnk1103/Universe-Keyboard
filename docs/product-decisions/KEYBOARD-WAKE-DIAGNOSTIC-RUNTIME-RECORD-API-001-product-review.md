# Product Review: KEYBOARD-WAKE-DIAGNOSTIC-RUNTIME-RECORD-API-001

- **Lifecycle:** Recorded — implementation candidate accepted with conditions; Assignment is Reviewed
- **Authority:** Human Product Owner / Product Lead
- **Decision date:** 2026-09-29 Asia/Shanghai
- **Parent:** [KEYBOARD-WAKE-LIFECYCLE-DIAGNOSTICS-001](../assignments/keyboard-wake-lifecycle-diagnostics-001.md)
- **Assignment:** [KEYBOARD-WAKE-DIAGNOSTIC-RUNTIME-RECORD-API-001](../assignments/keyboard-wake-diagnostic-runtime-record-api-001.md)

## Decision source

In the current Codex task, the Human Product Owner replied “接受” to the explicit request to accept the exact Runtime Record API implementation candidate and carry forward the stated Architecture and Quality conditions. This records the Product review of that result, not a new implementation or rollout authorization.

## Exact candidate and review identities

- Canonical ten-file source/test manifest SHA-256: abbe6154d52b5b4e23fcde32cea455f2de93d9a3a56356ef77e12486217f975c.
- All ten current file SHA-256 values were independently rechecked against that manifest immediately before this decision and matched.
- Assignment identity before the Reviewed writeback: 8f123d1c06e5ce0f39c472c4d8c3cea1c55aadeaffdd3699f8dadf04c62814c9.
- Parent identity before status synchronization: d5e97a8a314b628f4b4ddf068d35dee0e4a3c29b951cc16fe18b00cb99ecae5f.
- docs/ACTIVE_WORK.md identity before status synchronization: e615a441bb459c812b59cc01fac68fd98f1e037434f4c165ec6f5d5c9f0c5a83.
- Implementation evidence SHA-256: 3485abf306014835dde10528e61adb3c1f5f8757471b11a93dd55eba0c652b47.
- Architecture review: **ACKNOWLEDGED — Pass with conditions**, receipt [Architecture implementation review](../reviews/keyboard-wake-diagnostic-runtime-record-api-001-architecture-implementation-review-2026-09-29.md), SHA-256 0adcd8a18c35628573ec213d5dd6c42a9d7134b6ed93cb1a8b0c3c8ea290af00.
- Quality review: **Pass with conditions**, receipt [Quality implementation review](../reviews/keyboard-wake-diagnostic-runtime-record-api-001-quality-implementation-review-2026-09-29.md), SHA-256 cada3c92ddb5f86c77958899b23e7890f06b91ba7f8a4284d106457cea84d658.
- After the original reviews, Architecture and Quality independently rechecked the current Assignment, parent, and Active Work identities. Both confirmed that the changes were status/history synchronization only, with no scope, authorization, or source/test candidate drift.

## Accepted outcome

The Human Product Owner accepts the exact implementation candidate for this Assignment's Product review, with the conditions below carried forward. The candidate adds the three typed Runtime submissions and minimum writer support; Runtime/Ingress remain v3 by default, typed v4 submission requires explicit opt-in, and no production Extension call site enables v4. The recorded KeyboardCore result is 1137 tests with 0 failures; this Product review did not rerun tests.

### Conditions carried forward

1. Preserve v3 defaults and explicit-v4 opt-in. Do not enable a production .v4 Runtime or add Extension typed call sites under this decision.
2. Production v4 emission requires a separately issued and authorized paired-build Assignment that binds the same Main App + Keyboard Extension build and the required writer/reader compatibility evidence, including strict code/payload/raw-key validation and incomplete/unsupported/legacy-fallback behavior.
3. Carry the Quality review's non-blocking coverage residuals into that successor: the candidate does not exhaust all lifecycle phases, text-proxy operation/phase combinations, RIME failure enum values, queue backpressure, writer I/O failure, and lifecycle suspend races. Preserve the documented Reader limitation for duplicate JSON object keys.
4. If any file in the ten-file source/test manifest changes, freeze a new manifest and obtain fresh exact-candidate Architecture and Quality reviews before relying on the current conclusions.

## Scope and non-claims

This decision records Product acceptance of the implementation result and the Completed to Reviewed lifecycle transition only. It does not:

- close this child Assignment or the parent diagnostic Assignment;
- constitute a Product Gate, Quality Gate, Release decision, or merge approval;
- authorize commit, push, pull request, merge, Simulator/device activity, or installation;
- authorize Extension event call sites, production v4 emission, or the separate paired-build rollout Assignment;
- claim a keyboard behavior fix or established root cause.

The parent remains Active and root cause remains unresolved. The Extension producer predecessor remains Reassigned; no successor paired-build Assignment has been issued.

## Documentation link-check record

The KOS M-02 markdown-link check result and its baseline/candidate-tree pair are recorded in [the validation log](../evidence/keyboard-wake-diagnostic-runtime-record-api-001-product-review-markdown-links-2026-09-29.log).
