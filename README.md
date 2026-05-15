# Universe Keyboard

iOS 第三方中文输入法，基于 RIME/librime 引擎 + 雾凇拼音配置，追求接近 iOS 原生体验。

## 当前状态

🚧 **Phase 3 架构完成，待 iOS 编译** — RIME 桥接层和双路径架构已全部完成并经过 macOS 真实 librime 1.16.1 验证。iOS 端暂时使用硬编码候选词，等待 librime 从源码编译为 iOS xcframework。

## 功能

### 已实现

- **26 键 QWERTY 布局** — 字母页 / 数字页 / 符号页三页体系
- **横向滚动候选栏** — UIScrollView 驱动、SF Symbol 展开按钮、渐隐遮罩
- **Inline Preedit** — 拼音直接显示在输入框中（类似原生键盘），候选栏只显示候选词
- **上下文感知标点** — 中文模式下数字页显示中文标点
- **Shift / Caps Lock** — 双击锁定大写，单击切换单次大写
- **长按变体字符** — 19 个字母键支持长按弹出变体
- **长按删除** — 按下即时删除 + 0.5s 后连续删除（0.08s 间隔，匹配原生键盘节奏）
- **中英切换** — 一键切换输入模式
- **空格 / 回车** — 回车键标题根据输入框类型动态变化
- **地球键** — 切换到下一个输入法
- **键盘类型适配** — 邮箱/URL 自动切换英文并显示快捷键
- **自动大写** — 句首自动 Shift
- **双击空格句号** — 英文模式下双击空格输入 `. `
- **深浅色模式** — 自动跟随系统
- **触感反馈 + 键盘点击音** — 可独立开关
- **App Group 设置共享** — 主 App 与键盘扩展通过 UserDefaults 共享设置
- **主 App** — 双 Tab 布局（引导 / 设置）、RIME 部署 UI（状态追踪、诊断日志、进度显示）
- **RIME 诊断系统** — 键盘运行状态自动写入共享存储，主 App 可查看

### 开发中

- iOS 版 librime 1.16.1 编译（Boost + yaml-cpp 已就绪，leveldb/opencc/glog 待编译）

### 计划中

- 雾凇拼音配置导入
- 滑动输入（英文先行，中文跟进）
- iPad 适配
- 用户词库

## 架构

```
Universe Keyboard.xcodeproj
├── Universe Keyboard/          # 主 App (SwiftUI, 双 Tab)
│   ├── ContentView.swift       # Tab 1: 引导 / Tab 2: 设置 + RIME 部署
│   ├── Universe_KeyboardApp.swift
│   └── Components/
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
│   ├── UITextDocumentProxyAdapter.swift          # 代理适配器
│   ├── KeyboardType+UIKit.swift                  # 类型桥接
│   ├── RimeConfigManager.swift                   # RIME 配置部署
│   ├── RimeDiagnostics.swift                     # RIME 运行诊断
│   └── RimeBridge/                               # ObjC 桥接 + Swift 封装
│       ├── Keyboard-Bridging-Header.h
│       ├── RimeSessionManager.h/.m               # librime C API 封装
│       ├── rime_api.h                            # librime 官方 C API
│       └── RimeEngineImpl.swift                  # RimeEngine 协议实现
│
└── Packages/
    ├── KeyboardCore/            # 纯逻辑层 (SPM, 113 个单元测试)
    │   └── Sources/KeyboardCore/
    │       ├── KeyboardController.swift   # 状态机 + 双路径 (RIME/Fake)
    │       ├── KeyboardState.swift        # 键盘状态 (含 inline preedit 支持)
    │       ├── KeyboardAction.swift       # 用户动作枚举
    │       ├── KeyboardEffect.swift       # UI 刷新标记
    │       ├── CandidateItem.swift        # 候选数据模型
    │       ├── CandidateProvider.swift    # 候选词协议
    │       ├── RimeEngine.swift           # RIME 引擎抽象协议
    │       ├── RimeOutput.swift           # 引擎输出模型
    │       └── CandidateProviderRimeAdapter.swift  # Fake → RimeEngine 适配器
    │
    └── RimeBridge/              # RIME 桥接包 (SPM, 待链接 xcframework)
        ├── Sources/
        │   ├── RimeEngineImpl.swift       # 真实 RIME 引擎
        │   └── RimeBridgeObjC/            # ObjC 桥接层
        ├── Vendor/                        # xcframework 存放目录
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
        → candidateItems()                [只显示候选词，不重复拼音]
```

## 构建与运行

```bash
# 单元测试
cd Packages/KeyboardCore && swift test    # 113 tests

# Xcode 构建
xcodebuild -project "Universe Keyboard.xcodeproj" \
  -scheme "Universe Keyboard" \
  -destination 'generic/platform=iOS' build

# macOS RIME 验证工具
cd Packages/RimeBridge/TestTool && make && ./test_rime
```

## RIME 集成状态

| 模块 | 状态 |
|------|------|
| RimeEngine 协议 | ✅ |
| KeyboardController 双路径 | ✅ |
| ObjC 桥接层 (RimeSessionManager) | ✅ |
| macOS 真实 librime 验证 | ✅ nihao→你好 |
| Preedit inline 显示 | ✅ |
| 候选栏 | ✅ |
| RIME 部署 UI | ✅ |
| iOS xcframework | 🔴 待编译 |

## 许可证

本项目代码采用 MIT License。RIME/librime 为 BSD-3-Clause。
