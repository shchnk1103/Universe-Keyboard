# Plan: KOS-MIG-001 — Knowledge OS 2.0 Operational Migration

> **Status:** Archived
>
> **Assignment:** [`KOS-MIG-001`](../assignments/kos-mig-001.md)
>
> **Repository Change Type:** `Migration`
>
> **Archived:** `2026-07-17 Asia/Shanghai` after Product acceptance and closure
>
> **Completion record:** [`../kos/migration-001-record.md`](../kos/migration-001-record.md)

## Purpose

Apply Knowledge OS 2.0 as the single operational governance track. Remove dual-track “v1 remains operational until migration” authority without redesigning frozen principles or moving domain documentation.

## Source → Destination Mapping

| Source (pre-migration role) | Destination (post-migration role) | Action |
|---|---|---|
| `docs/kos/knowledge-os-2.0-specification.md` | Same path | Keep as frozen governance SoT; update structure language to post-migration |
| `docs/kos/zero-context-startup.md` | Same path | Keep as startup SoT; remove “migration not begun” as current state claim where stale |
| `docs/kos/migration-readiness.md` | Same path | Keep as historical readiness assessment; mark migration executed via completion record |
| `docs/KNOWLEDGE_OS.md` | Same path | Rewrite as operational entry under 2.0; no competing frozen principles |
| `docs/DOCUMENTATION_GOVERNANCE.md` SoT row for Knowledge OS | Same path | Split frozen governance vs operational entry ownership |
| `docs/KNOWLEDGE_INDEX.md` governance links | Same path | Single-track wording |
| `docs/DOCUMENTATION_GRAPH.md` | Same path | Clarify kos vs KNOWLEDGE_OS contracts |
| `docs/KNOWLEDGE_DEPENDENCIES.md` | Same path | Add migration/completion impact routing if needed |
| `docs/kos/README.md` | Same path | Record migration completion and assignment |
| `docs/ENGINEERING_DASHBOARD.md` | Same path | State synchronization only |
| New: `docs/kos/migration-001-record.md` | New path | Owns migration execution evidence and rollback |
| New: this plan | Same path | Temporary plan; archive after closure |
| New: Assignment record | `docs/assignments/kos-mig-001.md` | Owns task authority |

## Ownership After Migration

| Knowledge fact | Owner |
|---|---|
| Frozen Knowledge OS 2.0 principles, authority, lifecycle, task levels, change types, migration rules | `docs/kos/knowledge-os-2.0-specification.md` |
| Zero-Context Startup procedure | `docs/kos/zero-context-startup.md` |
| Knowledge layers, navigation protocol, evolution, self-healing operational behavior | `docs/KNOWLEDGE_OS.md` |
| Documentation SoT table and doc lifecycle rules | `docs/DOCUMENTATION_GOVERNANCE.md` |
| Task Assignment contract | `docs/ASSIGNMENT_POLICY.md` |
| KOS-MIG-001 execution evidence / rollback | `docs/kos/migration-001-record.md` |

## Link Rewrite Policy

1. Prefer links to the owning document for any substantive rule.
2. Replace “until separately migrated” / “v1 remains operational” language in current guidance with post-migration authority statements.
3. Keep historical Assignment/readiness text that describes past publication scope, but mark current migration status where those files still claim “not started” as present tense.
4. Do not copy frozen principles into navigation or operational entry documents.

## Duplicate-Fact Removal Policy

1. `docs/KNOWLEDGE_OS.md` must not restate the frozen authority/lifecycle/change-type tables from the 2.0 specification.
2. Navigation documents name and link owners; they may keep one-line purpose summaries only.
3. If two documents still appear to own the same frozen fact after rewrite, stop and fix ownership before closure.

## Validation Matrix

| Check | Command / method | Pass criterion |
|---|---|---|
| Formatting | `git diff --check` | No whitespace errors |
| Migration files present | path existence | Assignment, plan, completion record exist |
| Dual-track language | `rg` for current guidance phrases | No active “v1 remains operational until migration” in current SoT docs |
| Ownership discoverability | read index + kos README + KNOWLEDGE_OS | Single-track route is explicit |
| Internal links (migration set) | targeted path checks | Local markdown targets resolve |
| Scope compliance | `git status` / `git diff --name-only` | No production/test/build/runtime files |
| No redesign | review diff | No new roles, lifecycle states, object models or 2.1/3.0 |

## Rollback / Stop

Rollback:

1. Revert the migration commit(s) or restore the pre-migration versions of the modified documentation files from git.
2. Restore Dashboard/Assignment lifecycle text only if Product reopens the Assignment.
3. Do not attempt partial silent rollback of only one SoT document while leaving others post-migration.

Stop if:

- frozen principle redesign is required;
- domain tree moves become necessary for success;
- production/runtime files would need change;
- authority conflict cannot be resolved by ownership links.

## Acceptance Owner

- Architecture review of ownership and link integrity: 🏛️ Architecture & Knowledge Steward
- Product acceptance and closure: 🧭 Product Lead

## Out Of Scope Reminder

Domain architecture moves, product feature docs reorganization, Assignment Policy changes, Knowledge OS 2.1 and implementation work remain unauthorized.
