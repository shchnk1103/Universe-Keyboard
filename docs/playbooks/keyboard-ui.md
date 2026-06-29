# Keyboard UI Playbook

## Mission

Own UIKit keyboard presentation, candidate views, layouts, gestures, feedback and accessibility while delegating business semantics to KeyboardCore.

## When to Use

- Files under `Keyboard/Controllers`, `Keyboard/Views`, `Keyboard/Services` or `Keyboard/Bridge`.
- CandidateBar/expanded panel, keys, gestures, layout or accessibility.
- Extension presentation lifecycle integration after the contract is already defined.

## Do Not Use For

- Redefining KeyboardCore state semantics.
- Implementing librime deployment/session internals.
- Main-App SwiftUI settings.

## Required Reading

- UI task in [Reading Maps](../READING_MAPS.md)
- [Project Context](../PROJECT_CONTEXT.md)
- [UI Style Guide](../UI_STYLE_GUIDE.md)
- [Input Pipeline](../architecture/input-pipeline-and-marked-text.md) when input/candidates are affected

## Optional Reading

- ADR [0002](../architecture/decisions/0002-visibility-change-abandons-composition.md), [0004](../architecture/decisions/0004-rime-runtime-session-model.md), [0008](../architecture/decisions/0008-fallback-engine-product-semantics.md)
- [DEBUGGING](../DEBUGGING.md)
- [RELEASE_CHECKLIST](../RELEASE_CHECKLIST.md)

## Allowed Files / Areas

- `Keyboard/`
- `KeyboardTests/`
- UI documentation directly affected by authorized changes.

## Forbidden Changes

- Full RIME deployment or schema repair from the Extension.
- Business state stored in views/accessibility metadata.
- Restoring stale composition across visibility changes.
- Bypassing marked-text/fallback ADRs or putting heavy I/O in key handling.

## Common Tasks

- Candidate rendering/paging/selection presentation.
- Key construction, layout, gesture and feedback behavior.
- Lifecycle cleanup wiring and accessibility fixes.
- Thin translation from UI events to KeyboardAction/effects.

## Required Evidence

- Simulator build and focused UI/contract tests.
- Physical-device evidence for interaction, lifecycle, marked text, performance or system-keyboard behavior claims.
- Light/dark, VoiceOver and Dynamic Type review where relevant.

## Output Format

`User Interaction` → `UI Files` → `Delegated Action/Effect` → `Visual/Device Evidence` → `Regression Risk`.

## Handoff Checklist

- [ ] Core semantics remain outside UIKit.
- [ ] RIME deployment boundary preserved.
- [ ] Lifecycle/marked-text ADRs respected.
- [ ] Accessibility and device checks reported.
- [ ] Core/bridge changes handed to their owner.

## Escalation Rules

Stop and hand to KeyboardCore when state/action semantics must change, RimeBridge when real engine behavior is the cause, Debug Investigator when evidence is insufficient, or Coordinator when UI requests alter a durable product contract.

## Documentation Impact Rules

Review UI guide, input architecture, [DEBUGGING](../DEBUGGING.md) and [RELEASE](../RELEASE_CHECKLIST.md) based on impact. Lifecycle/fallback/product changes require ADR review under [Governance](../DOCUMENTATION_GOVERNANCE.md).
