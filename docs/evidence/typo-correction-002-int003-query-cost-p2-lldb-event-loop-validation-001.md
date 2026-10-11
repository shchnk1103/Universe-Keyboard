# LLDB事件处理修正与一次真实条件快照验证

Status: Completed / Executor-recorded — 工具验证Pass；本次arm rejected；非正式P2 Capture

## 权限与工具改动

Human“继续吧”批准[限定方案](../plans/typo-correction-002-int003-query-cost-p2-lldb-event-loop-validation-001.md)，先建立并消费[独立AUTH](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-P2-LLDB-EVENT-LOOP-VALIDATION-001.md)。[Assignment](../assignments/typo-correction-002-int003-query-cost-p2-lldb-event-loop-validation-001.md)现Completed，AUTH耗尽。未复用旧Capture预算。

仅private driver/launcher：保留同一SBListener变量，消费状态事件；attach/恢复/Human等待/cleanup使用有界事件循环，记录数字状态和停点；保留恢复运行准入。每周期64事件、累计4096、一次LLDB420秒上限。新增6event API签名及空listener GetNextEvent一次离线检查Pass（0.641秒）；没有重跑旧二进制离线检查。

## 固定身份及时间线

- source25 candidate `6d1e5c285b49717f53546b94e673cebf053903b351383bb9f3206e88ad7c31a9`，installed78 manifest `c5d921c821f38ec5532aaa813870ce69a39254b423b4c2213a80d32a1a2b5c34`全部匹配。
- 指定405D994F-28CB-4F89-BB22-B64AD81C05A2，唯一当前Keyboard PID28957，初态Ss；two loaded UUID/path与exact helper live resolved1通过。
- Continue后消费同PID running事件：state6，公开state6；精确ps为同path非T/Z。ready写于2026-10-10T14:12:40.975023Z之后才给Human一次按钮指引。
- Human只点一次观测成本，回复“不可启用”；helper停点来自唯一预期breakpoint，address/count有效，读取exact128严格decode成功。
- session40.809618667秒；nativeLLDB exit0，script snapshot_saved=true、stop=null。finally Detach(False)成功，同PID精确ps Ss、path不变，0CONT、0kill/重启。

## 本次数字结果与结论

| 条件 | 实际 |
|---|---|
| arm_result | rejected |
| elapsed / touch / callbacks | passed / passed / passed |
| aggregate eligible | true |
| Full Access | true |
| coordinator ordinal | 1 |
| correction session ordinal | 0 |
| schema code | unknown |
| snapshot bytes | 128 |

snapshot SHA-256 `2369634d879e172a832e61930b580d86cd7f128c60f45a0c66bbcfb33bf43d6b`。

固定源码QueryCostMemoryProbe.arm先排除alreadyAttempted，再要求eligible、FullAccess、非零coordinator、非零session、Luna schema。本次actual rejected且前三条件都通过，**sessionOrdinal !=0与schema ==lunaPinyin两项未满足**。因此这次拒绝不来自按键速度、空闲条件或完全访问。

controller的queryCostDebugSession观测链路只读取已有scope；nil被填为0/unknown。scope未取得可能涉及owner/route/observer或已有correction session状态；当前快照不能区分这些，也不能把0直接宣称为“RIME完全没有session”或App实际未选择Luna。不能反推历史旧Run同一原因。

工具修正后首次通过真实running准入及128bytes传输，支持所选事件处理方案有效；旧002缺失中间事件，仍不做完整历史根因证明。

## 下一最小建议（Proposed）

先只读收敛已有纠错查询scope的准备链路：入口owner/route、session创建条件、可触达的最短公开输入和清理后scope是否保留。协调器当前要求letters/chinese与非空白至少8字符；历史nihao仅5字符，不满足该协调器入口。不能据此认为换成长输入必然成功。

本次probe状态已rejected，不能在同实例继续arm；下一运行需要明确的新Extension实例与有限准备/一次快照AUTH，复用当前包、不改guard、不重编译。准备步骤先与真实源码对应再给Human详细指引，不重复无根据预热，不新增存储/UI或扩大P2合同。

## 保存与边界

`/private/tmp/uk-armevent1`保留binding及脚本hash、API/preflight、events.jsonl、各state checkpoint、Continue/ready/running-ps、Human指引与实际标题、pointer/exact128/严格decode、session/detach/ps/native回执。本轮无任何测试输入，未执行正式query-cost序列。

源码、工程、部署和产品合同未改；docs-only收尾，跳过xcodebuild，无新测试/安装/Git提交推送合并/Gate/ADR Accept/Release。CHANGELOG或架构合同无需更新。父TYPO-CORRECTION-002 Active；当前整体仍是P2运行证据阶段，工具传输已打通，查询成本证据尚未完成。
