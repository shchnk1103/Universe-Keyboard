# Evidence: INT-003 cancel observability markers — tip rebind hygiene — 2026-09-23

## Identity

| Field | Value |
|---|---|
| **Kind** | Docs-only tip rebind / field-budget arithmetic hygiene after Arch/Quality |
| **AUTH** | [`AUTH-TYPO-CORRECTION-002-INT003-CANCEL-OBSERVABILITY-MARKERS-001`](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-CANCEL-OBSERVABILITY-MARKERS-001.md) (remains **Consumed**) |
| **Assignment** | [`TYPO-CORRECTION-002-INT003-CANCEL-OBSERVABILITY-MARKERS-001`](../assignments/typo-correction-002-int003-cancel-observability-markers-001.md) |
| **Squash tip** | `c1869cf9dda9f1643495e8ebdcfb67acc788b843` ([#152](https://github.com/shchnk1103/Universe-Keyboard/pull/152)) |
| **Branch tip (historical)** | `862014483a4a879e55a159b298184c870d116124` |
| **Recorded at** | `2026-09-23T19:33:31+08:00` (Asia/Shanghai) |

## What changed (docs only)

1. Rebind Assignment / AUTH `implementation_tip` (and matching tip fields) from branch tip `862014483a4a879e55a159b298184c870d116124` to main squash tip `c1869cf9dda9f1643495e8ebdcfb67acc788b843`.
2. Reflect #152 **merged/closed** on main (no longer “PR unmerged”).
3. Note Architecture **Pass with conditions** + Quality **Bounded Pass with conditions** dated `2026-09-23 Asia/Shanghai` on the Assignment; **do not** Close parent `TYPO-CORRECTION-002`.
4. Correct field-budget CountMetrics arithmetic: Quality noted draft **9→14**; tip baseline total at `c1869cf9dda9f1643495e8ebdcfb67acc788b843` is **11→16** (+5 additive `CountMetric` set). Enum split: `CountMetric` 9→14, `DurationMetric` 2→2.
5. Capture AUTH remains **Proposed** / untouched.

## Non-claims

- No Swift / RIME / Capture Live / Product Gate / parent Close / provenance restore.
- AUTH status stays **Consumed** (not re-Live).
