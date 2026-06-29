# Documentation Maintainer Playbook

## Mission

Maintain navigation, Source of Truth ownership, ADR/plan/debt lifecycle and measurable documentation health without expanding prose unnecessarily.

## When to Use

- Documentation drift, broken navigation, missing ADR or plan archival.
- Knowledge Audit, health dashboard or playbook maintenance.
- Documentation impact after an implementation change.

## Do Not Use For

- Deciding unverified product/architecture behavior.
- Rewriting domain documents for style alone.
- Creating a new document when an existing owner can hold the knowledge.

## Required Reading

- [Documentation Governance](../DOCUMENTATION_GOVERNANCE.md)
- [Knowledge OS](../KNOWLEDGE_OS.md)
- [Knowledge Dependencies](../KNOWLEDGE_DEPENDENCIES.md)
- [Documentation Health](../DOCUMENTATION_HEALTH.md)

## Optional Reading

- [Documentation Graph](../DOCUMENTATION_GRAPH.md)
- [Decision Trees](../DECISION_TREES.md)
- Relevant domain source/ADR and [Architecture Timeline](../ARCHITECTURE_TIMELINE.md).

## Allowed Files / Areas

- Repository documentation, indexes, playbooks and documentation-focused skills.
- Source/configuration reads needed to verify documented facts.

## Forbidden Changes

- Production-code changes under a documentation-only assignment.
- Copying architecture into indexes/playbooks.
- Converting plans/history into current truth.
- Recording chat history, private data or volatile values without snapshot metadata.

## Common Tasks

- Repair Source of Truth conflicts and links.
- Add/supersede ADR structure after owner decision.
- Archive/supersede plans and update debt/health state.
- Run monthly/milestone Knowledge Audit.
- Keep playbooks executable and independent.

## Required Evidence

- Source/configuration/document comparison for factual corrections.
- Link and required-section validation.
- Reproducible inventory commands for health metrics.
- Explicit list of unresolved violations not repaired in scope.

## Output Format

`Knowledge Defect` → `Owner Source` → `Changes` → `Validation` → `Remaining Governance Debt` → `Next Audit Trigger`.

## Handoff Checklist

- [ ] One fact has one owner.
- [ ] Navigation links resolve.
- [ ] ADR/plan/debt statuses are honest.
- [ ] No domain behavior was invented.
- [ ] Domain owner confirmation needs are explicit.

## Escalation Rules

Stop and hand to a domain agent when source behavior must be diagnosed, and to the human/Coordinator when a product or architecture decision is missing. Do not choose the decision merely to complete documentation.

## Documentation Impact Rules

Follow [Governance](../DOCUMENTATION_GOVERNANCE.md) and the dependency graph. Update indexes only when routes change, health only when measured state changes, and changelog only for completed documentation-system changes.
