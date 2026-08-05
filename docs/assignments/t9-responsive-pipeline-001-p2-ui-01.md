# Assignment: T9-RESPONSIVE-PIPELINE-001 / P2-UI-01

Policy version: 1.0.0  
Lifecycle status: **Ready**  
Date: 2026-08-01 Asia/Shanghai

## Authority

- Assignment Authority: Product Lead
- Decision Source / Date: Human Product Lead authorization in the current Codex task, 2026-08-01 Asia/Shanghai
- Product Approver: Human Product Owner / Product Lead
- Parent assignment: [`P2-Regression-Matrix-001`](t9-responsive-pipeline-001-p2-regression-matrix.md)
- Parent architecture: [`ADR 0025`](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md)（Proposed）

## Boundary

### Scope

1. Add only the minimum Xcode test-target wiring needed to load the UIKit
   Keyboard Extension presentation code in a deterministic test bundle.
2. Add regression tests for bar and expanded candidate prefetch while
   `controller.isResponsiveProvisionalAhead` is true.
3. Use a controllable Fake RIME engine/spy to observe `candidateWindow` calls,
   candidate snapshot mutation, owner-depth proxies and presentation refresh
   callbacks without using typed content.
4. Prove that ordinary prefetch resumes after the composition is settled and
   `provisionalAhead` is false.
5. Record exact build/test commands, skipped checks and the bounded conclusion.

### Non-goals

- No changes to `Keyboard/` or `Packages/KeyboardCore/` production logic.
- No change to either responsive gate, ADR 0025 status, or Release defaults.
- No real librime/Lua/OpenCC performance claim, physical-device test, jetsam
  observation, Product Gate, R6 acceptance or Release approval.
- No refactor of candidate paging, Core state semantics or Extension lifecycle.
- No engine/session object is moved across isolation domains; no
  `@unchecked Sendable`.

### Required inputs

- [P2 regression assignment](t9-responsive-pipeline-001-p2-regression-matrix.md)
- [P2 Architecture re-review](t9-responsive-pipeline-001-p2-regression-matrix-architecture-rereview.md)
- [P2 Quality re-review](t9-responsive-pipeline-001-p2-regression-matrix-quality-rereview.md)
- [ADR 0025](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md)
- [Project context](../PROJECT_CONTEXT.md)
- [Keyboard UI playbook](../playbooks/keyboard-ui.md)
- [Test / Release playbook](../playbooks/test-release.md)

## Assignment

- Domain Owner: Keyboard UI permanent owner
- Executor: Current Codex task
- Environment Executor: Current Codex task for local Xcode/test execution; no physical device required
- Human Dependency: Not Applicable — no device interaction or private content is required
- Architecture Reviewer: Independent Architecture & Knowledge Steward
- Quality Reviewer: Independent Quality, Performance & Release Maintainer

## Entry criteria

- Product Lead authorization is recorded above.
- Existing P2 Core changes remain ambient and are not rewritten by this task.
- The test design can observe the real Extension paging method or the task is
  stopped before introducing a production seam or duplicated implementation.
- The test harness uses content-free fixtures and keeps all engine calls
  serialized within the test's MainActor boundary.

## Exit criteria

1. A minimal test-target/project wiring change is present, if required, and
   production targets remain behaviorally unchanged.
2. Ahead-state bar and expanded prefetch tests prove no `candidateWindow` call,
   no owner-depth increase, no candidate snapshot mutation and no presentation
   refresh.
3. A settled-state control test proves ordinary prefetch still reaches the Fake
   engine and updates the candidate snapshot.
4. The affected test target and existing relevant tests pass, or the task is
   recorded Blocked with the exact build/tooling reason.
5. `git diff --check` passes and the evidence records target, configuration,
   simulator/build provenance and all skipped validation.
6. Independent Architecture and Quality reviews are requested; this task stops
   before any Product Gate or Release decision.

## Stop conditions

- Testing the real Extension requires modifying production code or changing a
  durable architecture contract.
- The only viable test path duplicates production candidate paging logic rather
  than loading the real method.
- A target wiring change would alter Release embedding, runtime behavior or
  default gate selection.
- Xcode/Scheme/Simulator tooling cannot build the target and no deterministic
  local fallback exists.
- Any requested evidence would require real user text, a physical device,
  Release signing, jetsam or Product Gate authority.

## Handoff

- Handoff Target: Independent Architecture reviewer, then independent Quality reviewer
- Required Handoff Content: changed test/project files, exact test results,
  production-diff check, target-wiring limitations, skipped device/performance
  checks, and a bounded Pass/Fail/Blocked recommendation.
- Revalidation Trigger: any production candidate-paging change, target graph
  change, gate/default change, Xcode major-version change, or new requirement
  for real-device/performance evidence.

