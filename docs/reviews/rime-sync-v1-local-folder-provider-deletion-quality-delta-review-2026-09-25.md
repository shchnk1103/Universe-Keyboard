# RIME-SYNC-001 — local-folder provider deletion — independent Quality delta review — 2026-09-25

## Verdict

**Blocked** for closing `QR-PROVIDER-DELETE-01`. The follow-up receipt directly records the private package root absent and the RIME standard-data directory present in the same unique Simulator Files folder at capture time. That is a privacy-safe observation of the later state. It does not establish that the confirmed production deletion caused that state: capture was at 02:21:25 +08, after the original attempt, and the recorded mtimes near 01:54 cannot rule out an intervening change. The original UI test also failed in its later Files UI query. On this evidence I cannot close the operation-level deletion check.

The test remains **1 failed / 0 passed** as reported by the executor receipt. This Quality conclusion neither relabels it as passing nor makes a Product or Assignment lifecycle decision. The parent Assignment remains `Active`.

## Exact identity and review boundary

| Item | Value |
|---|---|
| Repository/worktree | `/Users/doubleshy0n/.codex/worktrees/rime-sync-docs-close-20260923/Universe Keyboard` |
| HEAD | `4a51228fc8e435d538e9a5f7342ae325502e1e66` |
| Candidate paths | 61 |
| Manifest SHA-256 | `d76298f2fb7e4e5b61847f074b17a40fd6124daf17f207a361c52ef057e05dc7` |
| Excluded paths | `docs/reviews/rime-sync-v1-local-folder-provider-deletion-quality-delta-review-2026-09-25.md`; `docs/reviews/rime-sync-v1-local-folder-provider-deletion-architecture-delta-review-2026-09-25.md` |
| Reviewer identity | Independent Quality reviewer in this Codex runtime; this is a fresh review of the stated candidate, not an adoption of prior review conclusions. |
| Model identity | **UNKNOWN** — exact model variant/runtime identity cannot be independently attested here. |
| Review mode | Repository documents, source and recorded result summaries inspected. No tests/builds run; no Simulator/device operated; no provider contents changed or read. Only this receipt was written by this review. |

### Manifest recomputation

I independently formed the unique path union from `git diff --name-only -z HEAD`
and `git ls-files --others --exclude-standard -z`, sorted and deduplicated
under `LC_ALL=C` (UTF-8 byte order), and excluded exactly the two paths
above. For each remaining path I ran `shasum -a 256`; I joined the complete
output lines with LF including the final LF and SHA-256 hashed those bytes.
The independent result was 61 paths and
`d76298f2fb7e4e5b61847f074b17a40fd6124daf17f207a361c52ef057e05dc7`,
matching the coordinator-provided identity. The two excluded delta-review
paths were absent from the candidate set when recomputed.

## Evidence matrix

| Claim | Evidence reviewed | Quality assessment |
|---|---|---|
| Attempt targeted an isolated local Files provider folder | Executor [deletion-attempt receipt](../evidence/rime-sync-v1-local-folder-provider-deletion-attempt-2026-09-25.md): iPhone 18 Pro Max / iOS 27.0 Simulator, UDID `C1B96097-D5CD-4FE3-BF01-C2C6B7DDDE20`, provider `com.apple.FileProvider.LocalStorage`, unique folder `Universe-Rime-Sync-0757F4BD`; reports use of production ViewModel, Keychain and local-folder transport. | Specific, bounded executor record for one Simulator folder. No physical-device or other-provider inference. |
| Private package absent and standard directory present | [State reinspection receipt](../evidence/rime-sync-v1-local-folder-provider-state-reinspection-2026-09-25.md): capture at `2026-09-25 02:21:25 +08:00`; exact provider root; only immediate child names, two existence checks and directory metadata. Output: `private_package=absent`, `standard_rime_directory=present`; root mtime 01:54:31 and standard root mtime 01:54:22 +08. | Direct observation of the state at capture time. Similar mtimes support temporal proximity only; they do not establish uninterrupted state or causation. |
| Confirmed delete action preceded the state | The attempt receipt records first sync, explicit “删除并断开” confirmation, return to “尚未配置”, and a later host-side listing. | Executor-recorded operation sequence. The later state receipt binds the same unique target, but does not provide an operation-time state transition or exclude intervening modification. |
| XCTest result and failure boundary | Attempt receipt identifies the first `.xcresult` and records `1 failed / 0 passed`, with failure in the post-deletion Files UI navigation/assertion. It records the second attempt ending before folder creation/sync/deletion. | These are the supplied executor summaries; I did not directly inspect the `.xcresult` bundles in this review. Preserve the first result as failed. The second attempt is not deletion evidence. |
| Production deletion scope and privacy boundary | Current `RimeSyncViewModel.disconnect(deleteRemoteData:)` calls the selected transport deletion before removing local credentials/configuration. The local-folder transport targets the private package root. The UI/privacy wording distinguishes that package from standard RIME data. The reinspection did not recurse into either child or read file contents. | Consistent with the claimed deletion boundary and data minimization. It does not prove that the provider state changed because of this call or that standard-data contents are correct. |
| Assignment exit criterion | `docs/assignments/rime-sync-001.md` requires the scoped local-folder deletion check and recorded Simulator/provider boundary; the readiness ledger marks this item pending fresh reviews. | Boundary is recorded, but the operation-level deletion check is not established strongly enough to close while intervening changes remain possible. |

## Finding dispositions

| Finding | Disposition | Basis |
|---|---|---|
| `QR-PROVIDER-DELETE-01` | **Open — Blocked** | The new receipt resolves the earlier missing-artifact issue and establishes the later provider state. The temporal gap leaves operation attribution unresolved. A new isolated run should record the privacy-safe provider state immediately after the production delete action, bound to that action and capture time. A green UI test is not required for this separate state evidence, but any test failure must retain its actual status. |
| `QR-XCTEST-BOUNDARY-01` | **Resolved as a reporting boundary; test remains failed** | The supplied attempt summary reports 1 failed / 0 passed at the post-delete Files UI query. The later filesystem snapshot does not convert the UI test into a pass. The second attempt did not reach deletion. |
| `QR-PRIVACY-01` | **No finding** | The state receipt limits inspection to the exact root, immediate names, existence and metadata; it reports no payload or dictionary-content reads. |
| `QR-SCOPE-01` | **Bounded** | One test-created folder in one Simulator `com.apple.FileProvider.LocalStorage` container only. |
| `TD-002` | **Open; unchanged** | This observation does not address cross-process access or exclusion risk. Retain `tech_debt:TD-002`. |

## Conditions and non-claims

- Keep the later snapshot and failed XCTest as separate evidence items. Do not describe the snapshot as contemporaneous, causal proof, or a successful Files UI assertion.
- If the deletion check is repeated, bind an immediate read-only listing of the exact provider root and two child states to the confirmed operation and capture time. Avoid recursive traversal or reading package/user-dictionary contents.
- No end-to-end test pass; no proof that the deletion call caused the 02:21 state; no Files UI refresh assertion; no physical-device, cross-device, cloud/third-party provider, WebDAV, CloudKit, crash/interruption recovery, standard-data correctness, or full portability claim.
- No resolution of `TD-002`, Product acceptance, Assignment completion/closure, merge, TestFlight or Release decision is made here.

## Handoff

The provider-deletion evidence condition remains blocked pending operation-correlated, privacy-safe state evidence and fresh Quality review. Product Lead retains the separate Assignment lifecycle decision. Preserve the original XCTest failure status and all scope limits in any later ledger update.
