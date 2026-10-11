# 固定 Debug payload readout — Completed（仅 metadata）

记录时间：2026-10-09T14:26:43.255287+08:00。证据等级 **Executor-recorded**，无独立 Quality / runtime 验收。

## 本轮结果

- 最终 runner/helper 全文语法检查通过。Mock 成功路径精确2命令，失败路径1命令即停止；报告JSON roundtrip通过，真实XML及section读取通过。
- 新独立 AUTH 在上述预检后释放并消费，绑定 runner SHA `514eb5e974a36fb47b14812fe05cc93b07cef55199b50d1bd5b4cbeedc4e27e0`；旧 Consumed AUTH 没有复用。
- 原成功编译的 embedded Keyboard：`codesign --verify --strict` 与 `codesign --display --entitlements :-` **2/2 exit 0**。UTC `2026-10-09T06:25:27.417767+00:00` 至 `2026-10-09T06:25:27.622031+00:00`。
- codesign App / Keyboard XML字典均为空；实际Simulator二进制 `__TEXT/__entitlements` 区段分别读取，均包含 `group.com.DoubleShy0N.Universe-Keyboard`。不得把空codesign字典写成真实设备entitlement结论。
- 同74产物+9原始证据前后hash匹配；收尾22源文件hash、固定HEAD `72dd21710f2a86c9f951d489f645bae89b053b58` 与空index匹配。脚本hash未变。
- 本轮0 rebuild、0产品测试、0源改、0模拟器操作、0发布。新命令轮无失败。两次历史工具失败仍保留。

## 与原编译关联

复用原一次 target-only Debug SDKbuild exit0回执 `f460a89cd84fea4bb87fb7fd5b63ae44eec8e3cc3912c51959d0ca4792c547cf`；原readout `b3152b40c979438e5ded6b2afc09af3b3954cdf062c6206cb98171c489252453` 已成功核对 flags、2 MachO/UUID、exportReady、noTESTING、App signature，存在旧parser失败，未篡改。本轮补完 embedded Keyboard signature/Info 与 bytes XML/Simulator AppGroup，完成固定产物metadata关联。没有重跑并新增CI或产品测试结论。

## 残余与下一步

P2仍处于实际采集之前。下一个最小切片是独立安装绑定：Human重新确认指定405D994F模拟器可用后，新AUTH仅安装本次固定payload并核对installed bytes/UUID；不沿用旧安装记录（属于旧payload）。随后实际环境、测量外暖机与无输入transport验证分别绑定授权；observer/profiler与正式Capture仍未执行。29跨域skip不由本记录接受或关闭。

父TYPO-CORRECTION-002保持Active。无Capture/Gate/ADR Accept/merge/TestFlight/Release/父Close。docs-only及私有证据工具，跳过xcodebuild；无需CHANGELOG或架构文档修改。

[完整读取回执](typo-correction-002-int003-query-cost-p2-memory-payload-readout-completion-001-completion-readout.json) / [工具预检](typo-correction-002-int003-query-cost-p2-memory-payload-readout-completion-001-preflight-receipt.json) / [归档清单](typo-correction-002-int003-query-cost-p2-memory-payload-readout-completion-001-archive-manifest.json)。
