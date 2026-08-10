# TD-012 G1: Reproducible octagram Vendor Build Evidence

**Date / timezone:** `2026-08-10 Asia/Shanghai`
**Evidence grade:** `Executor-recorded`
**Assignment:** [`TD-012-OCTAGRAM-VENDOR-G1`](../assignments/td-012-octagram-vendor-g1.md)
**Non-claims:** No `.gram` model, no schema/UI feature, no memory/Jetsam budget, no product release acceptance.

## Artifact

| Field | Value |
|---|---|
| Version | `rime-vendor-ios-1.16.1-lua.1-octagram.1` |
| Archive | `universe-keyboard-rime-vendor-ios-1.16.1-lua.1-octagram.1.zip` |
| SHA-256 | `d17aab9a8b08b5901ab583c143b0a8a03994e36fe092309fd14c5bee31399dd9` |
| Release | <https://github.com/shchnk1103/Universe-Keyboard/releases/tag/rime-vendor-ios-1.16.1-lua.1-octagram.1> |
| Rollback baseline | `rime-vendor-ios-1.16.1-lua.1` / `c299f36e…c840436c` |

Inventory: baseline 11 frameworks (byte-copied from the pinned baseline vendor) plus
`librime-octagram.xcframework`. Optional notice file
`THIRD_PARTY_OCTAGRAM_NOTICE.txt` records BSD-3-Clause source + header residual.

## Source / toolchain pins

From `config/rime-octagram-vendor-build.env` / build receipt:

| Input | Pin |
|---|---|
| librime | `1300e568967feeeedd72028c7cb5ef9151f7fb37` (peer of baseline `librime.a`) |
| octagram | `bfb168ca33d8b372596fdf2007933f3da1cf360e` (relicense merge) |
| Boost headers | 1.91.0 tarball SHA-256 `de5e6b0e…51264f5` |
| Plugin iOS deployment target | `15.0` (Xcode 27 minimum; project still targets iOS 26.4) |
| Xcode | 27.0 (`27A5228h`) |
| Recipe | `scripts/build_rime_octagram_plugin.sh` + `scripts/assemble_rime_vendor_with_octagram.sh` |

## Slice / symbol evidence

| Slice | Architectures | `rime_require_module_octagram` |
|---|---|---|
| `ios-arm64` | `arm64` | present (C++ mangled) |
| `ios-arm64_x86_64-simulator` | `arm64`, `x86_64` | present on fat archive |

Commands used at packaging time:

```bash
lipo -info Packages/RimeBridge/Vendor/librime-octagram.xcframework/ios-arm64/librime-octagram.a
lipo -info Packages/RimeBridge/Vendor/librime-octagram.xcframework/ios-arm64_x86_64-simulator/librime-octagram.a
nm -gU …/librime-octagram.a | grep rime_require_module_octagram
bash scripts/ensure_rime_vendor.sh verify
```

## Bridge wiring (runtime activation path)

Mirrors the existing Lua pattern:

1. SwiftPM binary target `librimeOctagramRIME`
2. Compile define `RIME_HAS_OCTAGRAM`
3. `RimeOctagramModuleShim` references `rime_require_module_octagram`
4. Keyboard target `-force_load` of the octagram static archive
5. App + Extension traits load `octagram` with `core/dict/gears/lua`
6. Capability probes: `octagramModuleRegistered` / `grammarComponentRegistered`

No `.gram` path, schema key, download, or user setting is introduced.

## Reproduce

```bash
bash scripts/ensure_rime_vendor.sh fetch   # baseline must already be present before rebuild
bash scripts/build_rime_octagram_plugin.sh
bash scripts/assemble_rime_vendor_with_octagram.sh
# publish new immutable tag, then update config/rime-vendor-manifest.env
```

## Local verification (executor host, 2026-08-10)

| Check | Result | Notes |
|---|---|---|
| `bash scripts/ensure_rime_vendor.sh verify` | Pass | 12 frameworks + receipt for new pin |
| `RimeBridgeTests` (iPhone 17 Pro, iOS 26.5 Simulator) | Pass | 57 tests, 20 skipped (env spikes), 0 failures; includes `RimeOctagramCapabilityTests` ×3 |
| `Universe Keyboard` Debug build (same destination) | Pass | App + Keyboard extension |
| `Universe Keyboard` Release build (same destination) | Pass | App + Keyboard extension |
| Full App/Keyboard test suite (iPhone 17 Pro, iOS 26.5) | Pass | After Keyboard also `-force_load` of `libglog` (octagram objects reference glog; SPM auto-link was insufficient for extension debug-dylib link) |

`RimeOctagramCapabilityTests` specifically proved, with empty shared/user dirs and **no** `.gram` file:

- `octagramModuleCompiledIn == true`
- traits modules `core+dict+gears+lua+octagram`
- after setup/initialize: `octagramModuleRegistered` and `grammarComponentRegistered`
- Lua module path still registers

## Residuals for independent review

- Upstream stale GPLv3 file header residual remains documented; notice retained.
- Architecture & Quality independent conclusions still required before
  Assignment `Reviewed` / `Closed`.
- Model G2–G6 (model pin, deploy, memory, productization) remain unauthorized.
