# v6 reader Stage A local delivery / partial validation

日期：2026-09-30 Asia/Shanghai。状态：Stage A local candidate delivered；Executor-recorded，非独立review或Gate。Assignment与parent继续Active。

## Final identity

[Authorization](../product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001-v6-reader-stage-a-authorization-2026-09-30.md)、[Entry](keyboard-wake-diagnostic-extension-paired-rollout-001-v6-reader-stage-a-entry-2026-09-30.md)、[candidate manifest](keyboard-wake-diagnostic-extension-paired-rollout-001-v6-reader-stage-a-manifest-2026-09-30.json)（SHA-256 `71ab90d528b598f6bd7a2d19f2f20dd942e2e4eeb91d5c14791dbf4ec15a0e18`）绑定指定worktree/branch/HEAD与五文件最终内容、七个只读依赖。既有2330文件中，仅五文件与owning Assignment被本阶段改变，另外2324字节hash保持；原231 dirty没有删除、stage/reset/clean/switch/commit/push。pre-edit备份及六份本阶段diff在 `/private/tmp/ukey-wake-v6-decision-20260930-01a0f254/before`、`diffs`；基线corpus hashes随evidence保存。

## Delivered behavior

reader支持显式3/4/5/6；wake marker仅4/6，typo_recall新字段仅5/6。全局生产schemaVersion与isWritableV5保持原5约束，未引入production v6构造/发射。严格wire validator保留closed keys/values/pairing和未知未来版本拒绝；无Journal/Runtime/Ingress/App生产源/Extension修改。

Core tests覆盖三marker、generic/scheme_delivery/runtime_route/rime_sync/typo_recall保真、query非法cardinality/value/pairing、future7/非整数版本、unknown code/raw keys、malformed marker、v4可读/v5 marker拒绝；混合3/4/5/6的latest/pages/date preview保持原字节与有效邻接记录；v6拒绝-only为incomplete；生产v5拒绝decoded v6 marker与普通v6记录。现有future6负向样本改为7，保留未来版本负向合同。

App新增一项表驱动直接Composite query测试：v6-only、mixed-complete、v6-incomplete、mixed-incomplete、rejected-only；每个场景隔离临时raw JSON/随机defaults suite/legacy sentinel，检验有效邻接数量、incomplete notice、fallback抑制与fixture原字节。现有complete-empty fallback用例保持。**App test authored/not-run，未编译，不能声称五个场景通过。**

## Validation

- 五文件 `xcrun swift-format format --in-place --configuration .swift-format` 后 `lint --strict` 全部通过；[format log](keyboard-wake-diagnostic-extension-paired-rollout-001-v6-reader-stage-a-swift-format.log)。
- 最终host `swift test --package-path Packages/KeyboardCore --scratch-path /private/tmp/ukey-wake-v6-decision-20260930-01a0f254/host-build --cache-path /private/tmp/ukey-wake-v6-decision-20260930-01a0f254/swift-cache --config-path /private/tmp/ukey-wake-v6-decision-20260930-01a0f254/swift-config --security-path /private/tmp/ukey-wake-v6-decision-20260930-01a0f254/swift-security` exit0；**1181 tests / 0 failures**。Swift Testing另报告0 tests不额外累计。[final log](keyboard-wake-diagnostic-extension-paired-rollout-001-v6-reader-stage-a-host-test-final.log)。
- 初次沙箱内host尝试在SwiftPM manifest处 `sandbox_apply: Operation not permitted` exit1；保留[失败log](keyboard-wake-diagnostic-extension-paired-rollout-001-v6-reader-stage-a-host-test.log)。经授权主机执行相同host命令，第一次1181通过后新增family断言并重跑最终1181通过；不是重跑v5的429/428计数。
- Xcode27.0 build27A266a、AppleSwift6.4 (swiftlang-6.4.0.34.1 clang-2100.3.34.1)、arm64 macOS27 host；测试构建与cache均独立private/tmp，未用共享.build。
- 六份pre-edit至final diff whitespace checks通过；root自查writer guard与双层reader合同；Core/App GPT6 Luna仅scope ACK与测试文本协作，未执行独立Architecture/Quality review。

## Remaining dependencies / non-claims

Stage B需要另行授权新鲜指定Simulator独占窗口及完整CI矩阵，运行真实App target并完成exact-candidate独立评审。Stage C需要旧API/parent patch可审核字节、writer/producer source ownership与另行实施授权。paired二进制身份/promotion/install/Maps依赖仍未满足。

V5-Q-001继续428接受不重跑；V5-Q-002/003继续v5-only未验证环境残项，20+10 skips不是通过。之前Release bundle原七文件hash匹配，新增database.sqlite3时间及invocation identity与后续xcresulttool query相符，保留executor-recorded高置信归因与无syscall证明限制；差异核验 (`/private/tmp/ukey-wake-v6-decision-20260930-01a0f254/release-evidence-reconciliation.md`)。不改旧manifest/删除database/宣称新Quality关闭。

duplicate JSON member detection仍未实现。没有根因、行为修复、生产marker发射、模拟器/安装/Maps、完整CI、可合并、Product/Quality Gate、Release或closure。Accepted ADR合同无需本阶段改写；CHANGELOG留待正式集成/发布阶段决定，本切片不扩围编辑。
