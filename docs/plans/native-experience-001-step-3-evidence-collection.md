# NATIVE-EXPERIENCE-001 — Step 3 Evidence Collection

> **Status:** Archived
>
> **Closure date:** 2026-07-11 Asia/Shanghai (partial Product Review closure)
>
> **Current source of truth:** step-3 interruption diagnosis record and subsequent NE assignments.
>
> **Related ADRs:** none required
>
> **Guidance:** This plan is no longer current development guidance.

Record Date: 2026-07-09

Product Review Date: 2026-07-11

Protocol: `docs/plans/native-experience-001-investigation-protocol.md`

Step 2 Source of Truth:
`docs/plans/native-experience-001-step-2-environment-selection.md`

Source Scope: Step 3 only — Evidence Collection

## Scope Boundary

This Step records reproducible measurements, evidence metadata, and evidence
indexing only.

No findings, bottleneck classification, optimization opportunity, ownership
decision, implementation planning, production code change, instrumentation,
or follow-up Work Item is created by this record.

## Collection Summary

Primary Environment:

- Environment ID: NE1-ENV-001
- Device: iPhone 17 Pro Simulator
- Simulator UDID: 900FB396-39BF-4A84-9E75-FF813C155FA7
- OS Runtime: iOS 26.5
- Build: Release
- Host: Messages (five manual baseline samples collected in NE1-M-038; qualitative only)
- Schema: `rime_ice` ordinary pinyin (planned by Step 2; no typing measurement collected in this Step)
- OpenCC: Enabled (planned by Step 2; no candidate measurement collected in this Step)
- Full Access: ON (planned by Step 2; no keyboard-settings interaction measurement collected in this Step)

Collection Status:

- Environment metadata: Collected
- Release build artifact: Collected
- Simulator boot/install artifact: Collected
- xctrace recording artifact: Interrupted
- main app launch artifact: Collected
- app install / visibility artifacts: Collected
- execution environment revalidation: Collected
- physical device visibility metadata: Collected
- keyboard interaction artifacts: Qualitative observations collected (NE1-M-036 through NE1-M-042)
- cold/warm keyboard startup artifacts: Qualitative observations collected (staged cold, smooth warm)
- first-key/candidate artifacts: Not collected (no quantitative measurement)
- memory/jetsam artifacts: Not collected

## Measurement Records

### NE1-M-001 — Repository and Toolchain Metadata

Environment: NE1-ENV-001

Status: Collected

Artifacts:

- `evidence/native-experience-001/step-3/raw/git-head.txt`
- `evidence/native-experience-001/step-3/raw/git-status-short.txt`
- `evidence/native-experience-001/step-3/raw/xcode-version.txt`
- `evidence/native-experience-001/step-3/raw/keyboard-info-plist.txt`
- `evidence/native-experience-001/step-3/raw/xcodebuild-release-build-settings.txt`
- `evidence/native-experience-001/step-3/logs/xcodebuild-show-build-settings-stderr.txt`

Evidence Metadata:

- Measurement Type: Environment/build metadata
- Tooling: `git`, `xcodebuild`, `plutil`
- Production Code Modified: No
- Instrumentation Added: No
- Measurement Result Included: No

### NE1-M-002 — Simulator and xctrace Device Metadata

Environment: NE1-ENV-001

Status: Collected

Artifacts:

- `evidence/native-experience-001/step-3/raw/simctl-devices-available.txt`
- `evidence/native-experience-001/step-3/raw/simctl-runtimes.txt`
- `evidence/native-experience-001/step-3/raw/xctrace-devices.txt`
- `evidence/native-experience-001/step-3/raw/xctrace-templates.txt`
- `evidence/native-experience-001/step-3/raw/xctrace-record-help.txt`
- `evidence/native-experience-001/step-3/raw/simctl-device-NE1-ENV-001-after-install.txt`

Evidence Metadata:

- Measurement Type: Environment/device metadata
- Tooling: `xcrun simctl`, `xcrun xctrace`
- Production Code Modified: No
- Instrumentation Added: No
- Measurement Result Included: No

### NE1-M-003 — Release Simulator Build Artifact

Environment: NE1-ENV-001

Status: Collected

Artifacts:

- `evidence/native-experience-001/step-3/build/xcodebuild-release-build-NE1-ENV-001.stdout.txt`
- `evidence/native-experience-001/step-3/build/xcodebuild-release-build-NE1-ENV-001.stderr.txt`
- `evidence/native-experience-001/step-3/build/DerivedData/Build/Products/Release-iphonesimulator/Universe Keyboard.app`

Evidence Metadata:

- Measurement Type: Build artifact and build log
- Tooling: `xcodebuild`
- Configuration: Release
- Destination: `platform=iOS Simulator,id=900FB396-39BF-4A84-9E75-FF813C155FA7`
- Production Code Modified: No
- Instrumentation Added: No
- Measurement Result Included: No

### NE1-M-004 — Simulator Boot and Install Artifact

Environment: NE1-ENV-001

Status: Collected

Artifacts:

- `evidence/native-experience-001/step-3/logs/simctl-boot-NE1-ENV-001.stdout.txt`
- `evidence/native-experience-001/step-3/logs/simctl-boot-NE1-ENV-001.stderr.txt`
- `evidence/native-experience-001/step-3/logs/simctl-install-NE1-ENV-001.stdout.txt`
- `evidence/native-experience-001/step-3/logs/simctl-install-NE1-ENV-001.stderr.txt`

Evidence Metadata:

- Measurement Type: Simulator preparation artifact
- Tooling: `xcrun simctl boot`, `xcrun simctl install`
- Production Code Modified: No
- Instrumentation Added: No
- Measurement Result Included: No

### NE1-M-005 — Time Profiler Recording Attempt

Environment: NE1-ENV-001

Status: Interrupted

Artifacts:

- `evidence/native-experience-001/step-3/traces/NE1-M-001-NE1-ENV-001-main-app-launch-time-profiler.trace`
- `evidence/native-experience-001/step-3/logs/NE1-M-001-xctrace.stdout.txt`
- `evidence/native-experience-001/step-3/logs/NE1-M-001-xctrace.stderr.txt`

Evidence Metadata:

- Measurement Type: Time Profiler recording attempt
- Tooling: `xcrun xctrace record`
- Template: Time Profiler
- Time Limit Requested: 5s
- Target Requested: Release simulator main app bundle
- Production Code Modified: No
- Instrumentation Added: No
- Measurement Result Included: No
- Collection Status Note: Command exceeded expected completion window and was terminated. Artifact is retained as an interrupted recording attempt.

### NE1-M-006 — Main App Launch Attempt

Environment: NE1-ENV-001

Status: Interrupted

Artifacts:

- `evidence/native-experience-001/step-3/logs/simctl-launch-main-app-NE1-ENV-001.stdout.txt`
- `evidence/native-experience-001/step-3/logs/simctl-launch-main-app-NE1-ENV-001.stderr.txt`

Evidence Metadata:

- Measurement Type: App launch attempt
- Tooling: `xcrun simctl launch`
- Bundle ID: `com.DoubleShy0N.Universe-Keyboard`
- Production Code Modified: No
- Instrumentation Added: No
- Measurement Result Included: No
- Collection Status Note: Command exceeded expected completion window and was terminated.

### NE1-M-007 — App Container Query Attempts

Environment: NE1-ENV-001

Status: Interrupted

Artifacts:

- `evidence/native-experience-001/step-3/raw/app-container-NE1-ENV-001.txt`
- `evidence/native-experience-001/step-3/logs/app-container-NE1-ENV-001.stderr.txt`
- `evidence/native-experience-001/step-3/raw/keyboard-extension-container-NE1-ENV-001.txt`
- `evidence/native-experience-001/step-3/logs/keyboard-extension-container-NE1-ENV-001.stderr.txt`

Evidence Metadata:

- Measurement Type: Installed app container query attempt
- Tooling: `xcrun simctl get_app_container`
- Production Code Modified: No
- Instrumentation Added: No
- Measurement Result Included: No
- Collection Status Note: Commands exceeded expected completion window and were terminated.

### NE1-M-008 — Artifact Manifest

Environment: NE1-ENV-001

Status: Collected

Artifacts:

- `evidence/native-experience-001/step-3/raw/artifact-paths.txt`
- `evidence/native-experience-001/step-3/raw/artifact-sha256.txt`

Evidence Metadata:

- Measurement Type: Artifact index and checksum manifest
- Tooling: `find`, `shasum`
- Production Code Modified: No
- Instrumentation Added: No
- Measurement Result Included: No

### NE1-M-009 — Execution Environment Revalidation

Environment: NE1-ENV-001

Status: Collected

Artifacts:

- `evidence/native-experience-001/step-3/raw/NE1-M-009-xcode-version-revalidation.txt`
- `evidence/native-experience-001/step-3/raw/NE1-M-009-simctl-devices-revalidation.txt`
- `evidence/native-experience-001/step-3/logs/NE1-M-009-simctl-devices-revalidation.stderr.txt`
- `evidence/native-experience-001/step-3/raw/NE1-M-009-xctrace-devices-revalidation.txt`
- `evidence/native-experience-001/step-3/logs/NE1-M-009-xctrace-devices-revalidation.stderr.txt`

Evidence Metadata:

- Measurement Type: Execution environment revalidation metadata
- Tooling: `xcodebuild`, `xcrun simctl`, `xcrun xctrace`
- Production Code Modified: No
- Instrumentation Added: No
- Measurement Result Included: No
- Collection Status Note: Tooling and device-list commands returned successfully. Physical iPhone visibility metadata is recorded in the xctrace devices artifact.

### NE1-M-010 — Simulator Install Revalidation Attempt

Environment: NE1-ENV-001

Status: Interrupted

Artifacts:

- `evidence/native-experience-001/step-3/logs/NE1-M-010-simctl-install-revalidation.stdout.txt`
- `evidence/native-experience-001/step-3/logs/NE1-M-010-simctl-install-revalidation.stderr.txt`
- `evidence/native-experience-001/step-3/raw/NE1-M-010-process-state-before-terminate.txt`
- `evidence/native-experience-001/step-3/raw/NE1-M-010-simctl-device-after-interruption.txt`
- `evidence/native-experience-001/step-3/logs/NE1-M-010-simctl-device-after-interruption.stderr.txt`

Evidence Metadata:

- Measurement Type: Simulator install revalidation attempt
- Tooling: `xcrun simctl install`, `ps`, `xcrun simctl list devices`
- Production Code Modified: No
- Instrumentation Added: No
- Measurement Result Included: No
- Collection Status Note: Install command exceeded expected completion window and was terminated after process-state evidence was captured.

### NE1-M-011 — Simulator App Visibility Query Attempt

Environment: NE1-ENV-001

Status: Interrupted

Artifacts:

- `evidence/native-experience-001/step-3/raw/NE1-M-011-simctl-listapps.txt`
- `evidence/native-experience-001/step-3/logs/NE1-M-011-simctl-listapps.stderr.txt`
- `evidence/native-experience-001/step-3/raw/NE1-M-011-process-state-before-terminate.txt`

Evidence Metadata:

- Measurement Type: Simulator app visibility query attempt
- Tooling: `xcrun simctl listapps`, `ps`
- Production Code Modified: No
- Instrumentation Added: No
- Measurement Result Included: No
- Collection Status Note: App visibility query exceeded expected completion window and was terminated after process-state evidence was captured.

### NE1-M-012 — All-Processes Time Profiler Revalidation Attempt

Environment: NE1-ENV-001

Status: Interrupted

Artifacts:

- `evidence/native-experience-001/step-3/traces/NE1-M-012-NE1-ENV-001-all-processes-time-profiler.trace`
- `evidence/native-experience-001/step-3/logs/NE1-M-012-xctrace-all-processes.stdout.txt`
- `evidence/native-experience-001/step-3/logs/NE1-M-012-xctrace-all-processes.stderr.txt`
- `evidence/native-experience-001/step-3/raw/NE1-M-012-process-state-before-terminate.txt`

Evidence Metadata:

- Measurement Type: All-processes Time Profiler revalidation attempt
- Tooling: `xcrun xctrace record`, `ps`
- Template: Time Profiler
- Time Limit Requested: 5s
- Target Requested: all processes on NE1-ENV-001 simulator
- Production Code Modified: No
- Instrumentation Added: No
- Measurement Result Included: No
- Collection Status Note: Recording command exceeded expected completion window and was terminated after process-state evidence was captured.

### NE1-M-018 — Manual Command-Path Smoke Evidence

Environment: NE1-ENV-001

Status: Collected

Artifacts:

- `evidence/native-experience-001/step-3/diagnosis/NE1-M-018-manual-smoke-results.txt`

Evidence Metadata:

- Measurement Type: Manual command-path smoke evidence
- Tooling: User-provided manual command execution
- Production Code Modified: No
- Instrumentation Added: No
- Measurement Result Included: No
- Collection Status Note: Manual evidence reports successful `simctl spawn`, `simctl listapps`, `simctl install`, `simctl launch`, and `xctrace record` when using the correct simulator product and command form.

### NE1-M-019 — App Product and Simulator State Before Install

Environment: NE1-ENV-001

Status: Collected

Artifacts:

- `evidence/native-experience-001/step-3/raw/NE1-M-019-app-products.txt`
- `evidence/native-experience-001/step-3/raw/NE1-M-019-simctl-device-before-app-smoke.txt`
- `evidence/native-experience-001/step-3/logs/NE1-M-019-simctl-device-before-app-smoke.stderr.txt`
- `evidence/native-experience-001/step-3/logs/NE1-M-019-simctl-install-correct-product.stdout.txt`
- `evidence/native-experience-001/step-3/logs/NE1-M-019-simctl-install-correct-product.stderr.txt`

Evidence Metadata:

- Measurement Type: App product path and pre-install simulator state
- Tooling: `find`, `xcrun simctl list devices`, `xcrun simctl install`
- Production Code Modified: No
- Instrumentation Added: No
- Measurement Result Included: No
- Collection Status Note: Initial install attempt returned simulator `Shutdown` state; this is retained as command evidence.

### NE1-M-020 — Simulator Boot and Correct Product Install

Environment: NE1-ENV-001

Status: Collected

Artifacts:

- `evidence/native-experience-001/step-3/logs/NE1-M-020-simctl-boot-before-install.stdout.txt`
- `evidence/native-experience-001/step-3/logs/NE1-M-020-simctl-boot-before-install.stderr.txt`
- `evidence/native-experience-001/step-3/raw/NE1-M-020-simctl-bootstatus-before-install.txt`
- `evidence/native-experience-001/step-3/logs/NE1-M-020-simctl-bootstatus-before-install.stderr.txt`
- `evidence/native-experience-001/step-3/logs/NE1-M-020-simctl-install-correct-product.stdout.txt`
- `evidence/native-experience-001/step-3/logs/NE1-M-020-simctl-install-correct-product.stderr.txt`

Evidence Metadata:

- Measurement Type: Simulator boot and install command evidence
- Tooling: `xcrun simctl boot`, `xcrun simctl bootstatus`, `xcrun simctl install`
- App Product: `Release-iphonesimulator/Universe Keyboard.app`
- Production Code Modified: No
- Instrumentation Added: No
- Measurement Result Included: No

### NE1-M-021 — App Visibility After Install

Environment: NE1-ENV-001

Status: Collected

Artifacts:

- `evidence/native-experience-001/step-3/raw/NE1-M-021-simctl-listapps-after-install.txt`
- `evidence/native-experience-001/step-3/logs/NE1-M-021-simctl-listapps-after-install.stderr.txt`

Evidence Metadata:

- Measurement Type: Installed app visibility evidence
- Tooling: `xcrun simctl listapps`
- Production Code Modified: No
- Instrumentation Added: No
- Measurement Result Included: No
- Collection Status Note: Artifact contains the installed main app bundle identifier and App Group path.

### NE1-M-022 — Main App Launch Command Evidence

Environment: NE1-ENV-001

Status: Collected

Artifacts:

- `evidence/native-experience-001/step-3/logs/NE1-M-022-simctl-launch-main-app.stdout.txt`
- `evidence/native-experience-001/step-3/logs/NE1-M-022-simctl-launch-main-app.stderr.txt`

Evidence Metadata:

- Measurement Type: Main app launch command evidence
- Tooling: `xcrun simctl launch`
- Bundle ID: `com.DoubleShy0N.Universe-Keyboard`
- Production Code Modified: No
- Instrumentation Added: No
- Measurement Result Included: No

### NE1-M-023 — All-Processes Time Profiler Collection Attempt

Environment: NE1-ENV-001

Status: Interrupted

Artifacts:

- `evidence/native-experience-001/step-3/traces/NE1-M-023-NE1-ENV-001-all-processes-time-profiler.trace`
- `evidence/native-experience-001/step-3/logs/NE1-M-023-xctrace-all-processes.stdout.txt`
- `evidence/native-experience-001/step-3/logs/NE1-M-023-xctrace-all-processes.stderr.txt`
- `evidence/native-experience-001/step-3/raw/NE1-M-023-process-state-before-terminate.txt`

Evidence Metadata:

- Measurement Type: All-processes Time Profiler collection attempt
- Tooling: `xcrun xctrace record`, `ps`
- Template: Time Profiler
- Time Limit Requested: 5s
- Target Requested: all processes on NE1-ENV-001 simulator
- Production Code Modified: No
- Instrumentation Added: No
- Measurement Result Included: No
- Collection Status Note: Recording command exceeded the observation window and was terminated after process-state evidence was captured.

### NE1-M-024 — All-Processes Time Profiler No-Prompt Collection Attempt

Environment: NE1-ENV-001

Status: Interrupted

Artifacts:

- `evidence/native-experience-001/step-3/traces/NE1-M-024-NE1-ENV-001-all-processes-time-profiler-no-prompt.trace`
- `evidence/native-experience-001/step-3/logs/NE1-M-024-xctrace-all-processes-no-prompt.stdout.txt`
- `evidence/native-experience-001/step-3/logs/NE1-M-024-xctrace-all-processes-no-prompt.stderr.txt`
- `evidence/native-experience-001/step-3/raw/NE1-M-024-process-state-before-terminate.txt`

Evidence Metadata:

- Measurement Type: All-processes Time Profiler no-prompt collection attempt
- Tooling: `xcrun xctrace record`, `ps`
- Template: Time Profiler
- Time Limit Requested: 5s
- Target Requested: all processes on NE1-ENV-001 simulator
- Production Code Modified: No
- Instrumentation Added: No
- Measurement Result Included: No
- Collection Status Note: Recording command used `--no-prompt`, exceeded the observation window, and was terminated after process-state evidence was captured.

### NE1-M-025 — Device Hub / CoreDevice Host-Tooling Context

Environment: NE1-ENV-001

Status: Collected

Artifacts:

- `evidence/native-experience-001/step-3/diagnosis/NE1-M-025-device-hub-coredevice-context.txt`

Evidence Metadata:

- Measurement Type: Manual host-tooling context evidence
- Tooling: User-provided manual observation and external context
- Production Code Modified: No
- Instrumentation Added: No
- Measurement Result Included: No
- Collection Status Note: Manual context records Xcode 27 Device Hub/CoreDevice behavior as host-tooling context only, not product performance evidence.

### NE1-M-026 — Manual Step 3 Artifact Batch Manifest

Environment: NE1-ENV-001

Status: Collected

Artifacts:

- `evidence/native-experience-001/step-3/manual/manual-artifact-list.txt`
- `evidence/native-experience-001/step-3/manual/manual-sha256.txt`
- `evidence/native-experience-001/step-3/manual/manual-sha256-verify.txt`
- `evidence/native-experience-001/step-3/manual/manual-sha256-verify.stderr.txt`

Evidence Metadata:

- Measurement Type: Manual artifact manifest and checksum verification
- Tooling: User-provided manual collection, `shasum`
- Production Code Modified: No
- Instrumentation Added: No
- Measurement Result Included: No
- Collection Status Note: Manual SHA-256 verification passed for listed manual text artifacts.

### NE1-M-027 — Manual Simulator Install and Launch Evidence

Environment: NE1-ENV-001

Status: Collected

Artifacts:

- `evidence/native-experience-001/step-3/manual/manual-simctl-install-launch-note.txt`

Evidence Metadata:

- Measurement Type: Manual simulator install/launch command evidence
- Tooling: User-provided manual `simctl install` and `simctl launch`
- Production Code Modified: No
- Instrumentation Added: No
- Measurement Result Included: No
- Collection Status Note: Manual note records install success using the correct simulator app product and launch success with PID 8374.

### NE1-M-028 — Manual All-Processes Time Profiler Trace

Environment: NE1-ENV-001

Status: Collected

Artifacts:

- `evidence/native-experience-001/step-3/manual/manual-all-processes-time-profiler.trace`
- `evidence/native-experience-001/step-3/manual/manual-xctrace-time-profiler.log`

Evidence Metadata:

- Measurement Type: Manual all-processes Time Profiler trace artifact
- Tooling: User-provided manual `xcrun xctrace record`
- Template: Time Profiler
- Target: All Processes
- Production Code Modified: No
- Instrumentation Added: No
- Measurement Result Included: No
- Collection Status Note: Manual log records successful output save and dylib overlap timeline warnings.

### NE1-M-029 — Manual All-Processes System Trace

Environment: NE1-ENV-001

Status: Collected

Artifacts:

- `evidence/native-experience-001/step-3/manual/manual-system-trace.trace`
- `evidence/native-experience-001/step-3/manual/manual-xctrace-system-trace.log`

Evidence Metadata:

- Measurement Type: Manual all-processes System Trace artifact
- Tooling: User-provided manual `xcrun xctrace record`
- Template: System Trace
- Target: All Processes
- Production Code Modified: No
- Instrumentation Added: No
- Measurement Result Included: No
- Collection Status Note: Manual log records successful output save and dylib overlap timeline warnings.

### NE1-M-030 — Manual Allocations All-Processes Attempt

Environment: NE1-ENV-001

Status: Unsupported Target

Artifacts:

- `evidence/native-experience-001/step-3/manual/manual-allocations.trace`
- `evidence/native-experience-001/step-3/manual/manual-xctrace-allocations.log`

Evidence Metadata:

- Measurement Type: Manual Allocations all-processes attempt
- Tooling: User-provided manual `xcrun xctrace record`
- Template: Allocations
- Target: All Processes
- Production Code Modified: No
- Instrumentation Added: No
- Measurement Result Included: No
- Collection Status Note: Manual log records that Allocations cannot handle a target type of All Processes.

### NE1-M-031 — Manual Allocations Attach Attempt

Environment: NE1-ENV-001

Status: Process Target Unresolved

Artifacts:

- `evidence/native-experience-001/step-3/manual/manual-xctrace-allocations-universe.log`

Evidence Metadata:

- Measurement Type: Manual Allocations process attach attempt
- Tooling: User-provided manual `xcrun xctrace record`
- Template: Allocations
- Target: `Universe Keyboard`
- Production Code Modified: No
- Instrumentation Added: No
- Measurement Result Included: No
- Collection Status Note: Manual log records that xctrace could not find a process matching `Universe Keyboard`.

### NE1-M-032 — Non-Interactive Simulator State and App Visibility

Environment: NE1-ENV-001

Status: Collected

Artifacts:

- `evidence/native-experience-001/step-3/raw/NE1-M-032-session-start-utc.txt`
- `evidence/native-experience-001/step-3/raw/NE1-M-032-sim-state.txt`
- `evidence/native-experience-001/step-3/logs/NE1-M-032-sim-state.stderr.txt`
- `evidence/native-experience-001/step-3/raw/NE1-M-032-listapps.txt`
- `evidence/native-experience-001/step-3/logs/NE1-M-032-listapps.stderr.txt`

Evidence Metadata:

- Measurement Type: Non-interactive simulator and app visibility evidence
- Tooling: `xcrun simctl list devices`, `xcrun simctl listapps`
- Production Code Modified: No
- Instrumentation Added: No
- Measurement Result Included: No
- Collection Status Note: Simulator booted and confirmed; app bundle `com.DoubleShy0N.Universe-Keyboard` visible in installed app list.

### NE1-M-033 — Non-Interactive Main App Launch and Screenshot

Environment: NE1-ENV-001

Status: Collected

Artifacts:

- `evidence/native-experience-001/step-3/logs/NE1-M-033-main-launch.txt`
- `evidence/native-experience-001/step-3/raw/NE1-M-033-main-launch-screenshot.png`

Evidence Metadata:

- Measurement Type: Non-interactive main app launch and visual proof
- Tooling: `xcrun simctl launch`, `xcrun simctl io screenshot`
- Production Code Modified: No
- Instrumentation Added: No
- Measurement Result Included: No
- Collection Status Note: Main app launched successfully (PID recorded). Screenshot captured as visual proof.

### NE1-M-034 — XcodeBuildMCP Execution Boundary

Environment: NE1-ENV-001

Status: Requires Human Interaction (Tooling)

Artifacts:

- `evidence/native-experience-001/step-3/raw/NE1-M-034-mcp-boundary.txt`

Evidence Metadata:

- Measurement Type: Host-tooling execution boundary
- Tooling: XcodeBuildMCP MCP server
- Production Code Modified: No
- Instrumentation Added: No
- Measurement Result Included: No
- Collection Status Note: XcodeBuildMCP `session-set-defaults` is unavailable in the current execution context. `build_run_sim`, `launch_app_sim`, `screenshot`, and `get_sim_app_path` cannot be used without it.

### NE1-M-035 — Non-Interactive Collection Boundary

Environment: NE1-ENV-001 through NE1-ENV-007

Status: Requires Human Interaction

Artifacts:

- `evidence/native-experience-001/step-3/raw/NE1-M-035-human-interaction-boundary.txt`

Evidence Metadata:

- Measurement Type: Non-interactive collection boundary
- Tooling: Manual analysis of Step 3 requirements against available non-interactive tools
- Production Code Modified: No
- Instrumentation Added: No
- Measurement Result Included: No
- Collection Status Note: Keyboard Extension activation, first-key interaction, page switching, Lua validation, OpenCC validation, repeated host switching, and xctrace/Instruments recording require human interaction in the current execution context. This is a collection boundary, not a performance finding.

### NE1-M-036 — Human-Interaction Qualitative Observations

Environment: NE1-ENV-003 (Notes), NE1-ENV-002 (Safari), Third-party (WeChat)

Status: Collected (Qualitative)

Artifacts:

- `evidence/native-experience-001/step-3/raw/NE1-M-036-human-interaction-observations.txt`

Evidence Metadata:

- Measurement Type: Human-interaction qualitative observations
- Hosts: Notes, Safari, WeChat (third-party observation)
- Method: Manual keyboard interaction observed by user
- Production Code Modified: No
- Instrumentation Added: No
- Quantitative Measurement Included: No

Recorded observations:

- Notes: Keyboard activation successful. No white screen, no crash. First key latency not observed (no timing). Continuous typing smooth. Candidate updates smooth. Backspace responsive. No visible dropped frames.
- WeChat and Safari: Cold activation consistently shows staged keyboard presentation (top/bottom regions appear before center key area, approximately one second subjective, not instrumented). Automatically resolves. Warm activations smooth and do not reproduce staging.
- Keyboard reset verification: After removing and re-adding in Settings, first activation still reproduced the same staged presentation.

Collection Status Note: This is qualitative cross-host human-interaction evidence only. It does not contain quantitative duration measurements, Instruments traces, or os_log timestamps. The staged cold-presentation pattern has been observed across three hosts and after a keyboard configuration reset. It is recorded as an observation, not as a bottleneck classification or Finding.

### NE1-M-037 — Additional Human-Interaction Observations

Environment: NE1-ENV-004 (Lua trigger observation), NE1-ENV-005 (OpenCC configuration state pending verification), NE1-ENV-006 (host switching)

Status: Collected (Qualitative; configuration verification pending where noted)

Artifacts:

- `evidence/native-experience-001/step-3/raw/NE1-M-037-additional-human-interaction-observations.txt`

Evidence Metadata:

- Measurement Type: Human-interaction qualitative observations
- Method: Manual keyboard interaction observed by user
- Production Code Modified: No
- Instrumentation Added: No
- Quantitative Measurement Included: No
- Configuration Dump Included: No

Recorded observations:

- Lua: An observation was reported after entering trigger `rq`. The active configuration and trigger outcome are not independently verified in this evidence record.
- OpenCC: An OpenCC-related behavior observation was reported. It is not recorded as a functional failure. The active configuration and expected behavior require configuration verification before association with a configuration state.
- Host switching: The keyboard appeared normally across hosts. Staged presentation was observed only on initial activation. No automatic fallback to Apple Keyboard and no degradation across host switching were observed.

Collection Status Note: This is qualitative observation evidence only. It contains no configuration dump or quantitative measurement and does not infer cause, classify a bottleneck, or recommend an action.

### NE1-M-038 — Messages Baseline Manual Samples

Environment: NE1-ENV-001

Status: Collected (Qualitative; N=5 human-observation samples)

Artifacts:

- `evidence/native-experience-001/step-3/raw/NE1-M-038-messages-baseline-human-interaction-samples.txt`

Evidence Metadata:

- Measurement Type: Human-interaction qualitative observations
- Host: Messages
- Sample Count: N=5 human-observation samples
- Method: Manual keyboard interaction observed by user
- Production Code Modified: No
- Instrumentation Added: No
- Quantitative Measurement Included: No
- Trace Marker or Timestamp Included: No

Recorded observations:

- S1: Top and bottom regions appeared before the main keyboard area. User-perceived delay was less than approximately one second (subjective, not instrumented). After stable state, input `n` produced an immediate user-perceived candidate response.
- S2: Bottom region appeared before the main keyboard area. No significant user-perceived delay; input response normal.
- S3: No obvious staged presentation. Temporary candidate-bar residual observed. No user-perceived delay; input response normal.
- S4: No staged presentation or candidate residual. No user-perceived delay; input response normal.
- S5: No staged presentation or candidate residual. No user-perceived delay; input response normal.

Collection Status Note: N=5 refers only to manual qualitative samples. This record is not an instrumented latency measurement set and does not infer cause, classify a bottleneck, or recommend an action.

### NE1-M-039 — Messages Warm Activation Manual Samples

Environment: NE1-ENV-001

Status: Collected (Qualitative; N=5 human-observation samples)

Artifacts:

- `evidence/native-experience-001/step-3/raw/NE1-M-039-messages-warm-activation-human-interaction-samples.txt`

Evidence Metadata:

- Measurement Type: Human-interaction qualitative observations
- Host: Messages
- Activation State: Warm
- Sample Count: N=5 human-observation samples
- Method: Manual keyboard interaction observed by user
- Production Code Modified: No
- Instrumentation Added: No
- Quantitative Measurement Included: No
- Trace Marker or Timestamp Included: No

Recorded observations:

- All five samples: No staged presentation, no candidate-bar residual, and no user-perceived activation delay.
- All five samples: After activation, input `n` produced an immediate user-perceived candidate response; continuous interaction felt smooth.

Collection Status Note: These are qualitative human observations. N=5 does not represent an instrumented latency measurement, and this record does not infer cause, classify a bottleneck, or recommend an action.

### NE1-M-040 — Page Switching Qualitative Observation

Environment: NE1-ENV-007

Status: Collected (Qualitative)

Artifacts:

- `evidence/native-experience-001/step-3/raw/NE1-M-040-page-switching-human-interaction-observation.txt`

Evidence Metadata:

- Measurement Type: Human-interaction qualitative observation
- Method: Manual keyboard interaction observed by user
- Production Code Modified: No
- Instrumentation Added: No
- Quantitative Measurement Included: No
- Trace Marker or Timestamp Included: No
- Sample Count: Not recorded

Recorded observations:

- Keyboard page switching responded immediately in user perception; no animation stutter, temporary blank key area, or candidate-bar refresh abnormality was observed.
- Repeated page switching remained responsive.
- Uppercase/lowercase switching showed a brief visual transition, recorded only as observed transition behavior.

Collection Status Note: This is qualitative behavior evidence only. The uppercase/lowercase transition is not classified as a defect or assigned a root cause.

### NE1-M-041 — Lua Trigger Qualitative Observation

Environment: NE1-ENV-004

Status: Collected (Qualitative)

Artifacts:

- `evidence/native-experience-001/step-3/raw/NE1-M-041-lua-trigger-human-interaction-observation.txt`

Evidence Metadata:

- Measurement Type: Human-interaction qualitative observation
- Method: Manual keyboard interaction observed by user
- Production Code Modified: No
- Instrumentation Added: No
- Quantitative Measurement Included: No
- Trace Marker or Timestamp Included: No
- Sample Count: Not recorded

Recorded observations:

- Input `rq` was repeatedly tested; date-related candidates appeared consistently.
- No visible input delay or candidate-rendering abnormality was observed.

Collection Status Note: This is qualitative behavior evidence only and does not infer cause, classify a bottleneck, or recommend an action.

### NE1-M-042 — OpenCC Behavior Qualitative Observation

Environment: NE1-ENV-001 (OpenCC enabled), NE1-ENV-005 (OpenCC disabled)

Status: Collected (Qualitative; configuration verification required)

Artifacts:

- `evidence/native-experience-001/step-3/raw/NE1-M-042-opencc-behavior-human-interaction-observation.txt`

Evidence Metadata:

- Measurement Type: Human-interaction qualitative observation
- Method: Manual keyboard interaction observed by user
- Production Code Modified: No
- Instrumentation Added: No
- Quantitative Measurement Included: No
- Configuration Dump Included: No
- Trace Marker or Timestamp Included: No
- Sample Count: Not recorded

Recorded observations:

- OpenCC-enabled and OpenCC-disabled behavior were tested.
- Candidate output remained simplified Chinese in both states; no visible conversion difference was observed under the current `rime_ice` test path.

Collection Status Note: This is a behavior observation only and requires configuration verification. It is not classified as an OpenCC failure.

### NE1-M-043 — Messages Trace Pipeline Validation Sample

Environment: Out-of-matrix metadata boundary; artifact identifier includes `NE1-ENV001`, but recorded metadata does not match Step 2 NE1-ENV-001.

Status: Collected (Trace Pipeline Validation; not a cold-activation measurement)

Artifacts:

- `evidence/native-experience-001/step-3/manual/device-trace/NE1-ENV001-messages-cold-sample-001-time-profiler.trace`
- `evidence/native-experience-001/step-3/manual/device-trace/NE1-ENV001-messages-sample-001-time-profiler-bundle.sha256`
- `evidence/native-experience-001/step-3/manual/device-trace/NE1-ENV001-messages-sample-001-metadata.txt`

Evidence Metadata:

- Artifact Identifier: `NE1-ENV001-messages-sample-001`
- Host: Messages
- Recorded Device Type: Physical iPhone
- Recorded Device: DoubleShy0N iPhone
- Recorded OS: iOS 27.0
- Instrument: Time Profiler
- Target: All Processes
- Actual Activation State: Warm activation
- Production Code Modified: No
- Instrumentation Added: No
- Measurement Result Included: No

Recorded artifact boundary:

- The trace bundle exists and the collection metadata records successful trace completion and artifact save.
- The filename retains `cold-sample-001` from the initial collection command, while the metadata records the actual state as Warm activation because the keyboard was already visible before recording started.
- Step 2 defines NE1-ENV-001 as iPhone 17 Pro Simulator on iOS 26.5. The recorded physical iPhone / iOS 27.0 metadata is therefore not associated with NE1-ENV-001 baseline coverage.

Collection Status Note: This record is a trace pipeline validation sample only. It is not a cold-activation measurement, not a valid NE1-ENV-001 baseline measurement, and contains no performance finding, root-cause inference, or optimization proposal.

### NE1-M-044 — Messages Cold Activation Trace Sample

Environment: NE1-ENV-001

Status: Collected (Single raw trace sample; not validated)

Artifacts:

- `evidence/native-experience-001/step-3/manual/device-trace/NE1-ENV001-simulator26.5-messages-cold-sample-001-time-profiler.trace`
- `evidence/native-experience-001/step-3/manual/device-trace/NE1-ENV001-simulator26.5-messages-cold-sample-001-metadata.txt`
- `evidence/native-experience-001/step-3/manual/device-trace/NE1-ENV001-simulator26.5-messages-cold-sample-001-bundle.sha256`

Evidence Metadata:

- Artifact Identifier: `NE1-ENV001-simulator26.5-messages-cold-sample-001`
- Environment Cell: NE1-ENV-001
- Host: Messages
- Device: iPhone 17 Pro Simulator
- OS: iOS 26.5
- Build: Release
- Input Scheme: `rime_ice` ordinary pinyin
- OpenCC: Enabled
- Full Access: Enabled
- Instrument: Time Profiler
- Target: All Processes
- Activation State: Cold activation
- Production Code Modified: No
- Instrumentation Added: No
- Measurement Result Included: No

Recorded artifact boundary:

- The Time Profiler trace bundle, metadata file, and bundle hash manifest exist.
- The collection metadata records successful trace completion and artifact save.
- The recorded interaction sequence includes Messages with the system keyboard active, keyboard selection through the switcher, keyboard extension activation and presentation, input `n`, and observed candidate response.
- The human observation is retained as metadata boundary only: a temporary visual presentation anomaly was observed during the initial keyboard switch; the keyboard later stabilized, and no candidate-bar residue was observed.

Collection Status Note: This is one raw cold-activation trace sample. It is not validated, does not satisfy the required N=5 sample count, and contains no performance finding, root-cause inference, or bottleneck classification.

### NE1-M-045 — Messages Cold Activation System Trace Sample

Environment: NE1-ENV-001

Status: Collected (Single raw trace sample; not validated)

Artifacts:

- `evidence/native-experience-001/step-3/manual/device-trace/NE1-ENV001-simulator26.5-messages-cold-sample-001-system-trace.trace`
- `evidence/native-experience-001/step-3/manual/device-trace/NE1-ENV001-simulator26.5-messages-cold-sample-001-system-trace-metadata.txt`
- `evidence/native-experience-001/step-3/manual/device-trace/NE1-ENV001-simulator26.5-messages-cold-sample-001-system-trace-bundle.sha256`

Evidence Metadata:

- Artifact Identifier: `NE1-ENV001-simulator26.5-messages-cold-sample-001-system-trace`
- Environment Cell: NE1-ENV-001
- Host: Messages
- Device: iPhone 17 Pro Simulator
- OS: iOS 26.5
- Build: Release
- Input Scheme: `rime_ice` ordinary pinyin
- OpenCC: Enabled
- Full Access: Enabled
- Instrument: System Trace
- Target: All Processes
- Activation State: Cold activation
- Production Code Modified: No
- Instrumentation Added: No
- Measurement Result Included: No

Recorded artifact boundary:

- The System Trace bundle, metadata file, and bundle hash manifest exist.
- The collection metadata records successful trace completion and artifact save.
- The recorded interaction sequence includes Messages with the system keyboard active, keyboard selection through the switcher, keyboard extension activation and presentation, input `n`, and observed candidate response.
- The human observation is retained as metadata boundary only: a temporary visual presentation anomaly was observed during the initial keyboard switch; the keyboard later stabilized, and no candidate-bar residue was observed.

Collection Status Note: This is one raw cold-activation System Trace sample. It is not validated, does not satisfy the required N=5 sample count, and contains no performance finding, root-cause inference, or bottleneck classification.

### NE1-M-046 — Messages Cold Activation Time Profiler Sample

Environment: NE1-ENV-001

Status: Collected (Single raw trace sample; not validated)

Artifacts:

- `evidence/native-experience-001/step-3/manual/device-trace/NE1-ENV001-simulator26.5-messages-cold-sample-002-time-profiler.trace`
- `evidence/native-experience-001/step-3/manual/device-trace/NE1-ENV001-simulator26.5-messages-cold-sample-002-time-profiler-metadata.txt`
- `evidence/native-experience-001/step-3/manual/device-trace/NE1-ENV001-simulator26.5-messages-cold-sample-002-time-profiler-bundle.sha256`

Evidence Metadata:

- Artifact Identifier: `NE1-ENV001-simulator26.5-messages-cold-sample-002-time-profiler`
- Environment Cell: NE1-ENV-001
- Host: Messages
- Device: iPhone 17 Pro Simulator
- OS: iOS 26.5
- Build: Release
- Input Scheme: `rime_ice` ordinary pinyin
- OpenCC: Enabled
- Full Access: Enabled
- Instrument: Time Profiler
- Target: All Processes
- Activation State: Cold activation
- Production Code Modified: No
- Instrumentation Added: No
- Measurement Result Included: No

Recorded artifact boundary:

- The Time Profiler trace bundle, metadata file, and bundle hash manifest exist.
- The collection metadata records successful trace completion and artifact save.
- The recorded interaction sequence includes Messages with the system keyboard active, keyboard selection through the switcher, keyboard extension activation and presentation, input `n`, and observed candidate response.
- The human observation is retained as metadata boundary only: no staged presentation, candidate-bar residue, or automatic fallback to the system keyboard was observed; input response was immediate after stabilization.

Collection Status Note: This is one raw cold-activation Time Profiler sample. It is not validated, does not satisfy the required N=5 sample count, and contains no performance finding, root-cause inference, or bottleneck classification.

### NE1-M-047 — Messages Cold Activation Time Profiler Sample

Environment: NE1-ENV-001

Status: Collected (Single raw trace sample; not validated)

Artifacts:

- `evidence/native-experience-001/step-3/manual/device-trace/NE1-ENV001-simulator26.5-messages-cold-sample-003-time-profiler.trace`
- `evidence/native-experience-001/step-3/manual/device-trace/NE1-ENV001-simulator26.5-messages-cold-sample-003-time-profiler-metadata.txt`
- `evidence/native-experience-001/step-3/manual/device-trace/NE1-ENV001-simulator26.5-messages-cold-sample-003-time-profiler-bundle.sha256`

Evidence Metadata:

- Artifact Identifier: `NE1-ENV001-simulator26.5-messages-cold-sample-003-time-profiler`
- Environment Cell: NE1-ENV-001
- Host: Messages
- Device: iPhone 17 Pro Simulator
- OS: iOS 26.5
- Build: Release
- Input Scheme: `rime_ice` ordinary pinyin
- OpenCC: Enabled
- Full Access: Enabled
- Instrument: Time Profiler
- Target: All Processes
- Activation State: Cold activation
- Production Code Modified: No
- Instrumentation Added: No
- Measurement Result Included: No

Recorded artifact boundary:

- The Time Profiler trace bundle, metadata file, and bundle hash manifest exist.
- The collection metadata records successful trace completion and artifact save.
- The recorded interaction sequence includes Messages with the system keyboard active, keyboard selection through the switcher, keyboard extension activation and presentation, input `n`, and observed candidate response.
- The human observation is retained as metadata boundary only: no staged presentation, candidate-bar residue, or automatic fallback to the system keyboard was observed; input response was immediate.

Collection Status Note: This is one raw cold-activation Time Profiler sample. It is not validated, does not satisfy the required N=5 sample count, and contains no performance finding, root-cause inference, or bottleneck classification.

### NE1-M-048 — Messages Cold Activation Time Profiler Sample

Environment: NE1-ENV-001

Status: Collected (Single raw trace sample; not validated)

Artifacts:

- `evidence/native-experience-001/step-3/manual/device-trace/NE1-ENV001-simulator26.5-messages-cold-sample-004-time-profiler.trace`
- `evidence/native-experience-001/step-3/manual/device-trace/NE1-ENV001-simulator26.5-messages-cold-sample-004-time-profiler-metadata.txt`
- `evidence/native-experience-001/step-3/manual/device-trace/NE1-ENV001-simulator26.5-messages-cold-sample-004-time-profiler-bundle.sha256`

Evidence Metadata:

- Artifact Identifier: `NE1-ENV001-simulator26.5-messages-cold-sample-004-time-profiler`
- Environment Cell: NE1-ENV-001
- Host: Messages
- Device: iPhone 17 Pro Simulator
- OS: iOS 26.5
- Build: Release
- Input Scheme: `rime_ice` ordinary pinyin
- OpenCC: Enabled
- Full Access: Enabled
- Instrument: Time Profiler
- Target: All Processes
- Activation State: Cold activation
- Production Code Modified: No
- Instrumentation Added: No
- Measurement Result Included: No

Recorded artifact boundary:

- The Time Profiler trace bundle, metadata file, and bundle hash manifest exist.
- The collection metadata records successful trace completion and artifact save.
- The recorded interaction sequence includes Messages with the system keyboard active, keyboard selection through the switcher, keyboard extension activation and presentation, input `n`, and observed candidate response.
- The human observation is retained as metadata boundary only: no staged presentation, candidate-bar residue, or automatic fallback to the system keyboard was observed; input response was immediate.

Collection Status Note: This is one raw cold-activation Time Profiler sample. It is not validated, does not satisfy the required N=5 sample count, and contains no performance finding, root-cause inference, or bottleneck classification.

### NE1-M-049 — Messages Cold Activation Time Profiler Sample

Environment: NE1-ENV-001

Status: Collected (Single raw trace sample; not validated)

Artifacts:

- `evidence/native-experience-001/step-3/manual/device-trace/NE1-ENV001-simulator26.5-messages-cold-sample-005-time-profiler.trace`
- `evidence/native-experience-001/step-3/manual/device-trace/NE1-ENV001-simulator26.5-messages-cold-sample-005-time-profiler-metadata.txt`
- `evidence/native-experience-001/step-3/manual/device-trace/NE1-ENV001-simulator26.5-messages-cold-sample-005-time-profiler-bundle.sha256`

Evidence Metadata:

- Artifact Identifier: `NE1-ENV001-simulator26.5-messages-cold-sample-005-time-profiler`
- Environment Cell: NE1-ENV-001
- Host: Messages
- Device: iPhone 17 Pro Simulator
- OS: iOS 26.5
- Build: Release
- Input Scheme: `rime_ice` ordinary pinyin
- OpenCC: Enabled
- Full Access: Enabled
- Instrument: Time Profiler
- Target: All Processes
- Activation State: Cold activation
- Production Code Modified: No
- Instrumentation Added: No
- Measurement Result Included: No

Recorded artifact boundary:

- The Time Profiler trace bundle, metadata file, and bundle hash manifest exist.
- The collection metadata records successful trace completion and artifact save.
- The recorded interaction sequence includes Messages with the system keyboard active, keyboard selection through the switcher, keyboard extension activation and presentation, input `n`, and observed candidate response.
- The human observation is retained as metadata boundary only: no staged presentation, candidate-bar residue, or automatic fallback to the system keyboard was observed; input response was immediate.

Collection Status Note: This is one raw cold-activation Time Profiler sample. It is not validated, does not satisfy the required N=5 sample count as an individual record, and contains no performance finding, root-cause inference, or bottleneck classification.

### NE1-M-050 — Messages Cold Activation System Trace Sample

Environment: NE1-ENV-001

Status: Collected (Single raw trace sample; not validated)

Artifacts:

- `evidence/native-experience-001/step-3/manual/device-trace/NE1-ENV001-simulator26.5-messages-cold-sample-002-system-trace.trace`
- `evidence/native-experience-001/step-3/manual/device-trace/NE1-ENV001-simulator26.5-messages-cold-sample-002-system-trace-metadata.txt`
- `evidence/native-experience-001/step-3/manual/device-trace/NE1-ENV001-simulator26.5-messages-cold-sample-002-system-trace-bundle.sha256`

Evidence Metadata:

- Artifact Identifier: `NE1-ENV001-simulator26.5-messages-cold-sample-002-system-trace`
- Environment Cell: NE1-ENV-001
- Host: Messages
- Device: iPhone 17 Pro Simulator
- OS: iOS 26.5
- Build: Release
- Input Scheme: `rime_ice` ordinary pinyin
- OpenCC: Enabled
- Full Access: Enabled
- Instrument: System Trace
- Target: All Processes
- Activation State: Cold activation
- Production Code Modified: No
- Instrumentation Added: No
- Measurement Result Included: No

Recorded artifact boundary:

- The System Trace bundle, metadata file, and bundle hash manifest exist.
- The collection metadata records successful trace completion and artifact save.
- The recorded interaction sequence includes Messages with the system keyboard active, keyboard selection through the switcher, keyboard extension activation and presentation, input `n`, and observed candidate response.
- The human observation is retained as metadata boundary only: no staged presentation, candidate-bar residue, or automatic fallback to the system keyboard was observed; input response was immediate.

Collection Status Note: This is one raw cold-activation System Trace sample. It is not validated, does not satisfy the required N=5 sample count as an individual record, and contains no performance finding, root-cause inference, or bottleneck classification.

### NE1-M-051 — Messages Cold Activation System Trace Sample

Environment: NE1-ENV-001

Status: Collected (Single raw trace sample; not validated)

Artifacts:

- `evidence/native-experience-001/step-3/manual/device-trace/NE1-ENV001-simulator26.5-messages-cold-sample-003-system-trace.trace`
- `evidence/native-experience-001/step-3/manual/device-trace/NE1-ENV001-simulator26.5-messages-cold-sample-003-system-trace-metadata.txt`
- `evidence/native-experience-001/step-3/manual/device-trace/NE1-ENV001-simulator26.5-messages-cold-sample-003-system-trace-bundle.sha256`

Evidence Metadata:

- Artifact Identifier: `NE1-ENV001-simulator26.5-messages-cold-sample-003-system-trace`
- Environment Cell: NE1-ENV-001
- Host: Messages
- Device: iPhone 17 Pro Simulator
- OS: iOS 26.5
- Build: Release
- Input Scheme: `rime_ice` ordinary pinyin
- OpenCC: Enabled
- Full Access: Enabled
- Instrument: System Trace
- Target: All Processes
- Activation State: Cold activation
- Production Code Modified: No
- Instrumentation Added: No
- Measurement Result Included: No

Recorded artifact boundary:

- The System Trace bundle, metadata file, and bundle hash manifest exist.
- The collection metadata records successful trace completion and artifact save.
- The recorded interaction sequence includes Messages with the system keyboard active, keyboard selection through the switcher, keyboard extension activation and presentation, input `n`, and observed candidate response.
- The human observation is retained as metadata boundary only: no staged presentation, candidate-bar residue, or automatic fallback to the system keyboard was observed; input response was immediate.

Collection Status Note: This is one raw cold-activation System Trace sample. It is not validated, does not satisfy the required N=5 sample count as an individual record, and contains no performance finding, root-cause inference, or bottleneck classification.

### NE1-M-052 — Messages Cold Activation System Trace Sample

Environment: NE1-ENV-001

Status: Collected (Single raw trace sample; not validated)

Artifacts:

- `evidence/native-experience-001/step-3/manual/device-trace/NE1-ENV001-simulator26.5-messages-cold-sample-004-system-trace.trace`
- `evidence/native-experience-001/step-3/manual/device-trace/NE1-ENV001-simulator26.5-messages-cold-sample-004-system-trace-metadata.txt`
- `evidence/native-experience-001/step-3/manual/device-trace/NE1-ENV001-simulator26.5-messages-cold-sample-004-system-trace-bundle.sha256`

Evidence Metadata:

- Artifact Identifier: `NE1-ENV001-simulator26.5-messages-cold-sample-004-system-trace`
- Environment Cell: NE1-ENV-001
- Host: Messages
- Device: iPhone 17 Pro Simulator
- OS: iOS 26.5
- Build: Release
- Input Scheme: `rime_ice` ordinary pinyin
- OpenCC: Enabled
- Full Access: Enabled
- Instrument: System Trace
- Target: All Processes
- Activation State: Cold activation
- Production Code Modified: No
- Instrumentation Added: No
- Measurement Result Included: No

Recorded artifact boundary:

- The System Trace bundle, metadata file, and bundle hash manifest exist.
- The collection metadata records successful trace completion and artifact save.
- The recorded interaction sequence includes Messages with the system keyboard active, keyboard selection through the switcher, keyboard extension activation and presentation, input `n`, and observed candidate response.
- The human observation is retained as metadata boundary only: no staged presentation, candidate-bar residue, or automatic fallback to the system keyboard was observed; input response was immediate.

Collection Status Note: This is one raw cold-activation System Trace sample. It is not validated, does not satisfy the required N=5 sample count as an individual record, and contains no performance finding, root-cause inference, or bottleneck classification.

### NE1-M-053 — Messages Cold Activation System Trace Sample

Environment: NE1-ENV-001

Status: Collected (Single raw trace sample; not validated)

Artifacts:

- `evidence/native-experience-001/step-3/manual/device-trace/NE1-ENV001-simulator26.5-messages-cold-sample-005-system-trace.trace`
- `evidence/native-experience-001/step-3/manual/device-trace/NE1-ENV001-simulator26.5-messages-cold-sample-005-system-trace-metadata.txt`
- `evidence/native-experience-001/step-3/manual/device-trace/NE1-ENV001-simulator26.5-messages-cold-sample-005-system-trace-bundle.sha256`

Evidence Metadata:

- Artifact Identifier: `NE1-ENV001-simulator26.5-messages-cold-sample-005-system-trace`
- Environment Cell: NE1-ENV-001
- Host: Messages
- Device: iPhone 17 Pro Simulator
- OS: iOS 26.5
- Build: Release
- Input Scheme: `rime_ice` ordinary pinyin
- OpenCC: Enabled
- Full Access: Enabled
- Instrument: System Trace
- Target: All Processes
- Activation State: Cold activation
- Production Code Modified: No
- Instrumentation Added: No
- Measurement Result Included: No

Recorded artifact boundary:

- The System Trace bundle, metadata file, and bundle hash manifest exist.
- The collection metadata records successful trace completion and artifact save.
- The recorded interaction sequence includes Messages with the system keyboard active, keyboard selection through the switcher, keyboard extension activation and presentation, input `n`, and observed candidate response.
- The human observation is retained as metadata boundary only: no staged presentation, candidate-bar residue, or automatic fallback to the system keyboard was observed; input response was immediate.

Collection Status Note: This is one raw cold-activation System Trace sample. It is not validated, does not satisfy the required N=5 sample count as an individual record, and contains no performance finding, root-cause inference, or bottleneck classification.

## Evidence Index

| Evidence ID | Measurement | Environment | Status | Artifact Reference |
|---|---|---|---|---|
| NE1-S3-E001 | NE1-M-001 | NE1-ENV-001 | Collected | Repository/toolchain metadata files |
| NE1-S3-E002 | NE1-M-002 | NE1-ENV-001 | Collected | Simulator/xctrace metadata files |
| NE1-S3-E003 | NE1-M-003 | NE1-ENV-001 | Collected | Release build logs and app bundle |
| NE1-S3-E004 | NE1-M-004 | NE1-ENV-001 | Collected | Simulator boot/install logs |
| NE1-S3-E005 | NE1-M-005 | NE1-ENV-001 | Interrupted | Time Profiler trace attempt and logs |
| NE1-S3-E006 | NE1-M-006 | NE1-ENV-001 | Interrupted | Main app launch attempt logs |
| NE1-S3-E007 | NE1-M-007 | NE1-ENV-001 | Interrupted | App container query attempt logs |
| NE1-S3-E008 | NE1-M-008 | NE1-ENV-001 | Collected | Artifact path and SHA-256 manifests |
| NE1-S3-E009 | NE1-M-009 | NE1-ENV-001 | Collected | Execution environment revalidation metadata |
| NE1-S3-E010 | NE1-M-010 | NE1-ENV-001 | Interrupted | Simulator install revalidation attempt |
| NE1-S3-E011 | NE1-M-011 | NE1-ENV-001 | Interrupted | Simulator app visibility query attempt |
| NE1-S3-E012 | NE1-M-012 | NE1-ENV-001 | Interrupted | All-processes Time Profiler revalidation attempt |
| NE1-S3-E018 | NE1-M-018 | NE1-ENV-001 | Collected | Manual command-path smoke evidence |
| NE1-S3-E019 | NE1-M-019 | NE1-ENV-001 | Collected | App product path and pre-install simulator state |
| NE1-S3-E020 | NE1-M-020 | NE1-ENV-001 | Collected | Simulator boot and correct product install evidence |
| NE1-S3-E021 | NE1-M-021 | NE1-ENV-001 | Collected | Installed app visibility evidence |
| NE1-S3-E022 | NE1-M-022 | NE1-ENV-001 | Collected | Main app launch command evidence |
| NE1-S3-E023 | NE1-M-023 | NE1-ENV-001 | Interrupted | All-processes Time Profiler collection attempt |
| NE1-S3-E024 | NE1-M-024 | NE1-ENV-001 | Interrupted | All-processes Time Profiler no-prompt collection attempt |
| NE1-S3-E025 | NE1-M-025 | NE1-ENV-001 | Collected | Device Hub / CoreDevice host-tooling context |
| NE1-S3-E026 | NE1-M-026 | NE1-ENV-001 | Collected | Manual artifact manifest and checksum verification |
| NE1-S3-E027 | NE1-M-027 | NE1-ENV-001 | Collected | Manual simulator install and launch evidence |
| NE1-S3-E028 | NE1-M-028 | NE1-ENV-001 | Collected | Manual all-processes Time Profiler trace |
| NE1-S3-E029 | NE1-M-029 | NE1-ENV-001 | Collected | Manual all-processes System Trace |
| NE1-S3-E030 | NE1-M-030 | NE1-ENV-001 | Unsupported Target | Manual Allocations all-processes attempt |
| NE1-S3-E031 | NE1-M-031 | NE1-ENV-001 | Process Target Unresolved | Manual Allocations attach attempt |
| NE1-S3-E032 | NE1-M-032 | NE1-ENV-001 | Collected | Simulator state and app visibility |
| NE1-S3-E033 | NE1-M-033 | NE1-ENV-001 | Collected | Main app launch and screenshot |
| NE1-S3-E034 | NE1-M-034 | NE1-ENV-001 | Requires Human Interaction (Tooling) | XcodeBuildMCP execution boundary |
| NE1-S3-E035 | NE1-M-035 | NE1-ENV-001 through NE1-ENV-007 | Requires Human Interaction | Non-interactive collection boundary |
| NE1-S3-E036 | NE1-M-036 | NE1-ENV-001/002/003 | Collected (Qualitative) | Human-interaction observations: Notes, Safari, WeChat |
| NE1-S3-E037 | NE1-M-037 | NE1-ENV-004/005/006 | Collected (Qualitative; configuration verification pending where noted) | Additional human-interaction observations: Lua, OpenCC, host switching |
| NE1-S3-E038 | NE1-M-038 | NE1-ENV-001 | Collected (Qualitative; N=5 human-observation samples) | Messages baseline manual samples |
| NE1-S3-E039 | NE1-M-039 | NE1-ENV-001 | Collected (Qualitative; N=5 human-observation samples) | Messages warm activation manual samples |
| NE1-S3-E040 | NE1-M-040 | NE1-ENV-007 | Collected (Qualitative) | Page switching human-interaction observation |
| NE1-S3-E041 | NE1-M-041 | NE1-ENV-004 | Collected (Qualitative) | Lua trigger human-interaction observation |
| NE1-S3-E042 | NE1-M-042 | NE1-ENV-001/005 | Collected (Qualitative; configuration verification required) | OpenCC behavior human-interaction observation |
| NE1-S3-E043 | NE1-M-043 | Out-of-matrix metadata boundary | Collected (Trace Pipeline Validation) | Messages Time Profiler trace; actual metadata is physical iPhone / iOS 27.0 / warm activation |
| NE1-S3-E044 | NE1-M-044 | NE1-ENV-001 | Collected (Single raw trace sample; not validated) | Messages cold activation Time Profiler trace, Simulator iOS 26.5 |
| NE1-S3-E045 | NE1-M-045 | NE1-ENV-001 | Collected (Single raw trace sample; not validated) | Messages cold activation System Trace, Simulator iOS 26.5 |
| NE1-S3-E046 | NE1-M-046 | NE1-ENV-001 | Collected (Single raw trace sample; not validated) | Messages cold activation Time Profiler sample 002, Simulator iOS 26.5 |
| NE1-S3-E047 | NE1-M-047 | NE1-ENV-001 | Collected (Single raw trace sample; not validated) | Messages cold activation Time Profiler sample 003, Simulator iOS 26.5 |
| NE1-S3-E048 | NE1-M-048 | NE1-ENV-001 | Collected (Single raw trace sample; not validated) | Messages cold activation Time Profiler sample 004, Simulator iOS 26.5 |
| NE1-S3-E049 | NE1-M-049 | NE1-ENV-001 | Collected (Single raw trace sample; not validated) | Messages cold activation Time Profiler sample 005, Simulator iOS 26.5 |
| NE1-S3-E050 | NE1-M-050 | NE1-ENV-001 | Collected (Single raw trace sample; not validated) | Messages cold activation System Trace sample 002, Simulator iOS 26.5 |
| NE1-S3-E051 | NE1-M-051 | NE1-ENV-001 | Collected (Single raw trace sample; not validated) | Messages cold activation System Trace sample 003, Simulator iOS 26.5 |
| NE1-S3-E052 | NE1-M-052 | NE1-ENV-001 | Collected (Single raw trace sample; not validated) | Messages cold activation System Trace sample 004, Simulator iOS 26.5 |
| NE1-S3-E053 | NE1-M-053 | NE1-ENV-001 | Collected (Single raw trace sample; not validated) | Messages cold activation System Trace sample 005, Simulator iOS 26.5 |

## Uncollected Included Environments

The following table records current evidence coverage and remaining measurement
gaps for Step 2 `Included` environments:

| Environment ID | Step 2 Status | Step 3 Artifact Status |
|---|---|---|
| NE1-ENV-002 | Included | Qualitative observations collected (NE1-M-036); quantitative measurement not collected |
| NE1-ENV-003 | Included | Qualitative observations collected (NE1-M-036); quantitative measurement not collected |
| NE1-ENV-004 | Included | Qualitative Lua observations collected (NE1-M-037, NE1-M-041); active configuration remains independently unverified |
| NE1-ENV-005 | Included | Qualitative OpenCC observations collected (NE1-M-037, NE1-M-042); configuration state and expected behavior require verification |
| NE1-ENV-006 | Included | Qualitative host-switching observations collected (NE1-M-037); quantitative measurement not collected |
| NE1-ENV-007 | Included | Qualitative page-switching observation collected (NE1-M-040); quantitative measurement not collected |

This section records collection state only. It does not interpret cause,
classify a bottleneck, or propose an action.

## Governance Self-Review

| Check | Result | Evidence |
|---|---|---|
| Step 3 collected evidence only. | Pass | This record contains measurement metadata, artifact paths, statuses, and checksums only. |
| Step 3 avoided interpretation and bottleneck classification. | Pass | No finding, classification, bottleneck statement, or optimization opportunity is recorded. |
| Step 3 avoided implementation changes and instrumentation. | Pass | No production code was modified and no instrumentation was added. |
| Step 3 created no follow-up Work Item. | Pass | The record contains no Work Item creation or recommendation. |
| Every collected artifact traces to Step 2 Environment Matrix. | Pass | Collected artifacts are bound to NE1-ENV-001 through NE1-ENV-007, or explicitly recorded as third-party observation where Step 2 deferred that host choice. |
| Step 3 fully collected all Included Step 2 environments. | Not Pass | Only qualitative observations exist for NE1-ENV-002 through NE1-ENV-007; required quantitative evidence remains outstanding. |

## Closing Decision

Product Lead accepted Step 3 as a partial evidence collection on 2026-07-11
and authorized entry into Step 4 — Evidence Validation using only the raw
Measurements already recorded here.

This acceptance does not convert missing, interrupted, qualitative, or
single-sample Measurements into validated Evidence. In particular:

- the current macOS 27 beta / Xcode Simulator `xctrace` CLI boundary is a
  host-tooling limitation and is not a Universe Keyboard product failure;
- quantitative gaps for Included environments remain explicit;
- every Step 4 validation must still enforce readable trace artifacts,
  complete metadata, environment identity, and the protocol minimum `N >= 5`;
- unsupported or incomplete inputs must be flagged rather than used for
  performance conclusions.

The Simulator `xctrace` CLI smoke probe will be retried when a subsequent
macOS 27 beta or Xcode 27 beta becomes available. That retry is a deferred
tooling revalidation trigger and does not block Step 4 validation of currently
eligible Measurements.

No Protocol Revision is created by this partial closure. Step 4 proceeds under
the frozen protocol without changing its evidence requirements.
