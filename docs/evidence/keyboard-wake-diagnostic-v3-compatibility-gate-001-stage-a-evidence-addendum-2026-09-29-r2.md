# Stage A Evidence Addendum — V3 Compatibility Gate 001

This addendum supplements, and does not rewrite, the frozen Stage A host-validation record (`keyboard-wake-diagnostic-v3-compatibility-gate-001-stage-a-host-validation-2026-09-29.md`).

## Identity

- Assignment: `KEYBOARD-WAKE-DIAGNOSTIC-V3-COMPATIBILITY-GATE-001`
- Assignment SHA-256: `8a74c6587dab0b65799fe3cdad4ad9b0362a927e26474a8d2da4c5325c198586`
- Exact source base / HEAD: `84b9c19227330b0fe6ff391be001ee398010fd6a`
- Source/test manifest SHA-256: `32d8a402f9a683348b6ef3395156112491d10aeead74ad61fb89e41d0d7edb7c`
- Stage A host-validation record SHA-256: `f19795c74fad5099a5483502d285dcd816f8d8177c98a852732f0f551ee10028`
- Scope of this addendum: preserve raw command and exit evidence requested by Quality R5; no source/test file changed.

## Strict Swift format lint

Command recorded in [the lint log](keyboard-wake-diagnostic-v3-compatibility-gate-001-swift-format-lint-2026-09-29.log):

```text
xcrun swift-format lint --strict --configuration .swift-format Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEvent.swift Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournal.swift Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEventWireValidator.swift Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticEventTests.swift Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticsJournalTests.swift "Universe Keyboard/Views/Diagnostics/DiagnosticsLogSource.swift" UniverseKeyboardTests/DiagnosticsLogSourceTests.swift
```

- Exit code: `0`
- Log SHA-256: `a2df4fc4322b02db0cc690119989d28505c7a8bec2f3ba8c0071e00b0659ede0`
- Coverage: all seven Swift files in the frozen source/test manifest.

## Pinned RIME vendor verification

Command recorded in [the vendor verification log](keyboard-wake-diagnostic-v3-compatibility-gate-001-rime-vendor-verify-2026-09-29.log):

```text
bash scripts/ensure_rime_vendor.sh verify
```

- Exit code: `0`
- Log SHA-256: `d1449e3e11adc00522c65995c1a594620d34657cea793f7db5172b5ba0eaf8eb`
- Output: 12 pinned RIME framework artifacts passed structural inventory verification.
- Pinned version: `rime-vendor-ios-1.16.1-lua.1-octagram.1`
- Pinned archive SHA-256: `d17aab9a8b08b5901ab583c143b0a8a03994e36fe092309fd14c5bee31399dd9`
- The local receipt matched the pinned manifest. Vendor files remain ignored local dependencies in this isolated worktree.

## Remaining boundary

This addendum covers only Stage A host-side evidence. It records no `xcodebuild`, Simulator, app install/launch, production marker promotion, or manual Maps reproduction. The full Simulator-backed CI-equivalent matrix remains pending a fresh exclusive reservation for one exact model, iOS runtime, and UDID.

These results are engineering evidence only; they do not establish runtime behavior, root cause, a Product/Quality Gate, Release readiness, or parent Assignment closure.
