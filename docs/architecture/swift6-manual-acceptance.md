# Swift 6 Migration Acceptance Record

## Purpose

This record separates reproducible automated evidence from validation that must be performed with the keyboard
enabled as a real system keyboard. It must be updated before the Swift 6 migration is considered complete.

The hard product boundary is:

- Full RIME/schema deployment is completed in the main App before keyboard use.
- After deployment, the Keyboard Extension opens the available runtime session and handles input only.
- No result may be marked passed if it was inferred from a build, unit test, or code review rather than observed in
  the required environment.

## Automated Evidence

The following evidence was executed against the integrated migration worktree. Only results with completed
execution evidence are marked passed here.

| Scope | Command or Target | Result | Evidence Status | Notes |
| --- | --- | --- | --- | --- |
| `KeyboardCore` package | `swift test --package-path Packages/KeyboardCore` | 347 tests passed, 0 failed after Logger/actor integration | Passed | Executed outside the filesystem sandbox because SwiftPM manifest sandboxing is blocked in the contained environment. |
| RIME/Lua artifact provenance | `bash scripts/ensure_rime_vendor.sh fetch && verify` | Fixed Release downloaded, 11 frameworks verified, receipt matches SHA-256 | Passed | `rime-vendor-ios-1.16.1-lua.1`, SHA-256 `c299f36eae4966a8c22f83046c7015a04b3f047abcc4bab9355ca19ac840436c`. |
| `RimeBridgeTests` simulator scheme | `RimeBridgeTests`, Debug, iOS Simulator, strict warnings | 7 tests passed, 0 failed, 0 warnings | Passed | Rerun on 2026-05-28 using iPhone 17 simulator; includes keycode/deployment-boundary contracts; this is not a real Lua schema smoke test. |
| App and Keyboard contract tests | `Universe Keyboard`, Debug, iOS Simulator, strict warnings | 23 tests passed, 0 failed, 0 warnings | Passed | Rerun on the integrated worktree on 2026-05-28; includes app services, dictionary actor, and candidate paging contracts. |
| App and Keyboard Swift 6 Debug build | `Universe Keyboard`, Debug, iOS Simulator, strict warnings | Build passed, 0 warnings, 0 errors | Passed | Covered by the 2026-05-28 strict test build using iPhone 17 simulator. |
| App and Keyboard Swift 6 Release build | `Universe Keyboard`, Release, iOS Simulator, strict warnings | Build passed, 0 warnings, 0 errors | Passed | Rerun on the integrated worktree on 2026-05-28 using iPhone 17 simulator and an isolated DerivedData path. |

### Final Automated Verification Template

Fill this table from the final integrated worktree. Attach or reference logs where available.

| Date and Time | Git Commit / Worktree State | Xcode and Simulator | Verification Command | Result | Log or Evidence Path | Recorded By |
| --- | --- | --- | --- | --- | --- | --- |
| 2026-05-28 18:43 Asia/Shanghai | `codex/swift6-enterprise-migration` integrated worktree | Xcode 17 toolchain; local macOS SwiftPM | `swift test --package-path Packages/KeyboardCore` | PASS, 347 tests | Terminal output from this verification run | Codex |
| 2026-05-28 18:44 Asia/Shanghai | `codex/swift6-enterprise-migration` integrated worktree | Xcode 17 toolchain; iPhone 17 simulator, iOS 26.5 runtime | `RimeBridgeTests` Debug test with Swift 6 strict warnings-as-errors | PASS, 7 tests | `/tmp/universe-keyboard-final-verify/Logs/Test/Test-RimeBridgeTests-2026.05.28_18-43-59-+0800.xcresult` | Codex |
| 2026-05-28 18:45 Asia/Shanghai | `codex/swift6-enterprise-migration` integrated worktree | Xcode 17 toolchain; iPhone 17 simulator, iOS 26.5 runtime | `Universe Keyboard` Debug test with Swift 6 strict warnings-as-errors | PASS, 23 tests | `/tmp/universe-keyboard-final-verify/Logs/Test/Test-Universe Keyboard-2026.05.28_18-44-50-+0800.xcresult` | Codex |
| 2026-05-28 18:46 Asia/Shanghai | `codex/swift6-enterprise-migration` integrated worktree | Xcode 17 toolchain; iPhone 17 simulator, iOS 26.5 runtime | `Universe Keyboard` Release build with Swift 6 strict warnings-as-errors | PASS | Terminal output from isolated `/private/tmp/universe-keyboard-final-release-verify` build | Codex |

## Real System Keyboard Acceptance Matrix

These checks cannot be satisfied by package tests or simulator builds alone. They require the extension to be
enabled as a system keyboard and exercised in a real text entry workflow. Rows marked as user-reported evidence were
observed on a physical device by the project owner and should be supplemented with screenshots or logs before release
tagging when practical.

| Scenario | Procedure | Acceptance Criteria | Status | Evidence |
| --- | --- | --- | --- | --- |
| First keyboard presentation | Enable the keyboard, focus a text field, and open the keyboard for the first time after App deployment. | No height jump, flicker, candidate bar displacement, or visible initialization stall. | Passed by user report | Physical device smoke test on 2026-05-28 reported no observed issue. Add screenshot or recording before release tagging if available. |
| Rapid continuous typing | Type long text rapidly using the deployed schema. | Input remains responsive; no freeze; diagnostics contain timing/state events without actual entered text. | Passed by user report | Physical device smoke test on 2026-05-28 reported no observed issue. Add diagnostic export reference before release tagging if available. |
| Repeated delete | Long-press delete and perform repeated deletions after composing text and candidates. | No timer leak, stuck repeat, UI freeze, or inconsistent composition/session state. | Passed by user report | Physical device smoke test on 2026-05-28 reported no observed issue. |
| App deployment then keyboard use | In the App install/update/select a schema and complete deployment, then switch immediately to a text field. | Updated schema is usable immediately; keyboard does not require typing to start deployment and does not show stale configuration. | Passed by user report | Physical device smoke test on 2026-05-28 reported no observed issue. This directly validates the App-deploy-before-typing boundary. |
| Schema switching and recovery | Switch schema in the App, deploy, then test after changing apps and returning to input. | Session recovers correctly and uses the deployed schema without performing full deployment in the extension. | Passed by user report | Physical device smoke test on 2026-05-28 reported no observed issue. Record exact schemas before release tagging if available. |
| Lua-enabled schema smoke test | Deploy an available schema that relies on Lua capability and exercise the Lua-specific input path. | Expected Lua behavior works using the verified packaged artifacts, or failure is documented before capability is advertised. | Not run | Record artifact version, schema, test input class, and result without retaining private entered text. |
| VoiceOver | Enable VoiceOver and navigate functional keys and candidate controls. | Labels, hints, and state/value announcements are meaningful for shift, delete, globe/mode, space, return, and candidate expand/collapse controls. | Not run | Record device and any missing announcement. |
| Dynamic Type | Increase text size and inspect App settings and diagnostics screens. | App screens remain usable and legible; the keyboard's fixed interaction geometry is not changed by this validation. | Not run | Capture affected screens at tested setting. |
| Light and dark appearance | Compare keyboard after deployment in light and dark appearances. | Contrast is readable and stable keyboard geometry matches the migration baseline. | Not run | Save paired screenshots. |

### Session: 2026-05-28 Asia/Shanghai

- Tester: Project owner
- Build or commit: `codex/swift6-enterprise-migration` integrated migration worktree
- Device / OS: Physical iPhone; exact model and OS not recorded
- Keyboard enabled as system keyboard: Yes
- RIME artifact version and checksum receipt: `rime-vendor-ios-1.16.1-lua.1`,
  `c299f36eae4966a8c22f83046c7015a04b3f047abcc4bab9355ca19ac840436c`
- Schema(s) tested: Not recorded
- Appearance and accessibility settings: Not recorded

| Scenario | Result (`PASS` / `FAIL` / `BLOCKED`) | Observation | Evidence Path |
| --- | --- | --- | --- |
| First keyboard presentation | PASS | User reported no observed issue during physical-device testing. | User report in project thread |
| Rapid continuous typing | PASS | User reported no observed issue during physical-device testing. | User report in project thread |
| Repeated delete | PASS | User reported no observed issue during physical-device testing. | User report in project thread |
| App deployment then keyboard use | PASS | User reported no observed issue; this confirms deployment is not deferred until typing in the tested flow. | User report in project thread |
| Schema switching and recovery | PASS | User reported no observed issue during physical-device testing. | User report in project thread |
| Lua-enabled schema smoke test | BLOCKED | Not explicitly covered by the reported test scope. | None |
| VoiceOver | BLOCKED | Not explicitly covered by the reported test scope. | None |
| Dynamic Type | BLOCKED | Not explicitly covered by the reported test scope. | None |
| Light and dark appearance | BLOCKED | Not explicitly covered by the reported test scope. | None |

#### Issues Found

- None reported in the physical-device smoke test.

#### Diagnostic Privacy Check

- Confirmed diagnostics contain timing/count/state metadata only and do not retain actual entered text: not rechecked
  during this device session; covered by code review and automated contract boundaries.

## Manual Execution Record Template

Create one entry per testing session. Do not mark a matrix row passed without a matching execution entry.

```markdown
### Session: YYYY-MM-DD HH:mm TZ

- Tester:
- Build or commit:
- Device / OS:
- App version:
- Keyboard enabled as system keyboard: Yes / No
- RIME artifact version and checksum receipt:
- Schema(s) tested:
- Appearance and accessibility settings:

| Scenario | Result (`PASS` / `FAIL` / `BLOCKED`) | Observation | Evidence Path |
| --- | --- | --- | --- |
| First keyboard presentation |  |  |  |
| Rapid continuous typing |  |  |  |
| Repeated delete |  |  |  |
| App deployment then keyboard use |  |  |  |
| Schema switching and recovery |  |  |  |
| Lua-enabled schema smoke test |  |  |  |
| VoiceOver |  |  |  |
| Dynamic Type |  |  |  |
| Light and dark appearance |  |  |  |

#### Issues Found

- `<issue identifier or none>`

#### Diagnostic Privacy Check

- Confirmed diagnostics contain timing/count/state metadata only and do not retain actual entered text: Yes / No
```

## Acceptance Gate

The migration is ready for release review only after:

1. The App/Keyboard Debug test and Release build rows remain passing on the integrated worktree used for release.
2. Every required real system keyboard scenario has a recorded outcome, with blockers or failures resolved or
   explicitly accepted outside this document.
3. Lua-facing user documentation is consistent with the recorded Lua smoke-test result and verified binary
   artifact receipt.
