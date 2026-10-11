# ADR 0036 Addendum 002: Forward Wire v6 for Keyboard-Wake Markers

## Status

**Accepted; implementation pending.** The Human Product Owner accepted the v6 contract in the [Product Decision](../../product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-WIRE-VERSION-RECONCILIATION-001-product-decision.md). Architecture R7 and Quality R5 returned **Pass with conditions** on the exact pre-status candidate SHA-256 `accd1586baa0214368a1ee634c462447ce41a482cff27dbdba0710e514d03fc3`; see the [Architecture review](../../reviews/keyboard-wake-diagnostic-wire-version-reconciliation-001-architecture-r7-review.md) and [Quality review](../../reviews/keyboard-wake-diagnostic-wire-version-reconciliation-001-quality-r5-review.md). Read this addendum together with [ADR 0036](0036-diagnostic-event-wire-v4-writer-compatibility.md). It extends the future marker path without rewriting the accepted historical ADR body. The residuals remain future implementation/promotion conditions; this acceptance does not authorize source or test changes, builds, Simulator operations, installation, or production marker emission.

## Context

ADR 0036 establishes a static writer-version rule: one writer build uses one persisted wire version for every newly written event, and retained history is validated by its original per-record version. The later reviewed compatibility-gate candidate preserves schema-v5 behavior, including v5-only typo-recall diagnostics, reads v3/v4/v5, and keeps production wake-marker emission off.

The marker payloads were first reviewed as v4 schema additions, but an active writer that also emits v5-only typo-recall cannot label only its markers v4 while writing existing events v5. That would violate the static writer rule. The reviewed wire-version reconciliation compares expanding v5 with introducing a forward wire version. The Human Product Owner accepted the exact proposal's v6 recommendation for a future marker-enabled paired build.

## Decision

1. Preserve ADR 0036's static writer-version invariant: each writer build labels every newly persisted event with its single declared wire version, regardless of event code or payload family.
2. The separately reviewed schema-v5 compatibility candidate remains writer-v5, preserves existing v5 behavior including typo_recall, reads v3/v4/v5, and keeps production wake-marker emission off. Its candidate identity and prior evidence do not establish v6 behavior or promotion readiness.
3. Reserve schemaVersion 6 for a future, separately authorized wake-marker-enabled paired build. That build writes all new records as v6, including existing event families such as typo_recall and the new keyboard-wake marker families. It must not emit v4- or v5-labeled events from the v6 writer build.
4. A v6 reader explicitly validates and reads retained v3, v4, v5, and v6 records by each record's own schemaVersion. Its closed version-specific allowlist must:
   - accept v6-labeled typo_recall and v6-labeled wake markers;
   - continue to accept retained v5 typo_recall and v4 marker records under their original versions;
   - preserve valid neighboring records in mixed-version history without relabeling or rewriting retained bytes.
5. A non-integer, malformed, unsupported, or future schema version, unknown key/code/value, malformed payload, or invalid version/code/payload pairing remains bounded incomplete/unsupported state. Valid neighboring records remain available; a rejection cannot become a complete-empty result or permit legacy fallback.
6. Production marker emission remains off until a separately authorized and reviewed v6 promotion candidate proves the same-build Main App + Keyboard Extension writer/reader identity, strict validation, incomplete propagation, and legacy-fallback suppression. A v5 compatibility candidate, the pre-revision writer-v3 implementation authorization (which was held at Entry), a unit test, or document review does not authorize v6 production emission.
7. Preserve the Diagnostics/v1 journal layout, ownership, retention, locks, privacy fields, existing capture gates, bounded asynchronous ingress, and content-free payload boundary.

## Alternatives Considered

- **Extend v5 for the new markers:** technically possible, but it broadens the accepted Proposal 0.4 rule that a new event code/payload contract advances schemaVersion. It would require a separate Product/Architecture amendment and a same-build gate for older v5 readers that may not recognize the marker codes. The Human Product Owner selected the forward v6 contract for this candidate.
- **Keep marker production off without selecting a future wire version:** remains the current operational state until a separate implementation and promotion gate passes, but it does not resolve the long-term compatibility contract selected by the Human Product Owner.
- **Write markers as v4 while continuing to write typo_recall as v5 in one build:** rejected because per-code writer-version mixing violates ADR 0036.
- **Rewrite retained history to v6:** rejected because records retain the version and bytes under which they were written.
- **Change the journal directory to Diagnostics/v2:** rejected because the wire-version decision does not require a layout or ownership change.

## Consequences

- A future v6 implementation requires a new exact source/test manifest and version-aware KeyboardCore reader, Main App consumer, and Extension writer candidate.
- Every new event in the v6 writer build is v6, including event families previously written under v5. Existing v3/v4/v5 records remain unchanged and continue to be read by their own version.
- The v5 compatibility-gate candidate and its tests/reviews remain valid only for their frozen v5 scope.
- The paired-rollout Assignment must distinguish the v5 producer-off compatibility candidate from the future v6 emission-promotion candidate and must bind a single Main App + Extension build for v6 promotion.

## Risks and Residuals

- Arbitrary older v3/v4/v5 readers are not claimed to safely consume v6. A same-build v6 reader/writer gate is required before production emission.
- Direct Main App coverage for v6-only and mixed v5/v6 history with legacy fallback data present, rejected-only history, unknown raw keys, malformed payloads, and incomplete propagation remains future implementation evidence.
- Foundation JSONDecoder does not expose duplicate object member occurrences. The implementation must use a parser that can reject duplicates or explicitly retain that limitation; do not claim duplicate-member detection without evidence.
- The historical Entry receipt transcription error ENTRY-ID-DRIFT-01 remains narrowly excluded from current identity proof as recorded in the reconciliation Assignment and Quality reviews.

## Follow-up Work

1. Rebind the paired-rollout Assignment to this v6 contract and obtain current-scope role acknowledgments/reviews. Keep it Not Ready until its Entry criteria and a fresh exact authorization for the v5 compatibility stage are satisfied; any v6 implementation and promotion require their own separate authorizations.
2. Create a separately authorized v6 implementation candidate with fresh source/test identities, verified writer ownership, strict version-specific validation, full CI-equivalent target evidence, and a fresh exclusive Simulator reservation before Simulator validation.
3. Obtain independent exact-candidate Architecture and Quality review before installation or production marker promotion.
4. Ask the Human Product Owner to perform the previously planned Maps App Switcher reproduction only after the exact v6 promotion candidate is authorized, reviewed, and installed, and after the human dependency is rebound to that candidate.

## Related Documents

- [ADR 0036 — Diagnostic Event Wire v4 Writer Compatibility](0036-diagnostic-event-wire-v4-writer-compatibility.md)
- [ADR 0036 acceptance decision](../../product-decisions/ADR-0036-ACCEPT-authorization.md)
- [Wire-version reconciliation proposal](../../plans/keyboard-wake-diagnostic-wire-version-reconciliation-001-proposal.md)
- [Wire-version Product Decision](../../product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-WIRE-VERSION-RECONCILIATION-001-product-decision.md)
- [Paired-rollout Assignment](../../assignments/keyboard-wake-diagnostic-extension-paired-rollout-001.md)
- [V3 compatibility-gate Assignment](../../assignments/keyboard-wake-diagnostic-v3-compatibility-gate-001.md)
- [Parent keyboard-wake diagnostic Assignment](../../assignments/keyboard-wake-lifecycle-diagnostics-001.md)
