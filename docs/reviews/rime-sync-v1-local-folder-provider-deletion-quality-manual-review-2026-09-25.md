# RIME-SYNC-001 — manual local-folder provider deletion Quality review — 2026-09-25

## Verdict

**Pass with conditions — `QR-PROVIDER-DELETE-01` is resolved as `fix` for the
single iOS Simulator Apple Files local-storage provider observation.** The
manual evidence now records the selected isolated folder before deletion, the
explicit delete-and-disconnect flow, the App's resulting unconfigured state,
and the immediately subsequent provider-root listing: the private package
root is absent and the standard RIME directory remains. The evidence is
sufficient for this bounded observed-state check. It is not an automated
end-to-end test pass or a general provider-deletion claim.

This is a fresh independent Quality review of the exact candidate below. It
does not decide Product lifecycle.

## Exact identity

- Repository: `/Users/doubleshy0n/.codex/worktrees/rime-sync-docs-close-20260923/Universe Keyboard`
- HEAD: `4a51228fc8e435d538e9a5f7342ae325502e1e66`
- Candidate paths: `64`
- Candidate manifest SHA-256: `bd73b5470d34d292b5f594ed5fc0c3723ebf32aac931c5908ac28d6b65b863d6`
- Manifest procedure: union `git diff HEAD --name-only -z` and
  `git ls-files --others --exclude-standard -z`, de-duplicate, sort path bytes,
  exclude only this Quality receipt and its paired new Architecture receipt,
  append each `shasum -a 256` output line including final LF, then SHA-256 the
  resulting bytes. The reviewer independently recomputed the count and digest;
  neither excluded receipt was in the candidate set at recomputation.
- Reviewer/runtime identity: independent Quality reviewer reported current
  Codex GPT-6; exact model variant and reviewer-to-executor runtime
  independence are `UNKNOWN`, not independently verifiable.
- Inspection mode: retained evidence and source inspection only; no Simulator,
  device, build, or test was rerun; no files were edited by the reviewer.

## Evidence assessment

The ordered record distinguishes the first accessibility tap that did not
take effect (followed by cancel) from the later explicit confirmation that
returned the App to “未设置”. The immediately subsequent listing of the exact
provider root contained only the standard `universe-ios-*` directory;
`universe-rime-sync/` was absent. The receipt identifies the Simulator UDID,
provider, unique folder, root, and capture time, and records that no payload,
dictionary, recovery-code value, or user input was read or retained.

The reviewed disconnect implementation awaits the provider deletion before
clearing local key/configuration. This corroborates the recorded operation
sequence. The successful button press itself has no independent timestamp,
operation UUID, structured diagnostic event, or retained screenshot, so action
to listing correlation remains executor-recorded and time-adjacent rather than
independently instrumented. The installed bundle metadata is `1.0 (1)`;
source-to-executable binding and executable digest are `UNKNOWN`.

The prior provider-deletion XCTest remains **1 failed / 0 passed** at its later
Files UI query. This manual evidence does not repair, rerun, or relabel that
test. No `.xcresult` exists for this manual operation.

## Finding disposition

| Finding | Disposition | Owner / pointer |
|---|---|---|
| `QR-PROVIDER-DELETE-01` | **Resolved as `fix` for the bounded Simulator LocalStorage state observation** | Assignment Executor; [manual receipt](../evidence/rime-sync-v1-local-folder-provider-deletion-manual-2026-09-25.md). This does not establish a passing UI assertion or broader deletion semantics. |
| `QR-XCTEST-BOUNDARY-01` | Resolved as a reporting boundary; test remains failed | Preserve `1 failed / 0 passed` in the [attempt receipt](../evidence/rime-sync-v1-local-folder-provider-deletion-attempt-2026-09-25.md). |
| `QR-CAUSALITY-01` | `accept` as an explicit evidence-strength limit for this bounded observation | Owner: Assignment. The action/capture interval has no independently timed operation receipt; retain this qualification in the [manual receipt](../evidence/rime-sync-v1-local-folder-provider-deletion-manual-2026-09-25.md). |
| `QR-BINARY-PROVENANCE-01` | `accept` as an explicit non-claim for this bounded manual observation | Owner: Assignment. Installed app is reported as 1.0 (1), but executable/source binding is `UNKNOWN`; retain in the [manual receipt](../evidence/rime-sync-v1-local-folder-provider-deletion-manual-2026-09-25.md). |
| `TD-002` | `tech_debt:TD-002` | Cross-process RIME / Keyboard Extension concurrency remains open; this evidence does not address it. |

## Conditions and non-claims

- The claim is limited to one manual production-App path against one Apple
  Simulator Files local-storage folder. The standard RIME directory's
  presence is established, not its contents or immutability.
- No XCTest pass, Files UI refresh assertion, device/cross-device result,
  cloud/third-party provider behavior, live WebDAV, CloudKit, interruption
  recovery, background-scheduling result, or resolution of `TD-002` is
  established.
- CloudKit remains deferred; WebDAV validation remains in `TD-019`; full
  cross-platform compatibility remains in `TD-008`.
- No Product Gate, Assignment completion/closure, merge, TestFlight, or Release
  conclusion is made. The parent remains `Active` pending its other exit
  criteria and a separate Product lifecycle decision.
