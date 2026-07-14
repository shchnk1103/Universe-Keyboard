# NATIVE-EXPERIENCE-001 — Step 3 Interruption Diagnosis

Status: Evidence Recorded

Record Date: 2026-07-09

Parent Step:
`docs/plans/native-experience-001-step-3-evidence-collection.md`

Protocol:
`docs/plans/native-experience-001-investigation-protocol.md`

Step 1 Source of Truth:
`docs/plans/native-experience-001-step-1-observability-assessment.md`

Step 2 Source of Truth:
`docs/plans/native-experience-001-step-2-environment-selection.md`

## Scope Boundary

This diagnosis records interruption evidence for the current Step 3 simulator
path only.

It does not modify Step 1, Step 2, or the Protocol. It does not create a
Revision. It does not enter Step 4. It does not collect performance
measurements, classify bottlenecks, propose optimizations, or create Work
Items.

Existing interrupted measurements remain `Interrupted`.

## Diagnosis Question

Determine which command or operation is interrupting in the current simulator
path, and whether the interruption appears at:

- simulator install;
- app launch / visibility query;
- xctrace record;
- Codex sandbox/runtime timeout;
- Xcode command-line tool mismatch;
- simulator state;
- another host tooling issue.

## Diagnosis Evidence

### NE1-M-013 — Command-Line Toolchain Identity

Status: Collected

Artifacts:

- `evidence/native-experience-001/step-3/diagnosis/NE1-M-013-diagnosis-start-utc.txt`
- `evidence/native-experience-001/step-3/diagnosis/NE1-M-013-xcode-select-path.txt`
- `evidence/native-experience-001/step-3/diagnosis/NE1-M-013-xcode-select-path.stderr.txt`
- `evidence/native-experience-001/step-3/diagnosis/NE1-M-013-developer-dir.txt`
- `evidence/native-experience-001/step-3/diagnosis/NE1-M-013-developer-dir.stderr.txt`
- `evidence/native-experience-001/step-3/diagnosis/NE1-M-013-xcrun-find-simctl.txt`
- `evidence/native-experience-001/step-3/diagnosis/NE1-M-013-xcrun-find-simctl.stderr.txt`
- `evidence/native-experience-001/step-3/diagnosis/NE1-M-013-xcrun-find-xctrace.txt`
- `evidence/native-experience-001/step-3/diagnosis/NE1-M-013-xcrun-find-xctrace.stderr.txt`

Recorded State:

- `xcode-select -p`: `/Applications/Xcode-beta.app/Contents/Developer`
- `xcrun --find simctl`: `/Applications/Xcode-beta.app/Contents/Developer/usr/bin/simctl`
- `xcrun --find xctrace`: `/Applications/Xcode-beta.app/Contents/Developer/usr/bin/xctrace`
- `DEVELOPER_DIR`: not set in the command environment

### NE1-M-014 — Simulator State and Minimal Command Channel

Status: Collected

Artifacts:

- `evidence/native-experience-001/step-3/diagnosis/NE1-M-014-simctl-device-state.txt`
- `evidence/native-experience-001/step-3/diagnosis/NE1-M-014-simctl-device-state.stderr.txt`
- `evidence/native-experience-001/step-3/diagnosis/NE1-M-014-simctl-bootstatus.txt`
- `evidence/native-experience-001/step-3/diagnosis/NE1-M-014-simctl-bootstatus.stderr.txt`
- `evidence/native-experience-001/step-3/diagnosis/NE1-M-014-simctl-spawn-echo.txt`
- `evidence/native-experience-001/step-3/diagnosis/NE1-M-014-simctl-spawn-echo.stderr.txt`

Recorded State:

- `simctl list devices` for the target simulator returned successfully.
- `simctl bootstatus` for the target simulator returned successfully.
- `simctl spawn ... /bin/echo simctl-spawn-ok` returned successfully.

### NE1-M-015 — Bounded Simulator Install Smoke

Status: Interrupted

Artifacts:

- `evidence/native-experience-001/step-3/diagnosis/NE1-M-015-simctl-install-bounded.stdout.txt`
- `evidence/native-experience-001/step-3/diagnosis/NE1-M-015-simctl-install-bounded.stderr.txt`
- `evidence/native-experience-001/step-3/diagnosis/NE1-M-015-simctl-install-bounded.state.txt`
- `evidence/native-experience-001/step-3/diagnosis/NE1-M-015-simctl-install-bounded.process.txt`

Recorded State:

- Bounded command: `xcrun simctl install 900FB396-39BF-4A84-9E75-FF813C155FA7 ...`
- Boundary: 20 seconds
- State: `TIMEOUT_AFTER_SECONDS 20`
- stdout lines: 0
- stderr lines: 0

### NE1-M-016 — Bounded App Visibility Query Smoke

Status: Interrupted

Artifacts:

- `evidence/native-experience-001/step-3/diagnosis/NE1-M-016-simctl-listapps-bounded.stdout.txt`
- `evidence/native-experience-001/step-3/diagnosis/NE1-M-016-simctl-listapps-bounded.stderr.txt`
- `evidence/native-experience-001/step-3/diagnosis/NE1-M-016-simctl-listapps-bounded.state.txt`
- `evidence/native-experience-001/step-3/diagnosis/NE1-M-016-simctl-listapps-bounded.process.txt`

Recorded State:

- Bounded command: `xcrun simctl listapps 900FB396-39BF-4A84-9E75-FF813C155FA7`
- Boundary: 20 seconds
- State: `TIMEOUT_AFTER_SECONDS 20`
- stdout lines: 0
- stderr lines: 0

### NE1-M-017 — Bounded xctrace Recording Smoke

Status: Interrupted

Artifacts:

- `evidence/native-experience-001/step-3/diagnosis/NE1-M-017-xctrace-show-recording-options.txt`
- `evidence/native-experience-001/step-3/diagnosis/NE1-M-017-xctrace-show-recording-options.stderr.txt`
- `evidence/native-experience-001/step-3/diagnosis/NE1-M-017-xctrace-all-processes-bounded.stdout.txt`
- `evidence/native-experience-001/step-3/diagnosis/NE1-M-017-xctrace-all-processes-bounded.stderr.txt`
- `evidence/native-experience-001/step-3/diagnosis/NE1-M-017-xctrace-all-processes-bounded.state.txt`
- `evidence/native-experience-001/step-3/diagnosis/NE1-M-017-xctrace-all-processes-bounded.process.txt`
- `evidence/native-experience-001/step-3/traces/NE1-M-017-NE1-ENV-001-all-processes-time-profiler-bounded.trace`

Recorded State:

- `xctrace record --show-recording-options` returned successfully.
- Bounded recording command: `xcrun xctrace record --template "Time Profiler" --device 900FB396-39BF-4A84-9E75-FF813C155FA7 --all-processes --time-limit 5s ...`
- Boundary: 20 seconds
- State: `TIMEOUT_AFTER_SECONDS 20`
- stdout lines: 1
- stderr lines: 0

### NE1-M-018 — Manual Command-Path Smoke Evidence

Status: Collected

Artifacts:

- `evidence/native-experience-001/step-3/diagnosis/NE1-M-018-manual-smoke-results.txt`

Recorded State:

- User reported `DEVELOPER_DIR = /Applications/Xcode-beta.app/Contents/Developer`.
- User reported `simctl spawn` succeeded in approximately 0.5s.
- User reported `simctl listapps` succeeded in approximately 0.3s.
- User reported `simctl install` succeeded in approximately 1.3s when using the correct Debug-iphonesimulator app.
- User reported `simctl launch` succeeded in approximately 1.7s.
- User reported `xctrace record --all-processes --time-limit 5s` succeeded and saved a trace in approximately 20.9s total.
- User reported the earlier iphoneos install failure was caused by using a device build for a simulator.
- User reported the earlier xctrace failure was caused by shell line-break formatting.

### NE1-M-025 — Device Hub / CoreDevice Host-Tooling Context

Status: Collected

Artifacts:

- `evidence/native-experience-001/step-3/diagnosis/NE1-M-025-device-hub-coredevice-context.txt`

Recorded State:

- User reported that in Xcode 27, simulator/device management appears integrated into Device Hub.
- User reported that selecting the iPhone 17 simulator in Xcode and running Cmd+R opens Device Hub and completes build/run successfully.
- User reported external context that Xcode 27 appears to replace the old Devices and Simulators workflow with Device Hub.
- User reported external context that Device Hub and `devicectl` rely on CoreDeviceService.
- User requested this be recorded as host-tooling context only, not as proof of a platform bug.

### NE1-M-026 through NE1-M-031 — Manual Step 3 Evidence Batch

Status: Collected / Unsupported Target / Process Target Unresolved

Artifacts:

- `evidence/native-experience-001/step-3/manual/manual-artifact-list.txt`
- `evidence/native-experience-001/step-3/manual/manual-sha256.txt`
- `evidence/native-experience-001/step-3/manual/manual-sha256-verify.txt`
- `evidence/native-experience-001/step-3/manual/manual-simctl-install-launch-note.txt`
- `evidence/native-experience-001/step-3/manual/manual-all-processes-time-profiler.trace`
- `evidence/native-experience-001/step-3/manual/manual-xctrace-time-profiler.log`
- `evidence/native-experience-001/step-3/manual/manual-system-trace.trace`
- `evidence/native-experience-001/step-3/manual/manual-xctrace-system-trace.log`
- `evidence/native-experience-001/step-3/manual/manual-allocations.trace`
- `evidence/native-experience-001/step-3/manual/manual-xctrace-allocations.log`
- `evidence/native-experience-001/step-3/manual/manual-xctrace-allocations-universe.log`

Recorded State:

- Manual simulator install and launch succeeded using the correct simulator app product.
- Manual Time Profiler all-processes trace completed and saved output.
- Manual System Trace all-processes trace completed and saved output.
- Manual Time Profiler and System Trace logs include dylib overlap timeline warnings.
- Manual Allocations all-processes attempt recorded that Allocations cannot handle a target type of `All Processes`.
- Manual Allocations attach to `Universe Keyboard` recorded that xctrace could not find a matching process.
- Manual SHA-256 verification passed for listed manual text artifacts.

## Diagnosis Answers

### 1. Which exact command or operation is interrupting?

Recorded interruption points:

- `xcrun simctl install ...` timed out at the 20 second boundary.
- `xcrun simctl listapps ...` timed out at the 20 second boundary.
- `xcrun xctrace record --template "Time Profiler" --device ... --all-processes --time-limit 5s ...` timed out at the 20 second boundary.

Commands that completed:

- `xcode-select -p`
- `xcrun --find simctl`
- `xcrun --find xctrace`
- `xcrun simctl list devices ...`
- `xcrun simctl bootstatus ...`
- `xcrun simctl spawn ... /bin/echo ...`
- `xcrun xctrace record --template "Time Profiler" --show-recording-options`

### 2. Which cause category is supported by current evidence?

Current evidence supports a narrow statement only:

- Basic simulator command channel is operational.
- Command-line app-management operations are available on this host when the correct simulator build product and command form are used.
- xctrace template parsing is operational.
- xctrace recording is available on this host when the command is formed correctly.
- Time Profiler all-processes recording is not blocked when collected manually in Terminal.
- System Trace all-processes recording is not blocked when collected manually in Terminal.
- Allocations requires a specific attach or launch target and should not be treated as supporting `All Processes`.
- The failed `Universe Keyboard` Allocations attach is process-target discovery evidence, not product failure evidence.
- Xcode GUI build/run succeeds through Device Hub per manual observation.
- Codex execution still experiences interrupted xctrace recording.
- The likely difference is execution context, command wrapper, timeout behavior, or Device Hub/CoreDevice session state under Codex.

Current evidence does not prove:

- physical iPhone lock state as the cause;
- protocol invalidity;
- production app behavior as the cause;
- Xcode GUI build path failure.
- a platform bug.
- Time Profiler or System Trace being blocked on this host.
- simulator app-management being blocked on this host.

### 3. Does the Xcode GUI success path differ from the command-line path?

Recorded difference:

- User reports Xcode Cmd+R succeeds.
- User reports Xcode GUI execution succeeds through Device Hub.
- User manual smoke reports command-line `simctl install`, `simctl listapps`, `simctl launch`, and `xctrace record` can complete when the correct simulator app product and command form are used.
- Manual Step 3 batch reports successful all-processes Time Profiler and System Trace trace output files.
- Command-line `xcrun simctl list devices`, `bootstatus`, and `spawn /bin/echo` do complete.
- Codex command execution still has interrupted `xctrace record` attempts in NE1-M-023 and NE1-M-024.

This establishes that GUI success and command-line success must be validated
separately; current manual evidence indicates the command-line path is available
when configured correctly, while Codex execution context remains separately
observable.

### 4. Can a minimal command-line smoke test succeed outside the full Step 3 flow?

Yes, for basic simulator commands:

- `simctl list devices`
- `simctl bootstatus`
- `simctl spawn ... /bin/echo`
- `xctrace --show-recording-options`

Yes, per manual smoke evidence, for command-line app-management and recording
when using the correct simulator build product and command form:

- `simctl install`
- `simctl listapps`
- `xctrace record --all-processes`

Yes, per manual Step 3 batch evidence, for:

- `xctrace record --template "Time Profiler" --all-processes`
- `xctrace record --template "System Trace" --all-processes`

No, per manual Step 3 batch evidence, for:

- `xctrace record --template "Allocations" --all-processes`
- `xctrace record --template "Allocations" --attach "Universe Keyboard"` with the process target used in the manual attempt

Existing bounded attempts remain recorded as `Interrupted`; they are not
reclassified as `Failed`.

## Diagnosis Boundary

### 2026-07-11 Revalidation Addendum

Later revalidation on macOS 27.0 build `26A5378j` narrowed the interruption
boundary:

- Instruments GUI discovered the iPhone 17 Pro iOS 26.5 Simulator, enumerated
  its processes, and completed both process-attach and All Processes Time
  Profiler recordings with populated CPU tracks;
- Xcode 27 beta `xctrace` successfully completed a five-second All Processes
  recording against the Mac host and produced an approximately 47 MB trace;
- Xcode 27 beta Simulator CLI probes using `--all-processes`, `--attach`, and
  `--launch` did not reach recording completion;
- Xcode 26.6 Simulator CLI probes reproduced the interruption;
- after successful Instruments GUI recording, a bounded Simulator CLI probe
  remained active for 90 seconds and its trace stayed at approximately 40 KB
  with only `RunIssues.storedata` present.

This supports a Simulator-specific `xctrace` CLI / host-tooling boundary on the
current beta host. It does not support a Universe Keyboard product failure or
a general CoreDevice, Simulator process-enumeration, or Instruments GUI
failure. The exact Apple toolchain root cause remains `Unknown / Requires
Apple`.

Product Lead accepted partial Step 3 closure on 2026-07-11 and authorized
entry into Step 4 using only already collected, independently eligible raw
Measurements. Revalidation is deferred until a subsequent macOS 27 beta or
Xcode 27 beta release.

No Step 3 measurement is marked `Failed`.

No Protocol Revision is created.
