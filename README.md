# Universe Keyboard

iOS 第三方中文输入法，基于 RIME/librime 1.16.1 + librime-lua 引擎，追求接近 iOS 原生体验。

## 当前状态

✅ **Swift 6 严格并发迁移 + 统一 RIME 桥接边界 + 候选栏稳定性修复。** App 与 Keyboard Extension 以 Swift 6 构建；RIME 会话和主 App 部署能力统一由 `Packages/RimeBridge` 提供。完整部署只允许在主 App 中完成，切换到键盘后输入路径不得触发部署。`KeyboardCore` 当前基线为 347 个单元测试，0 失败。

## 功能

### 已实现

- **RIME/librime 1.16.1 + librime-lua** — 真实中文输入引擎，11 个依赖库全部从源码编译为 iOS xcframework
- **雾凇拼音 (rime-ice)** — 主 App 内一键下载 + 自动部署（~16MB），完整词库覆盖
- **Lua 插件接线** — `librime-lua` 已链接；日期输入、计算器等高级路径须在发布制品下 smoke test 后确认
- **方案选择器** — 内置朙月拼音 + 可下载雾凇拼音，支持切换和卸载
- **OpenCC 简繁转换** — 集成 t2s/s2t，用户可在设置中切换
- **26 键 QWERTY 布局** — 字母页 / 数字页 / 符号页三页体系
- **横向滚动候选栏** — 无极滑动翻页（无翻页按钮）、预加载 2 页、近边缘自动加载、渐隐遮罩
- **流式布局展开面板** — 替代固定网格，候选词宽度自适应，换行自动分行，竖向无限滚动
- **Apple HIG 合规** — 44pt 触摸目标、VoiceOver 无障碍标签、Dynamic Type、语义色、Spring 动画
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
- **按键音** — 内嵌生成点击音，由隔离音频 actor 串行播放，可调音量；运行时配置依赖允许完全访问
- **触感反馈** — UIImpactFeedbackGenerator，可调强度，实时预览
- **统一日志系统** — Logger 单例，4 级/6 类/环形缓冲/按分类独立开关
- **RIME 配置 UI** — 方案选择/候选数量/简繁切换/部署状态追踪
- **诊断日志** — 子页面：分类筛选胶囊、颜色编码、刷新/清空/复制
- **RIME Session 自动恢复** — 检测 session 丢失后自动重建并恢复方案选择
- **候选面板高度限制** — 展开面板不超过正常按键区高度，超出滚动
- **键盘闪烁缓解** — view.alpha=0 + 最终高度触发显示 + 候选面板高度限制
- **主 App** — 双 Tab 布局（引导 / 设置），设置全部改为子页面模式

### 计划中

- 滑动输入（英文先行，中文跟进）
- iPad 适配
- 用户词库

## 架构

```
Universe Keyboard.xcodeproj
├── Universe Keyboard/          # 主 App (SwiftUI, 双 Tab)
│   ├── App/                    # @main + ContentView
│   ├── Views/
│   │   ├── Components/         # BulletRow, CapsuleBadge, InfoSection, ToggleRow, SettingsNavigationLink
│   │   ├── Settings/           # FeedbackSettings, RimeSettings, SchemaPickerRow
│   │   ├── Diagnostics/        # DiagnosticsView
│   │   └── License/            # LicenseView
│   └── Services/               # Observation SchemaManager
│
├── Keyboard/                   # 键盘扩展 (UIKit + ObjC)
│   ├── Controllers/            # KeyboardViewController + 按职责拆分的扩展/协调器
│   ├── Views/
│   │   ├── KeyPopupView.swift
│   │   └── CandidateBar/       # CandidateButtonFactory, CandidateBarDataSource
│   ├── Services/               # KeyClickPlayer, UITextDocumentProxyAdapter
│   └── Bridge/                 # KeyboardType+UIKit
│
└── Packages/
    ├── KeyboardCore/            # 纯逻辑层 (SPM, 347 个基线单元测试)
    │   ├── KeyboardController, KeyboardState, KeyboardAction, KeyboardEffect
    │   ├── RimeConfigPostProcessor, RimeConfigTemplateGenerator + templates
    │   ├── ClickSoundGenerator, AutoCapitalizationRules
    │   ├── CandidateProviderRimeAdapter, Unzip, ZLib, Logger
    └── RimeBridge/              # 唯一生产 RIME 桥接包 (SPM)
        ├── Vendor/              # 11 xcframework (gitignored)
        ├── Sources/             # RimeEngine + RimeDeploymentService + ObjC bridge
        ├── Tests/               # 桥接契约测试
        └── TestTool/            # macOS 验证工具
```

## 数据流

```
用户按键 → KeyboardViewController
  → KeyboardController.handle(.insertKey("n"))
    → rimeEngine.processKey("n")         [RIME/librime-lua 路径]
    → 可用的 schema 过滤与翻译链       [Lua 高级路径待真实制品验证]
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
  → deployRimeConfig()                  [主 App 端全量部署]
    → RimeDeploymentService.deploy(.fullCheck)
      → setup + initialize + start_maintenance(True) + join + cleanup
    → rime_deployed = true             [键盘启动直接使用预编译 .bin]

主 App 修改设置 → UserDefaults (App Group)
  → 主 App 生成配置并执行 deployRimeConfig()
    → rime_deployed = true
      → 用户切换键盘后直接输入
        → RimeEngineImpl.processKey()   [只处理当前 session 输入，不做磁盘同步或部署]

Extension 运行期异常
  → 重建/恢复当前 RIME session          [runtime recovery，仅恢复会话]
  → 若仍需完整部署，提示回到主 App 处理 [Extension 不执行 full deployment]
```

## 构建与运行

```bash
# 校验固定版本 RIME 二进制制品与本地 receipt
bash scripts/ensure_rime_vendor.sh verify

# 纯逻辑单元测试（运行测试以查看数量）
swift test --package-path Packages/KeyboardCore

# 桥接契约测试（制品仅支持 iOS，因此由工程测试目标在 Simulator 上执行）
xcodebuild -project "Universe Keyboard.xcodeproj" \
  -scheme "RimeBridgeTests" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  CODE_SIGNING_ALLOWED=NO SWIFT_STRICT_CONCURRENCY=complete \
  SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES test

# App store 与键盘契约测试
xcodebuild -project "Universe Keyboard.xcodeproj" \
  -scheme "Universe Keyboard" \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  CODE_SIGNING_ALLOWED=NO SWIFT_STRICT_CONCURRENCY=complete \
  SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES test

# Swift 6 Xcode 构建
xcodebuild -project "Universe Keyboard.xcodeproj" \
  -scheme "Universe Keyboard" \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  CODE_SIGNING_ALLOWED=NO SWIFT_STRICT_CONCURRENCY=complete \
  SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES build

xcodebuild -project "Universe Keyboard.xcodeproj" \
  -scheme "Universe Keyboard" \
  -configuration Release \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  CODE_SIGNING_ALLOWED=NO SWIFT_STRICT_CONCURRENCY=complete \
  SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES build

# macOS RIME 验证工具
cd Packages/RimeBridge/TestTool && make && ./test_rime
```

> **注意**：`Packages/RimeBridge/Vendor/` 中的 xcframework 未纳入 Git。CI 与新开发环境通过
> `scripts/ensure_rime_vendor.sh fetch` 获取带 SHA-256 校验的固定 Release 制品，且依据
> `config/rime-vendor-manifest.env` 校验版本、归档摘要与 framework 清单。当前已固定到
> `rime-vendor-ios-1.16.1-lua.1` Release 资产，配置与升级方式见
> `docs/architecture/rime-artifacts.md`。

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
| librime-lua 插件 | 已链接 `RIME_HAS_LUA=1`；发布前仍需真实制品下的 Lua schema 冒烟验证 |
| 方案切换 | ✅ 朙月拼音 ↔ 雾凇拼音 |
| `KeyboardCore` 单元测试 | ✅ All tests passing |
| `RimeBridgeTests` | ✅ iOS Simulator, 7 contract tests |
| `UniverseKeyboardTests` / `KeyboardTests` | ✅ iOS Simulator, 23 store/model/coordination contract tests |
| Swift 6 构建 | ✅ App + Keyboard Extension strict concurrency |

## 许可证

本项目代码采用 MIT License。RIME/librime 为 BSD-3-Clause。OpenCC 为 Apache-2.0。
雾凇拼音 (rime-ice) 为 GPL-3.0，用户在使用前需阅读并同意许可证。
