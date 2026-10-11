# TYPO-CORRECTION-002 Simulator Paired-Performance Run Receipt — Revalidation 02

> **Run ID:** `TC2-PERF-20260919-192740-REVAL-02`
>
> **Status:** `inconclusive — BASELINE captured without product timing events;
> TREATMENT not run`
>
> **Evidence grade:** `Executor-recorded`

This was a bounded diagnostic paired-performance attempt. The package and RIME
provenance were frozen, but the baseline produced no keyboard input or sidecar
events in the fresh diagnostic window. Per the Authorization stop condition,
the treatment arm was not collected; there is no performance comparison.

## Authority and identity

- Assignment: [`TYPO-CORRECTION-002-PARENT-REVALIDATION-002`](../assignments/typo-correction-002-parent-revalidation-002.md)
- Authorization: [`AUTH-TYPO-CORRECTION-002-PERFORMANCE-REVALIDATION-002`](../authorizations/AUTH-TYPO-CORRECTION-002-PERFORMANCE-REVALIDATION-002.md)
- Scope: diagnostic `BASELINE` / `TREATMENT` comparison only
- Worktree: `/private/tmp/universe-keyboard-typo-correction-002-provenance-sidecar`
- Branch / HEAD: `codex/typo-correction-002-provenance-sidecar` /
  `9eb83158e49218c1e8f75dbe7dd9e0390db81409`
- Tracked Swift diff SHA-256: `f1e4e17637bf6aaaaf314f882b229d50751792cfafc488f0d2cd8197863c7862`
- Untracked Swift manifest SHA-256: `f0ad8759e22deedaa3d5424280c481b2625c550c29609cc70258e3590861ec9d`
- Simulator: iPhone 17 Pro Max / iOS `27.0`
- Simulator UDID: `06C5BC3E-7599-4761-A1A2-71DAEA991474`
- Host: Messages, conversation `+1 (888) 555-1212`
- Build/install: same Debug package built and installed before this pair; no
  rebuild or reinstall between the two arms because the second arm was stopped

## Package identity

| Package member | SHA-256 |
|---|---|
| Main executable | `6f3ad3ea8e0dccb85af0ddc00c1885f6bb0d4101beee5c71283f976ec882cbba` |
| Main debug dylib | `ce2c05a3e665c3fb3d5eaec15a8a7f4d1b157f7108b39f7cfcd7c7732c25d58a` |
| Keyboard executable | `0ec6b1e8467de8edca3603e3e4db226e1094343f0a70497e4e87ed5d87a07f91` |
| Keyboard debug dylib | `6c7c2d26727a63102987faf07477fae0167271bc98e21093d0ed0473bcdef6d2` |

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
| Receipt raw SHA-256 | `b6c9a74a747b35997cc4dc67c651443b7dfd610f50fd290f9076760de7865c54` |
| librime | `1.16.1` |
| Runtime smoke / Lua smoke | `true / true` |

## Arm disposition

### BASELINE

- Requested setting: contextual correction sidecar disabled.
- Synthetic composition: declared QA/performance sequence; no host message was
  sent.
- Human note: one extra `y` was entered and then removed with Delete.
- Final runtime snapshot showed the corrected raw composition, but the fresh
  keyboard-extension journal did not record the input lifecycle.
- Screenshot was captured for the arm; it does not provide a timing clock.

### TREATMENT

- Not run. The baseline did not produce a qualifying product event stream, so a
  treatment arm would not be comparable and would violate the stop condition.

## Fresh diagnostic result

Fresh App Group files were captured from the designated Simulator. The
keyboard-extension journal contained exactly one event:
`presentation.appeared` at `2026-09-19T11:38:16Z`.

| Measure | BASELINE | TREATMENT |
|---|---:|---:|
| Keyboard-extension JSONL lines / bytes | `1 / 334` | `not-run` |
| `touch.terminal` events | `0` | `not-run` |
| `key_highlighted` events | `0` | `not-run` |
| `typo_correction.sidecar_query` events | `0` | `not-run` |
| Candidate-refresh timing samples | `0` | `not-run` |
| Median / worst timing | `not measurable` | `not-run` |

The main-app journal contained only two `rime_sync.invoked` and two
`rime_sync.skipped` records. It contained no paired candidate-refresh timing
events. The absence of events is treated as an observability/capture boundary,
not as a performance failure.

### Post-capture diagnostic-mode audit

A read-only App Group preference audit after the BASELINE capture found
`diagnostics_high_fidelity_expiration = 2026-09-19T10:29:24Z`, earlier than the
fresh baseline keyboard journal timestamp (`2026-09-19T11:38:16Z`). The visible
debug touch overlay was enabled separately, so its presence does not prove that
the high-fidelity timing journal was active. The persistent `rime_diag_log`
preference was not used as a substitute because it has no fresh process/journal
boundary for this arm and may contain historical text.

This explains why the baseline did not produce an evidence-grade timing stream;
it does not establish that the treatment would be slow or fast.

## Preserved artifacts

Raw artifacts are retained outside Git:
`/private/tmp/typo-correction-002-perf-runs/TC2-PERF-20260919-192740-REVAL-02/raw/`

| File | SHA-256 |
|---|---|
| `diagnostics-baseline.jsonl` | `751a61264de894c3f43936e2ed98406bce53905288c3b0ca70d09e72155a11fb` |
| `main_app-baseline.jsonl` | `e50c57177d94cc9dbae6fbffb07dfcab85b46fdea66736a3ef4d2fe8b57c73b6` |
| `rime-runtime-provenance.json` | `b6c9a74a747b35997cc4dc67c651443b7dfd610f50fd290f9076760de7865c54` |
| `baseline-screenshot.jpg` | `90d73b3b431ab8506952f1d8a1969a6a9e9b9956e4a3cb9bc00db58eb25fefaf` |

## Claim outcomes

| Claim | Outcome | Boundary |
|---|---|---|
| Exact build/device/schema/provenance identity | `pass for identity sub-claim` | Frozen package and live provenance match this receipt |
| Comparable BASELINE arm | `inconclusive` | No product input/timing event was emitted |
| TREATMENT arm | `not-run` | Stopped before toggle/input to avoid false pairing |
| Paired performance comparison | `not measurable` | No two comparable arms and no timing samples |
| Release/Product performance budget | `not claimed` | Diagnostic-only Authorization |

## Non-claims and next boundary

- This receipt does not close paired performance, QA-001, INT-003 or any
  Product/Quality/Release Gate.
- It does not claim that contextual correction is slow or fast.
- The performance Authorization is consumed and cannot be reused. A retry needs
  a new Authorization and Run ID, and must first verify that high-fidelity
  keyboard diagnostics emit at least one real key event in a one-key smoke.
