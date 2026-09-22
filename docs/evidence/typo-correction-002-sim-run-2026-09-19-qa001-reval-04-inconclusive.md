# TYPO-CORRECTION-002 Simulator QA-001 Run Receipt — Revalidation 04

> **Run ID:** `TC2-SIM-20260919-195848-QA001-REVAL-04`
>
> **Status:** `inconclusive — fresh keyboard input and candidate activity were observed, but the target candidate was not visible`
>
> **Evidence grade:** `Executor-recorded`

This is a fresh formal QA-001 attempt after the diagnostic observability smoke
passed. It establishes the current keyboard input/diagnostic route, but it does
not establish recovery of the target candidate. It is not a Product/Quality
Gate or an Assignment close.

## Authority and identity

- Assignment: [`TYPO-CORRECTION-002-PARENT-REVALIDATION-002`](../assignments/typo-correction-002-parent-revalidation-002.md)
- Authorization: [`AUTH-TYPO-CORRECTION-002-QA001-REVALIDATION-003`](../authorizations/AUTH-TYPO-CORRECTION-002-QA001-REVALIDATION-003.md)
- Case: `TC2-CASE-QA-001` / `TC2-CTR-QA-001`
- Worktree: `/private/tmp/universe-keyboard-typo-correction-002-provenance-sidecar`
- Branch / HEAD: `codex/typo-correction-002-provenance-sidecar` /
  `9eb83158e49218c1e8f75dbe7dd9e0390db81409`
- Simulator: iPhone 17 Pro Max / iOS `27.0`
- Simulator UDID: `06C5BC3E-7599-4761-A1A2-71DAEA991474`
- Host: Messages, conversation `+1 (888) 555-1212`
- Build configuration: Debug, unchanged signed Simulator package
- Tracked Swift diff SHA-256: `f1e4e17637bf6aaaaf314f882b229d50751792cfafc488f0d2cd8197863c7862`
- Untracked Swift manifest SHA-256: `f0ad8759e22deedaa3d5424280c481b2625c550c29609cc70258e3590861ec9d`
- Package identity: unchanged from the Authorization and diagnostic smoke
  receipt; no rebuild or reinstall occurred for this capture

## RIME provenance

| Field | Observed value |
|---|---|
| Active schema | `rime_ice` |
| Artifact identity | `rime-ice-20260630-675d23b0` |
| Artifact version | `2026.06.30` |
| Source variant | `nju` |
| Upstream revision | `6810e8916d160498620a16fef2135956fecbd485` |
| Archive SHA-256 | `675d23b070be00e1b800f9a6db033ef98f4493cd5b568ed8aa3b3541769c46ac` |
| Installed content SHA-256 | `2e906d14853255cd0eba534e2b40791008c2cee65fa5a6e50b40bbd159cb6c26` |
| Receipt ID | `078F7EA2-F9CA-4033-B7DD-48BE636BEB38` |
| librime | `1.16.1` |
| Runtime smoke / Lua smoke | `true / true` |

The high-fidelity expiration remained in the future during capture at
`2026-09-19T12:23:12Z`; logging was enabled and the RIME schema remained
`rime_ice`.

## Capture observations

- The operator manually entered `wimenjintianquhongyuan` and paused.
- The Messages UI snapshot showed the same draft value in the message field;
  the host send control was present and no message was sent.
- The fresh keyboard-extension segment contained real touch lifecycle events
  and candidate-visibility events. Its process instance continued from the
  immediately preceding smoke, but this Run used only the new journal segment
  beginning at `2026-09-19T12:01:39Z`; the preceding smoke file was not merged
  into this receipt.
- The target candidate `我们今天去公园` was not visible. This was confirmed by
  the human operator while the candidate bar was displayed.
- No candidate was selected. Delete, Space, Return, paging, Partial Commit and
  switch-away were not run because the target candidate was absent.
- The host message was not sent.

## Fresh journal evidence

Fresh segment:
`keyboard_extension-56964610-80B8-4A76-B3D2-7C5D0AECCD21-20260919T12-0.jsonl`

| Measure | Observed value |
|---|---:|
| JSONL lines / bytes | `129 / 64724` |
| Time window | `2026-09-19T12:01:39Z` – `2026-09-19T12:01:58Z` |
| `touch.terminal` | `46` |
| `candidate.visibility_changed` | `37` |
| `rime.owner.published` | `23` |
| `ui.applied` | `23` |
| Candidate-count range | `0–24` |
| Visible-cell-count range | `0–15` |
| Direct target-candidate text | `not recorded by content-free diagnostics` |

The current segment has no `typo_correction.sidecar_query` event. That is not
converted into a sidecar failure claim; this QA receipt is bounded to candidate
visibility and interaction behavior after real keyboard input was observed.

## Preserved artifacts

Raw artifacts are retained outside Git:
`/private/tmp/typo-correction-002-sim-runs/TC2-SIM-20260919-195848-QA001-REVAL-04/raw/`

| File | SHA-256 |
|---|---|
| `keyboard_extension.jsonl` | `4a9fcdbf258d52470d8861a99aa36d567198b8be3e3248bd4c5e4dfbc5f59798` |
| `rime-runtime-provenance.json` | `b6c9a74a747b35997cc4dc67c651443b7dfd610f50fd290f9076760de7865c54` |
| `qa001-screenshot.jpg` | `0214a1818daa15e2123050ca7572f5f7733bb34bd2f5da94db4e97b6c3cf2b87` |

## Claim outcomes

| Claim | Outcome | Boundary |
|---|---|---|
| Designated Simulator and package identity | `pass for environment sub-claim` | Exact device and frozen package hashes |
| Real Universe Keyboard input observed | `pass for bounded input sub-claim` | Fresh journal has 46 `touch.terminal` events |
| Candidate UI became active | `pass for bounded visibility sub-claim` | Counts only; no candidate text is logged |
| Target candidate visible | `not observed` | Human operator could not see `我们今天去公园` |
| Target candidate selected | `not-run` | No target candidate was available |
| Interaction regression checks | `not-run` | Stopped before selection |
| `TC2-CASE-QA-001` | `inconclusive; no QA pass` | Candidate recovery was not established |

## Non-claims and next boundary

- This receipt does not claim a product regression, a missing-RIME-artifact
  failure or a performance failure.
- It does not close QA-001, INT-003, paired performance or any
  Product/Quality/Release Gate.
- The QA Authorization is consumed and cannot be reused. Paired performance
  remains a separate active Authorization and must retain its own Run ID.
