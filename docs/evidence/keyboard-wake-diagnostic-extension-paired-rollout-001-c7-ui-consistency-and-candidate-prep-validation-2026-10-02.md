# C7 UI静态一致性补正与新候选验证准备交付

Human明确授权仅补一致性并准备新候选验证。本轮新scope完成；独立C1/C2/C3 Covered，Complete consistency supplement，仅Positive scoped static opinion；[新候选验证计划](../plans/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-candidate-validation-plan-2026-10-02.md)及未执行host argv准备完成。无源码新增、build/test/install/设备/Maps操作，父子Assignment仍Active，非Gate/Release。

## 独立补正

原GPT6 Luna Quality复用，同lane QUALITY-C7-PROBE-UI-BINDING新round2；[packet](../reviews/quality-c7-probe-ui-binding-r2-consistency-packet-2026-10-02.json) digest `034a371f8ae933ebafcca795a2d5caf63f3eb90b3e0956748f33e4f1ad11f013`，8/8输入hash匹配。只审旧报告/usage与已有patch、source identity、root保全/provenance，不读取新源码body或重跑静态检查。

[独立报告](../reviews/quality-c7-probe-ui-binding-r2-consistency-review-2026-10-02.md)与[usage](../reviews/quality-c7-probe-ui-binding-r2-consistency-usage-2026-10-02.json)原字节已归档；报告SHA `9545ed8631121321dc7b263ae5473ba936f200b114fee0dc611a1f88d65e2a58`。实际2/4底层calls，末样本92.678656s<240soft/360hard，report与usage同call写入，call2 UTC起止完整。末样本采于usage序列化前，不能冒称覆盖其后所有平台最终交付时刻；不影响本轮预算足够与实际2calls的有限记账。

C1：before/after Presentation缩短label是同源码版本，root571 manifest仅该输入变化/原文件保全支持单文件；旧parser期待diff --git导致误判。C2：实际UI/runtime根因证明被排除，未做范围外runtime不构成静态criterion必需缺口；禁止用旧installed/runtime覆盖新源仍适用。C3：新报告/usage判定与hash一致，旧后deadline调用和归档hash差异明确保留。

## 旧轮不可倒写的事实

R1实际归档报告SHA `46142620cd2cbbda0a153fe2c7d6cd18ccd3cdaff04055d9a556f963e0d2d4e5`，与当时正文引用初版393ba44…不同；root stop receipt实际也匹配461版。[provenance补正](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-consistency-and-candidate-prep-artifacts/root-provenance-note.json)明确区分正文旧初版assertion与归档实际字节。旧正文/报告/usage/packet保留，不覆盖。

原R1 call3于15:10:42.430508Z完成，晚于240s hard截止15:10:23.642013Z约18.788495s；是post-hard修改，不由本轮追认。原Partial和预算缺陷历史保留；本轮只使静态解释与记账一致、给出新有限静态意见，不将原过程改成完全合规。更早正常路径运行验收的Partial/超hard9.9s等也是独立历史，不在本轮接受或改判。

## 新候选准备及依赖

[host argv](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-candidate-prep-artifacts/host-build-command.json)是原generic SDK standalone规则的新scratch路径模板，不执行。H1新host配对构建需另执行授权/实际SDK工具链及依赖Entry；新candidate digest/Info/UUID/签名嵌入section证明均尚不存在，不预填通过。现571 source/build输入仍匹配UI本地修复SHA `5f16aa1031b1ee4a90d72e4d15693e3656b0c746bcd71a10874e90655a0269c9`；后续产物只能绑定此新源码，不复用旧ddd557候选。

T实际套件之前必须完整fresh main data/AppGroup/installedApp备份、可执行恢复方案及指定UDID fresh独占。测试曾替换AppGroup，不能以测试无失败声称数据未变；测试后数据健康/restore/readback与安装前新backup分别核。当前准备不接触设备或填新的FullAccess/diagnostics原值，全部fresh字段留UNKNOWN、不是Ready。旧30skip仍skip；按actual数记账、不为发现差额凑数重跑，阶段残项需要Product对新实际记录决定，非Release。

普通Debug/Release探针排除、专用Debug最终App/appex/全部MachO/byte-binding、新candidate独立意见、数据保护后实际套件、安装与UI单轮、Maps分阶段明确。只读一致性报告不替代任何新candidate/runtime/安装意见。不修改Core/热路径/两秒policy/单轮状态，不为复现自动restart/rearm。

本轮docs-only，跳过xcodebuild及项目测试；无需CHANGELOG或架构合同，普通Assignment镜像同步无M-02触发。源码/已安装App保留，Git无暂存/提交/推送/切分支/清理。
