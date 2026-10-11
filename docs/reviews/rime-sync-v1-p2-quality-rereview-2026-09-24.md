# RIME-SYNC-001 P2 deletion-boundary fresh Quality re-review — 2026-09-24

## Verdict

**P2 remediation scope: Pass with conditions.** This is an incremental Quality
conclusion for the deletion-boundary change and its focused evidence. It is not
a pass for the full 44-path candidate or the complete RIME-SYNC-001 Assignment.

## Exact snapshot binding

- Worktree: `/Users/doubleshy0n/.codex/worktrees/rime-sync-docs-close-20260923/Universe Keyboard`
- `HEAD`: `4a51228fc8e435d538e9a5f7342ae325502e1e66`
- Changed/untracked candidate paths: `44`
- Manifest algorithm: sorted union of `git diff --name-only --no-renames` and
  `git ls-files --others --exclude-standard`; each entry is SHA-256 of file
  bytes, two spaces, relative path, newline; SHA-256 of the concatenated entries.
- Manifest SHA-256:
  `533fa5e1ebf0a2e72b10f6001f85d6ce48a676ec3b19cf84396e96f57fb5acf7`
- This receipt is a review output and is excluded from the bound candidate.

## Independent review and evidence

- Fresh read-only review by an independent GPT-6 Luna Quality reviewer
  (agent `01a0d399-f4ef-7f71-bbc7-6310ae1b4c68`), without inherited thread
  context. The reviewer independently recomputed the path manifest and read the
  supplied `.xcresult`; it did not rerun the tests or modify files.
- iPhone 18 Pro / iOS 27.0 Simulator: **5 passed / 0 failed / 0 skipped**.
- `.xcresult`:
  `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-09-24T13-17-28-139Z_pid14565_c82f8a6c.xcresult`.
- The changed production and test Swift files pass strict `swift-format lint`;
  `git diff --check` passes.
- The evidence correctly states that credential-retention assertions use
  `MemoryRimeSyncSecretStore`, not real Keychain. It records the AppIntents
  metadata extraction build warning and raw Simulator App Group / IOHID log
  messages without diagnosing their cause or claiming a warning-free raw log.
  See the [P2 evidence](../evidence/rime-sync-v1-p2-deletion-boundary-remediation-2026-09-24.md).

## Coverage and conditions

The focused cases cover injected lookup failure, an injected unknown metadata
state with ViewModel configuration/secret-test-double retention, a same-name
regular file remaining untouched, confirmed absence as idempotent success, and
successful deletion of only the private package while standard RIME files
remain. Unknown metadata is supplied by an injected seam; behavior of a real
document provider is not established.

The earlier whole-candidate `Pass with conditions` remains bound only to its
original 38-path snapshot. The earlier P1 incremental Quality review remains
bound only to its 41-path snapshot. Neither is promoted to the current 44-path
candidate or a complete suite pass by this receipt.

## Non-claims

The full App + Keyboard suite, hosted CI, real document-provider metadata and
deletion propagation, real Keychain credential retention, physical-device
behavior, production background delivery, Product Gate, and Assignment close
were not established by this review.

## Snapshot reconciliation after status-sync corrections

The preceding review record was written with a manifest value that did not
match the reviewer's independently recomputed `6e8e0b…` value. The review above
therefore remains historical and must not be used as the exact identity receipt
for the corrected candidate. After correcting the stale `ACTIVE_WORK` row and
the Assignment Phase mirror, the current 44-path candidate (same `HEAD`) has
manifest SHA-256:

`2c09ee2f3eba9abf1511e09285548e437fea657c3762899eb5166f8cb75a4d2a`

A separate context-isolated read-only reviewer (`01a0d3a7-a9dc-7611-bba5-7c739dde5485`)
recomputed this value and returned **P2 deletion-boundary increment: Pass with
conditions**. It confirmed the corrected Assignment, ACTIVE_WORK, and Dashboard
state mirrors align; the five existing Simulator tests remain 5/5 from the
supplied `.xcresult`; no tests were rerun and no files were changed by the
reviewer. It also confirmed the P2 non-claims for real document-provider
semantics and real Keychain retention.

The reviewer could not attest its exact model identity, despite being requested
with the GPT-6 Luna override. Treat this result as an independent bounded
technical check, not as a model-identity-certified formal Quality receipt.
Architecture review, full-candidate Quality, hosted CI, Product Gate, and
Assignment close remain unestablished.
