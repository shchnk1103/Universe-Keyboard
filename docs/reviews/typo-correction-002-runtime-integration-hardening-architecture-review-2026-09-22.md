# Architecture review: TYPO-CORRECTION-002 runtime-integration hardening

## Verdict

**Blocker** — 当前 hardening 快照的身份已经独立复现，但仍存在三项未闭合的
源码级 Architecture blocker。因此不得直接进入独立 Quality review，也不产生
任何 publication、产品或运行时结论。

## Review identity and method

| Field | Value |
|---|---|
| Reviewer | Independent Architecture & Knowledge Steward（Hubble sub-agent；非 hardening Executor） |
| Assignment | [`TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-001`](../assignments/typo-correction-002-runtime-integration-hardening-001.md) |
| Authorization | [`AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-ARCHITECTURE-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-ARCHITECTURE-001.md)，本审查消费 |
| Review worktree | `/Users/doubleshy0n/.codex/worktrees/typo-correction-002-runtime-integration-hardening-001/Universe Keyboard` |
| Method | 只读核对身份与源码；未编辑、未 test/build、未触发 RIME、Simulator、设备、capture、commit、push、PR 或 merge |

审查员阅读了当前 Assignment/Authorization、前序设计与审查、输入/marked-text、
共享容器/RIME 生命周期、ADR 0004 和 Swift 6 合同，并检查 coordinator、
ModeActions、sidecar owner、Core typo correction、RimeBridge adapter 与
Bootstrap 入口。

## Independent identity recomputation

| Item | Independent result | Disposition |
|---|---|---|
| Review HEAD | `4d1050f4b677494e06448cb40a83ef2da46d7b27` | matches |
| Review tree | `5f864a6f6f139810ed59c7e00ab6c33caad7e500` | matches |
| Review current `git diff HEAD \| shasum -a 256` | `7eb4b6714c27230c212ec9b7ad398b9dc419291c9aaf4303cdb12b4532a68d95` | recorded observation |
| Preserved implementation tracked diff | `d1366181e0436242211aa496934792e90a6ab1b0454608f0e1c3dd5a17ef4c1b` | matches |
| Preserved pure-Core checkpoint diff | `8bb105c5381feb43fc41ec168fd239fd7c864cc0efa739cae3976beb685ebbab` | matches; unchanged |
| Authorized hardening delta | `003c2e004764f96a83fa437262ac49e1b34952a13e523aa2ee9d7fe6d595a319` | independently reproduced |

The hardening delta was reproduced by emitting a `diff -u` for each of the
six authorized hardening files, in the Assignment-recorded order, with stable
preserved/hardening labels, and SHA-256 hashing that concatenated stream.
There is no identity-recipe residual.

## Findings

| ID | Severity | Result | Disposition |
|---|---:|---|---|
| Q-01 | Medium | `Pass with conditions`: coordinator is `@MainActor`; yielded callback creates `Task { @MainActor ... }`; no `Task.detached` or direct cross-actor call found. | Quality must independently prove warnings-as-errors compilation; no compiler-success claim here. |
| F-01 page/mode/owner | Medium | Named page toggle, changed-target page cycle, empty-composition mode toggle and sidecar-owner replacement now invalidate first. | Source-level pass. |
| F-01 canary/P3D1 | High | **Blocker**: production canary/P3D1 change responsive/thread-affine flags and bootstrap before a later `installTypoCorrectionSidecarOwner` invalidation. | Input Intelligence / Keyboard UI must invalidate before route/bootstrap mutation, or Product must explicitly accept this Architecture residual. |
| F-01 yielded callback ownership | High | **Blocker**: RunLoop continuation has neither operation token nor cancellable task handle. A stale callback after invalidation and before/after a new operation can statically advance the current driver. | Add callback-generation or operation-token fencing, then re-review the exact new snapshot. |
| F-03 empty/budget stop | Medium | `Pass with conditions`: empty joined material returns before Core apply; candidate bar refresh requires a successful apply and still-current fence. | Structural display no-op is source-visible; tests were not re-run. |
| F-03 legacy hot path | High | **Blocker / UNKNOWN**: active-recall early return depends on an installed wrapper; fallback/default query may reach the coordinator before that owner is installed. Unique writer for an operation is not proven. | Prove wrapper installation before every recall entry, or move lifetime authority to a controller-owned contract. |
| F-03 fences/lifetime | High | `Pass with conditions`: query-before/query-after/final-apply/refresh fences and most terminal paths exist. | Cannot close while stale callback and fallback-owner blockers remain. |
| RIME / sidecar ownership | High | No new live session, deployment or file work entered recall code; but default, MainActor-responsive and thread-affine no-bypass proof is incomplete. Canary/P3D1 still use `CandidateProviderTypoCorrectionQuery`. | RimeBridge Maintainer must close three-route adapter/owner proof. |
| marked-text / host commit | Low | Pass at source boundary: no new `TextInputClient`, `insertText`, `setMarkedText`, pasteboard or live-RIME selection route. | No runtime claim. |
| privacy / diagnostics | Low | Pass with conditions: no new persistent receipt or raw-text logging; F-04 remains `tech_debt`. | Out of scope for this fix slice. |

## Residual ownership

| Residual | Owner | Disposition |
|---|---|---|
| Canary/P3D1 invalidate-first order and yielded callback ownership | Input Intelligence Maintainer / Keyboard UI | `fix` |
| Fallback unique `state.typoCorrection` writer / recall lifetime | Input Intelligence Maintainer | `fix` or a newly accepted Architecture residual |
| Default, MainActor-responsive and thread-affine adapter/no-bypass proof | RimeBridge Maintainer | `fix` or a newly accepted Architecture residual |
| Re-review changed exact snapshot | Independent Architecture & Knowledge Steward | required after fix |
| Quality review | Independent Quality, Performance & Release Maintainer | blocked until Architecture blockers close |
| F-04 diagnostics | Input Intelligence Maintainer | `tech_debt` |

## Non-claims

This review does not claim test/build/format/hosted-CI success, compiler
elimination of `#ActorIsolatedCall`, complete lifecycle coverage, real RIME
candidates, QA-001, INT-003, paired performance or 180 ms. It also does not
claim Simulator/device/capture, Product/Quality/Release Gate, commit, push,
PR, merge, TestFlight, Release or Assignment Close.
