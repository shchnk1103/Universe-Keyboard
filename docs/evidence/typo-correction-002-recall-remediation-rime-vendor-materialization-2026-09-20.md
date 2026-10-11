# Evidence: TYPO-CORRECTION-002 pinned RIME vendor materialization

## Identity

| Field | Value |
|---|---|
| Assignment | [`TYPO-CORRECTION-002-RECALL-REMEDIATION-RIME-VENDOR-MATERIALIZATION-001`](../assignments/typo-correction-002-recall-remediation-rime-vendor-materialization-001.md) |
| Authorization | [`AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-RIME-VENDOR-MATERIALIZATION-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-RIME-VENDOR-MATERIALIZATION-001.md) |
| Worktree | `/private/tmp/universe-keyboard-typo-correction-002-recall-preflight-001` |
| Branch | `codex/typo-correction-002-recall-preflight-001` |
| Source HEAD | `d0df9a6342d8209b5aa7f9826541d0b430b9da04` |
| Source tree | `27ae44bec1b157e391ef1e0b859db3a068e21ba8` |
| Frozen remediation manifest | `c135c78b435fb2278fc734ed354bbf9e396266cdfffe878aef8a887b22c30ac0` |
| Vendor manifest SHA-256 | `a67cf99046a180c9e648755c793182529f2937f3d0469e3b59d6f63638802804` |
| Fetch script SHA-256 | `30dac2bd1166b119430da6860133cf010647f708bca87dc861ddb2349301461a` |
| Evidence status | `Pass — materialized dependency provenance` |

No product Run ID was created. This record proves build dependency materialization only; it is not RIME deployment or keyboard behavior evidence.

## Pinned archive

| Field | Value |
|---|---|
| Version | `rime-vendor-ios-1.16.1-lua.1-octagram.1` |
| URL | `https://github.com/shchnk1103/Universe-Keyboard/releases/download/rime-vendor-ios-1.16.1-lua.1-octagram.1/universe-keyboard-rime-vendor-ios-1.16.1-lua.1-octagram.1.zip` |
| Archive size | `42,329,296` bytes |
| Expected SHA-256 | `d17aab9a8b08b5901ab583c143b0a8a03994e36fe092309fd14c5bee31399dd9` |
| Observed SHA-256 | `d17aab9a8b08b5901ab583c143b0a8a03994e36fe092309fd14c5bee31399dd9` |
| Temporary archive | `/private/tmp/universe-keyboard-typo-correction-002-vendor-materialization-001/universe-keyboard-rime-vendor.zip` |

## Verification

- `bash scripts/ensure_rime_vendor.sh fetch` completed after archive checksum validation。
- `bash scripts/ensure_rime_vendor.sh verify` passed。
- Receipt contents:

  ```text
  version=rime-vendor-ios-1.16.1-lua.1-octagram.1
  sha256=d17aab9a8b08b5901ab583c143b0a8a03994e36fe092309fd14c5bee31399dd9
  ```

- Exactly 12 manifest frameworks were present; every framework had a valid `Info.plist` and static-library payload。
- The required device `ios-arm64` and simulator slice directories were present in all 12 frameworks。
- `Info.plist` entries matched the iOS contract: device `arm64`; simulator `arm64` for the three Boost frameworks and `arm64,x86_64` for the remaining nine frameworks。
- Materialized Vendor tree contained 630 files, including the receipt; aggregate tree SHA-256 was `d446b0a4cdd40d42f53359ba8a7677d625ac8461c60ecfe92f90ca73e8df14fd`。

Per-framework content aggregates:

| Framework | SHA-256 |
|---|---|
| `boost_atomic.xcframework` | `bd68451f99dd7a2939800e81ec915ce1ae9a78c9b03c606c99d8a83ad6d762cf` |
| `boost_filesystem.xcframework` | `fc52774fa242a894eaf4e445a3a80027a713cc67a868bc964168a62de38081df` |
| `boost_regex.xcframework` | `929cdc44b99d6455e71deeba9b0d7c4ff922e867836900d990d5f6b84485d2c3` |
| `libglog.xcframework` | `daac650261c6e08cf9e488547046fcf889f48c38d56dbaf8cb1e39fe292b0236` |
| `libleveldb.xcframework` | `021f8f017f1344d2776ec226753416a398454d6b53af637a95f9d0803177b420` |
| `liblua.xcframework` | `dc163122e8425c9eb19ef1d7715ba5e60b61ffb4ad3b3b33e000a320fa044bd3` |
| `libmarisa.xcframework` | `8a9aba0212327cbff10bcfd57dac792f417d4f4159816937ead26ad96caf3b3e` |
| `libopencc.xcframework` | `4a8100ffaf61c7bc1d1b5f6a51f69ff56241287d199a50ea53bc0d488016b0db` |
| `librime-lua.xcframework` | `cc1fbdd1584673bbba9ec74420e260851c48377fed83369e5ec0e3022b73614a` |
| `librime-octagram.xcframework` | `236e80bbb01484bbf947aa26ebac1c6925d240f1996b9f68e7edc69a6d123ede` |
| `librime.xcframework` | `50fd1a78a91ca6d7f0a59a4f55ba1f88453dadd233204b09d89fd1b546ea72cc` |
| `libyaml-cpp.xcframework` | `af3f520c48be24b80776b89bdffaa768937af3aa08a22837387da9310c4105cd` |

## Non-claims / handoff

The ignored Vendor directory is now available for the isolated build only. This does not authorize copying it to another checkout, changing the checked-in pin, deploying RIME resources, wiring runtime behavior, or publishing the remediation. The next step is a new publication-preflight snapshot followed by the three previously blocked Xcode gates.
