# ADR 0017: Ephemeral Post-Commit Continuation

## Status

Accepted

## Context

The existing candidate pipeline is composition-centric. Final commit clears RIME composition, so normal RIME candidates cannot represent suggestions that appear after text has already reached the host. The feature also handles sensitive text inside a resource-constrained Keyboard Extension.

## Decision

KeyboardCore owns a continuation state separate from RIME, typo correction and Partial Commit. A narrow provider maps a bounded in-memory suffix of text committed by this KeyboardController to a bounded suggestion list from a bundled, versioned resource.

Final host commits update continuation state at the same exactly-once finalization boundary used by committed-text observation. Candidate presentation gives active composition priority, then exposes continuation items through a distinct candidate kind. Selecting a continuation performs a normal final host commit and can therefore chain another lookup.

V1 retains at most 32 Swift `Character` values in process memory. It does not read host surrounding text, persist content, query RIME, learn from the user or perform file I/O in the key path. Newline, host deletion, English mode, visibility abandonment, process death and disabling the feature clear the state.

The bundled resource is decoded once when the provider is created. Decode failure degrades to an empty provider. Ranking uses longest exact suffix, resource order, deduplication and a maximum of eight results.

### V1.1 Bounded Content Evolution

V1.1 keeps the resource format at version 1 and introduces an explicit content version. Loading fails closed when the JSON exceeds 512 KiB, contains more than 4,096 entries, exceeds the existing 32-`Character` context bound, exposes more than eight suggestions per context, or contains empty, duplicate or line-breaking content. Increasing these ceilings requires new Extension startup and memory evidence.

The V1.1 quality benchmark is test-only and synthetic. It may prove that registered, reviewed scenarios preserve their expected top-three result, but it cannot be cited as real-user coverage, acceptance rate or production telemetry. No benchmark fixture ships into the runtime resource unless it separately passes content review.

### V1.2 Curated Quality Expansion

V1.2 keeps the V1.1 runtime, privacy and fail-closed ceilings unchanged. It expands only manually authored synthetic content and its test-only Top-3 representative fixture. Specific multi-character contexts are preferred when they prevent a generic shorter suffix from controlling the result; resource order remains the sole ranking authority.

The larger inventory still does not establish corpus frequency, population coverage or acceptance rate. Any downloaded corpus, runtime telemetry, host-context access, learning or model-based ranking remains outside this ADR and requires a new Product and data review.

## Alternatives Considered

- Keep a RIME composition alive after commit: rejected because it contaminates marked-text and session semantics.
- Read `documentContextBeforeInput`: deferred because it expands the privacy and lifecycle contract beyond V1.
- Persist user n-grams: rejected because it creates reconstructable input history and conflicts with the accepted Typing Intelligence boundary.
- Add an on-device language model immediately: rejected because V1 first needs a quality and performance baseline with bounded deterministic behavior.

## Consequences

- KeyboardState gains an independent transient continuation state and candidate kind.
- Candidate UI is reused without changing its frozen geometry.
- Suggestions cannot be reconstructed after process death or arbitrary host edits that the keyboard did not commit.
- The shipped resource can improve independently while the state-machine contract remains stable.

## Risks

- Curated ranking may feel generic or produce weak suggestions.
- External cursor movement may make current-process context stale until an observable invalidation boundary occurs.
- Resource size or decode cost may regress Extension startup if allowed to grow without measurement.

## Follow-up Work

- Establish curated quality fixtures and physical-device behavior evidence.
- Obtain licensed or otherwise approved aggregate language evidence before making population-coverage claims or materially scaling beyond the curated pack.
- Review any proposal for host context, personal learning or models as a separate product/data change.

## Related Documents

- `docs/POST_COMMIT_CONTINUATION.md`
- `docs/architecture/input-pipeline-and-marked-text.md`
- `docs/architecture/decisions/0002-visibility-change-abandons-composition.md`
- `docs/architecture/decisions/0007-full-access-and-privacy-boundary.md`
- `docs/PERFORMANCE_BASELINE.md`
- `docs/RELEASE_CHECKLIST.md`
