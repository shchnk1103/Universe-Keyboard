# 独立 P round2 评审：T4–T6

范围：仅审查冻结 packet 的 T4–T6；packet 双重身份已核对，58 项 allowlist 与 baseline 身份均无漂移。离线 reader helper 仅作证据定位工具，其输出不作为独立结论。独立检查了 helper 的 provenance 比较规则、原始 inventories、恢复动作、签名/恢复 receipts、测试摘要及健康回执。

## Scope / Evidence Matrix

| Criterion | 结果 | 证据与判断 |
|---|---|---|
| T4 | Covered | 两段 baseline 分开比较。初次 T0→旧 C7 恢复：应用数据树按协议排除根、container metadata plist 与 SplashBoard Snapshots 子树后，无 missing/added/changed；Snapshots 文件 SHA multiset 相同。恢复记录 117 项：main 覆盖 4、删除 46；App Group 恢复 51 文件、14 目录、2 链接。fresh post-health backup→最小恢复：应用库存无既有内容/metadata 差异；备份副本仅新增 provenance（main 865、Group 8、installed app 9 条），比较规则保留并核对所有原有 xattr 值。最终相对 postinstall 的系统根与 metadata 行均相同，快照 SHA multiset 相同；final-vs-postinstall 仅 3 项 TipKit 内容变化，与授权恢复动作一致。第二次恢复 Group 写入 0、删除 0。两段 installed-app 的两个可执行文件只显示 install_uuid 改变，最终旧 C7 payload、双签名 receipts 有效。两诊断键在健康机器回执中仍缺失、默认关闭；Human 的完全访问/候选/提交正常是人工健康结果，不推为机器测量或完整字节相等。 |
| T5 | Covered | 冻结 Rime 20 与 AppKeyboard 10 个 raw skipped identities 保留；签名 Keychain 同一专项另有 1/1 pass，按当前阶段记录剩 29 项仍未验证。当前 Assignment 明确 Product 对这 29 项的处置尚缺。该依赖保持 open，skip 不计 passed，也不外推旧 v5/B/C7 的处置。 |
| T6 | Covered | 历史 T1 Partial/Hold 与旧数据保护停止记录保持不变。当前恢复对象仍是旧 C7 `ddd557…`，不是新候选 `43d85d…`；没有由本轮推出候选 runtime、Maps、Quality/Product/Release Gate 或 Release 结论。 |

**P 范围覆盖：Complete（T4–T6 均 Covered）。整体 T 接受：Hold。** 这是限定的独立范围意见；29 个 skip 的当前 Product disposition 仍是未完成依赖，不由本评审代替。

## Findings

- **P2-01 — P2 / Product Owner：** 当前阶段对 29 个未验证 skip 尚无 Product disposition。保持未验证和阻塞状态；本评审不接受、不豁免、不将其计为通过。
- **P2-02 — P3 / Quality record owner：** 首次与第二次恢复使用不同 baseline。归档及后续引用应继续按 T0→首次旧 C7 restore、fresh post-health backup→Keychain test-after→3 项最小恢复区分；复制副本新增 provenance 与 install_uuid 身份变化单独分类，不宣称 all-metadata-exact。

## 精确证据定位与范围限制

- 初次链：`docs/evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-t0-validation-2026-10-03.md`；`...-c7-ui-t2-restore-validation-2026-10-03.md`；T0 `before-inventories.json`、T2 `restored-inventories.json` / `postinstall-inventories.json`、T2 `restoration-actions.json` 与 `restore-verification.json`。
- 新鲜链：`...-c7-ui-keychain-continuation-validation-2026-10-03.md`；`...-c7-ui-keychain-minimal-restoration-validation-2026-10-03.md`；`...-c7-ui-keychain-minimal-restoration-health-validation-2026-10-03.md`；新鲜 `before/backup/test-after/test-after-backup/minimal-restoration postinstall/restored inventories`、minimal `restoration-actions.json` / `restore-verification.json`、`install-receipt.json` 与 `health-post-readback.json`。
- Skip 状态：`docs/evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-t1t2-validation-2026-10-03.md`、Rime/AppKeyboard skip 清单、Keychain `xcresult-summary.json`；当前 Assignment 的最近状态记录。
- 不覆盖新候选运行、设备操作、Map/LLDB、实现、Product 决策或 Release。未读取备份原内容。
