# Universe Keyboard

iOS 第三方中文输入法，基于 RIME/librime 1.16.1 引擎，追求接近 iOS 原生体验。

## 当前状态

✅ **Phase 3 完成 — librime 1.16.1 已编译并在 iOS 上运行。** 键盘可产生真实中文候选词，支持 OpenCC 简繁转换。

🚧 **Phase 4 待启动** — 引入雾凇拼音 (rime-ice) 方案，提升词典质量和覆盖率。

## 功能

### 已实现

- **RIME/librime 1.16.1** — 真实中文输入引擎，9 个依赖库全部从源码编译为 iOS xcframework
- **OpenCC 简繁转换** — 集成 t2s/s2t，用户可在设置中切换
- **26 键 QWERTY 布局** — 字母页 / 数字页 / 符号页三页体系
- **横向滚动候选栏** — UIScrollView 驱动、SF Symbol 展开按钮、渐隐遮罩
- **Inline Preedit** — 拼音直接显示在输入框中（类似原生键盘）
- **上下文感知标点** — 中文模式下数字页显示中文标点
- **Shift / Caps Lock** — 双击锁定大写，单击切换单次大写
- **长按变体字符** — 19 个字母键支持长按弹出变体
- **长按删除** — 按下即时删除 + 0.5s 后连续删除（0.08s 间隔）
- **中英切换** — 一键切换输入模式，自动记录日志
- **空格 / 回车** — 回车键标题根据输入框类型动态变化
- **键盘类型适配** — 邮箱/URL 自动切换英文并显示快捷键
- **自动大写** — 句首自动 Shift
- **双击空格句号** — 英文模式下双击空格输入 `. `
- **深浅色模式** — 自动跟随系统
- **按键音** — 内嵌生成点击音（2000Hz+谐波，4ms），AVAudioPlayer 播放，可调音量，无需完全访问
- **触感反馈** — UIImpactFeedbackGenerator，可调强度（0.1-1.0），实时预览
- **统一日志系统** — Logger 单例，4 级/5 类/环形缓冲/独立开关
- **RIME 配置 UI** — 子页面：候选数量/简繁切换/部署状态追踪
- **诊断日志** — 子页面：动画刷新和清空按钮
- **主 App** — 双 Tab 布局（引导 / 设置），设置全部改为子页面模式

### 计划中

- 雾凇拼音 (rime-ice) 配置导入
- 滑动输入（英文先行，中文跟进）
- 多方案切换
- iPad 适配
- 用户词库

## 架构

```
Universe Keyboard.xcodeproj
├── Universe Keyboard/          # 主 App (SwiftUI, 双 Tab)
│   ├── ContentView.swift       # Tab 1: 引导 / Tab 2: 设置
│   ├── Universe_KeyboardApp.swift
│   ├── FeedbackSettingsView.swift  # 键盘反馈子页面
│   ├── RimeSettingsView.swift      # RIME 方案设置子页面
│   ├── DiagnosticsView.swift       # 诊断日志子页面
│   └── Components/
│       ├── InfoSection.swift
│       └── ToggleRow.swift
│
├── Keyboard/                   # 键盘扩展 (UIKit + ObjC)
│   ├── KeyboardViewController.swift              # 主控
│   ├── KeyboardViewController+Actions.swift      # 按键动作
│   ├── KeyboardViewController+CandidateBar.swift  # 候选栏
│   ├── KeyboardViewController+Display.swift      # 按钮状态
│   ├── KeyboardViewController+Gestures.swift     # 高亮 + 长按
│   ├── KeyboardViewController+KeyFactory.swift   # 按键工厂
│   ├── KeyboardViewController+Layout.swift       # 键盘布局
│   ├── KeyPopupView.swift                        # 变体弹出面板
│   ├── KeyClickPlayer.swift                      # 内嵌点击音播放器
│   ├── UITextDocumentProxyAdapter.swift          # 代理适配器
│   ├── KeyboardType+UIKit.swift                  # 类型桥接
│   ├── RimeConfigManager.swift                   # RIME 配置部署 + OpenCC
│   └── RimeBridge/                               # ObjC 桥接 + Swift 封装
│       ├── Keyboard-Bridging-Header.h
│       ├── RimeSessionManager.h/.m               # librime C API 封装
│       ├── rime_api.h                            # librime 官方 C API
│       └── RimeEngineImpl.swift                  # RimeEngine 协议实现
│
└── Packages/
    ├── KeyboardCore/            # 纯逻辑层 (SPM, 120 个单元测试)
    │   └── Sources/KeyboardCore/
    │       ├── KeyboardController.swift   # 状态机 + 双路径 (RIME/Fake)
    │       ├── KeyboardState.swift        # 键盘状态
    │       ├── KeyboardAction.swift       # 用户动作枚举
    │       ├── KeyboardEffect.swift       # UI 刷新标记
    │       ├── CandidateItem.swift        # 候选数据模型
    │       ├── CandidateProvider.swift    # 候选词协议
    │       ├── RimeEngine.swift           # RIME 引擎抽象协议
    │       ├── RimeOutput.swift           # 引擎输出模型
    │       ├── CandidateProviderRimeAdapter.swift  # Fake → RimeEngine 适配器
    │       └── Logger.swift               # 统一日志系统
    │
    └── RimeBridge/              # RIME 桥接包 (SPM)
        ├── Sources/
        │   ├── RimeEngineImpl.swift       # 真实 RIME 引擎
        │   └── RimeBridgeObjC/            # ObjC 桥接层
        ├── Vendor/                        # xcframework (github: gitignored)
        └── TestTool/                      # macOS 验证工具
```

## 数据流

```
用户按键 → KeyboardViewController
  → KeyboardController.handle(.insertKey("n"))
    → rimeEngine.processKey("n")          [RIME 路径]
    → state.lastRimeOutput = output
    → updateInlinePreedit("n")            [拼音显示在输入框中]
    → syncUI(.compositionChanged)
      → refreshCandidateBar()
        → candidateItems()                [只显示候选词]
```

## 设置数据流

```
主 App 修改设置 → UserDefaults (App Group)
  → 设置 rime_needs_deploy = true
    → 用户切换键盘打字
      → RimeEngineImpl.processKey()
        → syncCustomYamlFiles()          [生成 .custom.yaml]
        → deployIfNeeded()               [librime 重新部署]
          → 新配置生效
```

## 构建与运行

```bash
# 单元测试（120 tests）
cd Packages/KeyboardCore && swift test

# Xcode 构建
xcodebuild -project "Universe Keyboard.xcodeproj" \
  -scheme "Universe Keyboard" \
  -destination 'platform=iOS Simulator,name=iPhone 17' build

# macOS RIME 验证工具
cd Packages/RimeBridge/TestTool && make && ./test_rime
```

> **注意**：`Packages/RimeBridge/Vendor/` 中的 xcframework 未纳入 Git（大小 126MB）。
> 首次克隆后需按 `.claude/plans/eager-sleeping-meteor.md` 中的说明编译这些依赖。

## RIME 集成状态

| 模块 | 状态 |
|------|------|
| RimeEngine 协议 | ✅ |
| KeyboardController 双路径 | ✅ |
| ObjC 桥接层 (RimeSessionManager) | ✅ |
| macOS 真实 librime 验证 | ✅ nihao→你好 |
| Preedit inline 显示 | ✅ |
| 候选栏 | ✅ |
| RIME 配置 UI | ✅ 候选数/简繁/部署 |
| OpenCC 简繁转换 | ✅ t2s + s2t |
| iOS xcframework (9个) | ✅ librime 1.16.1 |
| 统一日志系统 | ✅ Logger + 子页面 |
| 雾凇拼音 | 🔴 Phase 4 |

## 许可证

本项目代码采用 MIT License。RIME/librime 为 BSD-3-Clause。OpenCC 为 Apache-2.0。
