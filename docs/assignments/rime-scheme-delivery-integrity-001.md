# Assignment: RIME-SCHEME-DELIVERY-INTEGRITY-001 — Integrity Failure Diagnostics And Verified Source Recovery

**Policy version:** `1.0.0`
**Parent:** [`RIME-SCHEME-DELIVERY-001`](rime-scheme-delivery-001.md)

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Closed` |
| **Phase** | Human Product Gate Passed；PR #83 merged `e9aea57`；empty stored zip entries extracted |
| **Non-claims** | Not TestFlight; not GitHub-source proof |
| **Next** | None for this Assignment |
| **Residuals** | [`implementation evidence`](../evidence/rime-scheme-delivery-integrity-implementation-2026-08-26.md) · [`Entry design`](rime-scheme-delivery-integrity-001-entry-design.md) · [`Architecture pre-review and ADR re-review`](rime-scheme-delivery-integrity-001-architecture-review.md) · [`accepted ADR 0032`](../architecture/decisions/0032-verified-scheme-source-recovery-and-integrity-classification.md) · [`failure evidence`](../evidence/rime-scheme-delivery-wanxiang-integrity-failure-2026-08-26.md) |

---

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human Product Owner in the active Codex task,
  `2026-08-26 Asia/Shanghai`, accepted recording the Wanxiang failure as a PR
  #83 Review blocker and creation of this minimum remediation Assignment; then
  accepted the detailed internal-state taxonomy, restrained user-facing states
  and content-free structured local diagnostics. Independent Architecture
  pre-review and ADR re-review subsequently returned `Pass with conditions` and
  authorized ADR 0032 acceptance before production implementation starts.
- **Product Approver:** Human Product Owner acting as Product Lead

## Boundary

- **Scope:** distinguish archive-size, archive-SHA-256 and guarded staged-content
  failures; add content-free diagnostics and accurate Simplified Chinese
  recovery text; after deleting a failed temporary archive, permit the next
  independently pinned source variant to be attempted only for archive-level
  integrity failure; add regression tests and update affected delivery evidence.
- **Non-goals:** no integrity weakening; no installation of any mismatching
  artifact—the final selected source must pass complete archive and
  staged-content verification before installation; no cross-source recovery
  after staged-content mismatch; no mutable `latest`
  asset, source/version/hash change, blind proxy, Universe server/CDN, update
  discovery, TD-001 atomic-install work, Keyboard Extension networking, push,
  merge, TestFlight distribution or Release acceptance.
- **Required Inputs:** parent
  [`Assignment`](rime-scheme-delivery-001.md), source-variant
  [`Product Decision`](../product-decisions/RIME-SCHEME-DELIVERY-001-source-variants.md),
  current implementation/evidence, the physical-device failure snapshot, and a
  frozen clean implementation base before code starts.

## Assignment

- **Domain Owner:** Main App UI — scheme download/install/deploy orchestration.
- **Executor:** Current Codex task, only after a separate explicit authorization
  to implement this Assignment.
- **Environment Executor:** Current Codex task — local static analysis,
  automated tests, Simulator builds and public-endpoint artifact verification.
- **Human Dependency:** Human Product Owner — provide a later Mainland
  physical-device retry using the remediated exact build and make the final
  Product Gate decision. Previously omitted device/build facts remain honestly
  unavailable rather than inferred.
- **Architecture Reviewer:** Independent AI subagent `architecture_review` —
  review trust root, fallback boundary, diagnostic privacy and whether an ADR
  amendment is required; no implementation edits.
- **Quality Reviewer:** Independent AI subagent `quality_review` — independently
  review failure injection, cancellation, cleanup, localization and final
  evidence; no implementation edits.
- **Handoff Target:** Human Product Owner after Architecture and Quality review,
  with the exact-build Mainland device result for Product Gate.

## Remediation Contract To Review

ADR 0032 is the durable Architecture Source of Truth. This section is only the
bounded execution summary for this Assignment and must not independently evolve
the long-term contract.

1. Preserve the compiled manifest as the trust root. Every attempted source
   retains its own exact version/revision, byte count, archive SHA-256 and
   redirect-host allowlist.
2. Classify integrity failures internally as `archiveSize`, `archiveDigest` or
   `stagedContent`; do not collapse their diagnostics into one unobservable
   branch.
3. An `archiveSize` or `archiveDigest` failure deletes the downloaded temporary
   artifact through a throwing or explicit-result cleanup barrier and verifies
   that the exact operation/source artifact is absent before another source is
   considered. Cleanup failure stops fallback. The next source is eligible only
   when the manifest explicitly binds it to the same accepted staged-content
   identity.
4. A `stagedContent` mismatch always stops the operation. It must not silently
   try another source because it may identify client post-processing, allowlist
   or manifest drift rather than a damaged transport artifact.
5. Failure diagnostics may contain operation ID, scheme/version, source ID,
   phase, expected/actual byte count and digest prefixes. They must not contain
   typed content, credentials, sensitive query values or complete local paths.
6. User-facing text identifies the recovery category and action without
   exposing raw system descriptions or full digests.
7. A successful installed-source/version/checksum receipt remains writable only
   after installation and deployment succeed. Failed attempts cannot overwrite
   the last successful receipt.
8. Source equivalence is represented by an immutable staged identity descriptor,
   not inferred from scheme/version or array membership. The full identity binds
   Lua-on/off staged digests, installation-plan revision and deterministic
   post-processing revision.

## State And Diagnostics Contract To Review

### Internal operation phases

The internal state model must distinguish enough phases to make recovery and
diagnosis deterministic:

1. source selection and bounded source probing;
2. archive download;
3. archive-size verification;
4. archive-SHA-256 verification;
5. extraction;
6. deterministic compatibility/post-processing;
7. guarded staged-content verification;
8. installation;
9. RIME deployment;
10. completion, cancellation or classified failure.

The implementation may use nested or associated-value states, but it must not
collapse `archiveSize`, `archiveDigest` and `stagedContent` into one internal
failure identity. State transitions must remain MainActor-owned where they feed
SwiftUI; hashing, file reads and extraction must not be moved onto the main
thread. `SchemaManager` remains the sole owner of fallback decisions and receipt
commit. Background workers receive immutable `Sendable` value snapshots and
must not capture MainActor-isolated `self`; cancellation and operation generation
are revalidated after suspension before every state transition or side effect.

### Restrained user-facing states

Normal UI feedback remains intentionally coarser than internal state:

- selecting a download source;
- downloading through the selected named source;
- verifying downloaded content;
- preparing the input scheme;
- deploying RIME;
- completion.

When archive-level verification triggers a safe fallback, the UI may state that
the current source failed verification and a backup source is being attempted.
It must not expose full digests, raw enum names or raw system descriptions.
Terminal copy distinguishes incomplete archive, archive security verification,
post-extraction content verification and all-sources-unavailable recovery.

### Structured local diagnostics

Write transition-level typed `DiagnosticEvent` records through ADR 0027's
bounded asynchronous `DiagnosticsJournalRuntime`, rather than legacy free-form
`Logger` strings or progress-percentage events. Each operation uses a random
correlation ID. Allowed fields are limited to:

- operation ID;
- scheme ID and immutable version;
- source ID and sanitized final host;
- phase, transition/result and fallback reason;
- expected/actual byte count;
- short expected/actual digest prefixes used only for diagnosis;
- HTTP status plus system error domain/code;
- bounded phase duration;
- Lua-availability boolean;
- install/deploy success flags.

Host/error/digest fields require reviewed finite value types or explicit
length/character constraints; a generic string field must not bypass the
allowlist. The full digest remains mandatory for verification but is not required in the
diagnostic event. Digest prefixes are diagnostic correlation only and must never
be accepted as integrity evidence. Events must not contain typed content,
candidates, credentials, cookies/tokens, URL query values, IP address, carrier,
SSID, precise location or complete local paths. Logging must be asynchronous and
must not write one event for every progress callback. Diagnostics respect the
existing switch; disabled/unavailable/overloaded journal states may reduce
observability but cannot change business behavior.

## Architecture Residuals

| ID | Owner | Disposition | Entry closure |
|---|---|---|---|
| `AR-RSDI-P1-01` | Main App UI | `closed` | Truthful cleanup outcomes and injected deletion-failure evidence complete |
| `AR-RSDI-P1-02` | Main App UI | `closed` | Manifest binding, validation and aggregate integrity evidence complete |
| `AR-RSDI-P1-03` | Main App UI + Architecture privacy review | `closed` | Typed payload, writer preservation and noninterference evidence complete |
| `AR-RSDI-P1-04` | Architecture & Knowledge Steward | `closed` | ADR 0032 accepted and implementation evidence linked |

The full finding text and P2 recommendations live in the
[`Architecture pre-review`](rime-scheme-delivery-integrity-001-architecture-review.md).
The accepted actor/state table, cleanup receipt, staged identity, commit lease
and exact typed field allowlist live in the
[`Entry design`](rime-scheme-delivery-integrity-001-entry-design.md). Architecture
Entry and implementation P1 findings are closed. Final Architecture review is
`Pass`, P0=0/P1=0; the remaining gates are listed below.

## Gates

- **Entry Criteria:** Assignment responsibilities are acknowledged; ADR 0032 is
  `Accepted; implementation pending`; the cleanup barrier, explicit staged
  identity descriptor, actor/state transition table and ADR 0027 typed
  event/field allowlist close `AR-RSDI-P1-01...04`; the implementation base
  commit and changed-file allowlist are recorded; no Extension-network or
  TD-001 expansion is confirmed.
- **Exit Criteria:** automated evidence proves first-source archive-size and
  archive-digest failures clean up and can recover through the next independently
  pinned source; all-source archive failure stops; staged-content mismatch stops
  without cross-source retry; cancellation and operation-generation rules hold;
  installed receipts remain success-only; localized categories and content-free
  diagnostics are verified; Swift format, affected tests, stable-toolchain full
  App suite and Debug/Release builds pass; the Human Dependency records an exact
  Mainland physical-device retry for Product Gate.
- **Stop Conditions:** a source lacks an immutable digest; variants no longer
  converge on the guarded staged-content identity; fallback changes version;
  failed temporary content survives; diagnostics require private input or
  credentials; code work starts without explicit implementation authorization;
  or work expands into update discovery, atomic install or Release operations.

## Handoff

- **Required Handoff Content:** exact commit/build; source and phase taxonomy;
  redacted diagnostic samples; failure-injection matrix; temporary-file cleanup
  evidence; localized UI states; current endpoint receipts; Architecture and
  Quality conclusions; stable-toolchain results; and physical-device network
  result with device/OS/network/source.
- **Revalidation Trigger:** scheme version/asset, source revision/digest,
  staged-content allowlist/hash, redirect behavior, failure taxonomy, logging
  privacy boundary, URLSession behavior or release-channel change.

## History

- `2026-08-26 Asia/Shanghai` — Product Lead assigned the bounded remediation
  design and KOS recording only. Lifecycle remains `Assigned`; no production
  implementation has started.
- `2026-08-26 Asia/Shanghai` — Product Lead accepted the detailed state and
  structured local-diagnostics contract and instructed the task to continue.
  Executor acknowledged the Assignment; lifecycle advanced to `Acknowledged`
  for Architecture pre-review. No production implementation has started.
- `2026-08-26 Asia/Shanghai` — independent Architecture pre-review returned
  `Pass with conditions`, `P0=0`, with four P1 Entry blockers. Proposed ADR 0032
  and the residual disposition table were added; lifecycle remains
  `Acknowledged` and no production implementation has started.
- `2026-08-26 Asia/Shanghai` — independent Architecture re-review found ADR
  0031 acceptable with no new P0. ADR status advanced to `Accepted;
  implementation pending`; AR-RSDI-P1-04 is closed at design level only.
- `2026-08-26 Asia/Shanghai` — final Architecture Entry re-review accepted the
  cleanup identity, staged descriptor invariants, typed payload privacy schema
  and cross-entry commit lease with `P0=0`. AR-RSDI-P1-01/02/03 are design
  closed and implementation/evidence pending. Exact implementation base and
  allowlist were frozen at
  `bcf6c1c46ff374cfea20ec2552ca273161cb8d76`. Product implementation
  authorization remains the only open Entry Gate.
- `2026-08-26 Asia/Shanghai` — Human Product Lead explicitly authorized
  `RIME-SCHEME-DELIVERY-INTEGRITY-001` implementation. Lifecycle advanced to
  `Active`; authorization excludes commit, push and merge.
- `2026-08-27 Asia/Shanghai` — implementation recovery after cross-agent handoff
  closed cleanup-receipt truthfulness, typed phase field validation,
  diagnostics noninterference test coverage and all-source size/digest/mixed
  aggregate classification. KeyboardCore `1065/1065` and the affected iOS
  Simulator matrix `24/24` passed on the available Xcode 27 beta toolchain.
  Independent Architecture and Quality review remain `Fail`, P0=0: T9
  prepare→deploy still needs production-entry coordination and an entry-path
  regression. `DiagnosticsJournal.swift` is also a necessary frozen-allowlist
  expansion because writer normalization must preserve the typed payload.
  Product expansion authorization, stable-toolchain evidence and the Mainland
  physical-device Human Gate remain open; no commit, push or merge occurred.
- `2026-08-27 Asia/Shanghai` — Human Product Lead explicitly expanded the frozen
  changed-file allowlist by exactly `SchemaManager+T9Layout.swift`,
  `DiagnosticsJournal.swift` and `NineKeyEnableTransactionTests.swift`. This
  authorizes only T9 prepare→deploy coordination, typed-payload writer
  preservation and the production-entry regression; commit, push, merge and
  unrelated T9 behavior remain excluded.
- `2026-08-27 Asia/Shanghai` — T9 prepare→deploy entered the shared commit
  coordinator. Follow-up review found and closed foreign-lease cancellation and
  post-acquire generation-invalidity lease leaks with deterministic regression
  tests. Final Architecture returned `Pass`; final Quality returned `Pass with
  conditions`; both report P0=0/P1=0. Beta-toolchain local gates passed as
  recorded in the implementation evidence. Registry retirement remains a
  non-blocking P2. Stable CI, exact-candidate Mainland device evidence and Human
  Product Gate remain open; no commit, push or merge occurred.
- `2026-08-28 Asia/Shanghai` — Human Product Owner authorized continuing #83 by
  merging current `main`, then TD-015 journal, then Human retest. This branch
  merged `origin/main` (`c44ec00`). Scheme integrity ADR was renumbered to
  **0032** because `main` already accepted CI classification as ADR 0031. Merge
  of PR #83 to `main` remains unauthorized.
- `2026-08-28 Asia/Shanghai` — Human v1 journal classified Wanxiang download
  `11831eec-…` as `failure=staged_content` after archive size/digest passed on
  CNB. Executor reproduced actual prefix `24227ffc…` from production `Unzip`
  skipping empty `lua/data/chaifen.txt`. Pin `5b182801…` remains valid. Empty
  stored zip entries are now extracted; hashes are not weakened. Merge still
  unauthorized.
- `2026-08-28 Asia/Shanghai` — Human CNB retry `38b5a8d3-…` completed after the
  empty-file unzip fix: staged-content, install, deploy and terminal succeeded.
  Hosted full-path `33174305736` on `388bfd2` was green. Human authorized merge.
- `2026-08-28 Asia/Shanghai` — PR #83 merged `e9aea57`. Human Product Gate
  Passed. GitHub-source remains untested (`accept`). Assignment Closed.
