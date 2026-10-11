# RIME-SYNC-001 — bounded iOS V1 parent Architecture review — 2026-09-25

## Verdict

**Accept with conditions** for the bounded iOS V1 local-folder architecture.
This is not a lifecycle decision. Before a separate Product lifecycle request,
reconcile the readiness ledger's stale status and obtain independent Quality
and Architecture conclusions on the final synchronized candidate.

## Exact identity

- Repository: `/Users/doubleshy0n/.codex/worktrees/rime-sync-docs-close-20260923/Universe Keyboard`
- HEAD: `4a51228fc8e435d538e9a5f7342ae325502e1e66`
- Candidate: `66` paths; SHA-256
  `08d16753aa41c9b64dc718fea0e55c1eaf95d0930fa1d8d77fc69b97d10bfad2`.
- The reviewer independently recomputed the candidate manifest and matched
  the expected count and digest.
- Reviewer/runtime: independent Architecture reviewer; exact model/runtime
  identity `UNKNOWN` and not independently verifiable.
- Review mode: read-only inspection of docs, evidence, source, and tests. No
  Simulator/build/test/CI was run and no files were edited.

## Architecture assessment

For the bounded local-folder path, the architectural boundary is acceptable:
the Main App owns standard RIME synchronization, the keyboard extension does
not perform sync/network work, and the Universe settings package uses a
separate encrypted transport path. Local deletion is limited to the
`universe-rime-sync` private package root; unknown or non-directory metadata
fails closed. The Main-App process gate does not prove mutual exclusion with
Keyboard Extension access to `Rime/user`; `TD-002` must remain open.

The current full App + Keyboard Simulator receipt reports 401 total, 391
passed, 10 skipped, 0 failed; native Xcode IDs match `.xcresult` IDs. The
402/401 MCP residual is accepted only for that exact run; cause is unknown and
the 10 skips are not passes. UI-01 and signed Keychain receipts remain scoped
evidence, not physical-device or hosted-CI proof. The manual deletion finding
is resolved only for the single Simulator Apple Files LocalStorage observed
state; the original UI XCTest remains 1 failed / 0 passed, no Files UI refresh
assertion or installed binary/source binding exists, and standard-directory
contents were not inspected. UI-02 residuals retain their Product-bounded
acceptance, not a formal pass. CloudKit is deferred; live WebDAV and full
cross-platform work remain TD-019 and TD-008. Run 02 remains `INVALID`; the
older exact error remains `UNKNOWN` under TD-013.

## Findings and residual dispositions

| Finding | Owner | Disposition | Pointer / condition |
|---|---|---|---|
| Readiness ledger still says the deletion evidence awaits fresh review and contains stale close-gate narration | Assignment Executor / documentation maintainer | `fix` | Update the ledger while preserving historical review states; then review the final synchronized candidate. [Ledger](../evidence/rime-sync-v1-closure-readiness-2026-09-23.md) and [Assignment current status](../assignments/rime-sync-001.md). |
| Independent Quality conclusion for the same complete 66-path parent candidate | Quality reviewer / Assignment | `fix` | The fresh parent Quality receipt has now been produced as a separate review result, but the current architecture review did not rely on it as an established independent conclusion at review time. Require matched final-snapshot Quality and Architecture disposition after ledger correction. |
| `QR-PROVIDER-DELETE-01` | Main App / Quality / Architecture | `fix` — completed for one observation only | Private package absent, standard directory present in the single Simulator local provider; [manual evidence](../evidence/rime-sync-v1-local-folder-provider-deletion-manual-2026-09-25.md). Does not relabel old XCTest. |
| Manual operation/capture correlation and installed-binary provenance | Assignment | `accept` as evidence limits | No separately timed click or operation ID; executable provenance remains `UNKNOWN`. [Manual Quality review](rime-sync-v1-local-folder-provider-deletion-quality-manual-review-2026-09-25.md). |
| `QR-CURRENT-01` | Quality / CI integration | `accept` for exact 402/401 run only | No MCP cause or future-run accuracy claim. [Product decision](../product-decisions/RIME-SYNC-001-QR-CURRENT-01-PRODUCT-RESIDUAL-2026-09-24.md). |
| UI-02 narrow-device and device/source-binding residual | Human owner / Quality | `accept` within bounded scope | No narrow-device pass or full accessibility-conformance claim. [Product decision](../product-decisions/RIME-SYNC-001-UI02-RESIDUAL-ACCEPTANCE-2026-09-24.md). |
| `TD-002` | Main App / RIME Platform | `tech_debt:TD-002` | Open cross-process RIME / Keyboard Extension concurrency risk. [Debt record](../TECH_DEBT.md#td-002-validate-rimeuser-concurrent-access). |
| `TD-008`, `TD-019`; CloudKit | Main App / RIME Platform | `tech_debt:TD-008`; `tech_debt:TD-019`; CloudKit deferred | Full portability and live WebDAV remain outside scope. [Assignment scope](../assignments/rime-sync-001.md). |
| `TD-013`, `TD-017` | Diagnostics / Main App RIME sync | `tech_debt:TD-013`; `tech_debt:TD-017` | Open; preserve unknown cause. [Debt record](../TECH_DEBT.md). |
| Run 02 `INVALID` | RIME-SYNC-001 Product / Quality | `accept` only as invalid history | Preserve historical `HOLD`; not a pass. [Run 02 receipt](../evidence/rime-background-sync-natural-device-run-2026-09-01-r2.md). |

No additional local-provider Simulator run is required for the current bounded
claim. This review does not authorize parent `Completed`, `Reviewed`, or
`Closed`, nor merge, TestFlight, or Release. Product lifecycle authority must
decide separately after final evidence/state synchronization.
