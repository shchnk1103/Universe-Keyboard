# ENV-TOOLING-001 Quality Rework R1 Evidence

> Collection date: 2026-07-03 Asia/Shanghai
>
> Q-SHP revalidation date: 2026-07-07 Asia/Shanghai
>
> Baseline: `74c8ff3b578b4b28d831bf63df914ee6c3093165`
>
> Branch: `codex/env-tooling-001`
>
> Scope: Capability and shipping-boundary verification only. This is not 004C-R1, Benchmark or Task 7 evidence.

## Capability Verification

| Check | Result | Evidence |
|---|---|---|
| Focused tests | Passed | `swift test` in `Packages/EnvironmentDigestTool`; all executed tests passed |
| Tool Release build | Passed | `swift build -c release` in `Packages/EnvironmentDigestTool` |
| Swift format lint | Passed | `swift format lint --recursive Sources Tests Package.swift` |
| Static shipping target membership | Passed | No `EnvironmentDigestTool` or `EnvironmentDigest` reference in the Xcode project, `Packages/RimeBridge/Package.swift` or `Packages/KeyboardCore/Package.swift` |

The focused suite covers the frozen exclusion patterns, unsupported nested lookalikes, excluded-item metadata
privacy, canonical JSON escaping, LF/BOM, Unicode normalization collision, case preservation, provenance artifacts,
failure artifacts, complete inventory mutation detection and `custom_phrase.txt` approval provenance.

## Dynamic Main App / Extension / RimeBridge Release Graph

**Result: Passed.**

RIME-ENV-001 Environment Review has been accepted, and the restored local `Packages/RimeBridge/Vendor/`
environment was applied to this isolated worktree as ignored verification state. No artifact restoration was rerun and
no implementation files were changed for this revalidation.

### Source And Target Membership

| Check | Timestamp | Exit status | Evidence |
|---|---:|---:|---|
| `rg -n 'EnvironmentDigest\|EnvironmentDigestTool\|EnvironmentDigester\|EnvironmentDigestCLI' 'Universe Keyboard.xcodeproj' 'Universe Keyboard' Keyboard Packages/RimeBridge Packages/KeyboardCore --glob '!Packages/RimeBridge/Vendor/**'` | `2026-07-07T12:35:44Z` | 1 | No matches; shipping project, Main App, Keyboard Extension, RimeBridge and KeyboardCore do not reference the capability |

### Release Builds

| Matrix ID | Release graph | Exact command | Timestamp | Exit status | Result |
|---|---|---|---:|---:|---|
| `Q-SHP-002` | Main App | `xcodebuild -project 'Universe Keyboard.xcodeproj' -scheme 'Universe Keyboard' -configuration Release -destination 'generic/platform=iOS Simulator' -derivedDataPath /private/tmp/env-tooling-001-q-shp-002-mainapp CODE_SIGNING_ALLOWED=NO ARCHS=arm64 ONLY_ACTIVE_ARCH=YES build` | `2026-07-07T12:36:58Z` to `2026-07-07T12:37:35Z` | 0 | Passed; Release build succeeded |
| `Q-SHP-003` | Keyboard Extension | `xcodebuild -project 'Universe Keyboard.xcodeproj' -scheme 'Keyboard' -configuration Release -destination 'generic/platform=iOS Simulator' -derivedDataPath /private/tmp/env-tooling-001-q-shp-003-keyboard CODE_SIGNING_ALLOWED=NO ARCHS=arm64 ONLY_ACTIVE_ARCH=YES build` | `2026-07-07T12:37:48Z` to `2026-07-07T12:38:22Z` | 0 | Passed; Release build succeeded |
| `Q-SHP-004` | RimeBridge | `xcodebuild -project 'Universe Keyboard.xcodeproj' -scheme 'RimeBridge' -configuration Release -destination 'generic/platform=iOS Simulator' -derivedDataPath /private/tmp/env-tooling-001-q-shp-004-rimebridge CODE_SIGNING_ALLOWED=NO ARCHS=arm64 ONLY_ACTIVE_ARCH=YES build` | `2026-07-07T12:38:35Z` to `2026-07-07T12:38:47Z` | 0 | Passed; Release build succeeded |

### Product Inspection

| Matrix ID | Inspection | Timestamp | Raw exit status | Interpreted result |
|---|---|---:|---:|---|
| `Q-SHP-002` | Main App product resource scan, `strings` scan, `nm` scan and build-log scan for `EnvironmentDigest`, `EnvironmentDigestTool`, `EnvironmentDigester`, `EnvironmentDigestCLI` | `2026-07-07T12:39:16Z` to `2026-07-07T12:39:18Z` | 1 | Passed; no capability token matched |
| `Q-SHP-003` | Keyboard Extension product resource scan, `strings` scan, `nm` scan and build-log scan for `EnvironmentDigest`, `EnvironmentDigestTool`, `EnvironmentDigester`, `EnvironmentDigestCLI` | `2026-07-07T12:39:30Z` | 1 | Passed; no capability token matched |
| `Q-SHP-004` | RimeBridge product scan, `strings` scan, `nm` scan and build-log scan for `EnvironmentDigest`, `EnvironmentDigestTool`, `EnvironmentDigester`, `EnvironmentDigestCLI` | `2026-07-07T12:39:41Z` | 1 | Passed; no capability token matched |
| `Q-SHP-002/003/004` | `otool -L` dependency inspection on Main App binary, Keyboard Extension binary and `RimeBridge.o`, followed by the same capability-token scan | `2026-07-07T12:39:53Z` to `2026-07-07T12:39:54Z` | 1 | Passed; no capability dependency token matched |

Retained local logs:

- `/private/tmp/env-tooling-001-q-shp-source-membership.log`
- `/private/tmp/env-tooling-001-q-shp-002-mainapp-build.log`
- `/private/tmp/env-tooling-001-q-shp-003-keyboard-build.log`
- `/private/tmp/env-tooling-001-q-shp-004-rimebridge-build.log`
- `/private/tmp/env-tooling-001-q-shp-002-mainapp-inspection.log`
- `/private/tmp/env-tooling-001-q-shp-003-keyboard-inspection.log`
- `/private/tmp/env-tooling-001-q-shp-004-rimebridge-inspection.log`
- `/private/tmp/env-tooling-001-q-shp-otool.log`
