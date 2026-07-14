# NE1 UI Automation Feasibility

Lifecycle status: Active

## Purpose

This plan records the tooling foundation for `NE1-TOOLING-UIAUTO-001`.
It investigates whether XCUITest can cross the system keyboard interaction
boundary used by Native Experience Investigation Step 3:

- launch or control Messages;
- discover the system keyboard switching UI;
- select Universe Keyboard through accessible system UI;
- send automated text input after keyboard activation.

This is a tooling feasibility probe only. It does not replace current NE1
evidence collection, does not change the NE1 Protocol, does not enter Step 4,
and does not support performance conclusions.

## Iteration History

### Iteration 1 Result

The first UI automation execution produced useful tooling evidence but mixed
multiple capabilities in the same probes:

- XCUITest successfully launched Messages.
- XCUITest obtained the Messages accessibility hierarchy.
- The run failed after interacting with the Messages SearchField.
- SearchField interaction triggered transient iOS editing UI, including Paste
  and AutoFill menu items, which changed the accessibility hierarchy.
- No keyboard switcher UI was reached in the failing activation path.
- Universe Keyboard activation was not proven.

This result is recorded as a tooling boundary, not a Universe Keyboard product
failure. It shows that host-app launch and hierarchy capture are feasible, but
SearchField-driven setup is too noisy for keyboard automation feasibility.

### Iteration 2 Changes

Iteration 2 refactors the probes into independent capability boundaries:

- launch availability does not inspect fields, type text, or interact with the
  keyboard;
- accessibility snapshot collection prints `app.debugDescription` and records
  visible elements without tapping dynamic controls;
- keyboard switcher discovery no longer assumes a keyboard is visible and no
  longer treats generic `Keyboard` labels as success;
- Universe Keyboard activation records switcher availability and Universe
  selection as separate facts;
- text input records a precondition failure unless Universe Keyboard active
  state is independently observable.

The probes intentionally return after documenting a tooling limitation instead
of turning every unsupported system UI state into a product test failure.

### Iteration 2 Validation

The refactored probes were executed on an available iOS Simulator after the
Iteration 2 split. The suite completed all five tests successfully.

This result means the probes now produce clean capability boundaries. It does
not prove that system keyboard switching or Universe Keyboard activation is
automated.

Observed boundary in this run:

- Messages launch and accessibility snapshot collection completed.
- No system keyboard was visible in the initial Messages state used by the
  switcher, activation, and post-activation typing probes.
- Keyboard switcher availability was therefore recorded as an XCTest/system
  state precondition boundary.
- Universe Keyboard selection was not exercised because the switcher
  precondition was not met.
- Text input was not attempted because active Universe Keyboard state was not
  independently proven.

The snapshot logger uses `debugDescription` instead of indexed element
enumeration. This avoids turning XCTest's unstable accessibility element
indexes into false probe failures.

### Iteration 3 Result

Iteration 3 adds a realistic Messages cold-activation preparation path before
any keyboard automation:

- launch Messages and locate the deterministic conversation
  `+1 (888) 555-1212` inside `ConversationList`;
- open that conversation and locate the Messages composer only through its
  observed accessibility identifier, `messageBodyField`;
- tap the composer, then wait up to five seconds for
  `XCUIElementTypeKeyboard`;
- attach the current accessibility hierarchy, a screenshot, and preparation
  metadata on every outcome.

The preparation probe was executed on the NE1 simulator environment. It
reached the deterministic conversation, found `messageBodyField`, and tapped
it in every preparation-dependent probe. `XCUIElementTypeKeyboard` was not
observed during the bounded wait.

The actual observed boundary is therefore **C: composer tapped but system
keyboard does not appear**. This is a reproducible XCTest/system UI boundary
for the current simulator run, not a Universe Keyboard product failure. The
run did not attempt keyboard switching, Universe Keyboard selection, or text
input. It does not prove system keyboard automation success.

The earlier intermediate B boundary (the composer was initially queried as a
TextView) was resolved by the attached hierarchy: Messages exposes the
composer as a `TextField` with identifier `messageBodyField`. That correction
does not change the final C classification.

### Iteration 4 Result

Iteration 4 replaces the unreliable `XCUIApplication.keyboards` /
`XCUIElementTypeKeyboard` check with keyboard-surface evidence. The probe
waits for and inspects the explicit `q`, `w`, and `e` Key descendants using
case-insensitive matching, because the simulator may expose those labels in
either case after a keyboard transition.

The test-only `KeyboardSurfaceState` records only three facts:

- `absent`: no complete `q` / `w` / `e` key evidence exists;
- `visibleUnknownIdentity`: the keyboard surface exists but no direct active
  keyboard identity is exposed;
- `visibleWithKnownIdentity`: an exact known keyboard identity is directly
  exposed through accessibility.

Keyboard identity is never inferred from the keyboard surface, key layout, a
generic `Keyboard` label, or the keyboard switcher's value. This keeps XCTest
capability, product behavior, and future NE1 readiness separate.

The Iteration 4 simulator run established these facts:

- `q` / `w` / `e` were visible and hittable after composer activation, proving
  a keyboard surface even though the previous keyboard-element query was not a
  reliable detector.
- The explicit `下一个键盘` switcher control was exposed and long-pressable.
- `English (US)` was exposed as a selection item and its tap action completed.
- The keyboard surface remained visible and interactable after the selection,
  but XCTest exposed no direct active-keyboard identity.

Therefore deterministic keyboard state preparation is **not proven**. The
system UI selection action is feasible in this run, but it cannot establish a
known baseline without post-selection identity evidence. Universe Keyboard
activation was not inferred or tested as product behavior. Automated NE1
performance measurement remains blocked on a deterministic, independently
verifiable baseline state.

### Iteration 4 Initial-State Isolation Probe

`testInitialKeyboardStateBeforeSwitching` captures the state reached by only
the realistic Messages preparation flow: launch Messages, enter the fixed
conversation, find and tap `messageBodyField`, then observe the `q` / `w` /
`e` keyboard-surface descendants. It does not press the keyboard switcher,
select a keyboard, type text, or launch Universe Keyboard.

Run it independently from the other probes:

```bash
xcodebuild -project "Universe Keyboard.xcodeproj" \
  -scheme "UniverseKeyboardUITests" \
  -destination 'platform=iOS Simulator,id=<simulator-id>' \
  CODE_SIGNING_ALLOWED=NO SWIFT_STRICT_CONCURRENCY=complete \
  SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES \
  test -only-testing:UniverseKeyboardUITests/NativeExperienceKeyboardAutomationFeasibilityTests/testInitialKeyboardStateBeforeSwitching
```

The attachment records direct identity evidence only when accessibility exposes
it, plus switcher candidates discovered without invoking them. A standalone
`-only-testing` result rules out actions performed by earlier test methods in
that invocation. It cannot, by itself, distinguish test-runner installation
lifecycle effects from a persistent simulator input mode; that attribution
requires a separately controlled simulator reset or runner reinstall
comparison.

The isolated probe was run on the existing iPhone 17 Pro, iOS 26.5 simulator.
It passed as one selected test and recorded these observations:

- the deterministic conversation and `messageBodyField` composer were reached;
- after the composer tap, `q`, `w`, and `e` Key descendants were all visible
  and hittable, proving the keyboard system UI boundary;
- a `下一个键盘` switcher candidate was exposed with value `简体拼音`, but was
  only inspected and never invoked;
- XCTest exposed no direct active-keyboard identity.

This excludes test-method ordering as the cause of the observed initial state
for that standalone invocation. The switcher value is not identity evidence,
so the result neither proves nor disproves Universe Keyboard activation. It
also does not attribute the state to either test-runner installation lifecycle
or persistent simulator input mode; those remain separate hypotheses pending a
controlled lifecycle comparison.

### Deterministic Non-Universe Cold-Start Baseline

The initial-state investigation found that the simulator persists keyboard
selection independently from the XCTest methods. The enabled keyboard list
contained Universe Keyboard, while `com.apple.keyboard.preferences` retained
Universe Keyboard in `KeyboardsCurrentAndNext` and in language-specific
last-used mappings. This explains why a fresh test method can encounter
Universe Keyboard on its first composer activation without any switcher action
inside that method.

The shared `UniverseKeyboardUITests` scheme now runs
`UniverseKeyboardUITests/Tools/prepare_simulator_keyboard_baseline.sh` as a
Test pre-action. Before the test runner launches Messages, the script:

- preserves Universe Keyboard in the enabled keyboard list;
- sets Apple English as the current and last-used keyboard;
- maps Chinese contexts back to Apple's Simplified Pinyin keyboard instead of
  Universe Keyboard;
- places Universe Keyboard next in the current/next sequence for a later cold
  activation action;
- terminates Messages and refreshes cached keyboard services;
- reads the persisted values back and fails the test action if normalization
  was not written successfully.

`testInitialKeyboardStateBeforeSwitching` now provides an independent,
fail-closed runtime guard. A valid baseline requires a visible `q` / `w` / `e`
surface, either exact Apple system layout evidence
(`UIKeyboardLayoutStar Preview`) or exact Apple system switcher evidence
(`Next Keyboard` or `下一个键盘`), and no exact Universe Keyboard controls
(`切换键盘`, `键盘页面`, `输入语言`). The layout identifier is necessary because
iOS can expose the Apple keyboard before its switcher becomes hittable. Generic
`Keyboard` labels and key layout alone remain insufficient. If runner
installation or stale simulator state still presents Universe Keyboard first,
the test records the hierarchy and screenshot, then fails before any cold-start
or performance conclusion is allowed.

The pre-action runs once per Xcode test invocation. Any future test that
activates Universe Keyboard must therefore run as an isolated `-only-testing`
invocation, or explicitly restore the Apple baseline before another test is
allowed to claim a cold activation.

Validation snapshot (2026-07-11, Asia/Shanghai): the isolated baseline test was
run on the iPhone 17 Pro, iOS 26.5 simulator from the uncommitted tooling
worktree based on `cd31785d00dc234021f44e89b432576b01fe0825`. The selected
test passed and its attachment recorded:

- `Q` / `W` / `E` Key descendants visible and hittable;
- exact Apple system switcher label `下一个键盘` with value
  `Universe Keyboard`, showing that Universe Keyboard was next rather than the
  currently presented surface;
- no matches for the Universe Keyboard-specific controls;
- `Known non-Universe baseline: yes`.

This validates the normalization and runtime guard for that environment. It
must be revalidated after an iOS runtime change, keyboard bundle identifier
change, simulator reset, or change to the scheme pre-action.

The pre-action also verifies that the Simulator-hosted Universe Keyboard
Extension process is not resident. It terminates an exact process-path match
for `Universe Keyboard.app/PlugIns/Keyboard.appex/Keyboard`, waits for exit,
and fails closed if the process remains. This is the test-only cold lifecycle
precondition; it does not modify extension implementation or lifecycle code.

The full shared-scheme regression was also run after normalization. Messages
restored the previously open conversation during one probe, so the preparation
path now uses the stable `BackButton` identifier to return to
`ConversationList` before selecting the deterministic conversation. After that
host-state correction, the current full suite completed with eight capability
probes passed, zero failed, and the environment-gated cold measurement probe
skipped as designed. This is tooling regression evidence only; it is not
Universe Keyboard cold-start or performance evidence.

### Cold Activation and First-Input Probe

`testNE1ColdActivationAndFirstInput` is an isolated, environment-gated test.
Normal shared-scheme runs skip it so capability probes cannot accidentally
activate Universe Keyboard and contaminate later initial-state observations.
The external runner enables it with `NE1_COLD_ACTIVATION_RUN=1` after running
the same baseline preparation script.

The isolated probe performs this bounded user path:

1. launch Messages and enter the fixed conversation;
2. tap `messageBodyField` and prove the non-Universe Apple baseline;
3. long-press the exact Apple keyboard switcher;
4. select the exact `Universe Keyboard` system menu item;
5. prove activation from the product-owned `键盘页面` and `输入语言` controls;
6. tap the exact Universe Keyboard `n` Key element;
7. treat an increase in Messages candidate Cell count as first-response UI
   evidence.

The test does not use `typeText`, unstable element indexes, generic keyboard
labels, or candidate text content as proof.

The isolated UI path was executed on the iPhone 17 Pro, iOS 26.5 simulator and
passed. Its attachment recorded:

- known non-Universe baseline: yes;
- Universe Keyboard activation proven: yes;
- exact real `n` key tapped: yes;
- candidate Cell count before tap: 0;
- candidate Cell count after tap: 7;
- candidate response observed: yes.

This proves UI automation feasibility for the cold activation interaction path
on that simulator run. It does not prove timing quality, CPU behavior, RIME
correctness, candidate correctness, or physical-device behavior.

### xctrace Measurement-Runner Foundation

`UniverseKeyboardUITests/Tools/run_ne1_cold_activation_trace.sh` provides the
Terminal orchestration boundary for future NE1 collection. It:

- validates the selected booted Simulator and discovers available xctrace
  templates instead of hard-coding a temporary device name;
- performs one Release `build-for-testing` before isolated samples;
- re-establishes the Apple-English, extension-not-resident baseline before
  every sample;
- starts the XCTest path and waits for its Apple-keyboard-ready marker;
- starts an All Processes Time Profiler or System Trace recording;
- releases XCTest only after xctrace reports recording start;
- keeps XCTest alive until xctrace completes;
- writes per-run metadata and SHA-256 manifests only after both XCTest and
  xctrace succeed;
- refuses to overwrite an existing run directory.

`--time-limit`, `--samples`, `--configuration`, and the concrete Simulator UDID
remain explicit inputs because earlier manual xctrace commands varied by
environment. `--completion-timeout` is a separate host-tool bound: when
xctrace does not exit after its requested recording duration, the runner ends
the processes and records exit status `124` instead of hanging or treating the
event as a product failure.

Example readiness run, not yet an Evidence Collection command:

```bash
/bin/zsh UniverseKeyboardUITests/Tools/run_ne1_cold_activation_trace.sh \
  --instrument all \
  --simulator-id <simulator-udid> \
  --samples 5 \
  --time-limit 10s \
  --configuration Release \
  --output-root <new-artifact-directory>
```

The Time Profiler single-sample smoke reached these boundaries in the current
Codex execution context:

- baseline preparation succeeded and reported the extension non-resident;
- XCTest reached the Apple keyboard and emitted its ready marker;
- xctrace reported `Starting recording with the Time Profiler template`;
- while recording was active, XCTest selected Universe Keyboard, tapped `n`,
  and reached the candidate-response query;
- xctrace did not terminate after its requested 10-second duration.

That smoke was interrupted and is not valid measurement evidence. The partial
trace and xcresult are not eligible for NE1 Evidence or performance analysis.
This reproduces the repository's existing distinction between Terminal/manual
xctrace availability and interruption under the Codex execution context. A
System Trace smoke and the N=5 batches were intentionally not run after this
host-tool boundary. They remain blocked until the orchestration command is
revalidated from the intended Terminal/Xcode host context.

## Supported Scenarios

The new `UniverseKeyboardUITests` target contains the initial probe cases:

- `testMessagesLaunchAvailability`
- `testMessagesAccessibilitySnapshot`
- `testMessagesConversationKeyboardPreparation`
- `testInitialKeyboardStateBeforeSwitching`
- `testKeyboardSwitcherDiscovery`
- `testKeyboardStateNormalizationFeasibility`
- `testUniverseKeyboardActivationFeasibility`
- `testTextInputAfterKeyboardActivation`
- `testNE1ColdActivationAndFirstInput` (isolated and environment-gated)

Run the probes with the dedicated shared scheme:

```bash
xcodebuild -project "Universe Keyboard.xcodeproj" \
  -scheme "UniverseKeyboardUITests" \
  -destination 'platform=iOS Simulator,name=<installed device>' \
  CODE_SIGNING_ALLOWED=NO SWIFT_STRICT_CONCURRENCY=complete \
  SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES test
```

Use a concrete simulator discovered by `xcrun simctl list devices available`.
Do not copy a temporary simulator name into durable documentation or release
claims.

Each probe records an XCTest attachment with:

- test purpose;
- current application;
- app state;
- visible accessibility element snapshot;
- failure boundary;
- limitation classification.

The preparation-dependent probes additionally record:

- deterministic conversation navigation state;
- explicit composer identifier and matched element summary;
- composer tap state;
- keyboard-surface classification from `q` / `w` / `e` Key descendants;
- a full-screen screenshot at the recorded boundary.

## Known iOS Sandbox Limitations

XCUITest is allowed to launch apps by bundle identifier, but system apps and
system UI are not guaranteed to expose stable accessibility structure across
iOS versions, simulator states, accounts, or localizations.

Known boundaries for this investigation:

- Messages may not expose a usable compose or editable field in every simulator
  state.
- `XCUIApplication.keyboards` and `XCUIElementTypeKeyboard` are not reliable
  keyboard-presence detectors on the current iOS 26.5 simulator runtime. A
  keyboard surface can be visibly present and expose Key descendants while
  those queries do not provide usable evidence.
- `q` / `w` / `e` Key descendants are the current keyboard-surface indicator.
  They prove a visible surface, not the active keyboard identity.
- SearchField interaction can trigger transient iOS editing menus such as Paste
  and AutoFill; these menus are system UI state changes and should not be
  treated as Universe Keyboard failures.
- A custom keyboard must still be installed and enabled through iOS keyboard
  settings before it can appear in the keyboard switcher.
- The keyboard switcher/globe control may not be exposed as a tappable
  accessibility element.
- The long-press keyboard selection menu may appear outside the app hierarchy
  or may expose localized labels only.
- A switcher action and a baseline selection-item tap do not prove that the
  selected keyboard is active. Without direct post-selection identity evidence,
  keyboard state normalization remains unproven.
- The Apple keyboard can expose the exact `UIKeyboardLayoutStar Preview`
  accessibility identifier before the next-keyboard control is hittable. This
  is accepted only together with complete surface keys and absence of exact
  Universe Keyboard controls.
- The extension display name `Keyboard` is generic. A generic `Keyboard` or
  localized `键盘` label is not sufficient proof that Universe Keyboard was
  selected.
- Selecting an item from the system keyboard menu proves only an automation
  action. It does not prove the keyboard extension produced correct candidates.
- `typeText` completion proves only that XCUITest delivered an input command to
  the focused field. It is not evidence of candidate quality, latency, memory,
  lifecycle, RIME state, or production behavior.
- `xctrace --time-limit` completion is host-tool behavior and requires an
  independent timeout. A trace-process timeout is a tooling interruption, not
  a Universe Keyboard failure and not a valid partial measurement.

When a probe cannot progress because of one of these boundaries, it records the
limitation as an XCTest attachment and returns without reporting a Universe
Keyboard product failure. A documented tooling boundary is an acceptable probe
outcome for this target.

## Relationship With Future Measurement Runner

The future Measurement Runner may reuse this target only after the feasibility
boundary is proven on the required environment matrix.

The runner must still provide its own:

- environment selection and exact device/runtime record;
- setup verification for enabled keyboard and Full Access state;
- timing and trace collection method;
- measurement schema and artifact manifest;
- product/quality review rules.

This target is intentionally narrow. It establishes whether system interaction
can be automated or whether the limitation is reproducible enough to document
and hand off before Measurement Runner design.

The current result establishes the UI interaction path on one Simulator run.
The xctrace wrapper is a foundation only: formal N=5 collection, trace
validation, Evidence registration, performance analysis, and Step 4 remain
outside this iteration.
