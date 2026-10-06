# KEYBOARD-WAKE-DIAGNOSTIC-EVENT-SCHEMA-001 — Schema Proposal 0.4

> **Status:** Product-accepted as a document-only schema design on 2026-09-28 Asia/Shanghai; Domain Owner acknowledged, Architecture Pass, Quality acknowledged with conditions. This is not an implementation contract, Accepted ADR, or code authorization.
>
> **Assignment:** [KEYBOARD-WAKE-DIAGNOSTIC-EVENT-SCHEMA-001](../assignments/keyboard-wake-diagnostic-event-schema-001.md)
>
> **Proposal date:** 2026-09-27 Asia/Shanghai
>
> **Source identity:** baseline `9eb83158e49218c1e8f75dbe7dd9e0390db81409`; `DiagnosticEvent.swift` SHA-256 `1bd22fde04849e6a5f85ebc2750e80b7888931a3dc9a9e59c1aef3376ead3613`; `DiagnosticsJournal.swift` SHA-256 `9c999e18645573da1519d0f84be0f83152e800a41b109783b5730788f7a4f005`.

## Goal and boundary

Define the smallest content-free event contract that can distinguish keyboard Extension visibility transitions, RIME resume/readiness progress, and calls crossing the `UITextDocumentProxy` adapter during a later App Switcher reproduction. This proposal does not change Swift, tests, builds, simulator state, event emitters, the Main App reader, or ADR 0027.

The current user-observed failure and source-only findings remain in the [lifecycle Assignment](../assignments/keyboard-wake-lifecycle-diagnostics-001.md) and its [evidence report](../evidence/keyboard-wake-lifecycle-diagnostics-2026-09-27.md). This proposal does not establish a root cause or prove host text insertion.

## Version decision proposed

There are three distinct version concepts: `Diagnostics/v1` is the journal directory/layout; `DiagnosticEvent.schemaVersion` is the event wire version currently at 3; payloads have no separate version in this proposal. A payload shape or code change changes the event wire contract and must be handled under `schemaVersion`.

Recommend `DiagnosticEvent.schemaVersion = 4` for the future typed payloads and codes. The Human Product Owner accepted this recommendation as part of the document-only design; it is not an accepted ADR decision or implementation contract. Do not introduce a new payload-only version number.

Rationale: event codes are a closed persisted enum; adding new raw values and payload shapes changes the durable event protocol. The current `DiagnosticEvent.schemaVersion` is a static value copied into every event, so a future implementation would label all events written by that build as version 4, including pre-existing event codes. The Architecture review passed this recommendation, but no ADR has been accepted.

### Reader/writer compatibility matrix

| Writer | Reader | Proposed behavior | Current baseline behavior / limitation |
|---|---|---|---|
| v3 | v3 | Supported. | Current supported path. |
| v3 | v4 | v4 reader continues to read retained v3 events. | Current decoder reads the integer version but does not validate it; known v3 codes/payloads decode. Future implementation should make support explicit. |
| v4 build, existing v3 code | v3 | v3 reader is unsupported for v4 records; do not use its output to infer event absence. | Since the version is not checked, a known code may still decode. |
| v4 new code/payload | v3 | Unsupported. Pair producer/reader rollout; keep v4 producer disabled until the reader reports incomplete/unsupported data without legacy fallback. | Unknown `Code` raw values fail decoding; `try?`/`compactMap` drops the JSONL line. The reader can then report an empty v1 result and fall back to stale legacy `rime_diag_log`, masking the unsupported events. |
| v4, old and new codes | v4 | Supported only after future implementation adds explicit v3/v4 decoding, exact code/payload validation, and controlled incomplete status. | Not implemented or validated by this proposal. |
| mixed v3/v4 writers in one retained history | v4 | Proposed v4 reader explicitly accepts both versions and validates each event against its own version. Unknown/invalid events mark the source incomplete while scanning continues. | Not implemented or validated by this proposal. |
| invalid version (non-integer, `<3`) or future unknown version (`>4`) | v4 | Reject the event, continue scanning other lines, and return controlled incomplete/unsupported status; never present the source as a normal empty journal. | Current decoder only requires an integer and does not validate supported values. |

Keep Extension production at v3 until a future v4 rollout gate is satisfied. V4 may be enabled only when one installed Main App + Keyboard Extension build has a verifiable shared source/build identity and includes all of the following: explicit v3/v4 reader support; exact event/payload and strict wire-key validation; a controlled incomplete/unsupported status when any record is rejected; suppression of legacy fallback in that status; and implementation evidence covering v3 history, mixed v3/v4 history, unknown version/code/key, and malformed payload. Sharing a source package alone is not sufficient; the installed binaries must be traceable to the same build candidate. Until that gate is independently authorized and evidenced, the producer remains v3.

The future KeyboardCore reader must return a controlled incomplete/unsupported status if any event is skipped for an unknown version/code, unknown enum, unknown raw key or malformed payload. The Main App source selector must not treat that result as a normal empty v1 journal and must not fall back to stale legacy `rime_diag_log`; it should show a bounded unsupported/incomplete status without exposing unknown content. Input Intelligence owns event version/payload decoding and per-line skip semantics in KeyboardCore; App & Data Operations owns Main App query, formatter, source selection and user-visible fallback/status behavior. Both require a separate implementation Assignment if changed. The current baseline is not explicitly version-aware.

## Event and payload allowlist

Each family gets a new code and a dedicated typed payload; do not reuse a v3 code with a new payload. The code requires exactly its matching payload and an empty generic `fields` array; all other composite payloads must be absent. No family accepts an open-ended dictionary or arbitrary string. Suggested wire codes and finite values:

| Code | Payload wrapper and exact member keys | Category / level / capture gate | Allowed values / constraints | Diagnostic question answered |
|---|---|---|---|---|
| `keyboard.lifecycle.phase_changed` | `keyboardLifecyclePayload { phase }` | `.display` / `.debug`; diagnostics logging and active Debug high-fidelity window required | `view_will_appear`, `view_did_appear`, `view_will_disappear`, `host_will_resign_active`, `host_did_become_active` | Did the Extension and host lifecycle boundary run around the failure? |
| `rime.resume.phase_changed` | `rimeResumePayload { phase, failure?, sessionEpoch?, revision? }` | `.engine` / `.debug`; diagnostics logging and active Debug high-fidelity window required | Phases: `started`, `session_created`, `schema_selected`, `owner_ready`, `completed`, `failed`. Failure is required only for `failed`, absent otherwise. | Did resume start, produce a usable session/schema, publish readiness, complete, or fail? |
| `text_proxy.operation_phase_changed` | `textProxyPayload { operation, phase }` | `.display` / `.debug`; diagnostics logging and active Debug high-fidelity window required | Operations: `set_marked_text`, `insert_text`, `unmark_text`; phases: `entered`, `returned`. | Did the adapter enter and return from a host proxy call? |

Finite `RimeResumeFailure` proposal: `engine_unavailable`, `session_creation_failed`, `schema_selection_failed`, `owner_not_ready`. There is no `other` bucket. Do not attach `NSError`, `localizedDescription`, exception text, schema name, path, or free-form detail. If a failure does not map to a listed stable boundary, do not emit a `phase == failed` event with missing `failure`; omit that resume event and report only a bounded drop/unavailable summary if the existing health contract supports it.

Wire-key contract proposal:

- Existing envelope keys remain the only common top-level keys: `schemaVersion`, `utcTimestamp`, `monotonicNanoseconds`, `origin`, `processInstanceID`, `localSequence`, optional `appearanceID`, optional `actionSequence`, `code`, `level`, `category`, and `fields`.
- Lifecycle event: `keyboardLifecyclePayload` has exactly required key `phase`.
- RIME resume event: `rimeResumePayload` requires `phase`; `failure`, `sessionEpoch`, and `revision` are optional and omitted when unavailable. `failure` must be present exactly when `phase == failed`.
- Proxy event: `textProxyPayload` has exactly required keys `operation` and `phase`.
- For every new event, `fields` is encoded as `[]`; its values must not repeat `sessionEpoch` or `revision`. Exactly one matching new payload key is present; the other new and existing composite payload keys are absent.
- Normative proposed reader rule: reject a v4 event with any unknown top-level raw JSON key, unknown field enum, unknown payload key/value, invalid pairing, or multiple payload wrappers; mark the source incomplete, continue scanning valid events, suppress legacy fallback, and never display raw unknown data. Implement explicit raw-key inspection; do not rely on `Codable`'s default unknown-key handling. Current code does not implement these checks.
- Duplicate literal JSON member names are invalid writer output. A future decoder must detect and reject them or its implementation Assignment must explicitly document that the selected parser cannot detect them; never claim detection without evidence.

`owner_ready` means only that the Extension's typed owner/readiness predicate was true at that point. It does not assert that a candidate was visibly rendered. `completed` means the bounded resume sequence returned to its caller without a classified failure; it does not establish subsequent input acceptance. `host_did_become_active` means an Extension emitter observed that callback; it is not proof of system-wide activation. The baseline has no corresponding host-active observer, so an absent event cannot prove that activation did not occur.

## Correlation and bounds

- Preserve the existing envelope identity: `origin`, `processInstanceID`, `localSequence`, `appearanceID?`, and `actionSequence?`. New event families are Extension-origin events. `processInstanceID` and `localSequence` remain required by the existing event envelope.
- `appearanceID` is included when the event belongs to an active keyboard presentation; absence must not be interpreted as proof that no presentation existed. Lifecycle emission must bind the same presentation identity according to the final Keyboard Experience handoff.
- `actionSequence` is included only when the proxy call can be causally attributed to the existing input action. Do not invent a second operation UUID or persist a text/context hash.
- `sessionEpoch` and `revision` appear only in the RIME typed payload, never also in generic `fields`. Each is an optional `UInt64` in `0...UInt64.max`, intentionally reusing the existing KeyboardCore counter type as the upper bound; no smaller business maximum is proposed. `nil` means the emitting boundary did not provide a value. Zero is valid only where the owning counter contract defines zero as a real initial value, never as a substitute for unavailable data. Do not clamp, wrap, or convert counters to strings; an overflow/unrepresentable value prevents emitting that counter-bearing event.
- This proposal adds no duration, text-length, selection-range, candidate-count, coordinates, or extra count metrics. Existing `monotonicNanoseconds` and `localSequence` provide local ordering; cross-process ordering remains approximate.
- Field presence and valid event/payload pairings are closed by payload type. A future decoder must reject unknown enum raw values, missing required fields, invalid failure/phase combinations, unrelated payloads, multiple payload wrappers, and privacy-disallowed keys. It must not claim rejection behavior until separately implemented and tested.
- The baseline's `CodingKeys` allowlist controls known properties, but the current decoder does not explicitly reject every unknown top-level JSON key. Future implementation must add and test strict raw-key validation; until that is present in the paired reader, the v4 producer must remain disabled. A `CodingKeys` enum alone is not strict rejection. Writer output must contain only the explicitly approved keys above and the existing envelope keys.

## Privacy, capture and hot-path constraints

Never persist input text, candidate text, marked text, host text, `documentContext` before/after, coordinates, text length, selection range, schema names, filesystem paths, URLs, arbitrary errors, or free-form strings. Do not hash or redact such content as a substitute for excluding it.

All proposed events are Debug high-fidelity observations and are eligible only while the existing diagnostics logging switch, the event's category switch, and the unexpired 30-minute high-fidelity window permit capture. All three use `.debug` level and are equally low-priority under bounded overload; the existing overload policy may drop them, which makes absence non-conclusive. The future emitter may only submit typed value data to the existing bounded asynchronous ingress. The writer must reject/drop invalid values without throwing into or changing keyboard input. It must not JSON-encode, format dates, query `UserDefaults`, access files, wait, or perform synchronous persistence in the key/proxy path. This proposal makes no performance pass claim; the parent Keyboard Experience Assignment owns later emission-path validation.

The proposal does not add a journal root, generation, retention rule, lock, writer, Main App formatter, reader behavior, or error surface. An event missing from reader output can mean no callback, disabled/expired capture, dropped ingress, process termination before flush, unsupported old reader, or another observation gap; absence is not a root-cause finding.

## ADR 0027 disposition

If the implementation stays within the existing versioned typed-event envelope, reviewed allowlists, user-enabled Debug high-fidelity gate and bounded asynchronous ingress, this proposal recommends **no ADR 0027 change**. Changes to privacy fields, unknown-event handling, Main App fallback/read behavior, default capture gates, journal root/generation, retention or persistence semantics require a separate Architecture/Product Assignment. This proposal itself changes no ADR.

## Ownership and follow-up

| Concern | Owner / boundary |
|---|---|
| Typed event contract, schema-version/payload decoding and per-line unsupported/incomplete signal in `KeyboardCore` | Input Intelligence Maintainer; future implementation needs a separate Assignment. |
| Extension lifecycle, RIME readiness and proxy emission points | Keyboard Experience Maintainer under the parent lifecycle Assignment. |
| Main App query, formatter, source selection, legacy fallback suppression and user-visible unsupported/incomplete status | App & Data Operations Maintainer under a separate Assignment if behavior changes. |
| RIME bridge/session behavior | RIME Platform Maintainer only if evidence or required fields cross that boundary; not in this proposal. |
| Privacy, compatibility, and architecture review | Architecture & Knowledge Steward. |
| Proposal completeness/evidence boundary | Quality, Performance & Release Maintainer; no tests or Quality Gate in this Assignment. |

Any future schema implementation Assignment must name the source/test files and all affected reader ownership. Its Exit Criteria must include the full `swift test --package-path Packages/KeyboardCore` command, strict Swift formatting for changed files, exact source/toolchain/test evidence, and independent Quality review. That future work requires a new explicit Product authorization.

## Review state

The Domain Owner, Architecture, Quality and Keyboard Experience acknowledged the narrowed document-only Assignment boundary. Proposal 0.4 incorporates the review conditions from 0.1–0.3, including mandatory strict raw-key validation. Domain Owner review is **Acknowledged**, Architecture review is **Pass**, and Quality review is **Acknowledged with conditions** against design-content SHA-256 `d4e0be99907b3f3846f32434da913393202a9654925c29538e028050e78aed57`. On 2026-09-28 Asia/Shanghai, the Human Product Owner accepted this document-only design, bound to the exact pre-disposition complete-file SHA-256 `c20038a8c33acd9ce777eb6b1fe0ea72d0076bcbcaa82e6aaec9293ac9b75774` and the reviewed design-content SHA above. This accepts the proposal as a design deliverable only; it does not adopt a production schema contract or ADR, or authorize implementation, tests, builds, or runtime work. The v4 reader/writer rollout and strict parser requirements remain future implementation conditions.

On 2026-09-28 Asia/Shanghai, the pre-disposition complete-file digest transcription was corrected to the 64-character value above against the previously recorded `shasum -a 256` output. This is an identity-metadata correction; proposal content, review conclusions and Product disposition are unchanged.

No source code, tests, builds, simulator/device state, raw diagnostic JSONL, or user text was accessed or changed for this proposal beyond the previously authorized read-only baseline inspection.
