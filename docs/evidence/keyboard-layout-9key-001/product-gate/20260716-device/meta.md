# Product Gate evidence — KEYBOARD-LAYOUT-9KEY-001

Operator: Human Product Owner（自测，非专业测试记录）
Assisted summary: Grok（对照截图整理）

## Environment

| Field | Value |
|---|---|
| Date / TZ | 2026-07-16 Asia/Shanghai（设置约 21:40；输入约 21:59） |
| Device | iPhone 13 Pro |
| iOS | iOS 27 beta 3 |
| Build / commit | `5a1c407`（`fix(9key): close Codex implementation re-review findings`） |
| Full Access | **On** |
| Keyboard | **Universe Keyboard** 已启用 |
| Host apps | 信息 / iMessage；备忘录（Notes） |
| Operator | Human Product Owner |

## Overall result

| Field | Value |
|---|---|
| **Product Gate (evidence package)** | **PASS** |
| Failures | 无 |
| Notes | 设置 UI、九键盘面、T9 候选/上屏汉字、回车不泄 raw 数字、英文 26 键、收起再开均有截图。删除单测（T4）无单独图，由 T2 组合态 + 操作者自述覆盖；非阻塞。 |

---

## Screenshot index

### §1 安装与权限

| 文件 | 内容 |
|---|---|
| `键盘列表.PNG` | 系统键盘列表含 Universe Keyboard |
| `Full Access 开.PNG` | 允许完全访问 = On |
| `主 App 首页.PNG` | 主 App 可启动 |
| `主 App设置页.PNG` | 设置 →「键盘布局」入口（启用前副标题曾为 26键） |

### §2 布局设置 UI

| 文件 | 清单 | 内容 |
|---|---|---|
| `A1 A5.PNG` | A1 + A5 | 深色：26/9 卡片、无字缩略图、9 键勾选、「九键已启用」 |
| `A3.PNG` | A3 | 设置入口副标题 **9键** |
| `A4.PNG` | A4 | 浅色布局页，9 键勾选 |
| `A6.PNG` | A6 | 横屏布局页 |

### §5–6 扩展输入与生命周期

| 文件 | 清单 | 审阅结论 |
|---|---|---|
| `9键键盘.jpeg` | T1 | 信息 App：九键 1–9 + 字母标注 |
| `T2-64-candidates.PNG` | T2 | 预编辑 **ni**（非 raw `64`）；候选 **你/呢/密/米/迷/秘**；九键盘仍在 |
| `T3-commit-hanzi.PNG` | T3 | 上屏 **你**（汉字，非数字串） |
| `T7-return-no-raw.PNG` | T7 | 文本为 **你好**；无 raw `64`/`64426`；组合结束后仍九键 + 联想条 |
| `T9-english-qwerty.PNG` | T9 | 英文模式 **QWERTY**（`英` / English），非九键英文 |
| `L1-reopen.PNG` | L1 | 再打开后仍为九键；文本 **你好** 保留 |

---

## Checklist coverage

### Strong (screenshot-backed)

- [x] 扩展安装 + Full Access
- [x] 布局页 26/9 + 无字缩略图 + 浅/深色 + 启用状态
- [x] 设置入口副标题随选择更新
- [x] 中文九键盘面
- [x] `64` 路径：可读预编辑 + 非空候选
- [x] 选词上屏汉字
- [x] 有输入路径后回车/提交结果不含 raw 数字串
- [x] 布局=9 键时英文为 26 键 QWERTY
- [x] 收起/再开仍九键

### Acceptable gap (non-blocking)

- [ ] T4 删除减一位：无单独截图（操作者此前自述整体符合期望）
- [ ] 多宿主、卸载雾凇失败路径：未强制要求于本包

### Not required for this gate

- 候选排序固定
- 失败路径全矩阵（除非 Product Lead 要求）

---

## Reviewer assessment

| Area | Status |
|---|---|
| 主 App 布局设置 | **PASS** |
| 扩展九键 chrome | **PASS** |
| T9 输入语义（候选 / 上屏汉字 / 不泄 raw 数字） | **PASS** |
| 中/英布局契约 | **PASS** |
| hide → show 恢复 | **PASS** |
| **Product Gate evidence package** | **PASS** |

Code-review gate remains as previously approved (`codex-implementation-rereview-3.md`).
This package supplies the human interactive / device evidence previously listed as open.

## Product Lead acceptance

| Field | Value |
|---|---|
| Role | Product Lead (KOS 2.0; not Human Product Owner) |
| Decision | `PG-KEYBOARD-LAYOUT-9KEY-001` — **PASS** |
| Record | `docs/evidence/keyboard-layout-9key-001-product-gate-decision.md` |
| Date | 2026-07-16 Asia/Shanghai |
| Assignment | KEYBOARD-LAYOUT-9KEY-001 → **`Closed`** |

Human Product Owner provided device capture as **Human Dependency** only. Product Gate verdict is issued by Product Lead.
