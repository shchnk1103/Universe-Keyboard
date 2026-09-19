# TYPO-CORRECTION-002 Simulator Paired-Performance Run Receipt — Revalidation 03

> **Run ID:** `TC2-PERF-20260919-195848-REVAL-03`
>
> **Status:** `inconclusive — BASELINE and TREATMENT were captured, but the
> arms used different keyboard-extension processes and are not a valid pair`
>
> **Evidence grade:** `Executor-recorded`

This was a bounded diagnostic BASELINE/TREATMENT attempt after the diagnostic
observability smoke passed. Both arms produced fresh product-side evidence, but
the treatment arm started a new keyboard-extension process. The Authorization
requires comparable arms and therefore no paired-performance conclusion is
claimed.

## Authority and identity

- Assignment: [`TYPO-CORRECTION-002-PARENT-REVALIDATION-002`](../assignments/typo-correction-002-parent-revalidation-002.md)
- Authorization: [`AUTH-TYPO-CORRECTION-002-PERFORMANCE-REVALIDATION-003`](../authorizations/AUTH-TYPO-CORRECTION-002-PERFORMANCE-REVALIDATION-003.md)
- Scope: diagnostic `BASELINE` / `TREATMENT` comparison only
- Worktree: `/private/tmp/universe-keyboard-typo-correction-002-provenance-sidecar`
- Branch / HEAD: `codex/typo-correction-002-provenance-sidecar` /
  `9eb83158e49218c1e8f75dbe7dd9e0390db81409`
- Tracked Swift diff SHA-256: `f1e4e17637bf6aaaaf314f882b229d50751792cfafc488f0d2cd8197863c7862`
- Untracked Swift manifest SHA-256: `f0ad8759e22deedaa3d5424280c481b2625c550c29609cc70258e3590861ec9d`
- Simulator: iPhone 17 Pro Max / iOS `27.0`
- Simulator UDID: `06C5BC3E-7599-4761-A1A2-71DAEA991474`
- Host: Messages, conversation `+1 (888) 555-1212`
- Build/install: unchanged Debug package; no rebuild, reinstall or schema
  change occurred between the arms

## Package and RIME provenance

| Field | Observed value |
|---|---|
| Main executable SHA-256 | `6f3ad3ea8e0dccb85af0ddc00c1885f6bb0d4101beee5c71283f976ec882cbba` |
| Main debug dylib SHA-256 | `ce2c05a3e665c3fb3d5eaec15a8a7f4d1b157f7108b39f7cfcd7c7732c25d58` |
| Keyboard executable SHA-256 | `0ec6b1e8467de8edca3603e3e4db226e1094343f0a70497e4e87ed5d87a07f91` |
| Keyboard debug dylib SHA-256 | `6c7c2d26727a63102987faf07477fae0167271bc98e21093d0ed0473bcdef6d2` |
| Active schema | `rime_ice` |
| Artifact identity | `rime-ice-20260630-675d23b0` |
| Archive SHA-256 | `675d23b070be00e1b800f9a6db033ef98f4493cd5b568ed8aa3b3541769c46ac` |
| Installed content SHA-256 | `2e906d14853255cd0eba534e2b40791008c2cee65fa5a6e50b40bbd159cb6c26` |
| Runtime receipt ID | `078F7EA2-F9CA-4033-B7DD-48BE636BEB38` |
| Runtime provenance SHA-256 | `b6c9a74a747b35997cc4dc67c651443b7dfd610f50fd290f9076760de7865c54` |
| High-fidelity expiration | `2026-09-19T12:23:12Z` |

## Arm disposition

### BASELINE — contextual correction sidecar disabled

- Preference audit: `typo_experimental_contextual_correction_enabled=false`.
- Fresh post-QA segment: `2026-09-19T12:13:19Z` –
  `2026-09-19T12:13:23Z`.
- Process instance: `56964610-80B8-4A76-B3D2-7C5D0AECCD21`.
- The process continued from the preceding smoke/QA capture; only events
  after the QA cutoff `2026-09-19T12:01:58Z` were used for this arm.
- The host draft was left unsent. The fresh slice contains 4
  `touch.terminal`, 22 `rime.owner.published`, 22 `ui.applied` and 8
  `candidate.visibility_changed` events.
- No `typo_correction.sidecar_query` event was expected or observed with the
  sidecar disabled.

### TREATMENT — contextual correction sidecar enabled

- Preference audit: `typo_experimental_contextual_correction_enabled=true`.
- Fresh journal: `2026-09-19T12:18:49Z` – `2026-09-19T12:19:05Z`.
- Process instance: `9E631FEE-5E7D-40A5-ABC8-411CD6B3A154`.
- The operator entered `wimenjintianquhongyuan` and paused. Messages showed
  the raw draft and the host send control; no message was sent.
- The target candidate `我们今天去公园` was not visible to the operator and
  no candidate was selected.
- The fresh journal contains 44 `touch.terminal`, 22
  `rime.owner.published`, 22 `ui.applied`, 57 candidate-visibility events and
  70 direct `typo_correction.sidecar_query` events.
- All 70 sidecar queries used route `real_rime_sidecar`, returned `3/3`, had
  schema `rime_ice`, stable live session ID `4392416920`, stable sidecar
  session ID `4458112856`, and elapsed values from `1` to `6` ms.

## Pair comparability and result

| Check | BASELINE | TREATMENT | Disposition |
|---|---|---|---|
| Package / device / host / schema | same | same | comparable |
| Sidecar setting | disabled | enabled | intended difference |
| Keyboard process | `56964610-…` | `9E631FEE-…` | **not comparable** |
| Fresh product event stream | present | present | independently observed |
| Direct sidecar query | 0 | 70 returned | descriptive only |
| Target candidate visible | not established | not visible | no QA pass |
| Paired performance result | — | — | **not measurable** |

The new treatment process is a hard comparability break under this
Authorization. The 1–6 ms values are internal sidecar-query observations from
the treatment arm only; they are not an end-to-end keyboard latency, a user
perceived latency, an INT-003 result, or a 180 ms Release budget.

## Preserved artifacts

Raw artifacts are retained outside Git:
`/private/tmp/typo-correction-002-sim-runs/TC2-PERF-20260919-195848-REVAL-03/raw/`

| File | SHA-256 |
|---|---|
| `baseline-source-journal.jsonl` | `1ab5e5a0fca0c9899efba95e2c82c9fb9576e6251b0ddb971e8ed4fe5fbf5ddd` |
| `baseline-journal-slice.jsonl` | `497877063a1ada9e4f5a060117ee6240e5b34d07d2e472cf31593e1f38ab633f` |
| `baseline-screenshot.jpg` | `16802a2afdbc6ff8db26a363fda26c9dc54faec005ccff927587133b11e18d28` |
| `rime-runtime-provenance.json` | `b6c9a74a747b35997cc4dc67c651443b7dfd610f50fd290f9076760de7865c54` |
| `treatment-journal.jsonl` | `8d1d4ae75be515ba195ee77cc2b627aaff7428f47ba6cf3e542eb3244d5dd0a0` |
| `treatment-screenshot.jpg` | `8d2b28c871beda82f276328aee999e7ddd40b5c7e5c23983a1da97aa76f622a2` |
| `treatment-rime-runtime-provenance.json` | `b6c9a74a747b35997cc4dc67c651443b7dfd610f50fd290f9076760de7865c54` |

## Claim outcomes and non-claims

| Claim | Outcome | Boundary |
|---|---|---|
| Exact package/device/schema/provenance identity | `pass for identity sub-claim` | Frozen package and live provenance match |
| BASELINE fresh product stream | `pass for bounded arm sub-claim` | Fresh post-cutoff segment; process continued from prior capture |
| TREATMENT direct sidecar route | `pass for bounded arm sub-claim` | 70 real-rime-sidecar events, 3/3 returned |
| Comparable pair | `inconclusive` | Keyboard process changed between arms |
| Paired performance timing | `not measurable` | No comparable pair; no end-to-end timing claim |
| Target candidate recovery | `not observed` | Human did not see `我们今天去公园` |

- This receipt does not claim a product regression or that contextual
  correction is slow or fast.
- It does not close QA-001, INT-003, paired performance, or any
  Product/Quality/Release Gate.
- The Performance Authorization is consumed and cannot be reused. A new same-
  process pair requires a new Authorization and Run ID.
