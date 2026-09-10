# Assignment: KOS-UPGRADE-UK-004 — 审查 KOS Kit v0.8.0

Policy version: 1.0.0

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Closed |
| Current Phase | Human Product Owner adopted v0.8.0 advisory; optional contracts apply only through explicit opt-in on new records |
| Material non-claims | 未启用 `required`；不迁移现有 Active Assignment；不实施 H-02/W-01；未授权 commit、push、merge、Release |
| Next handoff / decision | Future opt-in Assignment uses the adopted policy; `required`、H-02/W-01 或范围变化需新 Assignment |
| Residuals | No blocking document-review finding. Historical compatibility reviews remain non-adoption evidence. |

---

## Authority

- Assignment Authority / Product Approver: Human Product Owner acting as Product Lead.
- Decision Source / Date: current Codex session, `2026-09-10 Asia/Shanghai`; Human Product Owner approved `Adopted` after the completed document-only Architecture and Quality review handoff.

## Boundary

- Scope: freeze and assess the released Kit `v0.8.0` against the project’s adopted `v0.7.0` advisory baseline; determine the project fit and required local constraints for E-01, A-01/B-01, P-01 and D-01 on future Universe Keyboard Assignments; repair the known advisory-pin wording drift.
- Non-goals: automatically adopt any Kit contract; change KOS 2.0 core/schema/validator or this project's `required` mode; instantiate H-02/W-01; migrate an Active Assignment; modify Swift, CI, devices, RIME privacy policy, merge or Release.
- Required Inputs: locally verified [Kit v0.8.0 Release](https://github.com/shchnk1103/kos-agent-kit/releases/tag/v0.8.0) annotated tag `530d1b7` → commit `2c990756`; current [`UPGRADE_STATUS`](../kos/UPGRADE_STATUS.md); v0.7.0 adoption record; the upstream `KOS-PORTABLE-OPS-001` Product Decision, Assignment, evidence and independent reviews; this project’s Assignment Policy and AI Workflow; the frozen [`upgrade record`](../kos/upgrade-records/KOS-UPGRADE-UK-004-v0.8.0.md).

## Assignment

- Domain Owner / Executor: Architecture & Knowledge Steward / current Codex executor in isolated worktree `codex/kos-v080-upgrade-review`.
- Environment Executor: Not Applicable — this slice reads source records and edits no runtime, device, account or release environment.
- Human Dependency: Human Product Owner — future adoption, merge, tag, Release and any required-mode decision.
- Architecture Reviewer: independent, read-only runtime `/root/v080_architecture_review` in logical lane `KOS-UPGRADE-UK-004/document-architecture`; it may only append its own review record and must not edit the governance packet.
- Quality Reviewer: independent, read-only runtime `/root/v080_quality_review` in logical lane `KOS-UPGRADE-UK-004/document-quality`; it may only append its own review record and must not edit the governance packet.

## Gates and Handoff

- Entry: this Assignment; current v0.7.0 baseline; locally verified v0.8.0 tag/commit/source blobs; isolated worktree.
- Exit: document-only findings and dispositions for the exact governance packet; explicit current/new/Active boundaries; independent Architecture and Quality conclusions; a Human Product Adopted, Deferred or Not applicable decision.
- Stop: any automatic adoption/migration; inferred upstream facts beyond the locally frozen source map; a need to change core/schema/validator/`required`; product, project CI, device or implementation evaluation; missing reviewer independence.
- Handoff Target: independent reviewers, then Human Product Owner.
- Required Handoff Content: v0.7.0/v0.8.0 source map, applicability matrix, validation and privacy implications, residuals, disposition and revalidation trigger.
- Revalidation Trigger: upstream release/source changes; proposed adoption scope; active-assignment boundary; independent review finding; or Product decision.

## History

- `2026-09-10 Asia/Shanghai`: Established by Human Product Owner authorization. The upstream v0.8.0 release is recorded as Deferred while this Upgrade Review is active; no project adoption or runtime change is authorized.
- `2026-09-10 Asia/Shanghai`: The executor froze the upstream tag, commit and relevant source blobs in the upgrade record, issued the project-fit assessment, and bound the two independent read-only review lanes. This is preparation for review, not an A-01 authorization frontier or a Product adoption decision.
- `2026-09-10 Asia/Shanghai`: The first independent reviews found current-entry version drift, a freshness timestamp mismatch and missing future owner mapping. The executor repaired only those documentation findings in scope. Because the four frozen inputs changed, both reviewer lanes must issue addenda before any Product disposition.
- `2026-09-10 Asia/Shanghai`: Independent re-review addenda completed: [Architecture](../reviews/KOS-UPGRADE-UK-004-v0.8.0-architecture-review.md) = `Pass` (`P0/P1/P2/P3 = 0/0/0/1`); [Quality](../reviews/KOS-UPGRADE-UK-004-v0.8.0-quality-review.md) = `Pass with conditions` (`0/0/0/2`). Both retain their explicit non-claims. The only remaining action is a Human Product disposition; no contract is adopted by either review.
- `2026-09-10 Asia/Shanghai`: Product clarification: UK-004 requires a document-only governance review. The earlier compatibility-focused reviews remain historical inputs, but do not close this handoff. The independent lanes are rebound to assess only the frozen governance packet's source ownership, status/navigation mirrors, scope/non-claims, review binding and documentation validation receipts; no product implementation, CI/device sufficiency, upstream test sufficiency or adoption conclusion is in scope.
- `2026-09-10 Asia/Shanghai`: The final document-only delta reviews both passed with `P0/P1/P2/P3 = 0/0/0/0`; see the [Architecture review](../reviews/KOS-UPGRADE-UK-004-v0.8.0-architecture-review.md) and [Quality review](../reviews/KOS-UPGRADE-UK-004-v0.8.0-quality-review.md). This Current Status update is their derived mirror, not a further contract change or adoption decision.
- `2026-09-10 Asia/Shanghai`: Human Product Owner approved `Adopted`. The project pin is `v0.8.0` advisory; E-01, A-01/B-01, P-01 and D-01 apply only when future new records explicitly opt in. This closes UK-004 locally; commit, push, merge and Release remain separate actions.
