# Swift 6 Migration Architecture

## Build Contract

- The main app and keyboard extension build with `SWIFT_VERSION = 6.0` and complete strict concurrency checking.
- App, extension and Xcode test targets enable warnings-as-errors in their target build settings. SwiftPM
  dependencies are validated by package tests and build diagnostics because Xcode builds dependency targets with
  its own warning-suppression option.
- The main SwiftUI app and keyboard extension use default `MainActor` isolation for UI and input coordination.
- `KeyboardCore` and `RimeBridge` do not apply global default actor isolation; package boundaries are isolated
  explicitly according to state ownership.

## Ownership Boundaries

| Boundary | Owner | Rule |
| --- | --- | --- |
| Key presentation, document proxy, delete repeat, candidate button creation | Keyboard UI | Main actor only |
| Key click audio players | `KeyClickPlayer` actor | No mutable player crosses isolation |
| RIME input session | `RimeBridge.RimeEngineImpl` | Called synchronously by the keyboard input path; session operations only |
| Full schema deployment | `RimeDeploymentService` actor | Called from the main app before keyboard use, never from the extension or input path |
| Settings and dictionary observable state | Main app Observation models | UI updates on main actor |

`KeyboardCore.KeyboardController` keeps state ownership and its public action entry point in one small type. Text
editing, mode/shift handling, candidate operations and RIME recovery live in dedicated extension files so changes to
latency-sensitive recovery code can be reviewed separately from ordinary text semantics.

## RIME Consolidation

`Packages/RimeBridge` is the single production bridge module. It owns the Swift session engine, configuration
preparation, deployment service, ObjC bridge and C header. App and extension targets import the package; they must
not add direct RIME bridge implementations back to their own source trees.

Lua registration remains force-loaded by the keyboard target while the binary artifacts are packaged as SwiftPM
binary dependencies. This is deliberate: static plugin registration must not be dead stripped.

Full deployment is an App-owned prerequisite for using changed schemas or settings. Once the user switches to the
keyboard, `processKey()` handles input against the available session only: it must not generate configuration files,
run maintenance or trigger deployment. The extension may rebuild or recover a lost session at runtime, but it must
never perform a fallback full deployment. If deployed data is unavailable or stale, the user returns to the App to
complete deployment before continuing with the updated configuration.

## Regression Invariants

- Do not override `loadView` in `UIInputViewController`.
- Preserve current key and candidate geometry: candidate bar 44 pt, key height 44 pt, vertical spacing 8 pt,
  horizontal spacing 6 pt and corner radius 9 pt.
- Candidate preloading/paging must call the engine directly and restore page state; it must not replace
  `KeyboardController.state.lastRimeOutput`, which represents first-page selection semantics.
- Space selection, candidate commit and reset paths must leave the RIME session clean.
- Full deployment and configuration file synchronization must finish in the App; `processKey()` and all extension
  recovery paths remain free of full deployment and blocking file work.
- Keep latency and engine diagnostic logging for rapid typing; never log committed user text.

## Verification

```bash
bash scripts/ensure_rime_vendor.sh verify
swift test --package-path Packages/KeyboardCore
xcodebuild -project "Universe Keyboard.xcodeproj" -scheme "RimeBridgeTests" \
  -configuration Debug -destination 'platform=iOS Simulator,name=<installed device>' \
  CODE_SIGNING_ALLOWED=NO SWIFT_STRICT_CONCURRENCY=complete \
  SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES test
xcodebuild -project "Universe Keyboard.xcodeproj" -scheme "Universe Keyboard" \
  -configuration Debug -destination 'platform=iOS Simulator,name=<installed device>' \
  CODE_SIGNING_ALLOWED=NO SWIFT_STRICT_CONCURRENCY=complete \
  SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES test
xcodebuild -project "Universe Keyboard.xcodeproj" -scheme "Universe Keyboard" \
  -configuration Debug -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO SWIFT_STRICT_CONCURRENCY=complete \
  SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES build
xcodebuild -project "Universe Keyboard.xcodeproj" -scheme "Universe Keyboard" \
  -configuration Release -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO SWIFT_STRICT_CONCURRENCY=complete \
  SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES build
```

Replace `<installed device>` with a destination reported by `xcrun simctl list devices available`. Builds use the generic Simulator destination; tests require a concrete bootable destination.

The binary RIME package is iOS-only, so its tests must run through `RimeBridgeTests` on Simulator rather than
macOS `swift test`. CI repeats artifact preparation, changed-file formatting checks, `KeyboardCore` tests, the
Simulator bridge tests, app/keyboard contract tests and explicit Swift 6 Debug/Release app/extension builds.
