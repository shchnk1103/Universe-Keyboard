# C7-B2 Core test 编译单文件修复授权 — 2026-10-02

Human在建议“先处理T9PinyinPathTests.swift:1429编译阻断，再跑完整Core；需要新增单文件授权，不操作Simulator”之后回复“可以按照你的建议继续”。仅授权该文件map闭包的index显式Int类型标注及完整host KeyboardCore严格套件验证。原测试数据/断言/业务代码保持；不扩展到整文件格式化、其他源码、UIKit/RimeBridge、Simulator或Git/Release。

原Assignment角色维持：Keyboard Experience primary，KeyboardCore secondary；root Executor/host Environment Executor，唯一repo writer。root已读KeyboardCore playbook并ACK当前单文件测试范围与Inputs，当前修改不改领域业务合同。原独立Architecture/Quality角色保留，其C7-B1报告不因本次test修改自动改写或解除Hold；后续精确补审另冻结范围/预算。Human未来设备交互仍未可用，本阶段无需其操作。

stop：身份/source不匹配、还需修改其他路径/断言/警告门槛、测试触及device或发现scope外失败时只记录交回Owner/Product。不降warnings-as-errors、不减少suite、不用聚焦通过冒充full通过。源文件原格式问题单独保留，本轮无commit/push，不能宣称Swift格式/merge Gate通过。
