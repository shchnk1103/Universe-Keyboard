# SCHEME-DELIVERY-SOURCE-STATE-001 evidence

Executor-recorded, 2026-09-06. No physical-device, TestFlight or Release acceptance.
Base: Universe Keyboard `4c9f424e06c316578f1b97ae5ecfbcd9afdeb2e4`.

## Reproduction boundary

User observed selecting → terminal failed (`all_sources_unavailable`) for old identity
`rime_ice_nightly_f60aa4f3`; the failure UI also appeared on Wanxiang's detail page.
Host HEAD probes returned 200 from both moving nightly URLs, size 16,041,243 versus
catalog 16,041,786. This proves a current reproducible rejection path, not the exact
transport conditions of the user's earlier phone attempt. The view ignored the failed
scheme when rendering the global state.

## Reviewed dated artifact

- Official release: https://github.com/iDvel/rime-ice/releases/tag/2026.06.30
- Tag resolved source commit: `6810e8916d160498620a16fef2135956fecbd485`.
- GitHub asset ID: `461862575`, name `full.zip`, release `immutable=false`.
- Official URL: https://github.com/iDvel/rime-ice/releases/download/2026.06.30/full.zip
- Mirror URL: https://mirror.nju.edu.cn/github-release/iDvel/rime-ice/2026.06.30/full.zip
- Independently downloaded both archives: 16,050,491 bytes each;
  SHA-256 `675d23b070be00e1b800f9a6db033ef98f4493cd5b568ed8aa3b3541769c46ac`,
  matching GitHub API digest. Mirror equivalence comes from verified bytes, not host name.
- Lua-enabled staged content: 60 admitted files,
  `df0fd1c9b8634cef9f0c832f11b0ccc47940047f331242fc7476bc19d6693b37`.
- Lua-disabled staged content: 30 admitted files,
  `22d420406168ef53d7c94ac9cfe3bdf5401192334c1bf0518915c1f8317b1d51`.
- Initial calculation uses production RimeConfigPostProcessor/T9SchemaCompatibility with a
  standalone temporary driver, followed by sorted path/NUL/big-endian UInt64 length/content/NUL
  hashing. The Simulator XCTest uses production Unzip and SchemaArtifactVerifier to independently
  verify those manifest values for both archives and both Lua modes.
- Temporary downloaded fixtures: `/private/tmp/rime-ice-20260630/{github,nju}.zip` (not committed).

## Verification status

Core: 1073 tests passed after typed probe diagnostics extension. Focused source and pinned-archive tests: 6 passed, zero skips, including both downloaded archives and both Lua modes. Full App/Keyboard: 299 total, 296 passed, 3 pre-existing physical-device-only skips; Bridge: 95 total, 75 passed, 20 conditional skips. Zero failures. Debug/Release strict builds passed. Independent reviews are tracked below; they are not inferred from tests.

The fixture integration test is opt-in via `TEST_RUNNER_SCHEME_PIN_ARCHIVE_ROOT` pointing to the
folder containing independently downloaded `github.zip` and `nju.zip`. Xcode forwards this as
`SCHEME_PIN_ARCHIVE_ROOT` inside the test runner, which is the name read by XCTest; the two
names describe the launch and test-process sides of the same variable. A skipped fixture test
is not source-content verification; local artifact acceptance requires its non-skipped pass.

## Frozen tested implementation

- Commit: `905c50ee69cf4698c43b9912937a69ba1592752b`; comparison base `4c9f424e06c316578f1b97ae5ecfbcd9afdeb2e4`.
- Tree: `17c3ff8a80d53644c92b71c111703c1395e13cc1`.
- SHA-256 of `git diff --binary base candidate`: `57b14d410f2142601a88f81f615666d95c84c1391cb32fa2d3491741e745afca`.
- The App rerun used this final source/test content before its commit; the previous run's two obsolete nightly-as-current fixtures were corrected, with an explicit legacy-nightly update regression added. Earlier failing run remains `/private/tmp/scheme-app-full.log`; final passing run is `scheme-app-full-r2.log`.
- Hosted full pass on that exact implementation: [run 34028658338](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/34028658338).
- Later record-only commits do not change these tested objects. Their link/status checks and current PR HEAD CI are separately required; no claim about unseen future code.

## Commands and local retention

Host macOS 27 beta; Xcode 27 beta; iPhone 17 Pro/iOS 26.5 (`36BAABED-6846-4F9A-A672-6884B54CF50E`). No global Xcode selection change or physical-device install.

```sh
swift test --package-path Packages/KeyboardCore
# For RimeBridgeTests Debug test and Universe Keyboard Debug test/Debug build/Release build:
TEST_RUNNER_SCHEME_PIN_ARCHIVE_ROOT=/private/tmp/rime-ice-20260630 \
DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer xcodebuild \
  -project 'Universe Keyboard.xcodeproj' -scheme '<scheme>' -configuration '<configuration>' \
  -destination 'platform=iOS Simulator,id=36BAABED-6846-4F9A-A672-6884B54CF50E' \
  -derivedDataPath /private/tmp/uk-scheme-fix-derived \
  CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=6.0 SWIFT_STRICT_CONCURRENCY=complete \
  SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES '<test or build>'
```

Swift strict formatting and `run_lightweight_checks.sh origin/main HEAD` with pinned Kit v0.7.0 passed. Advisory legacy warnings are not Product/Quality approval. Local logs are temporary retention, not permanent hosted artifacts.

| Local log | SHA-256 |
|---|---|
| `scheme-core-tests.log` | `40b59499da93f3911131a55c38d7634ed6ea78c054338a180f06a062d66a5ac7` |
| `scheme-focused.log` | `a08b20667e51c1557c3f9f1a72bf8182af898430acf671b392e8da6f2a954f58` |
| `scheme-bridge.log` | `0b9c6b79f131a756f694bb14e8426b4f583fdeb8743bb6a3d00a0138b17defc0` |
| `scheme-app-full-r2.log` | `e4eff2fd86ca4a37792b456d81de35113785785f0b10ddb1021b18895ba5c1f8` |
| `scheme-build-Debug.log` | `d0fde530fa57bbec40f07efedde0ec58f91f557cc70f0b1aa0e71fdd8679caca` |
| `scheme-build-Release.log` | `2e02e8378e685d2996297208677c4d7e2b60b2c307dc6f389566379adb676aae` |
| `scheme-lightweight.log` | `4452f3ea6a20be09bc700a999c628be516870ea2fca9ffba00ad13f2b58d9cae` |

## Review continuity

First Architecture/Quality runtimes ended on quota without conclusions and later could not be resumed. Replacement read-only runtimes use the same logical lanes and frozen implementation; the unavailable attempts are not counted as passes. Both replacement reviews completed with no blocking findings: [independent review](../reviews/scheme-delivery-source-state-001.md).

## Human retest handoff

Use the candidate built from PR #100, not the old TestFlight binary. Verify Rime Ice can download/install/deploy, then normal input; verify Wanxiang remains installable. To exercise failure attribution, interrupt/deny a download, navigate to the other scheme and back: the unrelated page must show no stale error, the originating page must retain its own error, and retry must address that scheme. Switching the active input scheme is distinct from navigating its detail page.

Physical-device and TestFlight acceptance remain pending; Simulator tests do not replace them. No device, merge or upload was performed.
