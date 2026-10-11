# Architecture Review R1 — V3 Compatibility Gate

## Identity

- Assignment: `KEYBOARD-WAKE-DIAGNOSTIC-V3-COMPATIBILITY-GATE-001`
- Assignment SHA-256 reviewed: `f19ee343da3347c04f89fa0cf99bbf96c9e82d4b94fc16fdd3d56260fff38245`
- Architecture packet SHA-256: `38424bf5a6c2ff5767554fa5f0816d1d12ab6e9ad3f0865ae4a355473be4129a`
- Product Authorization SHA-256: `600c9e0419d050912d59b8496bce592896cf75aa08ef48d07a215d28df63fe4e`
- Exact base: `84b9c19227330b0fe6ff391be001ee398010fd6a`
- Disposition: **Pass with conditions**

This was an Assignment/contract review, not an implementation-candidate review, runtime diagnosis, Quality Gate, or Product Gate.

## Architecture disposition

The compatibility gate must preserve the current production schema-v5 writer behavior, including `typo_recall`. It must not force the current production path back to v3. “V3 compatibility” means that the reader explicitly validates each retained v3, v4, and v5 record against that record's own version, including valid mixed-version history.

New keyboard-wake markers remain producer-off in the production Extension for this candidate. A v4 marker may appear only in isolated test fixtures backed by temporary or in-memory storage. Those fixtures must not use the production App Group, `DiagnosticsJournalRuntime`, or real Extension ingress. The candidate must not create a production per-record v4/v5 mixed writer.

Preserve v5 `typo_recall` behavior. Rejected or malformed records must remain visible as bounded incomplete/unsupported status, and query-wide incompleteness must survive continuation. Main App legacy fallback is allowed only after a known-complete empty v1 journal result; incomplete, unsupported, partial, unavailable, or rejected-only results suppress fallback.

The current Foundation `JSONDecoder` duplicate-member limitation may remain an explicit non-claim. Detecting duplicate JSON members would require a separate parser decision.

## Required clarification

Record this candidate-scoped interpretation in addenda to Proposal 0.4 and ADR 0036 rather than rewriting their accepted historical bodies. The addenda clarify that this candidate preserves the current v5 production writer and reader compatibility; they do not authorize future production marker emission. A future production wake-marker version, production mixed-version writer, changed legacy-fallback contract, or stronger duplicate-key detection requires a separate Product/Architecture decision.

## Ownership and validation conditions

- Primary Domain Owner remains Keyboard Experience Maintainer.
- Input Intelligence consultation covers typed event/schema and reader completeness.
- App & Data Operations consultation covers query aggregation and legacy fallback.
- Quality validation includes the current signed Keychain integration test.
- Simulator-backed validation requires a fresh exclusive reservation naming the exact model, iOS runtime, and UDID.
- Exact implementation-candidate Architecture and Quality reviews require a new numbered round after the source/test manifest and evidence are frozen.

## Evidence boundary

The reviewer verified the frozen packet, Assignment, Product Authorization, base, and current source by read-only inspection. No source or Assignment was edited during this review. No tests, builds, Simulator operations, installation, network access, root-cause finding, behavior conclusion, Gate, Release, or parent closure occurred.

The reviewer reported 13 read-only tool calls and approximately seven minutes of active review time, within the frozen lane limits. The reviewer did not write this receipt; the coordinator recorded it from the final response.
