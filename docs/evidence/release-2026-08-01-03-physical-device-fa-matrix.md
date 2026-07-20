# RELEASE-2026-0801-03 — Physical-Device Full Access Matrix

> **Status:** Recorded human Environment Executor observation  
> **Date / timezone:** `2026-07-20 Asia/Shanghai`  
> **Assignment:** [`RELEASE-2026-0801-03`](../assignments/release-2026-08-01-03-onboarding-full-access.md)  
> **Product source:** [`ONBOARDING_ACTIVATION.md`](../ONBOARDING_ACTIVATION.md)  
> **Operator:** Human Product Owner (Environment Executor for physical device)

## Environment

| Field | Value |
|---|---|
| Device | iPhone 13 Pro |
| OS | iOS 27.0 beta 3 |
| Branch | `feature/release-2026-08-01-03-onboarding` |
| Base docs commit on branch tip before uncommitted work | `17116a3` (release-control parent); implementation still uncommitted at capture time |
| Schema | 雾凇拼音 (`rime_ice`), **already deployed** in main App |
| Process handling | Keyboard process killed between FA toggles (per operator report) |

## Observed matrix

| Check | FA **off** | FA **on** |
|---|---|---|
| Keyboard can be invoked after process kill | Yes | Yes |
| `nihao` candidates | Same as FA on (operator: consistent with FA on) | Normal / expected |
| Main-App setting change reflected in keyboard | Yes (operator) | Yes |
| User-visible degradation banner/prompt | None | n/a |
| Key haptic feedback | **Absent** | **Present** |
| Other perceptible input differences | Operator reports none beyond haptics (and possibly key-click path) | — |

## Operator interpretation

> 项目中 FA 开关可能目前只影响按键音和按键震动。

## Structured conclusions (from observation)

| Claim | Result |
|---|---|
| Basic input does **not** require Full Access | **Supported** — Stop Condition for 03 remains green |
| Complete shared RIME / Chinese candidates require Full Access on this build/OS | **Not supported by this run** — candidates matched with FA off while 雾凇 already deployed |
| Some shared feedback capabilities require Full Access | **Supported** — haptics present only with FA on |
| Setup/degradation is fully self-diagnosing in UI | **Not supported** — no degradation prompt when FA off |
| TD-004 fully closed | **No** — matrix fidelity and Extension-visible recovery remain open |

## Product / Architecture notes

1. Pre-implementation capability matrix in `ONBOARDING_ACTIVATION.md` **over-states** “real RIME candidates unavailable without FA” relative to this iPhone 13 Pro / iOS 27 beta 3 observation when resources are already deployed.
2. Feedback settings UI already documents Full Access for haptic/App Group sync; device evidence aligns more closely with that narrower dependency than with a blanket RIME-off claim.
3. Possible explanations (not proven by this record): iOS 27 beta App Group readability without FA; residual container access after prior FA-on deploy; settings “sync” observed on non-feedback keys; haptic path gated by cached feedback prefs or FA-sensitive APIs. Architecture follow-up should verify with logging of `runtimeDirectories()` / App Group defaults read under FA off after cold Extension launch.
4. Guide activation checklist remains valuable for add-keyboard / FA education / deploy / first-input; copy that implies full Chinese input is impossible without FA should be softened in a follow-up amendment.

## Evidence boundary

- This is a human qualitative matrix, not a performance/jetsam package.
- It does not authorize App Store submission.
- It does not by itself close TD-004.
