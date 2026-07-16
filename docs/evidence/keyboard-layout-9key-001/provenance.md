# T9 Spike Provenance

- Timestamp: 2026-07-16 19:44:26 CST
- Branch: feature/keyboard-layout-9key-spike
- Commit: eaa72d5207deacab1dc0b94024c67af96448ad19
- Upstream URL: https://raw.githubusercontent.com/iDvel/rime-ice/main/t9.schema.yaml
- Upstream version field: 3.0.0
- Upstream SHA-256: `56bc593d2c846666361b3394bdc0bdb0c6f1a663f1fd810dceab2d222b5bf8f6`
- Patched isolated schema SHA-256: `176a01aefcfeba856906ba6e83a9cf147fbd57d39f9923c70b36879c8bb5d57b`
- Patch: remove lines containing `t9_processor` only
- Source shared runtime (read-only copy source): `/Users/doubleshy0n/Library/Developer/CoreSimulator/Devices/06C5BC3E-7599-4761-A1A2-71DAEA991474/data/Containers/Shared/AppGroup/357A63AB-6D07-4573-B289-698E573655C1/Rime/shared`
- Isolated shared dir: `/Users/doubleshy0n/Dev/Universe Keyboard/evidence/keyboard-layout-9key-spike/20260716-194424/runtime/shared`
- Isolated user dir: `/Users/doubleshy0n/Dev/Universe Keyboard/evidence/keyboard-layout-9key-spike/20260716-194424/runtime/user`
- Destination: `platform=iOS Simulator,id=06C5BC3E-7599-4761-A1A2-71DAEA991474`
- Pinned vendor tag (from docs/architecture/rime-artifacts.md): `rime-vendor-ios-1.16.1-lua.1`
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
