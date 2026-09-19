# TYPO-CORRECTION-002 Diagnostic Observability Smoke Receipt

> **Run ID:** `TC2-SIM-20260919-194824-DIAG-SMOKE-01`
>
> **Status:** `bounded pass — observability precondition only`
>
> **Evidence grade:** `Executor-recorded`

This receipt proves only that a newly enabled high-fidelity diagnostic window
produced a fresh process-bound keyboard journal with a real key event. It does
not establish QA-001 candidate recovery, INT-003 cadence, paired performance,
or any Product/Quality/Release Gate.

## Authority and identity

- Assignment: [`TYPO-CORRECTION-002-PARENT-REVALIDATION-002`](../assignments/typo-correction-002-parent-revalidation-002.md)
- Authorization: [`AUTH-TYPO-CORRECTION-002-DIAGNOSTIC-SMOKE-001`](../authorizations/AUTH-TYPO-CORRECTION-002-DIAGNOSTIC-SMOKE-001.md)
- Worktree: `/private/tmp/universe-keyboard-typo-correction-002-provenance-sidecar`
- Branch / HEAD: `codex/typo-correction-002-provenance-sidecar` /
  `9eb83158e49218c1e8f75dbe7dd9e0390db81409`
- Simulator: iPhone 17 Pro Max / iOS `27.0`
- Simulator UDID: `06C5BC3E-7599-4761-A1A2-71DAEA991474`
- Host: Messages, conversation `+1 (888) 555-1212`
- No source change, rebuild, reinstall or schema change occurred for this
  smoke.

### Source and package identity

- Tracked Swift diff SHA-256: `f1e4e17637bf6aaaaf314f882b229d50751792cfafc488f0d2cd8197863c7862`
- Untracked Swift manifest SHA-256: `f0ad8759e22deedaa3d5424280c481b2625c550c29609cc70258e3590861ec9d`
- Main executable SHA-256: `6f3ad3ea8e0dccb85af0ddc00c1885f6bb0d4101beee5c71283f976ec882cbba`
- Main debug dylib SHA-256: `ce2c05a3e665c3fb3d5eaec15a8a7f4d1b157f7108b39f7cfcd7c7732c25d58a`
- Keyboard executable SHA-256: `0ec6b1e8467de8edca3603e3e4db226e1094343f0a70497e4e87ed5d87a07f91`
- Keyboard debug dylib SHA-256: `6c7c2d26727a63102987faf07477fae0167271bc98e21093d0ed0473bcdef6d2`

## Diagnostic precondition

The App Group preference audit immediately before the one-key action reported:

| Preference | Observed value |
|---|---|
| `logging_enabled` | `true` |
| `diagnostics_high_fidelity_expiration` | `2026-09-19T12:23:12Z` |
| `debug_key_hitbox_overlay_enabled` | `true` |
| `rime_active_schema` | `rime_ice` |

The fresh journal's first event was at `2026-09-19T11:53:44Z`, before the
verified future expiration. The visible overlay is recorded separately and is
not used as proof of high-fidelity activation.

## Fresh journal result

The fresh process was
`56964610-80B8-4A76-B3D2-7C5D0AECCD21`. The process-bound journal was:

| Code | Count | Boundary |
|---|---:|---|
| `presentation.appeared` | 1 | `2026-09-19T11:53:44Z` |
| `touch.terminal` | 2 | `2026-09-19T11:53:45Z` |
| `typo_correction.query_route` | 1 | Same fresh process; route marker only |
| `candidate.visibility_changed` | 6 | Content-free visibility counters |
| `rime.owner.published` | 1 | Session publication marker |
| `ui.applied` | 1 | UI revision marker |

The operator performed exactly one ordinary key tap. No phrase, candidate
selection, host send, pasteboard, `typeText`, `documentContext` or
`setMarkedText` was used. Historical/persistent `rime_diag_log` text was not
used to supplement the fresh journal.

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

## Preserved artifacts

Raw artifacts are retained outside Git:
`/private/tmp/typo-correction-002-diagnostic-smoke-runs/TC2-SIM-20260919-194824-DIAG-SMOKE-01/raw/`

| File | SHA-256 |
|---|---|
| `keyboard_extension.jsonl` | `b7e738ff0c6a9c6e91c619436c032ae6acf405adb87c3ebde82a70dbe12d389a` |
| `rime-runtime-provenance.json` | `b6c9a74a747b35997cc4dc67c651443b7dfd610f50fd290f9076760de7865c54` |

## Disposition

- **Smoke result:** `pass` for fresh high-fidelity keyboard observability.
- **Permitted next boundary:** request separate new bounded Authorizations and
  Run IDs for QA-001 and paired performance.
- **Not established:** candidate recovery, target selection, interaction
  regression, INT-003 stale-work cancellation, timing budget or Product Gate.
- This smoke Authorization is consumed and must not be reused.
