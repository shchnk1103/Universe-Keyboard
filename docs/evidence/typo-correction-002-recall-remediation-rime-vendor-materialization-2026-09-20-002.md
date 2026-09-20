# TYPO-CORRECTION-002 pinned RIME vendor materialization — staging 002

- Materialization ID：`TC2-RECALL-VENDOR-20260920-002`
- Authorization：`AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-RIME-VENDOR-MATERIALIZATION-002`
- Worktree：`/private/tmp/universe-keyboard-typo-correction-002-recall-publication-staging-001`
- Branch：`codex/typo-correction-002-recall-publication-staging-001`
- Bound HEAD：`162b09fd58ba60538a944026b1902efa405c75aa`
- HEAD tree：`92c5047c5d1a6dd6a751eb5344117f8138c14ef2`

## Pinned artifact

| Field | Value |
|---|---|
| Version | `rime-vendor-ios-1.16.1-lua.1-octagram.1` |
| Archive SHA-256 | `d17aab9a8b08b5901ab583c143b0a8a03994e36fe092309fd14c5bee31399dd9` |
| Vendor tree SHA-256 | `d446b0a4cdd40d42f53359ba8a7677d625ac8461c60ecfe92f90ca73e8df14fd` |
| Receipt | `version=rime-vendor-ios-1.16.1-lua.1-octagram.1`, `sha256=d17aab9a8b08b5901ab583c143b0a8a03994e36fe092309fd14c5bee31399dd9` |

## Verification

- `bash scripts/ensure_rime_vendor.sh fetch`：通过；archive SHA-256 匹配固定值。
- `bash scripts/ensure_rime_vendor.sh verify`：通过；12/12 framework inventory 通过，Info.plist 与 static-library payload 结构有效。
- Vendor tree file count：`630`（含 receipt）。
- 与前一轮已绑定 `d446b0a4…` 的旧 worktree 执行 `diff -qr`：无差异；新 staging tree 与已验证 vendor tree 字节一致。
- 未修改 checked-in vendor manifest、源码、工程或测试文件。

## Boundary

本证据只证明新 staging worktree 的固定构建依赖已物化并可验证，不证明 RIME deployment、Keyboard Extension runtime、真实候选、设备行为、INT-003、QA-001、paired performance、180 ms 或任何 Product/Quality/Release Gate。尚未生成质量测试 Run ID。

## Next handoff

vendor prerequisite 已满足。下一步可在本 staging worktree 建立新的 bounded quality Run ID，执行适用的 Swift format、KeyboardCore、RimeBridgeTests、App + Keyboard Debug tests 和 Release build；质量门仍不等于 publication 或 merge 授权。
