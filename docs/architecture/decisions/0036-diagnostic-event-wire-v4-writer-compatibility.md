# ADR 0036: Diagnostic Event Wire v4 Writer Compatibility

## Status

**Accepted (Conditional) — Human Architecture Authority and Product Lead accepted on 2026-09-29; see [ADR 0036 acceptance decision](../../product-decisions/ADR-0036-ACCEPT-authorization.md). The writer-compatibility contract is binding; implementation, v4 event emission and paired-build rollout remain separately unauthorized.**

## Context

ADR 0027 fixes the local journal at `Diagnostics/v1` and defines content-free, typed events submitted to a bounded asynchronous ingress. The directory/layout version and the event wire version are separate contracts. Proposal 0.4 adds typed event families whose codes and payloads require a new `DiagnosticEvent.schemaVersion`.

The current writer is v3-only: event construction/encoding and `DiagnosticsJournal.append` do not persist v4 payloads. The existing ingress alone therefore cannot implement the accepted event envelopes. Proposal 0.4 also defines a static writer-version rule: a v4 build labels every new event it writes as v4, including events with existing codes.

The Product Decision [PD-KEYBOARD-WAKE-DIAGNOSTIC-V4-WRITER-001](../../product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-V4-WRITER-001-authorization.md) accepts this writer scope and defers Extension call sites to a separate paired-build rollout Assignment. That earlier scope decision did not itself accept this ADR or authorize implementation; the later conditional ADR acceptance is recorded separately.

## Decision (Accepted — Conditional)

1. Keep `Diagnostics/v1` layout, journal ownership, per-process segment boundaries, retention, locks, privacy rules, capture gates and bounded asynchronous hot-path behavior unchanged.
2. Treat `DiagnosticEvent.schemaVersion` as the persisted event-wire version:
   - A v3 writer labels every newly written event v3.
   - A v4 writer labels every newly written event from that build v4, including existing event codes.
   - Persisted v3 history remains v3 and is never rewritten in place.
   - A v4-only code or payload is never downgraded or encoded as v3; a v3 writer rejects or omits it.
3. Permit mixed retained v3/v4 history only through an explicitly version-aware v4 reader that validates each record against its own version. A v3 reader cannot establish that v4 records are absent.
4. Keep v4 Extension event emission disabled until a separate, explicitly authorized paired-build rollout proves that one installed Main App + Keyboard Extension build contains the v4 writer and reader, strict version/code/payload/raw-key validation, controlled incomplete/unsupported status, and legacy-fallback suppression. The source/build identity and required compatibility evidence must bind to the same candidate.
5. Keep the three Proposal 0.4 event families on their reviewed typed payloads and existing privacy/capture contract. This ADR introduces no payload-only version, open-ended fields, event-content logging or synchronous persistence.

## Alternatives Considered

- Keep the writer at v3 and place the new event families in v3: rejected because the persisted event protocol changes while its version says otherwise.
- Add a payload-only version while leaving `schemaVersion` at 3: rejected because it creates two version authorities for one persisted event contract.
- Let a v4 build write old event codes as v3 and new codes as v4: rejected because Proposal 0.4 defines a static writer version for every newly written event in the build, and mixed per-code writer semantics would be ambiguous.
- Enable Extension emission as soon as the writer exists: rejected because an older or incomplete reader could drop v4 records and misreport the journal as empty or fall back to stale legacy data.
- Change the journal directory/layout to `Diagnostics/v2`: rejected because the wire version change does not require changing the journal layout or its existing ownership/retention contract.

## Consequences

- A future Runtime Record API implementation must include typed submission methods plus the minimum v4 construction, encoding and append path; adding methods alone is insufficient.
- Reader compatibility is explicit: a v4 reader must preserve retained v3 history and validate v4 records. Rejected or unknown records must not appear as a normal empty journal or trigger legacy fallback.
- Extension call sites, v4 production enablement and paired-build evidence remain outside the Runtime Record API Assignment.
- No behavior, root cause, Product Gate, Quality Gate or Release conclusion follows from accepting this ADR.

## Risks

- A v3 reader may decode some known-code v4 events without validating the version, creating a false impression of compatibility.
- Unknown v4 codes or malformed v4 payloads can be dropped by older readers; without controlled incomplete status, fallback can mask their presence.
- Mixed retained v3/v4 records can be misread if the reader does not apply version-specific validation to every event.
- Concurrent source changes or another active writer on KeyboardCore production/test files can invalidate the implementation baseline.

## Follow-up Work

1. Complete the Runtime Record API Assignment's remaining Entry Criteria, including a separate implementation authorization, fresh exact KeyboardCore production/test identities and exclusive writer ownership before code changes.
2. Implement and review the v4-capable writer without Extension call sites, app installation or runtime emission, within the accepted contract and a separately authorized Assignment.
3. Create and authorize a separate paired-build rollout Assignment for Extension call sites and enablement after the v4 reader/writer compatibility gate is satisfied; bind its roles and evidence to one exact Main App + Extension build.

## Related Documents

- [PD-KEYBOARD-WAKE-DIAGNOSTIC-V4-WRITER-001](../../product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-V4-WRITER-001-authorization.md)
- [Schema Proposal 0.4](../../plans/keyboard-wake-diagnostic-event-schema-proposal-001.md)
- [Runtime Record API Assignment](../../assignments/keyboard-wake-diagnostic-runtime-record-api-001.md)
- [Extension Producer Assignment](../../assignments/keyboard-wake-diagnostic-extension-producer-001.md)
- [ADR 0027 — Enterprise Local Diagnostic Observability](0027-enterprise-local-diagnostic-observability.md)
- [ADR 0028 — Diagnostics Calendar Query and Bounded Preview](0028-diagnostics-calendar-query-and-bounded-preview.md)
- [ADR 0036 conditional acceptance decision](../../product-decisions/ADR-0036-ACCEPT-authorization.md)
