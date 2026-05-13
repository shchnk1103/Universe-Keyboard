# Universe Keyboard

iOS 第三方中文输入法，基于 RIME/librime 引擎 + 雾凇拼音配置，追求接近 iOS 原生体验。

## 当前状态

🚧 **早期开发中** — 键盘骨架和纯逻辑层已完成，RIME 引擎接入尚未开始。

## 功能

### 已实现

- **26 键 QWERTY 布局** — 字母页 / 数字页 / 符号页三页体系
- **横向滚动候选栏** — UIScrollView 驱动、可视区高亮（滚出视口的候选自动变暗）、右侧 SF Symbol 展开按钮弹出多行候选面板替代键盘区域、渐隐遮罩，贴近原生体验
- **上下文感知标点** — 中文模式下数字页显示中文标点（。，、？！等），英文模式下显示英文标点
- **Shift / Caps Lock** — 双击锁定大写，单击切换单次大写
- **长按变体字符** — 19 个字母键支持长按弹出变体（如 a → à á â ä æ）
- **删除键** — 单击删除、长按连续删除（带加速）
- **中英切换** — 一键切换输入模式
- **空格 / 回车** — 回车键标题根据输入框类型动态变化（search / send / go 等）
- **地球键** — 切换到下一个输入法
- **键盘类型适配** — 邮箱输入框自动切换英文并显示 `@` `.` 快捷键；URL 输入框显示 `/` `.com`
- **自动大写** — 句首自动 Shift
- **双击空格句号** — 英文模式下双击空格输入 `. `
- **深浅色模式** — 自动跟随系统
- **触感反馈** — 可开关的按键震动（无需完全访问权限）
- **键盘点击音** — 可开关的系统键盘音（需完全访问权限）
- **App Group 设置共享** — 主 App 与键盘扩展通过 UserDefaults 共享设置
- **主 App** — 引导启用键盘、设置管理、完全访问说明

### 开发中

- RIME/librime 引擎接入
- 雾凇拼音配置导入
- 真正的中文候选栏

### 计划中

- 滑动输入（英文先行，中文跟进）
- iPad 适配
- 用户词库

## 架构

```
Universe Keyboard.xcodeproj
├── Universe Keyboard/          # 主 App (SwiftUI)
│   ├── ContentView.swift       # 引导页 + 设置
│   ├── Universe_KeyboardApp.swift
│   └── Components/             # 可复用 UI 组件
│
├── Keyboard/                   # 键盘扩展 (UIKit)
│   ├── KeyboardViewController.swift              # 主控：生命周期、UI 同步
│   ├── KeyboardViewController+Actions.swift      # 按键动作处理
│   ├── KeyboardViewController+CandidateBar.swift  # 候选栏
│   ├── KeyboardViewController+Display.swift      # 计算属性 + 按钮状态
│   ├── KeyboardViewController+Gestures.swift     # 高亮 + 长按变体
│   ├── KeyboardViewController+KeyFactory.swift   # 按键工厂方法
│   ├── KeyboardViewController+Layout.swift       # 键盘行布局
│   ├── KeyPopupView.swift                        # 长按弹出面板
│   ├── UITextDocumentProxyAdapter.swift          # 代理适配器
│   └── KeyboardType+UIKit.swift                  # 类型桥接
│
└── Packages/
    └── KeyboardCore/            # 纯逻辑层 (Swift Package)
        ├── Sources/KeyboardCore/
        │   ├── KeyboardController.swift   # 状态机核心
        │   ├── KeyboardState.swift        # 键盘状态
        │   ├── KeyboardAction.swift       # 用户动作枚举
        │   ├── KeyboardEffect.swift       # UI 刷新标记
        │   ├── TextInputClient.swift      # 文本输入抽象
        │   ├── CandidateProvider.swift    # 候选词协议
        │   └── Fake*.swift                # 测试用假实现
        └── Tests/KeyboardCoreTests/       # 93 个单元测试
```

**核心设计原则**：所有业务逻辑在 `KeyboardController` 中，View Controller 只负责 UI 渲染和事件转发。`KeyboardController.handle(_:)` 是唯一的状态入口。

## 构建与运行

**环境要求**：Xcode 26.4+，iOS 26.4+ 部署目标

```bash
# 打开项目
open "Universe Keyboard.xcodeproj"

# 命令行构建
xcodebuild -project "Universe Keyboard.xcodeproj" \
  -scheme "Universe Keyboard" \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  build

# 运行单元测试
cd Packages/KeyboardCore && swift test
```

**测试键盘**：在 Xcode 中运行 Keyboard extension target，然后在模拟器/真机的 设置 → 通用 → 键盘 → 键盘 → 添加新键盘 中启用。

## 开发计划

完整开发计划见 [`ios-rime-keyboard-development-plan.md`](ios-rime-keyboard-development-plan.md)。

| 阶段 | 内容 | 状态 |
|---|---|---|
| Phase 1 | 基础键盘骨架 | ✅ 完成 |
| Phase 2 | KeyboardCore 抽象 | ✅ 完成 |
| Phase 3 | RIME 桥接 (librime) | 🔜 下一步 |
| Phase 4 | 候选栏与中文输入 | ⏳ 待开始 |
| Phase 5 | 雾凇拼音配置导入 | ⏳ 待开始 |
| Phase 6 | 原生体验打磨 | ⏳ 待开始 |
| Phase 7 | 滑动输入 MVP | ⏳ 待开始 |

## 许可证

本项目代码采用 MIT License。

RIME/librime 为 BSD-3-Clause，雾凇拼音配置为 GPL-3.0。在发布版本中需要展示相应许可证说明。
