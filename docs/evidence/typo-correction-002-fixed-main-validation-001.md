# 固定main整合候选一次验证 — Pass（Executor-recorded）

日期：2026-10-11。Run `TC2-CI-20261011-INT003-FIXED592-001`；UTC `2026-10-11T00:10:52.661622+00:00` 至 `2026-10-11T00:15:46.419725+00:00`，同进程单调耗时293.757秒。

## 授权、来源与绑定

Human：“模拟器仍独占，请你继续吧”。[独立AUTH](../authorizations/AUTH-TYPO-CORRECTION-002-FIXED-MAIN-VALIDATION-001.md)已释放、先消费、现耗尽；未复用旧AUTH。固定main `59272331b3627856c1c4480b0b5d7ad0ddade0ad`＋[28路径manifest](typo-correction-002-fixed-main-integration-001-candidate.json)，SHA256 `8cf4b3d3cd11dbff9baddb343cf25aa2dc3f2a2d92f864040db83286eb6d2b35`。writer与argv见[绑定](../plans/typo-correction-002-fixed-main-validation-001-binding.json)。Xcode.app，唯一405D/iPhone18Pro/iOS27.0；正常缓存、合成fixture及唯一Keychain测试写入在方案权限内。

## 逐项结果

| Suite | Passed | Skipped | Failed |
|---|---:|---:|---:|
| Core | 1207 | 0 | 0 |
| RimeBridge | 90 | 20 | 0 |
| Signed Keychain | 1 | 0 | 0 |
| DEBUG Core | 19 | 0 | 0 |
| DEBUG Extension | 33 | 0 | 0 |
| UniverseKeyboardTests.xctest | 403 | 10 | 0 |
| KeyboardTests.xctest | 44 | 0 | 0 |
| KeyboardExtensionTests.xctest | 6 | 0 | 0 |

Release：passed。23个Swift严格lint和轻量检查逐项回执见[execution receipt](typo-correction-002-fixed-main-validation-001-execution-receipt.json)。默认Extension覆盖与flag-on33分开；probe19＋33共52，不把默认6重复计入。发现数/skip/summary详见[结果计数](typo-correction-002-fixed-main-validation-001-result-accounting.json)，skip不是pass，签名Keychain与默认未签名skip不可相加声称新的独立用例。

源码closeout：28/28 hash一致。每条命令仅一次；无源码修正、main更新或自动重试。停止原因：`None`。

## 保存与经验

[归档manifest](typo-correction-002-fixed-main-validation-001-archive-manifest.json)记录小型回执/绑定/摘要字节与hash；raw logs及xcresults留在 `/private/tmp/uk-finalci592-001`，未声称完整迁移。没有大型SystemTrace/P2重录；证据仍有发布用途，暂不删除唯一raw或worktree。

进度读取器在receipt已写stage、但log字段尚未落盘时发生一次KeyError；执行器在命令结束才保存这一字段，运行期读取必须按可选字段或确定日志路径处理。后续已这样读取。执行器未失败或重试。可复用规则：进度快照可能只包含stage，不能假定log字段已发布；这不改变最终CI记录或扩大测试权限。

本轮为新main依赖组合的验证；原P1/P2/历史CI均保留原绑定。本结果不证明整体CPU/UI/内存或native非空查询成本，也不是独立Quality、hostedCI、Product Gate、merge或父Close。父Active；下一精确交付scope与commit/push/PR授权，merge/Gate/Close/Release独立决定。没有修改CHANGELOG或架构；发布阶段需随DEBUG工具/测试配置和已批准范围同步有限交付说明。

## 归档检查回执

8份Markdown无缺失链接，2个新kos-record JSON有效；9份归档hash一致；Rime20/App10 skip名称及原因完整提取，scoped diff check通过。
