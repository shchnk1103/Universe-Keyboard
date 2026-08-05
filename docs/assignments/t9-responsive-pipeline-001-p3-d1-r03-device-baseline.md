# Assignment: T9-RESPONSIVE-PIPELINE-001 / P3-D1-R03 iPhone 13 Pro Gate-off Baseline

Policy version: 1.0.0  
Lifecycle status: **Completed — gate-off baseline, independent reviews and bounded Evidence Hardening follow-up complete; Product decision pending**  
Date: 2026-08-03 Asia/Shanghai

## Authority

- Assignment Authority: Product Lead
- Decision Source / Date: Human Product Owner authorization in the active Codex task,
  “授权 P3-D1-R03：iPhone 13 Pro 真机人工输入、仅 content-free 诊断证据、不修改生产逻辑；先执行 gate-off baseline。”，2026-08-03 Asia/Shanghai
- Product Approver: Human Product Owner / Product Lead
- Parent Assignment: [`P3-D1 Runtime Lifecycle Evidence Matrix`](t9-responsive-pipeline-001-p3-d1-runtime-lifecycle-matrix.md)
- Architecture Boundary: [`ADR 0025`](../../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md)
  remains **Proposed**; this Assignment does not accept it or alter the current gate-off
  production path governed by [`ADR 0004`](../../architecture/decisions/0004-rime-runtime-session-model.md)

## Boundary

### Scope

- Establish one immutable gate-off baseline run on the connected physical iPhone 13 Pro.
- Use the already declared Human-input method from the parent matrix: Reminders, software
  keyboard, Universe Keyboard 中文九宫格, and the frozen synthetic fixture identified by the
  parent matrix. The Human types it manually; Codex does not type into the third-party keyboard.
- Capture only content-free App Diagnostics and the required run/build/device provenance.
- Observe input integrity (no lost or duplicated keystrokes, candidate disappearance, or keyboard
  exit) and record the Human's subjective responsiveness report without copying typed content.
- Leave the device in an ordinary usable state and record teardown/restore status.

### Non-goals

- No production logic, schema/Lua, bridge, pipeline, gate, UI or test-code changes.
- No gate-on, A/B comparison, T02/T03 harness activation, responsive-gate setting, ADR 0025
  acceptance, Product Gate, Release decision or performance SLO claim.
- No coordinate driver, Computer Use typing, XCTest typing, numeric-key tapping or candidate/path
  selection as part of the fixture.
- No uninstall, App Group wipe, RIME/userdb reset, destructive cleanup or device erasure.
- No raw pinyin, candidate text, host text, user dictionary data, credentials or screenshots that
  expose typed content in the evidence package.

### Required inputs

- Parent P3-D1 matrix and P2-PERF-02 content-free evidence contract.
- A build whose responsive gate is demonstrably off and whose source/build fingerprint can be
  recorded without changing project defaults.
- Connected, unlocked and trusted iPhone 13 Pro, with the keyboard available and Reminders ready.
- App Diagnostics export or equivalent content-free diagnostic channel accessible after the run.

## Assignment

- Domain Owner: Quality, Performance & Release Maintainer
- Executor: Current Codex task for non-destructive preflight, evidence orchestration and records
- Environment Executor: Current Codex task for read-only device/build discovery and explicitly
  authorized install/log operations
- Human Dependency: Human Product Owner manually performs the frozen fixture in Reminders and
  reports integrity and subjective responsiveness; Human does not paste typed content
- Architecture Reviewer: Independent Architecture & Knowledge Steward
- Quality Reviewer: Independent Quality, Performance & Release Maintainer

## Gates

### Entry criteria

- This Assignment contains no `UNKNOWN` required responsibility and remains within the parent
  matrix, ADR 0004 and ADR 0025 boundaries.
- The connected destination is confirmed to be the user's iPhone 13 Pro, unlocked/trusted and
  available for a non-destructive run; stale or guessed device identifiers are rejected.
- The selected build is identifiable and gate-off is proven from configuration/diagnostics; an
  inability to prove gate-off blocks the run rather than becoming an assumption.
- Reminders is open to the prepared list/title, software keyboard mode is selected, Universe
  Keyboard 中文九宫格 is visible, and App Diagnostics capture is available.

### Exit criteria

1. One immutable Run ID binds the source/dirty-worktree fingerprint, build configuration, app and
   extension identity, device/OS provenance, gate/path facts and diagnostics artifacts.
2. Human integrity and subjective responsiveness outcomes are recorded without typed content.
3. App Diagnostics are privacy-scanned, content-free, hash-bound where possible, and distinguish
   missing fields from explicit `gate=off` observations.
4. Teardown/restore status is recorded; no device or App Group destructive action is performed.
5. The parent matrix row is classified `Passed`, `Partial`, `Blocked` or `NotRun` with evidence
   layer provenance. This result is not a Product Gate decision.
6. The package is handed to independent Architecture and Quality review; unresolved residuals
   return to the Product Lead.

### Stop conditions

- Device is absent, locked, untrusted, stale, or the physical destination cannot be identified.
- Build/install/signing or App Diagnostics access fails; record the exact unavailable observation
  and retry condition instead of inferring success.
- Gate-off cannot be proven, diagnostics contain raw content, or capture would require a
  destructive reset or unauthorized automation.
- Human reports lost/duplicate input, candidate disappearance, keyboard exit or another safety
  issue; stop the run and preserve the evidence.
- Any request would expand into gate-on, production rewiring, target harness work, A/B testing,
  Product Gate or Release approval.

## Handoff

- Handoff Target: Independent Architecture reviewer, then independent Quality reviewer; final
  residual decision returns to the Product Lead.
- Completed reviews:
  - [`Independent Architecture review`](t9-responsive-pipeline-001-p3-d1-r03-device-architecture-review.md)
    — Pass with conditions for this bounded evidence layer; P0/P1 = 0; R03 remains `Partial`.
  - [`Independent Quality review`](t9-responsive-pipeline-001-p3-d1-r03-device-quality-review.md)
    — bounded gate-off baseline; P0/P1 = 0; evidence-completeness residuals remain; R03 remains
    `Partial`.
- Required Handoff Content: Assignment and parent-row update, Run ID, exact build/device
  provenance, content-free diagnostics artifact/hash, Human report, privacy scan, unavailable or
  contradictory observations, and teardown/restore proof.
- Revalidation Trigger: source/build configuration, device/OS, keyboard/runtime deployment,
  diagnostics schema, Full Access state, parent matrix, ADR 0025 status or Product Gate decision
  changes.

## Evidence record (to be completed after preflight/run)

- Run ID: `P3D1-R03-OFF-20260803-001` / device token `S6A-976A047CA1BB477AA5BAC6836278209B`
- Source/dirty-worktree fingerprint: HEAD `3585a540ba8389673acd49128d87040ac9619f27`; 86 dirty entries; tracked diff SHA-256 `5f67fc561b8e2494c895a6176909fc2602dad4492f275eed839a36eda40c45be`; untracked-name SHA-256 `ce8fbc520ed5e98eeb9a602ac95522941cd8373a381dc09653fbff8370513e0f`
- Build configuration and gate-off proof: Release; `T9_AUTO_ANCHOR_DEVICE_PREFLIGHT` only; no `T9_AUTO_ANCHOR_*_ENABLED`, responsive or thread-affine flag; app executable SHA-256 `36f1138bda3e8e2a3942eb099782acb2f449a401d97767a7046a57f3abc7165e`; Keyboard.appex executable SHA-256 `ec0f05193114b3cf0d98683608a8a225a4b09b3ad6bb7ed3e6bb0aaa65122d0f`
- Device/OS/UDID provenance: iPhone 13 Pro / `iPhone14,2`; iOS `27.0 (24A5390f)`; UDID `00008110-000A08440198801E`; CoreDevice identifier `DE65EBE1-463E-5EB4-9694-F6DCBFC04028`; wired, paired, connected, booted, developer mode enabled
- Human integrity report: no lost/duplicate input, candidate disappearance or keyboard exit; user reported noticeable key stalls
- Subjective responsiveness report: not smooth; no numeric score supplied
- Content-free App Diagnostics artifact/hash: [`P3-D1-R03 device evidence`](../evidence/t9-responsive-pipeline-p3-d1-r03-device-2026-08-03.md); attachment SHA-256 `6cc87c38e1f682a26d5cf1ad85aadeacfcda6b353b371dda131f576691fa4d76`
- Evidence Hardening follow-up: [`validator + restore smoke`](../evidence/t9-responsive-pipeline-p3-d1-r03-evidence-hardening-followup-2026-08-03.md); validator `complete`,
  run-bound actions/events `1…39`, geometry/session/privacy checks passed; Human post-restore
  smoke `keyboard visible=yes`, `single key effective=yes`, `keyboard exited=no`, `stable=yes`,
  `stallScore=0` for the one-key smoke only
- Q2/Q3 provenance addendum: [`source/build/restore + fixture/host evidence hardening`](t9-responsive-pipeline-001-p3-d1-r03-q2-q3-evidence-hardening.md);
  build/restore identity and observed marker fixture ID are recorded; canonical fixture digest
  binding and other historical missing fields remain explicitly `unavailable`/unproven.
- Q2/Q3 independent reviews: [`Architecture`](t9-responsive-pipeline-001-p3-d1-r03-q2-q3-architecture-review.md)
  and [`Quality`](t9-responsive-pipeline-001-p3-d1-r03-q2-q3-quality-review.md); both retain
  `Partial` and require a new canonical-bound run before A/B.
- Teardown/restore: after capture, an ordinary same-source Release package (no
  `T9_AUTO_ANCHOR_DEVICE_PREFLIGHT` injection) built successfully and replaced the
  diagnostic package on device; install database sequence `3744`; app executable
  SHA-256 `b5a6ee5fe1ba8ac19ff3342d96dc0ba0c11ec53007494938eab80cc35cbefce8`;
  Keyboard.appex executable SHA-256
  `8f24558f195c57201e51059608af53f8193219aca1df217ad4b964ea71c5fd4a`; no
  `T9_AUTO_ANCHOR_DEVICE_PREFLIGHT` or responsive preflight marker was present;
  no uninstall, App Group/userdb/Reminders cleanup or device erase; device remained connected
- Classification: `Partial — gate-off baseline captured; validator and post-restore smoke hardened; B comparison not run`
- Independent review disposition: Architecture and Quality both completed bounded reviews; neither
  accepts ADR 0025, opens B, changes Product Gate or authorizes Release. Open evidence residuals are
  tracked as Architecture P2/P3 and Quality Q2/Q3 findings in the linked review documents; the
  attachment-reopen/privacy and post-restore-smoke portions were closed by the follow-up.
