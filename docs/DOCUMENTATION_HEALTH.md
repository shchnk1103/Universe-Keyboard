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
| Permanent ownership | Seven long-term roles are defined; short-term Typo ownership has an explicit handoff to Input Intelligence | New; validate with long-lived-thread dry-runs |
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
9. Dry-run the permanent bootstrap prompts and verify that Typo transition handoffs preserve benchmark, ranking, learning and regression evidence.
10. Keep the Typo Benchmark Registry structural checks current as new Canonical IDs, aliases or supersessions are approved.

## Knowledge Audit Record

Add one row per monthly/milestone audit. Detailed findings belong in the audit artifact or issue, not this table.

| Date | Scope | Base commit | Result location | Next trigger |
|---|---|---|---|---|
| 2026-06-29 | Knowledge OS v1.0 + Phase C playbook structure | `75a5e8c` + documentation working tree | `DOCUMENTATION_HEALTH.md` current snapshot | Independent playbook audit or next milestone |
| 2026-06-29 | Virtual Engineering Team v1.0 ownership blueprint | Current documentation working tree | `VIRTUAL_ENGINEERING_TEAM.md` | Permanent-thread dry-run or ownership change |
| 2026-06-30 | Typo Correction Benchmark Registry v1.0 publication | `3cb5a6c` + existing documentation working tree | `TYPO_BENCHMARK_REGISTRY.md`, ADR 0009 and validation output | Registry version change, evidence-reference change or `TYPO-BENCHMARK-004B` review |

### 2026-06-30 Registry Publication Snapshot

- Scope: `TYPO-BENCHMARK-006B` documentation governance only.
- Registry: version `1.0.0`, 51 Canonical Contracts, 71 Canonical Cases and 17 frozen performance measurement profiles.
- Structural checks: unique Contract/Case IDs; every Case Primary Contract resolves; all secondary, Alias and Performance example targets resolve; `TC-CASE-EXP-004` and `TC-CASE-EXP-005` remain independent.
- Link check: all repository-local Markdown file links resolve.
- Formatting: `git diff --check` passed; new Registry/ADR files also passed trailing-whitespace and end-of-file checks.
- Change boundary: documentation only; no production source, test, Runtime, algorithm, behavior or Benchmark Case changed.
- Evidence boundary: publication does not mark any Case or Performance Scenario passed and does not authorize Task 7.

## Health Gate

The Knowledge OS is not healthy merely because documents exist. A milestone fails documentation health when:

- a durable change has no owner/ADR;
- a plan appears current after closure;
- a release claim lacks reproducible evidence;
- a playbook requires historical chat to operate;
- a permanent thread has no single long-term owner or reusable repository-based bootstrap;
- an index route leads to conflicting facts;
- documentation debt is known but has no visible queue or owner area.
## Documentation Hygiene Records

### DH-2026-07-08: Archive ios-rime-keyboard-development-plan.md

- **Action**：将 `ios-rime-keyboard-development-plan.md` 归档至 `docs/plans/`，添加 Superseded 生命周期头。
- **Impact**：Plan hygiene 维度改善；路线图引用统一更新至新路径；文档体系不再包含无生命周期标记的游离 plan 文件。
