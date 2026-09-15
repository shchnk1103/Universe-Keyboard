# Build 55 Store 上传包预检证据

> **状态：** `Upload delivered — ASC processing pending; upload-only candidate`
>
> **日期 / 时区：** `2026-09-13 Asia/Shanghai`
>
> **Assignment：** [`RELEASE-2026-0801-04`](../assignments/release-2026-08-01-04-device-performance.md)
>
> **范围：** 只验证已生成的 Build 55 Store 导出包与 Archive/dSYM 映射；不把包级预检扩大为 Quality Pass、Product Gate、外部分发或 Beta Review 结论。

## Candidate Fact Tuple

| 字段 | 值 |
|---|---|
| Source commit | `main` @ `b8175129f26f787a6c7fee0be5977ebec46edf60` |
| RC tag | `testflight-v1.0-rc2-build55`（远端轻量标签；指向 `b8175129f26f787a6c7fee0be5977ebec46edf60`） |
| Xcode Cloud workflow | `Archive Pilot (No Distribution)`；Build `55`；Build ID `8ca1634e-9139-405a-aa5c-75c3d6919908` |
| Version / build | Store export: `1.0 (55)`; retained Archive embedded App/Extension metadata: `1.0 (1)` |
| App bundle | `com.DoubleShy0N.Universe-Keyboard` |
| Keyboard bundle | `com.DoubleShy0N.Universe-Keyboard.Keyboard` |
| Store IPA | `Universe Keyboard.ipa`；SHA-256 `b178c05530b92a207eb8aaf4e701c1db803fec728c3df702424c89944ee1c6fd`；`30,764,219` bytes |
| Archive | `Universe Keyboard Build 55 Archive for Universe Keyboard on iOS.xcarchive`；本机审计临时目录保留；embedded metadata is `1.0 (1)` |
| App executable | UUID `6898B44F-EF4F-3B46-93C8-BCE83668270A`；Store-export SHA-256 `80bf464910b7f946d75a7a23c71d96111f69dafa1489525c6be033297905f2f6` |
| Keyboard executable | UUID `C6C1758B-ECA2-3784-8EFA-22AF59B6CF25`；Store-export SHA-256 `bbeef3f59f67a190375afb2009e156566ccf0695fa3783dedff03d79d35343d3b` |
| App dSYM | UUID 与 App executable 匹配；DWARF SHA-256 `e93313058a4983af7a8d5f5d75aff751a53899becceb3329a7a9eea9bd88d5d0` |
| Keyboard dSYM | UUID 与 Keyboard executable 匹配；DWARF SHA-256 `d82a1ca71fec466acf23fd7be12431fd794392e8b7b77211732cda034434ec0f` |
| RIME manifest | `RimeBuiltin.manifest.json` SHA-256 `6aa2d28918b9146cdf417ddb369ba57907e5bbcc3e2ce2c9bc1280f1a6e7b233`；与 Archive 中的 manifest 相同 |

## Upload eligibility checks

| Check | Result |
|---|---|
| Export method | `app-store-connect` |
| `testFlightInternalTestingOnly` | `false` |
| Signing profile | `iOS Team Store Provisioning Profile` for App and Keyboard |
| Entitlements | `beta-reports-active=true`；`get-task-allow=false`；App Group 为 `group.com.DoubleShy0N.Universe-Keyboard` |
| Build metadata | Store export: `CFBundleShortVersionString=1.0` / `CFBundleVersion=55`; retained Archive/dSYM metadata: `CFBundleVersion=1`; minimum OS `18.0` |
| Symbols | `uploadSymbols=true`；App/Keyboard dSYM 已保留且 UUID 匹配 |
| Archive/export toolchain | Embedded metadata: Xcode `26.6 (17F113)`；iPhoneOS SDK `26.5 (23F81a)`；Build machine OS `25G83` |

## 判定边界

- 包级上传前提为 **Pass**；这不是 App Store Connect 已接受或已处理的证明。
- 本包的 Store 导出是从 Build 55 Archive 审计目录取得的现有产物；上传前必须再次对同一路径执行 SHA-256，避免临时目录产物被替换或失效。
- Archive ↔ 导出包关系已单独核对：代码映像 UUID、dSYM 和非身份资源清单一致；Xcode Cloud 导出日志明确传入
  `buildNumber=55`，但 retained Archive/dSYM 的 `CFBundleVersion` 仍为 `1`。因此“Build 55 Archive”表示
  导出阶段的候选来源，不把 Archive plist 本身称为 `1.0 (55)`。详见 [`Archive ↔ export reconciliation`](release-2026-09-13-build55-archive-export-reconciliation.md)。
- Build 55 的真机功能、雾凇九宫格、TD-003/004/005、共享容器边界和材料状态仍按各自证据记录，不因本预检改变。
- 本地当前 `HEAD=3139f8d` 是后续文档提交；它不属于这个 Store 包，也不得作为上传来源。
- 上传成功后的 ASC processing、内部组、外部分发和 Beta Review 必须分别记录和授权；本记录不授权后续动作。

## Archive ↔ export reconciliation addendum

只读核对确认：冻结 commit 的项目配置和 retained Archive 默认是 `1.0 (1)`；Store/Ad Hoc 导出日志都
明确提供 `buildNumber=55`，并从 Archive 产品树进入导出流程，最终包和导出摘要为 `1.0 (55)`。App/Keyboard
UUID 与 dSYM、非身份资源清单一致，所以代码映像关系为 **confirmed**；Archive plist 与导出包构建号并不相同，
该差异保留为元数据边界，不推断 Xcode 内部改写原因。完整回执：[`Build 55 Archive ↔ export reconciliation`](release-2026-09-13-build55-archive-export-reconciliation.md)。

## Upload-only 结果

| 字段 | 值 |
|---|---|
| Delivery tool | Apple Transporter `26.30.2 (173002)` |
| Destination | App Store Connect App `6804236252` |
| Delivered | `2026-09-13 15:47 Asia/Shanghai` |
| Transporter status | `已交付` |
| ASC status at last observation | `APP 正在处理` |
| Groups / distribution / Beta Review | 未执行 |

Transporter 的“已交付”确认文件已发送到 App Store Connect；它不等于 App Store Connect 已完成二进制处理，也不等于已向任何测试员开放。

## 下一动作

在确认临时包仍能按上述哈希复核后，已创建远端轻量标签 `testflight-v1.0-rc2-build55` 到 `b8175129…`；随后只上传该 Store IPA。任何 ASC 处理完成后的分组、外部测试开放、Beta Review 或发布动作另行停留在 Human/Product Gate。
