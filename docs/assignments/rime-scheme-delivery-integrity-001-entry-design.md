# RIME-SCHEME-DELIVERY-INTEGRITY-001 — Entry Design

**Status:** Architecture Entry accepted; implementation complete; external gates open
**Date / timezone:** `2026-08-26 Asia/Shanghai`
**Implementation:** completed locally on `2026-08-27`; see the linked Assignment
and implementation evidence for review and gate status
**Frozen implementation base:**
`bcf6c1c46ff374cfea20ec2552ca273161cb8d76`
**Architecture SoT:**
[`ADR 0031`](../architecture/decisions/0031-verified-scheme-source-recovery-and-integrity-classification.md)

This document supplies the state/commit table, cleanup barrier, staged-identity
invariants, typed diagnostic payload schema and changed-file allowlist required
before the Assignment may enter `Active`. It is not implementation evidence;
each section remains subject to Architecture Entry review.

## Actor And State Ownership

- `SchemaManager` is the sole MainActor owner of `operationID`, cancellation
  generation, current source/attempt, internal phase, restrained UI state,
  fallback decision and installed receipt commit.
- Each background operation receives immutable `Sendable` values: operation ID,
  source variant, staged identity, URLs and installation-plan snapshot. It
  returns an immutable result and never publishes UI, chooses fallback, installs,
  deploys or writes receipts.
- File hashing, extraction, post-processing and cleanup verification execute off
  MainActor. No detached closure captures `SchemaManager` or another
  MainActor-isolated reference.
- Diagnostics are best-effort side effects after the owning transition is
  decided. Journal failure cannot change the transition result.

## Internal Transition Table

Every `await` return first checks task cancellation and exact `operationID`
generation. Failure of that check transitions only to cancelled/idle cleanup;
it cannot publish a stale phase, choose fallback, install, deploy or write a
receipt.

| Phase owned by MainActor | Operation executor and input/result | Success transition | Recoverable branch | Terminal branch |
|---|---|---|---|---|
| `selectingSource` | background selector: immutable variant list → selected variant | `downloadingArchive(source, attempt)` | ordinary probe/transport policy selects another eligible source | cancelled / all sources unavailable |
| `downloadingArchive` | background downloader: source + new attempt/artifact identity → unique downloaded artifact | `verifyingArchiveSize` | ordinary transport failure may use parent fallback policy | cancelled / no eligible source |
| `verifyingArchiveSize` | background verifier: artifact + expected bytes → actual bytes | `verifyingArchiveDigest` | mismatch enters `cleaningFailedArchive(.archiveSize)` | non-regular/corrupt artifact |
| `verifyingArchiveDigest` | background verifier: artifact + complete expected digest → complete actual digest | `extracting` | mismatch enters `cleaningFailedArchive(.archiveDigest)` | hash I/O failure |
| `cleaningFailedArchive` | dedicated Sendable cleanup worker: exact attempt/artifact → cleanup receipt proving absence | next eligible source bound to the same resolved staged descriptor | cleanup success permits a new attempt | cleanup failure; no next source; cancellation |
| `extracting` | background extractor: verified artifact → unique extraction root | `postProcessing` | none | unsafe/corrupt archive or extraction failure |
| `postProcessing` | background processor: extraction root + immutable plan/Lua state → processed root | `verifyingStagedContent` | none | deterministic processing/allowlist failure |
| `verifyingStagedContent` | background verifier: processed root + complete expected identity → complete actual identity | acquire `schemeDeliveryCommitLease`, then `installing` | none | staged mismatch always terminates; best-effort cleanup cannot authorize fallback |
| `installing` | MainActor-owned installer service under commit lease: fully verified root → install result | `deploying` | none | installation failure; TD-001 remains open |
| `deploying` | MainActor-owned async deployment service under the same commit lease → deployment result | `committingReceipt` | none | deployment failure |
| `committingReceipt` | MainActor synchronous commit under the same lease: verified source/digests → persisted receipt | release lease, then `completed` | none | process termination window remains ADR 0006/TD-001; do not claim atomicity |

The user-facing `DownloadState` may remain coarser and maps internal phases as:

| User-facing state | Internal phases |
|---|---|
| selecting source | `selectingSource` |
| downloading through named source | `downloadingArchive` |
| verifying download | `verifyingArchiveSize`, `verifyingArchiveDigest`, `cleaningFailedArchive` |
| preparing input scheme | `extracting`, `postProcessing`, `verifyingStagedContent`, `installing` |
| deploying RIME | `deploying`, `committingReceipt` |
| completed / classified failure | terminal state |

## Cleanup Barrier

The downloader assigns a non-reusable `attemptID` and `artifactID` before
registering the exact unique URL for that operation/source attempt. A dedicated
`Sendable` cleanup worker—not the existing MainActor-isolated installer—receives
that registered immutable artifact identity. It removes the exact item, treats
already-absent as success only when that artifact identity was registered by the
current downloader, then verifies nonexistence.

Only the cleanup worker can construct a success receipt. The value-type receipt
binds `operationID + attemptID + sourceID + artifactID +
removedOrAlreadyAbsent`; artifact ID and path never enter UI or diagnostics.
Any remove, registration or existence-check error is failure. The MainActor
owner rechecks generation and exact equality of all receipt identity fields
against the current attempt before requesting another source. A stale receipt
is terminal for that operation and cannot clean or authorize a later attempt.

Injected tests must cover successful deletion, registered exact-item already
absent, unregistered already-absent rejection, same-source second-attempt stale
receipt, deletion failure, existence-check failure, cancellation after cleanup,
stale operation receipt and proof that every failure avoids requesting the next
source.

## Explicit Staged Identity

Each source variant references an immutable `stagedIdentityID`. The referenced
descriptor binds:

- scheme ID and immutable artifact identity;
- Lua-enabled complete staged SHA-256;
- Lua-disabled complete staged SHA-256;
- `installationPlanRevision`;
- `postProcessingRevision`.

Changing admitted paths, path normalization, Lua stripping, T9 sanitization or
other deterministic processing requires a revision and new complete receipts.
Within one manifest, every `stagedIdentityID` is unique and resolves to exactly
one descriptor. Duplicate IDs, unresolved references or one ID mapping to
conflicting descriptors fail closed before source probing or download begins.
Every source resolves one and only one descriptor. Fallback eligibility compares
the fully resolved descriptor identity—not only its string ID—and then executes
all complete verifications; neither ID nor descriptor substitutes for hashing.

## Install, Deploy And Receipt Commit Lease

After staged-content verification, `SchemaManager` performs one final generation
check and acquires a MainActor `schemeDeliveryCommitLease` before installation.
While the lease exists:

- one MainActor coordinator rejects or queues every intent that can modify the
  schema installation tree, change active schema or start RIME deployment. This
  includes install/download/redownload/reset, uninstall, scheme switch, T9
  deployment and Settings manual/pending deployment;
- no conflicting intent executes concurrently and no user intent is silently
  discarded. At most one latest idempotent intent per kind is retained with its
  required immutable arguments; destructive or order-sensitive intents retain
  FIFO order;
- a user cancellation request is retained but does not invalidate generation or
  interrupt the install/deploy/receipt sequence;
- install, async deploy and successful receipt commit remain ordered under the
  same logical lease even though the deploy `await` yields MainActor execution;
- deploy success always commits the matching verified receipt before the lease
  is released; deploy failure writes no receipt;
- after release, deferred cancellation is cleared because the operation is
  already completed/failed, then queued intents are revalidated against current
  state and processed serially. Invalidated intents receive an explicit
  no-op/failure state rather than disappearing.

Every install, uninstall, active-schema mutation and deploy entry routes through
the same coordinator. Central `deployRimeConfig` lease enforcement may protect
T9/Settings callers without changing their files, but tests must exercise those
entry paths. This closes the in-process “new deployment + old receipt” window. Process
termination during file-by-file install/deploy/receipt remains ADR 0006/TD-001
and is not claimed as solved.

## ADR 0027 Typed Diagnostic Allowlist

### Event codes

| Proposed `DiagnosticEvent.Code` | Emission boundary |
|---|---|
| `schemeDeliveryPhaseChanged` | one event when an internal phase changes; never for progress callbacks |
| `schemeDeliveryIntegrityFailed` | classified archive-size, archive-digest or staged-content mismatch |
| `schemeDeliveryFallback` | transition from one source to another with a finite reason |
| `schemeDeliveryTerminal` | completed, cancelled or terminal classified failure |

### One composite typed payload per event

Each scheme-delivery event contains exactly one
`SchemeDeliveryDiagnosticPayload` whose enum case must correspond to its event
code. Scheme-delivery codes forbid the generic field array for delivery data;
non-delivery codes forbid this payload. Custom decoding rejects missing,
duplicate, mismatched or unknown delivery payloads instead of letting the
display layer infer meaning.

| Event code | Required payload | Optional payload | Forbidden ambiguity |
|---|---|---|---|
| `schemeDeliveryPhaseChanged` | operation, artifact identity, phase | attempt index/source/final host when a source exists; bounded prior-phase duration | integrity tuples, from/to fallback pair, terminal outcome |
| `schemeDeliveryIntegrityFailed` | operation, artifact identity, attempt index/source, phase, exactly one composite integrity observation | final host, duration, Lua flag | multiple observations or separable digest role/kind/value fields |
| `schemeDeliveryFallback` | operation, artifact identity, distinct from-attempt/source and to-attempt/source, finite fallback reason | normalized from/to host | one unqualified source or staged-content reason |
| `schemeDeliveryTerminal` | operation, artifact identity, outcome and installed/deployed flags | final attempt/source, finite transport/local failure, duration | fallback pair or raw error strings |

The composite integrity observation is exactly one of:

- `archiveSize(expected: Int64, actual: Int64)`;
- `archiveDigest(expected: DigestPrefix16, actual: DigestPrefix16)`;
- `stagedContent(expected: DigestPrefix16, actual: DigestPrefix16)`.

This representation makes expected/actual role and digest kind inseparable and
prevents duplicate or conflicting field-array combinations.

### Finite payload value types

| Field | Type / allowed values | Constraint and purpose |
|---|---|---|
| operation | `UUID` | random per explicit user download; correlation only |
| artifact | reviewed enum | cases bind the manifest revision plus complete receipt identity, e.g. the current 雾凇 archive identity and 万象 `17.5.9` source-receipt set; mutable display labels such as `nightly` are not sufficient identity |
| staged identity | reviewed enum | current cases bind scheme + plan/post-process revision; no arbitrary string |
| attempt | integer `1...8` | starts at 1; manifest validation rejects more than eight attempts and duplicate source IDs; identifies attempts without persisting internal attempt/artifact UUIDs |
| source | reviewed enum | `nju`, `github`, `cnb`; fallback payload has separately typed `from` and `to` values |
| final host | reviewed enum | only current redirect allowlist hosts: `mirror.nju.edu.cn`, `github.com`, `release-assets.githubusercontent.com`, `objects.githubusercontent.com`, `cnb.cool`, `asset.cnb.cool` |
| phase | reviewed enum | the internal phases in the transition table |
| result | reviewed enum | `started`, `succeeded`, `failed`, `cancelled` |
| integrity kind | reviewed enum | `archiveSize`, `archiveDigest`, `stagedContent` |
| fallback reason | reviewed enum | `transport`, `archiveSize`, `archiveDigest` only |
| integrity observation | composite enum | pairs expected/actual bytes or digest prefixes with exactly one integrity kind |
| digest prefix | `DigestPrefix16` | exactly first 16 lowercase hexadecimal characters of a complete SHA-256; correlation only |
| HTTP status | reviewed integer | absent or `100...599` |
| system error domain | reviewed enum | `url`, `cfNetwork`, `posix`, `cocoa`, `other`; no raw domain string |
| system error code | signed 32-bit integer | diagnostic code only; paired with finite domain |
| duration | bounded milliseconds | clamp to `0...300_000`; no wall-clock/network identity inference |
| flags | reviewed booleans | Lua available, cleanup confirmed, installed, deployed |

Implementation uses a dedicated optional composite payload on `DiagnosticEvent`
or an equivalent single composite `Field` case with code/payload validation. It
must not flatten delivery data into independently repeatable generic fields or
reuse `appearanceID`, `actionSequence`, `Reason` or generic strings with
incorrect semantics. Decoder, runtime adapter, display formatter and round-trip
tests must be updated together.

### Privacy and availability decisions

- Scheme/display names, versions, hosts and error domains never enter as raw
  strings; only reviewed enums are persisted.
- Digest prefix length is fixed at 16 lowercase hex characters. It cannot be
  accepted as integrity proof.
- No full URL, port, path, query, redirect token, IP, carrier, SSID, location,
  local file path, typed content or candidate appears.
- Diagnostics use the existing category switch and bounded asynchronous ingress.
  Disabled, unavailable or full journal states produce no synchronous fallback
  logging and do not alter download behavior.
- The UI formatter derives labels from enums. It does not render hidden raw
  strings from a payload.
- The diagnostics adapter is nonthrowing and never waits for journal durability.
  Tests inject diagnostics disabled, root unavailable, queue overload and
  encoder/ingress drop and compare business transitions against diagnostics
  enabled behavior.

## Proposed Changed-File Allowlist

The following exact-path allowlist is bound to implementation base
`bcf6c1c46ff374cfea20ec2552ca273161cb8d76`. At freeze time, local HEAD and
`origin/codex/task11-reproduction-details` both resolved to that commit and the
worktree had documentation-only changes; no production-code dirt was present.
Production implementation may touch only these paths unless a new
Product/Architecture disposition expands the list:

- `Universe Keyboard/Services/SchemaManager.swift`
- `Universe Keyboard/Services/SchemaManager+Download.swift`
- `Universe Keyboard/Services/SchemaManager+Deployment.swift`
- `Universe Keyboard/Services/SchemaManager+Installation.swift`
- `Universe Keyboard/Services/SchemaManager+T9Layout.swift` (Product-authorized expansion, `2026-08-27`)
- `Universe Keyboard/Services/SchemaManagerDependencies.swift`
- `Universe Keyboard/Services/SchemaManagerTypes.swift`
- `Universe Keyboard/Services/SchemaArtifactSecurity.swift`
- `Universe Keyboard/Services/SchemaArchiveInstaller.swift`
- `Universe Keyboard/Services/SchemaTemporaryArtifactCleaner.swift` (new)
- `Universe Keyboard/Services/SchemaDeliveryDiagnostics.swift` (new)
- `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEvent.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournal.swift` (Product-authorized expansion, `2026-08-27`)
- `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournalRuntime.swift`
- `Universe Keyboard/Views/Diagnostics/DiagnosticsLogSource.swift`
- `UniverseKeyboardTests/SchemaManagerTests.swift`
- `UniverseKeyboardTests/NineKeyEnableTransactionTests.swift` (Product-authorized expansion, `2026-08-27`)
- `UniverseKeyboardTests/SchemaArtifactSecurityTests.swift`
- `UniverseKeyboardTests/RimeSettingsStoreTests.swift`
- `Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticEventTests.swift`
- `Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticsJournalRuntimeTests.swift`
- `docs/assignments/rime-scheme-delivery-integrity-001.md`
- `docs/assignments/rime-scheme-delivery-integrity-001-entry-design.md`
- `docs/assignments/rime-scheme-delivery-integrity-001-architecture-review.md`
- `docs/architecture/decisions/0031-verified-scheme-source-recovery-and-integrity-classification.md`
- `docs/evidence/rime-scheme-delivery-wanxiang-integrity-failure-2026-08-26.md`
- `docs/evidence/rime-scheme-delivery-integrity-implementation-2026-08-26.md` (new)
- `docs/assignments/rime-scheme-delivery-001.md`
- `docs/RIME_SCHEME_MANAGEMENT.md`
- `docs/DEBUGGING.md`
- `docs/RELEASE_CHECKLIST.md`
- `docs/ACTIVE_WORK.md`
- `docs/KNOWLEDGE_INDEX.md`

Explicitly excluded: Keyboard Extension networking/input paths, RimeBridge,
scheme runtime content, source URLs/versions/digests, user dictionaries,
automatic update discovery and TD-001 transaction implementation.

## Entry Review Request

At Entry, independent Architecture final re-review accepted this design with
`P0=0`: `AR-RSDI-P1-01/02/03` are design closed and implementation/evidence
pending; `AR-RSDI-P1-04` is closed by accepted ADR 0031. Any field, state,
privacy or allowlist expansion reopens review. The exact implementation base and
allowlist are now frozen above. Product implementation authorization remains the
only open Entry Gate at that historical checkpoint.

Implementation subsequently completed within the frozen and explicitly
expanded allowlist. Final independent Architecture review returned `Pass`,
P0=0/P1=0; Quality returned `Pass with conditions`, P0=0/P1=0. Stable-toolchain,
exact-candidate Mainland physical-device and Human Product gates remain open.
