# RIME-SYNC-001 — local-folder provider deletion Architecture review — 2026-09-25

## Verdict

**Accept with conditions** for the exact bounded iOS V1 local-folder candidate.
The new observation satisfies the Architecture evidence condition for deletion
state in the tested Simulator Files local-storage provider. It does not turn
the enclosing failed XCTest into a pass, nor establish propagation beyond that
provider container. `TD-002` remains an open P1 risk explicitly retained as
`tech_debt:TD-002`; this review does not make or imply a Product lifecycle
decision. The parent Assignment remains `Active` pending the independent
Quality conclusion and Product Lead lifecycle authority.

## Exact candidate and reviewer boundary

| Item | Value |
|---|---|
| Worktree | `/Users/doubleshy0n/.codex/worktrees/rime-sync-docs-close-20260923/Universe Keyboard` |
| HEAD | `4a51228fc8e435d538e9a5f7342ae325502e1e66` |
| Candidate paths | 58 |
| Candidate manifest SHA-256 | `65374606d7322aea52756a6c7ff457ea805452c5859880f8e977f983dc29382c` |
| Excluded post-review receipts | `docs/reviews/rime-sync-v1-local-folder-provider-deletion-quality-review-2026-09-25.md`; this receipt |
| Reviewer role | Independent Architecture reviewer |
| Requested model identity | GPT-6 Luna; the exact runtime/model identity is not independently attestable from this review runtime |

I independently recomputed the manifest before review. The algorithm was the
unique path union of `git diff HEAD --name-only -z` and
`git ls-files --others --exclude-standard -z`; paths were sorted by raw UTF-8
bytes (equivalent to C-locale byte ordering) and deduplicated. The two receipt
paths above were excluded. For each remaining relative path, I computed
SHA-256 and emitted the `shasum -a 256` line (`<digest>  <path>`); those lines
were joined with LF including the final LF, then hashed with SHA-256. The
independent result was 58 paths and the digest shown above, matching the
coordinator's value. Neither excluded receipt was present in the candidate at
recalculation time.

This review was read-only except for creating this dedicated receipt. I did not
run tests or builds, inspect result bundles, operate a Simulator or device,
change provider contents, or alter production files. The evidence and source
were reviewed from their repository records only.

## Evidence assessed

The executor receipt
[`rime-sync-v1-local-folder-provider-deletion-attempt-2026-09-25.md`](../evidence/rime-sync-v1-local-folder-provider-deletion-attempt-2026-09-25.md)
records one production-path operation on iPhone 18 Pro Max / iOS 27.0 Simulator
(`C1B96097-D5CD-4FE3-BF01-C2C6B7DDDE20`) against a newly created folder in
`com.apple.FileProvider.LocalStorage`. The production ViewModel, Keychain and
local-folder transport were used. After first sync and the explicit delete and
disconnect confirmation, the App returned to “尚未配置”. A read-only inspection
of that same Simulator provider container found `universe-rime-sync/` absent
and the sibling RIME standard-data directory still present, including the
recorded standard data files. The private package and user-dictionary contents
were not read.

The first XCTest failed after the deletion action, in the subsequent Files UI
navigation/assertion (`1 failed / 0 passed`). A second attempt stopped before
folder creation or sync because Files remained in a sidebar/menu state. Neither
run is a passing end-to-end test; the second attempt provides no deletion
evidence. This review relies on the first attempt's separately recorded App
state and provider-container observation, not on a green test result.

## Architecture boundary analysis

- **Main-App ownership and side effects:** `RimeSyncViewModel.disconnect`
  requests deletion from the selected transport before removing credentials
  and local provider configuration. A deletion error leaves configuration in
  place and reports failure; a successful return clears the local sync state.
  The recorded transition to “尚未配置” is consistent with the production
  flow having completed. The Keyboard Extension remains outside this path.
- **Transport scope:** `LocalFolderRimeSyncTransport.deleteRemoteData()` uses
  the folder write-access/coordinator boundary and targets only the fixed
  `universe-rime-sync` package root. It accepts an already-missing package as
  idempotent success, removes only a directory, and fails closed for a
  non-directory or unknown root type. No standard `sync_dir` removal is part
  of this private-package deletion method.
- **Storage separation:** ADR 0013 and `RIME_SYNC.md` place plaintext RIME
  standard data and the encrypted Universe-private package in separate
  locations; deleting the private package must not delete standard sync data.
  The same-provider observation directly corroborates that boundary for this
  one operation: the private package root was absent while the standard RIME
  directory remained. It does not establish the correctness of every RIME
  file, a remote replica, or another provider's behavior.
- **Provider evidence strength:** The inspection was against the actual
  Simulator File Provider local-storage container, not a temporary test
  filesystem or injected metadata seam. Combined with the production flow's
  returned unconfigured state, it is sufficient for the narrow Architecture
  question that the selected Simulator local-storage provider reflected
  deletion of the private package while preserving the RIME standard folder.
  A post-delete Files UI query is absent, but it is not required to override
  this direct provider-container state observation. The XCTest remains failed
  and must continue to be represented as such.
- **TD-002 / runtime coordination:** Process-local Main-App serialization and
  keyboard activity checks do not prove cross-process exclusion from
  Keyboard Extension/librime writes to `Rime/user`. The deletion observation
  does not exercise or mitigate that concurrency hazard. Per the existing
  Product disposition and `TECH_DEBT.md`, keep `TD-002` open as
  `tech_debt:TD-002`.

## Findings and dispositions

| Finding ID | Severity / status | Owner | Disposition | Basis |
|---|---|---|---|---|
| `ARCH-RIME-SYNC-001-PROVIDER-2026-09-25-R1` | P2; resolved for the tested Simulator LocalStorage boundary only | App & Data Operations; Quality to independently assess evidence grade | `fix` | Production-path operation plus same-provider read-only state observation in the [deletion attempt receipt](../evidence/rime-sync-v1-local-folder-provider-deletion-attempt-2026-09-25.md). This supersedes the local-Simulator deletion-evidence gap in prior Architecture receipts; it does not resolve external propagation. |
| `ARCH-RIME-SYNC-001-TD-002` | P1; open | RimeBridge, Main-App data operations and Extension lifecycle | `tech_debt:TD-002` | [`TECH_DEBT.md`](../TECH_DEBT.md#td-002-validate-rimeuser-concurrent-access); risk remains open and unmitigated by this provider observation. |
| `ARCH-RIME-SYNC-001-TD-008` | Deferred/open; outside this iOS V1 closure | Main App data operations / cross-platform compatibility | `tech_debt:TD-008` | [`TECH_DEBT.md`](../TECH_DEBT.md#td-008-complete-portable-rime-data-compatibility). No cross-platform parity or scheme portability claim. |
| `ARCH-RIME-SYNC-001-TD-019` | Deferred/open; outside this evidence slice | Main App data operations | `tech_debt:TD-019` | [`TECH_DEBT.md`](../TECH_DEBT.md#td-019-live-webdav-provider-validation). No live WebDAV or remote deletion claim. |

## Remaining limitations and non-claims

- The first XCTest is **failed**, not passed; its post-delete Files UI query
  did not complete. The second attempt ended before deletion and adds no
  evidence.
- The observation is limited to one test-created folder and the named
  Simulator's `com.apple.FileProvider.LocalStorage` state. It does not prove
  physical-device behavior, iCloud Drive or third-party provider propagation,
  another device's view, durable cloud deletion, live WebDAV semantics,
  CloudKit behavior, or deletion after interruption/crash.
- The RIME standard directory's presence supports only non-deletion in this
  observed state; it does not prove standard sync correctness or data
  interoperability.
- `TD-002`, `TD-008`, `TD-013`, `TD-017` and `TD-019` are not closed by this
  review. CloudKit remains deferred. Historical Run 02 `INVALID` remains an
  invalid historical record, not a successful sync result.
- This is an Architecture conclusion only—not Quality acceptance, Product
  Gate, lifecycle `Completed` / `Reviewed` / `Closed`, commit, PR, merge,
  TestFlight or Release authorization.

## Handoff

The provider-specific local Simulator deletion-state gap may be treated as
addressed for this bounded Architecture review. Quality should independently
decide whether the source evidence and failed-test boundary are sufficient for
its evidence conclusion. The Product Lead retains the separate decision on
whether to move the parent Assignment through its lifecycle. Preserve the
explicit `TD-002` technical-debt disposition and all non-claims above.
