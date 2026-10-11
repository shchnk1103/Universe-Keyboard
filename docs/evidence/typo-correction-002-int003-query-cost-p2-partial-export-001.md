# TYPO-CORRECTION-002-INT003-QUERY-COST-P2-PARTIAL-EXPORT-001

Completed：一次限定诊断导出成功；AUTH consumed/exhausted。原12fixture合同未满足，formal P2 Pass=false，父Active。

[Assignment](../assignments/typo-correction-002-int003-query-cost-p2-partial-export-001.md) / [AUTH](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-P2-PARTIAL-EXPORT-001.md)。

## 实际刺激与归属

序列1先完成；Human随后重复序列1（重新begin/end），再完成2–6，已确认共7闭合序列、当前空输入框/开始序列。实际顺序F01,F01重复,F02,F03,F04,F05,F06。第2开始automatic encoded fixture/arm与实际输入错位，不能把ordinal7的arm2称真正warm组，也不按原fixture归属作比较。停止后0新输入/重arm/重录。原capture AUTH耗尽，新限定AUTH仅本run export。[实际映射](./typo-correction-002-int003-query-cost-p2-partial-export-001-actual-sequence-accounting.json)。

## 数值与传输结果（Executor核对，未独立接受）

| 项目 | 实际及边界 |
|---|---|
| 双副本 | 同一有效字节借用内2×12,896 bytes一致，SHA256 `729b9422660e891239235e84b869c2e6686c06c0ab40a775b924a5b23cac8106`；256+79×160，未超过655616上限 |
| wire完整性 | v2 Complete=true/reasonbits0，records79，begins=ends7，queryStarted=queryCompleted61/active0，operationsStarted=terminal2/active0，rejected0，无loss/capacity/clock异常 |
| 作用域 | loaded新两UUID和exactPID46758/paths通过；header runUUID与arm128对应，provider kind2/facade1/ownerEpoch3/coordinator1/Luna/FullAccess2 |
| 实际调用 | Stage1=48、Stage2=13；readiness全部unknown3，returned61，candidate bucket1共61，disposition1共61；是installed provider facade invocation，非native librime调用量 |
| facade elapsed | 61有效样本，min0/median0/p95 nearest rank3/max6 µs；仅微秒量化provider壁钟，不是CPU、完整UI延迟或Release成本，0µs不等于零成本 |
| cleanup | oneattach elapsed40.820s，无stop；detach(False)成功，同PID Ss，0CONT；Human一次显示已冻结 |
| 正式合同 | stimulus_contract_complete=false/formal_P2_pass=false；数字完整不替代原12fixture覆盖，无FirstObserved/warm性能结论 |

[快照结果](./typo-correction-002-int003-query-cost-p2-partial-export-001-snapshot-result.json) / [session](./typo-correction-002-int003-query-cost-p2-partial-export-001-session-result.json) / [detach](./typo-correction-002-int003-query-cost-p2-partial-export-001-detach.json) / [同PID恢复](./typo-correction-002-int003-query-cost-p2-partial-export-001-process-after-detach.json) / [Human结果](./typo-correction-002-int003-query-cost-p2-partial-export-001-human-export-response.json)。原始两数字副本和完整工具/事件/receipt/hash清单保存在 `/private/tmp/uk-routepartial1`，当前仍有transport复核价值，未删除。未上传raw到GitHub。

## 经验与下一步

同次borrow双读、v2严格字段/大小/计数、arm/runUUID及scope、loadedUUID/liveBP1/running、finallydetach非T/Z已首次真实验证通过，后续无需单独重复空快照来再证明传输。正式工具应全部在arm前完成compile/offline验证，避免30min TTL被准备吞掉。批次指令应明确已完成项目不要重做，唯一开始/停止编号。

下一Human单独授权限定独立证据审查，判断本次transport可复用范围与下一正式新Run最小准备；不把本诊断升级正式P2/Gate，也不自动重建/重装/延长TTL/重启键盘。父TYPO-CORRECTION-002 Active，无Gate/Close/ADR Accept/merge/TestFlight/Release。docs-only跳过xcodebuild，无Swift/CHANGELOG/生产架构修改。
