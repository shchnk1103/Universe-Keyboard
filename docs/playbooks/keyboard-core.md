# KeyboardCore Playbook

## Mission

Own testable input/state logic in `Packages/KeyboardCore` while preserving UI, RIME and persistence boundaries.

## When to Use

- `KeyboardAction`, `KeyboardState`, `KeyboardEffect` or pure input semantics.
- Candidate models, typo correction, Partial Commit or pure configuration processing.
- Focused KeyboardCore tests.

## Do Not Use For

- UIKit layout/gesture implementation.
- librime/ObjC session implementation.
- Main-App downloads, file orchestration or deployment UI.

## Required Reading

- [Knowledge Index](../KNOWLEDGE_INDEX.md)
- Relevant task in [Reading Maps](../READING_MAPS.md)
- [Project Context](../PROJECT_CONTEXT.md)
- [Input Pipeline](../architecture/input-pipeline-and-marked-text.md) when editing input semantics

## Optional Reading

- [Partial Commit](../architecture/partial-commit.md)
- [Typo Benchmark](../TYPO_BENCHMARK.md)
- ADR [0002](../architecture/decisions/0002-visibility-change-abandons-composition.md) and [0004](../architecture/decisions/0004-rime-runtime-session-model.md)
- `.claude/skills/keyboard-test-writer/` references.

## Allowed Files / Areas

- `Packages/KeyboardCore/Sources/KeyboardCore/`
- `Packages/KeyboardCore/Tests/KeyboardCoreTests/`
- Directly affected domain documentation when authorized.

## Forbidden Changes

- Adding UIKit/AppKit dependencies to KeyboardCore.
- Moving deployment, network or heavy filesystem work into input logic.
- Bypassing Swift 6 isolation with unsafe annotations.
- Changing lifecycle, marked-text or product contracts without ADR review.

## Common Tasks

- Add/fix state transitions and effects.
- Preserve raw-input/display-preedit separation.
- Add regression tests around candidate, Delete, Space, Return and restore behavior.
- Keep experimental correction behavior explicitly gated.

## Required Evidence

- Failing/passing focused tests and relevant full package result.
- Before/after state/action/effect examples.
- Source evidence for any cross-layer assumption.

## Output Format

`Behavior` → `State Invariant` → `Files` → `Tests` → `Cross-layer Risks` → `Documentation Impact`.

## Handoff Checklist

- [ ] Logic remains UI-independent.
- [ ] RIME assumptions remain protocol-level.
- [ ] Tests cover regression and boundary cases.
- [ ] Required UI/bridge follow-up is assigned, not implemented opportunistically.

## Escalation Rules

Stop and hand to Keyboard UI for rendering/gesture issues, RimeBridge for real session semantics, Main App UI for persistence/deployment, or Coordinator when the requested behavior changes a durable product contract.

## Documentation Impact Rules

Review [Governance](../DOCUMENTATION_GOVERNANCE.md). Changes to marked text/actions review input architecture, [DEBUGGING](../DEBUGGING.md) and [RELEASE](../RELEASE_CHECKLIST.md); durable contracts require ADR review.
