# NATIVE-EXPERIENCE-001 — Step 2 Environment Selection

> **Status:** Archived
>
> **Closure date:** 2026-07-09 Asia/Shanghai
>
> **Current source of truth:** environment capture procedure and later NE evidence records.
>
> **Related ADRs:** ADR 0010 when provenance applies
>
> **Guidance:** This plan is no longer current development guidance.

Closed Date: 2026-07-09

Frozen Date: 2026-07-09

Protocol: `docs/plans/native-experience-001-investigation-protocol.md`

Step 1 Source of Truth:
`docs/plans/native-experience-001-step-1-observability-assessment.md`

Source Scope: Step 2 only — Environment Selection

## Closing Rule

This Step selects the Investigation environment baseline only.

No measurement data is collected during Step 2. No implementation work is
created during Step 2. No new Work Item is created during Step 2. Step 2 does
not modify Step 1 findings, evidence, classifications, or confidence values.

If Step 2 must be changed later, create a new Revision. Do not directly edit
this Frozen Step record.

## Source of Truth for Step 3

This document is the only Source of Truth for Step 3 — Evidence Collection.

Step 3 may collect evidence only for environments marked `Included` below,
unless a formal Revision changes this Step 2 record. Step 3 must preserve the
`Deferred` and `Excluded` reasons recorded here.

## Step 2 Evidence

### NE1-S2-E001 — Frozen Environment Matrix

Evidence Type: Protocol source

Source: Frozen Protocol §6 Environment Matrix

Observation: The protocol defines the required dimensions: Device, OS Version,
Cold/Warm, Host App, Schema, Simplification, Full Access, Thermal State, and
Debugger Attached.

Confidence: High

Reason: This is directly specified by the frozen Investigation Protocol.

### NE1-S2-E002 — Step 1 Tooling Constraints

Evidence Type: Closed Step source

Source: Step 1 Closing Record

Observation: Existing observability is sufficient to begin Investigation, but
not sufficient for full-resolution answers across all Scope items. Startup
subphase, RIME subphase, and first-key-to-candidate boundaries require reduced
precision.

Confidence: High

Reason: Step 1 is closed and is the only Source of Truth for Step 2.

### NE1-S2-E003 — Project Deployment Target

Evidence Type: Source audit

Source: `Universe Keyboard.xcodeproj/project.pbxproj`

Observation: Project build settings include `IPHONEOS_DEPLOYMENT_TARGET = 26.4`.

Confidence: High

Reason: The deployment target is present in project build settings.

### NE1-S2-E004 — Available Simulator Runtime

Evidence Type: Environment discovery

Source: `xcrun simctl list devices available`

Observation: iOS 26.5 simulators are available for iPhone 17 Pro, iPhone 17 Pro
Max, iPhone 17e, and iPhone Air. iOS 27.0 simulators are also installed.

Confidence: High

Reason: The local simulator list was read successfully outside the sandbox.

### NE1-S2-E005 — Physical Device Availability

Evidence Type: Environment discovery

Source: `xcrun xctrace list devices`

Observation: The command listed simulators only. No connected physical iPhone
was reported.

Confidence: Medium

Reason: `xctrace list devices` is a standard discovery source, but physical
device availability can change without repository state changing.

### NE1-S2-E006 — Full Access Requirement

Evidence Type: Source audit

Source: `Keyboard/Info.plist`

Observation: The Keyboard Extension declares `RequestsOpenAccess = true`.

Confidence: High

Reason: The value is present in the extension plist.

### NE1-S2-E007 — Full Access Degradation Boundary

Evidence Type: Architecture source

Source: ADR 0007 — Full Access And Privacy Boundary

Observation: Full Access OFF is a degraded state. The complete degradation
matrix is accepted as follow-up work and is not currently implemented.

Confidence: High

Reason: ADR 0007 explicitly states the boundary and pending degradation matrix.

### NE1-S2-E008 — RIME Production Scheme Options

Evidence Type: Source audit

Source: `Universe Keyboard/Services/SchemaManagerTypes.swift`

Observation: The scheme catalog includes built-in `luna_pinyin` and downloaded
`rime_ice`. `rime_ice` requires Lua and represents the richer production scheme.

Confidence: High

Reason: The catalog source defines the available schemes and their properties.

### NE1-S2-E009 — Simplification Default

Evidence Type: Source audit

Source: `Universe Keyboard/Views/Settings/RimeSettingsStore.swift`

Observation: `rime_simplification` defaults to `true` when no persisted value
exists.

Confidence: High

Reason: The settings store explicitly reads the persisted value or defaults to
`true`.

## Baseline Environment

### Primary Baseline Device

Selected: iPhone 17 Pro Simulator, iOS 26.5

Status: Included

Reason: The frozen protocol names Simulator as the Primary Baseline. iPhone 17
Pro Simulator on iOS 26.5 is available locally and satisfies the project
deployment target of iOS 26.4+. It provides repeatable local execution for
initial evidence collection while physical validation remains unavailable.

### Validation Devices

Selected: Physical modern iPhone 17-series device

Status: Deferred

Reason: The frozen protocol requires modern-device validation, but `xctrace`
did not report any connected physical iPhone. This remains required before
product-level Native Experience conclusions are finalized.

Selected: Physical older supported device, preferably iPhone 13 Pro

Status: Deferred

Reason: The frozen protocol requires one older-device regression reference if
available. No physical device is currently visible. This remains the regression
reference target once hardware is available.

### iOS Version

Primary: iOS 26.5 Simulator

Status: Included

Reason: iOS 26.5 is available locally and is compatible with the project's
iOS 26.4 deployment target. It is the closest available stable simulator
runtime discovered during Step 2.

Validation: Physical-device iOS version

Status: Deferred

Reason: No physical device is currently connected. Exact OS build must be
recorded during Step 3 if a device becomes available.

Excluded: iOS 27.0 Simulator

Reason: iOS 27.0 is not selected for the production baseline because it may
represent future or beta lifecycle behavior outside the current baseline scope.
It is Future Investigation material.

### Build Configuration

Selected: Release configuration

Status: Included

Reason: `docs/PERFORMANCE_BASELINE.md` requires Release-like behavior for
product conclusions. Debug runs may be used only for diagnostic orientation,
not for baseline conclusions.

### RIME Configuration

Selected Baseline: `rime_ice`, default production configuration, ordinary
pinyin input, Lua available but no dedicated advanced-input trigger sequence.

Status: Included

Reason: `rime_ice` is the richer production scheme and exercises the RIME,
Lua, OpenCC, and large-dictionary path relevant to user-perceived typing
quality. Ordinary pinyin input is selected for baseline because first typing
latency should represent normal use.

Selected Validation: `rime_ice` with advanced-input trigger sequences

Status: Included

Reason: Lua initialization is in scope. Advanced-input trigger sequences are
validation scenarios, not the primary ordinary typing baseline.

Selected Regression: `luna_pinyin`

Status: Deferred

Reason: `luna_pinyin` is useful as a smaller built-in scheme reference, but
the primary production baseline is `rime_ice`. It may be collected later to
separate large-schema cost from extension lifecycle cost.

### Simplification / OpenCC

Selected Baseline: OpenCC simplification enabled

Status: Included

Reason: The settings default is `rime_simplification = true`, and OpenCC is
part of the deployed RIME pipeline. This represents the default production
candidate/output path.

Selected Validation: OpenCC simplification disabled

Status: Included

Reason: `docs/PERFORMANCE_BASELINE.md` requires OpenCC impact comparison.
This is a validation comparison, not the primary production baseline.

### Full Access State

Selected Baseline: Full Access ON

Status: Included

Reason: The extension requests Full Access, shared RIME runtime/configuration
depends on App Group access, and ADR 0007 classifies Full Access OFF as
degraded.

Selected Degraded State: Full Access OFF

Status: Deferred

Reason: Full Access OFF is not the production baseline and the degradation
matrix remains pending per ADR 0007. It should not block the primary baseline,
but it remains a future degraded-state investigation target.

### Host Applications

Selected Primary Host: Messages

Status: Included

Reason: The frozen protocol names Messages as the Primary Baseline host. It is
a common high-frequency text-entry surface and suitable for first-key baseline
collection.

Selected Validation Hosts: Safari address bar, Notes body

Status: Included

Reason: Safari address bar and Notes body exercise different host text-field
behaviors. They validate that findings are not specific to Messages.

Selected Third-Party Host

Status: Deferred

Reason: The protocol includes third-party app coverage, but no specific
third-party host is selected for the baseline. Selection requires a stable,
repeatable host app with known text-field behavior.

### Cold / Warm Startup Definitions

Cold Startup:

The Keyboard Extension process is not resident before invocation. The main App
deployment and RIME runtime files are already prepared. The measurement window
begins at keyboard invocation and excludes main-App deployment, download, and
schema installation.

Warm Startup:

The Keyboard Extension process remains resident after a prior presentation.
The keyboard is dismissed and invoked again without killing the extension
process. Visibility cleanup from ADR 0002 is part of warm-start behavior.

Runtime Session Recovery:

Runtime recovery after an active-session failure while still visible is not a
cold or warm startup. It is a separate validation scenario under ADR 0004.

## Environment Matrix

| Environment ID | Device | OS | Build | Host | Startup | Schema | OpenCC | Full Access | Status | Reason |
|---|---|---|---|---|---|---|---|---|---|---|
| NE1-ENV-001 | iPhone 17 Pro Simulator | iOS 26.5 | Release | Messages | Cold + Warm | rime_ice ordinary pinyin | Enabled | ON | Included | Primary Baseline: available, protocol-aligned, repeatable. |
| NE1-ENV-002 | iPhone 17 Pro Simulator | iOS 26.5 | Release | Safari address bar | Cold + Warm | rime_ice ordinary pinyin | Enabled | ON | Included | Host validation: validates non-Messages text-field behavior. |
| NE1-ENV-003 | iPhone 17 Pro Simulator | iOS 26.5 | Release | Notes body | Cold + Warm | rime_ice ordinary pinyin | Enabled | ON | Included | Host validation: validates long-form text field behavior. |
| NE1-ENV-004 | iPhone 17 Pro Simulator | iOS 26.5 | Release | Messages | First-key + typing | rime_ice advanced-input trigger | Enabled | ON | Included | Lua validation: isolates advanced-input path from ordinary baseline. |
| NE1-ENV-005 | iPhone 17 Pro Simulator | iOS 26.5 | Release | Messages | Cold + Warm | rime_ice ordinary pinyin | Disabled | ON | Included | OpenCC validation: required to compare simplification impact. |
| NE1-ENV-006 | iPhone 17 Pro Simulator | iOS 26.5 | Release | Messages | Repeated host switching | rime_ice ordinary pinyin | Enabled | ON | Included | Stress scenario: lifecycle and memory warm behavior. |
| NE1-ENV-007 | iPhone 17 Pro Simulator | iOS 26.5 | Release | Messages | Rapid page switching | rime_ice ordinary pinyin | Enabled | ON | Included | Stress scenario: UI responsiveness and rendering stability. |
| NE1-ENV-008 | Physical iPhone 17-series | Exact OS TBD | Release | Messages | Cold + Warm | rime_ice ordinary pinyin | Enabled | ON | Deferred | Modern-device validation required, but no physical device is currently visible. |
| NE1-ENV-009 | Physical iPhone 13 Pro | Exact OS TBD | Release | Messages | Cold + Warm | rime_ice ordinary pinyin | Enabled | ON | Deferred | Older-device regression reference required if hardware is available. |
| NE1-ENV-010 | iPhone 17 Pro Simulator | iOS 26.5 | Release | Third-party app TBD | Cold + Warm | rime_ice ordinary pinyin | Enabled | ON | Deferred | Third-party host not selected; needs a stable repeatable app choice. |
| NE1-ENV-011 | iPhone 17 Pro Simulator | iOS 26.5 | Release | Messages | Cold + Warm | rime_ice ordinary pinyin | Enabled | OFF | Deferred | Degraded Full Access state; ADR 0007 degradation matrix remains pending. |
| NE1-ENV-012 | iPhone 17 Pro Simulator | iOS 26.5 | Release | Messages | Cold + Warm | luna_pinyin | Enabled | ON | Deferred | Built-in scheme regression reference; not primary production baseline. |
| NE1-ENV-013 | iPhone 17 Pro Simulator | iOS 27.0 | Release | Messages | Cold + Warm | rime_ice ordinary pinyin | Enabled | ON | Excluded | Future/beta system behavior is outside current production baseline. |
| NE1-ENV-014 | iPad simulators | iOS 26.5 / 27.0 | Release | Messages | Cold + Warm | rime_ice ordinary pinyin | Enabled | ON | Excluded | Protocol baseline is iPhone-focused; iPad needs separate layout baseline. |
| NE1-ENV-015 | Debug build | iOS 26.5 | Debug | Messages | Cold + Warm | rime_ice ordinary pinyin | Enabled | ON | Excluded | Debug behavior is diagnostic only and cannot support product conclusions. |

## Baseline Selection Decision

### Production Baseline Representation

The selected baseline is sufficient to begin Investigation because it covers:

- The production scheme path (`rime_ice`)
- The default production OpenCC state (`simplification = true`)
- The requested production access mode (`Full Access ON`)
- The primary host specified by the frozen protocol (Messages)
- Both cold and warm startup definitions
- A Release build configuration
- An available iOS runtime compatible with the project deployment target

The selected baseline is not sufficient for final product-level conclusions
until physical-device validation is collected or explicitly marked unavailable
in the final report.

### Category Assignment

| Category | Environments |
|---|---|
| Baseline | NE1-ENV-001 |
| Validation | NE1-ENV-002, NE1-ENV-003, NE1-ENV-004, NE1-ENV-005, NE1-ENV-008 |
| Regression | NE1-ENV-009, NE1-ENV-012 |
| Stress | NE1-ENV-006, NE1-ENV-007 |
| Future Investigation | NE1-ENV-010, NE1-ENV-011, NE1-ENV-013, NE1-ENV-014 |
| Excluded From Baseline | NE1-ENV-013, NE1-ENV-014, NE1-ENV-015 |

## Risks

| Risk ID | Description | Impact | Mitigation |
|---|---|---|---|
| NE1-S2-R001 | Device-specific behavior: simulator latency may not match physical device latency. | Product conclusions could overfit simulator behavior. | Treat simulator as Primary Baseline for repeatability only; require physical modern-device validation before final product conclusions. |
| NE1-S2-R002 | No physical device currently discovered. | Modern-device and older-device validation cannot be executed immediately. | Mark physical devices Deferred; Step 3 may proceed only for Included environments. Final Report must preserve the validation gap if unresolved. |
| NE1-S2-R003 | iOS 26.5 simulator differs from deployment target iOS 26.4. | Minor lifecycle/runtime differences may affect timing. | Record exact runtime in every Measurement; do not generalize across iOS versions without matching evidence. |
| NE1-S2-R004 | iOS 27.0 simulators are installed and could be accidentally used. | Future/beta behavior could contaminate baseline. | Exclude iOS 27.0 from current baseline and require environment ID tagging for every Measurement. |
| NE1-S2-R005 | Background process interference. | Repeatability and latency distribution could be distorted. | Step 3 must record thermal state, debugger state, host, and anomalous system behavior per protocol. |
| NE1-S2-R006 | Host application differences. | Messages-only evidence may not represent other text fields. | Include Safari address bar and Notes body as validation hosts. |
| NE1-S2-R007 | Step 1 reduced observability for first-key and subphase boundaries. | Some findings may have lower confidence or reduced phase precision. | Step 3 must preserve Step 1 confidence and classify unresolved gaps as Requires Tooling or Unknown without implementation. |
| NE1-S2-R008 | Full Access OFF is deferred. | Degraded-state behavior remains outside primary baseline. | Explicitly mark Full Access OFF as Future Investigation / Deferred; do not treat baseline as degraded-state proof. |

## Step 2 Findings

### NE1-S2-F001 — Primary Baseline Is Simulator-Based

Evidence: NE1-S2-E001, NE1-S2-E003, NE1-S2-E004

Finding: The Primary Baseline environment is iPhone 17 Pro Simulator on iOS
26.5, Release configuration, Messages host, `rime_ice`, OpenCC enabled,
Full Access ON, cold and warm startup.

Classification: Environment Baseline

Confidence: High

Reason: This environment is available locally and matches the frozen protocol's
Primary Baseline requirement.

### NE1-S2-F002 — Physical-Device Validation Is Required But Deferred

Evidence: NE1-S2-E001, NE1-S2-E005

Finding: Modern physical-device validation and older-device regression
validation are required for product-level confidence, but no physical device
is currently discoverable.

Classification: Deferred Validation

Confidence: Medium

Reason: Physical-device availability is environment-dependent and can change.

### NE1-S2-F003 — Production RIME Baseline Uses `rime_ice`

Evidence: NE1-S2-E008, NE1-S2-E009

Finding: `rime_ice` with OpenCC simplification enabled is selected as the
production RIME baseline. `luna_pinyin` is deferred as a smaller built-in
regression reference.

Classification: Environment Baseline

Confidence: High

Reason: `rime_ice` is the richer production scheme and simplification defaults
to enabled.

### NE1-S2-F004 — Full Access ON Is The Baseline State

Evidence: NE1-S2-E006, NE1-S2-E007

Finding: Full Access ON is selected for baseline collection. Full Access OFF
is deferred as degraded-state investigation.

Classification: Environment Baseline

Confidence: High

Reason: The extension requests Full Access and ADR 0007 treats OFF as degraded.

## Step 2 Decisions

| Decision ID | Decision | Evidence | Confidence |
|---|---|---|---|
| NE1-S2-D001 | Use iPhone 17 Pro Simulator iOS 26.5 as Primary Baseline. | NE1-S2-E001, NE1-S2-E003, NE1-S2-E004 | High |
| NE1-S2-D002 | Use Release configuration for all baseline conclusions. | NE1-S2-E003, `docs/PERFORMANCE_BASELINE.md` | High |
| NE1-S2-D003 | Use `rime_ice` ordinary pinyin + OpenCC enabled + Full Access ON as production baseline. | NE1-S2-E006, NE1-S2-E007, NE1-S2-E008, NE1-S2-E009 | High |
| NE1-S2-D004 | Include Safari and Notes as host validation environments. | NE1-S2-E001 | Medium |
| NE1-S2-D005 | Defer physical modern and older-device environments until hardware is available. | NE1-S2-E005 | Medium |
| NE1-S2-D006 | Exclude iOS 27.0 and Debug builds from baseline conclusions. | NE1-S2-E003, NE1-S2-E004 | High |

## Environment Selection Confidence

Overall Confidence: Medium

Evidence: NE1-S2-E001 through NE1-S2-E009

Reason: The simulator baseline is well-supported by protocol and local
environment evidence. Overall confidence is Medium, not High, because physical
device validation is deferred and Step 1 already established reduced
observability for some first-key and subphase boundaries.

## Governance Self-Check

| Check | Result | Evidence |
|---|---|---|
| 1. 是否完成本 Step 的全部 Exit Criteria？ | Yes | Baseline Environment, Environment Matrix, Baseline Selection Decision, Risks, Confidence, and Closing are documented. |
| 2. 是否产生新的 Knowledge Asset？ | Yes | This Frozen Step 2 Environment Selection record. |
| 3. 是否越过本 Step 的 Scope？ | No | No measurement collection, no implementation, no instrumentation, and no new Work Item. |
| 4. 是否可以正式 Freeze，并作为下一 Step 的唯一 Source of Truth？ | Yes | Status is Frozen; Step 3 source-of-truth rule is defined above. |

## Final Governance Self-Review

Review Date: 2026-07-09

Review Result: Passed

| Check | Result | Evidence |
|---|---|---|
| Every decision recorded in Step 2 is supported by explicit evidence or documented rationale. | Pass | Decisions NE1-S2-D001 through NE1-S2-D006 each cite evidence records or protocol/baseline rationale. |
| No measurement result has entered Step 2. | Pass | Step 2 contains environment discovery and source audit evidence only; no latency, memory, CPU, or interaction measurement value is recorded. |
| No optimization recommendation has entered Step 2. | Pass | Step 2 contains no implementation recommendation and creates no Work Item. Risk mitigations are scoped to environment control and evidence handling. |
| All deferred environments remain explicitly classified as Deferred rather than silently omitted. | Pass | NE1-ENV-008 through NE1-ENV-012 are explicitly marked `Deferred`; excluded environments are separately marked `Excluded`. |
| Step 2 can be understood independently without requiring later Investigation Steps. | Pass | The record includes baseline environment, matrix, decisions, evidence, confidence, risks, and closing rules. |

## Closing Decision

Step 2 — Environment Selection is Frozen.

This document is the authoritative Knowledge Asset for Environment Selection
and the only Source of Truth for Step 3 — Evidence Collection.
