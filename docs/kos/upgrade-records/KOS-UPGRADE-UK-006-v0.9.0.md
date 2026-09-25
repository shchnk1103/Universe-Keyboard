# KOS Kit v0.9.0 Adopter Upgrade Record — KOS-UPGRADE-UK-006

## Review status

- Review baseline: Universe Keyboard remote `main` at
  `50cdccc8d07e70cb02987c9fe0a17be55291701d`.
- Upstream latest Release check: `v0.9.0`, verified from GitHub Release API on
  `2026-09-25`; immutable tag commit `c98b2813240e22b2ac7fec44b2445321b03f73e0`.
- Current adopted pin remains `v0.8.0` advisory until a separate Human Product
  disposition. No contract is adopted by this review record.
- Review evidence: [source freeze](../../evidence/kos-upgrade-uk-006-v0.9.0-source-freeze-2026-09-25.md),
  [Architecture review](../../reviews/KOS-UPGRADE-UK-006-v0.9.0-architecture-review.md),
  [Quality review](../../reviews/KOS-UPGRADE-UK-006-v0.9.0-quality-review.md).

## Baseline and target

- From: KOS Kit `v0.8.0`, commit `2c9907565bf6b6fcd00e698cc539d9e2db573bc5`;
  Universe Keyboard advisory pin remains `v0.8.0`.
- To assess: released KOS Kit `v0.9.0`, annotated tag object
  `4a386cdc07cc52a3da4d7cf77b429b874169becb` → commit
  `c98b2813240e22b2ac7fec44b2445321b03f73e0`.
- Release class: upstream marks it compatible minor with optional operational
  contracts. Release discovery alone does not adopt those contracts.
- Project owner: Human Product Owner; domain owner: Architecture & Knowledge
  Steward.

## Project applicability assessment

| Change | Existing Universe Keyboard boundary | Review assessment | Recommendation for a later Human decision |
|---|---|---|---|
| KOS 2.1 M-02 trigger identity and one-time closeout | The project already runs an M-02 checklist after Product Gate, ADR Accept, Assignment Close and lifecycle-changing tip-PR merges. It does not currently identify a trigger or define non-recursive closeout. | Directly applicable to the observed risk of a status-sync PR being treated as a new trigger for another status-sync PR. The Kit rule retains separate later triggers and independent closures. It does not turn all documentation edits into M-02 triggers. | Adopt the v0.9.0 M-02 addition for future state-sync events. Record Work Item, exact event and authority record; include merged tip PR/commit for merge events; let the same closeout transaction finish without recursively triggering itself. No historical backfill. |
| Bounded independent-review dispatch | Universe adopted the optional agent-orchestration contract for future multi-agent/multi-provider assignments but has not instantiated a repository-wide `ORCHESTRATION_PLAN.md`. Existing tasks retain their own recorded scope/budgets. | The v0.9.0 addition addresses the reported scope expansion and repeated corrective-prompt pattern. It requires a per-lane frozen packet, positive acceptance/coverage criteria, allowed/excluded inputs and operations, budget checkpoints, a stop rule, and explicit Assignment Authority for any scope/budget extension. Incomplete coverage becomes Partial/incomplete, never Pass. | Adopt the updated optional orchestration clauses for newly assigned independent review lanes. Do not retroactively rewrite or migrate Active Assignments; do not require a global plan for work that does not use independent agent orchestration. |
| `kos.release-evidence` v1.0 | UK-005 already adopted this contract prospectively for new release-evidence records/handoffs and implemented a Universe-owned adapter/profile. | The v0.9.0 contract source, standalone schema and evaluator are byte-identical to the already-adopted UK-005 candidate. This Kit release adds a released identity for unchanged bytes; it does not create a second contract or invalidate existing UK-005 reviews. | Preserve UK-005's existing decision and profile. Do not repeat its contract adoption, alter its pins, or migrate its work solely because the unchanged contract is now in a Kit release. A future new Assignment may cite the v0.9.0 release identity while preserving the existing adopted content digest. |
| Core / validator / required mode | `.kos/project.json` is advisory; frozen Knowledge OS 2.0 owns authority and lifecycle; existing Active Assignments remain pinned. | The reviewed v0.9.0 changes are optional operations. They do not alter frozen core, existing record schema, the project's validator mode, Product/Quality authority, or historical evidence. | Keep `record_envelopes.mode=advisory`; no schema/validator enforcement change, no `required` cutover and no Active-Assignment migration. |

## Review conclusion boundary

The package recommends a bounded future Product disposition: adopt Kit `v0.9.0`
in advisory mode for new M-02 closeouts and new independent review lanes, while
preserving UK-005's existing `kos.release-evidence` adoption as-is. This is a
recommendation only; Architecture and Quality reviews do not make the Product
decision.

The v0.9.0 release does not address Simulator/CoreDevice discovery or
Accessibility/Device Hub health classification. That remains a separate,
project-specific operational improvement and is not a blocker or claimed fix
within this Upgrade Review.

No `required` mode, Active-Assignment migration, historical backfill, project
implementation, validator change, device operation, commit, push, PR, merge or
Release is authorized by this record.
