# Assignment: T9-AUTO-ANCHOR-001-S6A — 真机 Release-like 配对预检

**Policy version:** `1.0.0`
**Lifecycle status:** `Active — Pre-installation Gate Pass; physical A/B evidence in progress`
**Parent:** [`T9-AUTO-ANCHOR-001`](t9-auto-anchor-001.md)

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human Product Owner explicitly replied
  “授权S6-A 真机预检” in the active Codex task on
  `2026-07-28 Asia/Shanghai`.
- **Product Approver:** Human Product Owner acting as Product Lead
- **Product Decision:**
  [`PD-T9-AUTO-ANCHOR-001`](../product-decisions/T9-AUTO-ANCHOR-001-authorization.md)

## Boundary

- **Scope:**
  - Add two source-visible but project-default-absent compilation conditions:
    `T9_AUTO_ANCHOR_DEVICE_PREFLIGHT` enables the same minimum content-free
    measurement surface in both arms;
    `T9_AUTO_ANCHOR_DEVICE_PREFLIGHT_ENABLED` additionally enables the existing
    capped-two-syllable gate in B only.
  - Build A from the same source checkpoint with Release optimization, the
    common measurement condition and the auto-anchor gate off.
  - Build B from the same source checkpoint and Release optimization with both
    conditions; the enabled condition is the only declared A/B difference.
  - Install the two internal variants alternately on the connected physical
    iPhone 13 Pro, drive the visible T9 letter-group keys in a Human-created
    disposable Reminders list and collect five valid pairs.
  - After the final B arm, reinstall the ordinary same-checkpoint gate-off
    Release without uninstall/reset and verify that the device no longer runs
    a preflight-enabled binary.
  - Preserve the existing App Group/runtime/userdb state across arms. The
    harness must not select a candidate or Path and therefore must not train
    user data.
- **Non-goals:**
  - No project-default or archive-default enablement, user setting, App Store
    build, distribution, Release acceptance budget or public performance claim.
  - No second automatic attempt, runtime backoff, candidate-window scan,
    threshold change, second RIME session, schema/vendor/deployment mutation,
    production personalization or 26-key behavior change.
  - No userdb reset, app/container deletion, sync/backup access, private host
    text capture or content-bearing logs. Automation may not delete a Reminder
    or list; final deletion of the exact disposable list remains a Human
    cleanup action.
  - No Product Gate conclusion from automated evidence alone.
- **Required Inputs:**
  - S4 implementation checkpoint
    `22d34ddb612dcf50e5dc0dde569ba82c226d3731`.
  - S4 supplementary documentation checkpoint
    `6b684a3a417d5081d763e7fe1a9316990570aa2f`.
  - [`PERFORMANCE_BASELINE.md`](../PERFORMANCE_BASELINE.md),
    [`ADR 0024`](../architecture/decisions/0024-t9-auto-anchor-shadow-observation-boundary.md),
    the parent Assignment and Product Decision.
  - Connected USB device: iPhone 13 Pro (`iPhone14,2`), iOS
    `27.0 (24A5390f)`, arm64e, UDID
    `00008110-000A08440198801E`.
  - Host: Apple Reminders title field; Chinese nine-key software keyboard.

## Assignment

- **Domain Owner:** 🧠 Input Intelligence Maintainer
- **Executor:** Current Codex task
  `019f9dac-ff8d-7872-a913-d5dd3f930dc1`, limited to this Assignment
- **Environment Executor:** Current Codex task for signed build, install,
  launch/log capture and automation on the named device; Human Product Owner
  remains the physical operator for unlock, trust, keyboard/Full Access
  selection and any required manual observation
- **Human Dependency:** Human Product Owner — keep the named device connected
  and unlocked, perform only requested system-setting/keyboard actions, and
  retain Product Gate judgment
- **Architecture Reviewer:** 🏛️ Architecture & Knowledge Steward
- **Quality Reviewer:** 🧪 Quality, Performance & Release Maintainer

### Executor acknowledgement

The current Codex task accepts the bounded Executor and Environment Executor
roles. It will not treat device availability as Product acceptance, widen the
one-attempt transaction, erase device state or publish an internal preflight
build.

## Independent Entry Review

- Architecture initial review found two P1 and two P2 contract defects:
  mandatory post-B device restore was missing; fixture identity conflicted with
  the privacy Stop Condition; post-implementation checks caused a Ready
  lifecycle cycle; and Reminders cleanup lacked an exact safe target.
- Quality initial review found two P1 and one P2: device restore was missing;
  environment validity was not rechecked per arm; and runtime fixture identity
  conflicted with the content-free contract. Its final clarification also
  separated stable session identity/validity from the expected
  `empty → active(38 actions)` composition transition and defined power as
  discrete source/charging/Low Power Mode state.
- All findings were remediated in this Assignment, Product Decision and ADR.
  Independent re-review returned:
  - **Architecture Entry:** `Pass`, P0–P3 none.
  - **Quality Entry:** `Pass`, P0–P3 none.
- These verdicts authorize `Ready` and local implementation only. They do not
  pass the Pre-installation Gate, device evidence, Exit review or Product Gate.

## Gates

### Entry Criteria

- This Assignment contains no `UNKNOWN`.
- Product authorization, device fingerprint and prior immutable checkpoints
  are recorded.
- Architecture accepts that both preflight conditions are absent from normal
  project/archive defaults and cannot become hidden shipping enablement.
- Quality accepts the Run Header, privacy contract, arm comparability,
  invalidation rules and evidence-retention method.

The Assignment may enter `Ready` only after both independent entry reviews
pass. No physical build or install may occur before then.

### Local implementation candidate evidence

Immutable implementation checkpoint
`33fc35f48161478e2f4f7c7f0b27495bfbae9b47` completed the local portion of the
Pre-installation Gate on 2026-07-28. It supersedes
`76966cbbedfe0a9f25df01a21ad2b5ce68699554` only in the UI driver: readiness
requires both the Universe-specific cross-element-type `键盘页面` identity and
all eight tappable T9 letter groups. The prior host-lifecycle remediation
remains: Reminders uses `activate()` rather than `launch()`.

- UI fixture/statistics/evidence-validator contracts: `4 / 4`;
- KeyboardCore: `751 / 751`;
- RimeBridge: `33` passed, `15` external-fixture-gated skips retained as
  non-coverage;
- strict Debug, ordinary Release, Release-like A and Release-like B Simulator
  builds: zero warnings and zero errors;
- the invalid enabled-only condition failed at compile time as required;
- ordinary Release contained no preflight marker or evidence surface; A/B
  binary inspection identified the common surface and the expected
  disabled/enabled marker respectively;
- third-round independent Architecture and Quality reviews both returned
  `Pass`, P0–P3 none.
- the one-line host-lifecycle remediation passed UI contracts `4 / 4`,
  signed Release-like A/B `build-for-testing`, and independent Architecture
  and Quality re-review with P0–P3 none.

The clean checkpoint also produced an ordinary signed device Release with
Xcode `27.0 (27A5228h)`, iPhoneOS SDK `27.0 (24A5390e)`, Team ID
`C33N6HTS9N`, App bundle `com.DoubleShy0N.Universe-Keyboard` and Extension
bundle `com.DoubleShy0N.Universe-Keyboard.Keyboard`. Its App/Extension binary
SHA256 values were respectively
`2d82d00d9608c72c8674358ff84b25e447b45b1c48d048494dbbcc6d5fec7e24`
and
`f03e39f50cf0de697a894d855fafd7c63988e6ee93e01d48689773af1011c870`.
The signed ordinary Release contained no S6-A marker.

A read-only device query confirmed the existing installation has the same App
bundle identifier and accessible App Group
`group.com.DoubleShy0N.Universe-Keyboard`. The reviewed installation command is
`devicectl device install app`, which accepts the signed `.app` and contains no
uninstall/reset/container-deletion action. This establishes the non-uninstall
installation method; no S6-A binary has yet been installed.

At 2026-07-28 20:20 Asia/Shanghai, the Human Product Owner explicitly
confirmed that an otherwise empty local Reminders list named exactly
`Universe Keyboard S6A 20260728` had been created and opened on the named
device. A subsequent read-only query confirmed the device remained paired,
wired, connected, booted, Developer Mode enabled and unlocked.

**Pre-installation Gate:** `Pass`. Installation of the first declared A arm is
authorized under this Assignment. Physical-device evidence, Exit review and
Product Gate remain open.

### Physical execution manifest

The following pre-run attempts are retained and are not valid matrix arms:

1. `pair1-A.xcresult`: build stopped before installation because the UI Test
   Runner profile did not yet exist. Xcode automatic provisioning was then
   explicitly enabled; no host action occurred.
2. `pair1-A-arm1.xcresult`: signed A installed, but the test was skipped because
   shell environment variables did not propagate into the physical-device test
   runner. Zero fixture actions occurred. Explicit environment values are now
   bound through a generated `.xctestrun`.
3. `pair1-A-arm2.xcresult`: the runner started but failed closed with
   `disposable-list-unavailable` before creating an item. The old driver had
   relaunched Reminders and discarded the Human-confirmed navigation state.
   Xcode produced a potentially content-bearing diagnostic attachment after
   failure; it was not opened, exported or copied into the repository, and the
   raw result remains isolated at its declared temporary path.
4. `pair1-A-run1.xcresult`: after the host-lifecycle remediation, exact-list
   validation passed and one empty test item was created, but automatic
   keyboard selection failed closed with `keyboard-unavailable`. Zero fixture
   actions occurred. The empty item remains for Human cleanup. Xcode again
   produced a potentially content-bearing failure diagnostic; it remains
   isolated and was not opened, exported or copied.
5. `pair1-A-run2.xcresult`: failed closed with `keyboard-unavailable` before
   the 38-action fixture began. The Human operator then clarified that the
   preceding failure flow had switched to the content-free evidence App and
   the exact Reminders list plus Universe T9 keyboard had not been manually
   restored before this retry. One empty item remains for Human cleanup; the
   raw failure result remains isolated and its diagnostic was not opened or
   copied.

Because every arm intentionally switches from Reminders to the content-free
evidence view before XCTest records a verdict, the Environment Executor must
pause before **every** subsequent arm and obtain fresh Human confirmation that
the exact list is foreground with the Universe Chinese nine-key software
keyboard visible. A prior arm's confirmation cannot be reused.

After remediation, signed A/B App binary SHA256 values are respectively
`6a2f31dfdf2198a950d35de465fd58f68f6cdb741a318098b0f1614715966178`
and
`f5389bed8bac839a59293b1ad845a2f1176c06871a97e51e73318ae3d6dd18a5`;
Extension values are
`00b051781b7c49dce5507ed173f318b1c5570908479d5cb9026a10fde7c52e80`
and
`8535366b93aad26077f97a28caeb4337238d2ab3ce94390594f1a4ce3b385b70`.
The valid five-pair matrix has not started.

### Pre-installation Gate

After `Ready`, implementation and local validation may begin. Physical install
remains prohibited until:

- an immutable implementation checkpoint is recorded;
- focused/KeyboardCore tests and strict default Debug/Release builds pass;
- default Release binary scans contain neither preflight marker;
- A/B build-setting and binary-identity inspection proves the common
  measurement condition is symmetric and only B contains the enabled
  condition;
- the mandatory content-free preflight writer is proven to bypass disabled
  user diagnostics preferences while remaining absent from ordinary Release;
- the opt-in UI driver compiles, its fixture/statistics contract tests pass,
  and its failure path switches away from Reminders before emitting an XCTest
  failure;
- signed install is proven not to require uninstalling the app or deleting its
  App Group/container;
- Human Product Owner creates and confirms an otherwise empty, disposable
  local Reminders list named `Universe Keyboard S6A 20260728`. Automation may
  create test items only inside this exact list and may not delete any item or
  list.

### Exit Criteria

- One immutable implementation checkpoint identifies all source changes.
- A and B record the same source checkpoint, Xcode, optimization level,
  signing identity, bundle identifiers, schema/runtime fingerprint and device
  state and common measurement condition; their declared difference is only
  `T9_AUTO_ANCHOR_DEVICE_PREFLIGHT_ENABLED`.
- Five valid pairs complete in the frozen order with 38 ordered actions per
  arm and content-free per-key records.
- Each arm's internal evidence view returns exactly 38 scoped `T9SEG` records
  after the latest expected marker, one `T9ARM` summary, zero commits and one
  stable valid native session; A has zero `T9AUTO` outcomes and B has exactly
  one accepted or rejected-and-restored outcome.
- Every A arm records gate off and no automatic attempt. Every B arm records
  gate on and exactly one acceptable bounded outcome; any rejected/restored
  outcome is retained and assessed rather than discarded.
- No arm produces an engine/host commit, internal digit presentation, Path
  ownership, candidate disappearance, session loss or Extension termination.
- Paired median, p95, worst, `≥50 ms` count and source-slot 24/32/34 values are
  reported for total/controller/RIME timing without inventing a Product SLO.
- Default Release is rebuilt after evidence collection and proves both
  preflight conditions absent and auto-anchor default off.
- That ordinary same-checkpoint default Release is reinstalled on the device
  without uninstall/reset. Installed App/Extension identity, gate-off state,
  marker absence and successful software-keyboard switching are recorded.
- Human Product Owner is asked to delete only the exact disposable list
  `Universe Keyboard S6A 20260728`; the harness never deletes Reminders state.
  The actual Human cleanup result is recorded separately from automated
  evidence.
- Architecture and Quality issue independent exit verdicts; Product Gate
  remains a separate Human Product Owner decision.

### Stop Conditions

Stop and retain the current checkpoint if:

- either preflight condition appears in `project.pbxproj`, a shared scheme,
  ordinary Release build settings or an archive/export path;
- A/B differ in source, optimization, common measurement condition,
  schema/runtime, signing/container identity or any undeclared setting other
  than `T9_AUTO_ANCHOR_DEVICE_PREFLIGHT_ENABLED`;
- enabling B requires `DEBUG`, a user preference, persistence, candidate
  selection, more than one automatic apply, runtime backoff or broader
  candidate authority;
- installation would require uninstalling the app, erasing App Group data,
  resetting userdb or changing sync/backup state;
- the device is locked/disconnected, thermal state is Serious/Critical, the
  debugger is attached during timing, or the host/keyboard/access state cannot
  be frozen;
- an arm's start/end thermal, discrete power condition, debugger, Full Access,
  host, orientation, layout, schema/runtime or session identity/validity is
  unknown or drifts. Discrete power means power source, charging state and Low
  Power Mode, not battery percentage. The expected content-free composition
  transition `empty → active(38 actions)` is not session drift;
- automation cannot tap the visible letter-group keys at the declared cadence.
  Manual typing may remain qualitative smoke evidence but cannot replace the
  paired performance matrix;
- any action starts more than `50 ms` late relative to the monotonic fixed
  `200 ms` schedule. This is a driver-validity budget, not a Product SLO; the
  invalid arm remains in the manifest and is not silently retried away;
- any arm has the wrong gate marker, non-empty startup composition, missing or
  out-of-order key records, unexpected commit, content-bearing output, fewer
  than 38 actions or an unexplained crash/termination;
- fewer than five valid pairs remain after invalid arms are retained in the
  manifest;
- evidence collection would read or persist private host text, pinyin,
  candidate text, raw T9 digits or user-dictionary entries. Runtime evidence
  may identify the repository-declared synthetic fixture only by case ID,
  SHA256, action count and cadence.
- restoring the ordinary gate-off Release fails. In that case the task becomes
  `Blocked`, the device must be reported as still containing an internal
  preflight build, and the keyboard must not be returned for ordinary use
  until the Human operator receives recovery instructions.

## Frozen S6-A Run Header Contract

Before the first arm, record:

- implementation commit, dirty-state check, Xcode/build version, SDK, Release
  optimization and code-signing identity;
- A/B build commands, compilation conditions, app/Extension binary SHA256,
  bundle identifiers, proof that both contain the measurement marker and only
  B contains the enabled-gate marker;
- device model/code, iOS build, architecture, UDID, capacity/free-space,
  connection type, discrete power condition (source/charging/Low Power Mode)
  and thermal state;
- exact disposable Reminders list identity, portrait orientation, Chinese
  nine-key layout, schema/runtime fingerprint and Full Access state;
- synthetic fixture ID `T9-LONG-38-V1`, SHA256
  `7b5075d1b2ab4df823b896e9bedf5eef0aec9e1fb4500988d0169c45ee410b98`,
  action count `38` and cadence `200 ms`; runtime logs/evidence do not repeat
  the literal spelling or digit identity;
- run order `A→B`, `B→A`, `A→B`, `B→A`, `A→B`;
- log start/end timestamps, run/pair/arm IDs and artifact locations/digests;
- exact temporary `.xcresult` location, attachment-scan result and the
  content-free subset retained after review. Raw result bundles are never
  copied into repository evidence; any content-bearing screenshot or UI
  hierarchy invalidates the arm.

Each arm must:

1. install the declared internal variant without uninstall/reset;
2. record start thermal/discrete-power/debugger/Full Access/host/orientation/
   layout/schema/runtime plus session identity/validity and invalidate any
   unknown or mismatch;
3. start with a newly created empty test item inside the exact disposable list
   and an empty composition;
4. launch without debugger attachment and confirm the expected gate marker;
5. tap only visible T9 letter-group keys at `200 ms` cadence;
6. avoid Path, candidate, space, commit and Delete during the timing arm;
7. after the 38th action, keep the extension visible for one second while the
   ordered writer drains; then switch to the internal evidence view and require
   exactly 38 ordered content-free timing records, the expected marker, zero
   commits and one stable valid native session;
8. record the same environment fields at arm end; any drift invalidates the
   arm. The session identity must remain valid with no loss/recreation; the
   expected composition transition from empty to active after 38 actions is
   recorded separately and is not drift;
9. capture a content-free functional result and leave all test-created
   Reminders state for Human cleanup.

The runner must not call `XCTFail`, `XCTAssert*` or `XCTUnwrap` while Reminders
is visible. Driver errors are retained as content-free codes, the main App's
internal evidence surface first replaces Reminders, and only then may XCTest
record a failure. Each raw `.xcresult` remains in its exact temporary arm
directory until attachment inspection; only content-free console/manifest
output and digests are retained in the repository.

Invalid arms remain listed with a reason and are never silently retried into a
Pass.

## Handoff

- **Handoff Target:** Architecture and Quality for entry/exit review; Human
  Product Owner for manual experience judgment and any later Product Gate
- **Required Handoff Content:** immutable commit, A/B build identities, device
  Run Header, valid/invalid manifest, timing distributions, functional
  outcomes, cleanup proof, default-Release negative scan and all limitations
- **Revalidation Trigger:** source/build-setting, Xcode/SDK, signing identity,
  device/OS, schema/runtime, Full Access, host/cadence, instrumentation,
  privacy boundary or matrix-order change
