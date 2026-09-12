# ADR 0034: Multi-Scheme Resource Ownership

## Status

**Proposed — 未批准，2026-09-07。**

本轮仅授权规划。本文不替代 Accepted ADR 0006 / 0032 / 0033；不授予实现、数据恢复、merge 或 Release 权限。接受前复核编号是否被其他已合并分支占用。

**Numbering check (`2026-09-07`):** `main` `2816009` 与本分支 `codex/scheme-delivery-fix`（规划前提交 `5cec512`）的 `docs/architecture/decisions/` 均无既有 `0034`。若并行分支先合入同号，接受前改号，不静默覆盖。

**Numbering re-check (`2026-09-12` Accept prep):** `main` @ `be91ca5`（含 #102 `a6fc6f0`）仍仅一份 `0034-multi-scheme-resource-ownership.md`。Status **仍为 Proposed**。

## Context

内置 Luna 按 ADR 0033 把 Prelude `default.yaml` 当作官方不可变闭包的一部分，部署前按 receipt 校验字节。可下载雾凇的 `rime-ice-plan-1` 允许安装同名 `default.yaml`；万象 `wanxiang-plan-1` 跳过该文件。雾凇卸载列表不含 `default.yaml`，因此覆盖一旦发生，卸载也不会自动恢复官方字节。

P0 已在生产 `installSchemaFiles` + `install()` 上复现：有 builtin receipt 时 Ice 覆盖 `default.yaml` 导致 `.byteCountMismatch`。P1 清单见 [`scheme-delivery-source-state-001-p1-2026-09-07.md`](../../evidence/scheme-delivery-source-state-001-p1-2026-09-07.md)：同名不同字节目前只有 `default.yaml`；Ice/T9/`melt_eng` 仍 `__include` / `import_preset` 该文件（含 `digit_separators`）。简单跳过不保证上游行为。Ice `s2t.json` 与内置 OpenCC 共享；`lua/` 与 `opencc/emoji*` 卸载列表未覆盖。

RIME 官方允许配置替换及 custom patch；配置引用不提供多个发行包之间的文件所有权隔离。共享 `lua/` 前缀也不是所有权证明（TD-011）。详见 [实施计划的事实、官方依据与选项](../../plans/scheme-resource-ownership-and-coexistence-plan.md)。

需要一个跨方案的文件归属决策，而不是继续让安装顺序隐式决定全局有效配置。

## Decision

**尚未 Architecture Accepted。** Human Product Owner 已于 `2026-09-07` 指定按候选 A 实现：共享 `default.yaml` 禁止被下载方案覆盖；万象继续 skip；雾凇改为独立预设。下列条文指导本切片实现，不是独立 Architecture Gate。

候选 A：主 App 保持单一公共配置基线与既有官方字节；第三方方案所需预设使用独立名称并显式适配依赖；每一安装路径拥有明确的 owner 或批准的共享关系，安装/升级/卸载均依据 manifest/receipt。

若 A 在先决条件满足后被接受，预期约束为：

- 保留来源归档与适配产物的不同身份；plan、处理版本和 staged 摘要随适配变更。
- App 管理的全局行为通过已批准 overlay 表达；方案行为与用户自定义的优先级须在接受前明确。
- 新方案安装不得无声更改无关方案的有效配置；共享字节相同也不能省略卸载引用关系。
- 历史污染恢复必须验证来源/范围并可回滚，不使用失效 receipt 授权任意删除。
- 主 App 仍为唯一部署写者，Extension 只消费一致状态。
- 不通过实现偷偷修改 ADR 0033 的官方不可变字节合同；若必须改官方文件，先修订 0033。
- 不声称关闭 ADR 0006 / TD-001，除非另有明确还债授权。

## Alternatives Considered

- **B. 安装时自动合并各包 `default.yaml`：** 拒绝作为默认建议。冲突键、列表与补丁优先级未定义，结果随安装顺序变化。
- **C. 每方案隔离运行资源目录：** 保留备选。隔离命名空间，但扩大 session、同步、用户词典、磁盘与切换/回滚范围；仅当 A 无法保真时再单独评估。
- **保持现状（雾凇覆盖、内置校验失败即部署失败）：** 拒绝作为产品终点。真机已观察到下载/安装成功后的部署失败；卸载也不能恢复官方 `default.yaml`。可在 P0 调查期间暂时保持，但不能当作归属策略。
- **安装雾凇时直接丢弃其 `default.yaml`：** 拒绝作为未审计结论。引用链未闭合前会静默丢失 punctuator 等预设行为。

## Consequences

接受 A 之前：本文不改变运行时行为。

若后来接受 A：

- 增加方案适配与来源审计成本，避免安装顺序隐式决定全局行为。
- 下载方案的 staged identity / plan revision 会因引用改写而递增，必须重算 Lua 开/关摘要。
- 设置 UI 仍按方案呈现，但公共文件不再属于某一个下载包。
- 已安装设备需要有界恢复，而不是静默覆盖。

## Risks

- 把静态 `default.yaml` 冲突误当成已证实的唯一真机根因，修错分支。
- 引用改写不完整（`__include`、Lua `require`、T9）导致「部署成功、输入行为漂移」。
- 恢复逻辑信任失效 receipt，删除用户或第三方仍需要的文件。
- 借共存实现扩大成 TD-001 原子安装或任意方案包支持。
- Proposed 文本被后续实现者当成 Accepted。

## Follow-up Work

1. ~~按计划 P0 在生产安装链上复现并记录真实失败类型。~~ 完成：`.byteCountMismatch`；真机枚举仍未发出。
2. ~~完成递归依赖/同名文件审计。~~ 工程清单已落盘（含 CNB 万象 zip）。Ice/T9/`melt_eng` 的 `default` 引用已改独立预设路径（P2）。卸载按文件归属 / exact-hash，不整目录删除 `lua/` 或 `opencc/`。Wanxiang 与 Ice Lua **无路径/基名碰撞**；双方现均走独立预设（Ice `rime_ice_preset`；Wanxiang `wanxiang_preset` via Scheme Platform P2）。
3. Human Product 与独立 Architecture 就计划 §5.1 决策点作出书面结论。Human 已指定按候选 A 实现，并给出 Human-attested 真机：[P3 device](../../evidence/scheme-delivery-source-state-001-p3-device-2026-09-07.md)。Architecture 首审发现 P3 恢复未进入事务 mutation 账本并使用静态 backup；Codex takeover 增量修复后，delta 复审关闭这两个阻断。该复审不是 Acceptance。**Accept prep（本注）**附 §5.1 推荐 disposition 表（见下）；**正式写入 Accept 包仍须 Human「Accept ADR 0034」** — 本注 **不**改变 Status。
4. 工程落地指针（**Accept prep 2026-09-12 刷新**；取代过时的 `codex/scheme-delivery-fix` `b90d236` /「独立 Quality 尚无 delta」叙述）：
   - PR #100 已合入 `main` @ `814abfd`（共存 / Ice 独立预设 / fail-closed 事务切片）。
   - Scheme Platform 经 PR [#102](https://github.com/shchnk1103/Universe-Keyboard/pull/102) 合入：merge `a6fc6f0`；merge-record docs `main` @ `be91ca5`。P1–P3 Exit certified；Platform Assignment **仍 Active**（**no Close**）。
   - Wanxiang P4 Assignment **Closed**（narrow A34-R1 Exit）；残差 **A34-R1 Closed（narrow）**。
   - 独立 Quality 已有可引用 delta（含 Wanxiang P4 S5 IQ Pass with conditions；Platform P1 IQ Pass with conditions）。**这不是 ADR Accepted。**
5. 真机 / 设备限度：Human-attested Ice 重下可部署等仍有效；Device-attested 全 Assignment / 失败回滚未升格。未知改动仍 fail-closed。A34-R2（Ice `dofile`）→ `tech_debt:TD-011`。
6. 编号若冲突则改号后再接受。`main` @ `be91ca5` 抽样：`docs/architecture/decisions/` 仍仅一份 `0034-*`。

### §5.1 disposition（Accept **prep** draft — 推荐，非 Status 变更）

| # | Topic | Recommended disposition |
|---|---|---|
| 1 | 采纳候选 A | **Accept**（唯一长期归属策略；B/C 拒绝为默认） |
| 2 | 全局设置 / 方案预设 / 用户 `*.custom.yaml` 优先级 | **Accept** 方向：官方不可变基线 + App overlay + 方案独立预设 + 用户 custom；细节保持 ADR 0033 overlay 合同 |
| 3 | 允许的上游行为差异 | **`accept`**：Ice / Wanxiang 经独立预设保真；不要求与 Prelude 逐键一致 |
| 4 | 同名字节相同共享 / 引用计数 | **`tech_debt` / 有界**：Ice `namedList`；Wanxiang Lua `exactHash`；非通用引用计数器 |
| 5 | 历史污染恢复 | **Accept** 已知 Ice fingerprint 有界恢复；未知修改 fail-closed（已实现） |
| 6 | 活跃卸载回退 | **Accept**：Luna-only（Human 已 supersede peer-prefer B） |
| 7 | 角色任命 | **`out_of_scope`**（会话角色不写入 ADR 决策体） |

Architecture 对候选 A 决策层已无 P0 阻断；Verdict 仍为 **Conditional Accept**（A34-R2→TD-011；§5.1 正式 Accept-commit；Status 变更仅 Human Accept 后）。**在 Human 书面 Accept 之前，本 ADR 保持 Proposed。**

**2026-09-09：** Human 批准单独开一轮 Architecture Accept 复审清单（非 Acceptance）：[`adr-0034-architecture-accept-checklist-2026-09-09.md`](../../reviews/adr-0034-architecture-accept-checklist-2026-09-09.md)。独立 Architecture 结论已出具：[`adr-0034-architecture-accept-review-2026-09-09.md`](../../reviews/adr-0034-architecture-accept-review-2026-09-09.md) — **Conditional Accept**。在 Human 书面 Accept 之前，Status **仍为 Proposed**（本注记不改变 Status）。

**2026-09-12 Accept prep：** Human 授权 draft PR #101 **Accept prep only**（[#101](https://github.com/shchnk1103/Universe-Keyboard/pull/101)）。Freeze：`main` @ `be91ca5` / merge `a6fc6f0`。证据：[`adr-0034-accept-prep-2026-09-12.md`](../../evidence/adr-0034-accept-prep-2026-09-12.md)。A34-R8-style Follow-up tip 刷新已落盘；**prep ≠ Accept**；Status **仍为 Proposed**；leave #101 draft；Platform stays Active（no Close）。

## Related Documents

- [Architecture Accept 复审清单 2026-09-09](../../reviews/adr-0034-architecture-accept-checklist-2026-09-09.md)
- [Architecture Accept 复审结论 2026-09-09（Conditional Accept；非 Acceptance）](../../reviews/adr-0034-architecture-accept-review-2026-09-09.md)
- [实施计划](../../plans/scheme-resource-ownership-and-coexistence-plan.md)
- [`SCHEME-DELIVERY-SOURCE-STATE-001`](../../assignments/scheme-delivery-source-state-001.md)
- [`ADR 0001`](0001-main-app-owns-rime-deployment.md)
- [`ADR 0003`](0003-shared-container-ownership.md)
- [`ADR 0006`](0006-schema-install-transaction-model.md)
- [`ADR 0032`](0032-verified-scheme-source-recovery-and-integrity-classification.md)
- [`ADR 0033`](0033-main-app-owned-offline-rime-resource-closure.md)
- [`RIME_SCHEME_MANAGEMENT.md`](../../RIME_SCHEME_MANAGEMENT.md)
- [`TD-001`](../../TECH_DEBT.md#td-001-atomic-schema-installation)
- [`TD-011`](../../TECH_DEBT.md#td-011-multi-scheme-lua--advanced-input-compatibility-雾凇--万象)
- [F-02 upstream pin audit](../../evidence/rime-builtin-luna-quality-f02-upstream-pin-audit-2026-08-29.md)
