# A2-F1 四文件实施交付接收 — 2026-10-04

Human转交Grok已按当前Prepared Entry实施的结果，root只读接收，不并写源码。既定worktree、branch、HEAD `84b9c19227330b0fe6ff391be001ee398010fd6a`与staged0符合；Entry (`keyboard-wake-host-activation-fix-001-a2-f1-first-frame-guard-prepared-entry-2026-10-04.md`)不改。Grok作者报告已停止写入，未编译/测试/操作模拟器/Maps/Git；format/lint exit0及约20调用、低于20分钟仍只按转交摘要记录，没有原命令/逐调用账本原件，不冒称root复跑或预算机器核验。

## 字节与差量核验

四文件新hash符合转交；pbx仍 `49f0ebe89db1f30323d9bf6ceb297179ffed5fc9ef983fd3b947d11d5820586c`。root用原F3冻结diff及F0三原文件字节在内存独立重建上一候选，并核对其hash；重新生成相对原F3的四份差量，不以git HEAD归属大量既有dirty。1156构建输入除这四文件外的1152项hash保持。完整全仓其他dirty字节不作超范围保全证明。

[接收机器回执](keyboard-wake-host-activation-fix-001-a2-f1-received-artifacts/root-receive.json)含每文件before/after hash及增量；[四份差量manifest](keyboard-wake-host-activation-fix-001-a2-f1-received-artifacts/manifest.json)。私有完整before/after副本保留 `/private/tmp/ukey-host-activation-fix-a2-received-20261004`，未修改源码。

## 接线观察与验证边界

实际target传递同一CADisplayLink、generation、token；handler先核link与target身份，gate再核arm身份。Gate持有当前token/generation/live标记/两拍计数；visible/window才begin，同一live arm返回原token；拒绝/完成后抑制自动再发，重arm/新presentation按合同重置。viewDidAppear不再对无窗口/已执行rearm无条件arm。cancelRimeFirstFrameGate仅拆link，不invalidate新发token；gate各生命周期事件负责token失效。该观察是Coordinator接收核查，不是独立Architecture A2 Covered，不证明CADisplayLink实际停回调或Maps效果。

原17测试方法名精确保留，新增6个，共23个authored方法；查看差量符合首帧三例改token/two-tick以及拒绝/窗口失效/重复begin等覆盖方向。未执行测试，不把方法名/作者意图认定23通过或所有断言语义等价；由独立复审核覆盖与断言。

## 下一依赖

修复Assignment仍Blocked：A2-F1须在新候选上完成编译/实际target验证及独立定点复审，不能继承上一候选17/17或旧F3结论。建议准备新候选验证Entry，冻结23项方法/新四文件及其余依赖，规划严格Swift6实际target与完整质量矩阵适用/复用边界。此差量包含Controller/Bootstrap/Gate生产源码，不能只跑focused23便冒称完整质量通过。环境执行需另授权、原精确UDID新鲜独占及完整before保护；未从本接收推定安装、Maps、恢复或备份清理权限。

Q2-R1历史skip及F3-Q-AUDIT-001超时审计残项保持，未在本切片处置。父诊断Completed保持；未Git、Release或新独立审查。CHANGELOG未授权，本轮不扩路径。
