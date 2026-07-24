# Main App UI Playbook

## Mission

Own SwiftUI onboarding, settings, diagnostics and main-App orchestration surfaces without leaking work into the Extension input path.

## When to Use

- `Universe Keyboard/Views`, app shell or main-App state/store UI.
- Scheme settings, deployment feedback, user-dictionary UI, diagnostics or Full Access guidance.
- Main-App-owned download/install/deploy workflows when UI coordination is in scope.

## Do Not Use For

- Keyboard Extension UI.
- KeyboardCore input semantics.
- RimeBridge internals not required by the UI contract.

## Required Reading

- Main-App/UI tasks in [Reading Maps](../READING_MAPS.md)
- [Project Context](../PROJECT_CONTEXT.md)
- [UI Style Guide](../UI_STYLE_GUIDE.md)
- Applicable domain source such as [Scheme Management](../RIME_SCHEME_MANAGEMENT.md) or [User Dictionary](../RIME_USER_DICTIONARY.md)

## Optional Reading

- ADR [0001](../architecture/decisions/0001-main-app-owns-rime-deployment.md), [0003](../architecture/decisions/0003-shared-container-ownership.md), [0005](../architecture/decisions/0005-user-dictionary-restore-safety.md), [0006](../architecture/decisions/0006-schema-install-transaction-model.md), [0007](../architecture/decisions/0007-full-access-and-privacy-boundary.md)
- [TECH_DEBT](../TECH_DEBT.md)
- [DEBUGGING](../DEBUGGING.md)

## Allowed Files / Areas

- `Universe Keyboard/`
- `UniverseKeyboardTests/`
- Main-App domain documents affected by authorized work.

## Forbidden Changes

- Moving deployment/download/backup work into the Extension.
- Claiming pre-restore safety, atomic schema install or Full Access degradation is implemented when it remains debt.
- Silent overwrite of user data.
- Uploading typed content, dictionaries, logs or correction-learning data.

## Common Tasks

- Settings/status/navigation and reusable components under `Views/Components/` (`AppTokens`, `AppCard`, `SettingsGroup`, `EmptyStateView`, `MetricCell`, `KeyValueRow`, `LoadingStateView`, `SettingsNavigationLink`, `AppIconTile`, `AppMotion`, …). Prefer these over new private chrome or raw padding/radius numbers.
- Scheme operation feedback and duplicate-action protection.
- Diagnostics presentation and recovery guidance.
- Main-App user-data/deployment workflow coordination.

## Required Evidence

- Store/model tests and Simulator build.
- State transition evidence for loading/success/failure.
- Physical-device evidence for Full Access or cross-target behavior.
- Explicit user-data failure/recovery analysis.

## Output Format

`User Goal` → `Main-App State` → `Side Effects` → `UI Feedback` → `Tests` → `Unimplemented Debt`.

## Handoff Checklist

- [ ] Side effects remain main-App-owned.
- [ ] User data is protected and limitations are explicit.
- [ ] Full Access status is not guessed from an unreliable signal.
- [ ] Extension/Core/Bridge work is handed to the correct owner.

## Escalation Rules

Stop and ask the human owner before destructive/irreversible user-data behavior or product-copy decisions with privacy implications. Hand bridge/runtime issues to RimeBridge and input semantics to KeyboardCore.

## Documentation Impact Rules

User data, Full Access, schema install/deploy or recovery changes must review applicable ADRs, [DEBUGGING](../DEBUGGING.md), [RELEASE](../RELEASE_CHECKLIST.md) and [TECH_DEBT](../TECH_DEBT.md). Durable contracts require ADR review.
