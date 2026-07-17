# Universe Keyboard

iOS 第三方中文输入法，基于 RIME/librime 1.16.1 + librime-lua，目标是接近 iOS 原生的输入体验。

## 从这里开始

| 读者 | 先读 |
|---|---|
| 人类贡献者 | 本 README → [`docs/ONBOARDING.md`](docs/ONBOARDING.md) → [`docs/KNOWLEDGE_INDEX.md`](docs/KNOWLEDGE_INDEX.md) |
| AI / agent | [`AGENTS.md`](AGENTS.md) → [`docs/KNOWLEDGE_INDEX.md`](docs/KNOWLEDGE_INDEX.md) → [`docs/kos/zero-context-startup.md`](docs/kos/zero-context-startup.md) |
| 查当前架构 | [`docs/PROJECT_CONTEXT.md`](docs/PROJECT_CONTEXT.md) |
| 查文档规则 | [`docs/DOCUMENTATION_GOVERNANCE.md`](docs/DOCUMENTATION_GOVERNANCE.md) |
| 查任务路由 | [`docs/READING_MAPS.md`](docs/READING_MAPS.md) |

**README 只负责入口、最短构建路径和重要链接。**

功能清单、模块边界、RIME 生命周期与产品能力以 `docs/PROJECT_CONTEXT.md` 及领域文档为准；历史变更见 [`CHANGELOG.md`](CHANGELOG.md)。

## 仓库结构（概览）

```text
Universe Keyboard.xcodeproj
├── Universe Keyboard/     # 主 App（SwiftUI）
├── Keyboard/              # 键盘扩展（UIKit）
└── Packages/
    ├── KeyboardCore/      # 纯逻辑 SPM
    └── RimeBridge/        # 唯一生产 RIME 桥接包（Vendor 制品见 docs/architecture/rime-artifacts.md）
```

完整边界与数据流见 [`docs/PROJECT_CONTEXT.md`](docs/PROJECT_CONTEXT.md)。

## 构建与验证

```bash
# 校验固定版本 RIME 二进制制品
bash scripts/ensure_rime_vendor.sh verify

# KeyboardCore 单元测试
swift test --package-path Packages/KeyboardCore

# 选择本机已安装的 Simulator 后，可运行：
# xcrun simctl list devices available

xcodebuild -project "Universe Keyboard.xcodeproj" \
  -scheme "Universe Keyboard" \
  -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO SWIFT_STRICT_CONCURRENCY=complete \
  SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES build
```

更多测试/Release 命令与门禁见 [`docs/RELEASE_CHECKLIST.md`](docs/RELEASE_CHECKLIST.md)。
Vendor 获取与版本固定见 [`docs/architecture/rime-artifacts.md`](docs/architecture/rime-artifacts.md) 与 `scripts/ensure_rime_vendor.sh fetch`。

> `Packages/RimeBridge/Vendor/` 中的 xcframework 默认不入库；CI 与新环境通过带 SHA-256 校验的固定 Release 制品获取。

## Knowledge OS

仓库知识按 Knowledge OS 2.0 单轨运行：

- 冻结治理：[`docs/kos/`](docs/kos/)
- 运营入口：[`docs/KNOWLEDGE_OS.md`](docs/KNOWLEDGE_OS.md)
- 导航索引：[`docs/KNOWLEDGE_INDEX.md`](docs/KNOWLEDGE_INDEX.md)

## 许可证

本项目代码采用 MIT License。RIME/librime 为 BSD-3-Clause。OpenCC 为 Apache-2.0。
雾凇拼音 (rime-ice) 为 GPL-3.0，用户在使用前需阅读并同意许可证。
