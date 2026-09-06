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

Core: 1073 tests passed after typed probe diagnostics extension. Focused source and pinned-archive tests: 6 passed, zero skips, including both downloaded archives and both Lua modes. Full App/Keyboard and Bridge tests, Debug/Release builds and independent reviews pending.

The fixture integration test is opt-in via `TEST_RUNNER_SCHEME_PIN_ARCHIVE_ROOT` pointing to the
folder containing independently downloaded `github.zip` and `nju.zip`. A skipped fixture test
is not source-content verification; local artifact acceptance requires its non-skipped pass.
