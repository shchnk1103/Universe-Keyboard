# PR body archive — KEYBOARD-LAYOUT-9KEY-PINYIN-004

> **Historical:** PR [#27](https://github.com/shchnk1103/Universe-Keyboard/pull/27) MERGED (catalog + H5 residual). Residual-B Path-ledger cursor landed later as PR [#28](https://github.com/shchnk1103/Universe-Keyboard/pull/28) MERGED (`f84a00d`). This file remains the #27 draft archive.

**Branch (historical):** `codex/t9-atomic-path-snapshot` → `main`

---

## Summary (PR #27)

- Complete local T9 Path catalog + atomic composition presentation (004 / ADR 0023).
- Fixed-height Path Bar lists full focus choices without depending on expanded candidate discovery.
- Gate 5 β-limited identity (`T9CompositionIdentity`) for shortened remainder and typo Append/Delete; engine-only unchanged-raw **fail-closed** at that freeze.
- Post-β residual: Core `sourceDigits` SoT for multi-digit progressive Delete/append, host remaining projection after Path select, short `da→dao` Path bar sync.
- Human H5 residual Pass (device A/B/C) accepted by Product disposition; independent Architecture Accept + Quality Pass-with-findings.

## Follow-on (PR #28 — residual-B)

- Path-ledger **cursor**: `K=min(CJK, user Path stack)`; slots follow syllables; soft-select next user-chosen syllable; `wo…` unselected.
- Human residual-B device **Pass** `2026-07-23`; PD [`…-RESIDUAL-B-PATH-LEDGER-PEEL`](../product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-004-gate5-residual-b-path-ledger-peel.md) Accepted.
- Evidence remediation §28–§30.

## Authority

- PD-004, ADR 0023
- Gate5 path / β / [post-β residual disposition](../product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-004-gate5-post-beta-residual-disposition.md) / residual-B PD
- Independent review: [post-β independent review](keyboard-layout-9key-pinyin-004-gate5-post-beta-human-residual-independent-review.md)
- Evidence: remediation §21–§30

## Non-claims

- **Not** full 004 Assignment `Closed` solely by residual-B
- **Not** invent-slot without user Path stack
- provisional-only mixed-raw C `XCTSkip` still parked

## Test plan (archive + residual-B)

- [x] Directed Gate5 / Partial matrix (post-β freeze)
- [x] Human H5-A / H5-B / H5-C (device) Pass
- [x] KeyboardCore full suite residual-B freeze: **712 / 1 skip / 0 fail**
- [x] Human residual-B device Pass
