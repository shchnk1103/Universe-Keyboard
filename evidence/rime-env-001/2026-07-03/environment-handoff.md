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

All framework `Info.plist` declarations use `SupportedPlatform=ios`; simulator entries declare
`SupportedPlatformVariant=simulator`. Declared architectures and `lipo -archs` payload observations agree.

| XCFramework | Restoration | Device declaration/payload | Simulator declaration/payload |
|---|---|---|---|
| `boost_atomic.xcframework` | Restored | arm64 / arm64 | arm64 / arm64 |
| `boost_filesystem.xcframework` | Restored | arm64 / arm64 | arm64 / arm64 |
| `boost_regex.xcframework` | Restored | arm64 / arm64 | arm64 / arm64 |
| `libglog.xcframework` | Restored | arm64 / arm64 | arm64,x86_64 / arm64,x86_64 |
| `libleveldb.xcframework` | Restored | arm64 / arm64 | arm64,x86_64 / arm64,x86_64 |
| `liblua.xcframework` | Restored | arm64 / arm64 | arm64,x86_64 / arm64,x86_64 |
| `libmarisa.xcframework` | Restored | arm64 / arm64 | arm64,x86_64 / arm64,x86_64 |
| `libopencc.xcframework` | Restored | arm64 / arm64 | arm64,x86_64 / arm64,x86_64 |
| `librime-lua.xcframework` | Restored | arm64 / arm64 | arm64,x86_64 / arm64,x86_64 |
| `librime.xcframework` | Restored | arm64 / arm64 | arm64,x86_64 / arm64,x86_64 |
| `libyaml-cpp.xcframework` | Restored | arm64 / arm64 | arm64,x86_64 / arm64,x86_64 |

Missing, damaged, unexpected or mismatched frameworks: none.

## Commands And Results

| Command | Result |
|---|---|
| `curl --fail --silent --show-error --location --head --max-time 30 <canonical URL>` | Exit 0; GitHub redirect followed by `200 OK` |
| `bash scripts/ensure_rime_vendor.sh fetch` | Exit 0; archive restored and structural inventory verified |
| `shasum -a 256 "$TMPDIR/universe-keyboard-rime-vendor.zip"` | Exit 0; expected SHA-256 observed |
| `bash scripts/ensure_rime_vendor.sh verify` | Exit 0 at `2026-07-03T05:11:37Z` |
| Per-framework `plutil`, `jq` and `lipo -archs` matrix check | Exit 0; every required declaration/payload matched |
| `xcodebuild -list -project "Universe Keyboard.xcodeproj"` | Exit 0; local packages resolved |
| Main App, Release, generic arm64 iOS Simulator, no signing | Exit 0; build succeeded |
| Keyboard scheme, Release, generic arm64 iOS Simulator, no signing | Exit 0; build succeeded |
| RimeBridge scheme, Release, generic arm64 iOS Simulator, no signing | Exit 0; build succeeded |
| Main App, Release, generic arm64 iOS device, no signing | Exit 0; build succeeded and embedded Keyboard target resolved |

The supplemental universal Simulator build also exited successfully, but emitted expected x86_64 linker warnings for
the three Boost simulator entries whose accepted slice contract is arm64-only. The canonical arm64 Simulator builds
completed without relying on an unapproved slice.

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
