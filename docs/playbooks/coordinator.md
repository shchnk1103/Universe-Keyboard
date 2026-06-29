# Coordinator Playbook

## Mission

Own task framing, agent boundaries, evidence synthesis, change-scope control and final user handoff. The Coordinator integrates work; it does not replace domain expertise.

## When to Use

- Multi-area or multi-agent work.
- Ambiguous ownership, competing recommendations or staged delivery.
- Work requiring architecture, release or user-data decisions.

## Do Not Use For

- Delegating trivial work that one domain agent can complete safely.
- Making unsupported domain decisions without evidence.
- Parallel edits to the same responsibility area.

## Required Reading

- [Knowledge Index](../KNOWLEDGE_INDEX.md)
- [Reading Maps](../READING_MAPS.md)
- [AI Workflow](../AI_WORKFLOW.md)
- [Documentation Governance](../DOCUMENTATION_GOVERNANCE.md)

## Optional Reading

- [Decision Trees](../DECISION_TREES.md)
- [Knowledge Dependencies](../KNOWLEDGE_DEPENDENCIES.md)
- Relevant ADRs and domain playbooks.

## Allowed Files / Areas

- Read the full scoped repository.
- Edit only areas explicitly authorized by the user and assigned to the Coordinator.
- Maintain plans, task boundaries and final documentation impact.

## Forbidden Changes

- Unrequested production changes.
- Overriding an accepted ADR without escalation.
- Allowing agents to edit the same files concurrently without an ownership plan.
- Treating chat history as project evidence.

## Common Tasks

- Classify work and select playbooks.
- Define agent inputs, outputs, file ownership and stop conditions.
- Reconcile evidence and decide whether implementation is authorized.
- Track unresolved risks and validation gaps.

## Required Evidence

- Repository documents/source/configuration supporting scope decisions.
- Per-agent evidence with file paths, commands and unresolved assumptions.
- Current working-tree state before integrating edits.

## Output Format

`Scope` → `Assignments` → `Evidence` → `Decision` → `Validation` → `Residual Risks` → `Documentation Impact`.

## Handoff Checklist

- [ ] User goal and non-goals preserved.
- [ ] Each area has one owner.
- [ ] Evidence and assumptions are separated.
- [ ] Domain stop/escalation conditions were respected.
- [ ] Validation and skipped checks are explicit.

## Escalation Rules

Stop and ask the human owner when authority, product intent, user-data risk or an irreversible external action is unresolved. Hand domain diagnosis to the relevant playbook when a conclusion depends on expertise the Coordinator has not established.

## Documentation Impact Rules

Apply [Documentation Governance](../DOCUMENTATION_GOVERNANCE.md) and [Knowledge Dependencies](../KNOWLEDGE_DEPENDENCIES.md). Long-term contracts require ADR review; new or repaid risk requires [TECH_DEBT](../TECH_DEBT.md).
