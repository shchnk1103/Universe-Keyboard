# T9 Spike Provenance

- Timestamp: 2026-07-16 19:56:21 CST
- Branch: feature/keyboard-layout-9key-spike
- Harness commit (must contain Spike test + runner): `337dd30ab443ad2d2af497648910946d6beb1a35`
- Harness present in commit: yes
- Upstream URL: https://raw.githubusercontent.com/iDvel/rime-ice/main/t9.schema.yaml
- Upstream version field: 3.0.0
- Upstream SHA-256: `56bc593d2c846666361b3394bdc0bdb0c6f1a663f1fd810dceab2d222b5bf8f6`
- Patched isolated schema SHA-256: `176a01aefcfeba856906ba6e83a9cf147fbd57d39f9923c70b36879c8bb5d57b`
- Patch: remove lines containing `t9_processor` only
- Source shared runtime (read-only copy source): `/Users/doubleshy0n/Library/Developer/CoreSimulator/Devices/06C5BC3E-7599-4761-A1A2-71DAEA991474/data/Containers/Shared/AppGroup/357A63AB-6D07-4573-B289-698E573655C1/Rime/shared`
- Isolated shared dir: `/Users/doubleshy0n/Dev/Universe Keyboard/evidence/keyboard-layout-9key-spike/20260716-195542/runtime/shared`
- Isolated user dir: `/Users/doubleshy0n/Dev/Universe Keyboard/evidence/keyboard-layout-9key-spike/20260716-195542/runtime/user`
- Destination: `platform=iOS Simulator,id=06C5BC3E-7599-4761-A1A2-71DAEA991474`
- Pinned vendor tag (from docs/architecture/rime-artifacts.md): `rime-vendor-ios-1.16.1-lua.1`
- Vendor verify log SHA-256: `03fd59b207427813f241bb2217f226ac161e682885d370421269bff6e51b17e4`
- xcodebuild full log SHA-256: `784ac88f775d414cc7f181f55e9c7cdb0127b00c8d9d68a79eb59097c7ebe651`
- Vendor verify required: yes (non-zero exit fails Spike)
- Vendor manifest excerpt:

```
# RIME vendor artifact manifest.
#
# Pinned immutable release asset. Changes to these values require publishing a
# new archive and verifying the SHA-256 from the uploaded release bytes.
RIME_VENDOR_VERSION="rime-vendor-ios-1.16.1-lua.1"
RIME_VENDOR_ARCHIVE_URL="https://github.com/shchnk1103/Universe-Keyboard/releases/download/rime-vendor-ios-1.16.1-lua.1/universe-keyboard-rime-vendor-ios-1.16.1-lua.1.zip"
RIME_VENDOR_ARCHIVE_SHA256="c299f36eae4966a8c22f83046c7015a04b3f047abcc4bab9355ca19ac840436c"

RIME_VENDOR_FRAMEWORKS=(
    "boost_atomic.xcframework"
    "boost_filesystem.xcframework"
    "boost_regex.xcframework"
    "libglog.xcframework"
    "libleveldb.xcframework"
    "liblua.xcframework"
    "libmarisa.xcframework"
    "libopencc.xcframework"
    "librime-lua.xcframework"
    "librime.xcframework"
    "libyaml-cpp.xcframework"
)
```
