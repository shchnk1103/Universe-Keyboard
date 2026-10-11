# 最终固定候选一次CI验证方案

Status: Proposed execution；仅准备完成，未执行任何测试/编译/设备命令。

## 目的与完成边界

目标是让已有实现成为可交付候选，保留有效审查及P2结果。完整28路径与旧矩阵不相同，因此补一次最终完整门禁；不重做P1证据阶段、不重采P2、不新增功能或要求所有性能未知归零。

[准备Assignment](../assignments/typo-correction-002-final-ci-preparation-001.md) / [准备AUTH](../authorizations/AUTH-TYPO-CORRECTION-002-FINAL-CI-PREPARATION-001.md)已消费；[执行Assignment](../assignments/typo-correction-002-final-ci-validation-001.md)及[执行AUTH](../authorizations/AUTH-TYPO-CORRECTION-002-FINAL-CI-VALIDATION-001.md)仅待批准。精确每个argv、来源、例外和预算见[绑定JSON](typo-correction-002-final-ci-validation-001-binding.json)。

## 固定范围

HEAD72dd21710f2a86c9f951d489f645bae89b053b58＋[交付28路径](../evidence/typo-correction-002-fixed-candidate-delivery-audit-001-manifest.json)，23个Swift路径；执行前及后核对完整hash/size、HEAD/tree/index及工具链。已有source25 candidate和三继承路径均维持，不向共享checkout复制或写入。

仅拟使用iPhone18Pro iOS27.0 / 405D994F-28CB-4F89-BB22-B64AD81C05A2，作为CI默认17Pro的同平台等价环境，记录差异，不作为父指定17ProMax产品验收替代。**任何设备命令之前须Human重新确认独占**；当前方案不发现/启动/安装设备。无需手动输入。

## 一次执行顺序

1. Entry核对固定源码、Xcode/SDK、缓存/输出空间及独占。精确工具版本/依赖和所有命令写回receipt；identity不满足首停止。
2. Lightweight：对28路径manifest调用现有`classify_paths`必须为full；工作树diff whitespace及新增文本检查；`.kos/project.json`语法；现有`scripts/ci/tests` Python测试、final-gate fixture、KOS-trigger fixture各一次。classifier测试含full与docs-only路径，避免把workflow改动当docs-only。不能拿HEAD→HEAD空diff代替当前工作树检查。
3. Vendor：先核对现有pinned Vendor及manifest。不存在才允许一次原pinned fetch；不升级二进制/Package.resolved，不猜旧代理。失败停止。
4. 23Swift路径各一次严格lint，只读不format源码；没有本轮Swift commit/push。后续发布AUTH仍必须落实commit/push之前format＋lint硬门槛；任何格式变化须重新冻结内容，不能暗中改当前验证身份。
5. 默认KeyboardCore全套一次、iOS RimeBridge Debug一次、App/Keyboard Debug一次、签名Keychain独立用例一次、Release build一次。命令保持Swift6 strict/warnings-as-errors、正常配置，不新加全局probe宏或测试豁免。结果目录分开，使用已存在的本线程SourcePackages锁定解析，不外加sandbox-exec。
6. 同一预算内解析已有xcresult/log，列通过/skip/失败和所有实际target，署名Keychain重复不叠加不同覆盖数；收尾再次核对28源hash。只得到Executor本地工程验证，不能宣布已merge-ready或父Gate通过。

对未提交工作树不能直接用需要base/head commit的wrapper冒充最终发布差异。最终源码/docs发布清单冻结后，轻量diff/link/固定KOS validator须基于实际交付集合核对；hosted full run及docs-only路径证据在merge前依AGENTS另取得。本方案不授权Git写入来制造临时commit或默认分支变更。

## 证据复用与停止

- 复用当前52/0/0限定opt-in验证及增量审查，未新增语义变化不再复审一遍；本次完整默认矩阵补其未覆盖target。
- P2已有完整冻结快照、独立审查、Human接受，不做新输入/arm/LLDB/SystemTrace/CPU/profile/observer测量。
- 每stage最多一次，首失败/超时/不完整/身份漂移即停止，不自动修正、扩围或重跑。整体执行墙钟预算120分钟；结果读取最多15分钟。超时只终止本轮自己的进程，保留raw。
- main前进不fetch/rebase/rebind/重验。本轮固定内容不变就继续；后续发布若需要适配新main先只读影响判断，真正相关变更才新授权限一次验证。
- 必要同账户Xcode/SwiftPM缓存/temp/report原子写入及私有Rime fixture、唯一测试Keychain项在拟执行AUTH列明；不换macOS账户、不删除全局缓存、不清字典/AppGroup或其他线程目录。

## 当前没有执行的事项

0测试/编译/模拟器/发布。执行AUTH仅Proposed/unconsumed，环境独占尚须确认。父性能范围建议见[Proposed决定](../product-decisions/TYPO-CORRECTION-002-PARENT-PERFORMANCE-SCOPE-PROPOSAL-001.md)。父Active；Gate/Close/merge/ADR Accept/Release各自未获本方案授权。
