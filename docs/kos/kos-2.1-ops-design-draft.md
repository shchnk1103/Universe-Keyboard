# KOS 2.1 Operational Maturity — Design Draft (not Accepted)

> **Status:** Draft under [`KOS-2.1-OPS-001`](../assignments/kos-2.1-ops-001.md)  
> **Date:** `2026-08-06 Asia/Shanghai`  
> **Authority:** [`PD-KOS-2.1-OPS-001`](../product-decisions/KOS-2.1-OPS-001-authorization.md)  
> **Frozen track today:** Knowledge OS **2.0** remains binding  
> **This document is not** Knowledge OS 2.1 Accepted, not Migration, not 3.0

## 1. Purpose

Capture a design package for a possible **Knowledge OS 2.1 Operational Maturity**
release: reduce scale drift and ceremony friction after weeks of real 2.0 use,
without rewriting the frozen 2.0 constitution.

## 2. Pain inventory (post-MIG operational use)

| ID | Pain | Severity | Evidence class |
|---|---|---|---|
| P-01 | Dashboard / KNOWLEDGE_INDEX lag behind Assignment tip | High | Observed at Product Gate merge hygiene (default-off language still present while Gate landed) |
| P-02 | Historical “not claimed / default-off” language misread as current status | High | Parent PD/plan/checklist archaeology during responsive stack |
| P-03 | Stacked PR tip-merge coordination is tribal knowledge | Medium | PR #39–#42 stack; tip merge + supersede |
| P-04 | Conditional Accept / Pass with conditions residuals not forced closed | Medium | Recurrent Arch/Quality pattern across responsive phases |
| P-05 | Full dual-review ceremony applied to pure State/doc hygiene | Medium | Process cost vs risk |
| P-06 | Evidence strength informal (Executor-recorded vs Quality-reverified) | Medium | DEFAULT-ON Quality conditions on 915/0 |
| P-07 | Zero-context startup expensive at ~200 Assignments / large evidence corpus | Medium | Session bootstrap cost |
| P-08 | Active work discovery requires scanning long Dashboard | Medium | Dashboard length and multi-work-item noise |
| P-09 | Assignment volume (~200+) without archive/index convention for closed items | Low–Medium | `docs/assignments/` scale |
| P-10 | Plan documents retain stale Status headers longer than Assignments | Low–Medium | Plan status after Gate |

**What is not a pain:** 2.0 authority separation, lifecycle skeleton, change types,
“conversation is not truth,” and stop-on-UNKNOWN — these **worked** under load.

## 3. Design goals for 2.1

1. Keep **2.0 frozen principles** unless an additive amendment is proven necessary.  
2. Make **current vs historical** mechanically obvious.  
3. Make **status sync** a first-class, checkable obligation.  
4. Provide **lightweight paths** for low-risk State/doc work.  
5. Force **residual disposition** on conditional reviews.  
6. Standardize **evidence grades** and **stack merge** notes.  
7. Improve **Active work** discovery for new sessions.  

## 4. Proposed 2.1 package (Must / Should / Could)

### Must (2.1 ops minimum)

| ID | Proposal | Likely owner doc | Frozen 2.0 impact |
|---|---|---|---|
| M-01 | **Current Status block** required on every Active Assignment and Product Decision (max ~15 lines); historical checklists below a clear separator | Assignment Policy addendum or template + governance | Additive template rule; principles unchanged |
| M-02 | **State sync checklist** after Product Gate / Accept / merge: Dashboard, Index, parent Assignment, plan Status | `KNOWLEDGE_OS.md` + `AI_WORKFLOW.md` | Operational only |
| M-03 | **Residual registry rule**: every Pass with conditions lists residual IDs with owner + disposition (`fix` / `accept` / `tech_debt`) before Assignment close | Assignment Policy or review playbook | Additive |
| M-04 | **Evidence grade labels**: `Executor-recorded` / `Quality-reverified` / `Device-attested` required on validation tables | DOCUMENTATION_GOVERNANCE or evidence template | Operational / Contract light |
| M-05 | **Active Work Summary** entry (≤ N items) linked from Index; Dashboard summarizes, does not invent | new small ops doc or Dashboard section contract | Operational |

### Should

| ID | Proposal | Notes |
|---|---|---|
| S-01 | **Lightweight State path**: pure Dashboard/Index/lifecycle sync may skip independent dual review when no Contract/Implementation/Evidence claims change; still needs Product-visible Assignment or explicit State Work Order | Ceremony reduction |
| S-02 | **Stacked PR convention**: declare stack base/tip in PR body; prefer tip-merge; prefix PRs close as superseded when tip lands | `AI_WORKFLOW.md` |
| S-03 | **Supersession banners** on closed-phase PD sections that still say “not authorized” when a later PD supersedes | Reduces AI misread |
| S-04 | Closed Assignment **index / archive convention** (naming or folder) without bulk move in 2.1 | Scale |

### Could

| ID | Proposal | Notes |
|---|---|---|
| C-01 | Machine-checkable status linter (script) for Dashboard vs Assignment headers | Tooling Assignment later |
| C-02 | Auto-generated Active Work from Assignment front-matter | Tooling |
| C-03 | Formal “Conditional” ADR status token (today mapped to Accepted + residuals) | Only if DOCUMENTATION_GOVERNANCE needs it |
| C-04 | Prompt-compression pack for zero-context (“read Active Summary only”) | Startup ops |

## 5. Explicit non-changes (2.0 preserved)

- Ten frozen principles  
- Authority separation table  
- Assignment lifecycle skeleton  
- Change types (`Contract` / `State` / `Documentation` / `Implementation` / `Evidence` / `Migration`)  
- Migration must be assigned (no side-effect migration)  
- Conversation is not repository truth  

## 6. Migration readiness (recommendation only)

| Question | Draft answer |
|---|---|
| Is Migration required to ship Must items? | **No** — M-01…M-05 can land as ops/template/Contract-light without tree moves |
| When would Migration be warranted? | Closed-assignment archive foldering; domain doc tree reorg; bulk front-matter backfill |
| Dual-track risk? | Avoid: 2.0 remains sole track until Product Accepts 2.1 ops package |

**Recommendation:** Prefer **2.1 operational publication without Migration**; schedule Migration only if S-04/C-01 need structural moves.

## 7. Suggested follow-on Assignments (not authorized here)

| If Product Accepts design… | Next Assignment |
|---|---|
| Implement Must only | `KOS-2.1-OPS-IMPL-001` (Contract/Documentation/State) |
| Add lightweight path + stack convention | fold into IMPL or `KOS-2.1-OPS-IMPL-002` |
| Frozen additive amendment needed | separate Contract Assignment citing exact clause diffs |
| Archive foldering | `Migration` Assignment |

## 8. Open questions for Product / Architecture Review

1. Cap **N** for Active Work Summary (proposal: **7** or **10**)?  
2. Is S-01 (lightweight State path) acceptable, or always dual-review?  
3. Should residual disposition be **hard close blocker** or **allowed open with TECH_DEBT ID**?  
4. Do we want a status linter in-repo in 2.1 or defer to Could?  

## 9. Draft disposition options (for Product Review later)

| Disposition | Effect |
|---|---|
| Accept design → implement Must | Author IMPL Assignment |
| Accept design → Must + Should | Broader IMPL |
| Hold | Revise draft |
| Reject 2.1 | Close KOS-2.1-OPS-001; keep 2.0 only |

---

**End of draft.** Architecture review and Product Review are still required before
any implementation Assignment.  
