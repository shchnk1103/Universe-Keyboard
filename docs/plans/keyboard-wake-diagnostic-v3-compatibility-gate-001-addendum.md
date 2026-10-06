# Proposal 0.4 Addendum — V3 Compatibility Gate 001

## Status and scope

This addendum records how the previously accepted Proposal 0.4 design applies to the v3 compatibility-gate candidate based on `origin/main` commit `84b9c19227330b0fe6ff391be001ee398010fd6a`. It is limited to this candidate and does not rewrite or supersede the historical Proposal 0.4 text or create a new production schema contract.

The Human Product Owner's authorization for `KEYBOARD-WAKE-DIAGNOSTIC-V3-COMPATIBILITY-GATE-001` preserves current schema-v5 production behavior and delegates the new marker writer/producer boundary within that scope to Architecture. Architecture Round 1 resolved that boundary as specified below.

## Current-base compatibility interpretation

- The current production writer remains schema v5, including existing `typo_recall` events.
- This candidate's “v3 compatibility gate” refers to reader compatibility: each retained record is validated using its own version, and valid v3, v4, and v5 records may coexist in history.
- The candidate does not downgrade the current writer to v3, relabel v5 events, or change existing v5 event behavior.
- The new wake-marker producer is off in the production Extension for this candidate.
- A v4 wake-marker payload may be used only by isolated test fixtures backed by temporary or in-memory storage. Fixtures must not call production App Group storage, `DiagnosticsJournalRuntime`, or real Extension ingress.
- Future production wake-marker emission, whether v4 or v5, requires a separate Product and Architecture decision and a separately authorized paired-build rollout.

## Validation and failure semantics

Use per-record version validation. Preserve valid neighboring events while representing detectable malformed, unsupported, or mismatched records as bounded incomplete/unsupported status. Query-wide incompleteness must remain attached through page continuation. Only a known-complete empty v1 journal result may permit the existing legacy `rime_diag_log` fallback; incomplete, unsupported, partial, unavailable, or rejected-only results suppress it.

Preserve strict raw-key validation through `DiagnosticsJournalReader`. The known Foundation `JSONDecoder` duplicate-member limitation remains an explicit non-claim; detecting duplicate JSON members would require a separate parser decision.

## Non-authorization

This addendum does not authorize production marker emission, a mixed-version production writer, changes to current v5 behavior, a changed legacy-fallback contract, app installation, manual reproduction, or a Product/Quality Gate or Release conclusion. It applies only within the existing Product Authorization and Assignment.
