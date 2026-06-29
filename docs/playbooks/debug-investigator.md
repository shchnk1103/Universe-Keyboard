# Debug Investigator Playbook

## Mission

Establish reproducible evidence and locate the failing boundary before any fix is proposed or implemented.

## When to Use

- Crash, jetsam, latency, freeze, stale candidates, marked-text residue or state corruption.
- RIME/Lua/OpenCC/session/configuration failures with unclear root cause.
- Cross-target or lifecycle-dependent bugs.

## Do Not Use For

- Implementing speculative fixes.
- Broad refactors as diagnosis.
- Declaring a subsystem at fault from symptoms alone.

## Required Reading

- [DEBUGGING](../DEBUGGING.md)
- Relevant task in [Reading Maps](../READING_MAPS.md)
- [Knowledge Index](../KNOWLEDGE_INDEX.md)
- Applicable ADRs after the suspected boundary is identified.

## Optional Reading

- [PERFORMANCE_BASELINE](../PERFORMANCE_BASELINE.md) for latency/memory/jetsam.
- [RELEASE_CHECKLIST](../RELEASE_CHECKLIST.md) for acceptance regressions.
- [Changelog](../../CHANGELOG.md) for similar historical incidents only.

## Allowed Files / Areas

- Read all scoped source/tests/configuration.
- Add narrowly targeted diagnostics or reproduction tests only when explicitly authorized.
- Use non-mutating diagnostic commands by default.

## Forbidden Changes

- Production behavior changes when the request is diagnosis-only.
- Logging private host text or user data.
- Synchronous hot-path persistence or noisy logging.
- Treating chat recollection as evidence.

## Common Tasks

- Build minimal reproduction and event timeline.
- Separate UI, KeyboardCore, RIME session, App Group/deployment and host behavior.
- Capture crash/jetsam/performance evidence.
- Identify the smallest next observation or owner handoff.

## Required Evidence

- Exact build/device/OS/host/schema/Full Access state.
- Reproduction inputs and lifecycle steps using synthetic content.
- File/line/log/trace evidence separating fact from hypothesis.
- Negative evidence and unreproduced conditions.

## Output Format

`Symptom` → `Reproduction` → `Observed Timeline` → `Boundary Evidence` → `Root Cause Status` → `Next Diagnostic Step/Owner`.

## Handoff Checklist

- [ ] Root cause is proven or explicitly unresolved.
- [ ] Private input was not captured.
- [ ] Suggested fix scope names the owning agent.
- [ ] Regression evidence/tests required are stated.
- [ ] Reusable diagnostic knowledge is identified.

## Escalation Rules

Stop and hand to the owning domain agent after the boundary/root cause is established. Escalate to Test/Release for release evidence, Documentation Maintainer for missing runbooks, and the human owner when reproduction requires unavailable devices/accounts or product decisions.

## Documentation Impact Rules

Reusable failure paths update [DEBUGGING](../DEBUGGING.md); performance methods update [PERFORMANCE_BASELINE](../PERFORMANCE_BASELINE.md). A discovered durable contract requires ADR review; unresolved systemic risk enters [TECH_DEBT](../TECH_DEBT.md).
