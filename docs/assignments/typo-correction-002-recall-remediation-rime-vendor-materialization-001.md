# Assignment: TYPO-CORRECTION-002-RECALL-REMEDIATION-RIME-VENDOR-MATERIALIZATION-001

Policy version: 1.0.0

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Active` |
| **Phase** | 固定 pin 的 RIME iOS binary dependency 已物化并通过 provenance verify；等待回到 publication preflight。 |
| **Non-claims** | 不代表 RIME 部署正确、真实设备行为、INT-003、QA-001、180 ms、Product/Quality/Release Gate、commit、push、PR、merge 或 Release。 |
| **Next** | 绑定新 vendor provenance snapshot，重跑 RimeBridgeTests、App+Keyboard Debug tests 和 Release build；不把 materialization 单独视为 publication。 |
| **Residuals** | vendor materialization 只解决构建依赖缺失；runtime canonical group mapping、sidecar/runtime 接线与 contextual 7/8 `UNKNOWN` 不变。 |

## Authority

- **Assignment Authority:** Human Product Owner / Product Lead, current Codex task, `2026-09-20 Asia/Shanghai`。
- **Decision Source / Date:** [`publication preflight evidence`](../evidence/typo-correction-002-recall-remediation-publication-preflight-2026-09-20.md)。
- **Parent Assignment:** [`TYPO-CORRECTION-002-RECALL-REMEDIATION-PUBLICATION-PREFLIGHT-001`](typo-correction-002-recall-remediation-publication-preflight-001.md)。
- **Matching Authorization:** [`AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-RIME-VENDOR-MATERIALIZATION-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-RIME-VENDOR-MATERIALIZATION-001.md)。

## Boundary

### Scope

1. 只使用 `config/rime-vendor-manifest.env` 声明的不可变 Release asset。
2. 运行 `bash scripts/ensure_rime_vendor.sh fetch`，允许写入当前隔离 worktree 的被忽略 `Packages/RimeBridge/Vendor/` 与受控临时目录。
3. 运行 `bash scripts/ensure_rime_vendor.sh verify`，并独立记录 archive、receipt、framework inventory、Info.plist/static-library 与 iOS slice provenance。
4. 记录 materialized dependency 的新快照；随后只把它交回 publication preflight，不自动发布。

### Non-goals

- 不修改 Swift、测试源、Xcode 工程、`config/rime-vendor-manifest.env` 或 vendor 脚本。
- 不使用主仓库 Vendor、旧目录、Homebrew、macOS library、source build 或替代 slice。
- 不部署 RIME schema/资源、不运行键盘产品 Run、不改 runtime scheduler/controller。
- 不执行 commit、push、PR、merge、TestFlight、Release 或关闭 parent/child Assignment。

## Frozen Inputs

| Field | Value |
|---|---|
| Worktree | `/private/tmp/universe-keyboard-typo-correction-002-recall-preflight-001` |
| Branch | `codex/typo-correction-002-recall-preflight-001` |
| HEAD | `d0df9a6342d8209b5aa7f9826541d0b430b9da04` |
| HEAD tree | `27ae44bec1b157e391ef1e0b859db3a068e21ba8` |
| Frozen remediation manifest | `c135c78b435fb2278fc734ed354bbf9e396266cdfffe878aef8a887b22c30ac0` |
| Vendor manifest SHA-256 | `a67cf99046a180c9e648755c793182529f2937f3d0469e3b59d6f63638802804` |
| Vendor script SHA-256 | `30dac2bd1166b119430da6860133cf010647f708bca87dc861ddb2349301461a` |
| Vendor version | `rime-vendor-ios-1.16.1-lua.1-octagram.1` |
| Archive SHA-256 | `d17aab9a8b08b5901ab583c143b0a8a03994e36fe092309fd14c5bee31399dd9` |
| Framework count | 12 |

## Required evidence

- Archive bytes match the pinned SHA-256 before extraction.
- Receipt matches the pinned version and archive SHA-256.
- Exactly the 12 manifest frameworks exist; each has valid `Info.plist` and static-library payload.
- Required device `ios-arm64` and simulator slices match [`RIME Binary Artifacts`](../architecture/rime-artifacts.md)。
- No source/config/vendor-script drift occurred; the new snapshot is explicitly distinguished from the prior blocked preflight.

## Gates and handoff

- **Entry:** current blocked preflight, exact pinned manifest, and this Authorization are present。
- **Exit:** `fetch` and `verify` pass, provenance is recorded, and no source/config drift is observed；otherwise stop with the exact failure。
- **Handoff:** return to publication preflight for a new manifest and remaining Xcode gates；materialization alone is not publication authorization。
- **Stop:** checksum mismatch, receipt mismatch, unexpected framework, invalid slice, network ambiguity, source drift, or request to broaden scope。

## History

- `2026-09-20 Asia/Shanghai`：publication preflight 因隔离 worktree 缺少 12 个 RIME xcframework 阻塞；Product Owner 授权建立本 bounded materialization Assignment。
- `2026-09-20 Asia/Shanghai`：按固定 pin 完成 fetch；archive SHA-256、receipt、12-framework inventory、Info.plist/static-library 与 iOS device/simulator slice 核对通过；未修改源码、manifest 或脚本。
