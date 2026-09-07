# ADR 0034: Multi-Scheme Resource Ownership

## Status

**Proposed — 未批准，2026-09-07。**

本轮仅授权规划。本文不替代 Accepted ADR 0006 / 0032 / 0033；不授予实现、数据恢复、merge 或 Release 权限。接受前复核编号是否被其他已合并分支占用。

**Numbering check (`2026-09-07`):** `main` `2816009` 与本分支 `codex/scheme-delivery-fix`（规划前提交 `5cec512`）的 `docs/architecture/decisions/` 均无既有 `0034`。若并行分支先合入同号，接受前改号，不静默覆盖。

## Context

内置 Luna 按 ADR 0033 把 Prelude `default.yaml` 当作官方不可变闭包的一部分，部署前按 receipt 校验字节。可下载雾凇的 `rime-ice-plan-1` 允许安装同名 `default.yaml`；万象 `wanxiang-plan-1` 跳过该文件。雾凇卸载列表不含 `default.yaml`，因此覆盖一旦发生，卸载也不会自动恢复官方字节。

真机已定位 `resource_preparation` failed（operation `4169e168-de24-4e81-916a-e8d1f4d4a572`），但具体 `InstallationError` 尚待生产路径复现。雾凇 schema 仍 `__include` / `import_preset` 引用 `default`；T9 同样依赖。简单跳过该文件不保证上游行为。

RIME 官方允许配置替换及 custom patch；配置引用不提供多个发行包之间的文件所有权隔离。共享 `lua/` 前缀也不是所有权证明（TD-011）。详见 [实施计划的事实、官方依据与选项](../../plans/scheme-resource-ownership-and-coexistence-plan.md)。

需要一个跨方案的文件归属决策，而不是继续让安装顺序隐式决定全局有效配置。

## Decision

**尚未作出绑定 Decision。** 以下为提交 Architecture / Product 审查的候选，不是现行合同。

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

1. 按计划 P0 在生产安装链上复现并记录真实失败类型。
2. 完成递归依赖/同名文件审计；证明候选 A 可保真，或提交明确产品差异。
3. Human Product 与独立 Architecture 就计划 §5.1 决策点作出书面结论。
4. 仅在接受后实现适配安装、ownership receipt 与有界恢复；独立 Quality/Architecture 复审。
5. 真机验证内置 / 雾凇 / 万象安装顺序、卸载与失败回滚。
6. 编号若冲突则改号后再接受。

在 1–3 完成前，本 ADR 保持 Proposed。

## Related Documents

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
