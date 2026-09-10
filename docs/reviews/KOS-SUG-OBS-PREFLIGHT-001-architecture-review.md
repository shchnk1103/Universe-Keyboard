# Architecture Review: KOS-SUG-OBS-PREFLIGHT-001

## 审查身份与边界

| Field | Value |
|---|---|
| Reviewer | independent Architecture reviewer runtime；logical lane `KOS-SUG-OBS-PREFLIGHT-001/document-architecture` |
| Date / timezone | `2026-09-10 Asia/Shanghai` |
| Worktree / branch | `/private/tmp/universe-keyboard-kos-sug-obs-preflight` / `codex/kos-sug-obs-preflight-001` |
| Reviewed SHA | `c34b6dacba74cd3aa939d8e323daa0e8a9f7bd49`（`HEAD^{tree}=bf9d5c2401a059b9a656decf4f9815e377eae2a1`） |
| Baseline | `56bad7f71009c104c783477876d577c2fa95861e` (`origin/main`) |
| Review mode | 只读审查；仅允许写入本文件 |

独立性：本 runtime 未撰写或修改 Assignment、Authorization、Product Decision、
profile、治理交叉引用、台账或状态镜像；只检查最终已提交树并写入本独立审查。
本文件不替代 Quality 结论，不关闭 Assignment，不授权 push / PR / merge / 真机
或 SUG-08。

审查范围限于 `56bad7f7...c34b6da` 的 docs-only SUG-07 模板切片：

- [`universe-keyboard-human-operated-evidence-profile.md`](../kos/universe-keyboard-human-operated-evidence-profile.md) 新增 opt-in preflight 节；
- [`DOCUMENTATION_GOVERNANCE.md`](../DOCUMENTATION_GOVERNANCE.md) 治理交叉引用；
- 本切片的 Assignment、Authorization、Product Decision；
- `ACTIVE_WORK` / Dashboard 镜像与台账指针。

明确不审查、不授权：SUG-04/08 实施、SUG-06 CI、隐私政策、诊断 UI、生产日志、
Swift、Kit `required`、历史/Active 真机 Assignment 回填、push、PR、merge、
TestFlight 或 Release。

## 冻结输入

审查绑定下列工作树内容。任一输入、reviewer 绑定、采纳范围或项目边界变化，
本结论失效，需对新 SHA 重审。本审查文件本身不在下列 hash 内。

| Input | SHA-256 |
|---|---|
| [`KOS-SUG-OBS-PREFLIGHT-001` Assignment](../assignments/kos-sug-obs-preflight-001.md) | `86596f7a86c7367393c9e31b5afe2ae9440e95d8a6efc3f9d3417871aa4c6e79` |
| [`AUTH-KOS-SUG-OBS-PREFLIGHT-001`](../authorizations/AUTH-KOS-SUG-OBS-PREFLIGHT-001.md) | `10e63043e3d872bb6b66874fc6e0b079dbeff13c6eb205068a3461403f08873a` |
| [`KOS-SUG-OBS-PREFLIGHT-001` Product Decision](../product-decisions/KOS-SUG-OBS-PREFLIGHT-001-authorization.md) | `5957c6328cae89451ea7bfa971d6c8297bba0810484bfed186d7511ce782eeed` |
| [`universe-keyboard-human-operated-evidence-profile.md`](../kos/universe-keyboard-human-operated-evidence-profile.md) | `8b07ee4ec3e730ad7b45880a3f30e0644a323c5dde24f1a3a3d98fb0eedcc169` |
| [`DOCUMENTATION_GOVERNANCE.md`](../DOCUMENTATION_GOVERNANCE.md) | `6271b92a1a00a68e3bd80e575a2a0fccb9ec55788a9d97f7437160a2336cca72` |
| [`ACTIVE_WORK.md`](../ACTIVE_WORK.md) | `55452fd51fad36865f50a5ec546da4278f0446b1d0ca87ff506992573f296c90` |
| [`ENGINEERING_DASHBOARD.md`](../ENGINEERING_DASHBOARD.md) | `2d4cfeb4a5d8451227b5025c114be4b449d5cef87e2fc6f5190f192e96b141f2` |
| [`disposition ledger`](../kos/kos-improvement-suggestions-scheme-delivery-2026-09-09-disposition-ledger.md) | `382a1f16490ad97804495dbd92a05162da674dfa536aefcc5ddff8385f155f27` |
| [`nine-item disposition PD`](../product-decisions/KOS-IMPROVEMENT-SUGGESTIONS-001-disposition.md) | `47273da851ee5ddb631500060fe2ea8fc0d1b6491dee46b7dbf2205f830ea5ce` |
| [`SUG source proposal`](../kos/kos-improvement-suggestions-scheme-delivery-2026-09-09.md) | `254624c54e6040d42163807f57e9392abb89ed8d520873c41d797df418167d11` |
| [`ASSIGNMENT_POLICY.md`](../ASSIGNMENT_POLICY.md) | `59fc94f12b61ee303c4dda644c41eeae3b3fc3c63d9ea5b033e766ccc3b9fc5d` |
| [`UPGRADE_STATUS.md`](../kos/UPGRADE_STATUS.md) | `29f438145319127811d259dd692f24cbaf0c7b41666df799e8a1972cb71ef83a` |
| [`.kos/project.json`](../../.kos/project.json) | `890e590eb4963a9f028581135eab3b3f01484f05bb8bd614a3c944318ff3615f` |

`git diff --check 56bad7f7...c34b6da` 通过。范围内相对链接可解析。无 Swift /
隐私政策 / 诊断 UI / 生产日志文件变更。审查时工作树相对 `HEAD` 干净。

## 五项 Architecture 核对

### 1. Opt-in only；无回填；不是 Kit v0.8 合同

成立。

- Profile 新节标题为 `(KOS-SUG-07, opt-in)`，并写明本约定 **不是** KOS Agent
  Kit v0.8.0 合同；**新** human-device Assignment 仅在 Assignment 或其冻结
  run manifest **点名该节** 时才采纳；历史与当前 Active 真机 Assignment 不回填；
  省略该表即未采纳 SUG-07
  （[`profile:97-102`](../kos/universe-keyboard-human-operated-evidence-profile.md#L97)）。
- Governance 交叉引用使用 `may opt into`，并重复“项目 profile 约定、不是 Kit
  v0.8.0 合同、不回填”
  （[`DOCUMENTATION_GOVERNANCE.md:176-184`](../DOCUMENTATION_GOVERNANCE.md#L176)）。
- Product Decision：SUG-07 对未显式采纳该表的 Assignment 保持 inactive
  （[`PD:21-25`](../product-decisions/KOS-SUG-OBS-PREFLIGHT-001-authorization.md#L21)）。
- Assignment Non-goals 禁止全局强制与历史/Active 回填
  （[`Assignment:61-67`](../assignments/kos-sug-obs-preflight-001.md#L61)）。
- 本 Assignment 仅 Adopted A-01/B-01；E-01 / P-01 / D-01 为 `Not applicable`
  （[`Assignment:24-31`](../assignments/kos-sug-obs-preflight-001.md#L24)）。
  这是本记录的授权链 opt-in，不是把 SUG-07 升格为 Kit 合同。
- `.kos/project.json` 与 `UPGRADE_STATUS.md` 未把 SUG-07 登记为 Kit 合同；
  adopted pin 仍为 `v0.8.0` advisory，四项合同仅新记录显式 opt-in。

失败情景（未发生）：若 profile 把该表写成所有 human-device run 的默认门、或把
SUG-07 写入 `.kos/project.json` / Kit 合同表，则本切片会越权。当前文本没有这样做。

### 2. Functional 与 trace 分离；event code 不能证明 UUID / phase / elapsed

成立。

Profile 要求每个 claim 一行，`Kind` 只能是 `functional` 或 `trace`；示例将
“卸载后 Luna 对探测音节给出中文候选”标为 `functional`，将“同一操作记录
phase、operation UUID、elapsed”标为 `trace`；并写明诊断列表中出现 event code
不能证明 UUID、phase 或 elapsed
（[`profile:111-118`](../kos/universe-keyboard-human-operated-evidence-profile.md#L111)）。
这与源建议稿 SUG-07 最小合同一致
（[`source:102-112`](../kos/kos-improvement-suggestions-scheme-delivery-2026-09-09.md#L102)）。
Assignment Exit Criteria 也勾选了同一边界
（[`Assignment:96-100`](../assignments/kos-sug-obs-preflight-001.md#L96)）。

失败情景（未发生）：若允许用 `runtime_route.phase_changed` 一类 event code 推导
trace 字段齐全，则会把不可读字段写成已证明。当前规则显式禁止。

### 3. 不可读字段 → `inconclusive`；不授权 SUG-08、真机 run 或原始目录

成立。

- 必填字段无法从隐私安全 UI 或导出读取时，该 claim 的 preflight outcome 为
  `inconclusive`；不得要求操作者打开原始目录
  （[`profile:119-124`](../kos/universe-keyboard-human-operated-evidence-profile.md#L119)）。
- `inconclusive` 不授权 SUG-08 原始数据读取；SUG-08 仍需自己的 Assignment 与
  Human authorization。
- 该表不能授权真机 run、日志改动或采集用户内容。
- Governance 同步：不可读 → `inconclusive`，且不授权 raw-directory、device run
  或 SUG-08（[`DOCUMENTATION_GOVERNANCE.md:181-184`](../DOCUMENTATION_GOVERNANCE.md#L181)）。
- PD 与 AUTH exclusions 覆盖 `implement_sug_08`、`device_run`、
  `raw_log_or_directory_read`。

`Readable now?` 的 `unknown` 落在“当前不可从 UI/导出确认可读”，按同一规则应
标 `inconclusive` 而非 `pass`。这是 fail-closed 解读，不是缺口；本审查不把它
升为 finding。

失败情景（未发生）：若 `inconclusive` 被写成可打开 App Group 目录或自动升格
SUG-08，则越权。当前文本把 SUG-08 停在独立授权。

### 4. 权威链 Assignment → AUTH → PD；frontier 不创造权威

成立。

| 角色 | 当前权威 | 核对 |
|---|---|---|
| 生命周期 / Scope / Stop | Assignment | docs-only SUG-07 模板；Human Dependency `Not Applicable`（本切片无设备/原始数据） |
| 本切片 action | AUTH `implement_kos_sug_07_observability_preflight_template` | 绑定 profile + `DOCUMENTATION_GOVERNANCE.md`；exclusions 覆盖 SUG-04/08、设备、原始日志、隐私/诊断/生产日志、`required`、回填、CI、产品代码、push/PR/merge/Release |
| 产品决定 | PD Accepted — bounded documentation-only | 新 human-device Assignment opt-in only；publication 另案 |
| 处置方向 | 九项 disposition PD + 台账 | SUG-07 Adopted 方向仍要求隐私与 Human Dependency；本切片只实现 docs-only 模板，并在台账行标注 `no device run` |
| 状态镜像 | `ACTIVE_WORK` 第 9 行、Dashboard | 只链接 Assignment/PD/AUTH；不授权 |

A-01/B-01 frontier
（[`Assignment:33-41`](../assignments/kos-sug-obs-preflight-001.md#L33)）
当前文档切片为 `In progress`，权威来源为
`This Assignment → Authorization → Accepted Product Decision`；
push/PR/merge/Release、SUG-07 真机、SUG-08/04/06 自动化均为 `Not authorized`。
受控词表符合 [`ASSIGNMENT_POLICY.md:255-263`](../ASSIGNMENT_POLICY.md#L255)：
frontier 记录权威、不创造权威；无 `UNKNOWN`。Dashboard / Active Work / 台账指针
不能把本切片升格为真机或 SUG-08 授权。

失败情景（未发生）：若 frontier 把未匹配的 AUTH 标为 `Authorized`，或用
Dashboard 代替 PD，则违反 A-01。当前链 action/target/scope 匹配。

### 5. 范围 docs-only；无隐私政策、诊断 UI、生产日志或 Swift 变更

成立。

相对 baseline 的变更文件仅 8 个 Markdown：

- `docs/kos/universe-keyboard-human-operated-evidence-profile.md`
- `docs/DOCUMENTATION_GOVERNANCE.md`
- `docs/assignments/kos-sug-obs-preflight-001.md`
- `docs/authorizations/AUTH-KOS-SUG-OBS-PREFLIGHT-001.md`
- `docs/product-decisions/KOS-SUG-OBS-PREFLIGHT-001-authorization.md`
- `docs/ACTIVE_WORK.md`
- `docs/ENGINEERING_DASHBOARD.md`
- `docs/kos/kos-improvement-suggestions-scheme-delivery-2026-09-09-disposition-ledger.md`

AUTH 绑定前两个产品产物；其余为 Assignment 记录、状态镜像与台账
“Template implementation”指针（处置仍为 Adopted，未改 SUG-04 Deferred 触发器）。
无 `.swift`、无 `PRIVACY_POLICY`、无诊断 UI、无生产日志、无 workflow/script。
台账既有边界“不得以 docs-only 结论代替隐私/Human Dependency”
（[`ledger:30`](../kos/kos-improvement-suggestions-scheme-delivery-2026-09-09-disposition-ledger.md#L30)）
仍有效：本模板不代替未来 opted-in 真机 Assignment 的隐私审查与 Human Dependency。

## Source of Truth

| 事实 | 权威来源 | 其他文件角色 |
|---|---|---|
| SUG-07 preflight 表与规则 | human-operated evidence profile 新节 | Governance 只交叉引用，不复制完整表 |
| 本切片是否可实施 | Assignment + AUTH + 本切片 PD | Dashboard / Active Work 为镜像 |
| 九项方向性处置 | `KOS-IMPROVEMENT-SUGGESTIONS-001-disposition.md` | 台账当前表可链到本模板；源建议稿为历史 |
| Kit 版本与可选合同 | `UPGRADE_STATUS.md` / `.kos/project.json` | 本切片未改 |

Readiness Review 对 **已 opt-in** 的 run 增加“表完整后再发第一条人工指令”
（[`profile:125-127`](../kos/universe-keyboard-human-operated-evidence-profile.md#L125)），
没有把该表并入所有真机 run 的默认 Readiness Review。

Preflight 列 `pass` / `inconclusive` / `not-run` 描述的是**字段是否可读**，不是
E-01 产品/证据 claim 已成立。本 Assignment 将 E-01 标为 Not applicable，与该
区分一致。

## Findings

没有发现 P0、P1、P2 或 P3 finding。

| Severity | Count |
|---|---:|
| P0 | 0 |
| P1 | 0 |
| P2 | 0 |
| P3 | 0 |

无阻塞 finding，因此无失败情景待修。

## Verdict

**Architecture verdict: Pass.**

Counts: **P0/P1/P2/P3 = 0/0/0/0**.

SUG-07 以项目 profile 约定落地：仅新 human-device Assignment 显式 opt-in、不回填、
不是 Kit v0.8 合同；functional/trace 分行且 event code 不能证明 UUID/phase/elapsed；
不可读 → `inconclusive` 且不授权 SUG-08 / 真机 / 原始目录；权威链为
Assignment → AUTH → PD，frontier 不创造权威；diff 为 docs-only。

## Non-claims

本审查不：

- 关闭 Assignment，或把 Exit Criteria 中未勾选的独立 Quality / 最终 docs-only
  validation 标为已完成；
- 授权任何 human-device run、SUG-04/08、SUG-06 CI、隐私/诊断/日志/Swift 改动；
- 使 SUG-07 对未点名该表的 Assignment 生效，或回填
  `SCHEME-DELIVERY-RUNTIME-ROUTE-DEVICE-001` 等 Active 真机工作；
- 把 preflight `pass` 写成功能或 trace claim 已证明；
- 授权 commit 以外的 push、PR、merge、TestFlight 或 Release；
- 替代独立 Quality review。

## Validation and handoff

已执行：相对 `origin/main` 的范围 diff 与 `git diff --check`、输入 SHA-256、
权威链/SoT/五项边界静态核对、范围内相对链接存在性。未执行 Xcode、Swift 测试、
设备、原始目录读取、CI、网络发布或 Quality 复跑。

下一步仍属 Assignment 所有权：独立 Quality review（logical lane
`KOS-SUG-OBS-PREFLIGHT-001/document-quality`）以及最后一次文档编辑后的
scoped docs-only validation；publication 需新的 Human 授权。

---

## Vocabulary-delta addendum（`c34b6da` → `2d5263d`）

| Field | Value |
|---|---|
| Addendum reviewer | same independent Architecture runtime；logical lane `KOS-SUG-OBS-PREFLIGHT-001/document-architecture` |
| Addendum date / timezone | `2026-09-10 Asia/Shanghai` |
| Reviewed SHA | `2d5263deaef0fbe6547ae0cf869042d1da647752`（`HEAD^{tree}=f18ff993e5148746b96041fdd3c76fc441200a5a`） |
| Parent review SHA | `c34b6dacba74cd3aa939d8e323daa0e8a9f7bd49` |
| Baseline | `56bad7f71009c104c783477876d577c2fa95861e` |
| Mode | 只读；仅追加本 addendum |

本 runtime 未撰写词表修复。Quality 对 `c34b6da` 的 `P1-Q-001` 是该增量的输入，
不是本 Architecture 结论。本 addendum 不关闭 Assignment，不替代对该 SHA 的
独立 Quality 复审。

### 冻结输入（this SHA）

| Input | SHA-256 |
|---|---|
| [`KOS-SUG-OBS-PREFLIGHT-001` Assignment](../assignments/kos-sug-obs-preflight-001.md) | `ea531612deefc6f2c70d84e700aa2d6cb48f41dceca162abccbd2e8db28834fe` |
| [`AUTH-KOS-SUG-OBS-PREFLIGHT-001`](../authorizations/AUTH-KOS-SUG-OBS-PREFLIGHT-001.md) | `10e63043e3d872bb6b66874fc6e0b079dbeff13c6eb205068a3461403f08873a`（unchanged） |
| [`KOS-SUG-OBS-PREFLIGHT-001` Product Decision](../product-decisions/KOS-SUG-OBS-PREFLIGHT-001-authorization.md) | `5957c6328cae89451ea7bfa971d6c8297bba0810484bfed186d7511ce782eeed`（unchanged） |
| [`universe-keyboard-human-operated-evidence-profile.md`](../kos/universe-keyboard-human-operated-evidence-profile.md) | `b7588eeaec64e568945b74047828e455b68aa52f39877320bc813ce3135dd0ec` |
| [`DOCUMENTATION_GOVERNANCE.md`](../DOCUMENTATION_GOVERNANCE.md) | `d13c15217037571c8df9a43257ecae6e5d8c90556e4512116cae8568999651af` |
| [`KOS-SUG-OBS-PREFLIGHT-001-quality-review.md`](KOS-SUG-OBS-PREFLIGHT-001-quality-review.md) | `9066c6058c728f89159a2c0ca43a2bacb91682eddc7224b8bba3e3f2214785d5`（对 `c34b6da` 的快照，含 `P1-Q-001`） |

`git diff --check c34b6da..2d5263d` 通过。范围内产品文档仍无 Swift / 隐私政策 /
诊断 UI / 生产日志 / CI 脚本变更。相对 `origin/main` 新增的仅是两份 review
文件与上述词表修复。

### Delta 内容

Executor 采用 Quality `P1-Q-001` 的更强可选修复：把 preflight 列从
`Preflight outcome` / `pass` / `inconclusive` / `not-run` 改为
`Preflight readability` / `readable` / `unreadable` / `not-checked`。

Profile 现为该词表的 Source of Truth
（[`profile:107-136`](../kos/universe-keyboard-human-operated-evidence-profile.md#L107)）：

- `Readable now?` = `yes` → `readable`；`no` 或 `unknown` → `unreadable`（fail-closed）。
- `not-checked` = 该 opted-in 行尚未检查；任一行仍为 `not-checked` 时不得发出第一条 operator 指令。
- 三值只描述操作前字段可读性；禁止复制到 E-01 Outcome、M-04 grade、Device-attested、Quality-reverified 真机证据、Product Gate、Release 或 SUG-04 重开触发。
- 不可读 → `unreadable`；不得要求打开原始目录；`unreadable` 不授权 SUG-08。
- 该表仍不能授权真机 run、日志改动或采集用户内容。
- Readiness Review 对 opted-in run 要求每行已是 `readable` 或 `unreadable`（无 `not-checked`），允许带着 `unreadable` 行继续（功能 claim 仍可测），但不把 `unreadable` 升格为 SUG-08。

Governance 交叉引用同步为“preflight readability 不是 E-01 outcome；不可读 →
`unreadable`；不授权 raw-directory / device run / SUG-08”
（[`DOCUMENTATION_GOVERNANCE.md:182-186`](../DOCUMENTATION_GOVERNANCE.md#L182)）。
Assignment Objective 与 Exit Criteria 使用同一词表
（[`Assignment:47-50`](../assignments/kos-sug-obs-preflight-001.md#L47)、
[`Assignment:97-100`](../assignments/kos-sug-obs-preflight-001.md#L97)）。

### SoT / authority / scope

父审查五项边界在本 SHA 上仍然成立，且词表碰撞被收紧：

| Check | This SHA |
|---|---|
| Opt-in / 不回填 / 非 Kit v0.8 合同 | 未改；profile 仍要求点名该节 |
| functional vs trace；event code ≠ UUID/phase/elapsed | 未改 |
| 不可读不授权 SUG-08 / 真机 / 原始目录 | 词从 `inconclusive` 改为 `unreadable`；禁令仍在 |
| Assignment → AUTH → PD；frontier 不创造权威 | AUTH 未改；frontier 仍为 `In progress` / 后续片 `Not authorized` |
| docs-only | 产品增量仍只改 profile、Governance、Assignment；无代码/隐私/诊断/日志 |

`readable` 也不是设备授权或 SUG-04 自动重开：profile 明确禁止把三值复制到
SUG-04 触发器。未来 opted-in 真机 Assignment 仍需自己的 Human Dependency 与
匹配授权。

对 `c34b6da` 父审查中“preflight `pass`/`inconclusive`/`not-run` 描述可读性、
不是 E-01 claim 成立”的解读：本 SHA 已用独立词表落实，父审查该项观察关闭。

### Findings（this SHA）

| ID | Severity | Disposition | Finding |
|---|---|---|---|
| `A-SUG-OBS-P3-01` | P3 | `fix`（non-blocking） | 本切片 PD 末句仍写 “An inconclusive preflight does not authorize SUG-08” （[`PD:24-25`](../product-decisions/KOS-SUG-OBS-PREFLIGHT-001-authorization.md#L24)），而表词表 SoT 已改为 `unreadable`。禁令本身正确，且 PD 不是表字段权威；但权威包内残留 E-01 碰撞词。应对齐为 “`unreadable` preflight readability does not authorize SUG-08”，或把旧短语标为历史同义。不因此授权 SUG-08，也不把本切片升格为真机。 |

无 P0/P1/P2。无阻塞失败情景：即使 PD 用旧词，profile/Governance/Assignment/AUTH
仍 fail-closed，禁止把 preflight 值当作 E-01 或 SUG-08 授权。

### Verdict（this SHA）

**Architecture verdict: Pass.**

Counts for `2d5263d`: **P0/P1/P2/P3 = 0/0/0/1**.

词表拆分修复了与 E-01 Outcome 的碰撞，没有扩大权威或范围。`A-SUG-OBS-P3-01`
不阻止本 Architecture 结论；建议在最终 docs-only 收口前改 PD 一句。Quality
须对该 SHA 独立复审 `P1-Q-001` 是否关闭。本 addendum 落盘会使工作树相对
`2d5263d` 变脏，不覆盖后续文档树。
