# Assignment: T9-RESPONSIVE-PIPELINE-001 / P3-D1-T02/T03 Lifecycle Harness

Policy version: 1.0.0  
Lifecycle status: **Blocked — Product Hold; implementation and independent re-review complete; host-driven runtime proof unavailable**  
Date: 2026-08-03 Asia/Shanghai

## Authority and boundary

- Assignment Authority: Product Lead
- Decision Source / Date: Human Product Owner authorization in the active Codex task,
  “很好，我授权你继续”，2026-08-02 Asia/Shanghai
- Product Approver: Human Product Owner acting as Product Lead
- Parent Assignment: [`P3-D1 Runtime Lifecycle Evidence Matrix`](t9-responsive-pipeline-001-p3-d1-runtime-lifecycle-matrix.md)
- Predecessor: [`P3-D1-T01 Test Harness Repair`](t9-responsive-pipeline-001-p3-d1-t01-test-harness-repair.md)
- Production baseline: [`ADR 0004`](../architecture/decisions/0004-rime-runtime-session-model.md)
  remains **Accepted**
- Diagnostic architecture boundary: [`ADR 0025`](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md)
  remains **Proposed**, dual-gate remains default-off

## Product Lead disposition — Option 1 hold (2026-08-03)

The Human Product Owner selected the first close-out option: keep this bounded T02/T03 slice
unchanged and pause further work. The implementation, focused regressions and independent
Architecture/Quality reviews remain valid evidence, but the host-driven runtime rows remain
`Blocked (host accessibility)` rather than `Passed`.

Consequences of this hold:

- no additional production, harness, test, simulator or device changes under this Assignment;
- no ADR 0025 acceptance, Release default-on, Product Gate or real-RIME conclusion;
- reopening requires a new explicit Product Assignment for either target provenance/marker
  remediation or a host environment/driver that can prove the keyboard activation boundary.

This Assignment covers only a target-level, controlled Fake/Spike lifecycle harness for the
Extension target. It does not authorize real `RimeEngineImpl` production migration, Release
default-on, ADR 0025 acceptance, Product Gate, physical-device A/B, persistence durability or
memory/jetsam conclusions.

## Assignment

- Domain Owner: ⌨️ Keyboard Experience Maintainer
- Secondary domain consultation: 🧠 Input Intelligence Maintainer for epoch/revision contracts;
  🔧 RIME Platform Maintainer only for protocol-level Fake/Spike boundary review
- Executor: Current Codex task, after explicit implementation instruction, for the bounded harness,
  focused target tests and content-free evidence
- Environment Executor: Current Codex task for read-only target discovery, Xcode build/test and
  the already-discovered iOS 27.0 Simulator; no device creation, erasure or substitution
- Human Dependency: **Not Applicable** for this controlled target phase; physical input remains a
  separate R03/R04 dependency
- Architecture Reviewer: 🏛️ Architecture & Knowledge Steward, independent of implementation
- Quality Reviewer: 🧪 Quality, Performance & Release Maintainer, independent of implementation
- Handoff Target: Product Lead hold recorded; any reopening requires a new Product Assignment and
  fresh acknowledgement

## Scope

### T02 — controlled owner/lifecycle target harness

The harness must exercise the actual Extension-target boundary with a controlled Fake/Spike owner
or an explicitly isolated target fixture. It must prove only content-free contracts:

1. MainActor accept/enqueue returns while the owner is deliberately delayed (150 ms or more in the
   controlled fixture).
2. Accepted work remains ordered and is not dropped, merged or reordered.
3. Results crossing back to MainActor are checked by `sessionEpoch` and `revision` before apply.
4. A visibility/reset barrier invalidates old pending results and leaves the new epoch usable.
5. Gate-off behavior remains equivalent to the current ADR 0004 synchronous path.

The harness must not call a live non-Sendable `RimeEngine` across isolation boundaries and must not
use `@unchecked Sendable`. The real librime owner remains outside this Assignment.

### T03 — target visibility/reload lifecycle harness

The harness must exercise the target lifecycle boundary, not only a pure Core object:

1. First appearance starts from a clean controller/session boundary.
2. A later appearance clears unfinished composition, marked-text authority, candidate/Path caches,
   transient press state and the old epoch according to ADR 0002.
3. Disappearance performs the visibility abandon/release path before the target is considered
   suspended.
4. Return does not restore unfinished composition from the previous host interaction.
5. A controlled reload/fixture teardown does not allow an old snapshot to publish into the new
   lifecycle epoch.

T03 does not claim physical process death, App Group durability or jetsam behavior; those remain
   P3-D1-R04/R05/R06.

## Technical design constraints before implementation

`KeyboardExtensionTests` cannot link a concrete `Keyboard.appex` symbol as an XCTest host. Its T01
bundle-only probe therefore remains a smoke test and must not be expanded by simply referencing
`KeyboardViewController.self`.

Before code is written, the implementation must choose and document one target-real boundary:

- dynamic appex bundle discovery/reflection with a controlled lifecycle driver; or
- host-driven simulator lifecycle with a target-only diagnostic seam and content-free marker export;

and must record why the selected boundary observes the actual Extension target rather than a copied
test double. If neither boundary can safely run under the available Xcode target, the result is
`Blocked` and the harness is not replaced with a pure fake that is reported as target evidence.

The diagnostic seam, if needed, must be compile/test-flag scoped, explicit, default-off and absent
from Release behavior. It may expose only Sendable configuration, lifecycle markers and value
snapshots. It must not expose a live engine handle to the XCTest bundle.

## Implemented boundary and harness

The selected boundary is **host-driven iOS Simulator lifecycle + target-only diagnostic seam**.
The seam lives in the actual `Keyboard` Extension target (the filesystem-synchronized `Keyboard/`
source root), not in `KeyboardExtensionTests` and not in a copied test double. It is compiled only
when both `DEBUG` and `T9_P3_D1_LIFECYCLE_HARNESS` are present.

- The seam installs a config-only `ThreadAffineRimeEngineBootstrap` and a content-free Fake RIME
  owner on the existing `ThreadAffineRimeSessionCoordinator`.
- The Fake sleeps for 150 ms inside owner-thread `processKey`, keeps only a slot count, and returns
  placeholder-shaped value snapshots; it never stores or logs the key, candidate, marked text or
  committed text.
- Lifecycle markers cover load/appear/visible/disappear/return/clear/suspend and owner begin/end;
  they carry only gate, epoch, accepted/applied revision watermarks, pending/stale/discard counts,
  owner readiness/terminal state and bounded reason fields. A per-process run token is supplied by
  `P3_D1_T02_T03_RUN_ID` when present, otherwise generated from a sanitized UUID.
- The actual Extension exposes a harness-only `P3D1LifecycleHarness` accessibility handshake. Its
  value is the same content-free marker line used for validation, allowing the host test to fail
  closed when the installed appex lacks the harness or never publishes/clears the expected state.
- The coordinator keeps a lifecycle epoch outside the replaceable owner. Visibility owner restart
  replays that epoch, and the KeyboardCore regression rejects an epoch-1 snapshot both while the
  owner is stopped and after the replacement owner is ready.
- `T02` and `T03` XCTest methods are explicitly environment-gated by `P3_D1_T02_T03_RUN=1` and
  use the existing host-driven Messages keyboard-switcher flow. A missing switcher is reported as
  `Skipped` with an environment boundary, never as a product failure.
- No project/archive build setting was changed. The harness flag is supplied only on the recorded
  xcodebuild invocation; gate-off is compiled separately without the flag.

## Content-free evidence contract

Every T02/T03 observation is bound to one Run ID and may contain only:

- lifecycle stage (`LOAD`, `APPEAR`, `DISAPPEAR`, `RETURN`, `RELOAD`);
- gate/path/readiness booleans;
- session epoch, accepted/applied revision watermarks;
- pending/coalesced/discarded counters;
- owner delay/ready/terminal booleans and bounded reasons;
- state-cleared and stale-result-rejected booleans;
- marker identity (`schema`, opaque `run`, accepted/applied/stale/discard/terminal watermarks);
- source/build/flags/target/device provenance and artifact hashes.

Raw pinyin, candidate text, committed text, marked host text, user dictionary data, screenshots
and credentials are prohibited. A `PUBLISH` marker does not prove UI paint; a bundle-load result
does not prove lifecycle execution.

## Non-goals and forbidden actions

- No real `RimeEngineImpl` production wiring or Lua/schema changes.
- No change to `KeyboardController` Release defaults, user settings or Product Gate.
- No acceptance of ADR 0025 or revision of ADR 0004.
- No input drop, merge, reorder or queue policy change.
- No `@unchecked Sendable`, unsafe isolation, destructive simulator/device cleanup or App Group wipe.
- No coordinate-driven typing, Computer Use typing or physical third-party keyboard automation.
- No claim of subjective non-stutter, Release readiness, persistence durability or jetsam safety.

## Entry criteria

- T01 repair Assignment is complete and independently reviewed; T01 remains `Partial (bounded)`.
- Parent P3-D1 matrix and ADR 0002/0004/0025 are available; parent remains `Active`.
- `KeyboardExtensionTests` target/scheme and the iOS 27.0 Simulator provenance are discoverable.
- The chosen actual-target boundary is documented before implementation.
- No required Assignment field is `UNKNOWN`; this Assignment currently has no `UNKNOWN` field.

## Exit criteria

1. A focused T02/T03 target-level test or an explicit `Blocked` result with the failed entry command
   and reason.
2. Evidence shows MainActor accept during controlled owner delay, ordered delivery, epoch/revision
   rejection and gate-off equivalence without raw content.
3. Evidence shows first appearance, disappearance, return and controlled reload cleanup at the
   actual target boundary, or clearly records which lifecycle stage could not run.
4. Focused target tests, relevant KeyboardCore regression and `git diff --check` results are recorded.
5. Independent Architecture and Quality reviews classify T02/T03 separately from T01, R01–R06 and
   Product Gate.
6. No ADR 0025 Accept, Release default-on, real-RIME, device or Product Gate conclusion is claimed.

## Stop conditions

- The actual-target boundary cannot be run without linking an appex symbol or copying production
  lifecycle code into a test-only double.
- A test requires real librime, raw text, host marked text, destructive reset or unsafe isolation.
- A target/build/tool failure is mistaken for a runtime pass or a substitute simulator is proposed.
- Implementing the seam would alter Release behavior, persistent settings or the ADR 0004 boundary.
- A result would require a Product decision about timeout budgets, user-visible text semantics or
  default Gate behavior.

## Handoff and revalidation

Handoff must include the selected boundary, exact target/scheme/build flags, source/build fingerprint,
Run ID, content-free markers, skipped/blocked observations, privacy scan and teardown status.

Revalidation is required if the target scheme, Xcode/SDK, simulator/device, diagnostic flag, owner
implementation, ADR 0002/0004/0025 status or Product Gate decision changes.

## Execution record (content-free)

Run ID: `P3D1-T02-T03-SIM-20260803-001`  
Simulator: iOS 27.0 / iPhone 17 Pro Max / `06C5BC3E-7599-4761-A1A2-71DAEA991474`  
Configuration: `Debug`; project `Universe Keyboard.xcodeproj`; UI scheme `UniverseKeyboardUITests`  
Harness compile flag: `SWIFT_ACTIVE_COMPILATION_CONDITIONS=DEBUG T9_P3_D1_LIFECYCLE_HARNESS`  
UI test gate: `P3_D1_T02_T03_RUN=1`; marker token: `P3_D1_T02_T03_RUN_ID=P3D1-T02-T03-SIM-20260803-001`

| Evidence | Result | Artifact / command boundary |
|---|---|---|
| Keyboard Extension harness-on compile | **Passed** | `build_sim`, scheme `Keyboard`; [build log](/Users/doubleshy0n/Library/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/logs/build_sim_2026-08-02T16-17-30-946Z_pid40269_94150708.log) |
| Keyboard Extension gate-off compile | **Passed** | `build_sim`, scheme `Keyboard`, `SWIFT_ACTIVE_COMPILATION_CONDITIONS=DEBUG`; [build log](/Users/doubleshy0n/Library/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/logs/build_sim_2026-08-02T16-18-05-079Z_pid40269_f2122b35.log) |
| T02 host-driven UI invocation | **Blocked / Skipped** | Messages exposed a keyboard surface but no fully accessible Apple system keyboard activation boundary; [result bundle](/Users/doubleshy0n/Library/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-08-02T16-19-23-797Z_pid40269_b0e95931.xcresult) |
| T03 host-driven UI invocation | **Blocked / Skipped** | Same host accessibility boundary; no lifecycle conclusion inferred; [result bundle](/Users/doubleshy0n/Library/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-08-02T16-19-23-797Z_pid40269_b0e95931.xcresult) |
| ThreadAffineRimeWireTests | **Passed, 10/0** | `swift test --package-path Packages/KeyboardCore --filter ThreadAffineRimeWireTests` |
| P3D1LifecycleEvidenceValidatorTests | **Passed, 6/0** | `swift test --package-path Packages/KeyboardCore --filter P3D1LifecycleEvidenceValidatorTests` |
| KeyboardCore full regression | **Passed, 901/0** | `swift test --package-path Packages/KeyboardCore` |
| Diff hygiene | **Passed** | `git diff --check` |

The target-level lifecycle code is therefore compiled and bounded, but T02/T03 remain **Blocked
(host accessibility)** rather than Passed: the available Simulator run could not complete the
actual Extension activation through Messages, so no owner-delay or visibility-return marker
sequence was observed in the target process. The UI tests now fail closed if the harness handshake
is absent; that branch was not reached because the host activation boundary was skipped.

Current worktree source fingerprints for this run (ambient dirty worktree; not a commit identity):

- `Keyboard/Controllers/KeyboardViewController+Bootstrap.swift`: `90904e6fca385e71c02a37e4a6739a377ae6d7df0ecd7bc273c82f6cdb71ee5c`
- `Keyboard/Controllers/KeyboardViewController.swift`: `294d74878018e25bbdec59202cbb0bc62cb02ae2b2e9aa5f48bacadc719de31a`
- `Keyboard/Controllers/KeyboardViewController+Presentation.swift`: `22554f0cffa54d862b684679c422561a68e399e1c914dfdcdb19f54d3eb6f9ab`
- `Packages/KeyboardCore/Sources/KeyboardCore/ThreadAffineRimeSession.swift`: `00d490e91024db2b16f2e9217efa15b4760f9cebff3b5c486c36012f1d84cfb6`
- `Packages/KeyboardCore/Tests/KeyboardCoreTests/ThreadAffineRimeWireTests.swift`: `4d6d31a7adb91450172a677b848e2288beaf038e0dd77f562abcfdaa6cd4ab10`
- `Packages/KeyboardCore/Sources/KeyboardCore/P3D1LifecycleEvidenceValidator.swift`: `8fc6421b61650c90a4da86b295492f50c8cef852ab1a6164707989fd49dd457b`
- `Packages/KeyboardCore/Tests/KeyboardCoreTests/P3D1LifecycleEvidenceValidatorTests.swift`: `b640688bdd81e98fbdf02b77c3cadca818b5edba733ddfa502bc3f25a0cf606e`
- `UniverseKeyboardUITests/NativeExperienceKeyboardAutomationFeasibilityTests.swift`: `9073950761a8c836deb0888d845fb1c8351d38896607584642728d92c21905d8`

This does not prove real `RimeEngineImpl`, real Lua/schema behavior, physical-device lifecycle,
App Group persistence, Extension jetsam, or Product Gate readiness. The Assignment is now held at
the Product Lead boundary; reopening T02/T03 requires a new Product Assignment plus a host state
that exposes the keyboard activation boundary or a separately authorized target driver.
