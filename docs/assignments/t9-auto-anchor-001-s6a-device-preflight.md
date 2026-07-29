# Assignment: T9-AUTO-ANCHOR-001-S6A — 真机 Release-like 配对预检

**Policy version:** `1.0.0`
**Lifecycle status:** `Active — run3 invalid; matrix 0 / 5; physical retry requires fresh Human readiness`
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
  - When physical iOS does not expose the third-party keyboard accessibility
    tree, derive tap points only from a same-run, Extension-produced,
    content-free geometry record for the eight visible letter groups. Bind the
    geometry, binary marker and arm evidence to one opaque run token.
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
`6faa27727986925400ad0aa80d258bd759f6349b` completed the local portion of the
Pre-installation Gate on 2026-07-28. It supersedes
`33fc35f48161478e2f4f7c7f0b27495bfbae9b47` only in the UI driver: it resolves
one coherent accessibility owner from Reminders or SpringBoard, requires that
same owner to expose both the exact Universe identity and all eight tappable T9
letter groups, and fixes all 38 taps plus the end check to that owner.

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
6. `pair1-A-run3.xcresult`: failed closed with
   `reminder-control-unavailable` before creating the arm item or beginning the
   fixture. The Human followed an inaccurate preparation instruction to enter
   an existing empty item and expose the keyboard, which hid the list-level
   New Reminder control. No fixture action occurred; the isolated failure
   diagnostic was not opened or copied.
7. `pair1-A-run4.xcresult`: exact-list overview preparation passed and the
   Human visually confirmed that Universe Chinese nine-key appeared, but the
   host-only XCUI readiness query failed closed with `keyboard-unavailable`
   before the fixture began. One empty item remains for Human cleanup. The raw
   result remains isolated and its failure diagnostic was not opened or
   copied. The coherent-owner remediation above addresses this observed
   physical-iOS accessibility ownership boundary.
8. `pair1-A-run5.xcresult`: the coherent-owner driver still failed closed with
   `keyboard-unavailable` before the fixture began. The Human again visually
   confirmed that Universe Keyboard Chinese nine-key was present. This proves
   that the keyboard was visible while neither Reminders nor SpringBoard
   exposed its third-party controls to this XCTest process; zero fixture
   actions occurred. The raw result remains isolated and its potentially
   content-bearing failure diagnostic was not opened, exported or copied.
9. `pair1-A-coordinate-run1.xcresult`: the reviewed coordinate-driver A App was
   installed without uninstall/reset, but `UniverseKeyboardUITests-Runner`
   timed out while enabling physical-device automation mode and never
   initialized the UI test method. Zero fixture actions and zero coordinate
   taps occurred. Xcode created
   `Staging/1_Test/Diagnostics/devicectl_diagnostics.zip`, explicitly warning
   that it may contain personal/device/Apple Account information. The complete
   raw result remains isolated at
   `/private/tmp/universe-keyboard-s6a-coordinate-device-evidence/`;
   neither the diagnostic archive nor UI attachments were opened, exported or
   copied. Any retry requires a new Human readiness confirmation because the
   failed runner may have changed foreground state.
10. `pair1-A-coordinate-run2.xcresult`: physical automation initialized and
    entered the opt-in test method, then failed closed with the content-free
    code `geometry-invalid` before any coordinate fixture action. A source
    audit found that the driver queried `reminders.frame` only after launching
    the evidence App, when Reminders was no longer foreground. Device Hub
    independently showed the named iPhone connected, portrait and at the Home
    screen after test teardown; this post-test observation explains why a new
    Human readiness confirmation is required but is not treated as the arm's
    pre-switch geometry. The raw result remains isolated at
    `/private/tmp/universe-keyboard-s6a-coordinate-device-evidence/`; its
    potentially private diagnostics and UI attachments were not opened,
    exported or copied. The attempt is invalid and the matrix remains `0 / 5`.
11. `pair1-A-coordinate-run3.xcresult`: the reviewed host-frame remediation
    reached the physical test method and exact disposable list, created one
    empty item and failed closed with `geometry-unavailable` before any
    coordinate fixture action. The content-free evidence view showed the
    current envelope still in `prepared` state after failure, proving that the
    visible keyboard lifecycle had not consumed the new token. Source review
    identified that token consumption occurred only in Extension bootstrap;
    an Extension instance selected before token preparation could be reused on
    return without another bootstrap. The raw result remains isolated under
    `/private/tmp/universe-keyboard-s6a-coordinate-device-evidence/`; its
    diagnostics and UI attachments were not opened, exported or copied. The
    attempt is invalid, the matrix remains `0 / 5`, and another retry requires
    fresh Human readiness after remediation review.
12. `pair1-A-coordinate-run4.xcresult`: the reused-Extension remediation
    consumed the fresh token and produced one same-token prepared geometry
    record. Validation then failed closed with `geometry-invalid` before
    `driveFrozenFixture`; no coordinate fixture action or source-pinyin input
    occurred. The recorded screen and eight T9 slot frames were valid portrait
    screen coordinates, but `UIInputViewController.view.bounds` converted to
    the full `390 x 844` host screen (`minY = 0`) instead of the visible
    keyboard region. The raw result remains isolated under
    `/private/tmp/universe-keyboard-s6a-coordinate-device-evidence/`; its
    diagnostics, screenshots and UI hierarchy were not opened, exported or
    copied. The attempt is invalid, the matrix remains `0 / 5`, and another
    retry requires a reviewed geometry-source remediation plus fresh Human
    readiness.

The host-frame ordering remediation is immutable at
`ba98ecf73114f95436b37a1181a8386660cd6b5d` with parent
`0a0883369001ef1b8514d9309c14b4f8e9bddb76`. From a clean checkpoint,
Release-like A and B each passed the six selected content-free UI contracts.
Independent Architecture returned `Pass`, P0–P3 none. Independent Quality
found no code defect but returned `Fail` with one P2 evidence-provenance
finding because the first `6 / 6` record did not bind its build/log artifacts
to the immutable checkpoint. The tests were therefore rerun from clean
`ba98ecf`, and their exact invocations and artifacts are now recorded in the
linked evidence delta. Physical execution remains paused until both reviewers
accept that corrected evidence binding.

Quality then returned `Pass`, P0–P3 none. Architecture confirmed the
implementation and provenance boundaries but returned `Fail` with one P2
documentation-accuracy finding: the structured test result reported no
warnings, while each bound raw build log contained three
`appintentsmetadataprocessor` metadata-skipped warnings. The evidence now
records both layers explicitly and no longer claims that the raw logs are
warning-free. No implementation retest is required; physical execution remains
paused until the corrected statement is independently accepted.

The warning-accuracy remediation is immutable at
`939b0ed0e9772449c9194631b5c846b458b34fc7`. Final independent Architecture
and Quality reviews both returned `Pass`, P0–P3 none. A new signed
Release-like A1 was then built from the same code checkpoint, but the
read-only device precheck reported `localNetwork` transport and
`passcodeRequired=true`. Under the frozen Stop Conditions it was not installed
or launched. Its identities and the held environment state are recorded in the
linked evidence; physical execution awaits a new wired, unlocked Human
readiness confirmation.

The two independent Human-visible/XCTest-invisible observations invalidate
further accessibility-owner guessing. Before physical execution resumes, the
driver must instead implement the reviewed coordinate contract below:

- every arm receives a new opaque run token; the preflight main App writes it
  to the existing App Group only for the internal preflight build. Its
  canonical form is `S6A-` followed by 32 uppercase hexadecimal characters
  generated from a new 128-bit UUID;
- token transfer uses one versioned App Group envelope replaced as one value:
  `absent → prepared(token) → consumed(token) → absent`. Main App is the only
  producer/cleaner and Extension is the only consumer. Extension snapshots the
  prepared token before logging the marker, changes the envelope to consumed
  once, and never changes its in-memory token during that arm. The same
  Extension instance may continue with that snapshot after consumption; a new
  instance must reject a consumed envelope. Missing, malformed or log-reused
  tokens fail closed. “Reused” means the token already occurs in the retained
  S6-A log or the current five-pair matrix manifest. A crash residue is
  recorded, then a newly generated token atomically replaces it; the same
  residue token can never resume an arm.
  Normal arm teardown removes only a matching consumed envelope, and final
  preflight cleanup requires the envelope to be absent without touching other
  App Group or userdb state. A separate versioned registry retains at most 64
  opaque tokens for the current matrix only. Main App writes the updated
  registry before preparing the envelope; Extension never reads it. Missing
  registry means an empty matrix, malformed/duplicate/over-capacity registry
  fails closed, per-arm cleanup retains it, and explicit finalization removes
  it only while the envelope is absent;
- after the driver creates the new empty item, the Extension records exactly
  eight content-free slot rectangles for that token. Slot order means the
  visible groups `ABC`, `DEF`, `GHI`, `JKL`, `MNO`, `PQRS`, `TUV`, `WXYZ`;
  device evidence records only slot indices and rectangles, never letters,
  digits, pinyin, candidates or host text;
- geometry uses the current keyboard
  `view.window.windowScene.screen.coordinateSpace` in portrait logical points
  with top-left origin, never pixels, Extension-local or window-local
  coordinates.
  The canonical record includes screen bounds, native scale, portrait
  orientation and the T9 hit-target interaction envelope. That envelope must
  equal the union of the eight serialized slot rectangles within the existing
  geometry tolerance; it is not the `UIInputViewController` root view,
  keyboard chrome or container frame. The driver verifies that the logical
  screen bounds equal the foreground Reminders frame before converting each
  slot center to normalized screen offsets;
- the driver obtains the geometry through the internal evidence view, returns
  to the same Reminders editor, and taps the centers of those rectangles on the
  fixed monotonic schedule. It never discovers, labels or operates a numeric
  keypad;
- geometry is accepted only when the token and marker match the arm; screen,
  hit-target envelope and all eight rectangles are finite with strictly
  positive width and height; every slot is at least `30 × 30` logical points,
  is wholly inside both the screen and envelope, and does not overlap another
  slot. The envelope itself must be wholly inside the screen with
  `minY ≥ 0.5 × screenHeight`;
- slots must form the frozen `2 + 3 + 3` row-major topology: `0...1`, `2...4`
  and `5...7` share rows within 4 logical points of center Y; center X strictly
  increases within each row; and the three row-center values strictly
  increase. There is no fixed/guessed fallback;
- the prepared geometry has a SHA256 over its canonical token/screen/
  orientation/scale/keyboard/slot serialization. On the first real T9 key
  handler, before input processing, the Extension emits one `phase=execution`
  geometry from the then-current view. Final evidence requires its digest to
  equal the prepared digest, proving that the evidence-App round trip did not
  change the layout actually receiving taps;
- the full accepted provenance is a same-token partial order. Marker precedes
  prepared geometry, which precedes execution geometry. The 38 `T9SEG` records
  are strictly ordered by action; `T9ARM` follows action 38. A has zero scoped
  `T9AUTO` outcomes. B has exactly one `T9AUTO` after execution geometry and
  before `T9ARM`; it carries the action/event identity of the handler that
  produced it and may precede that action's `T9SEG` because the transaction is
  logged inside `controller.handle`. Every listed record carries the token;
  missing, duplicate, stale, mismatched or partial-order-invalid records
  invalidate the arm. A coordinate action without this closed-loop evidence
  can never prove success.

Because every arm switches from Reminders to the content-free evidence view,
the Environment Executor must pause before **every** arm and obtain fresh Human
confirmation that the exact list overview is foreground and Universe Chinese
nine-key is the most recently selected software keyboard. A prior arm's
confirmation cannot be reused.

After remediation, signed A/B App binary SHA256 values are respectively
`31927952062a963d1521f3b07ac4bf28a87de8cb8781fb099bd62d66b17e4a97`
and
`1b136f2ac3d723c4f6a072932ba502716d6da301d8745e9d8352356b6d8e653c`;
Extension values are
`e5eab40064597b22d3e3dcbc41c8a13bdec1bc21caf89842cd2bec9afae0130b`
and
`cb76378ab6354c3ba609aebc9a23e9c3ef9a29765f2c8090c7ff21602599f5d9`.
The valid five-pair matrix has not started (`0 / 5`). Physical execution is
paused until the coordinate driver has an immutable checkpoint, focused
contracts/builds pass, and independent Architecture and Quality reviews return
Pass.

Coordinate-driver implementation checkpoint
`8c5aa6d90ad881716593a4dd60b71150429054fd` is now immutable and locally
validated on Xcode `27.0 (27A5228h)` with iOS Simulator SDK `27.0`:

- flagged token/envelope lifecycle contracts: `4 / 4`;
- content-free fixture, cadence, geometry and evidence contracts: `5 / 5` in
  both arm64 Release-like A and B products;
- arm64 Release-like A and B `build-for-testing`: passed; the enabled-only
  condition still fails compilation at the declared `#error`;
- ordinary arm64 Debug and Release builds: passed; project/shared
  scheme/xcconfig search found neither preflight condition, and ordinary App
  plus Extension binary scans found no `T9_S6A`, `T9DEVICE`, `T9GEOM` or
  envelope-key string;
- KeyboardCore: `751 / 751`; RimeBridge iOS Simulator: `33` passed and `15`
  existing external-fixture-gated skips retained as non-coverage;
- `scripts/ensure_rime_vendor.sh verify`: all `11` structural artifacts
  verified.

This evidence does not reopen physical execution by itself. Architecture and
Quality must independently review the immutable implementation checkpoint
before a new signed arm is built or installed.

Independent implementation review of `8c5aa6d` returned Architecture `Pass`
with P0–P3 none, but Quality `Fail`: two P1 findings identified silent
replacement of malformed envelope residue and a current-matrix token set that
was not connected to the main-App coordinator; two P2 findings identified
incomplete frozen negative coverage and insufficiently traceable command/
artifact evidence. Consequently `8c5aa6d` is retained as a historical
checkpoint but is not eligible for physical execution. Remediation is limited
to those four findings and requires a new immutable checkpoint plus both
independent re-reviews.

Remediation implementation checkpoint
`13ee432cefa83d2b2d9717c9675db0ed6e934404` addresses only those findings.
Its exact commands, environment, result-bundle paths, negative-case coverage
and A/B/ordinary Simulator digests are recorded in
[`t9-auto-anchor-s6a-coordinate-driver-2026-07-28.md`](../evidence/t9-auto-anchor-s6a-coordinate-driver-2026-07-28.md).
Physical execution remains paused until independent Architecture and Quality
both re-review this checkpoint and return Pass.

The first re-review of `13ee432` remained `Fail`. Architecture found that the
evidence view collapsed present malformed/non-String envelope or registry
objects into `absent`, which could falsely prove cleanup/finalization. Quality
found that registry list parsing omitted empty comma fields and therefore
accepted malformed values such as `v1|,`. Both are P1 fail-closed defects.
Their remediation introduces explicit `absent / valid / invalid` storage
inspection, uses that inspection for evidence and finalization, and permits an
empty registry only as the exact serialization `v1|`. A further immutable
checkpoint and both independent re-reviews remain mandatory.

That second remediation is immutable at
`cff226dc08502d881bb480ec59c990932a21db67`. The linked evidence snapshot now
binds its post-checkpoint A/B test result bundles, six focused storage tests and
updated A/B binary digests. Third-round independent re-review returned:

- **Architecture:** `Pass`, P0–P3 none;
- **Quality:** `Pass`, P0–P3 none; the `15` RimeBridge skips remain
  external-fixture non-coverage.

The two prior storage P1 findings are closed. This permits preparation of the
next signed A1 arm, but records no physical-device result and grants no Product
Gate. Installation and execution still require a fresh per-arm Human
confirmation of the exact Reminders list overview and most-recently-selected
Universe Chinese nine-key software keyboard.

### Coordinate-driver focused contract matrix

Before a new signed physical arm, deterministic UI-target contracts must prove:

- token/envelope: the complete matching
  `absent → prepared(token) → consumed(token) → absent` transition passes;
  absent, empty, malformed, retained-log reuse, current-matrix reuse, unknown
  envelope version, illegal state and crash-residue resume fail. The same
  Extension instance may continue using its snapshotted token after the
  envelope is consumed; a reconstructed instance must reject a consumed
  envelope. Matching cleanup removes it; non-matching cleanup must leave it
  untouched. A versioned bounded matrix registry round-trips and appends fresh
  canonical tokens; duplicate token, malformed version/token/state,
  duplicate entries and overflow fail. A malformed existing envelope cannot
  be silently overwritten. Every cross-record token mismatch fails;
- geometry shape: one valid eight-slot record passes; `0`, `7` or `9` slots,
  duplicate/missing indices, `NaN`/infinity, zero/negative or smaller-than-
  `30 × 30` size, overlap, screen/keyboard escape, incorrect coordinate space,
  scale, bounds or orientation fail;
- topology: the declared `2 + 3 + 3` row-major centers pass; swapped slots,
  reversed columns/rows, non-monotonic centers and wrong row grouping fail;
- lifecycle drift: equal prepared/execution canonical digests pass; any screen,
  orientation, scale, keyboard-frame or slot change fails;
- evidence: same-token marker and prepared/execution geometry precede input;
  38 ordered `T9SEG` records precede one `T9ARM`; A has zero `T9AUTO`, while B
  has one action/event-bound `T9AUTO` between execution geometry and `T9ARM`
  and possibly before its producing action's `T9SEG`. Missing, duplicate,
  stale, segment-order-invalid, partial-order-invalid or token-mismatched
  records fail;
- timing: the fixed monotonic `200 ms` schedule passes at the frozen boundary;
  an action starting more than `50 ms` late fails;
- privacy: every token/geometry/evidence error is converted to an XCTest
  failure only after the internal evidence App replaces Reminders.

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
- when accessibility cannot expose the visible third-party keys, the opt-in
  coordinate driver proves fresh-token geometry validation, slot mapping,
  lower-keyboard-region bounds, same-geometry final validation and stale-token
  rejection in focused contract tests;
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
- Each arm's internal evidence view returns one same-token marker, matching
  prepared/execution geometry, exactly 38 same-token scoped `T9SEG` records,
  one same-token `T9ARM` summary, zero commits and one stable valid native
  session; A has zero `T9AUTO` outcomes in that scoped arm and B has exactly one
  same-token accepted or rejected-and-restored outcome.
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
- a run token is absent, reused or malformed; geometry is absent, stale,
  content-bearing, outside the lower keyboard region, overlapping, out of slot
  order, different after the arm, or not bound to the latest expected binary
  marker;
- the token envelope violates `absent → prepared → consumed → absent`, a crash
  residue is silently resumed, cleanup removes a non-matching value, or the
  matrix registry is malformed/reused/over capacity, finalization runs while
  an envelope exists, or ordinary Release reads/writes either preflight key;
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
- a unique opaque run token and the same-token content-free geometry digest;
- portrait global-screen logical bounds/scale, keyboard frame and the validated
  `2 + 3 + 3` slot-topology result;
- exact temporary `.xcresult` location, attachment-scan result and the
  content-free subset retained after review. Raw result bundles are never
  copied into repository evidence; any content-bearing screenshot or UI
  hierarchy invalidates the arm.

Each arm must:

1. install the declared internal variant without uninstall/reset;
2. prepare a unique opaque run token through the internal preflight main App;
   require the versioned envelope to reach `prepared(token)` by one-value
   replacement; ordinary Release must not contain this preparation path;
3. record start thermal/discrete-power/debugger/Full Access/host/orientation/
   layout/schema/runtime plus session identity/validity and invalidate any
   unknown or mismatch;
4. start with a newly created empty test item inside the exact disposable list
   and an empty composition;
5. launch without debugger attachment, consume the prepared envelope exactly
   once and confirm the same-token expected gate marker plus exactly eight valid
   same-token letter-group slot rectangles in the canonical portrait global
   screen coordinate space;
6. return to the same empty editor and tap only the centers derived from those
   visible T9 letter-group rectangles at `200 ms` cadence. The first real T9
   handler must emit a same-token execution-geometry digest equal to the
   prepared digest before processing its key;
7. avoid Path, candidate, space, commit and Delete during the timing arm;
8. after the 38th action, keep the extension visible for one second while the
   ordered writer drains; then switch to the internal evidence view and require
   exactly 38 ordered content-free timing records, the expected marker, zero
   commits, matching prepared/execution geometry, one summary, the expected A/B
   outcome count and one stable valid native session, all carrying the same run
   token;
9. record the same environment fields at arm end; any drift invalidates the
   arm. The session identity must remain valid with no loss/recreation; the
   expected composition transition from empty to active after 38 actions is
   recorded separately and is not drift;
10. capture a content-free functional result and leave all test-created
   Reminders state for Human cleanup; remove only the matching consumed token
   envelope and verify it is absent while the bounded matrix registry remains
   active.

After the last valid arm, the preflight main App performs the explicit
`T9_S6A_FINALIZE_MATRIX=1` action. It may remove only the matrix registry and
only while the run envelope is absent. Evidence must then report both
`T9TOKEN state=absent` and `T9MATRIX state=absent` before the ordinary
same-checkpoint Release is installed.

The runner must not call `XCTFail`, `XCTAssert*` or `XCTUnwrap` while Reminders
is visible. Driver errors are retained as content-free codes, the main App's
internal evidence surface first replaces Reminders, and only then may XCTest
record a failure. Each raw `.xcresult` remains in its exact temporary arm
directory until attachment inspection; only content-free console/manifest
output and digests are retained in the repository.

Invalid arms remain listed with a reason and are never silently retried into a
Pass.

## Zero-context physical-arm runbook

This section is the executable handoff for another AI. It does not replace the
contract, gates or Stop Conditions above.

1. Read this Assignment, ADR 0024 and
   [`t9-auto-anchor-s6a-coordinate-driver-2026-07-28.md`](../evidence/t9-auto-anchor-s6a-coordinate-driver-2026-07-28.md).
   Confirm the current implementation checkpoint and that both independent
   reviews are Pass. Do not infer Product Gate.
2. Query the declared device read-only. Require the same UDID/model/OS,
   connection, unlocked state and Developer Mode. Any drift starts a new Run
   Header review.
3. Build each arm from the same implementation source and Release
   configuration. A uses only
   `-DT9_AUTO_ANCHOR_DEVICE_PREFLIGHT`; B uses the same condition plus
   `-DT9_AUTO_ANCHOR_DEVICE_PREFLIGHT_ENABLED`. Use separate DerivedData and
   `build-for-testing` against the physical-device destination with
   `-allowProvisioningUpdates`.
4. Inspect App/Extension hashes, bundle/team identity and Extension strings.
   A must contain only `T9DEVICE_DISABLED`; B only `T9DEVICE_ENABLED`. Both may
   contain the common envelope/registry strings. Ordinary Release must contain
   none. A host `CSSMERR_TP_NOT_TRUSTED` result is recorded as a host trust
   warning, never rewritten as strict verification success.
5. Bind the following three values inside the generated `.xctestrun` test
   target's `EnvironmentVariables`; shell-only environment variables do not
   reliably reach a physical-device runner:
   `T9_S6A_DEVICE_PREFLIGHT_RUN=1`,
   `T9_S6A_DISPOSABLE_LIST=Universe Keyboard S6A 20260728`, and the arm-specific
   `T9_S6A_EXPECTED_MARKER=T9DEVICE_DISABLED|T9DEVICE_ENABLED`.
   Run `plutil -lint` and read the three values back before installation.
6. Announce the exact arm and pause. The Human must freshly confirm the exact
   list overview is foreground, the phone is unlocked, and Universe Chinese
   nine-key is the most recently selected software keyboard. Never reuse a
   prior confirmation.
7. Install with `xcrun devicectl device install app --device <UDID> <App>`.
   Never uninstall, erase a container, reset userdb or delete Reminders state.
8. Execute only
   `UniverseKeyboardUITests/T9DevicePreflightUITests/testFrozenLongCompositionInDisposableRemindersList`
   through `xcodebuild test-without-building -xctestrun ... -destination ...`.
   Give every attempt a unique `.xcresult` path under `/private/tmp`.
9. The runner must create its own empty title, prepare a fresh token, accept
   only eight Extension-owned rectangles in visible group order
   `ABC…WXYZ`, return to the same editor and tap their centers. Slot indices
   represent visible letter groups; automation never discovers or displays a
   numeric keypad.
10. If the test method initializes, accept an arm only after the same-token
    marker/geometry/38 segments/summary/session/outcome and matching cleanup
    pass. If automation mode or the test runner fails before initialization,
    record zero actions and classify it as an environment failure, not a
    keyboard result.
11. Never open/export/copy Xcode failure diagnostics or UI attachments before
    a privacy review. `devicectl_diagnostics.zip` is always treated as
    potentially private. Keep the raw result isolated and record only the
    content-free failure code/path.
12. After every success or failure, obtain another fresh Human readiness
    confirmation before any retry or next arm. Follow the frozen pair order.
    After the final arm, require matching envelope cleanup, explicit matrix
    finalization, ordinary Release reinstall without uninstall/reset and a
    successful keyboard-switch smoke check.

## Handoff

- **Handoff Target:** Architecture and Quality for entry/exit review; Human
  Product Owner for manual experience judgment and any later Product Gate
- **Required Handoff Content:** immutable commit, A/B build identities, device
  Run Header, valid/invalid manifest, timing distributions, functional
  outcomes, cleanup proof, default-Release negative scan and all limitations
- **Revalidation Trigger:** source/build-setting, Xcode/SDK, signing identity,
  device/OS, schema/runtime, Full Access, host/cadence, instrumentation,
  privacy boundary or matrix-order change
