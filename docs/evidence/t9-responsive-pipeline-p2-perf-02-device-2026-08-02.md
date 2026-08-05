# T9-RESPONSIVE-PIPELINE-001 / P2-H-06 真机运行证据

状态：**Partial — A/B 真机观察完成，合同与 validator 残余条件保持开放**  
日期：2026-08-02（Asia/Shanghai）

本记录承接 [`P2-PERF-02 Release-like Assignment`](../assignments/t9-responsive-pipeline-001-p2-perf-02-release-like.md)。本次只做已授权的 iPhone 13 Pro 运行取证、诊断日志导出、分析和恢复；没有修改生产逻辑、默认 gate、ADR 0025 或 Product Gate。

## 运行边界

| 字段 | 值 |
|---|---|
| Fixture | `jintiandetianqizhenbucuowomenchuquwanba`（39 个九宫格字母键） |
| Host | Reminders 空列表/标题输入位置；software keyboard；Universe Keyboard 中文九宫格 |
| Human 操作 | 只手动点击可见字母分组键；未点数字页、Path 或候选；未使用坐标自动输入 |
| Device | iPhone 13 Pro（`iPhone14,2`）；UDID `00008110-000A08440198801E` |
| Device CoreDevice | `DE65EBE1-463E-5EB4-9694-F6DCBFC04028` |
| OS | iOS 27.0（`24A5390f`） |
| Source HEAD | `3585a540ba8389673acd49128d87040ac9619f27` |
| Worktree | dirty（63 个既有变更；本次未覆盖、未暂存、未提交） |
| Bundle | `com.DoubleShy0N.Universe-Keyboard`，`1.0 (1)` |
| Scale | `0=最卡，4=最流畅`（本次在人工报告固化前纠正了先前不直觉的方向） |

## A/B 包指纹

| 臂 | 配置与 flags | App SHA-256 | Keyboard.appex SHA-256 |
|---|---|---|---|
| A | Release；`T9_AUTO_ANCHOR_DEVICE_PREFLIGHT`；未定义 responsive flag；无 `T9_AUTO_ANCHOR_*_ENABLED` | `ee176c6652ac21e6b8a660a47fb809bf371deb959d4f494ac119277e9fbb5229` | `4fde6e616b16b9e491572ed2b9f422116fccd64eec8d401948799c2eb1a65708` |
| B | Release；`T9_AUTO_ANCHOR_DEVICE_PREFLIGHT` + `T9_RESPONSIVE_DEVICE_PREFLIGHT_ENABLED`；无 `T9_AUTO_ANCHOR_*_ENABLED` | `ff727c47d572361a9c42465bdf855effd6cc72550f5982d07c3c912d9ba349da` | `b67f254c54bbc4134d9d7f05fd9fd409571ba8f4c4bda2419d631e2565a243d5` |
| Restore | 普通 Release；未注入 preflight flags | `3c9aa210fe80b9631e0f3bcc224d22da94ba2da50e700cb42e6ab2b3359e30c9` | `60ea7cafa58f38fa2ce2216509078e64ad08974aa1808b273a8e17df21ffbb87` |

两个诊断臂均为开发签名的 Release-optimized 内部包，不是 App Store Release 或 iOS 26.0 RC 证明。

## Run token 与日志来源

| 臂 | Run token | 原始 App 诊断日志来源 | 原始日志 SHA-256 |
|---|---|---|---|
| A | `S6A-0B1C2D3E4F5061728394A5B6C7D8E9F0` | App Group `rime_diag_log`，按 A 的 `T9DEVICE` 起点截取 | `ff4b332c18fe942f6a5394f129cd62c0ef0007278012fbd814da814b814be7fd` |
| B | `S6A-9D6B7A3C1E2F4A5B8C0D6E7F9A1B2C3D` | App Group `rime_diag_log`，完整导出后按 B token 解析 | `385c74a60ea2efd434fe08ee284ef8927f4009dc2b8713a049c7d3549633859c` |

日志取自应用已有的 App Group 诊断存储；没有新增记录机制，也没有读取提醒事项内容。原始导出中只出现长度、计数、时间、session identity、geometry 和 enum-like marker；未发现 raw pinyin、候选文本、宿主文本或非 ASCII 内容。

## Human report

| 臂 | 漏键 | 重键 | 候选消失 | 键盘退出 | 主观报告 | 分数（0=最卡，4=最流畅） |
|---|---|---|---|---|---|---:|
| A | 无 | 无 | 无 | 无 | 主观上比 B 稍微卡顿 | **3/4** |
| B | 无 | 无 | 无 | 无 | 整体蛮流畅 | **4/4** |

## 直接运行事实

### A：同步 gate-off

- `T9DEVICE schema=v1 marker=T9DEVICE_DISABLED gate=off measurement=on`；
  `T9RESP marker=PATH path=sync dualGateRequested=0 dualGateActive=0`。
- `T9SEG` action/event **1…39** 连续，全部 `committed=false`；native session
  identity `4444243096`，39 条均 `validBefore/After=true` 且保持稳定。
- prepared/execution geometry 使用同一 digest
  `1e4c12c19d5c7add52dd0badb190ca4432abebac4e2cd1617c36bb5c190930b2`。
- 观察到 6 条 `SLOW RIME`，最高 `processKey api≈200.7 ms`。
- `T9SEG` 总耗时中位约 `15.8 ms`、最大 `202.0 ms`；UI 中位约 `5.3 ms`，RIME
  中位约 `9.0 ms`。

### B：thread-affine responsive gate

- `T9DEVICE ... gate=off measurement=on` 仍只表示 auto-anchor 设备 gate 关闭；
  responsive gate 由 `T9RESP PATH path=thread-affine dualGateRequested=1 dualGateActive=1`
  和 `READY bootstrap=config-only session=owner-thread` 证明。
- `T9SEG` action/event **1…39** 连续，全部 `committed=false`；native session
  identity `4712770776`，39 条均 `validBefore/After=true` 且保持稳定。
- prepared/execution geometry 使用同一 digest
  `ee6dac9fbbeb6286c06daf5ec709621193958253287275b4eb8ac15bf11d64f2`。
- 观察到 6 条 `SLOW RIME`，最高 `processKey api≈202.2 ms`。
- ACCEPT 共 39 条；VISIBLE 共 42 条，其中 6 条是 provisional、36 条是 engine；
  `T9SEG` 接受热路径总耗时中位约 `0.3 ms`、最大 `2.3 ms`。
- rev 16、25、33 只有 provisional visible，没有对应的 epoch-bound publish；因此
  B 不能按当前合同写成 Complete。

## Validator 结果

使用项目内 `T9ResponsiveEvidenceValidator` 对同一 App 诊断日志执行只读解析。由于现有
隐私 deny-list 将 `SLOW RIME ... candidates=12` 这一计数摘要识别为敏感字段，原始日志
结果会被标为 `Blocked`；这不是发现候选文本，而是字段名规则的误识别。为区分运行事实与
该规则影响，同时执行了排除这些慢调用摘要的 marker-only 对照：

| 臂 | 原始日志结果 | marker-only 对照 | 直接缺口 |
|---|---|---|---|
| A (`sync`) | `Blocked`：`privacy-sensitive-content`、`publish-marker-missing`、`accept-revisions-not-complete` | `Partial`：`publish-marker-missing`、`accept-revisions-not-complete` | 当前 validator 对 sync expectation 仍要求响应式 ACCEPT/PUBLISH；这与 A“仅 active 时记录 publish”的合同语义不完全对齐 |
| B (`thread-affine`) | `Blocked`：`privacy-sensitive-content`、`epoch-bound-publish-incomplete` | `Partial`：`epoch-bound-publish-incomplete` | rev 16/25/33 缺 epoch-bound publish；provisional visible 已保留 |

因此本次结果是“真实 A/B 运行事实已取得，但合同判定仍为 Partial/Blocked”，不得升级为
P2-PERF-02 Complete、ADR 0025 Accepted、Product Gate 或 Release 默认开启。

## 恢复与清理

- A/B 两个 consumed envelope 均按 token 精确 cleanup；matrix registry 也已 finalize。
- 清理后只读核验：`t9_s6a_run_envelope` 与 `t9_s6a_matrix_tokens` 不存在，
  `rime_diag_log` 仍保留；没有执行提醒事项删除、RIME/userdb reset、container wipe 或卸载。
- 普通 gate-off Release 已替换安装成功；安装输出 database sequence number 为 `3680`。
- 恢复后设备仍为 `connected` 的 iPhone 13 Pro；未再向键盘注入输入。

## 已证明与未证明

已证明：在同一真实 iPhone 13 Pro、同一 39-key 手动 fixture 下，A/B 都保留了 39 条
完整性记录、稳定有效的 native session 和一致 geometry；B 的接受热路径显著短于同步 A，
且用户报告 B=4/4、A=3/4。

未证明：B 每个 revision 的 epoch publish 合同、A 的 sync validator 语义闭合、jetsam/内存
峰值、多轮/多设备复现、iOS 26.0 Release RC、签名归档/TestFlight/App Store、Product Gate
或用户可见 SLO。真实设备证据只支持 bounded direction observation，不能单独授权生产接线。

建议下一步由独立 Architecture / Quality 针对本记录复核两件事：

1. 明确 A sync arm 是否应跳过响应式 ACCEPT/PUBLISH 要求，或补一个独立的 sync validator 合同；
2. 决定 rev 16/25/33 的 provisional→engine coalescing 是否要补 epoch-bound publish，随后再
   评估是否值得另行授权生产接线。
