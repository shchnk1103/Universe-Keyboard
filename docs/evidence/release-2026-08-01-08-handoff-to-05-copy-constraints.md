# Handoff: RELEASE-2026-0801-08 → 05 — 颜表情第一方目录与对外文案约束

**Date / timezone:** `2026-08-24 Asia/Shanghai`  
**From:** [`RELEASE-2026-0801-08`](../assignments/release-2026-08-01-08-kaomoji-content.md) Executor（当前 Grok 任务）  
**To:** [`RELEASE-2026-0801-05`](../assignments/release-2026-08-01-05-app-store-materials.md) — App Store / TestFlight 文案、截图、内容版权、What to Test  
**Authority:** [`PD-RELEASE-2026-0801-08-KAOMOJI-CATALOG`](../product-decisions/RELEASE-2026-0801-08-kaomoji-catalog.md) · [`ADR 0030`](../architecture/decisions/0030-pending-kaomoji-palette.md)  
**Lifecycle of this card:** `Accepted` — Human Product Owner / Product Lead, `2026-08-24 Asia/Shanghai`. 05 写简介、截图说明、What to Test、审核备注时必须对照本卡。本卡仍 **不是** 已填进 App Store Connect 的句子，也不是 08 Product Gate。

本文件只约束 **怎么说**。它不关闭 08，不授权 merge，不改 App Store Connect，不代替 Human Product Gate。

---

## 1. Provenance（必须写对的那一句）

V1 颜表情目录是 **本仓库内的第一方字符串字面量**（`PendingKaomojiState` 表），随键盘二进制离线提供。

| 是 | 不是 |
|---|---|
| 产品自己维护的固定表 | Apple 颜文字数据文件或 Apple 许可转载 |
| 交互形状曾对照系统面板截图 | 该截图构成授权或「系统同款词库」 |
| 以后可用 **具名** 开源项目替换（需新的 Product Decision） | 当前绑定了某个第三方颜文字项目 |
| ASCII `^_^` 与全角 `＾_＾` / `＾＿＾` 是不同 token | 可按「看起来一样」合并对外宣传 |

无网络拉取、无用户云词库、无学习/排序、无账号、无持久化用户自建目录。

## 2. 隐私与内容版权（给 05 已有字段）

- **隐私：** 颜表情路径不采集、不上报、不把用户输入的表情存进可同步目录。不改变现有 `No data collected` 口径，也不新增隐私营养标签项。
- **内容版权：** 已保存的「Yes, the app contains or accesses third-party content…」是因为 **RIME / 下载方案 / 捆绑引擎组件**，**不是**因为这张颜表情表。不要把颜表情加进第三方内容清单，也不要因为颜表情去改成 No。
- **开源软件与内容页：** 不必为这张表新增许可证条目。它不是 librime、不是词库、不是第三方 notice。
- **年龄分级：** 表内是常见 ASCII / 全角表情和少量汉字脸；本卡不重新评定 4+。若 Product 日后加入不适宜条目，必须重开 05 年龄问卷，而不是改本卡。

## 3. 现在可以诚实描述的能力

Product 已认本卡。08 Human Product Gate 已于 `2026-08-24` Passed。TestFlight What to Test 与商店主文案可以使用下面这一层，并必须带上 §6 已知限制：

- 中文 **九键** 字母页右列和中文 **符号页** 都有 `^_^`（VoiceOver：「颜表情」）。
- 点一下会在输入框插入默认 `^_^`，候选栏出现可点选的本地颜表情；点选 **替换** 刚插入的那段，不是再拼一份。
- 再点 `^_^` 键会留下当前这段，再新开一个默认 `^_^`。 **没有** 标点那种 1 秒同键轮换。
- 可展开 / 下滑看更多。宽表情在 34 pt 紧凑栏里可能被截断；展开面板是溢出口。
- **26 键字母页没有** 这枚键。符号页上的 `^_^` 不是 26 键字母区新键。

## 4. 禁止出现的说法

在 08 Exit Criteria 关闭且 Product 接受本卡之前，以及关闭之后，下列句子仍禁止（PD Explicit non-authorization + 本卡）：

- 「系统颜文字」「Apple 同款」「官方颜文字盘」
- 「海量颜文字词库」「在线更新」「用户可上传/云同步」
- 「智能推荐 / 学习常用表情」（没有排序系统）
- 把占位时期的 `^_^` 键说成早就完成的功能
- 把颜表情写成系统同款或已做完整无障碍认证（Gate 过了仍须带 §6）

截图：可以拍九键或符号页点开后的候选栏，但说明必须是「本键盘的颜表情」，不要并排暗示与系统面板数据相同。

## 5. What to Test（供 05 在有 TestFlight build 后裁剪）

建议给外部测试者的最小句，仍须等 Gate / RC，且须附带已知限制：

1. 九键点 `^_^`：出现 `^_^`，候选栏可换脸。
2. 再点 `^_^`：应再开一个，而不是在几个脸之间轮换。
3. 点 `，。？！` 再点 `^_^`：标点应留下，两套不要互相删字。
4. 26 键字母页：确认没有凭空多出一枚颜表情键。

不要让测试者以为这是完整系统级颜文字浏览器。

## 6. 已知限制（必须跟着文案走）

| ID | 限制 | 对外含义 |
|---|---|---|
| A30-P2-05 | 抄录表可能有近形重复 | 不要宣称「精校无重复」 |
| A30-P2-06 / Q1-C-03 | VoiceOver 可能没有「已选中」 | 不要宣称完整无障碍认证 |
| A30-P2-04 / Q1-C-02 | 真机 host 手术未按 Quality 矩阵验证 | 不要写「任意 App 光标行为均已认证」 |
| Q1-C-01 | 未跑与 CI 等价全套 | 05 不得把 08 写成「已可合并/已上架」 |
| 08 Product Gate | Passed `2026-08-24` | 主文案可用 §3；仍须带本表其余限制 |

## 7. 05 收到后做什么 / 不做什么

**做：** 写简介、截图说明、What to Test、审核备注时对照 §1–§4；内容版权问卷 **保持** 现有第三方 RIME 口径。What to Test 现可用 §3 + §6。

**不做：** 不因本卡去改 ASC 类别、年龄、出口合规、内容版权 Yes/No；不把本卡当成法律意见；不在 08 Human Product Gate 前把颜表情写成商店卖点。

## 8. 本卡不证明

- Human Product Gate
- 08 Closed
- 可合并到默认分支
- App Store Connect 字段已更新
