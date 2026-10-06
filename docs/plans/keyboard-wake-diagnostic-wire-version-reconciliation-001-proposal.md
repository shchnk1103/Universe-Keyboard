# Wire-Version Reconciliation 001 — decision candidate

> **Status:** Draft for independent Architecture and Quality review. This is a recommendation, not an accepted wire contract, ADR amendment, implementation authorization, production marker authorization, Gate, or Release decision.
>
> **Assignment:** [KEYBOARD-WAKE-DIAGNOSTIC-WIRE-VERSION-RECONCILIATION-001](../assignments/keyboard-wake-diagnostic-wire-version-reconciliation-001.md)
>
> **Reviewed scope SHA-256:** `edf450b3dbfbe621849d0fbf6bc641518cbc22e992fde6239034d05d2e7729c6`
>
> **Frozen Entry identity packet SHA-256:** `3a0a27291fe653daf02191622fa1392522d17b648bd5cdf74e5f13155000179b`
>
> **Baseline:** `84b9c19227330b0fe6ff391be001ee398010fd6a`; current uncommitted candidate in `/Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard`.

## Decision question

The reviewed Extension compatibility candidate has a single schema-v5 writer and existing v5-only `typo_recall` events. Proposal 0.4 assigns the three new keyboard-wake marker families to wire v4. Under ADR 0036, a writer build labels every newly persisted event with one static version. The paired rollout therefore cannot switch only its marker calls to v4 while continuing to write existing `typo_recall` events as v5.

This candidate compares the two bounded paths allowed by the Assignment: extend the v5 contract to include the markers, or use a forward wire version. It recommends v6 for a later marker-enabled paired build and keeps the reviewed v5 candidate producer-off until that decision and a new exact implementation scope are accepted.

## Frozen facts

- ADR 0036 is **Accepted (Conditional)**. A writer build uses one static wire version for every new event it writes; retained history is never rewritten; v4-only data is not downgraded; mixed retained versions require a version-aware reader. The same-build Extension v4 producer gate remains separate.
- Proposal 0.4 is Product-accepted as a document-only design. It proposes v4 for the new marker codes and payloads, says wire-contract changes are handled by `schemaVersion`, and does not authorize implementation or production emission.
- The reviewed v3 compatibility-gate manifest r2 is a local, uncommitted seven-file candidate. It declares reader versions 3/4/5, writer version 5, no production v4 marker emission, and isolated-only storage for v4 marker fixtures.
- The candidate `DiagnosticEvent` sets `schemaVersion = 5`, treats the wake-marker codes/payloads as v4-only reader data, treats `typo_recall` codes/fields as v5-only, and its writer boundary accepts only v5-writable events. The candidate reader accepts v3/v4/v5. The manifest and Entry packet bind the exact file identities.
- The current candidate Main App source carries journal incompleteness into its source-selection decision. Only a known-complete successful empty v1 journal permits legacy fallback; an unsupported/incomplete result stays on the v1 source and shows a bounded incomplete notice.
- The separately reviewed Runtime Record API manifest is historical input from baseline `9eb83158e49218c1e8f75dbe7dd9e0390db81409`; it is not part of manifest r2 and is not proof of integration with the current v5 candidate.
- The frozen records do not establish that the uncommitted schema-v5 candidate has never been privately built or installed. Treat its candidate state as local and unmerged; do not infer deployment history beyond the recorded evidence.

## Governing invariants

1. Keep the `Diagnostics/v1` directory layout, journal ownership, retention, locks, privacy fields, capture gates, and bounded asynchronous ingress unchanged.
2. One writer build emits every newly persisted event with its one declared wire version, including older event codes. Do not select a version per event code or payload.
3. Never relabel or rewrite retained v3, v4, or v5 records. A reader validates each record against its own version.
4. A v4 marker fixture remains isolated to temporary or in-memory test storage. No production App Group, `DiagnosticsJournalRuntime`, or real Extension ingress is used for fixtures.
5. Unsupported, unknown, malformed, or rejected records remain visible as bounded incomplete/unsupported state. Continue scanning valid neighboring records; never turn rejection into a normal complete-empty result or permit legacy fallback for incomplete data.
6. Keep production marker emission off until one explicitly authorized and reviewed Main App + Keyboard Extension build contains the selected writer and reader, strict version/code/payload/raw-key validation, controlled incomplete propagation, and legacy-fallback suppression.
7. Keep all diagnostics content-free and at the already reviewed callback/call boundaries. No root cause or typing behavior conclusion follows from this contract.

## Options

### Option A — finalize schema v5 with the new marker families

All events from the future build, including existing `typo_recall` events and the three marker families, would be written as v5. The paired reader would validate those marker codes/payloads as part of v5 and continue to read retained v3/v4/v5 history.

**Benefits:** one fewer wire-version family and no v6 reader path; the candidate's current v5 writer number can remain.

**Conditions and costs:** this changes Proposal 0.4's accepted document-only rule that adding a code or payload changes the wire contract handled by `schemaVersion`. Architecture and Product must explicitly supersede or amend that design and define why these marker additions belong to v5. The reader, raw-key validator, tests, and producer manifest still need a new exact candidate and review. Older v5 readers that do not know the new marker codes cannot be assumed safe; the same-build pairing gate and incomplete/fallback behavior remain mandatory. Current records do not prove there are no privately deployed v5 readers or journals.

This option is technically possible only as an explicit new Product/Architecture contract. It is not authorized by Proposal 0.4, ADR 0036, or the reviewed v3 compatibility candidate.

### Option B — introduce wire v6 for a later marker-enabled build (recommended)

The new paired build would declare wire v6 and write **all** new events from that build as v6, including existing event codes and `typo_recall`, plus the three wake-marker families. The v6 reader would explicitly read and validate retained v3, v4, v5, and v6 records by each record's own version.

**Benefits:** preserves the version-per-contract meaning from Proposal 0.4, avoids silently broadening v5, and makes the mixed-history reader obligation explicit. Retained v5 `typo_recall` records remain v5; new events from the v6 build use v6 without changing their diagnostic meaning.

**Costs and conditions:** the writer, KeyboardCore reader, Main App consumer, tests, Extension emitter, and paired-build evidence need a fresh, exact v6 candidate. A v3/v4/v5 reader cannot claim complete compatibility with v6 records. The existing v5 compatibility candidate must not be edited or retroactively called a v6 candidate; a new authorization, ownership check, source/test freeze, and same-build promotion review are required.

## Recommended contract candidate

Subject to Architecture review and an exact-candidate Human Product Owner disposition:

1. Reserve `schemaVersion = 6` for the future marker-enabled writer build.
2. That build writes all newly persisted events as v6, including pre-existing event codes and the v5-only `typo_recall` family. No per-code v4/v5/v6 production mixture is permitted.
3. The v6 reader accepts valid records with versions 3, 4, 5, and 6, validates each against its version-specific closed code/payload/field allowlist, and preserves query-wide completeness across paging. The v6 allowlist must accept the existing `typo_recall` code/payload family when newly written with version 6, while still reading retained v5 records as v5. It must likewise accept the wake-marker code/payload family both as retained v4 history and as new v6 records. These rules do not permit a v6 writer to emit any v4- or v5-labeled event.
4. Retained v3/v4/v5 records retain their original bytes and version. A v6 reader never rewrites them during reading or migration.
5. Invalid, non-integer, unsupported, or future `schemaVersion > 6`, unknown code/key/value, malformed payload, or invalid pairing records are rejected as bounded incomplete/unsupported. Valid neighboring records remain available. Incomplete results suppress legacy fallback and are displayed without raw unknown data.
6. The existing v5 compatibility candidate remains writer-v5 and production-marker-off. Its seven-file manifest, validation, and reviews do not satisfy v6 implementation or promotion evidence.
7. v4 wake-marker records may remain readable as historical/fixture records. Any test fixture is isolated from production storage and ingress.
8. The paired v6 producer may be enabled only in a separately authorized exact build whose Main App and Keyboard Extension source, app/extension bundle and executable identities are bound together and whose reader/fallback matrix is reviewed.

## Reader/writer compatibility matrix

`Complete` means the reader recognizes every record under the stated input and the source can be reported complete. An older reader is not declared compatible merely because a known event happens to decode.

| Retained or newly written record history | v3 reader | v4 reader | v5 reader | future v6 reader |
|---|---|---|---|---|
| v3 records only | Complete for its v3 contract | Reads v3 | Reads v3 | Reads v3 |
| v4 records only, including a valid v4 marker fixture/history record | Cannot establish v4 absence or full completeness | Reads v4 | Reads v4 | Reads v4 |
| v5 records only, including `typo_recall` | Cannot establish v5-only code/field completeness | Cannot establish v5-only code/field completeness | Reads v5 | Reads v5 |
| v6 records only, including v6 `typo_recall` and v6 wake markers | Unsupported; never use output to claim absence | Unsupported; never use output to claim absence | Unsupported; the current v5 candidate reports unknown versions incomplete and suppresses fallback, but older builds are not covered by this candidate | Reads v6 |
| mixed retained v3/v4/v5/v6 records | Cannot claim complete history | Cannot claim complete history | Cannot claim complete history once v6 is present | Reads each version in place; no rewriting |
| malformed/unknown/future version or rejected code/key/payload in a v6 reader | Not established | Not established | Not established for all deployed v5 readers | Reject record, continue valid lines, report incomplete/unsupported, suppress legacy fallback |

The matrix does not promise safe handling by an arbitrary old installed reader. The promotion gate requires a same-build reader and writer; records encountered by older builds remain outside the producer-compatibility claim.

## Reader and promotion evidence required later

No validation is run under this document-only Assignment. A separate implementation Assignment must define and prove at least:

- Each version's allowed event codes, payload wrappers, field/value enums, and version-specific pairings, including v5 `typo_recall` read under v6 writer output.
- Explicit v6 validation for `typo_recall` records labeled v6 and wake-marker records labeled v6, plus retained v5 `typo_recall` and v4 marker fixtures/history. The current candidate validator gates the marker family to v4 and the typo-recall family to v5, so a v6 implementation must consciously expand those version-specific allowlists without enabling per-code version mixing.
- Retained v3, v4, and v5 history; v6 old-code and marker records; mixed v3/v4/v5/v6 history; unknown future versions; non-integer and malformed versions; unknown code/key/value; malformed payload; and code/payload mismatch.
- Incomplete status through `latest`, `beginPage`, `recentPreview`, and cursor-bearing `nextPage`, including rejected-only root reads and query-wide incompleteness.
- Main App source selection: only known-complete successful empty v1 may use legacy fallback; incomplete/unsupported data must remain on the v1 source and show bounded status. Add explicit source-selection coverage for v6-only unknown-version history and mixed valid v5/v6 history (both with legacy fallback data present), as well as unknown raw keys/malformed payloads. Existing current-candidate fallback coverage includes unknown code, but does not by itself prove these v6 cases.
- Isolated temporary/in-memory fixtures only; no real App Group mutation for fixture generation.
- Bounded asynchronous submission, no synchronous persistence on the keyboard hot path, strict Swift formatting, full CI-equivalent target coverage for every changed target, and independent exact-candidate Architecture and Quality review.
- Same-build Main App + Extension source manifest, build settings, bundle/version/build identifiers, executable hashes, validation result bundles, and fresh exclusive Simulator reservation before any Simulator validation. Manual Maps reproduction stays with the Human Product Owner under the separately authorized promotion Assignment.

## Proposed handoff sequence

1. Architecture and Quality review this exact candidate and its frozen input identities. Record all conditions and residual dispositions.
2. Human Product Owner decides whether to accept the v6 recommendation, choose the explicitly superseding v5 route, or retain producer-off status. No option is accepted by the existence of this draft or a review pass.
3. Only after an exact Product disposition, record the accepted ADR 0036 addendum/successor decision and update the paired-rollout Assignment's version sequence and compatibility gate. Rebind all roles and scope ACKs affected by the version change.
4. Keep the parent lifecycle Assignment Active and the paired rollout held until the new implementation Assignment satisfies its exact Entry criteria, source ownership, and fresh exclusive Simulator reservation. A new implementation authorization is required; this document does not consume or extend the earlier v4 authorization.
5. After any future reviewed and installed v6 promotion candidate exists, request the previously accepted one-time Human Product Owner Maps App Switcher reproduction. This reconciliation itself performs no manual or Simulator action.

## Exact input identities and review boundary

The full Entry identity table is in the [frozen identity packet](../evidence/keyboard-wake-diagnostic-wire-version-reconciliation-001-entry-identity-2026-09-30.md). The identity packet was revalidated after the recorded Active status-only transition: 20 other required documents, 17 current source/test files, 3 scope-review records, and all 7 v3 manifest-r2 files matched; no mismatch was found.

| Input | Frozen SHA-256 / identity |
|---|---|
| Proposal 0.4 | `e501a4075c24a79de560e7381ae361708c1a085250470e69840e23c930b53c06` |
| ADR 0036 accepted file | `f950e4ee62c643efb21308cd7d633844379cb373fcde2e3e5604e5988fe5959c` |
| ADR 0036 acceptance decision | `3926918c0ae5f7aa0704f1696d75bbd32dfc1b32fd0895225bc49bcd9dc5035d` |
| M-06 writer-version brief | `ce5a729365deaf5775c96f91678586635e42dd5a851754e2b77aaf81ea2a7ae3` |
| v3 compatibility-gate Assignment | `2f8e39530d867f263d80e8d9cc51891bdd4af286603f75336e436feee706cda7` |
| v3 compatibility-gate manifest r2 | `c75a75bd8ed180149a7bc8cb6c26a5fa5e4f5cbec122eede980f73a4d8cef835` |
| Paired-rollout Assignment | `ef5a81d996f913fa69d61d0c3f70d591b1c25b155d1d9d3b5917f547578abd6e` |
| Paired-rollout pre-edit Entry receipt | `06cad80f247032cfc5711110daf2470deab7c29725e19492df1385da5c2b73e0` |
| Runtime Record API Assignment (historical predecessor only) | `a3e2d1c6bd5dd61d622cbd1505b1b012983be72c038d54941659bda103ee5d69` |
| Runtime Record API ten-file manifest (historical, older baseline) | `abbe6154d52b5b4e23fcde32cea455f2de93d9a3a56356ef77e12486217f975c` |

Relevant frozen source identities include `DiagnosticEvent.swift` `346efd59225cdf71fc61917fcb26bc72f3b1cf84aea19d873b3f238e791b492b`, `DiagnosticsJournal.swift` `49077a7a6ade1b41724fda92314cb4a41071163dc9f6c5e2a8666ee38273dbc9`, `DiagnosticEventWireValidator.swift` `965667328c2db1cba4c4f99e21a82ee13ae3890ff18bf510b9967c5396273534`, `DiagnosticsLogSource.swift` `bc874c7f019645e18c04b8b2c3a9d21c8247afc75b44cc8951a857078d558a70`, and `TypoCorrectionRecallCoordinator.swift` `db5cd320abad9bae0a170e9514818308d1c669b7b65d12f2c47954681a101a42`. The complete current and baseline source/test identity table remains the Entry packet's authority.

## Non-claims

- No wire version has been selected or adopted; v6 is a recommendation awaiting Architecture, Quality, and Human Product Owner disposition.
- No ADR, Proposal 0.4, v3 compatibility-gate Assignment, or paired-rollout Assignment has been amended by this draft.
- No source/test file, implementation, build, Simulator, installation, App Group, marker emission, manual Maps reproduction, root-cause finding, Product/Quality Gate, Release, commit, push, PR, merge, or parent closure is claimed.
- The reviewed v3 compatibility candidate remains local and uncommitted; its prior validation does not validate a future v6 candidate.
