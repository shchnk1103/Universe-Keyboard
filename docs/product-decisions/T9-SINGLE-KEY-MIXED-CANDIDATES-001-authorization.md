# Product Decision: T9-SINGLE-KEY-MIXED-CANDIDATES-001 — Single-key MNO mixed Chinese candidates (Apple-like first key)

**Decision ID:** `PD-T9-SINGLE-KEY-MIXED-CANDIDATES-001`  
**Lifecycle status:** `Proposed — Product goal recorded; implementation not authorized`  
**Date / timezone:** `2026-08-07 Asia/Shanghai`  
**Parent domain:** Chinese nine-key Path + RIME candidates (ADR 0020–0023)  
**Related:** ADR [`0021`](../architecture/decisions/0021-t9-deterministic-single-key-choices-and-cycle-selection.md) (Path identity vs Chinese candidates); dual-gate responsive pipeline is **out of scope** for this goal  
**Assignment:** Pending formal Assignment after Product Gate on approach

## Current Status (KOS 2.1 M-01)

| Field | Value |
|---|---|
| **Lifecycle** | `Proposed` — goal accepted for discussion, not for coding |
| **Phase** | Problem + north-star freeze; approach options pending Product Gate |
| **Non-claims** | Not a dual-gate / select / paging bug; not SLO; not App Store claim |
| **Next** | Product Lead chooses approach band; then Assignment + ADR amendment review |
| **Residuals** | None until Gate |

---

## Authority

- **Product Approver:** Human Product Lead (in-session 2026-08-07)  
- **Decision source:** User comparison of Apple system nine-key first-key candidate bar vs rime-ice `t9` raw-digit menu; request to **establish as product goal**, separate from `RESPONSIVE-CANDIDATE-ANOMALY-001` bug fix.

## Product problem

On Apple’s system Chinese nine-key, one press of **MNO** yields a rich candidate strip mixing **m / n / o** Chinese items (e.g. 吗、你、哦、年、能、美、那…), matching the mental model “one physical key → union of that key’s letters’ words.”

On pinned **librime + fog/rime-ice `t9`**, `processKey("6")` historically returns a **small** Chinese menu (evidence: `window6Count≈4`, comments largely `o`). KeyboardCore correctly surfaces Path choices `m|n|o` (ADR 0021) but does **not** merge three letter refinements into the Chinese bar. Users experience this as “broken nine-key,” even when dual-gate select/paging is correct.

## Bound Product Goal (north star — recorded)

**North star:** For an **unresolved single T9 digit key** (at least MNO/`6`; full `2…9` matrix to be decided), the Chinese candidate bar should present a **mixed, scrollable set of candidates covering that key’s letter group**, in the spirit of Apple first-key UX — **without** requiring the user to first tap Path `m`/`n`/`o` only to discover Chinese words.

### Explicit non-goals (until a later PD revises them)

- Not reopening dual-gate Delete/select/paging anomaly work as the delivery vehicle  
- Not claiming Apple parity on multi-digit progressive prediction, language model quality, or emoji ranking  
- Not mandating a second full Chinese dictionary outside RIME without Architecture review  
- Not a performance SLO or marketing claim  

### Relationship to ADR 0021

ADR 0021 currently states that key-identity Path mapping **does not generate Chinese candidates**. Delivering this goal **requires** either:

- an **ADR 0021 amendment** (or superseding ADR) authorizing a bounded single-key Chinese presentation path; or  
- a Product decision that Apple-like union is **display-only** with a named ownership model that Architecture accepts.

**Implementation remains blocked** until Product Gates an approach and Architecture accepts the ownership change.

## Approach bands (discussion only — none authorized)

| Band | Idea | Risk |
|---|---|---|
| A | Bounded probe: for one unresolved digit, `replaceInput`/query each letter in group, merge+rank, restore raw digit | Latency, session safety, dual-gate FIFO |
| B | Schema/dictionary/prism changes so raw digit code yields richer first menus | Upstream drift, deploy ownership |
| C | Hybrid: RIME first page + supplemental letter probes only when menu thinner than threshold | Complexity of merge rules |
| D | Keep RIME-only; improve Path-first education (fails north star) | Does not meet this PD’s goal |

## Separation from today’s bug fix

| Work | Class | Status |
|---|---|---|
| `RESPONSIVE-CANDIDATE-ANOMALY-001` | Correctness: double host commit on select; ThreadAffine `candidateWindow` first-page-only stall | **Completed** (Executor-recorded tests) |
| This PD | Product experience: single-key mixed Chinese candidates | **Proposed** only |

Do **not** treat sparse raw-`6` menus as a dual-gate regression. Do **not** land union/probe code under the anomaly Assignment.

## Implementation follow-through (not yet authorized)

| Action | Authorized? |
|---|---|
| Record goal + non-goals in repo | **Yes** (this PD) |
| Spike / design for Band A–C | **Only after** Product selects a band |
| Production Core/RimeBridge change | **No** until Assignment Ready + ADR path clear |
| Human device comparison matrix (Apple vs UK) | Recommended before Gate on quality bar |

## Human Product Owner notes

- 2026-08-07: Goal accepted for formal recording; ship anomaly fix first; deep design later.
