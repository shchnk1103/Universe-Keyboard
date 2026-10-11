# Product Decision: TYPO-CORRECTION-002 runtime-integration hardening blocker remediation

> **Decision ID:** `PD-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-HARDENING-BLOCKER-REMEDIATION-001`
>
> **Decision:** `Accepted — repair the exact Architecture blockers before Quality`
>
> **Date:** `2026-09-22 Asia/Shanghai`

## Decision

Human Product Owner / Product Lead accepts the independent Architecture
`Blocker` verdict as an engineering constraint, not as an accepted product
residual. Product directs one new, bounded remediation slice before any
independent Quality review.

| Input | Disposition |
|---|---|
| [Hardening Architecture review](../reviews/typo-correction-002-runtime-integration-hardening-architecture-review-2026-09-22.md) | Accepted as the authoritative source-level blocker finding |
| Review worktree HEAD / tree | `4d1050f4b677494e06448cb40a83ef2da46d7b27` / `5f864a6f6f139810ed59c7e00ab6c33caad7e500` |
| Independently reproduced hardening delta | `003c2e004764f96a83fa437262ac49e1b34952a13e523aa2ee9d7fe6d595a319` |
| Preserved implementation diff | `d1366181e0436242211aa496934792e90a6ab1b0454608f0e1c3dd5a17ef4c1b`; must remain untouched |
| Preserved pure-Core checkpoint | `8bb105c5381feb43fc41ec168fd239fd7c864cc0efa739cae3976beb685ebbab`; must remain untouched |

## Required remediation outcomes

1. Production canary/P3D1 must invalidate the recall operation before mutating
   responsive/thread-affine route or bootstrap state.
2. A yielded RunLoop continuation must be bound to the operation that scheduled
   it, so an old continuation cannot advance a newer operation after
   invalidation.
3. The controller must prove one `state.typoCorrection` writer for every
   recall operation, including fallback/default timing before an owner wrapper
   is installed; default, MainActor-responsive and thread-affine routes require
   a no-bypass owner/adapter contract.

The exact implementation must stay in a new isolated worktree. Before source
execution, Human Product Owner reassigned the still-unconsumed Authorization
from **Grok** to the current Codex task under the dedicated docs-only
reassignment receipt. The historical Grok handoff remains retained; the
Authorization remains `active` until a separate execution start is recorded.

### Handoff clarification

The reviewed predecessor is an uncommitted snapshot. Product therefore
authorizes its byte-identical sixteen-path bootstrap into Grok's new isolated
worktree, with before/after identity checks, solely as an implementation input.
This clarification does not authorize edits outside the listed remediation
paths and does not itself start Grok execution.

## Explicit non-decisions

This decision does not accept any blocker as a residual. It does not authorize
source execution yet, Quality review, real RIME, deployment, Simulator/device
capture, QA-001, INT-003, paired performance or 180 ms evidence. It also does
not authorize commit, push, PR, merge, TestFlight, Release, any Gate or any
Assignment Close.

**Decision source:** Human Product Owner / Product Lead, current task
instruction `授权按照你的建议继续进行下一步`, `2026-09-22 Asia/Shanghai`.
