# iOS RIME 键盘开发方案


> **状态：Superseded。** 本文件是项目初期（2026-05-10）生成的开发方案，已被实际实现超越，仅供历史追溯。当前架构与设计决策以 `docs/PROJECT_CONTEXT.md`、`docs/architecture/`（含 ADR）、`CONTEXT_INDEX.md` 及 Knowledge OS 体系为准。
生成日期：2026-05-10
目标读者：偏新手的 iOS 开发者
目标产品：一款接近 iOS 原生体验、支持 RIME 与雾凇拼音配置、支持滑动输入、界面简洁美观的 iOS 第三方键盘

---

## 1. 先说结论

这款产品可以做，但要把它当成“一个包含 App + 键盘扩展 + 输入法引擎 + 配置管理 + 测试体系”的长期项目，而不是一个简单 SwiftUI 页面。

推荐路线：

1. 先做一个稳定的第三方键盘骨架。
2. 再接入 RIME/librime，实现 26 键拼音输入、候选词、上屏、删除、翻页。
3. 再支持雾凇拼音配置的导入、部署、更新与回滚。
4. 最后做滑动输入，因为它不是 RIME 原生一行代码就能打开的功能，而是需要“手势轨迹识别 + 拼音/英文候选解码 + RIME 候选合并”。

建议总周期：9 到 12 个月。
建议第一个可用版本只做“RIME 拼音键盘 + 雾凇导入 + 基础候选栏 + 基础设置”，等核心稳定后再做滑动输入。

---

## 2. 官方资料优先级

每做一个阶段，先查官方文档。尤其是 iOS 键盘扩展有很多系统限制，不能靠猜。

### Apple 官方文档

- [Creating a custom keyboard](https://developer.apple.com/documentation/uikit/creating-a-custom-keyboard)：创建系统级自定义键盘扩展。
- [Configuring a custom keyboard interface](https://developer.apple.com/documentation/uikit/configuring-a-custom-keyboard-interface)：键盘界面如何适配不同输入类型、尺寸和系统要求。
- [Configuring open access for a custom keyboard](https://developer.apple.com/documentation/uikit/configuring-open-access-for-a-custom-keyboard)：Full Access、共享容器、网络权限与用户信任。
- [UIInputViewController](https://developer.apple.com/documentation/uikit/uiinputviewcontroller)：键盘扩展的主控制器。
- [UITextDocumentProxy](https://developer.apple.com/documentation/uikit/uitextdocumentproxy)：向当前输入框插入、删除、读取光标附近上下文。
- [UIInputViewAudioFeedback](https://developer.apple.com/documentation/uikit/uiinputviewaudiofeedback)：键盘点击音相关能力。
- [App Extension Programming Guide: Custom Keyboard](https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/CustomKeyboard.html)：旧文档，但仍然很有价值，里面集中说明了第三方键盘限制。
- [App Extension Keys](https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/AppExtensionKeys.html)：键盘扩展 `Info.plist` 里的 `PrimaryLanguage`、`RequestsOpenAccess` 等配置。
- [Virtual keyboards - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/virtual-keyboards)：虚拟键盘的人机界面设计要求。
- [SwiftUI](https://developer.apple.com/documentation/swiftui)：主 App 设置界面建议用 SwiftUI。
- [Observation](https://developer.apple.com/documentation/Observation)：iOS 17+ 的状态管理方式，适合主 App 设置页。
- [SwiftData ModelContainer](https://developer.apple.com/documentation/swiftdata/modelcontainer)：主 App 里保存用户配置、主题、导入记录。
- [App Intents](https://developer.apple.com/documentation/appintents/)：后期可给“切换方案、打开设置、同步配置”等动作做快捷指令。
- [Adding a privacy manifest](https://developer.apple.com/documentation/bundleresources/adding-a-privacy-manifest-to-your-app-or-third-party-sdk)：隐私清单，键盘类 App 必须认真做。
- [Liquid Glass](https://developer.apple.com/documentation/TechnologyOverviews/liquid-glass)：如果目标系统和 Xcode 版本支持，可以让主 App 采用最新系统视觉语言。

### RIME 与雾凇资料

- [rime/librime](https://github.com/rime/librime)：RIME 输入法核心库，C++ 实现。
- [iDvel/rime-ice](https://github.com/iDvel/rime-ice)：雾凇拼音配置，长期维护的简体词库。
- [RIME 官网](https://rime.im)：RIME 项目入口。

注意：`librime` 是 BSD-3-Clause，雾凇拼音仓库当前标注 GPL-3.0。假如你把雾凇配置直接打包进商店 App，需要认真阅读许可证，必要时咨询懂开源许可证的人。更稳妥的方式是：App 内置一份最小可用配置，把雾凇作为用户自行导入或可选下载的配置来源，并在 App 内展示许可证说明。

---

## 3. iOS 第三方键盘必须知道的限制

先理解限制，后面架构才不会走歪。

### 3.1 键盘扩展不是普通 App

iOS 第三方键盘是一个 App Extension。你会有两个 Target：

- 主 App：负责设置、配置导入、教程、主题编辑、隐私说明。
- Keyboard Extension：真正出现在别的 App 输入框里的键盘。

键盘扩展没有自己的窗口，只能在 `UIInputViewController` 的 `inputView` 区域里绘制。键盘想输入文字，必须通过 `textDocumentProxy.insertText()`；想删除文字，通过 `textDocumentProxy.deleteBackward()`。

### 3.2 必须提供“切换下一个键盘”

Apple 明确要求自定义键盘必须让用户可以切换到其他键盘。实现方式是：

- 判断 `needsInputModeSwitchKey`。
- 显示地球键或类似按钮。
- 点击时调用 `advanceToNextInputMode()`。

这个按钮不能省。即使你想做极简 UI，也要保留。

### 3.3 不是所有输入框都能用第三方键盘

以下场景系统可能会自动切回系统键盘：

- 密码输入框，也就是 `secureTextEntry = true`。
- 电话号码键盘，例如 `UIKeyboardTypePhonePad`、`UIKeyboardTypeNamePhonePad`。
- 某些 App 主动禁用第三方键盘，例如银行、医疗、企业管理类 App。

所以产品文案里不要承诺“所有地方都可用”。正确说法是“在 iOS 允许第三方键盘的输入场景中可用”。

### 3.4 不能 100% 复刻系统键盘

第三方键盘不能完全复制系统键盘能力，例如：

- 不能在键盘区域上方弹出像系统键盘那样越界的按键气泡。
- 不能直接控制宿主 App 的文本选择菜单。
- 不能在安全输入框里工作。
- 语音听写等能力受限制。

所以“接近原生体验”的意思应该是：响应速度、布局、反馈、候选栏、按键状态、深浅色、横竖屏、iPad 适配尽量像原生，而不是完全拥有系统私有能力。

### 3.5 Full Access 要谨慎

`RequestsOpenAccess` 打开后，键盘可以获得更多能力，比如网络、共享容器写入等，但用户会看到“允许完全访问”的敏感开关。

建议策略：

- 默认离线可用，不上传用户输入。
- 第一个版本尽量不依赖网络。
- 主 App 负责写入共享 App Group 容器，键盘扩展优先只读配置。
- 如果确实需要键盘扩展写入用户词库、日志或同步状态，再开启 Full Access，并用非常直白的文字解释为什么需要。
- 不记录完整按键流。调试日志里也不要写入用户输入内容。

---

## 4. 产品目标

### 4.1 第一阶段目标

做出一款可长期维护的中文输入键盘：

- 26 键拼音输入。
- RIME 候选词。
- 雾凇拼音配置导入。
- 中英切换。
- 标点、数字、符号页。
- 删除、空格、回车、Shift、地球键。
- 深色模式、浅色模式。
- iPhone 主要尺寸适配。
- 主 App 里有清楚的新手引导。

### 4.2 第二阶段目标

接近原生体验：

- 根据当前输入框类型切换布局，例如邮箱、URL、数字、普通文本。
- 自动大写。
- 双击空格输入句号。
- 长按按键显示可选字符。
- 删除键长按连续删除。
- 候选栏翻页。
- RIME 方案切换。
- 用户词库和自定义短语。
- iPad 布局适配。

### 4.3 第三阶段目标

加入滑动输入：

- 英文滑动输入。
- 中文拼音滑动输入。
- 滑动轨迹预览。
- 滑动候选与 RIME 候选合并排序。
- 个性化排序，但必须本地处理。

---

## 5. 技术路线总览

推荐使用“混合架构”：

- 键盘扩展入口用 UIKit，因为 Apple 的键盘扩展核心 API 是 `UIInputViewController`。
- 键盘 UI 可以先用 SwiftUI 快速搭建，再把性能敏感的按键区域逐步替换成 UIKit 自定义 View。
- 主 App 用 SwiftUI。
- 配置、主题、导入记录用 SwiftData 或轻量 JSON。
- RIME 用 `librime` 编译为 iOS 可用的 `XCFramework`。
- Swift 调用 RIME 时，先用 Objective-C++ 包一层，降低新手直接处理 C++/Swift 互操作的难度。

一句话架构：

```text
主 App(SwiftUI)
  -> 配置导入/设置/主题/隐私说明
  -> App Group 共享目录

Keyboard Extension(UIInputViewController)
  -> Keyboard UI
  -> KeyboardCore 状态机
  -> RimeBridge
  -> librime
  -> textDocumentProxy 上屏
```

---

## 6. 推荐项目结构

建议从一开始就把项目拆清楚。新手也可以拆，因为这样后面更容易测试。

```text
RimeKeyboard/
  RimeKeyboard.xcodeproj
  Packages/
    KeyboardCore/
      Sources/
        KeyboardCore/
          KeyboardState.swift
          KeyboardAction.swift
          KeyboardLayout.swift
          KeyModel.swift
          TextInputClient.swift
          CompositionState.swift
          Candidate.swift
          InputMode.swift
      Tests/
        KeyboardCoreTests/

    KeyboardUI/
      Sources/
        KeyboardUI/
          KeyboardRootView.swift
          KeyButtonView.swift
          CandidateBarView.swift
          ToolbarView.swift
          SymbolKeyboardView.swift
          NumberKeyboardView.swift
          LayoutMetrics.swift
          KeyboardTheme.swift
      Tests/
        KeyboardUITests/

    RimeBridge/
      Sources/
        RimeBridge/
          RimeEngine.swift
          RimeEngineClient.swift
          RimeCandidate.swift
          RimeComposition.swift
          RimeBridge.h
          RimeBridge.mm
      Vendor/
        librime.xcframework
        opencc.xcframework
        yaml-cpp.xcframework
        marisa.xcframework
        leveldb.xcframework
      Tests/
        RimeBridgeTests/

    SwipeEngine/
      Sources/
        SwipeEngine/
          SwipePoint.swift
          SwipePath.swift
          SwipeDecoder.swift
          KeyHitTester.swift
          SpatialScorer.swift
          PinyinSwipeModel.swift
          EnglishSwipeModel.swift
          SwipeCandidateMerger.swift
      Tests/
        SwipeEngineTests/

    SharedModels/
      Sources/
        SharedModels/
          AppSettings.swift
          SchemaPackage.swift
          ThemePackage.swift
          PrivacyMode.swift
          SharedContainer.swift

  App/
    RimeKeyboardApp.swift
    Features/
      Onboarding/
      Settings/
      SchemaManager/
      ThemeEditor/
      PrivacyCenter/
      AboutLicenses/
    Resources/
      PrivacyInfo.xcprivacy
      DefaultRimeConfig/
      DefaultThemes/

  KeyboardExtension/
    KeyboardViewController.swift
    KeyboardHostView.swift
    Info.plist
    Resources/
      PrivacyInfo.xcprivacy

  Tools/
    build_librime_xcframework.sh
    verify_rime_config.sh
    package_rime_ice.sh
    generate_keyboard_snapshots.sh

  Docs/
    official-docs-checklist.md
    privacy-policy-draft.md
    rime-build-notes.md
    testing-matrix.md
```

---

## 7. 模块说明

### 7.1 主 App

主 App 不是摆设。Apple 要求包含键盘扩展的 App 本身也要有实际功能。

主 App 应该负责：

- 教用户如何启用键盘。
- 解释 Full Access 是否需要。
- 导入 RIME 配置。
- 更新或回滚雾凇配置。
- 管理主题。
- 管理用户短语。
- 查看许可证。
- 做故障修复，例如“重新部署 RIME 配置”。

新手友好建议：

- 首页不要堆功能，做成 4 个入口：启用键盘、配置方案、外观、隐私。
- 每个入口只解决一个问题。
- 导入失败时给出人话错误，比如“缺少 `default.yaml`”，不要只显示 `RIME deploy failed`。

### 7.2 Keyboard Extension

键盘扩展负责实时输入。它必须很轻：

- 启动快。
- 内存小。
- 不做网络请求。
- 不做大文件扫描。
- 不在主线程做 RIME 部署。
- 不记录用户输入日志。

建议只在扩展里做这些事：

- 加载已部署好的 RIME 数据。
- 处理按键。
- 显示候选词。
- 上屏文本。
- 读设置快照。
- 在必要时通知主 App“需要重新部署配置”。

### 7.3 KeyboardCore

这是最值得认真写测试的模块。

它不应该依赖 SwiftUI、UIKit 或 RIME。它只关心“用户动作如何改变键盘状态”。

例子：

```swift
public enum KeyboardAction: Equatable {
    case tapKey(String)
    case delete
    case space
    case enter
    case shift
    case switchMode(InputMode)
    case selectCandidate(Int)
    case beginSwipe(SwipePoint)
    case updateSwipe(SwipePoint)
    case endSwipe
}
```

这样做的好处是：你可以在单元测试里模拟按键，不需要启动 iOS 模拟器。

### 7.4 KeyboardUI

UI 要拆小，不要写一个几千行的 `KeyboardView.swift`。

推荐组件：

- `KeyboardRootView`：整个键盘。
- `CandidateBarView`：候选栏。
- `KeyButtonView`：单个按键。
- `KeyboardRowView`：一行按键。
- `KeyboardPageView`：字母页、数字页、符号页。
- `ToolbarView`：方案切换、设置、剪贴板等后期功能。
- `SwipeTrailView`：滑动输入轨迹。
- `KeyPopupView`：长按候选字符，但注意不能越过键盘扩展主区域。

设计规则：

- 键帽圆角控制在类似系统键盘的范围，不要做太夸张。
- 普通键、功能键、候选栏背景分层清晰。
- 深色模式不要只是反色，要单独调对比度。
- 所有按键要有稳定宽高，不要因为文字变化导致布局跳动。
- 候选词太长时截断或横向滚动，不要挤压其他候选。

### 7.5 RimeBridge

RIME 是 C++ 项目。新手直接在 Swift 里调用 C++ 会比较吃力。建议使用 Objective-C++ 包一层。

Swift 侧看到的是简单接口：

```swift
public protocol RimeEngineClient {
    func startSession() throws -> RimeSessionID
    func processKey(_ key: String, session: RimeSessionID) throws -> RimeOutput
    func selectCandidate(_ index: Int, session: RimeSessionID) throws -> RimeOutput
    func reset(session: RimeSessionID)
    func deploy(configPath: URL, userPath: URL) throws
}
```

Objective-C++ 侧负责：

- 初始化 `librime`。
- 设置共享目录、用户目录、同步目录。
- 创建 session。
- 处理 key event。
- 读取 composition、menu、candidates、commit。
- 把 C++ 数据转换成 Swift 能理解的结构。

### 7.6 SwipeEngine

滑动输入不要直接写死在 UI 里，要做成独立模块。

输入：

- 用户手指轨迹点：`[(x, y, time)]`
- 当前键盘布局：每个 key 的位置和大小
- 当前输入模式：中文、英文

输出：

- 候选拼音串或英文单词
- 每个候选的分数
- 可解释的 debug 信息，例如命中了哪些按键

最小算法：

1. 对轨迹采样，减少点数量。
2. 把每个点映射到最近的按键。
3. 合并连续重复按键。
4. 根据距离、拐点、速度计算 key sequence 分数。
5. 英文模式查词典。
6. 中文模式把 key sequence 转为可能的拼音串，再交给 RIME 出候选。
7. 将滑动候选和 RIME 普通候选合并。

后期算法：

- 用 Core ML 做本地排序。
- 用用户本地词频做个性化。
- 引入拼音音节约束，避免产生不存在的拼音。
- 引入常用词路径模板，提高中文滑动准确率。

---

## 8. RIME 与雾凇接入方案

### 8.1 librime 编译

`librime` 依赖较多，包括 Boost、LevelDB、marisa、OpenCC、yaml-cpp 等。iOS 里建议把它们都编成 `XCFramework`。

建议分三步：

1. 先在 macOS 命令行把 `librime` 跑通。
2. 再编 iOS Simulator。
3. 最后编真机 arm64，并合成 `XCFramework`。

新手不要一开始就追求“全自动脚本完美”。第一版可以先记录手工步骤，跑通后再把步骤脚本化。

### 8.2 是否启用 librime-lua

雾凇拼音有很多高级能力依赖 Lua，例如日期、农历、UUID、计算器、错音提示等。你的 App 可以分两种模式：

- 基础模式：不启用 `librime-lua`，先保证拼音、词库、候选稳定。
- 完整模式：编译 `librime-lua`，尽量还原雾凇体验。

建议第一版先做基础模式，等 RIME 主链路稳定后，再做 Lua 完整模式。

### 8.3 配置目录设计

推荐目录：

```text
App Group Container/
  Rime/
    shared/
      default.yaml
      rime_ice.schema.yaml
      rime_ice.dict.yaml
      cn_dicts/
      en_dicts/
      opencc/
      lua/
    user/
      user.yaml
      installation.yaml
      userdb/
    build/
      deployed files generated by librime
  Settings/
    keyboard-settings.json
    active-theme.json
    active-schema.json
```

主 App 写入和部署配置。键盘扩展启动时读取已部署好的结果。

### 8.4 导入雾凇配置

导入流程：

1. 用户在主 App 选择 zip 文件或文件夹。
2. App 解压到临时目录。
3. 校验是否包含必要文件。
4. 显示许可证与来源说明。
5. 复制到 App Group 的 `Rime/shared/`。
6. 调用 RIME deploy。
7. 写入导入记录。
8. 键盘扩展下次启动或收到配置版本变化后重新加载。

错误提示例子：

- “没有找到 `default.yaml`，这不像一个完整的 RIME 配置。”
- “配置里引用了 `cn_dicts/8105.dict.yaml`，但文件不存在。”
- “部署失败，可能是 YAML 缩进错误。请检查第 23 行附近。”

### 8.5 更新与回滚

不要直接覆盖用户正在使用的配置。建议保留版本：

```text
SchemaPackages/
  rime-ice-2026-05-10/
  rime-ice-2026-06-01/
  user-custom-001/
```

每次更新：

- 先复制到新目录。
- 部署成功后再切换 active schema。
- 部署失败则保持旧版本。

---

## 9. 输入流程设计

### 9.1 普通按键输入

流程：

```text
用户点击 key
  -> KeyboardUI 产生 KeyboardAction.tapKey
  -> KeyboardCore 更新本地状态
  -> RimeBridge.processKey
  -> RIME 返回 composition/candidates/commit
  -> 如果有 commit，调用 textDocumentProxy.insertText
  -> 更新候选栏
```

### 9.2 组合输入

中文输入时，用户输入 `nihao`，候选栏显示 “你好”。这里会有两个状态：

- composition：用户正在输入的编码，例如 `nihao`。
- candidates：候选词，例如 `你好`、`拟好` 等。

UI 上建议：

- 候选栏第一格显示当前高亮候选。
- 候选栏上方或候选第一项中显示拼音编码。
- 空格默认上屏第一候选。
- 回车可以提交原始编码，具体行为跟 RIME 配置走。

### 9.3 上屏

所有最终文字都通过 `textDocumentProxy.insertText()` 上屏。不要试图直接操作宿主 App 的输入框。

### 9.4 删除

删除分三种：

- 有 composition 时，先让 RIME 删除编码。
- 没有 composition 时，调用 `deleteBackward()` 删除宿主 App 中的字符。
- 长按删除时，做 repeat timer，频率逐步加快。

### 9.5 光标上下文

`textDocumentProxy.documentContextBeforeInput` 可以读取光标前文本，但不要假设永远有完整上下文。系统可能只给一小段，也可能返回 nil。

用途：

- 判断句首自动大写。
- 双空格句号。
- 英文补全。
- 中文候选排序。

注意：这些上下文属于用户隐私，不要写入日志。

---

## 10. 接近原生体验的功能清单

### 10.1 必做

- 地球键切换输入法。
- 删除键长按连续删除。
- Shift 大小写切换。
- Caps Lock 双击。
- 空格键显示当前语言或方案名。
- 回车键根据输入框类型显示不同文案，例如 `return`、`search`、`go`、`send`。
- 邮箱输入框显示 `@` 和 `.`。
- URL 输入框显示 `/`、`.`、`.com` 或更适合的网址符号。
- 数字页和符号页。
- 深浅色自动切换。
- 按键按下状态。
- 候选栏滚动。
- 横屏适配。
- iPhone 小屏适配。

### 10.2 应做

- 长按字母显示变体字符。
- 长按标点显示更多标点。
- 双击空格输入句号。
- 自动大写。
- 中文/英文模式独立记忆。
- 快速切换全拼、双拼。
- 标点中英文风格切换。
- 用户短语。
- 剪贴板短语面板，但要特别注意隐私。

### 10.3 后期做

- iPad 浮动键盘适配。
- 单手模式。
- 键盘高度自定义。
- 按键音。
- 触感反馈，先验证扩展里可用性，不可用时不要强求。
- App Intents 快捷动作，例如“打开键盘设置”“切换默认方案”。
- Control Center 控件，快速打开设置或切换隐私模式。

---

## 11. 滑动输入设计

滑动输入是本项目最大的不确定点之一。建议把它拆成“英文先行，中文跟进”。

### 11.1 为什么滑动输入难

普通点击输入是明确的：用户点了 `n`、`i`、`h`、`a`、`o`。

滑动输入是不明确的：用户手指划过一条路径，系统要猜他想输入哪个词。路径可能偏移，可能漏掉中间字母，也可能经过多余按键。

中文更难，因为中文不是直接输入单词，而是通常先输入拼音，再从候选词里选汉字。

### 11.2 第一版滑动输入

第一版只做清楚可控的范围：

- 英文单词滑动。
- 中文单字或短词拼音滑动。
- 不做整句滑动。
- 不做云端纠错。
- 不上传轨迹。

### 11.3 轨迹识别

数据结构：

```swift
public struct SwipePoint: Equatable {
    public let x: CGFloat
    public let y: CGFloat
    public let timestamp: TimeInterval
}

public struct SwipeCandidate: Equatable {
    public let text: String
    public let rawKeys: String
    public let score: Double
}
```

处理步骤：

1. 采样：每隔一定距离或时间保留一个点。
2. 命中：把点映射到最近 key。
3. 去重：`nnniiihhhaaoo` 变成 `nihao`。
4. 修正：允许轻微偏移，例如划到 `j` 附近也可能是 `h`。
5. 打分：越靠近 key 中心分越高，路径拐点越合理分越高。
6. 候选：输出多个可能 key sequence。

### 11.4 中文滑动到 RIME 的桥接

可以这样做：

```text
滑动轨迹
  -> 可能的字母串 nihao / nihao / niao
  -> 拼音合法性过滤
  -> 交给 RIME
  -> 得到中文候选
  -> 合并排序
```

RIME 仍然负责中文候选，SwipeEngine 只负责猜“用户可能想输入哪些拼音”。

### 11.5 滑动输入测试数据

要自己造一批测试轨迹：

- 标准轨迹：路径经过每个字母中心。
- 偏移轨迹：整体向上/下/左/右偏移。
- 快速轨迹：点少、速度快。
- 抖动轨迹：同一个 key 附近很多点。
- 相似词轨迹：`time`、`tree`、`there` 这种容易混淆。
- 中文拼音：`ni`、`hao`、`zhong`、`guo`、`shuang`、`pin`。

---

## 12. UI 设计方向

### 12.1 视觉风格

关键词：简洁、低干扰、接近系统、信息密度适中。

建议：

- 键盘区域使用系统背景色或轻微材质。
- 普通键白色或深灰，功能键稍深。
- 候选栏不要做成花哨卡片。
- 主题功能先少后多，先保证默认主题好看。
- 主 App 可以更精致，键盘扩展要克制。

### 12.2 主 App 信息架构

建议 Tab 或列表入口：

```text
首页
  - 键盘启用状态
  - 快速教程
  - 当前方案

方案
  - 当前 RIME 配置
  - 导入配置
  - 更新/回滚
  - 重新部署

外观
  - 主题
  - 键盘高度
  - 按键反馈

隐私
  - Full Access 说明
  - 本地数据说明
  - 日志开关
  - 删除所有数据
```

### 12.3 键盘布局

26 键基础布局：

```text
q w e r t y u i o p
 a s d f g h j k l
  shift z x c v b n m delete
 globe 123 space return
```

中文候选栏：

```text
[候选1] [候选2] [候选3] [候选4] [更多]
```

候选栏不要太高。中文输入法常用候选很重要，但键盘总高度也不能明显压迫输入区域。

---

## 13. 状态管理建议

主 App：

- iOS 17+ 用 `@Observable` 管理设置页状态。
- 用 SwiftData 保存用户方案、主题、导入记录。
- 用 App Group 导出一份 `keyboard-settings.json` 给扩展快速读取。

键盘扩展：

- 不建议直接使用复杂数据库。
- 启动时读取轻量 JSON 设置快照。
- RIME 状态由 `RimeEngine` 管。
- UI 状态由 `KeyboardState` 管。

重要原则：

- 主 App 可以慢一点，但要稳定。
- 键盘扩展必须快。
- 键盘扩展不要承担复杂设置编辑。

---

## 14. 组件复用策略

### 14.1 KeyModel 复用

所有按键都用同一套模型描述：

```swift
public struct KeyModel: Identifiable, Equatable {
    public let id: String
    public let label: String
    public let output: String?
    public let role: KeyRole
    public let width: KeyWidth
    public let longPressOutputs: [String]
}
```

这样字母键、删除键、空格键、符号键都可以用同一个 `KeyButtonView` 渲染，只是 role 不同。

### 14.2 Layout 复用

不要把布局写死在 View 里。定义布局数据：

```swift
public struct KeyboardLayout {
    public let rows: [KeyboardRow]
}
```

不同模式只需要换 layout：

- `.chineseQwerty`
- `.englishQwerty`
- `.numbers`
- `.symbols`
- `.email`
- `.url`

### 14.3 Theme 复用

主题只描述颜色、圆角、阴影、间距，不应该包含业务逻辑。

```swift
public struct KeyboardTheme: Codable, Equatable {
    public var backgroundColor: ThemeColor
    public var keyColor: ThemeColor
    public var functionKeyColor: ThemeColor
    public var textColor: ThemeColor
    public var cornerRadius: Double
}
```

### 14.4 TextInputClient 抽象

不要让业务逻辑直接依赖 `UITextDocumentProxy`。包一层：

```swift
public protocol TextInputClient {
    var documentContextBeforeInput: String? { get }
    func insertText(_ text: String)
    func deleteBackward()
    func adjustTextPosition(byCharacterOffset offset: Int)
}
```

测试时用假的 `FakeTextInputClient`，真实键盘里再适配 `UITextDocumentProxy`。

---

## 15. 新手学习路线

建议按这个顺序学，不要一次吃完整个项目。

### 第 1 阶段：Swift 与 SwiftUI

要会：

- `struct`、`class`、`enum`
- `protocol`
- `async/await`
- SwiftUI 的 `View`
- `@State`、`@Binding`、`@Observable`
- `NavigationStack`
- `List`、`Form`、`sheet`

练习：

- 做一个设置页。
- 保存一个主题。
- 从文件导入 zip。

### 第 2 阶段：UIKit 键盘扩展

要会：

- `UIInputViewController`
- `textDocumentProxy`
- Auto Layout 或 SwiftUI hosting
- App Extension 生命周期
- `Info.plist` 配置

练习：

- 做一个只会输入 `hello` 的键盘。
- 加删除键。
- 加地球键。
- 加 26 键布局。

### 第 3 阶段：RIME

要会：

- RIME 配置目录。
- schema、dict、deploy 是什么。
- C++ 库如何暴露给 Swift。
- Objective-C++ `.mm` 文件。

练习：

- 命令行跑通 librime。
- iOS Simulator 跑通 RIME 初始化。
- 输入 `nihao` 返回 `你好`。

### 第 4 阶段：滑动输入

要会：

- 手势坐标。
- 简单几何距离。
- 候选打分。
- 测试轨迹。

练习：

- 画出手指轨迹。
- 识别划过的 key。
- 输出一个可能的英文单词。

---

## 16. 开发周期规划

### Phase 0：调研与项目初始化，1 到 2 周

目标：

- 阅读 Apple 自定义键盘官方文档。
- 阅读 `librime` 和雾凇拼音 README。
- 创建 Xcode 工程。
- 建立 Git 仓库。
- 建立基本目录结构。
- 写第一版隐私原则。

交付：

- 可运行主 App。
- 空键盘扩展 Target。
- `Docs/official-docs-checklist.md`。

### Phase 1：基础键盘骨架，2 到 3 周

目标：

- `UIInputViewController` 正常显示键盘。
- 26 键布局。
- 点击字母上屏。
- 删除、空格、回车。
- 地球键切换。
- 深浅色。

交付：

- 可以在 Notes、Safari 搜索框中输入英文。
- 有基础单元测试。
- 有几张设备截图。

### Phase 2：KeyboardCore 抽象，2 周

目标：

- 把按键动作、布局、状态从 UI 里抽出来。
- 加 `TextInputClient`。
- 加 fake text client 测试。

交付：

- UI 层更薄。
- 按键逻辑可以单元测试。

### Phase 3：RIME 桥接，4 到 6 周

目标：

- 编译 `librime.xcframework`。
- Swift 可以初始化 RIME。
- 可以创建 session。
- 可以输入拼音并拿到候选。

交付：

- 测试：`nihao -> 你好`。
- 测试：删除 composition。
- 测试：选择候选。

### Phase 4：候选栏与中文输入，3 到 4 周

目标：

- 显示 RIME candidates。
- 空格选第一候选。
- 点击候选上屏。
- 翻页。
- composition 显示。

交付：

- 中文输入主链路可用。
- 基本体验可发 TestFlight 内测。

### Phase 5：雾凇配置导入，3 到 5 周

目标：

- 主 App 导入 zip。
- 校验 RIME 配置。
- 部署配置。
- 方案切换。
- 回滚。

交付：

- 用户能导入雾凇拼音。
- 导入失败有可理解提示。
- 许可证页面可见。

### Phase 6：原生体验打磨，4 到 6 周

目标：

- 输入框类型适配。
- 自动大写。
- 双空格句号。
- 长按按键。
- 删除 repeat。
- iPad 和横屏适配。
- 性能优化。

交付：

- 日常打字可用。
- 新手也能按教程完成启用和导入。

### Phase 7：滑动输入 MVP，6 到 8 周

目标：

- SwipeEngine 独立模块。
- 英文滑动输入。
- 中文拼音滑动输入第一版。
- 滑动候选合并到候选栏。

交付：

- `hello`、`world`、`nihao`、`zhongguo` 等基础样例可用。
- 有轨迹测试数据。

### Phase 8：隐私、稳定性、测试扩展，4 到 6 周

目标：

- Privacy Manifest。
- 隐私说明页。
- 日志脱敏。
- 崩溃恢复。
- 配置损坏恢复。
- 性能基准。

交付：

- TestFlight 公测准备。
- 测试矩阵完整。

### Phase 9：TestFlight 公测，6 到 8 周

目标：

- 收集真实用户反馈。
- 修复 RIME 配置兼容问题。
- 修复不同 App 输入框问题。
- 优化候选排序。
- 优化滑动输入。

交付：

- 1 到 3 个稳定 beta 版本。
- App Store 审核材料。

### Phase 10：上架准备，2 到 4 周

目标：

- App Store 文案。
- 隐私标签。
- 开源许可证。
- 截图。
- 审核说明。

交付：

- App Store 1.0。

---

## 17. 测试方案

### 17.1 单元测试

重点测不依赖 UI 的逻辑。

KeyboardCore：

- 点击字母后状态正确。
- Shift 状态正确。
- Caps Lock 正确。
- 删除 composition 优先于删除宿主文本。
- 空格在中文候选存在时选择第一候选。
- 输入模式切换正确。

RimeBridge：

- 初始化成功。
- 部署成功。
- 输入拼音返回候选。
- 选择候选返回 commit。
- session reset 后状态清空。
- 配置缺失时错误可读。

SwipeEngine：

- 标准轨迹识别正确。
- 偏移轨迹仍然能识别。
- 抖动轨迹不产生大量重复字母。
- 中文拼音合法性过滤正确。
- 候选排序稳定。

SharedModels：

- 设置 JSON 读写。
- 主题 JSON 读写。
- App Group 路径生成。
- 版本切换和回滚。

### 17.2 UI 测试

主 App：

- 首次打开显示启用教程。
- 导入配置流程。
- 切换主题。
- 查看隐私说明。
- 删除数据。

键盘扩展：

- 在测试宿主 App 的普通输入框输入。
- 在搜索框输入。
- 在邮箱输入框输入。
- 在 URL 输入框输入。
- 横竖屏切换。
- 深浅色切换。

### 17.3 快照测试

设备矩阵：

- 小屏 iPhone，例如 SE 尺寸。
- 标准 iPhone。
- 大屏 iPhone Pro Max。
- iPad 竖屏。
- iPad 横屏。

状态矩阵：

- 浅色中文。
- 深色中文。
- 英文。
- 数字。
- 符号。
- 候选很多。
- 候选很长。
- 滑动轨迹显示中。

### 17.4 性能测试

建议指标：

- 键盘冷启动：尽量小于 500ms。
- 单次按键到 UI 更新：尽量小于 16 到 33ms。
- 拼音候选刷新：尽量小于 80ms。
- 删除长按：不卡顿。
- 内存：尽量控制在扩展可承受范围内，避免被系统杀掉。

工具：

- Instruments Time Profiler。
- Allocations。
- XCTest measure。
- 自定义轻量性能日志，但日志不能包含用户输入内容。

### 17.5 隐私测试

必须测试：

- 不开启 Full Access 时核心输入是否可用。
- 没有网络权限时是否崩溃。
- 日志是否包含用户输入。
- 删除所有数据是否真的删除 App Group 数据。
- 导入配置是否会偷偷联网，第一版不应该联网。

### 17.6 RIME 回归测试

建立一份固定输入表：

```text
nihao -> 你好
zhongguo -> 中国
shijie -> 世界
ceshi -> 测试
woaini -> 我爱你
```

每次升级 RIME、雾凇配置、词库，都跑一遍。不要只靠手动试。

---

## 18. 风险清单

### 18.1 librime iOS 编译风险

风险：依赖复杂，编译脚本耗时。
应对：先做 macOS 命令行验证，再做 iOS；保留详细 build notes；不要一开始就接完整 Lua 插件。

### 18.2 键盘扩展性能风险

风险：扩展内存和生命周期受系统控制。
应对：键盘扩展只做实时输入，不做导入、部署、大文件操作。

### 18.3 Full Access 信任风险

风险：用户看到“完全访问”会担心隐私。
应对：默认离线、本地处理、解释清楚、尽量少要权限。

### 18.4 滑动输入准确率风险

风险：中文滑动输入难度高，第一版可能不好用。
应对：先做英文，再做中文短拼音；滑动候选不要覆盖 RIME 正常候选。

### 18.5 开源许可证风险

风险：雾凇 GPL-3.0 配置直接打包可能影响商业分发策略。
应对：显示许可证；考虑让用户自行导入；商业化前做许可证审查。

### 18.6 App Store 审核风险

风险：键盘类 App 对隐私说明要求高。
应对：准备清楚的隐私说明、Full Access 说明、数据收集说明、许可证说明。

---

## 19. 适合使用的 Codex Skills

你后续让 Codex 协助开发时，可以按任务叫这些 skills：

- `build-ios-apps:swiftui-ui-patterns`：设计主 App 的 SwiftUI 设置页、导航、状态管理。
- `build-ios-apps:swiftui-view-refactor`：当某个 SwiftUI 文件变得太大时，让它拆组件。
- `build-ios-apps:ios-debugger-agent`：需要在模拟器构建、运行、点按、截图、看日志时使用。
- `build-ios-apps:ios-ettrace-performance`：键盘卡顿、启动慢、候选刷新慢时做性能分析。
- `build-ios-apps:ios-memgraph-leaks`：键盘扩展内存上涨或疑似泄漏时使用。
- `build-ios-apps:ios-app-intents`：后期给主 App 增加快捷指令、系统搜索、控制中心入口时使用。
- `github:gh-fix-ci`：GitHub Actions 测试失败时排查。
- `github:yeet`：当你想让 Codex 帮你提交、推送、开 PR 时使用。

建议不要一次让 AI 写完整输入法。更好的方式是按阶段给任务，例如：

- “帮我搭一个 Custom Keyboard Extension 骨架。”
- “帮我把 KeyboardView 拆成 KeyButtonView 和 CandidateBarView。”
- “帮我给 KeyboardCore 写单元测试。”
- “帮我排查 librime 在 iOS Simulator 的链接错误。”

---

## 20. 第一版 MVP 范围

建议 MVP 不要贪。

### MVP 必须有

- 主 App 启用教程。
- 第三方键盘扩展。
- 26 键英文输入。
- 基础中文拼音输入。
- RIME 候选栏。
- 删除、空格、回车、Shift、地球键。
- 雾凇配置导入。
- 深浅色。
- 隐私说明。

### MVP 暂时不做

- 云同步。
- 账户系统。
- AI 联想。
- 整句滑动输入。
- 复杂主题商店。
- 剪贴板云同步。
- 语音输入。

这样 MVP 才可能稳定。

---

## 21. 可以马上开始的任务清单

第 1 天：

- 创建 Xcode iOS App 工程。
- 添加 Custom Keyboard Extension Target。
- 在主 App 显示“如何启用键盘”的静态页面。
- 在键盘扩展里显示一排测试按钮。

第 2 到 3 天：

- 做 26 键布局。
- 点击字母插入文本。
- 删除键可用。
- 地球键可用。

第 1 周：

- 抽出 `KeyboardCore`。
- 抽出 `TextInputClient`。
- 写 10 个单元测试。
- 加深浅色。

第 2 到 4 周：

- 准备 RIME 编译记录。
- 先在 macOS 命令行跑通 librime。
- 再尝试 iOS Simulator。

第 2 个月：

- RIME 接进键盘。
- 能输入拼音。
- 能展示候选。
- 能选择候选上屏。

---

## 22. 给新手的开发原则

1. 每次只做一个小功能。
2. 做完就跑模拟器。
3. 能写单元测试的逻辑，不要放在 View 里。
4. 不懂系统限制时，先查 Apple 文档。
5. 键盘扩展里不要做重活。
6. 隐私相关的事情宁可保守。
7. 先把默认体验做好，再做高级设置。
8. 不要为了“像原生”去使用私有 API。
9. 先离线可用，再考虑同步。
10. 每次升级 RIME 或雾凇，都跑回归测试。

---

## 23. 术语解释

- 主 App：用户从桌面点开的 App，负责设置和说明。
- Keyboard Extension：系统输入时显示的键盘扩展。
- RIME/librime：输入法核心引擎，负责把编码变成候选词。
- 雾凇拼音：一套 RIME 配置和词库。
- schema：RIME 输入方案，比如全拼、双拼。
- dict：RIME 词典。
- deploy：RIME 部署配置，把配置编译成运行时可用状态。
- composition：正在输入但还没上屏的编码。
- candidate：候选词。
- commit：最终上屏文本。
- App Group：主 App 和扩展共享文件的容器。
- Full Access：iOS 键盘的“允许完全访问”权限。
- XCFramework：Apple 平台分发二进制库的推荐格式。

---

## 24. 最推荐的下一步

先不要碰滑动输入，也不要急着编完整雾凇。下一步最稳的是：

1. 新建工程。
2. 跑通 Custom Keyboard Extension。
3. 做出 26 键英文输入。
4. 把按键逻辑抽成 `KeyboardCore`。
5. 写单元测试。

当你能稳定在任意普通输入框里输入、删除、切换键盘时，再接 RIME。这样每一步都能看到成果，也更适合新手持续推进。
