# RIME-ENV-001 Quality Environment Handoff

## Identity

- Assignment: `RIME-ENV-001`
- Assignment Policy: `1.0.0`
- Frozen baseline: `74c8ff3b578b4b28d831bf63df914ee6c3093165`
- Worktree: `/Users/doubleshy0n/Dev/Universe Keyboard-rime-env-001`
- Branch: `codex/rime-env-001`
- Worktree status before restoration: clean
- Environment: macOS 27.0 (`26A5368g`), arm64
- Xcode: 27.0 (`27A5209h`)
- Swift: 6.4 (`swiftlang-6.4.0.23.5`)
- Evidence collected: `2026-07-03T05:03:14Z` through `2026-07-03T05:11:37Z`
- Evidence rework: `2026-07-07T12:17:20Z` through `2026-07-07T12:23:59Z`

## Artifact Provenance

- Version: `rime-vendor-ios-1.16.1-lua.1`
- Source: `https://github.com/shchnk1103/Universe-Keyboard/releases/download/rime-vendor-ios-1.16.1-lua.1/universe-keyboard-rime-vendor-ios-1.16.1-lua.1.zip`
- Expected archive SHA-256: `c299f36eae4966a8c22f83046c7015a04b3f047abcc4bab9355ca19ac840436c`
- Observed archive SHA-256: `c299f36eae4966a8c22f83046c7015a04b3f047abcc4bab9355ca19ac840436c`
- Downloaded archive size: `42229490` bytes
- Archive timestamp: `2026-07-03T13:06:39+0800` to `2026-07-03T13:06:48+0800`
- Receipt: `Packages/RimeBridge/Vendor/.rime-vendor-receipt`
- Receipt timestamp: `2026-07-03T13:06:49+0800`
- Receipt version and SHA-256: match the manifest

The manifest governs the complete archive checksum. It does not publish separate expected checksums for each
extracted framework. Per-framework identity is therefore established by the checksum-verified archive, exact closed
inventory, valid XCFramework metadata, static-library payload and required slice validation; no individual checksum
is inferred.

## Inventory And Slice Matrix

The installed archive contains a complete 11-framework inventory. The iOS integration contract remains the canonical
requirement for this Assignment: every framework must provide the required iOS device and iOS Simulator entries from
`docs/architecture/rime-artifacts.md`. Non-iOS entries in the pinned archive are recorded here as observed bytes covered
by the manifest archive checksum; they are not used to satisfy the iOS requirement.

### Full XCFramework Info.plist Inventory

The following rows are direct observations from each XCFramework `Info.plist`, cross-checked against `lipo -archs` for
the static-library payload.

| XCFramework | Observed `LibraryIdentifier` entries |
|---|---|
| `boost_atomic.xcframework` | `ios-arm64-simulator` (`ios`, `simulator`, declared `arm64`, payload `arm64`); `tvos-arm64-simulator` (`tvos`, `simulator`, declared `arm64`, payload `arm64`); `xros-arm64` (`xros`, declared `arm64`, payload `arm64`); `macos-arm64` (`macos`, declared `arm64`, payload `arm64`); `xros-arm64-simulator` (`xros`, `simulator`, declared `arm64`, payload `arm64`); `ios-arm64-maccatalyst` (`ios`, `maccatalyst`, declared `arm64`, payload `arm64`); `tvos-arm64` (`tvos`, declared `arm64`, payload `arm64`); `watchos-arm64_x86_64-simulator` (`watchos`, `simulator`, declared `arm64,x86_64`, payload `x86_64 arm64`); `ios-arm64` (`ios`, declared `arm64`, payload `arm64`); `watchos-arm64` (`watchos`, declared `arm64`, payload `arm64`) |
| `boost_filesystem.xcframework` | `watchos-arm64_x86_64-simulator` (`watchos`, `simulator`, declared `arm64,x86_64`, payload `x86_64 arm64`); `ios-arm64` (`ios`, declared `arm64`, payload `arm64`); `tvos-arm64` (`tvos`, declared `arm64`, payload `arm64`); `xros-arm64` (`xros`, declared `arm64`, payload `arm64`); `macos-arm64` (`macos`, declared `arm64`, payload `arm64`); `ios-arm64-simulator` (`ios`, `simulator`, declared `arm64`, payload `arm64`); `watchos-arm64` (`watchos`, declared `arm64`, payload `arm64`); `tvos-arm64-simulator` (`tvos`, `simulator`, declared `arm64`, payload `arm64`); `ios-arm64-maccatalyst` (`ios`, `maccatalyst`, declared `arm64`, payload `arm64`); `xros-arm64-simulator` (`xros`, `simulator`, declared `arm64`, payload `arm64`) |
| `boost_regex.xcframework` | `xros-arm64` (`xros`, declared `arm64`, payload `arm64`); `macos-arm64` (`macos`, declared `arm64`, payload `arm64`); `ios-arm64-simulator` (`ios`, `simulator`, declared `arm64`, payload `arm64`); `watchos-arm64` (`watchos`, declared `arm64`, payload `arm64`); `watchos-arm64_x86_64-simulator` (`watchos`, `simulator`, declared `arm64,x86_64`, payload `x86_64 arm64`); `tvos-arm64` (`tvos`, declared `arm64`, payload `arm64`); `xros-arm64-simulator` (`xros`, `simulator`, declared `arm64`, payload `arm64`); `ios-arm64` (`ios`, declared `arm64`, payload `arm64`); `ios-arm64-maccatalyst` (`ios`, `maccatalyst`, declared `arm64`, payload `arm64`); `tvos-arm64-simulator` (`tvos`, `simulator`, declared `arm64`, payload `arm64`) |
| `libglog.xcframework` | `ios-arm64` (`ios`, declared `arm64`, payload `arm64`); `ios-arm64_x86_64-simulator` (`ios`, `simulator`, declared `arm64,x86_64`, payload `x86_64 arm64`) |
| `libleveldb.xcframework` | `ios-arm64_x86_64-simulator` (`ios`, `simulator`, declared `arm64,x86_64`, payload `x86_64 arm64`); `ios-arm64` (`ios`, declared `arm64`, payload `arm64`) |
| `liblua.xcframework` | `ios-arm64_x86_64-simulator` (`ios`, `simulator`, declared `arm64,x86_64`, payload `x86_64 arm64`); `ios-arm64` (`ios`, declared `arm64`, payload `arm64`) |
| `libmarisa.xcframework` | `ios-arm64_x86_64-simulator` (`ios`, `simulator`, declared `arm64,x86_64`, payload `x86_64 arm64`); `ios-arm64` (`ios`, declared `arm64`, payload `arm64`) |
| `libopencc.xcframework` | `ios-arm64_x86_64-simulator` (`ios`, `simulator`, declared `arm64,x86_64`, payload `x86_64 arm64`); `ios-arm64` (`ios`, declared `arm64`, payload `arm64`) |
| `librime-lua.xcframework` | `ios-arm64_x86_64-simulator` (`ios`, `simulator`, declared `arm64,x86_64`, payload `x86_64 arm64`); `ios-arm64` (`ios`, declared `arm64`, payload `arm64`) |
| `librime.xcframework` | `ios-arm64_x86_64-simulator` (`ios`, `simulator`, declared `arm64,x86_64`, payload `x86_64 arm64`); `ios-arm64` (`ios`, declared `arm64`, payload `arm64`) |
| `libyaml-cpp.xcframework` | `ios-arm64_x86_64-simulator` (`ios`, `simulator`, declared `arm64,x86_64`, payload `x86_64 arm64`); `ios-arm64` (`ios`, declared `arm64`, payload `arm64`) |

### Required iOS Integration Slice Matrix

The required iOS device/simulator entries are present and their `Info.plist` architecture declarations match the
static-library payload observations.

| XCFramework | Restoration | Required iOS device declaration/payload | Required iOS Simulator declaration/payload |
|---|---|---|---|
| `boost_atomic.xcframework` | Restored | `ios-arm64`: arm64 / arm64 | `ios-arm64-simulator`: arm64 / arm64 |
| `boost_filesystem.xcframework` | Restored | `ios-arm64`: arm64 / arm64 | `ios-arm64-simulator`: arm64 / arm64 |
| `boost_regex.xcframework` | Restored | `ios-arm64`: arm64 / arm64 | `ios-arm64-simulator`: arm64 / arm64 |
| `libglog.xcframework` | Restored | `ios-arm64`: arm64 / arm64 | `ios-arm64_x86_64-simulator`: arm64,x86_64 / x86_64 arm64 |
| `libleveldb.xcframework` | Restored | `ios-arm64`: arm64 / arm64 | `ios-arm64_x86_64-simulator`: arm64,x86_64 / x86_64 arm64 |
| `liblua.xcframework` | Restored | `ios-arm64`: arm64 / arm64 | `ios-arm64_x86_64-simulator`: arm64,x86_64 / x86_64 arm64 |
| `libmarisa.xcframework` | Restored | `ios-arm64`: arm64 / arm64 | `ios-arm64_x86_64-simulator`: arm64,x86_64 / x86_64 arm64 |
| `libopencc.xcframework` | Restored | `ios-arm64`: arm64 / arm64 | `ios-arm64_x86_64-simulator`: arm64,x86_64 / x86_64 arm64 |
| `librime-lua.xcframework` | Restored | `ios-arm64`: arm64 / arm64 | `ios-arm64_x86_64-simulator`: arm64,x86_64 / x86_64 arm64 |
| `librime.xcframework` | Restored | `ios-arm64`: arm64 / arm64 | `ios-arm64_x86_64-simulator`: arm64,x86_64 / x86_64 arm64 |
| `libyaml-cpp.xcframework` | Restored | `ios-arm64`: arm64 / arm64 | `ios-arm64_x86_64-simulator`: arm64,x86_64 / x86_64 arm64 |

Missing, damaged, unexpected or mismatched frameworks: none.

## Commands And Results

| Command | Timestamp | Exit status | Result summary |
|---|---:|---:|---|
| `curl --fail --silent --show-error --location --head --max-time 30 <canonical URL>` | `2026-07-03T05:03:14Z` | 0 | GitHub redirect followed by `200 OK` |
| `bash scripts/ensure_rime_vendor.sh fetch` | `2026-07-03T05:06:39Z` to `2026-07-03T05:06:49Z` | 0 | Archive restored and structural inventory verified |
| `shasum -a 256 "$TMPDIR/universe-keyboard-rime-vendor.zip"` | `2026-07-03T05:06:49Z` | 0 | Expected archive SHA-256 observed |
| `bash scripts/ensure_rime_vendor.sh verify` | `2026-07-03T05:11:37Z` | 0 | Receipt, manifest identity and structural inventory verified |
| Per-framework `Info.plist` and payload slice check using `python3`, `plutil` and `lipo -archs` | `2026-07-07T12:17:20Z` | 0 | Full XCFramework platform inventory observed; required iOS device/simulator declarations and payload architectures matched |
| `xcodebuild -list -project "Universe Keyboard.xcodeproj"` | `2026-07-03T05:11:37Z` | 0 | Local packages resolved |

### Reproducible Release Verification Evidence

The following Release verification commands were rerun during this evidence rework. They do not redo artifact
restoration and do not execute `Q-SHP-002/003/004`; they only prove the restored environment can resolve and link the
Release graphs needed for Quality to rerun those checks. Full command output was captured under `/private/tmp` for the
local review session.

| Verification | Exact command | Timestamp | Exit status | Result summary |
|---|---|---:|---:|---|
| Main App Release verification | `xcodebuild -project 'Universe Keyboard.xcodeproj' -scheme 'Universe Keyboard' -configuration Release -destination 'generic/platform=iOS Simulator' -derivedDataPath /private/tmp/rime-env-001-final-mainapp CODE_SIGNING_ALLOWED=NO ARCHS=arm64 ONLY_ACTIVE_ARCH=YES build` | `2026-07-07T12:22:27Z` to `2026-07-07T12:22:51Z` | 0 | Release build succeeded; target graph includes Main App, Keyboard Extension, KeyboardCore, RimeBridge, and Vendor XCFramework link inputs. Log: `/private/tmp/rime-env-001-final-mainapp.log` |
| Keyboard Extension Release verification | `xcodebuild -project 'Universe Keyboard.xcodeproj' -scheme 'Keyboard' -configuration Release -destination 'generic/platform=iOS Simulator' -derivedDataPath /private/tmp/rime-env-001-final-keyboard CODE_SIGNING_ALLOWED=NO ARCHS=arm64 ONLY_ACTIVE_ARCH=YES build` | `2026-07-07T12:23:06Z` to `2026-07-07T12:23:18Z` | 0 | Release build succeeded; target graph includes Keyboard Extension, KeyboardCore, RimeBridge, and Vendor XCFramework link inputs. Log: `/private/tmp/rime-env-001-final-keyboard.log` |
| RimeBridge Release verification | `xcodebuild -project 'Universe Keyboard.xcodeproj' -scheme 'RimeBridge' -configuration Release -destination 'generic/platform=iOS Simulator' -derivedDataPath /private/tmp/rime-env-001-final-rimebridge CODE_SIGNING_ALLOWED=NO ARCHS=arm64 ONLY_ACTIVE_ARCH=YES build` | `2026-07-07T12:23:31Z` to `2026-07-07T12:23:59Z` | 0 | Release build succeeded; target graph includes RimeBridge, RimeBridgeObjC, KeyboardCore, and Vendor XCFramework link inputs. Log: `/private/tmp/rime-env-001-final-rimebridge.log` |

The supplemental universal Simulator build from the original restoration run also exited successfully, but emitted expected
x86_64 linker warnings for the three Boost simulator entries whose accepted iOS integration slice contract is arm64-only.
The reproducible Release evidence above uses the canonical arm64 Simulator build path and does not rely on an unapproved
slice.

## Dependency Resolution And Dynamic Release Graph Readiness

- Main App dependency resolution: **Passed** for arm64 Simulator and arm64 device Release graphs.
- Keyboard Extension dependency resolution: **Passed** for arm64 Simulator and arm64 device Release graphs.
- RimeBridge dependency resolution: **Passed** for the arm64 Simulator Release graph and as a dependency in the
  arm64 device graph.
- `Q-SHP-002` environment readiness: **Ready to rerun**; not evaluated as a Quality pass here.
- `Q-SHP-003` environment readiness: **Ready to rerun**; not evaluated as a Quality pass here.
- `Q-SHP-004` environment readiness: **Ready to rerun**; not evaluated as a Quality pass here.

## Scope And Integrity

- Production code modified: no.
- Runtime, RimeBridge behavior, Session, Main App behavior and Extension behavior modified: no.
- Assignment, Architecture and Quality contracts modified: no.
- Repository-tracked restoration changes: none; `Packages/RimeBridge/Vendor/` is intentionally ignored.
- `git diff --check`: passed / no tracked diff before this handoff evidence file.
- Homebrew, local substitute libraries and source-built artifacts: not used.
- Blocked, failed, skipped or unexecuted environment checks: none required by this Assignment.
- ENV-TOOLING-001 Quality checks themselves: not executed; this task only restores their environment.

## Stop Conditions, Risks And Validity

- Stop Condition triggered: no.
- Residual risk: the restored Vendor directory is local and ignored; deleting or modifying it invalidates this handoff.
- Retry condition: rerun canonical `fetch`/`verify`, archive checksum, inventory/slice checks and Release dependency
  builds after any baseline, manifest, source, version, checksum, slice contract, Xcode or Vendor-directory change.
- Environment conclusion: sufficient for Quality to rerun `Q-SHP-002`, `Q-SHP-003` and `Q-SHP-004`.
