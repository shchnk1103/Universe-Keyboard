# C7 UI H2 普通模式隔离验证

Human授权“执行H2吧”，root仅host generic Simulator SDK构建与最终产物检查。沿[H2 Entry](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-h2-entry-2026-10-02.md)，原worktree/branch/HEAD一致，source571/Vendor630前后逐项匹配。没有源文件修改、测试、模拟器实例操作、安装、LLDB或Maps；父子Active，不是Gate或Release发布。

## 复用决定与实际命令

旧C7-B1的Presentation.swift和T9PinyinPathTests.swift与当前H1冻结输入不同，因此旧普通模式通过不复用。两模式新建独立DerivedData/xcresult，复用H1已解析SourcePackages；禁自动resolve/update，无Vendor或源码修补。

实际Xcode27.0/27A266a、SDK27.0/Swift6.4及developer路径读回与H1相同。两模式语言Swift6、warnings-as-errors、arm64/ad-hoc签名。普通Debug仅显式DEBUG，Release仅inherited；均无KEYBOARD_WAKE_OWNER_PROBE。实际主App/Keyboard compiler行语言6/warnings-as-errors及条件逐项确认，Release未带DEBUG。strict complete请求设置保持，Swift6的生效说明沿H1记录，不声称实际另发严格并发flag。literal inherited为subprocess argv，无shell展开。

## 最终配对产物

| 模式 | 实际构建 | payload文件 / MachO | xcresult warning | UI/导出探针符号 |
|---|---|---|---|---|
| ordinary-debug | 33.700s / exit0 | 78 / 6 | 0 | 无 |
| ordinary-release | 83.026s / exit0 | 74 / 2 | 0 | 无 |

两xcresult均succeeded/errors0，摘要warningCount为0；两份raw log各有2条AppIntents metadata extraction skipped warning（未链接AppIntents.framework），不声称日志绝对无warning。两App均嵌入Keyboard.appex，版本1.0/build1对应，签名--verify --deep --strict均通过，无test-host/xctest。所有MachO逐项arm64/SHA256/UUID与dwarfdump匹配，nm成功读取全部符号表；每个MachO均无12类UI/controller入口子串，包括install/set/refresh/handle控件方法、touch observer/callback、appearance/record方法及wakeOwnerProbeExportReady（完整过滤列表在verify.py），不以nm失败/stripped猜测缺失。

H1专用Debug的同两个入口为阳性对照，已再次核验其78 payload字节未变；H1 candidate43d85d…不被普通产物替代。普通Debug的Core DEBUG hooks可以保留；本轮只证明诊断UI/借用出口的编译排除，不证明零初始化成本或Runtime行为。Release SDK编译不是Release许可。

## 证据与下一阶段

[H2 artifacts](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-h2-artifacts/)归档exact argv/result/log/toolchain/input manifest/xcresult摘要、完整payload及MachO身份、签名、实际compiler行和全部nm gzip原始输出与hash。完整xcresult/产物留private scratch `/private/tmp/ukey-wake-probe-ui-h2-20261002`；未访问任何模拟器data或AppGroup。

source571/Vendor630/H1 payload78均无漂移；五个状态镜像之外原文件未变，完整dirty清单保存在private scratch，staged0。文档链接/diff检查见preservation。旧Partial/超预算/30skip/数据损失不倒写，无commit/push/Release/Close或M-02生命周期触发。CHANGELOG/长期架构合同无需更新。

H2 bounded Exit完成，建议下一步Q：新候选source→command→payload及嵌入权限的独立绑定评审，需冻结新packet/预算；H1/H2 executor自检不能充当独立验收。实际套件/安装/新UI或Maps仍分别授权，并需fresh独占和测试前完整备份。
