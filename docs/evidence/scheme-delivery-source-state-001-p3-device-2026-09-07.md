# SCHEME-DELIVERY-SOURCE-STATE-001 Human device observations — 2026-09-07

**Assignment:** [`SCHEME-DELIVERY-SOURCE-STATE-001`](../assignments/scheme-delivery-source-state-001.md)
**Evidence grade:** `Human-attested` (conversation report). **Not** `Device-attested`.
**Collection date / timezone:** `2026-09-07 Asia/Shanghai`
**Operator:** Human Product Owner
**Recorder:** current Grok session on `/private/tmp/uk-scheme-delivery-fix`
**Engineering HEAD at report time:** `b90d23657f10633531c5a7b67774772b968d9587` (`codex/scheme-delivery-fix`, P3)

This record is an index of Human statements. It is not a frozen payload manifest, not a journal paste, and not a Product Gate.

## Frozen engineering inputs (machine-known)

| Item | Value |
|---|---|
| Clone | `/private/tmp/uk-scheme-delivery-fix` |
| Branch / PR | `codex/scheme-delivery-fix` · [PR #100](https://github.com/shchnk1103/Universe-Keyboard/pull/100) draft |
| P2 commit | `1a475b6` — Ice private preset; skip shared `default.yaml` |
| P3 commit | `b90d236` — restore only known Ice 2026.06.30 Prelude pollution SHA |
| Ice plan after P2 | `rime-ice-plan-2` / `rime-ice-post-2` / staged id `rime-ice-20260630-plan2-post2` |
| Known pollution SHA | `0dacfbaca4774c07a0adb2ca2380dc290ada5dfb97e027d54063790ebaca37cd` |
| Official Prelude SHA | `0628ada16651d56c4cdfcb8e45ddba23d4d585cc8be0580a62c4e077c0bcc141` |

## Missing identity (explicitly unavailable)

The Human-operated evidence profile was **not** satisfied. The following are `UNKNOWN` and keep this grade at Human-attested:

| Boundary | Status |
|---|---|
| Device / OS | not stated |
| Installed Main App UUID / SHA-256 / size | not captured |
| Keyboard Extension UUID / SHA-256 / size | not captured |
| Debug payload identity | not captured |
| Build configuration (Debug/Release, SDK, signing) | not captured |
| Scheme / config fingerprint | not captured |
| Full Access | not stated |
| Host app / field type | not stated |
| Operation ID / journal phases | not pasted |
| `InstallationError` enum on device | still not emitted / not observed |
| App Group live SHA of `default.yaml` | not read |

Do not upgrade this file to `Device-attested` without a new run that fills those fields.

## Observation 1 — P3 redeploy of the isolated-clone build

Earlier in the same day, Human Product Owner reported that **one redeploy** of the isolated-clone build **no longer errors**.

Interpretation bound:

- Consistent with P3 restoring official Prelude `default.yaml` when live bytes match the pinned Ice 2026.06.30 fingerprint, then builtin `install()` succeeding.
- Does **not** prove the device SHA was that fingerprint.
- Does **not** rewrite already-installed Ice schemas to `rime_ice_preset` (P2 only applies on re-download / re-extract).

## Observation 2 — Re-download Ice, deploy, switch Luna, type

Human Product Owner, verbatim intent: 已重下雾凇并确认能部署；可以切换 LUNA 且不报错；雾凇与 Luna 都可以正常输入。

| Step | Human result | Bound interpretation |
|---|---|---|
| Re-download dated Ice | succeeded (Human) | New extract should take `rime-ice-plan-2` (private preset, skip `default.yaml`) |
| Deploy after that download | succeeded (Human) | `resource_preparation` no longer fails for this operator on this build |
| Switch to Luna | no error (Human) | Builtin redeploy / schema switch did not surface the previous `resource_preparation` failure |
| Ice input | normal (Human) | Smoke only; not a Lua/T9/OpenCC matrix |
| Luna input | normal (Human) | Smoke only; not F-02 quality re-gate |

## Non-claims

- Not Product Gate, merge, TestFlight, App Release, or ADR 0034 Acceptance.
- Not a unique-root-cause proof that the original `4169e168-de24-4e81-916a-e8d1f4d4a572` failure was only `.byteCountMismatch`.
- Not Wanxiang retest.
- Not Ice uninstall / upgrade / rollback / unknown-pollution matrix (P4).
- Not proof that on-device Ice schemas were rewritten before the re-download.
- Not proof of live `default.yaml` SHA, receipt generation, or `rime_ice_preset.yaml` presence.
- Not permission to relax integrity checks.

## Relation to P0 / P3 automation

P0 production-path: Ice `plan-1` overwrite + builtin receipt → `.byteCountMismatch` ([P0](scheme-delivery-source-state-001-p0-2026-09-07.md)).
P3 unit/coexistence: known SHA restores official bytes; unknown bytes stay fail-closed.

This Human report is **consistent with** P2 skip + P3 known-SHA restore, after a re-download that can apply plan-2. It does not replace those tests, and it does not close P4 or independent Architecture/Quality review.

## Next

Independent Architecture review of Proposed ADR 0034 / plan §5.1 versus implemented Candidate A. Quality review, P4, merge, and TestFlight remain separately authorized.
