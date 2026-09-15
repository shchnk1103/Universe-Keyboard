# RELEASE-2026-0801-04 — Build 55 TD-003 真人功能观察回执

> **Run ID:** RELEASE-2026-0801-04-B55-TD003-HUMAN-OBS-20260913
> **Status:** Device-attested functional observation — Pass; TD-003 performance baseline remains open
> **Evidence grade:** Device-attested for the Human observation; the Instruments attempts are Executor-recorded environment failures
> **Collected:** 2026-09-13 Asia/Shanghai
> **Assignment:** [RELEASE-2026-0801-04](../assignments/release-2026-08-01-04-device-performance.md)

## Scope and authority

Human Product Owner completed the declared label-based synthetic keyboard sequence twice after the TD-003 instructions and reported no observed abnormality. This receipt records that functional observation only. It does not convert an invalid Instruments collection into a performance measurement, and it is not a Quality, Product or Release conclusion.

The receipt intentionally does not retain the exact key sequence, typed text, candidate text, host text or screenshots. The observed action was performed against the exact Build 55 device setup; no install, uninstall, App Group reset or RIME reset was part of this observation.

## Frozen candidate and runtime context

| Boundary | Recorded value |
|---|---|
| Source | main @ b8175129f26f787a6c7fee0be5977ebec46edf60 |
| Candidate tag | testflight-v1.0-rc2-build55 (remote lightweight tag) |
| Xcode Cloud | Archive Pilot (No Distribution), Build 55; Build ID 8ca1634e-9139-405a-aa5c-75c3d6919908 |
| Version/build | 1.0 (55) |
| Device | iPhone 13 Pro (iPhone14,2), iOS 27.0 (24A435) |
| Measurement host/tool | macOS 27.0 (26A428); Xcode/Instruments 27.0 (27A266a) |
| Host field | Blank Reminders title field; no reminder was intentionally saved |
| Schema/access | Universe Chinese nine-key with the previously prepared 雾凇 schema; Full Access on |

## Human-attested result

| Claim | Outcome | Boundary |
|---|---|---|
| The declared synthetic key-label sequence was completed twice | pass | Human reported both runs completed |
| A visible abnormality was observed during the two runs | none reported | This is a Human observation, not a latency budget |
| Exact input/candidate/host content is retained | no | Content-free evidence boundary preserved |
| TD-003 cold/warm numeric baseline is established | inconclusive | No valid trace captured the actions |
| Quality/Release conclusion | pending | This receipt is not an independent review or Product decision |

## Instruments attempts excluded from TD-003

| Attempt | Trace pointer | Observed result | Disposition |
|---|---|---|---|
| After authorized Extension termination | /private/tmp/uk-build55-td003-release-RLUy5B/td003-release-time-profiler.trace | Duration 1.180512 s; end reason Device disconnected; no product-process sample | excluded |
| After authorized full iPhone reboot and main-App cleanup | /private/tmp/uk-build55-td003-rebooted-JzZA48/td003-rebooted-time-profiler.trace | Duration 1.194239 s; end reason Device disconnected; no product-process sample | excluded |

The device was subsequently confirmed connected, paired, unlocked since boot and in Developer Mode. The two trace starts therefore do not provide evidence that the Human actions were captured. They remain retained outside Git as explicit invalidation artifacts, not as performance evidence.

## Claim boundary and next action

This receipt supports the narrow claim that the Human completed the declared Build 55 keyboard sequence twice without reporting a visible problem. It does not support a claim about cold/warm startup, per-key latency, CPU, memory growth, candidate refresh timing, absence of hangs, absence of crashes or Jetsam, or regression against another build.

TD-003 remains open for broader external testing. The next valid route requires a compatible, stable physical-device collector environment or an explicit Product decision to leave the broader external gate blocked. No further same-host trace retry is implied by this receipt.

No code, install, uninstall, commit, push, TestFlight group assignment, Beta Review submission or release action is authorized by this record.
