# QA-001 governance closure — policy check

结论：**HUMAN DECISION REQUIRED**；QA-001正式关闭仍BLOCKED，不等于技术验收失败。当前Policy提供M-03 residual accept路径，但没有专门授予“追溯豁免缺失Reviewer Lane Packet”的权限。Writer不能从Product一般权力推导万能豁免，也不能从缺少专项豁免条款反推“必须重做全部技术审查”。

## 核对事实与范围

入口branch codex/keyboard-t9-adaptive-row-001，HEAD10b277461f238815e08c1fb5d6d1bf4ccf93547d，符合Human指定。只存在Human工程/Scheme原有dirty，哈希不变。产品/测试自Human验收f610763以来无变化。本轮不运行测试，不修改源码、Policy、工程或Scheme。

Human技术事实来自当前及上一条明确验收消息和acceptance-20261021/human-acceptance.md：DSON13Pro7/7 PASS；Claude Architecture PASS、Quality CONDITIONAL PASS、Finding A CLOSED，Recommendation READY FOR HUMAN DEVICE VALIDATION。该转述被如实保留，不冒充本Writer执行的独立Review。111PASS/0FAIL/0SKIP由regression.log及xcresult summary-retry.json双重核对，exit0。

已核验38个证据文件哈希（acceptance、review-remediation、minimal-fix及原始/提取device JSON）。历史源码哈希分别用af339d9/f271f68对应Git blob核验，不能用现在的源码对比旧manifest而误报篡改。入口Assignment与acceptance manifest一致；受保护文件哈希一致。原件全部未更改。测试证据是Executor-recorded，Human设备验收是Device-attested；不新增Quality-reverified主张（M-04）。

## 六项Policy判断

| 问题 | 结论与准确依据 |
|---|---|
| 1.是否必须事前冻结？ | 对2026-09-25起首次分配的独立lane，是。ASSIGNMENT_POLICY.md:208–234明确Before dispatch freeze及Coordinator preflight before starting。已分配旧lane不迁移/不追溯回填，见同文件:251–255及PD-KOS-UPGRADE-UK-006-v0.9.0-adoption.md:35–47、69–70。不能推定本任务Claude lane符合旧lane例外。 |
| 2.缺失后Human能否例外处置？ | 未找到专门的历史Packet waiver条款。ASSIGNMENT_POLICY.md:257–266及kos-2.1-operational-maturity.md:95–114明确允许条件性Review残余项采用fix / accept / tech_debt，accept必须明确non-blocking并在close继续列出。这是有记录的残余处置机制，不是把未冻结改写为已合规；缺包能否按可接受流程残余处置，尚需与独立Review完整覆盖/证据效力一起确定。 |
| 3.是否必须重新Review？ | 没有“缺包一律全部重审”的条款。ASSIGNMENT_POLICY.md:244–249要求未覆盖必需输入/主张为Partial/incomplete，Conditional也必须complete coverage并按M-03处置；:116–120要求Quality缺证或缺独立性时停止，:484要求证据缺口交Quality。最小动作先核验既有Review原件/覆盖和残余清单；若不足，再真实冻结新packet做有界补充复核，不默认重跑代码/真机/111测试。 |
| 4.Coordinator能否决定豁免？ | 不能自行决定。ASSIGNMENT_POLICY.md:90–95只准核查/报告/建议；:231–242负责preflight但不能自批扩权。VIRTUAL_ENGINEERING_TEAM.md:19–20、46明确Coordinator不替代决策者/Reviewer。上轮Assignment“Human/Coordinator处置”的泛称不构成Coordinator裁决授权，本轮纠正该表述。 |
| 5.Human Product Owner是否最终裁决？ | 对Assignment/Product Gate和验收，是（ASSIGNMENT_POLICY.md:69–88、457）；不是任意代签Quality/Architecture的总豁免权（:15、484；.kos/project.json:122–145的三个Gate均substitution:none、risk_acceptance:explicit）。当前消息表达有条件治理意向，不是已生效的M-03 accept或改变Policy的决定。AI_WORKFLOW.md:9–12允许有权用户改变既有决定并做revalidation，但不能据此推定本轮授权修改Policy。 |
| 6.还需哪些记录/签核？ | M-03要求Residual ID、Owner、Disposition、Pointer；无Disposition不能Close。Closed还须owning Gate已关闭且handoff完整（ASSIGNMENT_POLICY.md:427）。无专项“Packet例外固定双签表”条款；但证据适足性归Quality、非阻断风险接受/Product Gate归Product Lead，Writer不能代签任一方。需获得明确的残余处置及适用范围，而不是仅记录“希望判断”。 |

## 历史事实精度

本地docs/reviews和本任务记录仍未找到完整事前Packet；缺少stable lane/round/digest/budget/preflight的可核验证据。不能把“本地未找到”升级成“已证明从未冻结”。本轮Human的治理意向亦不自动成为这一历史事实的原始证明。可将“历史流程偏差/证据缺失”明确登记；如果Human另确认确实未冻结，保留该确认原话与日期，不能伪装成事前审批。

`.kos/project.json`的advisory仅是envelope模式，不免除UK-006已采用的前瞻lane约束；legacy_exemptions为空。UK-006:55–70保持Product/Architecture/Quality边界不变。

## 当前residual登记（未处置，不是已接受）

| ID | Owner/归口 | Disposition | Pointer |
|---|---|---|---|
| R-QA001-GOV-01 | Quality Reviewer负责证据效力/完整覆盖判定；Human Product Lead负责最终Product残余决定；Coordinator只执行记录 | **Pending**。`accept`仅是待审选项，尚未生效，不登记为已accept | 本文；../acceptance-20261021/review-packet-audit.md；proposed-decision.md |

未把新角色或Reviewer lane自动分配给任何人；此Owner是现行Policy归口，不是Writer代做Assignment。QA-001技术验收通过、Finding A已由Human转述关闭；正式治理仍待该项Disposition。本轮没有发现其他新的代码/测试阻断，也没有认定Quality所有未公开条件均已解除。

## 最小合规路径

1. 优先由已有Quality Reviewer提供原Review的真实baseline、覆盖/证据适足性、完整residual清单，并判断缺Packet是否只是可接受的流程偏差；如果确有旧Packet/旧lane适用证明，只补充原件来源与哈希，不倒填。
2. 若既有证据足够，按M-03提出R-QA001-GOV-01的明确Owner/accept(non-blocking)/Pointer，由有权Human Product Lead对本任务、此缺口作明确决定；不得写成“事前冻结已满足”、不得替代独立Quality结论。
3. 若不足，由Human另授权限界Quality补充复核，在启动前真实冻结新packet（当前日期、准确baseline、lane/round/digest、scope/budget/stop）。覆盖不足仍Partial，不强行Conditional PASS；无需默认重做已通过的技术测试。
4. 获得实际Disposition和owning Gate关闭决定后，再更新QA-001关闭状态。单次accept也不豁免以后packet、不自动关闭整个UI-2 Assignment、不授予PR/Push/Merge/Release。

当前授权只准Policy核查及本任务文档，故未派发新Reviewer、未改Policy、未代签、未关闭。下一决策具体文本见proposed-decision.md。

## PR217剩余门禁

明确治理残余Disposition及Quality条件清单；另获Push/PR更新授权；届时核对远端base/head与main变化、提交范围；对不含Human未提交工程/Scheme的干净提交树构建验证；更新后的精确HEAD按既有CI执行。Merge/Release仍分别授权。本轮不操作远端、不重跑测试、不清理工作区。
