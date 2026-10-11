# Product Decision: Build 94 公开外部 TestFlight 更新

| Field | Value |
|---|---|
| **Decision ID** | `PD-RELEASE-2026-09-25-BUILD94-PUBLIC-EXTERNAL-TESTFLIGHT` |
| **Lifecycle** | Human Product Owner accepted bounded external-beta risk and authorized execution; not a formal Release Gate Pass |
| **Date / timezone** | `2026-09-25 Asia/Shanghai` |
| **Assignment** | [RELEASE-2026-09-25-BUILD94-EXTERNAL-TESTFLIGHT](../assignments/release-2026-09-25-build94-external-testflight.md) |
**Related precedent:** [Build 55 public external-testing exception](RELEASE-2026-09-13-build55-limited-external-trial-exception-proposal.md)

## Decision and exact candidate

Human Product Owner authorized updating the existing external TestFlight cohort with this exact candidate:

- Xcode Cloud Build ID: `13b91c4a-e672-4c6f-97a7-7867be644082`
- Source commit: `50cdccc8d07e70cb02987c9fe0a17be55291701`
- App Store Connect app ID: `6804236252`; bundle ID: `com.DoubleShy0N.Universe-Keyboard`
- App Store export: `1.0 (94)`; SHA-256: `500105b71b5cf532a32db18032c4c257d672d056955600dc8b2363ac984a772f`
- Archive and dSYM metadata: `1.0 (1)`; app and Keyboard executable UUIDs match the archived dSYMs and exported IPA. This is the accepted TD-005 provenance limitation; the Archive itself is not represented as build 94.

The channel is **external TestFlight only**, by adding the exact processed build to the existing `Build 55 Public Beta` group (group ID `7d76e4b0-e24c-4c2e-a46f-3d14dd9afe16`). Preserve the existing public link and group membership; do not create a new group or link. At preflight, App Store Connect showed 356 testers and the existing link `https://testflight.apple.com/join/t48JR3Q3`. The intended outcome is for existing group members to update through TestFlight after Apple processing and any required Beta App Review. This decision does not authorize App Store release.

## Product risk acceptance and scope

The Human Product Owner's current decision is:

- TD-003 and TD-004 follow the same explicitly bounded public-beta deferral approach used for Build 55. They remain Open. The tester scope requires Full Access enabled and makes no claim about complete Full Access-off/shared-capability recovery behavior.
- TD-005 remains Open. The Archive/dSYM metadata is `1.0 (1)`, while the exported Store IPA is `1.0 (94)`. Matching executable UUIDs establish the recorded code-image relationship but do not erase the metadata difference or classify the existing Jetsam records.
- TYPO-CORRECTION-002 remains Open. Its unclosed behavior and evidence risk is accepted for this beta update; no parent closure or complete correction-quality claim is made.
- Recent Build 55 tester feedback is deferred for triage until `2026-09-26`, as directed by the Product Owner. Deferral does not mark the feedback resolved.

These are candidate-specific Product risk dispositions. They do not close technical debt, modify another thread's ownership, or change the independent Build 94 Quality/Release verdict, which remains **Blocked** because device and human-observation evidence is incomplete.

## Tester instructions

For What to Test, ask testers to:

- Keep Full Access enabled; test Luna 26-key input and the previously bounded 雾凇 nine-key input, including candidate selection and commit.
- Check the recent UI changes: letter/punctuation size, main-App action-button contrast, and the third-party scheme licence-and-download sheet.
- Treat typo correction as under evaluation. Report unexpected behavior with device model, iOS version, scheme, Full Access state and reproduction steps; do not include actual typed content or other private information.
- Report crashes, keyboard exits, freezes, lost input or scheme deployment failures promptly. Do not claim clean-install, performance, crash/Jetsam, or Full Access-off recovery coverage.

## Expiry and stop conditions

This exception expires at the earliest of the Build 94 TestFlight expiry shown by App Store Connect, Product Owner withdrawal, or a stop condition below. Record the displayed expiry in the execution receipt.

Stop distribution and return to Product Owner if the exact candidate identity changes; Apple reports a blocking review/validation issue; a reproducible crash, keyboard exit, hard hang, input loss, unrecoverable scheme failure, or privacy exposure occurs; or the Full Access prerequisite cannot be communicated truthfully.

## Authority and non-claims

This decision records the Human Product Owner's authorization in the current Codex task on `2026-09-25 Asia/Shanghai`, including the explicit acceptance of TD-005 and TYPO-CORRECTION-002 risk and direction to follow Build 55's TD-003/TD-004 deferral boundary. No source code changes are authorized by this decision. It authorizes the scoped upload, existing-group assignment, any required Beta App Review submission, and notification of that existing TestFlight group after Apple makes the build distributable.

It does **not** authorize or claim a production App Store release, an independent Quality Pass, a Product Gate Pass, closure of TD-003/004/005 or TYPO-CORRECTION-002, or resolution of Build 55 feedback.
