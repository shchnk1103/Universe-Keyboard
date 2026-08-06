# KOS 2.1 Operational Maturity Package

> **Version:** `2.1.0-ops`  
> **Status:** **Accepted as operational package under Knowledge OS 2.0**  
>   (Product disposition 2026-08-06; IMPL `KOS-2.1-OPS-IMPL-001`)  
> **Frozen constitution:** Knowledge OS **2.0**
>   ([`knowledge-os-2.0-specification.md`](knowledge-os-2.0-specification.md))  
> **This package does not replace 2.0 principles.** It tightens operational
> hygiene after scale use.

## Purpose

Reduce status drift, residual soft-closes, evidence-grade ambiguity, and
stack-merge folklore while preserving single-track 2.0 governance.

## Relationship to 2.0

| Layer | Owner |
|---|---|
| Frozen principles, authority, lifecycle skeleton, change types, migration rules | **2.0 specification** |
| Current vs historical presentation, state sync, residual close, evidence grades, Active Work, stack PR, supersession banners | **This package** |
| Permanent roles | `VIRTUAL_ENGINEERING_TEAM.md` |
| Assignment field contract | `ASSIGNMENT_POLICY.md` (includes addenda from this package) |

If this package conflicts with frozen 2.0, **2.0 wins** until a Product-authorized
frozen Contract amendment says otherwise.

## M-01 — Current Status block

Every **Active** or **Ready** Assignment and every **Recorded** Product Decision
that still drives work must open with a **Current Status** block (≤ ~15 lines / one
short table) containing only:

- Lifecycle state  
- Current phase (what is authorized now)  
- Non-claims that still matter  
- Next handoff / next decision  
- Link to residual table if any  

**Historical** checklists, phase logs, and closed gates go **below** a clear
separator (`---` or `## History`). Historical “not claimed” rows must not be
readable as current truth without a supersession banner (S-03).

Template: see [`ASSIGNMENT_POLICY.md`](../ASSIGNMENT_POLICY.md) § Current Status.

## M-02 — State sync checklist

After any of: Product Gate, ADR Accept, Assignment Close, or merge of a tip PR
that changes lifecycle language, the Executor (or PM with Executor confirmation)
runs:

1. Owning Assignment **Current Status** matches reality  
2. Parent Assignment Current Status / checkboxes if any  
3. `docs/ENGINEERING_DASHBOARD.md` row for the Work Item  
4. `docs/KNOWLEDGE_INDEX.md` if navigation text encodes status  
5. Active plan Status line if the plan is still `Active`  
6. `docs/ACTIVE_WORK.md` entry add/update/remove  

Failure to sync is a **documentation defect**, not optional polish.

Detail: [`KNOWLEDGE_OS.md`](../KNOWLEDGE_OS.md) § State Sync.

## M-03 — Residual disposition (hard close)

Independent Architecture or Quality conclusions of **Pass with conditions**
(or Conditional Accept) must list residuals with:

| Field | Required |
|---|---|
| Residual ID | e.g. `A-P2-01`, `R-04` |
| Owner | role or Assignment |
| Disposition | exactly one of `fix` / `accept` / `tech_debt:<ID>` |
| Pointer | evidence or TECH_DEBT entry |

**Close rules:**

| Disposition | Assignment may Close? |
|---|---|
| `fix` (+ evidence pointer) | Yes |
| `accept` (explicitly non-blocking residual) | Yes if still listed at close |
| `tech_debt:<ID>` present in `TECH_DEBT.md` | Yes |
| Missing disposition | **No** — remain `Reviewed` / `Blocked` for close |

## M-04 — Evidence grades

Validation tables in evidence docs must label each result row with exactly one:

| Grade | Meaning |
|---|---|
| `Executor-recorded` | Run by Executor; not independently re-run by Quality |
| `Quality-reverified` | Quality independently re-ran or re-checked the same claim |
| `Device-attested` | Physical-device / Human operator attestation per Assignment |

Do not invent intermediate grades. Do not present `Executor-recorded` as
Quality-verified.

## M-05 — Active Work Summary

- Path: [`docs/ACTIVE_WORK.md`](../ACTIVE_WORK.md)  
- Cap: **N ≤ 10** Active (or Ready) formal Work Items  
- Content: link + Current Status fields only  
- **Source of Truth for lifecycle remains the Assignment Record**  
- On conflict: fix Active Work / Dashboard; do not “fix” by editing memory  

Dashboard may summarize Active Work but must not invent lifecycle states.

## S-02 — Stacked PR convention

When multiple PRs form a commit stack:

1. PR body states `Stack: base=… tip=…` and lists prefix PR numbers.  
2. Prefer merging the **tip** (contains all commits).  
3. Prefix PRs close as **superseded** or GitHub-merge when commits land.  
4. After tip merge: run M-02 State sync.  

See [`AI_WORKFLOW.md`](../AI_WORKFLOW.md).

## S-03 — Supersession banners

When a later PD/Assignment supersedes an earlier “not authorized / default-off /
not claimed” statement that readers still encounter:

```md
> **Superseded for current status:** see <PD/Assignment link> (date).
> Text below is historical authorization narrative.
```

Place at the top of the stale section or document Current Status.

## Explicitly deferred (not in this package)

- **S-01** Lightweight skip of dual review — deferred (Architecture A-P1-01)  
- Assignment archive **folder Migration**  
- Status linter tooling  
- Frozen 2.0 principle text rewrite  

## Publication record

| Event | Date | Source |
|---|---|---|
| Design draft | 2026-08-06 | `kos-2.1-ops-design-draft.md` |
| Architecture Pass with conditions | 2026-08-06 | `kos-2.1-ops-001-architecture-review.md` |
| Product Accept Must (+ S-02/S-03) | 2026-08-06 | `KOS-2.1-OPS-001-design-disposition.md` |
| Ops package publication | 2026-08-06 | this file via `KOS-2.1-OPS-IMPL-001` |