# C7-B2 Core strict 编译修复 / 完整 host suite 交付

Human于2026-10-02批准最小单文件类型标注及完整Core验证。原worktree、branch、HEAD保持；root唯一repo writer。无模拟器、App构建/安装、LLDB、输入或Git操作，父Assignment仍Active。

## 修改及结果

仅`Packages/KeyboardCore/Tests/KeyboardCoreTests/T9PinyinPathTests.swift:1428`把`pageOnly` map的参数改为`(index: Int)`。RimeCandidate.globalIndex的参数是Int?；显式非可选索引避免字符串插值的optional debug描述诊断。原0..<16、候选构造表达式、comment/globalIndex赋值和所有测试断言保留，意图是明确生成x0…x15的合成fixture名称而不是Optional(...)调试描述；没有产品输入或probe行为变化。精确one-line diff归档，不做全文件格式化。

完整隔离package与工作树的204个非忽略文件逐字节相同，保留所有Sources/Tests/Resources/Package.swift；无删suite、无修改manifest。`xcrun swift test`使用Swift6语言，`-strict-concurrency=complete`、`-warnings-as-errors`和独立scratch/cache。完整XCTest实际**1194 passed / 0 failed / 0 skipped**，exit0；总38.100秒，其中suite运行19.278秒。Xcode27.0工具链AppleSwift6.4，host arm64 macOS27.0。编译位置诊断无warning/error；测试自身预期negative-fixture diagnostics或带skipped词的test名称不当作编译失败/跳过。早先按宽泛字符串解析导致摘要脚本assertion失败，随后使用XCTest skip terminals/编译位置格式解析，未重跑或修改实际test结果。

完整Core编译阻断的executor修复证据已提供，不改写Quality C7-B1的原Hold或声称其已独立复审。1194是当前host结果，不是RimeBridge/UIKit/appex运行通过；旧20+10skips仍未验证。

## 身份、SDK证据复用与格式限制

十文件源码/测试manifest身份为 `3c45e4d76a858d4d5484496d216cb8b1dc6a1d59d5bc3311eb5a2e451602e0e0`（C7原9文件加本次T9测试）。Core完整204文件package-input-manifest/log/command/exit各自归档。原probe九文件identity仍为9730e254cb8afd48f857ad9bef1659017fe90d26700ea3c9b1809249e3c751c8，无变更。

相对原C7-B1的571inputs，仅这份Core-host test文件变化，630Vendor未变。原专用Debug/普通Debug/Release的实际KeyboardCore.SwiftFileList均111产品源码，不含任何Tests路径；四SDK action日志也不含该T9测试文件。产品/工程/对应UIKit test target输入逐hash一致。因此本轮保留已有SDK编译层证据，不重复四action；原571完整集合digest已经变化，不能把旧build manifest/独立review标成新的同一完整candidate。源等价与实际filelist证据见sdk-reuse-equivalence.json。实际iOS测试和交互仍未执行。

该文件原有**57条strict format diagnostics**，修改前后去除绝对/相对路径前缀后诊断逐字相同；修改后lint exit1，原lint退出码未单独保留但诊断原文归档。本轮刻意保留单行scope，不自动格式化范围外行。编译严格警告门槛未降低；Swift格式硬门槛仍未满足，当前不commit/push、不声称可merge。

## 保全与handoff

基线2661文件/576dirty、完整前后status与hash归档。除本次单文件及所属/父Assignment/已有状态镜像治理外，既有文件保持原hash，无既有删除/暂存/切换/清理/提交。CHANGELOG/ADR不更新：仅测试类型澄清，没有发布或架构合同变化。普通阶段状态同步，不是M-02独立触发。

下一步owner：原Quality角色的精确补审需新packet/预算与授权；原Environment/Human负责fresh独占后的actual target suites，C7-C安装/按钮/真实appex冻结导出/Maps单次复现需另scope及Human可用。未自动复审/开启设备窗口。旧Architecture/Quality verdict、C6窗口、skip与恢复残项保持历史。

[授权](../product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001-c7b2-core-test-authorization-2026-10-02.md) · [Entry](keyboard-wake-diagnostic-extension-paired-rollout-001-c7b2-core-test-entry-2026-10-02.md) · [单行diff](keyboard-wake-diagnostic-extension-paired-rollout-001-c7b2-core-artifacts/single-file.diff) · [完整结果](keyboard-wake-diagnostic-extension-paired-rollout-001-c7b2-core-artifacts/test-summary.json) · [raw log](keyboard-wake-diagnostic-extension-paired-rollout-001-c7b2-core-artifacts/full-core-test.log) · [source/test manifest](keyboard-wake-diagnostic-extension-paired-rollout-001-c7b2-core-artifacts/source-test-manifest.json) · [SDK等价性](keyboard-wake-diagnostic-extension-paired-rollout-001-c7b2-core-artifacts/sdk-reuse-equivalence.json) · [保全](keyboard-wake-diagnostic-extension-paired-rollout-001-c7b2-core-artifacts/preservation.json)。
