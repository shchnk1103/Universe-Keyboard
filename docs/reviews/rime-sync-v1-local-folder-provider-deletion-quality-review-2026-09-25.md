# RIME-SYNC-001 — local-folder provider deletion — independent Quality review — 2026-09-25

## Conclusion

**Blocked** for the provider-deletion close evidence condition. The available record supports that the production UI flow reached and confirmed “删除并断开”, and that the enclosing XCTest failed later in Files UI navigation. It does not preserve independently inspectable raw evidence of the provider directory state after deletion. Therefore this review cannot verify that `universe-rime-sync/` was absent while the RIME standard-data directory remained. The XCTest is **not** a pass.

This is a bounded evidence review, not Product acceptance, Assignment completion, or a lifecycle decision. `RIME-SYNC-001` remains `Active`; no Product decision is made here.

## Snapshot and reviewer boundary

| Item | Value |
|---|---|
| Repository/worktree | `/Users/doubleshy0n/.codex/worktrees/rime-sync-docs-close-20260923/Universe Keyboard` |
| HEAD | `4a51228fc8e435d538e9a5f7342ae325502e1e66` |
| Candidate paths | 58, after excluding this Quality receipt and the paired Architecture receipt |
| Manifest SHA-256 | `65374606d7322aea52756a6c7ff457ea805452c5859880f8e977f983dc29382c` |
| Manifest recomputation | Union `git diff HEAD --name-only -z` and `git ls-files --others --exclude-standard -z`; de-duplicate; sort path bytes in UTF-8/C-locale order; exclude the two named review receipts; for each remaining path append the `shasum -a 256` output line with LF; SHA-256 the resulting bytes including the final LF. Independently recomputed: 58 paths and the digest above; both excluded receipt paths were absent from the candidate set at recomputation. |
| Reviewer/model identity | Codex review runtime. The requested GPT-6 Luna identity is **not available/attestable in this runtime**; this receipt does not claim to have been produced by GPT-6 Luna. |
| Review mode | Read-only review of repository documents, result-bundle summaries/activity metadata, and current test source. No tests run; no Simulator/device operated; no provider contents changed or inspected; no production files edited. |

## Evidence matrix

| Claim | Evidence and grade | Quality assessment |
|---|---|---|
| The action was scoped to a test-created local Files folder on one simulator | `Executor-recorded`: [provider deletion attempt](../evidence/rime-sync-v1-local-folder-provider-deletion-attempt-2026-09-25.md) names iPhone 18 Pro Max / iOS 27.0 / build `24A434`, UDID `C1B96097-D5CD-4FE3-BF01-C2C6B7DDDE20`, provider `com.apple.FileProvider.LocalStorage`, and unique folder `Universe-Rime-Sync-0757F4BD`. | Good scope/isolation description. This is not physical-device, cloud-provider, or cross-device evidence. |
| Production deletion flow was invoked after explicit confirmation | `Quality-reverified` from the first `.xcresult` activity timeline: the test tapped “删除云端数据并断开”, observed the confirmation alert and explanatory copy, then tapped “删除并断开”. Bundle: `/Users/doubleshy0n/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-09-24T17-52-12-930Z_pid14565_c881324b.xcresult`. | Confirms the UI action sequence, not successful provider-state deletion or the App's post-operation “尚未配置” state. The latter is stated in the executor receipt but no corresponding captured assertion/result is supplied. |
| The first XCTest completed end-to-end | `Quality-reverified`: `xcresulttool` summary reports `Failed`, 1 failed, 0 passed, 0 skipped. The failure/test-node evidence places the failure after the deletion confirmation, in subsequent Files browsing/navigation and assertion. | **Not passed.** A later UI-query failure does not disprove an independently captured provider-state observation, but it cannot itself prove that state. |
| A second attempt independently corroborates deletion | `Executor-recorded` in the attempt receipt; second bundle: `/Users/doubleshy0n/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-09-24T17-56-58-614Z_pid14565_76c6326c.xcresult`. | It stopped before folder creation/sync/deletion and is not corroborating deletion evidence. |
| Private package absent and RIME standard data retained after the operation | `Executor-recorded` summary in the attempt receipt. | The receipt provides the asserted names and scope, but not the contemporaneous read-only listing/metadata output, exact provider-root path, capture command/time, or a retained state artifact bound to this operation. I did not inspect the provider contents. This key close claim is therefore not independently verifiable from the supplied artifacts. |
| First-sync path was previously exercised | Separate `Executor-recorded` first-sync receipt and `.xcresult`, described in [first-sync evidence](../evidence/rime-sync-v1-local-folder-simulator-first-sync-2026-09-24.md). | Corroborates setup/production transport path only; it predates and does not verify deletion. |

## Findings

| ID | Status | Finding / required evidence |
|---|---|---|
| `QR-PROVIDER-DELETE-01` | **Open — Blocked** | Provider-state deletion is summarized but its contemporaneous read-only observation is not retained in an independently reviewable form. Provide a privacy-safe artifact bound to the exact Simulator UDID, provider container, unique folder, and post-confirmation time that shows the private package absent and the RIME standard-data directory retained. Do not read or emit package plaintext or user-dictionary contents. This can be a separately captured read-only provider listing/state record; a green XCTest is not required to misrepresent the current failed run, but the test must remain recorded as failed unless rerun successfully. Owner/handoff: Assignment Executor → fresh Quality re-review. |
| `QR-XCTEST-BOUNDARY-01` | **Resolved for this review** | The first result bundle is correctly classified as 1 failed / 0 passed, with the failure after the delete-confirmation tap in Files UI navigation/query. The second attempt did not reach deletion. Neither result may be counted as a passing end-to-end test. |
| `QR-SCOPE-01` | **Bounded / no new finding** | The attempt is isolated to one test-created iOS Simulator Files local-storage folder. No inference to real devices, other providers, WebDAV, CloudKit, or propagation to another device. |
| `QR-REVIEWER-MODEL-01` | **Open — Assignment to requested model not met** | This runtime cannot attest GPT-6 Luna. The review is transparent about its actual runtime and must not be represented as a GPT-6 Luna review. If the Assignment requires the specified model identity, obtain a fresh review from that model after the provider-state evidence is available. |

## Privacy, reproducibility, and exit-gate assessment

- Positive privacy boundary: the executor reports that no encrypted package payload or user-dictionary contents were read. This reviewer did not inspect provider contents.
- Isolation and result-bundle identities are sufficiently specific to distinguish the two attempts. The first bundle independently establishes the failed test and post-confirmation Files navigation failure; the second is explicitly pre-deletion.
- Reproducibility remains partial: the result bundle can reproduce the XCTest failure classification and action timeline, but the source used for the temporary deletion test was reverted and is not present in the current candidate. More importantly, the provider-state listing itself is not retained, so this review cannot reproduce or independently validate the claimed absence/preservation result without a new authorized capture.
- The RIME-SYNC-001 Exit Criteria require the scoped local-folder deletion check and a recorded provider boundary. The receipt documents the boundary and an executor-observed state, but the missing inspectable state artifact prevents Quality from confirming that this evidence condition is satisfied.
- Existing 401/391/10 full-suite evidence and the prior 53-path Quality/Architecture reviews do not cover this deletion observation and do not change this finding. `TD-002` remains open and unresolved.
- No assignment lifecycle, residual disposition, or Product acceptance is inferred. KOS 2.1 M-03 and the Assignment's separate Product lifecycle gate remain in force.

## Non-claims

No passing end-to-end XCTest; no independently verified provider-state deletion; no Files UI refresh assertion; no physical-device, cross-device, cloud/third-party provider, WebDAV, CloudKit, interruption-recovery, or full portability claim; no resolution of `TD-002`; no Product Gate, Assignment completion/closure, merge, TestFlight, or Release conclusion.

## Handoff

Preserve both failed result bundles and the explicit failure boundary. If Quality is to re-evaluate provider deletion, supply a privacy-safe, operation-correlated read-only provider-state artifact as described in `QR-PROVIDER-DELETE-01`, then request a fresh independent review from the required reviewer/model. Do not delete or alter unrelated Simulator/provider content to obtain that evidence.
