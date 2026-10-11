# 最小DEBUG route/facade scope实施收尾

Status: Completed — implementation / strict format only；未编译、未执行测试或运行采集

## 授权和身份

Human“批准，请继续吧”批准[两scope设计](../plans/typo-correction-002-int003-query-cost-p2-route-compatibility-design-001.md)及独立实施范围。先释放并消费[AUTH](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-P2-ROUTE-SCOPE-IMPLEMENTATION-001.md)，source25及10路径preimages匹配并备份，才进入实施。[Assignment](../assignments/typo-correction-002-int003-query-cost-p2-route-scope-implementation-001.md)现Completed，AUTH耗尽。

固定writer `/Users/doubleshy0n/.codex/worktrees/int003-query-cost-memory-impl-001/Universe Keyboard`，base HEAD72dd21710f2a86c9f951d489f645bae89b053b58；共享dirty checkout未写。旧candidate6d1e5c28…作为preimage，新candidate25 SHA-256 `d45bdc9be791aa1654dfde1699a261c34434cd05f68de9456d8102beebd1c2c2`；增量manifest `7a5efae2bf9abe615f9786561edd3d59641e03784d6d067e7b07a12434a30226`。新candidate还未绑定任何已安装包或运行PID，禁止沿用旧installed manifest当新源码证据。

## 改了什么、为什么

- Core probe新增仅DEBUG/probe可见FacadeScope：区分native correction session、threadAffine provider、unavailable、unsupportedResponsive；不改变旧TypoCorrectionQueryDebugScope语义。arm仍要求eligible/FullAccess/coordinator及Luna、真实非零facade/lifetime身份。
- Installed owner新增MainActor观察时分配的稳定非零facade ordinal和确切provider类型观察；ordinal溢出fail closed，不使用对象地址、不在query里分配identity。
- controller只读已安装owner：native路由复用existing correction scope；threadAffine路由核对flags/bridge/provider/coordinator和owner已发布diagnostics两次的epoch、runtime selection、native-valid快照与ready。nil/不一致/非Luna/unsupported均拒绝，没有等待或新建engine/session。
- 现有coordinator每次facade调用前后、sequence/freeze验证scope；变化记录原scopeChange，真实query/fence/scheduling/results不由probe控制。
- 私有arm/cost wire升级v2；header32words、record20words、arm128bytes、capacity4096和maximum655616bytes不变。明确kind、facadeOrdinal及lifetimeOrdinal，provider epoch不冒称native correction sessionID；严格解码拒绝v1冒用及armed-invalid scope。
- 四个现有测试文件更新消费类型与v2反例，并新增provider readiness/epoch变化、身份稳定/替换、unsupported、v2尺寸/准入覆盖。private `decode-v2.py`只包含arm v2严格纯解码，没有LLDB/进程调用，cost全记录严格解码仍由Core执行；未来采集driver必须绑定新candidate与该decoder，不覆盖历史v1 driver。

总计10个允许Swift路径有变；旧candidate其余15路径hash不变。未改Bootstrap、RimeBridge、thread-affine生产引擎、部署或UI。

## 实际检查与未执行项

- 指定Xcode.app：对10文件先`xcrun swift-format format --in-place --configuration .swift-format`，再`lint --strict`，均exit0；原始参数和stdout/stderr在format-receipts。
- private decoder只做Python语法compile，未执行case/读取快照。
- 6实现文件all-conditional-flags-off的静态文本投影一致；该简化模型不是真实Release编译或所有条件组合证明。
- delta逐文件与授权preimage比较、候选完整25hash核对、git diff --check；文档link/JSON检查在本轮closeout完成。
- **0新增test运行 / 0 build / 0 install / 0 LLDB / 0输入**。未核查真实新route身份、arm或query总量。有限实施结果不是独立review、CI或可合并结论。

原始产物 `/private/tmp/uk-route-impl1` 保存before10、逐文件delta、baseline、candidate、delta-manifest、format日志、静态projection与private decoder。必须保留可恢复检查点，未经后续确认不清理唯一证据。

## 下一验证建议（未授权）

只在固定candidate25上建立独立AUTH：一次Core QueryCostMemoryProbeTests（明确开启probe宏），通过后一次KeyboardExtensionTests hostless Debug suite，覆盖QueryCostArmDiagnosticTests、TypoCorrectionQueryCostProbeIntegrationTests及TypoCorrectionRecallCoordinatorIntegrationTests。每项最多一次；Swift6 warnings-as-errors、coverage关闭、隔离产物与必要同账户缓存例外；指定405D独占确认仍有效且执行前核对后才能设备测试。

Core和Extension编译/运行失败首停止，先保存原因；无自动扩围修复/重跑、无main追逐。正常App包build/install、重建Extension实例和正式P2运行仍另AUTH，不在本下一测试阶段输入或点取证按钮。新scope增量独立review应在candidate及测试回执冻结后单独绑定，旧review不冒用为新scope结论。

## 文档影响与父任务

Human接受的两scope准入含义已补入P2本地证据合同，所有required query/integrity/privacy保留；设计与经验同步。不改生产架构，CHANGELOG和ADR不需因这次未发布DEBUG增量更新；不恢复RimeRuntimeProvenance。

父TYPO-CORRECTION-002 Active；仍在P2运行证据准备阶段。当前待新scope编译/测试与实际arm/costCapture，无Gate/Close/ADR Accept/TestFlight/Release或Gitcommit/push/merge。
