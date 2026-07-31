# T9 responsive pipeline R5-Preflight evidence — 2026-07-31

**Status:** `R5-Preflight Closed — dual independent review Pass with conditions + physical device path on/off verified; formal R5 A/B not claimed`  
**Design:** [`r5-preflight-design`](../assignments/t9-responsive-pipeline-001-r5-preflight-design.md)  
**Product:** R5-Preflight authorized (Debug dual-gate arm + content-free logs)  
**Implementation tip:** `87d3e7c`  
**Formal R5 A/B / Product Gate / ADR Accept / Release default-on:** **not claimed**

## Delivered

| Item | Location |
|---|---|
| Arm resolution | `ResponsiveRimePreflight.swift` |
| App Group key | `uk.t9resp.preflight.dualGate` |
| Compile flag | `T9_RESPONSIVE_DEVICE_PREFLIGHT_ENABLED` (optional; not a project default) |
| Extension install | `KeyboardViewController+Bootstrap.installResponsiveDualGatePreflightIfArmed` |
| Publish marker | `KeyboardController.applyResponsivePublishedSnapshot` when thread-affine |

## Tests

```bash
swift test --package-path Packages/KeyboardCore --filter ResponsiveRimePreflightTests
swift test --package-path Packages/KeyboardCore
```

| Suite | Result |
|---|---|
| `ResponsiveRimePreflightTests` | **5 / 0** |
| KeyboardCore full | **836 / 0** |

## Operator arm (DEBUG device / Simulator)

App Group: `group.com.DoubleShy0N.Universe-Keyboard`

```bash
# Arm dual-gate (DEBUG build only; Release ignores)
defaults write group.com.DoubleShy0N.Universe-Keyboard uk.t9resp.preflight.dualGate -bool true

# Disarm
defaults write group.com.DoubleShy0N.Universe-Keyboard uk.t9resp.preflight.dualGate -bool false
```

Physical-device App Group cannot be written with Mac `defaults write` alone.
This preflight used `devicectl device copy` into the App Group preferences
plist and/or compile-flag injection for the on arm.

Then open the keyboard once so `activateRimeRuntimeAfterKeyboardPresentation` runs.
In diagnostics (logging enabled), look for:

```text
T9RESP marker=PATH path=thread-affine fixture=T9RESP-R5P dualGateRequested=1 dualGateActive=1
T9RESP marker=READY fixture=T9RESP-R5P bootstrap=config-only session=owner-thread
T9RESP marker=PUBLISH fixture=T9RESP-R5P epoch=… rev=…
```

## Physical device path on/off (Human + Environment Executor)

**Date:** `2026-07-31 Asia/Shanghai`  
**Device:** iPhone 13 Pro (`iPhone14,2`), iOS 27.0 (`24A5390f`), UDID
`00008110-000A08440198801E`, name `DoubleShy0N`  
**Host app diagnostics:** `logging_enabled=true`, engine category on  
**Human role:** physical T9 typing + App diagnostics export (full buffer; no
in-app filter)  
**Environment Executor:** Debug install / App Group prefs / teardown reinstall  
**Evidence class:** content-free path markers only (design §3 optional device)

### Arm ON (Round 1)

| Field | Value |
|---|---|
| Binary | Debug + `OTHER_SWIFT_FLAGS=-DT9_RESPONSIVE_DEVICE_PREFLIGHT_ENABLED` |
| App Group | `uk.t9resp.preflight.dualGate=true` |
| Source tip | `87d3e7c` |
| Wall clock (device log) | ~12:59:11 |

**Markers observed (content-free excerpts):**

```text
T9RESP marker=PATH path=thread-affine fixture=T9RESP-R5P dualGateRequested=1 dualGateActive=1
T9RESP marker=READY fixture=T9RESP-R5P bootstrap=config-only session=owner-thread
T9RESP marker=PUBLISH fixture=T9RESP-R5P epoch=1 rev=1
… continuous PUBLISH through at least rev=21 …
```

**Absent:** `FALLBACK` / `missing-runtime` / `rebuild-inactive`  
**Also present (context, not T9RESP):** owner-thread librime start
(`Engine init complete` ~44 ms); first key `SLOW RIME` bridge ~55 ms (cold);
subsequent keys show fast `KEY END` (~0.6–2 ms) with async BRIDGE END then
PUBLISH.

**Round-1 path verdict:** **Pass** (thread-affine dual-gate active).

### Arm OFF (Round 2, after teardown)

| Field | Value |
|---|---|
| Binary | Debug **without** `T9_RESPONSIVE_DEVICE_PREFLIGHT_ENABLED` |
| App Group | `uk.t9resp.preflight.dualGate=false` (verified pull-back) |
| Source tip | same `87d3e7c` tree, rebuilt gate-off |
| Wall clock (device log) | ~13:04:20 |

**Markers / install path observed:**

```text
Keyboard visible; creating RimeEngineImpl
T9RESP marker=PATH path=sync fixture=T9RESP-R5P dualGateRequested=0 dualGateActive=0
RIME session prepared for visible keyboard input
```

**Absent:** thread-affine `READY` (`bootstrap=config-only session=owner-thread`);
`T9RESP … PUBLISH fixture=T9RESP-R5P`; any `FALLBACK`  
**Also present (context):** live MainActor session (`validBefore=true` with
non-zero session id); `KEY END` includes engine time (key #1 total ~64 ms /
engine ~59 ms cold; later keys ~4–19 ms).

**Round-2 path verdict:** **Pass** (default sync / dual-gate inactive).

### Paired path matrix

| Dimension | ON | OFF |
|---|---|---|
| `path=` | `thread-affine` | `sync` |
| `dualGateActive` | `1` | `0` |
| READY owner-thread | yes | no |
| PUBLISH R5P | yes (rev↑) | no |
| Install line | dual-gate preflight | `creating RimeEngineImpl` |

## Explicit non-claims

- Formal R5 Human A/B Pass (fixed fixture matrix / subjective non-stutter)
- ADR 0025 Accept / Product Gate / Release default-on
- Subjective non-stutter or numeric product SLO
- Live typo librime sidecar under dual-gate (uses CandidateProvider adapter)
- Jetsam / memory budget under deep composition

## Close disposition (roles)

| Role | Judgment |
|---|---|
| 🧭 Product Lead | **R5-Preflight Closed** for authorized preflight scope only |
| 🧪 Quality | Device path evidence **accepted** as optional design §3 fulfillment; not formal R5 |
| 🏛️ Architecture | Boundary held: content-free markers; dual-gate default-off restored after teardown |
| 📋 Program Manager | Parent Assignment remains **Active**; next formal knife needs Product auth (formal R5 or other) |
