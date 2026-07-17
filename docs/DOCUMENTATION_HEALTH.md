# Documentation Health

## Purpose

This dashboard makes knowledge quality observable without turning manually maintained counts into permanent truth. Metrics are produced by commands; snapshots require evidence metadata and expire at the next monthly audit or important milestone.

## Health Dimensions

| Dimension | Healthy condition | Measurement |
|---|---|---|
| Discoverability | Every major task has a reading route | Review `READING_MAPS.md` against modules/targets and recent work |
| Authority | No fact has competing owners | Search duplicate durable claims; verify governance ownership |
| Decision coverage | Durable contracts have accepted ADRs | Compare governance ADR triggers with recent architecture/product changes |
| Plan hygiene | Every plan has valid lifecycle/closure metadata | Inspect headers under `docs/plans/` |
| Operational coverage | Known failure/release paths are actionable | Audit `DEBUGGING`, performance and release against recent incidents |
| Debt integrity | Risks have correct mitigation, owner and trigger | Review `TECH_DEBT.md` against source and completed work |
| Evidence quality | Snapshots carry date/commit/environment/command/location/expiry | Inspect acceptance and performance records |
| Playbook independence | Agents can work without copied chat context | Execute playbook dry-run against reading maps and current sources |
| Ownership continuity | Every stable capability has one long-term owner and a reusable bootstrap | Review `VIRTUAL_ENGINEERING_TEAM.md` against reading maps, playbooks and recent work |
| Navigation integrity | All index links resolve and no orphan source exists | Link/file scan plus documentation graph review |
| Registry integrity | Canonical IDs are unique and all Contract/Case/Performance/Alias targets resolve | Registry structural scan plus downstream duplicate-authority review |

## Reproducible Inventory Commands

```bash
# ADR inventory and statuses
find docs/architecture/decisions -maxdepth 1 -type f -name '*.md' -print | sort
rg -n '^## Status|^Accepted|^Proposed|^Superseded|^Deprecated' docs/architecture/decisions

# Plans and lifecycle headers
find docs/plans -maxdepth 1 -type f -name '*.md' -print | sort
rg -n '^> \*\*Status:\*\*' docs/plans

# Technical-debt inventory
rg -n '^## TD-' docs/TECH_DEBT.md

# Volatile-data and stale-routing candidates; results require human review
rg -n 'tests passed|[0-9]+ tests|iPhone [0-9]+|codex/|feature/' README.md CONTEXT_INDEX.md docs .claude/skills

# Repository documentation inventory
find docs -type f -name '*.md' -print | sort
```

Counts are derived output. Do not copy them into README, PROJECT_CONTEXT or indexes.

## Current Baseline Snapshot

Snapshot metadata:

- Collected: 2026-07-17 Asia/Shanghai.
- Base: working tree for DOC-HYGIENE-001 (builds on KOS-MIG-001 single-track authority).
- Commands: inventory commands above, local Markdown link scan, ADR identity uniqueness check, plan header enum scan, `git diff --check`.
- Evidence location: [`evidence/doc-hygiene-001-audit.md`](evidence/doc-hygiene-001-audit.md).
- Expiry: next monthly Knowledge Audit, important milestone, or any ADR/plan/debt/playbook lifecycle change.

Observed state:

| Area | Observation | Health |
|---|---|---|
| ADRs | 19 decision files; dual `0017` collision resolved (continuation stays 0017; notifications renumbered to 0019) | Structurally improved |
| Plans | All plans declare governance lifecycle enum in header | Improved |
| Assignment lifecycle | Closed KOS-GOV-001 and ENV-TOOLING-001 headers synchronized with Dashboard | Improved |
| Navigation | Knowledge index, maps, graph, kos single-track, slim README entry | Healthy for entry |
| Playbooks | Nine domain playbooks present | Structurally healthy; dry-runs still pending |
| Permanent ownership | Virtual Engineering Team blueprint present | Needs dry-run validation |
| Volatile evidence | Historical acceptance/history may still contain old snapshots | Residual governance debt |
| README scope | Reduced to entry/quick-start/navigation | Improved |
| Duplicate facts | Domain durable-fact duplication outside ADR renumber still possible | Residual |

## Documentation Debt Queue

1. Run independent dry-runs of every playbook against real tasks and record routing failures.
2. Dry-run permanent bootstrap prompts and Typo → Input Intelligence evidence handoff.
3. Resolve remaining duplicated durable facts (lifecycle, deployment, Full Access, UI constants) by one owner + links.
4. Convert historical acceptance records to fully qualified snapshots with expiry/evidence retention where still missing.
5. Decide whether OpenCC integration requires a rationale ADR (if still open).
6. Keep Typo Benchmark Registry structural checks current as new Canonical IDs, aliases or supersessions are approved.
7. Optionally ignore or clean local untracked `.DS_Store` under `docs/` (not git-tracked).

Completed in DOC-HYGIENE-001 (removed from active queue):

- Normalize plan closure/lifecycle headers to governance enum.
- Reduce README to entry/quick-start/navigation responsibility.
- Resolve dual ADR `0017` identity collision.

## Knowledge Audit Record

Add one row per monthly/milestone audit. Detailed findings belong in the audit artifact or issue, not this table.

| Date | Scope | Base commit | Result location | Next trigger |
|---|---|---|---|---|
| 2026-07-17 | DOC-HYGIENE-001 documentation hygiene | working tree at hygiene closure | `docs/evidence/doc-hygiene-001-audit.md` | Playbook dry-run or next monthly audit |
| 2026-07-17 | KOS-MIG-001 operational single-track migration | KOS-MIG-001 commit on `docs/kos-mig-001` | `docs/kos/migration-001-record.md` | Further Migration Assignment if domain tree moves needed |
| 2026-06-29 | Knowledge OS v1.0 + Phase C playbook structure | `75a5e8c` + documentation working tree | historical snapshot superseded by 2026-07-17 baseline | — |
| 2026-06-29 | Virtual Engineering Team v1.0 ownership blueprint | Current documentation working tree | `VIRTUAL_ENGINEERING_TEAM.md` | Permanent-thread dry-run or ownership change |
| 2026-06-30 | Typo Correction Benchmark Registry v1.0 publication | `3cb5a6c` + existing documentation working tree | `TYPO_BENCHMARK_REGISTRY.md`, ADR 0009 and validation output | Registry version change, evidence-reference change or `TYPO-BENCHMARK-004B` review |

### 2026-06-30 Registry Publication Snapshot

- Scope: `TYPO-BENCHMARK-006B` documentation governance only.
- Registry: version `1.0.0`, 51 Canonical Contracts, 71 Canonical Cases and 17 frozen performance measurement profiles.
- Structural checks: unique Contract/Case IDs; every Case Primary Contract resolves; all secondary, Alias and Performance example targets resolve; `TC-CASE-EXP-004` and `TC-CASE-EXP-005` remain independent.
- Link check: all repository-local Markdown file links resolve.
- Formatting: `git diff --check` passed; new Registry/ADR files also passed trailing-whitespace and end-of-file checks.
- Change boundary: documentation only; no production source, test, Runtime, algorithm, behavior or Benchmark Case changed.
