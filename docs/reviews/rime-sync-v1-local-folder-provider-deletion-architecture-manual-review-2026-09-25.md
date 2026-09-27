# RIME-SYNC-001 — manual local-folder provider deletion Architecture review — 2026-09-25

## Verdict

**Accept with conditions — architecture boundary only, for the single iOS
Simulator Apple Files local-storage provider path.** The new manual observation
materially strengthens evidence of provider state after the production App's
delete-and-disconnect flow. It does not establish an automated end-to-end pass,
general provider behavior, or preservation of standard RIME directory contents.

This is a fresh independent Architecture review of the exact candidate below.
It does not make a Product lifecycle decision.

## Exact identity

- Repository: `/Users/doubleshy0n/.codex/worktrees/rime-sync-docs-close-20260923/Universe Keyboard`
- HEAD: `4a51228fc8e435d538e9a5f7342ae325502e1e66`
- Candidate paths: `64`
- Candidate manifest SHA-256: `bd73b5470d34d292b5f594ed5fc0c3723ebf32aac931c5908ac28d6b65b863d6`
- Manifest procedure: union `git diff HEAD --name-only -z` and
  `git ls-files --others --exclude-standard -z`, de-duplicate, sort path bytes,
  exclude only this Architecture receipt and its paired new Quality receipt,
  append each `shasum -a 256` output line including final LF, then SHA-256 the
  resulting bytes. The reviewer independently recomputed the count and digest;
  neither excluded receipt was in the candidate set at recomputation.
- Reviewer/runtime identity: independent Architecture reviewer; exact identity
  and model/runtime are `UNKNOWN` and not independently attestable.
- Inspection mode: retained artifacts and production source only; no Simulator,
  device, build, or test operation was performed; no files were edited by the
  reviewer.

## Assessment

The manual receipt records a first accessibility tap that did not take effect,
an explicit cancel, and then a refreshed confirmation followed by a successful
delete action. The App returned to “未设置”; the immediately subsequent listing
of the exact provider root showed `universe-rime-sync/` absent and the sibling
standard RIME directory present. This supports a strong temporal link to the
delete flow, but the button press was not independently timestamped and there
is no operation ID, structured event, or saved screenshot to correlate action
and listing independently. Installed metadata is recorded as 1.0 (1), while
source-to-executable provenance and executable digest are `UNKNOWN`.

In the inspected source, `disconnect(deleteRemoteData:)` awaits transport
deletion before clearing the local key and provider configuration. The
local-folder transport targets only
`<selected folder>/universe-rime-sync`; it does not target the provider root or
the sibling `universe-ios-*` standard RIME directory. This supports the
intended private-package versus standard-directory boundary. The observation
establishes presence of the standard directory only; it did not inspect its
contents and cannot prove all standard RIME data remained unchanged.

## Findings and residual dispositions

| Finding | Disposition | Boundary / pointer |
|---|---|---|
| `ARCH-RIME-SYNC-001-PROVIDER-2026-09-25-R1` | `accept` | Accept the architecture boundary for this observed Simulator local-provider state only; [manual evidence](../evidence/rime-sync-v1-local-folder-provider-deletion-manual-2026-09-25.md) and inspected `RimeSyncTransport.swift` / `RimeSyncViewModel.swift`. |
| `QR-PROVIDER-DELETE-01` | Quality disposition pending | The prior UI XCTest remains `1 failed / 0 passed` at its later Files UI query; see [attempt receipt](../evidence/rime-sync-v1-local-folder-provider-deletion-attempt-2026-09-25.md). This Architecture verdict does not relabel it. |
| `TD-002` | `tech_debt:TD-002` | Cross-process RIME / Keyboard Extension concurrency remains open; this deletion observation provides no concurrency evidence. |
| `TD-008` | `tech_debt:TD-008` | Full cross-platform compatibility remains deferred. |
| `TD-019` | `tech_debt:TD-019` | Live WebDAV validation and deletion semantics remain deferred. |
| `TD-013`, `TD-017` | Existing open technical debts | This observation does not change diagnostics/query or sandbox-extension attribution residuals; see [TECH_DEBT](../TECH_DEBT.md). |

CloudKit remains deferred. This review establishes no physical-device,
cross-device, cloud/third-party provider, WebDAV, interruption recovery, or
general deletion claim. It does not decide parent lifecycle, Product Gate,
merge, TestFlight, or Release.
