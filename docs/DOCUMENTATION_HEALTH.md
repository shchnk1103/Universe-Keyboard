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
| Navigation integrity | All index links resolve and no orphan source exists | Link/file scan plus documentation graph review |

## Reproducible Inventory Commands

```bash
# ADR inventory and statuses
find docs/architecture/decisions -maxdepth 1 -type f -name '*.md' -print | sort
rg -n '^## Status|^Accepted|^Proposed|^Superseded|^Deprecated' docs/architecture/decisions

# Plans and lifecycle headers
find docs/plans -maxdepth 1 -type f -name '*.md' -print | sort
rg -n '^>.*(Status|状态)' docs/plans

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

- Collected: 2026-06-29 Asia/Shanghai.
- Base commit: `75a5e8c`; includes the current uncommitted Phase A/B/B.5/K documentation working tree.
- Commands: inventory commands above plus `git diff --check`.
- Evidence location: this working tree and current command output.
- Expiry: next monthly Knowledge Audit, important milestone, or any ADR/plan/debt/playbook lifecycle change.

Observed state:

| Area | Observation | Health |
|---|---|---|
| ADRs | Eight decision files exist and have required sections | Structurally healthy; coverage gaps remain possible |
| Plans | Five plans are marked historical/archived, but closure metadata is not yet governance-complete | Needs work |
| Technical debt | Seven canonical debt items exist | Healthy structure; status must be revalidated monthly |
| Navigation | Knowledge index, maps, graph and dependencies now exist | New; requires usage validation |
| Playbooks | Nine domain operating playbooks exist with required evidence, stop and handoff sections | Structurally healthy; independent task dry-runs remain pending |
| Volatile evidence | Manual acceptance/history still contains old counts, device/branch snapshots and temporary evidence paths | Governance debt |
| README scope | README still carries extensive feature/architecture details | Overloaded |
| Duplicate facts | Lifecycle, deployment, Full Access and UI constants appear in multiple long-lived documents | Requires ownership cleanup |

## Documentation Debt Queue

1. Run independent dry-runs of every playbook against real tasks and record routing failures.
2. Normalize all plan closure headers.
3. Reduce README to entry/quick-start/navigation responsibility.
4. Convert historical acceptance records to fully qualified snapshots with expiry/evidence retention.
5. Remove temporary branch/merge-readiness content from current architecture documents.
6. Resolve duplicated durable facts by preserving one owner plus links.
7. Decide whether OpenCC integration requires a rationale ADR.
8. Remove or explicitly manage tracked `.DS_Store` files under documentation directories.

## Knowledge Audit Record

Add one row per monthly/milestone audit. Detailed findings belong in the audit artifact or issue, not this table.

| Date | Scope | Base commit | Result location | Next trigger |
|---|---|---|---|---|
| 2026-06-29 | Knowledge OS v1.0 + Phase C playbook structure | `75a5e8c` + documentation working tree | `DOCUMENTATION_HEALTH.md` current snapshot | Independent playbook audit or next milestone |

## Health Gate

The Knowledge OS is not healthy merely because documents exist. A milestone fails documentation health when:

- a durable change has no owner/ADR;
- a plan appears current after closure;
- a release claim lacks reproducible evidence;
- a playbook requires historical chat to operate;
- an index route leads to conflicting facts;
- documentation debt is known but has no visible queue or owner area.
