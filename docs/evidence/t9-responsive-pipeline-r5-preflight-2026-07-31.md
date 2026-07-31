# T9 responsive pipeline R5-Preflight evidence — 2026-07-31

**Status:** `R5-Preflight dual independent review Pass with conditions; formal R5 A/B not claimed`  
**Design:** [`r5-preflight-design`](../assignments/t9-responsive-pipeline-001-r5-preflight-design.md)  
**Product:** R5-Preflight authorized (Debug dual-gate arm + content-free logs)  
**Formal R5 A/B / Product Gate:** **not claimed**

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

Then open the keyboard once so `activateRimeRuntimeAfterKeyboardPresentation` runs.
In diagnostics (logging enabled), look for:

```text
T9RESP marker=PATH path=thread-affine fixture=T9RESP-R5P dualGateRequested=1 dualGateActive=1
T9RESP marker=READY fixture=T9RESP-R5P bootstrap=config-only session=owner-thread
T9RESP marker=PUBLISH fixture=T9RESP-R5P epoch=… rev=…
```

## Explicit non-claims

- Formal R5 Human A/B Pass
- ADR 0025 Accept / Product Gate / Release default-on
- Subjective non-stutter
- Live typo librime sidecar under dual-gate (uses CandidateProvider adapter)
