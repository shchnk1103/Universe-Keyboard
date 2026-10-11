# TC2_PARENT_FINAL_EVIDENCE_R1 独立最终文档证据复核

## 结论

**Pass with conditions；close_eligible: true。** 这是对冻结交付 89bbce7087d0dd59a6429694ccd70f6d78ad1eb4 的证据适用性判断，不是 Product Gate / Close 执行，也不代表新风险被接受。Human 的条件授权仍须由 Product Lead 按其记录执行；本审查未消费 AUTH。

packet 列出的 22 项冻结输入均已独立核对 SHA-256 和字节内容，全部匹配。审查限定在 packet 与这 22 项短路径输入；没有读取 live/source/Git、网络或设备，也没有测试或构建。审查开始 UTC 为 2026-10-11T04:57:17.558278+00:00；最终实际结束时间及耗时见同目录 usage.json。

## C1–C7 覆盖

- **C1 — 七项父级退出证据：Covered。** 父 Assignment、exit map、Gate 准备与最终提案逐项关联了七项退出：隔离 sidecar 查询；多错误假设/排序的边界与默认安全；Registry/benchmark 对旧版与 V2 的区分；focused/full package 与 Debug/Release 验证；经 Human 收窄批准的 P2 性能观察；Device Hub iOS 27 / iPhone 17 Pro Max 的候选恢复与交互回归证据；文档与 Dashboard 同步。旧 fake、synthetic 和 skipped 结果没有被升级为语义通过。固定主 CI receipt 对应基线 59272331b3627856c1c4480b0b5d7ad0ddade0ad、28 路径清单；结果中 RimeBridge 有 20 项 skipped，App 有 10 项 skipped，均保留为 skipped。后续 F01/A44 固定全量 CI 是另一条明确标识的证据：RimeBridge 112 项（92 通过、20 skipped）、App 417 项（407 通过、10 skipped）；没有把两轮计数混为一轮。
- **C2 — QA 与交互合同：Covered，限制保留。** QA-001 reval-08 记录了指定设备上目标短语“我们今天去公园”可见、可选、位于第 2 位；该事实是 Human attestation。记录没有 keyboard_extension.jsonl，QA reviewer 未做 OCR，执行/捕获和 Architecture/Executor 存在多角色重合；closeout 明确接受这些边界。没有实际点击 selection 或 postselection Pass，本审查不声称存在。Child Assignment 的人工步骤和退出标准要求观察目标可见/可选；父 Assignment 要求记录候选恢复和交互回归结果，没有把目标点击或 postselection 列为 must-have。现有固定候选链的回归套件提供独立的交互回归结果，QA 观察提供设备上的可见/可选证据。因此这是按既有合同覆盖，不是 waiver，也没有发现原合同必需项缺失。QA 使用的运行包不是最新 592/A44/89bb 文档树；不得宣称最终合并树上重跑了设备 QA。QA child Close AUTH 仍保留 PR145 merge identity 为 PENDING_AFTER_MERGE，故本审查不宣称 PR145 merge 身份已核实。
- **C3 — 验证和合并身份：Covered，主张限于分层证据。** 固定 592 CI 结果对应其固定基线和清单；F01/A44 full CI 的五个 Swift 文件、严格格式检查与完整测试/Release 结果对应 A44 候选。PR207 合并提交 8f306c601bbae83a2ce945df0c76659343c36096 的 tree 与 592 验证候选一致；F01 PR139 merge 935520020ff66206d527dd8cdd051ff7b5ee2719 的 tree 与 A44 验证候选一致，宿主 CI 38110712011 有 10 项成功。其后的 PR209 merge 89bbce7087d0dd59a6429694ccd70f6d78ad1eb4 是 18 路径 docs-only；宿主 CI 的 6 个 heavy jobs 正确 skipped。该链支持源代码候选的组合验证和文档合并身份，不支持“最终 docs tree 上重新跑过全部 runtime CI / 设备 QA”的主张。
- **C4 — P2 与性能范围：Covered，结论保持受限。** Human 已批准不再追加配对采集，并接受有界 P2 观察而不设数值预算。P2 receipt 支持一次真实 Run 的 6 case once 加额外 F01 覆盖、actual mapping、7 个关闭序列、61 次 provider-facade 调用及所记录阶段/elapsed 统计。readiness 仍未知；facade elapsed 不是 native RIME、CPU、UI、整体 observer 或 Release 性能证据。旧 paired capture 仍 inconclusive；whole CPU/UI/memory 与 V2 observer 仍未知。旧 R4/R5 synthetic 不认证当前 V2 observer。未引入新的 paired capture 或重测要求。
- **C5 — 残余与 disposition：Covered。** P1 Q-R2-03（Input Intelligence Maintainer；canonical INT003-COORDINATOR-INDEPENDENT-ORACLE）和 Q-R2-04（RimeBridge owner；canonical INT003-RIME-FAILURE-BOUNDARY）仍为 open/retained；按现有登记，它们不是本父任务额外验证前置条件，不能说已修复或关闭。Q-R2-02 的 discovered/result-node 数差异仍作为已接受限制，Q-R2-05 的历史 compositional coverage 限制按旧 receipt 保留；后续完整固定 CI 是新证据，不改写旧 receipt。P2 QPA-R2-LEGACY-SYNTHETIC-NONREUSE-001 / P2-CURRENT-OBSERVER-BOUNDARY-001 与 QPA-R2-PRODUCT-RESIDUAL-DECISION-001 / P2-PRODUCT-BUDGET-001 的 Human disposition 为 accept。QA residual QR-QA08-01..05、F01 review residual F01-R-01..03 依原记录保留；不推断未提供的 owner/disposition，也不把 open P1 debt 包装成已接受或已关闭。
- **C6 — AUTH 与动作边界：Covered。** 当前 Parent Final Gate/Close AUTH 是 live、未消费，状态为 waiting_review_condition；授权仅允许在交付完成、C1–C7 覆盖且无未处置 must-have blocker 时进行有界 Product Gate / Close。它不授权本 reviewer 自行 Gate/Close、发布或 Release。本次只给出 eligibility。
- **C7 — 判定与限制：Covered。** 七项均有冻结证据映射；已知限制和残余都有来源或现存 disposition，没有发现原合同 must-have 缺口，因此 close_eligible=true。上述条件和不主张事项需在实际 Product Gate/Close 记录中继续保留。

## Findings 与可复用主张

- **FIND-QA-SELECTION-001（限制，已处置）：** QA-001 支持 Human-attested 可见/可选；不支持实际 selection/postselection。该点击不在当前父/child Exit 的明文 must-have 中，且既有回归套件覆盖交互回归部分。
- **FIND-EVIDENCE-IDENTITY-002（限制，已处置）：** 592、A44、QA reval-08 与最终 docs-only tree 是不同身份；只能按各自 receipt 复用，不能声称最终树上完成了当前设备或完整 runtime 重跑。
- **FIND-RESIDUAL-OPEN-003（持续保留）：** 两项 P1 技术债保持 open/retained；此结论不改变其状态或 owner。
- **FIND-AUTH-BOUNDARY-004（执行条件）：** close_eligible=true 只是最终证据适用性结论；实际 Product Gate/Close 仍须使用当前 Human AUTH 并由 Product Lead 记录。

可复用主张：固定 592 与 A44 候选各自拥有其 receipt 所记录的测试/Release 证据；最终 89bbce7 文档合并树由同身份 docs-only receipt 支持；QA 有界证明目标可见/可选的 Human observation，且不证明 selection/postselection；P2 仅支持 Human 批准的有界 facade 观察；P1 residual 仍开放。

## 最小剩余决定

本审查没有要求新增证据或任务。Product Lead 可依据当前 AUTH 对该有界交付执行并记录 Gate/Close，同时原样保留 QA 无实际 selection/postselection、QA 多角色/无 JSONL/Human attestation、性能 observer 边界及两项 open P1 技术债。不得将本报告解释为风险 waiver、Release 决定或 Gate/Close 已完成。

原报告字节保存在 [TYPO-CORRECTION-002-PARENT-FINAL-REVIEW-001-quality-r1.original.json](TYPO-CORRECTION-002-PARENT-FINAL-REVIEW-001-quality-r1.original.json)，展示版仅去除Markdown硬换行尾空格，结论未变。

冻结22项文档副本已持久归档为[inputs archive](../evidence/typo-correction-002-parent-final-review-001-inputs-archive.json)，每项base64解码可核对原hash；原review/usage结论未改。
