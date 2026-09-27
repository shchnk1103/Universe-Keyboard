# RIME-SYNC-001 bounded iOS V1 final Architecture re-review — 2026-09-24

## Verdict

**Accept with conditions** for the bounded iOS V1 architecture represented by
the exact candidate below. Both deletion-boundary findings from the prior final
Architecture `Blocked` review are addressed in source and focused regression
coverage. I found no new architecture finding in the reviewed candidate.

The condition is evidentiary: real document-provider metadata behavior and
provider-side deletion propagation remain unknown. The current implementation
may report success after a confirmed missing local package, successful local
`removeItem`, or accepted WebDAV response; this review does not establish that
a file provider or WebDAV service has completed durable remote deletion. Keep
that limitation explicit and satisfy the Assignment's provider/deletion
evidence requirement before treating V1 closure criteria as met. This is not a
Product acceptance of that residual.

## Exact candidate binding

| Item | Value |
|---|---|
| Worktree | `/Users/doubleshy0n/.codex/worktrees/rime-sync-docs-close-20260923/Universe Keyboard` |
| HEAD | `4a51228fc8e435d538e9a5f7342ae325502e1e66` |
| Candidate paths | 44 |
| Manifest SHA-256 | `2c09ee2f3eba9abf1511e09285548e437fea657c3762899eb5166f8cb75a4d2a` |
| Excluded paths | `docs/reviews/rime-sync-v1-p2-quality-rereview-2026-09-24.md`; this review receipt |

Manifest algorithm: sorted unique union of `git diff --name-only --no-renames`
and `git ls-files --others --exclude-standard`, excluding the two paths above.
For each remaining relative path, concatenate `<file SHA-256>  <relative
path>\n`; SHA-256 that exact concatenation. I independently computed the path
count and digest before review; both matched the supplied expectation. The
receipt was written after the calculation and was not included in, or followed
by a recalculation of, the candidate manifest.

## Scope and method

- Fresh, context-free read-only Architecture review. I did not implement this
  candidate or author its tests/evidence, and derived this verdict from current
  source, contracts and tests rather than inheriting another review's verdict.
- Read `AGENTS.md`, Knowledge Index, Active Work, Reading Maps (Portable RIME
  Sync route), Assignment Policy, AI Workflow, KOS 2.1 operational maturity,
  Project Context, Virtual Engineering Team, and the available coordinator,
  Main App UI, RimeBridge, Test/Release and Documentation Maintainer playbooks.
  The repository has no separate Architecture Review playbook.
- Reviewed `RIME-SYNC-001`, `RIME_SYNC.md`, ADR 0012/0013/0014 and applicable
  shared-container, privacy and user-dictionary ownership decisions; shared
  container/RIME lifecycle, Privacy Policy, TECH_DEBT, deletion remediation
  evidence, scoped Quality receipt and prior final Architecture receipt; and
  the corresponding transport, ViewModel, crypto, scheduler, bridge and test
  code.
- No tests/builds were run, no existing `.xcresult` was inspected, and no
  device or network was accessed. The only write was this authorized review
  receipt. The cited five-test result comes from the existing evidence record;
  it is not provider or device evidence.
- Model identity: **工具请求的模型 override，reviewer runtime 不可自证**。I
  cannot independently certify the requested `gpt-6-luna` model identity.

## Findings and dispositions

### `ARCH-RIME-SYNC-001-FINAL-P1-01` — unknown deletion target state could report success

**P1 · Resolved in this candidate.**

`RimeSyncTransport.swift:243-253` now recognizes only explicit Cocoa
no-such-file errors as `.missing`; other lookup errors propagate, and absent
`isDirectory` metadata becomes `.unknown`. In `:288-299`, only `.missing`
returns idempotent success and only `.directory` reaches `removeItem`; the
other states throw. `RimeSyncViewModel.swift:812-853` clears local provider
configuration and secrets only after `deleteRemoteData()` returns normally.
The recorded regressions cover lookup failure and preserved package,
configuration and secret-store values at `RimeSyncTests.swift:126-187`, and
unknown metadata with the same preservation properties at `:190-245`.

This closes the code-level false-success path. The credential assertions use
`MemoryRimeSyncSecretStore`, not the production Keychain.

### `ARCH-RIME-SYNC-001-FINAL-P2-02` — deletion did not verify package-root type

**P2 · Resolved in this candidate.**

The production lookup reads `URLResourceValues.isDirectory` and distinguishes
directory, non-directory and unknown at `RimeSyncTransport.swift:243-253`.
Only the confirmed-directory branch deletes at `:294-297`. Tests preserve a
same-name ordinary file at `RimeSyncTests.swift:809-827`; separately verify
confirmed-missing idempotence at `:797-807` and that successful scoped deletion
preserves standard RIME files at `:772-795`.

### `ARCH-RIME-SYNC-001-FINAL-R1-P2-01` — provider deletion outcome remains unverified

**P2 · Open evidence condition; not a new code defect.**

The remediation evidence explicitly limits its result to a local temporary
filesystem and an injected unknown-metadata seam, and disclaims real provider
metadata and deletion propagation (`docs/evidence/rime-sync-v1-p2-deletion-boundary-remediation-2026-09-24.md:54-62`).
The scoped Quality receipt retains the same limitation and also states that
real Keychain retention was not established
(`docs/reviews/rime-sync-v1-p2-quality-rereview-2026-09-24.md:36-45,54-63`).
Keep provider-specific deletion and metadata behavior unknown until observed
against the actual supported provider(s); do not infer it from the temporary
filesystem tests, fake WebDAV client, or accepted HTTP status. The Assignment
continues to require provider/deletion evidence. Owner: Main App & Data
Operations with Quality evidence review. Disposition: provide the required
evidence before parent close; no Product risk acceptance is recorded here.

### `ARCH-RIME-SYNC-001-P1-02` — cross-process RIME user-data concurrency

**P1 · Open; retained as `tech_debt:TD-002`.**

`docs/TECH_DEBT.md:18-26` says process-local serialization and the keyboard
activity heartbeat reduce overlap opportunity but do not prove exclusion from
Keyboard Extension/librime writes. This is not represented as solved by the
current conditional Architecture verdict. Product's explicit retention of
TD-002 is not technical remediation, proof of safety, or authorization to
close the debt.

### `ARCH-RIME-SYNC-001-P2-01` — diagnostic error-code stability

**P2 · Resolved in the reviewed source; no regression found.** The finite
diagnostic code mapping and unknown fallback remain present in
`RimeSyncTransport.swift:32-56,114-162`; current tests for stable values and
privacy-safe mapping are at `UniverseKeyboardTests/RimeSyncTests.swift:529-564`.

## Bounded architecture boundary review

- **Ownership and hot path:** Synchronization orchestration and credentials
  remain Main-App-owned. `RimeSyncViewModel` routes to the bridge from
  the App; the RIME operation invokes librime's standard sync path
  (`Universe Keyboard/Models/RimeSyncViewModel.swift:975-992`,
  `Packages/RimeBridge/Sources/RimeBridge/RimeStandardSyncService.swift:54-117`).
  Keyboard activity is a conservative heartbeat, not a sync client. I found no
  Extension networking, package scan, encryption or synchronization in the
  keyboard input hot path. Live `*.userdb*` copying/replacement remains
  prohibited by ADR 0013 and the Assignment.
- **Privacy and key separation:** The private settings envelope uses
  ChaCha20-Poly1305 with version/domain AAD
  (`Universe Keyboard/Services/RimeSyncCrypto.swift:5-27`). The WebDAV
  password and content key are separate Keychain accounts, with
  `AfterFirstUnlockThisDeviceOnly` accessibility
  (`Universe Keyboard/Services/RimeSyncCrypto.swift:94-145`). The current
  contract and privacy policy continue to exclude typed content, dictionaries,
  diagnostics, learning data and YAML/TXT from the private package; standard
  RIME sync remains a separate, unencrypted user-confirmed path.
- **Conditional writes and conflict preservation:** Local publication reads the
  current object, computes its digest and compares the supplied ETag before
  writing (`RimeSyncTransport.swift:270-285,313-324`). WebDAV uses `If-Match`
  and create-only `If-None-Match` (`:419-431`). The coordinator fetches,
  merges, conditionally publishes and bounds conflict retries
  (`Universe Keyboard/Services/RimeSyncCoordinator.swift:20-57`). No silent
  overwrite or non-destructive conflict regression was found in the reviewed
  paths.
- **Deletion scope:** Local deletion targets only `universe-rime-sync`, and
  tests show standard RIME files survive. WebDAV deletion targets the private
  package root and treats 404 as idempotent (`RimeSyncTransport.swift:394-399`).
  Client request completion is not proof of provider-side durable deletion;
  retain the open evidence condition above.
- **Automatic sync:** The main-App background entry checks user opt-in,
  configured standard-sync scope, a prior successful manual sync, busy state,
  cooldown and keyboard activity before taking its process-local gate
  (`RimeSyncViewModel.swift:552-625`). Scheduling remains an iOS opportunity,
  not a guaranteed timer. The heartbeat and process gate do not resolve
  cross-process TD-002.
- **Other open/deferred scope:** `TD-008` remains deferred cross-platform
  compatibility/custom-file import work; CloudKit remains deferred under its
  separate prerequisites; `TD-013` and `TD-017` remain open, including the
  historical unknown diagnostic cause and background sandbox-extension
  attribution. The invalid Run 02 is not promoted to valid evidence. I found no
  candidate wording or code that recasts these as completed.

## Verdict boundary and non-claims

`Accept with conditions` applies only to the architecture of the exact bounded
iOS V1 candidate and the source-level disposition of the two deletion
findings. The condition is the provider/deletion evidence above. This review
does not establish real provider metadata semantics, durable remote deletion,
production Keychain retention for this remediation, real-device behavior,
cross-process mutual exclusion, reliable iOS background delivery, CloudKit,
cross-platform compatibility or Product acceptance of any residual.

This is not a Quality Gate, Product Gate, Assignment lifecycle transition or
close, nor authorization to commit, push, publish, merge, TestFlight or Release.
The parent `RIME-SYNC-001` remains `Active` unless and until its authorized
owners make the separate lifecycle decisions.
