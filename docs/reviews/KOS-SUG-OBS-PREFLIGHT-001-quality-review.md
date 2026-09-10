# KOS-SUG-OBS-PREFLIGHT-001 — Quality Review

## Current Status

| Field | Value |
|---|---|
| Verdict | **Pass with conditions** |
| Reviewer | Independent Quality runtime · logical lane `KOS-SUG-OBS-PREFLIGHT-001/document-quality` |
| Reviewed SHA | `c34b6dacba74cd3aa939d8e323daa0e8a9f7bd49` |
| Tree | `bf9d5c2401a059b9a656decf4f9815e377eae2a1` |
| Baseline | `56bad7f71009c104c783477876d577c2fa95861e` |
| Branch / worktree | `codex/kos-sug-obs-preflight-001` · `/private/tmp/universe-keyboard-kos-sug-obs-preflight` |
| Scope | Docs-only SUG-07 opt-in observability-preflight table and governance cross-reference |
| Non-claims | Not Architecture review; not D-01 publication receipt; not hosted CI; not Product Gate; not merge / Release; not a device run; does not create Quality-reverified device evidence |

| 严重级别 | 数量 |
|---|---:|
| P0 | 0 |
| P1 | 1 |
| P2 | 0 |
| P3 | 0 |

---

## 审查基线与范围

- **范围内：** [`docs/kos/universe-keyboard-human-operated-evidence-profile.md`](../kos/universe-keyboard-human-operated-evidence-profile.md) 新增 Observability preflight 段；[`docs/DOCUMENTATION_GOVERNANCE.md`](../DOCUMENTATION_GOVERNANCE.md) SUG-07 交叉引用；Assignment / Authorization / Product Decision；[`docs/ACTIVE_WORK.md`](../ACTIVE_WORK.md) 第 9 行与 Dashboard 镜像；disposition ledger 对 SUG-07 的模板指针。对照 SUG-07 原文、E-01 claim outcome、M-04 grade。
- **排除：** SUG-04/08 实施、SUG-06 CI、隐私/诊断 UI/生产日志、Swift、真机、原始目录读取、push/PR/merge/Release、把本审查写成 D-01 或 hosted CI。
- **对照规范：** Assignment [`kos-sug-obs-preflight-001.md`](../assignments/kos-sug-obs-preflight-001.md)、[`AUTH-KOS-SUG-OBS-PREFLIGHT-001.md`](../authorizations/AUTH-KOS-SUG-OBS-PREFLIGHT-001.md)、[`KOS-SUG-OBS-PREFLIGHT-001-authorization.md`](../product-decisions/KOS-SUG-OBS-PREFLIGHT-001-authorization.md)、[`DOCUMENTATION_GOVERNANCE.md`](../DOCUMENTATION_GOVERNANCE.md) E-01 / SUG-07、[`universe-keyboard-human-operated-evidence-profile.md`](../kos/universe-keyboard-human-operated-evidence-profile.md)、M-02/M-04/M-05。

## 通过项

1. **范围与权威链收窄且一致。** Assignment Lifecycle=`Active`；A-01/B-01 Adopted，E-01/P-01/D-01 均为 Not applicable。Frontier 当前片为 `In progress`，push/PR/merge/Release、真机、SUG-08/04/06 自动化为 `Not authorized`，环境片 `Not applicable`。Authorization `kos-record` 可解析，`action=implement_kos_sug_07_observability_preflight_template`，exclusions 含 `device_run`、`raw_log_or_directory_read`、`push`/`pr`/`merge`/`release`。Product Decision 为 Accepted docs-only，明确无 device run。
2. **Opt-in / 不回填可执行。** Profile 要求新的 human-device Assignment 点名该节或 frozen manifest 才采纳；省略表格即未采纳；历史与当前 Active 真机 Assignment 不回填。Governance 同步该边界。现有 Active 产品/真机行未被改写为已采纳 SUG-07。
3. **表头六列存在，functional / trace 拆分与 event-code 规则清楚。** 列为 Claim、Kind、Required content-free fields、Visible location、Readable now?、Preflight outcome。Kind 限 `functional` 或 `trace`，并给出卸载后 Luna 候选 vs phase/UUID/elapsed 的拆分示例。诊断列表出现 event code 不能证明 UUID/phase/elapsed。内容字段禁止输入、候选、宿主文本、用户词典。不可读时不得要求打开原始目录；`inconclusive` 不能授权 SUG-08。
4. **ACTIVE_WORK 镜像存在（M-02 step 6 / M-05）。** 第 9 行为 `KOS-SUG-OBS-PREFLIGHT-001` / `Active` / 无真机、无 push/PR/merge，计数 9/10。Dashboard 有对应条目。Assignment 仍是生命周期 SoT。
5. **本片未把本地检查写成 hosted CI、D-01 或真机证据。** Assignment 将 D-01 标为 Not applicable；Exit 中「最后一次文档编辑后的 scoped docs-only validation」仍未勾选。仓库内无 evidence 文件宣称 Quality-reverified device 结果。Diff 为 8 个 Markdown 文件，无 Swift / workflow / `scripts/ci` 变更。

## Findings

### P1-Q-001 — `pass` / `inconclusive` / `not-run` 可被读成真机或 E-01 观察结果

Profile 模板把 **Preflight outcome** 的允许值写成与 E-01 claim Outcome 相同的 `pass` / `inconclusive` / `not-run`（[`universe-keyboard-human-operated-evidence-profile.md`](../kos/universe-keyboard-human-operated-evidence-profile.md) 表行；[`DOCUMENTATION_GOVERNANCE.md`](../DOCUMENTATION_GOVERNANCE.md) E-01 Outcome 词表为 `pass` / `fail` / `inconclusive` / `not-run`）。规则只定义了「必填字段从隐私安全 UI/导出不可读 → 该 claim 的 preflight outcome 为 `inconclusive`」，没有定义：

- `pass` 只表示「必填无内容字段现在可读」，**不是** 功能/trace claim 已在设备上成立；
- `not-run` 只表示「这条已 opt-in 的 claim 尚未做可读性检查」，**不是** E-01 的「有意未执行设备观察」；
- `Readable now?`（`yes` / `no` / `unknown`）如何映射到 outcome；`unknown` 是否 fail-closed。

Governance 交叉引用把不可读写成「marks that claim `inconclusive`」，Assignment Objective 同样写「mark that claim `inconclusive`」，都省略了 “preflight outcome”，更容易被抄进 E-01 Outcome、M-04 `Device-attested` / `Quality-reverified` 或 Product Gate。

**Failure scenario：** 未来 opted-in 真机 Assignment 在 frozen manifest 里对「卸载后 Luna 出中文候选」填 Preflight outcome=`pass`（字段可见）。后续读者把该 `pass` 当作 Device-attested / E-01 pass，或把 `not-run` 当成「设备观察未跑故可忽略」，在没有任何 operator 动作、也没有 Quality 复跑真机证据的情况下推进 Gate。这正是 SUG-07 要防止的「event code / 表格用词 ≠ 已证明字段或行为」误读。SUG-04 的重审触发（「SUG-07 preflight proves fields are readable」）也会被一次 preflight `pass` 误触发。

**Condition：** 在 Profile 规则（Governance 指针同步）中写明：

1. Preflight 三值只描述 **操作前可读性**，禁止复制为 E-01 Outcome、M-04 grade、Device-attested 结果、Quality-reverified 真机证据、Product Gate 或 Release 结论。
2. 映射：`Readable now=yes` → preflight `pass`（字段可读，不是设备结果）；`no` 或 `unknown` → `inconclusive`（fail-closed）；`not-run` 仅用于尚未执行该行 preflight，且 **不满足** Readiness「表已完整」——不得对 opted-in 行填 `not-run` 后发出第一条 operator 指令。
3. Governance / Assignment 叙述改为 “that claim’s **preflight outcome** is `inconclusive`”，不要写 “marks that claim `inconclusive`”。

可选更强修复：把列名/词表改成不与 E-01 碰撞的 `readable` / `unreadable` / `not-checked`。

未满足本条件前，该约定 **不得** 被新的 human-device Assignment 当作可执行模板，也不得 Close 本 Assignment。

## Quality-reverified local checks（this SHA only）

Environment: local Quality reviewer workstation; committed tip `c34b6da` / tree `bf9d5c24…`. 本审查落盘会使工作树相对该 SHA 多出本文件；那是审查记录，不覆盖后续文档树。

```text
python3 scripts/ci/check_markdown_links.py --base 56bad7f71009c104c783477876d577c2fa95861e --head HEAD
# PASS changed Markdown links (8 files)

python3 -m unittest discover -s scripts/ci/tests -p 'test_*.py'
# Ran 12 tests in 0.529s  OK

git diff --check 56bad7f71009c104c783477876d577c2fa95861e...HEAD
# clean
```

Authorization `kos-record` JSON 解析通过。Grade for these commands on `c34b6da`：**Quality-reverified** 本地 docs-only 检查。 **不是** D-01 publication receipt、hosted CI、merge/Release，也 **不是** Quality-reverified 真机证据。

## Residual 与验证边界

- 独立 Architecture review 仍是 Assignment Exit 缺口；本文件只提供 Quality 输入。
- Assignment Exit「scoped docs-only validation after the last documentation edit」在 `c34b6da` 上仍未勾选；本会话重跑覆盖该 SHA，不能替 Executor 勾选，也不能在本审查文件写入后再自称最终树已检。
- 默认 Readiness Review 八条清单适用于所有真机 run（含未采纳 SUG-07 者）；opt-in 的表格完整性检查写在新节末句。这与「不回填」一致。Opted-in Assignment 应在自己的 readiness 页点名该表，否则执行者可能只读八条清单。不单列 finding。
- CHANGELOG 未改：本片未发布、无产品行为变化；待 Human publication 时再决定。不单列 finding。
- 本结论不启用 `required`，不回填历史真机 Assignment，不授权 SUG-04/08、设备、原始读取、push/PR/merge/Release。

## Non-claims

本 Quality review **不是**：Architecture 通过、D-01 final-documentation receipt、hosted CI 绿灯、Product Gate、merge 许可、Release 许可、SUG-07 真机 run，或对任何设备观察的 Quality-reverified / Device-attested 升级。

---

## Addendum — tip `2d5263d`（P1-Q-001 repair）

### Current Status（本 tip）

| Field | Value |
|---|---|
| Verdict | **Pass** |
| Reviewed SHA | `2d5263deaef0fbe6547ae0cf869042d1da647752` |
| Tree | `f18ff993e5148746b96041fdd3c76fc441200a5a` |
| Baseline | `56bad7f71009c104c783477876d577c2fa95861e` |
| Scope | Vocabulary repair delta plus full scoped docs range vs baseline |
| Non-claims | Not D-01 publication receipt; not hosted CI; not Product Gate; not merge / Release; not device evidence |

| 严重级别 | 数量 |
|---|---:|
| P0 | 0 |
| P1 | 0 |
| P2 | 0 |
| P3 | 0 |

### Prior-finding disposition

| ID | Disposition | Evidence on this tip |
|---|---|---|
| P1-Q-001 | **Resolved** | Profile 列名改为 **Preflight readability**，词表为 `readable` / `unreadable` / `not-checked`，不再使用 E-01 的 `pass` / `inconclusive` / `not-run`。映射已写明：`Readable now=yes` → `readable`；`no` 或 `unknown` → `unreadable`（fail-closed）；`not-checked` = 该 opted-in 行尚未检查，任一 adopted 行为 `not-checked` 时不得发出第一条 operator 指令。非复制规则覆盖 E-01 Outcome、M-04 grade、Device-attested、Quality-reverified 真机证据、Product Gate、Release 与 SUG-04 重审触发。Governance 写明这些值不是 E-01 outcomes，不可读字段设置的是 **preflight readability** `unreadable`。Assignment Objective 与 Exit 已同步为 `unreadable` / 非 E-01。 |

### Quality-reverified local checks（this SHA only）

Environment: local Quality reviewer workstation; committed tip `2d5263d` / tree `f18ff99…`. 本 addendum 落盘会使工作树相对该 SHA 多出本文件未提交编辑。

```text
python3 scripts/ci/check_markdown_links.py --base 56bad7f71009c104c783477876d577c2fa95861e --head HEAD
# PASS changed Markdown links (10 files)

python3 -m unittest discover -s scripts/ci/tests -p 'test_*.py'
# Ran 12 tests in 0.495s  OK

git diff --check 56bad7f71009c104c783477876d577c2fa95861e...HEAD
# clean
```

Grade for these commands on `2d5263d`：**Quality-reverified** 本地 docs-only 检查。 **不是** D-01 publication receipt、hosted CI、merge/Release，也 **不是** Quality-reverified 真机证据。

### New findings

None.

### Residual（non-blocking）

- Assignment Non-goals 仍有一句 “Treat an inconclusive preflight as SUG-08 authorization”；Product Decision 仍有 “An inconclusive preflight does not authorize SUG-08”。禁止 SUG-08 的方向正确，但用词落后于 Profile SoT。不重开 P1；Close 前可改成 `unreadable`。
- Assignment Exit 的 Architecture / final Quality 勾选仍待双方在最终文档 SHA 上收口。本 addendum 关闭首轮 Quality condition，不代替 Architecture 对 `2d5263d` 的独立结论，也不 Close Assignment。
- 本 addendum 写入后 HEAD 将再移动；D-01 仍为 Not applicable，不得把本次检查称为最终文档 receipt。

### Non-claims（addendum）

本 tip 结论 **不是** Architecture 通过、D-01 publication receipt、hosted CI、Product Gate、merge 或 Release。
