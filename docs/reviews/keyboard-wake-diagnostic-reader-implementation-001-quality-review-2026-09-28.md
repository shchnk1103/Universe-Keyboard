# KEYBOARD-WAKE-DIAGNOSTIC-READER-IMPLEMENTATION-001 — Independent Quality Review

Review disposition: **ACKNOWLEDGED — Pass with conditions**. This is an independent read-only Assignment review, not a Quality Gate, Product Gate, merge, or Release conclusion.

## Identity and Evidence

- Base `HEAD`: `9eb83158e49218c1e8f75dbe7dd9e0390db81409`.
- Reviewed five-file candidate aggregate SHA-256: `c752ffe96743bca3df96d54dccdce2d2be2e59e186c85125b0b0c21174787ed7`.
- Per-file source/test identities and executor evidence: [`implementation evidence`](../evidence/keyboard-wake-diagnostic-reader-implementation-001-2026-09-28.md).
- Archived KeyboardCore package test log SHA-256: `b84559ca3e7ac98a23f9dd36224f2e3e4fca979dcb787dd357f20ea3b918f256`; recorded outcome: **1132 passed / 0 failed**. The reviewer did not rerun the suite.

## Review Findings

### Closed on the reviewed candidate

- The v3 decoder retains raw key presence for v4-only payload keys, including explicit `null`, and rejects such a v3 record.
- Nested unknown enum values in historical RIME Sync, Scheme Delivery and Runtime Route composite payloads are classified as `.unknownValue` before typed decoding.
- Historical composite v4 records are integrated through `latest`, `beginPage`, `nextPage` and `recentPreview`.
- Top-level and nested privacy-key exclusions, multiple payload wrappers, mixed/rejected-only histories, frozen-query completeness and the v3 writer invariant have regression coverage.
- Runtime Route `elapsedMilliseconds` is checked against the existing `0...600_000` invariant; `-1` and `600_001` are rejected as `.malformedPayload` through every applicable reader path.
- Public read APIs identify nonpositive budgets as invalid caller inputs. Their empty no-read return is not evidence that a journal is empty, and `nextPage` does not consume its cursor on that path.

### Conditions and residual ownership

| ID | Residual | Owner | Disposition |
|---|---|---|---|
| KWR-01 | Strict raw-key rejection is guaranteed at `DiagnosticsJournalReader`; direct `JSONDecoder().decode(DiagnosticEvent.self, from:)` can ignore unknown keys. | App & Data Operations Maintainer | **accept** for this KeyboardCore Assignment. Main App/export consumers must use the journal reader; any direct decoding path requires a separately scoped strict-decoder Assignment. |
| KWR-02 | Foundation's current parsing path cannot expose repeated JSON object member occurrences, so duplicate member names are not detected or reported incomplete. | Architecture & Knowledge Steward | **accept** for this Assignment, consistent with the pre-Ready Architecture disposition. Do not claim duplicate-name coverage. |

The v4 producer remains disabled. Main App incomplete-status presentation and legacy-fallback suppression, Extension emission, paired-build rollout, Simulator/runtime reproduction, performance, root cause, Product Gate and Release remain out of scope and require their own authorized work.

## Reviewer Checks

The reviewer independently recomputed all five candidate file hashes and the aggregate; both match the evidence record. The prior P1/P2 findings are closed on this exact candidate. No P0/P1 blocker remains. This review performs no implementation edit, Simulator/App/Extension/RIME operation, or Product/Release decision.
