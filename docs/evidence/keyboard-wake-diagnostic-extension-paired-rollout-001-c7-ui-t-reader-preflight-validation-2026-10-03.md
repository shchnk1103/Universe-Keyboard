# C7 UI T reader / 交付流程预检

## Scope / Ownership / Decision

Human「那先把 reader 和交付写出流程预检跑通吧」授权。root 为 Coordinator/预检执行者；本轮没有启动独立审查，不补造先前审查者的报告。预检工具与证据均为 docs/evidence 下的协调产物，不改产品源码。

**预检已跑通；独立 T 仍 Partial / Hold。**

## 验证结果

- Reader 使用 packet.baseline.worktree 显式定位，去掉易错的 parents[n]。先独立校验 canonical self digest、whole-file digest、分支/HEAD和allowlist内容hash，再读证据。出现不一致立即停止。
- Core204映射 Packages/KeyboardCore，文件集合/逐文件hash全吻合；候选571来源与630Vendor逐hash及hash-only映射全吻合。测试摘要为85/0/20、421/0/10、1/0/0；这些是reader观测，不是新的独立结论。
- S/P正常路径用新鲜协调预检快照跑通，各输出 reader-result.json、report.md、usage.json，原子写出并回读校验hash。S约0.58s、P约0.12s（包含进程、输出写出及回读的观察耗时，非独立review用量）。
- 故意使用旧Assignment hash、错误whole-file digest、缺失Core摘要locator，三种失败路径均退出非零且落盘明确Partial失败报告与usage，未产生成功reader-result。预检假包不用于正式授权。
- 旧Assignment唯一drift来自已归档split停止记录；本轮没有改写旧审查包，另建标识为“Coordinator preflight only”的快照。

## 库存规则及事实

比较只规范化reference原来没有的新增com.apple.provenance；不得忽略已存在属性值。应用数据与系统根/metadata、Snapshot子树分别核对。

- fresh before→backup新增provenance main865/group8/app9，既有属性变化/删除0。
- 初次恢复、fresh恢复的main-data/AppGroup应用库存均零差异，Snapshot SHA multiset相等。
- installed-app两处变化分别在主可执行文件和Keyboard appex可执行文件，仅com.apple.install_uuid；final与postinstall库存一致。此分类不把所有安装属性一概忽略，不声称allmetadataexact。
- 第二次final与postinstall的main-data差异正好3个TipKit文件，AppGroup0差异；系统根及metadata零差异。

## Reader的明确限制

raw driver观察选取含swiftc -module-name的行，计数3/12/12，仅是该筛选子集，不冒充此前compiler-flags的9/18/18全量。筛选行Swift6/probe/warnings-as-errors均出现；literal strict-concurrency complete为0，与requested argv的设置区别保留。Reader输出冻结argv/manifest/toolchain/loghash位置，但不会自动批准“standalone候选与test-host严格等价”；该语义仍须独立审查者判断。

report/usage为协调者演练，coverage=Not an independent assessment；失败coverage=Partial。演练usage的计时止于usage写出前，外层receipt单独记录包括写出和回读的实际观察耗时，不把两者混称独立实际预算。正式独立review仍应写真实调用数量、总elapsed及结论，并在第3call检查点后预留最后call交付；不能直接把演练报告复制成独立报告。

## 后续边界

正式补审前需重新冻结当前Assignment、helper、精准必需证据allowlist及预算时钟，让reviewer先检视helper代码，再程序化核查；不沿用本预检包的执行权，不恢复已耗尽预算。审查者须保留独立判断；缺必要证明报告Partial。

30raw skip/29未验证内容的当前阶段Product处置仍开放。未运行测试、构建、模拟器、安装、恢复、LLDB或读取用户原内容；无commit/push/Release。证据在同名-artifacts目录，旧split历史完整保留。
