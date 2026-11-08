# 朙月九宫格（luna_pinyin_t9）知识卡

写于 2026-11-08，依据 LUNA-PLANNER-001（PR #279，main `38c3930d`）与 LUNA-T9-001 的 PR1 取证。本页只记已验证的事实、已定的决定和未决项；细节与证据在任务报告里（见文末“证据位置”）。目标读者：以后做朙月九宫格 PR2、雾凇或万象九宫格，以及“键盘自有适配层”的人。

## 1. 它是什么
- 朙月九宫格不是一份独立发布的方案：运行时的 `luna_pinyin_t9` 由内置 `luna_pinyin.schema.yaml` 经 `LunaT9SchemaCompatibility`（`Packages/KeyboardCore`）确定性改写得到，改写输出的 SHA-256 记在 `outputSHA256` 常量里，仓库夹具 `Packages/RimeBridge/Tests/RimeBridgeTests/Fixtures/LunaT9/variant1.schema.yaml` 必须与改写输出逐字节相同。确定性改写对未知源、缺失或重复锚点及输出哈希不匹配失败关闭；grammar 存在时由 planner 的简繁与 algebra 闸门拒绝放行。
- 状态（2026-11-08）：生产 planner 已能为 `luna_pinyin_t9` 生成简繁、模糊音与学习的覆盖；九宫格功能本身未接线（未在 `NineKeySchemeRegistry` 登记，没有设置与键盘入口）。接线属 LUNA-T9 的 PR2。

## 2. 补丁链与 planner（PR #279 的结论）
- 旧隔离诊断中，九键 schema 的顶层 patch 未显式消费 luna_pinyin_t9.custom，实验的学习键和对照键未进入编译结果；追加第三项 luna_pinyin_t9.custom:/patch? 后该实验的对照键进入编译结果。朙月 26 键仍是两项；当前确定性重写、夹具与 outputSHA256 绑定。
- planner 对九键简繁 reset 与 algebra 的放行要求 compileInputProven 为真、源 SHA 与重写输出一致且无 grammar；放行后生成相应 reset 与受控 algebra。学习键另按现有 planner 规则生成，不应把上述三项条件概括为所有学习覆盖的共同闸门。
- 学习开关失败曾归为“L4”：隐式的 `luna_pinyin_t9.custom` 不进补丁链，显式引用后才生效。
- 测试证据路径：LUNA 合同测试通过 LunaT9EvidenceRoot 管理运行证据（环境变量 LUNA_T9_EVIDENCE_ROOT，缺省为唯一临时根）；依赖本机绝对路径的实际读写在 CI 环境可能无法访问，应核对目标环境并验证。

## 3. 真引擎事实（PR1 D 段与探针，librime 1.16.1）
- 六个样本 6、44、444444、64、6446、94664 在真引擎上的首选与退格结果：64 → 你，6446 → 你功能（繁体窗口含“你好嗎”，简体含“你好吗”），94664 → 中；退格后 raw 依次为 空、4、44444、6、644、9466。引擎自己的 preedit 是数字分组（如 `64 4 6`）。
- D 段和隔离探针所记录的候选窗口中，未加 spelling_hints 的 comment 均为空；D 段 6446 的现有 smoke 评价因此失败。有限窗口不能证明所有输入或候选均为空。
- 隔离探针中，只添加 spelling_hints（8 或 100）后，观测窗口的 comment 呈小写拼音，观测值由 validatedSource 接受，6446 的 smoke 评价为真。探针未叠加 overlay；模糊音下 comment 的语义尚未验证。
- 用户可见组字（`T9PreeditResolver`）：先看完整覆盖的 Path，其次高亮或首候选的合格 comment，最后只显示显式字母；仅输入数字且无 comment 时为空串。smoke 通过不等于可见组字非空。
- `NineKeySchemeRegistry.entries` 是 `static let`，不能在测试里注入新 ID；生产参数化 `RimeT9SmokeProbe.verify` 对未登记 ID 失败关闭。
- 版本：运行时 librime 1.16.1；生成器 1.17.0 在诊断与 manifest 里都没有证据（UNKNOWN）。

## 4. 已定与待定的决定
- 已定：采用方案 A，为派生变体加入 spelling_hints，R6 修订固定 N=8，产生新的重写输出与 outputSHA256；实现和性能对照仍须验证。设计补充 R6 经第二轮独立 Architecture 审查通过。
- 已定：PR1 保留参数化入口的正反例阻断；缝是 `RimeT9SmokeProbe.verify` 的测试可见重载，接受不可变登记快照，生产公开入口只用真实 entries，`entries` 保持 `static let`。
- 待定/待做：N=8 的实现验证与每键延迟对比（朙月旧值、8、雾凇，同条件）；模糊音与简繁叠加下的 comment 语义；Path 与 controller 的真实 fake-host 实测；旧部署目录升级与失败回退；雾凇与万象的内置资源闭包和三家回归仍须在 PR1 核验；缺 fixture 或证据时记未验证并阻断 PR2。
- Human 已定（2026-11-05）：朙月、雾凇、万象必须完整支持，输入缺口不得称“已知限制”。

## 5. 给后来者的提醒
- 做任何九宫格方案前先核对 comment 的来源：它可作为 Path 排序提示，也可成为可见组字来源；Path 的合法性由本地目录决定，空 comment 不妨碍产生合法路径。
- 新方案接入要三件事同时成立：确定性改写（失败关闭）、planner 放行条件、smoke 与可见组字的独立断言。
- 不要把“smoke 通过”当成“用户看得到拼音”。

## 6. 证据位置
任务报告在 PM 的外置工作目录（不在仓库）：LUNA-PLANNER-IMPL-001（planner 设计补充与审查、质量与门禁）、LUNA-T9-001（设计 R1–R5、Architecture 审查、PR1 各段）、LUNA-T9-PR1-D（D 段取证、设计补充 R6 与审查）、LUNA-T9-SPIKE-HINTS（拼写提示探针）。代码入口：`Packages/KeyboardCore/Sources/KeyboardCore/LunaT9SchemaCompatibility.swift`、`Packages/RimeBridge/Sources/RimeBridge/LunaT9DeploymentSupport.swift`、`RimeConfigManager+CustomYaml.swift`、`RimeT9SmokeProbe.swift`；`Packages/KeyboardCore/Sources/KeyboardCore/T9PreeditResolver.swift`、`NineKeySchemeRegistry.swift`、`SchemaSwitchResolver.swift`。
