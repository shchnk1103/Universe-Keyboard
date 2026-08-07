# Product Decision: T9-SINGLE-KEY-MIXED-CANDIDATES-001 — Single-key MNO mixed Chinese candidates (Apple-like first key)

**Decision ID:** `PD-T9-SINGLE-KEY-MIXED-CANDIDATES-001`  
**Lifecycle status:** `Closed — Won’t do`  
**Date / timezone:** `2026-08-07 Asia/Shanghai`  
**Parent domain:** Chinese nine-key Path + RIME candidates (ADR 0020–0023)  
**Related:** ADR [`0021`](../architecture/decisions/0021-t9-deterministic-single-key-choices-and-cycle-selection.md); dual-gate responsive pipeline out of scope  
**Assignment:** [`t9-single-key-mixed-candidates-001.md`](../assignments/t9-single-key-mixed-candidates-001.md) (`Closed — Won’t do`)  
**Discussion draft:** [`t9-single-key-mixed-candidates-001-discussion.md`](../plans/t9-single-key-mixed-candidates-001-discussion.md)  
**Superseding product direction:** multi-scheme expansion; next candidate [`PD-RIME-SCHEME-WANXIANG-001`](RIME-SCHEME-WANXIANG-001-authorization.md)

## Current Status (KOS 2.1 M-01)

| Field | Value |
|---|---|
| **Lifecycle** | `Closed — Won’t do` |
| **Phase** | Product declined Apple-like single-key mixed Chinese candidates |
| **Non-claims** | Not a dual-gate bug; sparse raw-`6` menus accepted as rime-ice `t9` default |
| **Next** | None for this PD; follow multi-scheme / 万象拼音 |
| **Residuals** | None |

---

## Authority

- **Product Approver:** Human Product Lead  
- **Open decision source:** In-session 2026-08-07 (establish as goal after Apple comparison)  
- **Close decision source:** In-session 2026-08-07 — *「混合候选目标正式不做了」*; accept fog/rime-ice `t9` single-digit menu sparsity; prefer supporting more schemes (e.g. 万象拼音)

## Product problem (historical)

Apple system nine-key shows rich m/n/o-mixed Chinese after one MNO press. Pinned librime + rime-ice `t9` on raw `6` historically yields a thin menu (~4, o-biased). Path `m|n|o` is separate from Chinese candidate generation (ADR 0021).

## Bound Product Decision — **Won’t do**

1. **Do not** implement Apple-like single-key mixed / union Chinese candidates (probe m/n/o merge, schema hacks for first-key density, or second Chinese candidate engine for that purpose).  
2. **Accept** rime-ice `t9` raw-digit candidate sparsity as scheme-default behavior, not a Universe Keyboard correctness defect.  
3. **Do not** amend ADR 0021 solely to enable first-key union candidates.  
4. Future experience investment prefers **additional user-selectable RIME base schemes** (catalog + deploy path), not rewriting t9 first-key ranking.

## Explicit non-claims (close)

- Closing this PD does **not** change dual-gate select double-commit or `candidateWindow` fixes (`RESPONSIVE-CANDIDATE-ANOMALY-001`).  
- Closing does **not** uninstall or deprecate nine-key / `t9`.  
- Closing does **not** authorize 万象拼音 implementation by itself (see separate PD).

## History

- 2026-08-07: Proposed after Apple first-key comparison.  
- 2026-08-07: **Closed — Won’t do**; pivot to multi-scheme support.
