# ADR 0036 Addendum — V3 Compatibility Gate 001

## Status and scope

This is a candidate-scoped clarification to ADR 0036 for `KEYBOARD-WAKE-DIAGNOSTIC-V3-COMPATIBILITY-GATE-001`, based on `origin/main` commit `84b9c19227330b0fe6ff391be001ee398010fd6a`. It preserves the accepted historical ADR body and does not supersede ADR 0036 or authorize a production writer rollout.

## Current-base writer boundary

ADR 0036's static writer-version rule continues to apply to builds intentionally using its v3 or v4 writer contract. It does not authorize changing the current production v5 writer back to v3 or v4. For this candidate:

1. Keep the current production schema-v5 writer and all existing v5 behavior, including `typo_recall`.
2. Add no production Extension call site that emits the new keyboard-wake markers.
3. Use v4 marker payloads only in isolated test fixtures with temporary or in-memory storage; do not route fixtures through production App Group storage, `DiagnosticsJournalRuntime`, or real Extension ingress.
4. Extend the reader to validate each retained v3, v4, and v5 record against its own schema version, including valid mixed-version histories.
5. Do not introduce a production per-record mixture of v5 existing events and v4 wake markers.

## Incomplete history and fallback

Any detectable unsupported version, unknown code or raw key, malformed payload, code/payload mismatch, or version-incompatible field combination must remain represented as bounded incomplete/unsupported state rather than being silently dropped. Query-wide completeness must survive continuation. Main App legacy fallback is allowed only after a known-complete empty v1 journal result and is suppressed for incomplete, unsupported, partial, unavailable, or rejected-only results.

The known Foundation `JSONDecoder` duplicate-member limitation remains an explicit non-claim. A requirement to detect duplicate JSON members needs a separate parser and Product decision.

## Future decision boundary

Choosing a production version for new wake markers, allowing production mixed-version writer semantics, changing the legacy-fallback contract, or requiring duplicate-member detection is outside this addendum. Each requires a new Product/Architecture decision and an explicitly authorized follow-up Assignment. This addendum does not promote markers, establish runtime behavior, prove a root cause, or close the parent Assignment.
