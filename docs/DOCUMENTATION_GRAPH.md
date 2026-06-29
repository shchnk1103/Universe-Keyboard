# Documentation Graph

## Purpose

This map describes relationships between knowledge sources. It does not explain implementation.

```text
AGENTS
  -> KNOWLEDGE_INDEX
       -> READING_MAPS
            -> PROJECT_CONTEXT
                 -> architecture documents
                      -> ADRs
            -> DEBUGGING / PERFORMANCE_BASELINE
            -> RELEASE_CHECKLIST
            -> TECH_DEBT

DOCUMENTATION_GOVERNANCE
  -> KNOWLEDGE_DEPENDENCIES
  -> DOCUMENTATION_HEALTH
  -> pre-push-review

CHANGELOG + archived plans
  -> ARCHITECTURE_TIMELINE
  -> ADRs/current sources (never the reverse authority)
```

Arrows mean “navigate to” or “depends on”; they do not transfer Source of Truth ownership.

## Major Document Contracts

| Document | Purpose | Readers / timing | Answers | Deliberately does not answer |
|---|---|---|---|---|
| `AGENTS.md` | Repository collaboration rules | Every agent, first | What behavior is mandatory? | Architecture or task-specific procedure |
| `README.md` | Public/project entry | First visit | What is this project and how do I enter? | Durable rationale or exhaustive status |
| `KNOWLEDGE_INDEX.md` | Pure navigation | Every new thread after AGENTS | Where should I go? | Domain facts |
| `KNOWLEDGE_OS.md` | Knowledge operating model | Maintainers, doc authors | How is repository knowledge organized? | Current product architecture |
| `READING_MAPS.md` | Task-based routing | Before implementation | What must I read for this task? | The content of those sources |
| `PROJECT_CONTEXT.md` | Current architecture overview | Any code/architecture task | What modules and boundaries exist? | Historical chronology or troubleshooting |
| `architecture/*.md` | Current subsystem contracts | Relevant subsystem change | How does this boundary currently work? | Why every decision was selected |
| `architecture/decisions/*` | Durable rationale | Before contract changes | Why this decision and what alternatives? | Step-by-step debugging or release procedure |
| `DEBUGGING.md` | Diagnostic entry and flows | Bug investigation | What evidence and boundary should I inspect? | Release approval or architecture history |
| `PERFORMANCE_BASELINE.md` | Measurement method | Performance work/release | How should performance be measured? | Invented targets or current architecture rationale |
| `RELEASE_CHECKLIST.md` | Release gates and evidence | Release/test work | What must pass before release? | Why architecture exists |
| `TECH_DEBT.md` | Canonical unresolved risk | Planning/review | What is intentionally incomplete and when must it be fixed? | Feature roadmap |
| `DOCUMENTATION_GOVERNANCE.md` | Documentation rules | Doc authors/reviewers | What owns a fact and when must docs change? | Task navigation details |
| `KNOWLEDGE_DEPENDENCIES.md` | Documentation impact routing | When a source changes | Which documents require review? | Whether implementation is correct |
| `DOCUMENTATION_HEALTH.md` | Observable knowledge quality | Monthly/milestone audit | Where is knowledge drift accumulating? | Detailed domain fixes |
| `GLOSSARY.md` | Project vocabulary routing | New contributors/ambiguity | What does this term mean here? | Full subsystem behavior |
| `ARCHITECTURE_TIMELINE.md` | Evolution of architecture | Historical orientation | Why did the system move between models? | Current status without following links |
| `DECISION_TREES.md` | Change-classification workflow | Before planning/review | What governance path applies? | Domain implementation instructions |
| `ONBOARDING.md` | Staged learning | New humans/agents | What should I learn and in what order? | A substitute for current task sources |
| `AI_WORKFLOW.md` | Multi-agent roles/handoffs | Complex delegated work | How are agents coordinated? | Domain architecture copied into prompts |
| `playbooks/*` | Executable domain operating boundaries | Assigned agent before work | What may this agent do, prove and hand off? | Domain architecture or ADR content |
| `CHANGELOG.md` | Dated completed changes | Regression/history research | What happened? | Current contracts |
| `plans/*` | Temporary milestone intent/history | Active work or archaeology | What was planned for this stage? | Current truth after archival |

## Domain Dependencies

```text
Keyboard UI
  -> UI_STYLE_GUIDE
  -> PROJECT_CONTEXT
  -> input-pipeline-and-marked-text (when interaction changes input)

RIME
  -> shared-container-and-rime-lifecycle
  -> ADR 0001 / 0003 / 0004 / 0008
  -> rime-artifacts (binary changes)

OpenCC
  -> opencc-integration
  -> shared-container-and-rime-lifecycle (ownership)
  -> DEBUGGING / PERFORMANCE_BASELINE / RELEASE_CHECKLIST (operations)

User dictionary
  -> RIME_USER_DICTIONARY
  -> ADR 0003 / 0005
  -> TECH_DEBT TD-002 / TD-007

Release
  -> RELEASE_CHECKLIST
  -> PERFORMANCE_BASELINE
  -> DOCUMENTATION_HEALTH
  -> current domain acceptance documents
```

## Graph Integrity Rules

- Entry documents point downward; domain sources do not repeat entry maps.
- Historical documents point forward to current sources.
- Playbooks point to domain sources; domain sources do not depend on playbooks.
- ADRs may link to current architecture, but architecture summaries link back to ADR rationale.
- A circular link is acceptable for navigation; circular ownership is not.
