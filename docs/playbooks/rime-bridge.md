# RimeBridge Playbook

## Mission

Own the Swift/ObjC/librime boundary, process-local sessions, deployment service and binary-artifact integration without violating App/Extension ownership.

## When to Use

- `Packages/RimeBridge` session, bridge, deployment service or tests.
- librime/librime-lua/OpenCC binary integration.
- Schema selection, session recovery or RIME runtime diagnostics.

## Do Not Use For

- Keyboard UI/state-machine behavior unrelated to real RIME semantics.
- Main-App scheme UX.
- Moving full deployment into the Extension.

## Required Reading

- RIME map in [Reading Maps](../READING_MAPS.md)
- [Shared Container And RIME Lifecycle](../architecture/shared-container-and-rime-lifecycle.md)
- ADR [0001](../architecture/decisions/0001-main-app-owns-rime-deployment.md), [0003](../architecture/decisions/0003-shared-container-ownership.md), [0004](../architecture/decisions/0004-rime-runtime-session-model.md), [0008](../architecture/decisions/0008-fallback-engine-product-semantics.md)
- [Swift 6 Architecture](../architecture/swift6-migration.md)

## Optional Reading

- [RIME Artifacts](../architecture/rime-artifacts.md)
- [DEBUGGING](../DEBUGGING.md)
- [PERFORMANCE_BASELINE](../PERFORMANCE_BASELINE.md)
- [RELEASE_CHECKLIST](../RELEASE_CHECKLIST.md)

## Allowed Files / Areas

- `Packages/RimeBridge/`
- RimeBridge tests/tools/scripts and artifact manifest when explicitly in scope.
- Directly affected architecture/operational sources.

## Forbidden Changes

- Full deployment, maintenance, downloads or repair in Keyboard Extension paths.
- Arbitrary background-thread librime calls.
- Duplicate production bridge sources in app/extension targets.
- Claims that linked Lua or fallback proves real runtime success.

## Common Tasks

- Diagnose/create/recover/select RIME sessions.
- Maintain bridge memory/thread boundaries.
- Verify deployment/session module parity.
- Validate pinned artifacts and contract tests.

## Required Evidence

- Exact session/deployment reproduction and logs.
- RimeBridge contract tests; real fixture/device evidence for runtime claims.
- Artifact receipt/checksum evidence for vendor changes.
- Performance evidence for startup/session/key-path changes.

## Output Format

`Boundary` → `Observed RIME State` → `Bridge Evidence` → `Verification` → `Extension Safety` → `Residual Risk`.

## Handoff Checklist

- [ ] Main App/Extension boundary preserved.
- [ ] Session and deployment are not conflated.
- [ ] Thread/memory ownership stated.
- [ ] Lua/OpenCC claims have runtime evidence.
- [ ] UI/Core follow-up assigned to correct owner.

## Escalation Rules

Stop and hand to Main App UI for deployment orchestration/UX, KeyboardCore for protocol/state semantics, Test/Release for release evidence, or Coordinator for cross-process/user-data strategy decisions.

## Documentation Impact Rules

RIME lifecycle, artifacts, Lua/OpenCC, performance and release changes require review of their linked sources. Long-term session/deployment decisions require ADR review; unresolved safety goes to [TECH_DEBT](../TECH_DEBT.md).
