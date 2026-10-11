# 最终固定候选一次完整本地CI — Pass（Executor-recorded）

日期：2026-10-11 Asia/Shanghai。Run `TC2-CI-20261011-INT003-FINAL-001`；UTC `2026-10-10T23:52:52.267346+00:00` 至 `2026-10-10T23:56:59.228778+00:00`，同进程单调墙钟246.961s。

## 授权及固定身份

Human明确批准父性能收窄、释放并消费[本轮AUTH](../authorizations/AUTH-TYPO-CORRECTION-002-FINAL-CI-VALIDATION-001.md)、必要自动写入及405D独占。执行前消费，未复用旧AUTH；[Assignment](../assignments/typo-correction-002-final-ci-validation-001.md)仅本轮Completed。父Active，无Gate/Close/发布授权。

S HEAD `72dd21710f2a86c9f951d489f645bae89b053b58` / tree `8ce8e8c0d9b821ca4d24aff4faf46a3e49bf87ff`；[28路径交付manifest](typo-correction-002-fixed-candidate-delivery-audit-001-manifest.json)前/后hash一致，index为空、source git status不变。命令按原binding argv各一次，0格式/源码修正、0自动重试、0fetch/rebase/main追逐。[精确执行receipt](typo-correction-002-final-ci-validation-001-execution-receipt.json)及[原binding](typo-correction-002-final-ci-validation-001-binding-original.json)保存每次命令、结果、时长与日志摘要。

Xcode身份、SDK与Booted 405D entry通过。Simulator：iPhone18Pro iOS27.0 / `405D994F-28CB-4F89-BB22-B64AD81C05A2`；本地CI等价环境，不替代父指定17ProMax产品验收。未操作其他模拟器，无手动输入、P2arm/LLDB/重采、部署/字典清理。

## 实际结果

| 检查 | 结果 |
|---|---|
| Lightweight / 分类 | full候选及docs-only路径分类正确；工作树/新增文本whitespace、Profile JSON、现有Python测试、final-gate/KOS-trigger fixture各一次通过 |
| Vendor | 现有pinned Vendor verify通过，未下载或升级 |
| Swift strict lint | 当前23路径全部通过；未format源码，无commit/push |
| KeyboardCore | 1171 passed / 0 failed |
| RimeBridge | 110 total = 90 passed + 20 skipped，0 failed |
| UniverseKeyboardTests | 410 total = 400 passed + 10 skipped，0 failed |
| KeyboardTests | 16 passed，0 failed |
| KeyboardExtensionTests（默认方案） | 6 passed，0 failed；含当前默认条件下5协调器例＋bundle可加载例 |
| Signed Keychain独立 | 1 passed，0 failed；与默认unsigned skip相对应，不重复累加不同覆盖 |
| Release | BUILD SUCCEEDED |
| Result readout / 源收尾 | 三test-summary成功读取，摘要total/status与日志对应；28源hash和状态不变 |

当前默认完整矩阵中的Extension6不等于probe-on限定33；probe-on当前25路径的Core19+Extension33已按[原52测试](typo-correction-002-int003-query-cost-p2-route-scope-validation-001.md)复用，没有另开一轮52验证或把两种条件下计数混成一个suite。既有增量审查仍有效。

## Skip与事实边界

20项Rime skips包含外部Lua/Ice fixture及T9/R4B Spike配对环境缺失；10项App skips包含外部固定archive/Wanxiang/Luna/Ice fixture、物理设备及unsigned Keychain条件。每个test identity/reason照实保存在[结果accounting](typo-correction-002-final-ci-validation-001-result-accounting.json)，不算通过、不自动补跑。Keychain已单独签名验证；其他明确外部/物理边界不由本轮默认CI证明。

该轮完成固定最终源码的默认完整本地矩阵，原旧矩阵身份不符缺口已补。本结果不是新的独立Quality审查、hosted CI、可合并结论或Product Gate。23文件lint通过不替代未来commit/push前format＋lint硬门槛；最终source/docs发布集合与比较基线门禁仍须在发布阶段绑定。

[Human-approved父性能范围](../product-decisions/TYPO-CORRECTION-002-PARENT-PERFORMANCE-SCOPE-PROPOSAL-001.md)已取消新增配对采集要求；整体CPU/UI/内存及v2总体observer未验证原样保留，不能叫性能Pass。P2现存结果保持接受，不重采。

## 下一步及经验

下一建议为**一次交付发布准备**：明确28源码＋本线程必要docs发布集合、同步Registry有限状态，并只读核对当前远端main相关变化；给出固定发布基线/证据复用判断后再取得具体commit/push/PR权限。不因main推进一直重试，不自动重新审查已有route/P2，也不执行merge或父Gate/Close。

辅助进度读取一度因当前row未写log字段报KeyError；随后只读固定日志路径，未修改runner、receipt或执行次数，不影响矩阵。经验是运行状态应保存log字段后再发布checkpoint，进度工具失败不能成为重跑产品测试的理由。

本轮无技术Blocker。私有原log/result bundles保留于`/private/tmp/uk-finalci1`，[归档manifest](typo-correction-002-final-ci-validation-001-archive-manifest.json)记录摘要；不向Git复制大型DerivedData。无CHANGELOG/架构修改；本次仅验证，后续交付时记录DEBUG能力的适用范围。文档link/JSON/diff检查在closeout记录。
