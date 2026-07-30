# Phase A freeze — T9-RESPONSIVE-PIPELINE-001 (post R2 P1 re-review)

| Field | Value |
|---|---|
| Date | 2026-07-30 Asia/Shanghai |
| Product instruction | 先 A（收口），再 B（R3，已授权实现） |
| Branch / PR | `codex/t9-auto-anchor-s5-checkpoint` · [#34](https://github.com/shchnk1103/Universe-Keyboard/pull/34) |

## Frozen baseline (do not rewrite history)

| Item | State |
|---|---|
| Auto-anchor S2.3 | Direction FAIL · Hold/harvest · default-off retained |
| Responsive R1 | Fake pipeline + tests · Arch re-review Pass (P1 closed) |
| Responsive R2 | Default-off owner + bridge + presentation · Arch re-review: P1-1/P1-2 **Closed**, P1-3 **open** |
| Quality R2 P1 re-review | Presentation bridge **Closed** · 33/811 green |
| ADR 0025 | **Proposed** only |
| Product Gate / Release default-on | **Not claimed / not authorized** |
| Gate default | `isResponsiveRimePipelineEnabled = false` |

## Phase A meaning

- Stop expanding scope under the R2 story.
- Keep PR #34 open as review/integration window — **not urgent to merge**.
- Prefer merge-strategy discussion (whole stack vs split) before merge.
- Next implementation slice is **R3 only** under separate Product auth (B).

## Open residuals carried into R3 (not closed by A)

- Arch P1-3: off-MainActor librime (out of R3 unless Product widens)
- handle-level multi-action matrix beyond bridge unit tests
- Path / auto-anchor post-processing parity after deferred publish
- Extension chrome `as? RimeEngineImpl` under bridge
- Symbol-page replace still sync-drains on handle
