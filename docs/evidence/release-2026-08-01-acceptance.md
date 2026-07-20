# RELEASE-2026-0801 Release Evidence And Acceptance Record

> **Status:** Active evidence ledger; no release conclusion yet
> **Target availability:** `2026-08-01 Asia/Shanghai`
> **Authority:** [`RELEASE-2026-0801`](../assignments/release-2026-08-01.md)
> **Evidence rule:** A historical or preliminary result is not final release evidence until it maps to the frozen release commit and archive.

## Release Identity

| Field | Current value |
|---|---|
| Release commit/tag | `UNKNOWN — freeze under RELEASE-2026-0801-02` |
| Marketing version/build | `UNKNOWN — confirm under RELEASE-2026-0801-01` |
| Stable Xcode/SDK | `UNKNOWN — verify under RELEASE-2026-0801-01` |
| Signed archive | `UNKNOWN` |
| dSYM retention | `UNKNOWN` |
| TestFlight/App Store build | `UNKNOWN` |
| Supported devices/OS | iPhone and iPad; iOS 26.0+. Scope is frozen by [`RELEASE-2026-0801-02`](../assignments/release-2026-08-01-02-scope-freeze.md), but iPad and iOS 26.0 support are not yet implemented or evidenced. |
| Included schemas/features | Existing baseline input; Chinese nine-key; precise-pinyin selection; post-commit continuation; kaomoji content. No schema expansion is authorized. Typing Intelligence and contextual typo correction are excluded from launch claims. |

## Child Gate Status

| Assignment | Status | Evidence / blocker |
|---|---|---|
| Stable archive | `Assignment Pending` | Executor/environment operator not assigned; stable toolchain evidence pending |
| Scope freeze | `Completed — independent review pending` | Product scope record published; iPad support, kaomoji content and iOS 26.0 target-change implementation remain release blockers |
| iPad support | `Assignment Pending` | Executor/device operator not assigned; no iPad release evidence yet |
| Kaomoji content | `Assignment Pending` | Executor/content decision owner not assigned; no working content evidence yet |
| Onboarding / Full Access | `Assignment Pending` | Executor/device operator pending |
| Device / performance | `Assignment Pending` | Executor/devices/final archive pending |
| App Store materials | `Assignment Pending` | Executor/account operator/public URLs pending |
| Product polish | `Assignment Pending` | Executor/visual operator pending |

## Preliminary Repository Audit Snapshot

This section records preparation evidence only. It expires when the release commit changes or the final archive is produced.

- **Collected:** `2026-07-20 Asia/Shanghai`
- **Base:** repository `main` at `9f5ed24`; clean against `origin/main` at collection time
- **Observed passed preparation checks:** repository whitespace check; pinned RIME vendor structural verification; current KeyboardCore, main-App/Extension and RimeBridge automated suites; beta-toolchain Debug/Release simulator and generic-device compilation
- **Observed limitations:** fixture-gated RimeBridge cases skipped; no stable-toolchain signed archive; no final physical-device matrix; no final performance/jetsam baseline; no App Store Connect state verification
- **Expiry:** any release-candidate commit, toolchain, artifact, feature scope or support-matrix change

Do not copy preliminary test counts into current product or release claims. Preserve exact command output in the child evidence handoff when those checks are repeated for the final candidate.

## Final Evidence Matrix

| Area | Required environment/artifact | Result | Evidence location | Reviewer | Expiry/revalidation |
|---|---|---|---|---|---|
| Repository/artifact integrity | Frozen release commit | Pending | — | — | Commit change |
| Stable signed archive/validation | Final archive | Pending | — | — | Archive/toolchain change |
| Automated tests/builds | Frozen commit, stable toolchain | Pending | — | — | Relevant diff/toolchain change |
| RIME/Lua/OpenCC runtime | Final deployed schemas | Pending | — | — | Artifact/schema/config change |
| Full Access off/on | Physical device | Pending | — | — | Access/onboarding/fallback change |
| Keyboard host/device matrix | Physical device, Release build | Pending | — | — | UI/Core/RIME/support change |
| Performance/memory/jetsam | Physical device, Release build | Pending | — | — | Performance-sensitive change |
| Accessibility/appearance | Supported devices/layouts | Pending | — | — | UI/support change |
| Privacy/security/licenses | Final binary and public policy | Pending | — | — | Binary/policy/dependency change |
| App Store metadata/screenshots | Final supported scope | Pending | — | — | Scope/copy/screenshot change |
| TestFlight smoke | Uploaded build | Pending | — | — | Uploaded build change |

## Failed Or Skipped Gates

No skipped release gate is accepted by default. Add one row for every failure or skip.

| Gate | Failed/skipped reason | Impact | Owner | Product decision | Expiry/follow-up |
|---|---|---|---|---|---|
| — | — | — | — | — | — |

## External Action Log

| Time | Action | Explicit authorization source | Actor/account boundary | Result/artifact |
|---|---|---|---|---|
| — | — | — | — | — |

## Release Decision

- **Quality conclusion:** Pending
- **Architecture/privacy conclusion:** Pending where applicable
- **Product Gate:** Pending
- **App Store submission authorization:** Not granted by this record
- **Manual release authorization:** Not granted by this record
- **Residual risks:** Pending final evidence
