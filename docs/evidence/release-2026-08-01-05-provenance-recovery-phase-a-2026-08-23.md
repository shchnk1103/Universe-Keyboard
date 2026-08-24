# RELEASE-2026-0801-05-PROVENANCE-A — Phase A Evidence And Handoff

> **Evidence grade:** `Executor-recorded`
>
> **Started:** `2026-08-23 Asia/Shanghai`
>
> **Assignment:** [`RELEASE-2026-0801-05-PROVENANCE-A`](../assignments/release-2026-08-01-05-provenance-recovery-phase-a.md)

## Zero-context reading order

1. [`Assignment`](../assignments/release-2026-08-01-05-provenance-recovery-phase-a.md)
2. [`existing third-party notice provenance`](release-2026-08-01-05-third-party-notice-provenance-2026-08-23.md)
3. [`RIME binary artifact contract`](../architecture/rime-artifacts.md)
4. `config/rime-vendor-manifest.env`
5. this evidence record, then only the source/build paths named by the active track

## Fixed investigation boundary

- Current Vendor: `rime-vendor-ios-1.16.1-lua.1-octagram.1`
- Current Vendor archive SHA-256: `d17aab9a8b08b5901ab583c143b0a8a03994e36fe092309fd14c5bee31399dd9`
- Baseline without octagram: `rime-vendor-ios-1.16.1-lua.1`
- Baseline archive SHA-256: `c299f36eae4966a8c22f83046c7015a04b3f047abcc4bab9355ca19ac840436c`
- Fixed librime peer revision: `1300e568967feeeedd72028c7cb5ef9151f7fb37`
- Shipped Lua identity: `5.4.8`
- Current `librime-lua` license-text snapshot only: `ec52e48ea18f11af37717a01c337f853215cf70b`; this is not a binary-source claim.
- Bundled Luna dictionary Git blob: `19181e3c3e609f075f0f2ceaf6c97d52d241ad96`
- Current upstream Luna history no-match remains the starting observation, not a proof that no historical distribution archive contains the file.

## Track A — `librime-lua`

### Required proof

An exact upstream commit and build-input receipt must be bound to both shipped device and simulator static archives by byte identity, or the record must explain why deterministic byte comparison cannot establish that conclusion.

### Investigation log

1. The retained `/Users/doubleshy0n/Dev/librime` checkout is clean at
   `1300e568967feeeedd72028c7cb5ef9151f7fb37`; no retained standalone
   `librime-lua` source/build directory exists. The copied App build product
   has the same SHA-256 as the shipped device archive and is not independent
   provenance.
2. `ar -tv` and `otool -l` show ten object members built at
   `2026-05-18 22:12`, with iOS/iOS Simulator minimum `15.0` and SDK `26.5`.
   The objects contain no DWARF, source path or embedded commit receipt.
3. Repository history places the integration commit at
   `75cf31c0eb28900ec6cf278e6e04dca22f1ac147` on `2026-05-18 22:48 +0800`.
   The official plugin head at build time was
   `hchunhui/librime-lua@ec52e48ea18f11af37717a01c337f853215cf70b`
   (authored `2026-05-02`); its next/parent boundary is fixed by the official
   Git history. The shipped objects expose both `Lua::gc_step(int)` and the
   destructor counter introduced by exactly that head commit.
4. A disposable rebuild used Xcode `26.6` / Apple clang
   `21.0.0 (clang-2100.1.1.101)`, whose device and simulator SDKs are `26.5`,
   with `-O2 -std=gnu++17`, no `NDEBUG`, iOS minimum `15.0`, the shipped Lua
   and librime headers, retained librime internals and Boost headers. For each
   of device `arm64`, Simulator `arm64` and Simulator `x86_64`, **9 of 10**
   independently compiled members matched the shipped object SHA-256 exactly:
   `lauxlib-compat`, `lua_gears`, `lua`, `lutf8lib-compat`, `modules`,
   `opencc_stub`, `script_translator`, `table_translator` and `types_ext`.
5. `opencc_stub.o` is not an upstream source filename. Disassembly is a single
   `ret` from `opencc_init(lua_State*)`; the bounded local source
   `#include "lib/lua.h"` plus `void opencc_init(lua_State *) {}` reproduces
   the shipped object byte-for-byte on all three architectures. Therefore the
   shipped artifact is accurately described as upstream `ec52e48…` with a
   local OpenCC-disabled stub, not as an unmodified upstream build.
6. The sole no-match is `types.o` on all three architectures. Symbol comparison
   isolates the difference to Boost.Regex header ABI namespace
   `re_detail_500` in the shipped object versus `re_detail_600` in the retained
   Boost 1.91.0 headers. The current Boost static archives remain independently
   byte-bound as recorded in the parent provenance evidence, but the exact
   historical Regex headers used while compiling this one plugin object are
   not retained. Codex could not fetch Boost.Regex history; Grok later completed
   the header-version check below.

### Reproduction roots and next safe command

- Official plugin clone: `/private/tmp/universe-license-librime-lua`
- Extracted/rebuilt device objects: `/tmp/universe-provenance-lua`
- Extracted/rebuilt Simulator objects:
  `/tmp/universe-provenance-lua-sim-arm64` and
  `/tmp/universe-provenance-lua-sim-x86_64`
- Header-version check complete: official last-500 release is Boost 1.88.0 and
  first-600 release is 1.89.0; neither overlay, nor a 1.91 `config.hpp` 600→500
  patch, reproduced device `types.o`. Do not rebuild or replace the Vendor
  archive in Phase A.

### Current disposition

`BOUNDED — plugin source is byte-supported as ec52e48… plus the reproduced
OpenCC-disabled stub on 9/10 objects across all shipped architectures;
types.o uses re_detail_500, but no official Boost.Regex tag produced an
exact SHA-256 match against the fixed compile receipt`.

## Track B — bundled Luna dictionary

### Required proof

An upstream Git blob or immutable distribution archive plus archive/file checksums must exactly match `Keyboard/Resources/luna_pinyin.dict.yaml`. Project-name similarity, current license text and file-header attribution are insufficient.

### Investigation log

1. The bundled file has SHA-256
   `971baa1f38a42d3d82f858b5bbdcad6482371f8d93a2f5d5c4ab341046419e3b`,
   Git blob `19181e3c3e609f075f0f2ceaf6c97d52d241ad96`, 29,259 lines and
   282,450 bytes.
2. Exact blob-ID enumeration covered all 116 historical
   `luna_pinyin.dict.yaml` blobs in the official split
   `rime/rime-luna-pinyin` repository and all 132 historical
   `preset/luna_pinyin.dict.yaml` blobs in the official predecessor
   `rime/brise` repository. The bundled blob is absent from both bounded sets.
3. `rime/brise@496683543269746670ee0886fc9c36e31e4a11bf` introduced official
   blob `728f883f4dada54841a299ca9fc93ac7ade3cbb7` on `2012-07-11`. Its file has
   the same 29,259 lines and all dictionary data is identical to the bundled
   resource. A full `diff -u` contains exactly one header-line change:
   `http://chewing.csie.net/` became `http://chewing.im/`; the six-byte size
   reduction (282,456 to 282,450) is fully explained by that replacement.
4. The exact content identity is therefore an official immutable base blob plus
   one local attribution-URL maintenance patch. No exact upstream blob claim is
   made. This is sufficient to replace an opaque `UNKNOWN` with a reproducible
   derivation receipt, but Product/license review still owns whether that
   derivation is acceptable for distribution.

### Current disposition

`BOUNDED — exact upstream base is rime/brise@4966835… blob 728f883… plus the
single chewing.im header patch; no exact all-bytes upstream blob exists in the
248 enumerated official-history blobs`.

## Grok continuation — Boost.Regex header-version check

Reassignment is recorded in the Assignment. The fixed 9/10 compile receipt was
reused with Xcode 26.6 / iPhoneOS SDK 26.5, `-O2 -std=gnu++17`,
`-DRIME_VERSION="1.16.1" -DBOOST_DLL_USE_STD_FS -DYAML_CPP_STATIC_DEFINE
-DOpencc_BUILT_AS_STATIC`, and the same include roots as the matching objects
(`librime-lua` src, Vendor librime/liblua headers, retained `librime`
src/include, `rime-ios-staging/include`, Homebrew). Only disposable Boost.Regex
header inputs were changed. Simulator slices were not rebuilt after the device
`arm64` object failed exact comparison.

Official header-version boundary:

| Boost release | `boostorg/regex` identity | `BOOST_RE_VERSION` |
|---|---|---|
| 1.88.0 | tag `boost-1.88.0` / `4cbcd3078e6ae10d05124379623a1bf03fcb9350` | 500 |
| 1.89.0 | tag `boost-1.89.0` | 600 |
| last 500 commit before the C++03-removal bump | `b8e58068ffbad37a9da9a2c5e4decbeeb3361fed` (2024-03-23) | 500 |

Device `arm64` `types.o` SHA-256
`c5a370b39f0aa40358789717129a24dc3f67e1b69097bcb200e3886165c400b8`
(size 1,913,088). Tested replacements, none matching:

| Input | Namespace | Size | SHA-256 |
|---|---|---|---|
| staging Boost 1.91 headers (`BOOST_RE_VERSION 600`) | `re_detail_600` | 1,913,280 | `112fdcba4f4a01b8d16a6986b39fce7ae9832fd6a29e410f244385fc96d1b59d` |
| same 1.91 tree with only `config.hpp` patched 600→500 | `re_detail_500` | 1,913,280 | `4032722622d1d31f9cd12db51e4acfe4da96875c5316581371fdb9dbcf8822d7` |
| overlay official 1.88.0 regex module onto the 1.91 tree | `re_detail_500` | 1,910,440 | `07a10c62bb36b231684a0b2e5762ebc8b1b4bbba027c861e2d55c733bdee16b0` |
| overlay last-500 commit `b8e58068…` regex module onto the 1.91 tree | `re_detail_500` | 1,911,256 | `986e56a032406c51049011581ca2a6c290369fad60f0c032f9497833134e039a` |

Shipped versus 1.91/600 is not a namespace-string rename: `__text` is 494,428 vs
497,928 bytes and `__gcc_except_tab` is 15,184 vs 14,140. Overlaying 1.88.0 also
moved non-regex Boost.Signals2 exported symbols, so a mixed 1.88+1.91 tree is
not a valid exact-source claim. Stop Condition reached: naming any other
revision would be a guess. Raw clones/objects remain under
`/tmp/universe-boost-regex-500` and `/tmp/universe-provenance-lua`.

## Grok / next-executor handoff contract

The Boost.Regex header-version check is closed as a bounded no-match. Product
Lead accepted the derived receipts as an external-candidate residual under
[`PD-RELEASE-2026-0801-05-PROVENANCE-A-ACCEPT`](../product-decisions/RELEASE-2026-0801-05-provenance-a-accept.md).
Preserve the current immutable Vendor and Luna bytes. Do not continue
mixed-header search. The Luna derivation is complete for Phase A and should
not be searched again unless a new official repository/archive is named. Stop
before any Phase B resource replacement, Vendor rebuild/publication, manifest
update, RC claim or App Store Connect action unless a new Assignment
authorizes it.

### Repository checkpoint

- Branch/HEAD at handoff: `main` / `4fd3ce70d9acfc54472923fb7d66ff0589e11f6d`.
- This Phase A Assignment and evidence are currently untracked in the shared
  release worktree. The worktree also contains the authorized license UI,
  offline notices, export declaration and other release-document changes from
  the parent task. A new executor must not reset, overwrite or selectively
  clean those ambient changes.
- Phase A changed documentation only. All recompilation products and upstream
  clones are disposable under `/tmp` or `/private/tmp`; no Vendor/resource
  byte, manifest, Swift source, App Store field, branch or remote was changed
  by Phase A.
- `git diff --check` passed after status synchronization. No app/test suite was
  rerun because Phase A itself is docs-only and its compiler invocations were
  artifact comparisons rather than production builds.

## Next safe command

None inside Phase A. Product Lead accepted the receipts
([`PD-RELEASE-2026-0801-05-PROVENANCE-A-ACCEPT`](../product-decisions/RELEASE-2026-0801-05-provenance-a-accept.md)).
Human Product Owner reported saving content-rights “Yes”, primary category
`工具` and secondary category `效率` under the parent materials Assignment. Do not
compile further Boost.Regex mixes against the shipped `types.o`.
