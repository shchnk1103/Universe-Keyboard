# Documentation Governance

## Purpose

This document governs how project knowledge is created, updated, reviewed and retired. Its goal is to keep repository knowledge accurate after chat history disappears. It does not replace domain documentation.

## Source Of Truth

Every fact has one primary document. Other documents may provide a short summary and link to that source, but must not maintain a competing copy.

| Knowledge type | Primary source | Boundary |
|---|---|---|
| Knowledge navigation and operating model | `docs/KNOWLEDGE_INDEX.md`, `docs/KNOWLEDGE_OS.md` | Routes and knowledge-system behavior only; no domain implementation |
| Project entry and quick start | `README.md` | Entry, minimum setup and important links only; avoid volatile implementation detail |
| Current architecture and module boundaries | `docs/PROJECT_CONTEXT.md` | Current overview, ownership boundaries and development entry points |
| Current OpenCC integration mechanics | `docs/architecture/opencc-integration.md` | RIME filter/config participation and cross-target responsibility boundary; operational steps remain in debugging/performance/release sources |
| Long-term architecture/product rationale | `docs/architecture/decisions/` | Why a durable decision exists, alternatives and consequences |
| Troubleshooting procedures | `docs/DEBUGGING.md` | Diagnostic flows, evidence and common failure boundaries |
| Release and acceptance procedure | `docs/RELEASE_CHECKLIST.md` | Current release gates and required evidence |
| Performance measurement | `docs/PERFORMANCE_BASELINE.md` | Measurement method and collected evidence requirements; no invented budgets |
| Typo Benchmark Contract/Case/Performance identity | `docs/TYPO_BENCHMARK_REGISTRY.md` | Canonical IDs, relationships, aliases and version only; behavior, measurement procedure and evidence status remain in their owning sources |
| Known unresolved engineering risk | `docs/TECH_DEBT.md` | Risk, mitigation, owner area, recommended fix and resolution trigger |
| Changes that already happened | `CHANGELOG.md` | Dated historical record; never the authority for current behavior |
| Stage-specific implementation work | `docs/plans/` | Temporary plan and milestone context; archive or supersede after use |
| Agent operating procedure | subagent playbooks | How an agent works, required inputs/outputs and boundaries; link to architecture instead of copying it |

When two documents describe the same fact, select one primary source and replace the other copy with a link or a clearly non-authoritative summary. If source and implementation disagree, treat the discrepancy as a defect: verify current behavior, then correct the source of truth and affected links.

## Mandatory Documentation Triggers

Every change in the following areas must include a documentation-impact review. Update the primary document in the same change when the documented fact changes:

- Keyboard Extension lifecycle or visibility behavior;
- RIME deployment, runtime or session behavior;
- App Group or shared-container directories, files, keys or ownership;
- marked text, commit, candidate, Delete, Space or Return semantics;
- fallback engine behavior;
- Full Access capability, degradation or privacy behavior;
- user dictionary learning, backup, restore or migration;
- schema download, installation, deployment, update or rollback;
- Lua, OpenCC or RIME binary artifacts;
- adding, deleting or moving a module;
- adding or deleting an Xcode/SPM target;
- an important user-visible feature;
- a complex bug whose cause/invariant must survive the current thread;
- introducing, changing priority of or resolving technical debt;
- test, build, release or acceptance workflow.

Documentation impact may be "no update required", but an important PR must state why. Silence is not evidence that documentation was considered.

## ADR Rules

Create or supersede an ADR when a change introduces:

- a long-term architecture decision;
- a durable product contract;
- a choice between multiple viable approaches;
- a cross-target ownership or lifecycle boundary;
- a user-data safety decision;
- a decision affecting Extension lifecycle, RIME, Lua, OpenCC, Full Access or release strategy.

Every ADR must contain:

- `Status`
- `Context`
- `Decision`
- `Alternatives Considered`
- `Consequences`
- `Risks`
- `Follow-up Work`
- `Related Documents`

An ADR must explain why the selected approach exists and why meaningful alternatives were not selected. A file that only lists implementation changes belongs in a plan or changelog, not an ADR.

Use these statuses consistently:

- `Proposed`: under review and not binding.
- `Accepted`: binding decision.
- `Accepted; implementation pending`: binding direction with an explicit implementation gap.
- `Superseded by ADR NNNN`: retained for history but no longer binding.
- `Deprecated`: retained temporarily while dependants migrate.

Do not edit an accepted decision into a different decision without recording supersession or a clearly justified amendment.

## Volatile Data Policy

Long-lived documents must not hardcode values that become stale without changing the underlying contract:

- test counts;
- file or document line counts;
- temporary simulator names;
- temporary branch/worktree names;
- one-off physical-device conclusions;
- performance numbers that have not been reverified;
- planned feature status presented as current capability.

Prefer commands, discovery steps, stable constraints or links to current evidence. When a volatile value is necessary for an acceptance record or historical comparison, record all of:

- collection date and timezone;
- exact commit/build;
- device and OS;
- command or measurement method;
- evidence location;
- expiry/revalidation condition.

Historical values must be labelled as snapshots and must not be copied into current architecture or quick-start claims.

## Plan Lifecycle

Every file under `docs/plans/` must declare exactly one lifecycle state near the top:

- `Active`
- `Archived`
- `Superseded`
- `Abandoned`

When work ends, the plan header must include:

- current status;
- completion/closure date;
- current source of truth;
- related ADRs, or an explicit statement that no ADR was required;
- a statement that the plan is no longer current development guidance.

`Superseded` plans must link to their replacement. `Abandoned` plans must state why the work stopped. Plans may preserve historical implementation notes, but current behavior must live in the appropriate architecture, debugging, release or product document.

## Changelog Rules

`CHANGELOG.md` records what happened and when. It is not:

- the authority for current architecture;
- the authority for current capability;
- a debugging handbook;
- a release handbook.

If a changelog entry contains durable knowledge, promote that knowledge to its primary source and link or summarize it from the changelog. Do not require future engineers to reconstruct current rules by reading chronological history.

## Subagent Playbook Rules

Playbooks define how an agent operates: responsibilities, required reading, allowed scope, prohibited actions, evidence, output and handoff. They must link to `PROJECT_CONTEXT`, ADRs and domain documents rather than copying architecture facts. A changed architecture contract therefore updates one source, not every playbook.

## Documentation Review Checklist

For every important PR or substantial Codex change, check:

- [ ] Did architecture change?
- [ ] Did a product contract change?
- [ ] Did user data or its safety model change?
- [ ] Did Extension lifecycle change?
- [ ] Did RIME, Lua or OpenCC behavior change?
- [ ] Did tests, build, release or acceptance change?
- [ ] Is a new or superseding ADR required?
- [ ] Must `DEBUGGING.md` change?
- [ ] Must `RELEASE_CHECKLIST.md` change?
- [ ] Must `TECH_DEBT.md` add, update or remove an item?
- [ ] Does the change introduce volatile hardcoded data?
- [ ] Is the same fact maintained in more than one document?
- [ ] Is a plan presented as current implementation truth?
- [ ] If no documentation changed, is the reason explicit and defensible?

## Monthly And Milestone Knowledge Audit

Run a focused Knowledge Audit monthly or after every important milestone, whichever occurs first. The audit is read-only unless its scope explicitly includes repairs.

At minimum, report:

- documentation/source conflicts;
- missing, obsolete or unsuperseded ADRs;
- missing debugging paths;
- missing release/acceptance gates;
- drift in technical-debt priority, mitigation or completion state;
- plans requiring archive, supersession or abandonment;
- README details that belong in another source of truth;
- whether subagent playbooks can still operate independently without chat history.

Each finding must name the primary source to update, severity and recommended owner area. Do not resolve drift by copying the same fact into more files.

Record the measurable snapshot and audit history in `docs/DOCUMENTATION_HEALTH.md`; keep detailed remediation in the owning source, debt register or tracked work item.

## Enforcement

- `CONTEXT_INDEX.md` routes readers to primary sources.
- `pre-push-review` applies the review checklist before commit/push.
- Reviewers block changes that alter a durable contract without updating its source of truth or ADR.
- Documentation-only changes still run `git diff --check` and link/status validation appropriate to their scope.
