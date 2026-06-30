# Knowledge Dependencies

## Purpose

This file routes documentation review when knowledge changes. “Review” means inspect for impact; update only when the owned fact or procedure changed.

## Dependency Direction

```text
Accepted decision
  -> current architecture/domain source
       -> debugging and performance procedure
            -> release acceptance
                 -> playbooks and reading maps

Implementation evidence
  -> current source or technical debt
       -> changelog history

Owner-confirmed task state / handoff / blocker
  -> ENGINEERING_DASHBOARD summary

Governance
  -> health checks
       -> pre-push enforcement
```

Navigation/index files are downstream consumers. They should change only when routes or document responsibilities change.

## Change Impact Matrix

| If this changes | Must review | Usually unaffected unless route changes |
|---|---|---|
| ADR status/decision | `PROJECT_CONTEXT`, relevant architecture/domain source, `DEBUGGING`, `RELEASE_CHECKLIST`, `TECH_DEBT`, reading maps, playbooks | README, glossary wording |
| `PROJECT_CONTEXT` module/boundary | reading maps, graph, glossary, debugging/release when behavior changed, playbooks | changelog history |
| Shared-container/RIME lifecycle | ADR 0001/0003/0004, `DEBUGGING`, `RELEASE_CHECKLIST`, performance baseline, RIME playbook | UI style |
| Input/marked-text contract | ADR 0002, Partial Commit, `DEBUGGING`, release device checks, KeyboardCore/UI playbooks | artifact management |
| RIME domain source | applicable ADRs, debugging, release, glossary, RIME playbook | onboarding beyond links |
| OpenCC integration | `architecture/opencc-integration.md`, applicable ADRs, shared-container lifecycle, debugging, release, performance method, RIME playbook | generic README detail |
| Lua/RIME artifacts | relevant domain/architecture source, debugging, release, performance method, tech debt | generic README detail |
| `DEBUGGING` procedure | release evidence if gate changed, reading maps, bug-investigator playbook | architecture rationale |
| `PERFORMANCE_BASELINE` method | release performance gate, performance playbook, health evidence | product feature docs |
| Typo Benchmark Registry ID/relationship/version | `TYPO_BENCHMARK`, `PERFORMANCE_BASELINE`, Partial Commit when referenced, release evidence, reading maps/index/graph | runtime and tests unless a separately approved implementation task changes them |
| `RELEASE_CHECKLIST` | test/release playbook, reading maps, governance if responsibility changed | current architecture |
| `TECH_DEBT` item/status | related ADR/plan, release gate if risk blocks release, health dashboard | README |
| plan lifecycle/status | changelog when work completed, current source and ADR links, health dashboard | architecture unless behavior changed |
| target/module add/remove | `PROJECT_CONTEXT`, reading maps, graph, onboarding, playbooks, release/build commands | ADR only if decision is durable |
| governance | index/graph, pre-push skill, health metrics, playbook format | domain architecture |
| playbook | `AI_WORKFLOW`, reading maps/index if role or route changes, documentation health | domain facts |
| permanent team ownership/bootstrap contract | `VIRTUAL_ENGINEERING_TEAM`, `AGENTS`, knowledge index, reading maps, graph, governance, affected playbooks and documentation health | domain architecture unless the system boundary also changed |
| owner-confirmed task status, handoff or blocker | `ENGINEERING_DASHBOARD`, then linked owner sources for consistency | Registry, ADRs, Product Contracts, runtime and tests unless their owning facts changed separately |

## Impact Algorithm

1. Name the changed fact or procedure.
2. Locate its owner in `DOCUMENTATION_GOVERNANCE.md`.
3. Update the owner first.
4. Follow the corresponding matrix row downward.
5. For each dependent, record `update`, `reviewed/no change`, or `not applicable`.
6. Check for a required ADR or technical-debt transition.
7. Run pre-push governance review.

## Prohibited Dependency Patterns

- `CHANGELOG -> current behavior` as the only path.
- `playbook -> copied architecture` with no link to its owner.
- `README -> detailed feature state` maintained independently.
- `plan -> production contract` after the plan closes.
- `health dashboard -> manually copied counts` without reproducible commands and snapshot metadata.
- `ADR -> implementation status claim` when implementation remains pending.
- `TYPO_BENCHMARK`, performance or archived plans -> copied Canonical Registry definitions instead of links.
- `VIRTUAL_ENGINEERING_TEAM -> copied architecture or playbook procedure` instead of links to their owners.
- `ENGINEERING_DASHBOARD -> new Product, Architecture or Quality decision` without confirmation from the owning role and source.

## Adding A New Knowledge Source

Before adding a document, define:

- its single responsibility;
- its Source of Truth category;
- its upstream inputs and downstream consumers;
- the reading maps that require it;
- what existing document will link rather than duplicate;
- its retirement or archive condition.

If these cannot be stated, add a link or section to an existing owner instead of creating a file.
