# RELEASE-2026-0801-03 — Implementation Handoff

**Date:** `2026-07-20 Asia/Shanghai`  
**Lifecycle at handoff:** `Active — main-App implementation delivered; physical-device Exit pending`  
**Executor:** Grok session as App & Data Operations Maintainer  
**Handoff target:** Quality Reviewer, then Human Environment Executor / Product Lead

## Delivered

| Output | Path / evidence |
|---|---|
| Product Decision | `docs/product-decisions/RELEASE-2026-0801-03-activation-authorization.md` |
| Journey / copy / matrix source | `docs/ONBOARDING_ACTIVATION.md` |
| Assignment roles + Active lifecycle | `docs/assignments/release-2026-08-01-03-onboarding-full-access.md` |
| Pure checklist state | `Universe Keyboard/Models/ActivationChecklistState.swift` |
| Guide activation UI | `Universe Keyboard/Views/Guide/GuideTab.swift` |
| Unit tests | `UniverseKeyboardTests/ActivationChecklistStateTests.swift` |

## Automated evidence

- Command:

```bash
xcodebuild -project "Universe Keyboard.xcodeproj" -scheme "Universe Keyboard" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' \
  -only-testing:UniverseKeyboardTests/ActivationChecklistStateTests test
```

- Result: **TEST SUCCEEDED** — `ActivationChecklistStateTests` 6/6 passed.
- Simulator: iPhone 17 Pro / iOS 26.5
- Branch: `feature/release-2026-08-01-03-onboarding` (based on release-control `17116a3`)

## Architecture notes

- No ADR change: implementation stays within ADR 0007/0008 presentation requirements.
- Main App does not invent a live Extension Full Access boolean.
- User affirmations are weak and can be overturned by `sharedDataUnavailable`.
- TipKit is documented only as a future presentation layer.

## Residual Exit Criteria (not claimed)

1. Physical-device Full Access **off**: basic typing usable; shared capabilities not falsely active.
2. Physical-device Full Access **on**: shared RIME / settings path works after deploy.
3. Fresh-install activation path screenshots / VoiceOver pass.
4. Independent Quality conclusion and Product Gate.
5. TD-004 remains open until device matrix evidence exists.

## Known limitations

- “打开设置” uses root app Settings URL; iOS does not guarantee deep-link into Keyboard → Keyboards.
- Prepare-resources step points users to the Settings tab deploy area; Guide does not embed full deploy orchestration.
- First-input success is user-affirmed in V1, not auto-detected from the Extension.
- Extension-visible degraded chrome beyond existing fallback semantics is out of this handoff’s code change set.

## Requested next owners

1. **Quality:** review unit evidence, build Guide on Simulator, confirm copy does not overclaim.
2. **Human Environment Executor:** run FA on/off matrix on a physical device and attach evidence to the release ledger.
3. **Product Lead:** Product Gate only after device Exit evidence.
