# Universe Keyboard

iOS 第三方中文输入法，基于 RIME/librime 1.16.1 + librime-lua 引擎，追求接近 iOS 原生体验。

## 当前状态

✅ **雾凇拼音 + librime-lua 集成完成。** 键盘支持完整 Lua 脚本功能（日期输入、计算器、错音纠正等），223 个单元测试，0 失败。

## 功能

### 已实现

- **RIME/librime 1.16.1 + librime-lua** — 真实中文输入引擎，11 个依赖库全部从源码编译为 iOS xcframework
- **雾凇拼音 (rime-ice)** — 主 App 内一键下载 + 自动部署（~16MB），完整词库覆盖
- **Lua 高级功能** — 日期输入(rq)、计算器(=1+2)、错音纠正、自动大写、候选置顶等
- **方案选择器** — 内置朙月拼音 + 可下载雾凇拼音，支持切换和卸载
- **OpenCC 简繁转换** — 集成 t2s/s2t，用户可在设置中切换
- **26 键 QWERTY 布局** — 字母页 / 数字页 / 符号页三页体系
- **横向滚动候选栏** — UIScrollView 驱动、SF Symbol 展开按钮、渐隐遮罩
- **Inline Preedit** — 拼音直接显示在输入框中（类似原生键盘）
- **上下文感知标点** — 中文模式下数字页显示中文标点
- **Shift / Caps Lock** — 双击锁定大写，单击切换单次大写
- **长按变体字符** — 19 个字母键支持长按弹出变体
- **长按删除** — 按下即时删除 + 0.5s 后连续删除（0.08s 间隔）
- **中英切换** — 一键切换输入模式
- **空格 / 回车** — 回车键标题根据输入框类型动态变化
- **键盘类型适配** — 邮箱/URL 自动切换英文并显示快捷键
- **自动大写** — 句首自动 Shift
- **双击空格句号** — 英文模式下双击空格输入 `. `
- **深浅色模式** — 自动跟随系统
- **按键音** — 内嵌生成点击音，AVAudioPlayer 播放，可调音量，无需完全访问
- **触感反馈** — UIImpactFeedbackGenerator，可调强度，实时预览
- **统一日志系统** — Logger 单例，4 级/5 类/环形缓冲/独立开关
- **RIME 配置 UI** — 方案选择/候选数量/简繁切换/部署状态追踪
- **诊断日志** — 子页面：动画刷新和清空按钮
- **主 App** — 双 Tab 布局（引导 / 设置），设置全部改为子页面模式

### 计划中

- 滑动输入（英文先行，中文跟进）
- iPad 适配
- 用户词库

## 架构

```
Universe Keyboard.xcodeproj
├── Universe Keyboard/          # 主 App (SwiftUI, 双 Tab)
│   ├── ContentView.swift       # Tab 1: 引导 / Tab 2: 设置
│   ├── Universe_KeyboardApp.swift
│   ├── SchemaManager.swift     # 雾凇下载/解压/安装/Lua剥离/主App部署 编排器
│   ├── RimeDeployer.h/.m       # 主 App 端最小 RIME 部署封装
│   ├── LicenseView.swift       # GPL-3.0 许可证查看
│   ├── SchemaPickerRow.swift   # 方案选择行组件
│   ├── FeedbackSettingsView.swift
│   ├── RimeSettingsView.swift  # 方案选择 + 下载 UI + 部署控制
│   ├── DiagnosticsView.swift
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
│       ├── RimeSessionManager.h/.m               # librime C API + schema切换 + lua检测
│       ├── rime_api.h                            # librime 官方 C API
│       └── RimeEngineImpl.swift                  # RimeEngine 协议实现 + deploy
│
└── Packages/
    ├── KeyboardCore/            # 纯逻辑层 (SPM, 223 个单元测试)
    │   ├── Sources/KeyboardCore/
    │   │   ├── KeyboardController.swift   # 状态机 + 双路径 (RIME/Fake)
    │   │   ├── KeyboardState.swift        # 键盘状态
    │   │   ├── KeyboardAction.swift       # 用户动作枚举
    │   │   ├── KeyboardEffect.swift       # UI 刷新标记
    │   │   ├── CandidateItem.swift        # 候选数据模型
    │   │   ├── CandidateProvider.swift    # 候选词协议
    │   │   ├── RimeEngine.swift           # RIME 引擎抽象协议
    │   │   ├── RimeOutput.swift           # 引擎输出模型
    │   │   ├── RimeConfigPostProcessor.swift # Lua剥离 + 条件检测
    │   │   ├── RimeConfigTemplates.swift  # YAML 生成 + OpenCC 配置
    │   │   ├── Unzip.swift                # zip 解压器（libz, raw deflate）
    │   │   ├── CandidateProviderRimeAdapter.swift  # Fake → RimeEngine 适配器
    │   │   └── Logger.swift               # 统一日志系统
    │   └── ZLib.swift                 # 纯 Swift zlib（@_silgen_name），替代 CZLib
    │
    └── RimeBridge/              # RIME 桥接包 (SPM)
        ├── Sources/
        │   └── RimeBridgeObjC/            # ObjC 桥接层
        ├── Vendor/                        # 11 xcframework (gitignored)
        │   ├── librime.xcframework        # RIME 引擎 1.16.1
        │   ├── librime-lua.xcframework    # Lua 插件
        │   ├── liblua.xcframework         # PUC Lua 5.4
        │   ├── libopencc.xcframework      # 简繁转换
        │   ├── libleveldb.xcframework     # 词典存储
        │   ├── libmarisa.xcframework      # Trie 索引
        │   ├── libyaml-cpp.xcframework    # YAML 解析
        │   ├── libglog.xcframework        # 日志
        │   ├── boost_atomic.xcframework   # Boost Atomic
        │   ├── boost_filesystem.xcframework  # Boost FS
        │   └── boost_regex.xcframework    # Boost Regex
        ├── scripts/                       # 编译脚本
        └── TestTool/                      # macOS 验证工具
```

## 数据流

```
用户按键 → KeyboardViewController
  → KeyboardController.handle(.insertKey("n"))
    → rimeEngine.processKey("n")         [RIME/librime-lua 路径]
    → Lua 脚本处理 (日期/计算器/纠正等)
    → state.lastRimeOutput = output
    → updateInlinePreedit("n")           [拼音显示在输入框中]
    → syncUI(.compositionChanged)
      → refreshCandidateBar()
        → candidateItems()              [只显示候选词]
```

## 设置数据流

```
主 App 下载雾凇 → SchemaManager.installRimeIceFiles()
  → activateRimeIce()                  [设置 active schema + requestDeploy]
  → deployRimeConfig()                  [主 App 端 RimeDeployer 全量部署]
    → RimeDeployer.deployWithSharedDataDir:userDataDir:
      → setup + initialize + start_maintenance(True) + join + cleanup
    → rime_deployed = true             [键盘启动直接使用预编译 .bin]

主 App 修改设置 → UserDefaults (App Group)
  → 设置 rime_needs_deploy = true
    → 用户切换键盘打字
      → RimeEngineImpl.processKey()
        → syncCustomYamlFiles()         [生成 .custom.yaml]
        → deployIfNeeded()              [librime 增量部署]
          → 新配置生效
```

## 构建与运行

```bash
# 单元测试（224 tests）
cd Packages/KeyboardCore && swift test

# Xcode 构建
xcodebuild -project "Universe Keyboard.xcodeproj" \
  -scheme "Universe Keyboard" \
  -destination 'platform=iOS Simulator,name=iPhone 17' build

# macOS RIME 验证工具
cd Packages/RimeBridge/TestTool && make && ./test_rime
```

> **注意**：`Packages/RimeBridge/Vendor/` 中的 xcframework 未纳入 Git（大小 ~170MB）。
> 首次克隆后需按编译脚本编译这些依赖。

## RIME 集成状态

| 模块 | 状态 |
|------|------|
| RimeEngine 协议 | ✅ |
| KeyboardController 双路径 | ✅ |
| ObjC 桥接层 (RimeSessionManager) | ✅ |
| macOS 真实 librime 验证 | ✅ nihao→你好 |
| Preedit inline 显示 | ✅ |
| 候选栏 | ✅ |
| RIME 配置 UI | ✅ 方案选择/候选数/简繁/部署 |
| OpenCC 简繁转换 | ✅ t2s + s2t |
| iOS xcframework (11个) | ✅ librime 1.16.1 + Lua |
| 统一日志系统 | ✅ Logger + 子页面 |
| 雾凇拼音 | ✅ 下载 + 自动部署 |
| 主 App 端 RIME 部署 | ✅ 全量编译，键盘秒启动 |
| librime-lua 插件 | ✅ 完整 Lua 功能，RIME_HAS_LUA=1 |
| 方案切换 | ✅ 朙月拼音 ↔ 雾凇拼音 |
| 单元测试 | ✅ 224 tests, 0 failures |

## 许可证

本项目代码采用 MIT License。RIME/librime 为 BSD-3-Clause。OpenCC 为 Apache-2.0。
雾凇拼音 (rime-ice) 为 GPL-3.0，用户在使用前需阅读并同意许可证。
