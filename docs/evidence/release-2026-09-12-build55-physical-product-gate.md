# Build 55 真机 Product Gate 证据

> **状态：** `Human Product Gate Pass`（功能性真机 smoke；不是 Release 结论）
>
> **日期 / 时区：** `2026-09-12 Asia/Shanghai`
>
> **Assignment：** [`RELEASE-2026-0801`](../assignments/release-2026-08-01.md)
>
> **授权：** Human Product Owner 在当前会话授权使用 Build 55 执行真机 Product Gate
>
> **Operator：** Human Product Owner

## Gate 范围

本记录只覆盖精确 Build 55 在当前主设备上的安装、启动、键盘启用和人工功能性 smoke。它不把一次人工确认扩大为性能基线、内存/Jetsam 证据、完整 Full Access on/off 矩阵、崩溃符号化手册闭环或 TestFlight / Release 授权。

## 冻结候选身份

| 字段 | 值 |
|---|---|
| Source | `main` @ `b8175129f26f787a6c7fee0be5977ebec46edf60` |
| Xcode Cloud workflow | `Archive Pilot (No Distribution)` |
| Xcode Cloud Build | `55`；Build ID `8ca1634e-9139-405a-aa5c-75c3d6919908` |
| 版本 / 构建号 | `1.0 (55)` |
| App bundle | `com.DoubleShy0N.Universe-Keyboard` |
| Keyboard bundle | `com.DoubleShy0N.Universe-Keyboard.Keyboard` |
| 安装包 | Ad Hoc ZIP；SHA-256 `de5b9b355f87af094b669f2548fb2811e8c1cf529dc551276dda8128b0ef8152` |
| 安装方式 | `devicectl` replacement install；未卸载、未清空 App Group / RIME / user dictionary |

## 设备与前置核验

| 字段 | 值 |
|---|---|
| 设备 | iPhone 13 Pro（系统名称 `DoubleShy0N`） |
| OS | iOS `27.0` |
| Xcode 窗口 | 正确仓库项目，分支显示为 `main` |
| Xcode 当前运行目标 | iPhone 16 Pro Simulator；已排除，未作为真机证据 |
| 已安装 App | 版本 `1.0`，Bundle Version `55` |
| 最终只读进程核验 | Main App PID `8237`；Keyboard Extension PID `8265` |

机器前置结果：

- 精确 Build 55 Ad Hoc 包安装成功。
- 主 App 启动及一次非破坏性冷启动重启成功。
- 主 App 首页显示资源状态“已就绪”。
- 冷启动截图：`/private/tmp/uk-build55-audit.DNj3jv/iphone13-build55-cold-launch.png`

## Human-operated smoke

Human 按此前声明的单轮序列完成：

1. 在系统设置中启用 Universe Keyboard 和“允许完全访问”。
2. 在空白提醒事项输入框中选择 Universe Keyboard 与中文九键。
3. 使用合成输入进行连续输入，不操作 Path 或候选；随后完成中文候选、英文 `test` 和 Return 基础操作。

Human 回执：`通过，没有任何异常。`

未报告卡顿、崩溃、自动回退系统键盘或数字泄漏。该结果是 Human-attested functional smoke，不是自动化替代人工输入，也不是数值性能基线。

## 判定与边界

| Claim | 结果 |
|---|---|
| Build 55 / iPhone 13 Pro / iOS 27 的功能性真机 Product Gate | **Pass — Human-attested** |
| 主 App 冷启动与 Extension 进程存活 | **Pass** |
| 全新安装 / 全新 App Group 状态 | **Not run**；本轮为保留数据的 replacement install |
| TD-003 性能、内存、终止证据 | **仍未关闭**；本记录不提供数值基线 |
| TD-004 Full Access off/on 完整矩阵 | **仍未关闭**；本轮只记录启用 Full Access 的人工 smoke |
| TD-005 crash / jetsam / symbolication handbook | **仍未关闭**；本轮仅记录 smoke 期间未观察到异常 |
| TestFlight 上传、分发、Beta Review 或 App Store Release | **未授权、未执行** |

## 下一步

先将本记录纳入当前 release evidence handoff，并由 Human Product Owner 单独决定是否接受剩余 TD-003/004/005 风险。任何 TestFlight 上传、测试组分发或 Review 提交仍需单独明确授权。
