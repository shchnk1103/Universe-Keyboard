# RIME-SYNC-001 — bounded iOS V1 parent Quality review — 2026-09-25

## Verdict

**Pass with conditions** for the user-bounded iOS V1 local-folder engineering
scope. This is a Quality conclusion only; it is not a Product lifecycle
decision or parent closure authorization.

## Exact identity

- Repository: `/Users/doubleshy0n/.codex/worktrees/rime-sync-docs-close-20260923/Universe Keyboard`
- HEAD: `4a51228fc8e435d538e9a5f7342ae325502e1e66`
- Candidate: `66` paths; SHA-256
  `08d16753aa41c9b64dc718fea0e55c1eaf95d0930fa1d8d77fc69b97d10bfad2`.
- The reviewer independently recomputed the candidate manifest and matched
  the expected path count and digest.
- Reviewer/runtime: independent Quality reviewer reported model family GPT-6;
  exact model/runtime identity is `UNKNOWN` and was not independently
  attestable.
- Review mode: read-only inspection of current source, tests, docs, and
  evidence. No file edits or Simulator/build/test reruns were performed.

## Assessment

- Full App + Keyboard Simulator result: **401 total; 391 passed, 10 skipped,
  0 failed**. Xcode's 401 native IDs match the `.xcresult` IDs. Product's
  `QR-CURRENT-01` acceptance is limited to this run's 402/401 MCP reporting
  residual; cause remains unknown. Skips are not passes.
- Full `UniverseKeyboardUITests` receipt: 29 passed, 7 skipped, 0 failed.
  The focused UI-01 matrix and signed Keychain + RIME transport 11/11 remain
  separately scoped evidence, not part of the full-suite total. They do not
  establish physical-device Keychain or hosted-CI behavior.
- The manual local-provider deletion supplement and its exact 64-path reviews
  support `QR-PROVIDER-DELETE-01` disposition `fix` for one Simulator Apple
  Files LocalStorage observed-state check: the private package root was absent
  and the standard RIME directory remained after the production App flow.
  The earlier deletion UI XCTest remains **1 failed / 0 passed**. The manual
  action has no `.xcresult`, Files UI refresh assertion, independently timed
  click/operation ID, or source-bound installed binary. The standard RIME
  directory's presence is established, not its contents or immutability.

## Residual ledger

| Item | Owner | Disposition | Boundary / pointer |
|---|---|---|---|
| `QR-PROVIDER-DELETE-01` | Main App / Quality / Architecture | `fix` | Resolved only for the observed single Simulator Apple Files LocalStorage state; [manual evidence](../evidence/rime-sync-v1-local-folder-provider-deletion-manual-2026-09-25.md) and [delta reviews](rime-sync-v1-local-folder-provider-deletion-quality-manual-review-2026-09-25.md). |
| Failed provider-deletion UI XCTest | Main App / Quality | `accept` as a reporting boundary | Preserve `1 failed / 0 passed`; the manual observation does not convert it to a pass. [Attempt receipt](../evidence/rime-sync-v1-local-folder-provider-deletion-attempt-2026-09-25.md). |
| Manual action/capture correlation and installed-binary provenance | Assignment | `accept` as explicit evidence-strength limitations | No independently timed action or operation ID; installed executable/source binding is `UNKNOWN`. [Manual Quality review](rime-sync-v1-local-folder-provider-deletion-quality-manual-review-2026-09-25.md). |
| `QR-CURRENT-01` | Quality / CI integration | `accept` for the exact 2026-09-25 402/401 report only | No MCP cause or future-run accuracy claim; 10 skips remain unverified. [Full-suite receipt](../evidence/rime-sync-v1-current-app-keyboard-full-suite-2026-09-25.md). |
| UI-02 narrow-device/source binding residuals | Human owner / Quality | `accept` within Product-bounded iOS V1 scope | Not a UI-02 pass or full accessibility conformance claim. [Product decision](../product-decisions/RIME-SYNC-001-UI02-RESIDUAL-ACCEPTANCE-2026-09-24.md). |
| `TD-002` cross-process RIME / Keyboard Extension concurrency | Main App / RIME Platform | `tech_debt:TD-002` | Open risk; not mitigated by the sync observations. [Debt record](../TECH_DEBT.md#td-002-validate-rimeuser-concurrent-access). |
| Full cross-platform compatibility / live WebDAV / CloudKit | Main App / RIME Platform | `tech_debt:TD-008`; `tech_debt:TD-019`; CloudKit deferred | Outside the present local-folder closure. [Assignment scope](../assignments/rime-sync-001.md). |
| Diagnostics/query and sandbox-extension attribution | Diagnostics / Main App RIME sync | `tech_debt:TD-013`; `tech_debt:TD-017` | Both remain open; do not infer root cause from later successes. [Debt record](../TECH_DEBT.md). |
| Run 02 `INVALID` and old exact error `UNKNOWN` | RIME-SYNC-001 Product / Quality | `accept` only as invalid historical record; old error under `tech_debt:TD-013` | Do not call Run 02 a pass or guess the old error. [Readiness ledger](../evidence/rime-sync-v1-closure-readiness-2026-09-23.md). |
| Readiness ledger current-status drift | Assignment Executor / documentation maintainer | `fix` | The ledger still used pending language for the now-reviewed manual provider supplement and had stale close-gate narration. Update before a separate lifecycle request, then obtain final-snapshot review. [Ledger](../evidence/rime-sync-v1-closure-readiness-2026-09-23.md). |

No additional Simulator deletion run is required for the bounded provider-state
claim. Before a Product lifecycle request, reconcile the readiness ledger's
stale status and have the final synchronized candidate reviewed. Parent remains
`Active`; Product lifecycle authority must decide separately.
