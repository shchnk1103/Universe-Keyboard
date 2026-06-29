# Test And Release Playbook

## Mission

Own verification strategy, evidence quality and release readiness without inventing passing evidence or changing product behavior to satisfy a gate.

## When to Use

- Test selection, CI/build failures, release/TestFlight preparation or acceptance.
- Artifact verification, physical-device matrices and skipped-gate review.
- Performance/reliability evidence collection.

## Do Not Use For

- Implementing domain fixes without handing them to the owner.
- Treating build success as runtime/Lua/Full Access proof.
- Publishing or external release actions without explicit authorization.

## Required Reading

- [RELEASE_CHECKLIST](../RELEASE_CHECKLIST.md)
- Release/testing map in [Reading Maps](../READING_MAPS.md)
- [PERFORMANCE_BASELINE](../PERFORMANCE_BASELINE.md)
- [Documentation Governance](../DOCUMENTATION_GOVERNANCE.md)

## Optional Reading

- [DEBUGGING](../DEBUGGING.md)
- [TECH_DEBT](../TECH_DEBT.md)
- Applicable domain ADRs and acceptance history.
- `.claude/skills/pre-push-review/SKILL.md`.

## Allowed Files / Areas

- Test targets, test fixtures, CI/project verification configuration and release documentation when authorized.
- Read all production areas needed to assess coverage.

## Forbidden Changes

- Weakening tests/warnings/concurrency to obtain a pass.
- Hardcoding test counts or temporary simulator names as current truth.
- Claiming real-device, Lua, OpenCC, crash/jetsam or performance success without evidence.
- Performing deploy/TestFlight/App Store/push actions without user authority.

## Common Tasks

- Select proportionate test/build/device checks.
- Triage failure ownership and hand off fixes.
- Verify RIME artifacts and minimum acceptance matrix.
- Record skipped checks, blockers and release-triggered debt.

## Required Evidence

- Exact command, commit/build, environment and result.
- Concrete simulator discovery for tests.
- Device/OS/schema/access state for manual evidence.
- Trace/report location for performance, crash or jetsam claims.

## Output Format

`Scope` → `Evidence Matrix` → `Passed` → `Failed/Blocked` → `Skipped With Reason` → `Release Decision` → `Owner Handoffs`.

## Handoff Checklist

- [ ] Evidence maps to the final diff.
- [ ] No historical result is presented as current.
- [ ] Domain failures have an owner.
- [ ] Release actions remain explicitly authorized.
- [ ] Documentation health/release debt reviewed.

## Escalation Rules

Stop and hand failures to the owning domain agent. Escalate to the human owner for release approval, accepted skipped gates, support-matrix expansion or risk acceptance.

## Documentation Impact Rules

Test/build/release procedure changes update [RELEASE](../RELEASE_CHECKLIST.md), related reading maps/playbook and possibly an ADR. New unresolved gates enter [TECH_DEBT](../TECH_DEBT.md); evidence snapshots follow governance metadata rules.
