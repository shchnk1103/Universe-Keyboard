# KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001 P1 独立 Quality / Performance / Release 审查

审查日期：2026-09-14（Asia/Shanghai）
审查角色：独立 Quality / Performance / Release Reviewer
审查目标：`/private/tmp/universe-keyboard-kos-upgrade-uk-005`
审查结论：**Needs work**

本报告只记录当前 worktree 的独立只读审查结果。除本报告外没有写入目标或主工作树；未读取另一位 reviewer 的新报告或结论；没有执行 commit、push、merge、tag、Release、TestFlight、App Store Connect、上传、网络或凭证相关动作。

## 1. 结论摘要

固定 Envelope 45 案例和 delta 21 案例均与机器报告中的期望结果一致，且六文件原始字节摘要与 package digest 均重新计算通过。但是，当前实现尚不能关闭本轮独立退出审查：

- **P1-01：首个 external candidate 的 `baseline=True` 会由 adapter 自动伪造一个 baseline review-record 指针。** 这不是独立验证过的 baseline receipt；在其余输入为合成 pass 时，pinned evaluator 会给出 `current-proof`。同时 `baseline_verification_ref` 被接受但没有被读取或验证。
- **P1-02：delta path classifier 没有把实际 Main-App `Universe Keyboard/Services/ReleaseEvidenceStore.swift` 识别为 release-evidence source-owner dependency。** 对该真实文件的路径探针仍会复用 candidate-identity evidence；这与 Profile 对 `SRC-MAIN-STORE` / source-owner 变更的 full/no-reuse 约束不闭合。

另有 P2 输入 fail-closed 和 provenance binding 缺口，详见第 6 节。没有观察到 P0；没有观察到本次六文件会触发 Keyboard Extension hot-path、App Group、网络、凭证或发布动作的越界。

## 2. 审查边界、输入与权威材料

已读取并以当前目标 worktree 为准核对：

- `AGENTS.md`、`docs/KNOWLEDGE_INDEX.md`、`docs/ACTIVE_WORK.md`、`docs/READING_MAPS.md`、`docs/playbooks/test-release.md`；
- parent/child Assignment、对应 Authorization、P1-A Product Decision、adoption/evidence handoff；
- `docs/kos/release-evidence-profile.md`、`docs/RELEASE_CHECKLIST.md`、`docs/kos/UPGRADE_STATUS.md`、`.kos/project.json`；
- pinned KOS contract、schema、standalone evaluator；
- `/private/tmp/uk-kos-kos-fixtures-fix7/report.json`；
- 主工作树中现有 `Universe Keyboard/Services/ReleaseEvidenceStore.swift`，仅作为 source-seam 输入只读核对，未将其改动纳入本次实现或报告 digest。

未读取 `docs/reviews/` 中任何其他 reviewer 报告。Implementation receipt 只作为被审查的执行记录交叉核对，未将其中已有的 CI 结果当作本 reviewer 的 Quality 通过依据。

## 3. 六文件原始字节摘要与 package digest

按用户指定顺序，使用 `shasum -a 256` 对每个文件，再使用 `cat "${files[@]}" | shasum -a 256` 对原始字节无分隔串联结果重算。当前 worktree 结果如下：

| 顺序 | 文件 | 独立重算 SHA-256 | 期望值 | 结果 |
|---:|---|---|---|---|
| 1 | `scripts/release/kos_release_evidence_adapter.py` | `e4dcbda8e77ed3bf63f4943a851b0133b790ba8391c4f806133e42fb8b4a0466` | 同左 | PASS |
| 2 | `scripts/release/run_kos_release_evidence_fixtures.py` | `37147357042924cd051a7d3f8ed9fee9198d1287c3b24f048e3e875006f75888` | 同左 | PASS |
| 3 | `scripts/release/fixtures/kos_release_evidence_cases.json` | `6cd843ffd61bf906310dec7e52d19a67656bfa0f422223509358af8cc6e4f37d` | 同左 | PASS |
| 4 | `scripts/release/tests/test_kos_release_evidence_adapter.py` | `26593d80d056e4291db518ed6d1ccae80b6798fff376361b8c95ef51f8163ae0` | 同左 | PASS |
| 5 | `docs/kos/release-evidence-profile.md` | `71d3b301fb8f0bbc71aab14143c6a863320004e6b3cf27f55ae1ef906ccd867b` | 同左 | PASS |
| 6 | `docs/RELEASE_CHECKLIST.md` | `6c3a2bb9611d32a09256a0e290629ec51a23b7f531f1d0e9ae9ddae0265e5eca` | 同左 | PASS |
| — | 六文件按上述顺序原始字节串联 | `35a055a4341dbd77bb2aec74fbae7699449d23c700d7c8c226b0e693c385421d` | `35a055a4341dbd77bb2aec74fbae7699449d23c700d7c8c226b0e693c385421d` | **PASS** |

本报告以当前重算的 `35a055a4341dbd77bb2aec74fbae7699449d23c700d7c8c226b0e693c385421d` 为准。报告文件不属于上述六文件串联包。

### Pinned KOS source digest

目标 Profile/runner 指向的 `/Users/doubleshy0n/Dev/kos-agent-kit` pinned source 也独立核对为：

| Source | 文件 | SHA-256 |
|---|---|---|
| Contract | `ops/release-evidence.md` | `f7ec8d9363cc37e53201e8bf990af80ba77fc9f88b7f78371d2c39f453a78673` |
| Schema | `schemas/release-evidence-v1.schema.json` | `4e48bcf127edb87e67c4d390a3baec93af26ef72aa251e8172cb1044dca893ce` |
| Evaluator | `scripts/validate_release_evidence.py` | `a45145681306c2da581f1054f002b7becd909d1bb4a8329ad14892f17839b9d9` |

三项 actual digest 均等于 Profile/fixture report 的 expected digest。候选实现 pins、candidate tree、adoption metadata 和 package digest 与 handoff 记录一致；这只证明材料绑定一致，不证明 hosted provenance 或产品发布资格。

## 4. 实际检查与测试

### 4.1 Focused Python tests

独立执行：

```text
PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s scripts/release/tests -p 'test_*.py'
```

结果：`Ran 17 tests in 0.010s`，`OK`，exit `0`。未生成 bytecode，也未修改实现。

### 4.2 现有 fixture machine report

只读解析：`/private/tmp/uk-kos-kos-fixtures-fix7/report.json`。该文件本次独立重算 SHA-256 为 `59138dbb7128184037d32db2fcaea9b914cc36af6e9145281d5ff2f66621c199`。

- 总计 `66/66`：Envelope `45/45`，delta `21/21`；
- fixed inventory 的 45 个 `UK-RE-FX-001..045` 与 21 个 `UK-RE-DELTA-001..021` 顺序、数量均正确；
- 45 个 evaluator command 均带显式 `--as-of`，本矩阵时钟为 `2026-09-14T12:00:00+08:00`；
- runner 在执行矩阵前核验了上述 contract/schema/evaluator 三个 pinned source digest；
- 每案记录了 command、stdout/stderr、exit、status 和 non-claim；
- 本 reviewer 没有把该既有机器报告或 implementation receipt 的“全套 Swift CI 已通过”当作本次质量门通过。

### 4.3 定向 bounded probes

在内存中导入当前 adapter/evaluator 做了不写文件的 bounded probe：

1. 将 canonical wrapper 的 outer `outcome` 改为 `fail`，而 steps、delivery、final validation 保持 pass；adapter 接受，pinned evaluator 返回 `current-proof`。
2. external first 使用 `promotion.baseline=True`；adapter 生成 `opaque://...;class=review-record` baseline 指针，pinned evaluator 返回 `current-proof`。生成指针来自 Main-App source pointer digest，并非独立 baseline receipt。
3. 加入无效的 `promotion.baseline_verification_ref`，输入仍被接受，且输出仍使用自动生成的 baseline 指针；该字段没有被验证或消费。
4. 在 `main_app_source` 加入 `note`、在 nested run 加入 `raw_user_input`，输入被接受且字段未进入输出。说明输出净化有效，但输入 schema 并未对这些 nested 字段 fail closed。
5. 对真实相对路径 `Universe Keyboard/Services/ReleaseEvidenceStore.swift` 调用 `plan_delta`：结果为 `triggered`、CI `full`、`stop_before_current_proof=true`，但仍复用 `EVIDENCE-CANDIDATE-IDENTITY-56`，并只使 changed/affected 两项失效。

### 4.4 静态越界检查

本次六文件没有 Swift 改动。adapter 仅使用 Python 标准库进行 bounded JSON、hash/identity 校验和本地计划输出；runner 的 `subprocess` 仅调用本地 adapter 和 pinned evaluator。未发现网络 client、上传 API、凭证读取、App Group/FileManager 访问、Keyboard Extension runtime/hot-path、xcodebuild、git 发布命令或 App Store Connect/TestFlight 操作。

## 5. 固定 45 Envelope 逐案结果

以下是从 machine report 读取并独立核对的实际结果；`PASS` 表示实际结果等于 fixture 期望，不表示 Product/Quality/Release 通过。

| ID | case | 实际 derived status | exit | adapter exit | 矩阵 |
|---|---|---|---:|---:|---|
| `UK-RE-FX-001` | daily current proof | `current-proof` | 0 | — | PASS |
| `UK-RE-FX-002` | invalid JSON | reject / 无分类 | 2 | — | PASS |
| `UK-RE-FX-003` | invalid schema / unknown key | reject / 无分类 | 2 | — | PASS |
| `UK-RE-FX-004` | invalid policy / missing required claims | reject / 无分类 | 2 | — | PASS |
| `UK-RE-FX-005` | timezone-less `as_of` | reject / 无分类 | 2 | — | PASS |
| `UK-RE-FX-006` | external first unbound target | `pending` | 0 | — | PASS |
| `UK-RE-FX-007` | external first bound, missing baseline | `none` | 0 | — | PASS |
| `UK-RE-FX-008` | all non-comparable | `comparator` | 0 | — | PASS |
| `UK-RE-FX-009` | mixed non-comparable and missing | `none` | 0 | — | PASS |
| `UK-RE-FX-010` | external first with baseline | `current-proof` | 0 | — | PASS |
| `UK-RE-FX-011` | first target with previous receipt | `none` | 0 | — | PASS |
| `UK-RE-FX-012` | subsequent target with baseline | `none` | 0 | — | PASS |
| `UK-RE-FX-013` | subsequent target with lineage history | `current-proof` | 0 | — | PASS |
| `UK-RE-FX-014` | subsequent missing release lineage | `none` | 0 | — | PASS |
| `UK-RE-FX-015` | candidate identity mismatch | `comparator` | 0 | — | PASS |
| `UK-RE-FX-016` | future observation | `none` | 0 | — | PASS |
| `UK-RE-FX-017` | future delivery | `none` | 0 | — | PASS |
| `UK-RE-FX-018` | future final validation | `none` | 0 | — | PASS |
| `UK-RE-FX-019` | future provenance | `none` | 0 | — | PASS |
| `UK-RE-FX-020` | stale observation | `none` | 0 | — | PASS |
| `UK-RE-FX-021` | stale delivery | `none` | 0 | — | PASS |
| `UK-RE-FX-022` | stale final validation | `none` | 0 | — | PASS |
| `UK-RE-FX-023` | stale provenance | `none` | 0 | — | PASS |
| `UK-RE-FX-024` | expired `valid_until` | `none` | 0 | — | PASS |
| `UK-RE-FX-025` | P-01 missing head | `none` | 0 | — | PASS |
| `UK-RE-FX-026` | P-01 unequal heads | `none` | 0 | — | PASS |
| `UK-RE-FX-027` | P-01 hosted fail | `none` | 0 | — | PASS |
| `UK-RE-FX-028` | P-01 comparison basis mismatch | `none` | 0 | — | PASS |
| `UK-RE-FX-029` | D-01 final tree mismatch | `none` | 0 | — | PASS |
| `UK-RE-FX-030` | D-01 checker unresolved | `none` | 0 | — | PASS |
| `UK-RE-FX-031` | D-01 nonzero exit | `none` | 0 | — | PASS |
| `UK-RE-FX-032` | D-01 result fail | `none` | 0 | — | PASS |
| `UK-RE-FX-033` | candidate unresolved | `none` | 0 | — | PASS |
| `UK-RE-FX-034` | all non-comparable with ahead delivery | `comparator` | 0 | — | PASS |
| `UK-RE-FX-035` | unresolved Main-App source | reject / 无分类 | 2 | 2 | PASS |
| `UK-RE-FX-036` | unsupported Main-App schema | reject / 无分类 | 2 | 2 | PASS |
| `UK-RE-FX-037` | unsupported Main-App contract | reject / 无分类 | 2 | 2 | PASS |
| `UK-RE-FX-038` | direct-run bypass | reject / 无分类 | 2 | 2 | PASS |
| `UK-RE-FX-039` | unallowlisted artifact identity | reject / 无分类 | 2 | 2 | PASS |
| `UK-RE-FX-040` | narrative final receipt field | reject / 无分类 | 2 | 2 | PASS |
| `UK-RE-FX-041` | mismatched release lineage | reject / 无分类 | 2 | 2 | PASS |
| `UK-RE-FX-042` | D-01 checker version unresolved | `none` | 0 | — | PASS |
| `UK-RE-FX-043` | D-01 scope unresolved | `none` | 0 | — | PASS |
| `UK-RE-FX-044` | D-01 baseline unresolved | `none` | 0 | — | PASS |
| `UK-RE-FX-045` | D-01 pass with output `UNKNOWN` | reject / 无分类 | 2 | — | PASS |

结论：固定 Envelope 矩阵覆盖了 invalid JSON/schema/key/timezone、UNKNOWN、future/stale/expiry、candidate identity、first/subsequent promotion、P-01 heads/hosted/basis、D-01 tree/checker/version/scope/baseline/output/exit/result，以及 adapter wrapper/identity/receipt/narrative 负例。其 positive `current-proof` 仅是合成 Envelope 的 evaluator classification。

## 6. 固定 21 delta 逐案结果

`reuse` 和 `invalidated` 为机器报告实际输出；`stop=true` 表示在该计划下停止当前-proof，不是 CI 或发布授权。

| ID | case | profile | CI | reuse | invalidated | stop | 矩阵 |
|---|---|---|---|---|---|---|---|
| `UK-RE-DELTA-001` | ordinary UI | `delta` | `full` | candidate identity | changed path, affected smoke | true | PASS |
| `UK-RE-DELTA-002` | exact docs checklist | `delta` | `docs_only` | all 3 | — | false | PASS |
| `UK-RE-DELTA-003` | candidate identity | `full` | `full` | — | all 3 | true | PASS |
| `UK-RE-DELTA-004` | privacy owner | `full` | `full` | — | all 3 | true | PASS |
| `UK-RE-DELTA-005` | freshness | `full` | `full` | — | all 3 | true | PASS |
| `UK-RE-DELTA-006` | promotion history | `full` | `full` | — | all 3 | true | PASS |
| `UK-RE-DELTA-007` | schema pin | `full` | `full` | — | all 3 | true | PASS |
| `UK-RE-DELTA-008` | delivery / fresh P-01 | `triggered` | `full` | all 3 | — | true | PASS |
| `UK-RE-DELTA-009` | final validation / fresh D-01 | `triggered` | `full` | all 3 | — | true | PASS |
| `UK-RE-DELTA-010` | unknown path | `full` | `full` | — | all 3 | true | PASS |
| `UK-RE-DELTA-011` | stale evidence on docs-only path | `delta` | `docs_only` | — | all 3 | true | PASS |
| `UK-RE-DELTA-012` | Profile path | `full` | `full` | — | all 3 | true | PASS |
| `UK-RE-DELTA-013` | `.kos/project.json` | `full` | `full` | — | all 3 | true | PASS |
| `UK-RE-DELTA-014` | wrong claim binding | `full` | `full` | — | all 3 | true | PASS |
| `UK-RE-DELTA-015` | missing coverage binding | `full` | `full` | — | all 3 | true | PASS |
| `UK-RE-DELTA-016` | unknown scope | `full` | `full` | — | all 3 | true | PASS |
| `UK-RE-DELTA-017` | extra evidence field | `full` | `full` | — | all 3 | true | PASS |
| `UK-RE-DELTA-018` | Keyboard triggered path | `triggered` | `full` | candidate identity | changed path, affected smoke | true | PASS |
| `UK-RE-DELTA-019` | semantic `source_owner` | `full` | `full` | — | all 3 | true | PASS |
| `UK-RE-DELTA-020` | unsafe path | `full` | `full` | — | — | true | PASS |
| `UK-RE-DELTA-021` | empty path input | `full` | `full` | — | — | true | PASS |

固定 delta 确实覆盖了 untouched reuse、changed/authority/privacy、unsafe、stale、malformed/duplicate、claim/coverage binding、unknown scope/path、delivery/final-validation、schema/profile/source-owner 和空输入。但它没有覆盖真实 `ReleaseEvidenceStore.swift` 文件路径与 `source_owner` 语义之间的绑定，这正是 P1-02。

## 7. Findings

### P0：无

本次没有观察到会立即造成数据破坏、凭证泄露、网络上传、Extension 热路径阻塞或未经授权发布动作的 P0 问题。

### P1-01 — 首个 external baseline 可由布尔值伪造（Open，阻断独立退出）

证据路径：

- `scripts/release/kos_release_evidence_adapter.py:824-839`：`_baseline(True, ...)` 由当前 Main-App source digest 生成 `opaque://.../baseline-...;class=review-record`，并填充 candidate/stage/profile 等字段；没有读取独立 baseline receipt 或验证其内容。
- `scripts/release/kos_release_evidence_adapter.py:975-1019`：`promotion.baseline=True` 被接受；`baseline_verification_ref` 虽在 allowed set（约 `:979-986`），但后续没有被消费或验证。
- `scripts/release/run_kos_release_evidence_fixtures.py:255-260`：external first fixture helper 明确传入 `"baseline": True`。
- `UK-RE-FX-010` 因此在合成 pass 输入上得到 `current-proof`。
- bounded probe 还验证了 `baseline_verification_ref="not-a-pointer"` 仍被接受，并且输出仍使用自动生成的 pointer。

Profile 的 first-target 规则要求 current-candidate-bound、可验证的 baseline；它不是“调用方声称 baseline 存在”的 Boolean。当前实现把一个测试/fixture 便利值暴露在 production adapter 输入边界，导致无独立 baseline 证据时也能形成支持 evaluator `current-proof` 的 Envelope。虽然该 adapter 没有上传或批准发布，但这是 proof boundary 的实质性 fail-open。

需要在后续修复中使生产输入拒绝该布尔捷径，或将它严格隔离在不会生成可审计 proof 的 test-only 构造路径；必须消费并验证真实 baseline verification reference/receipt，并增加 `baseline=True`、缺失 receipt、无效 verification ref 的负例。此处本 reviewer 不实施修改。

### P1-02 — 真实 Main-App release-evidence store 路径未进入 dependency-closed delta 分类（Open，阻断独立退出）

证据路径：

- Profile `docs/kos/release-evidence-profile.md:47-57` 将 `SRC-MAIN-STORE` 定义为 Main-App release-evidence ownership/lifecycle source seam，并规定在 `REP-Q-01` 前不是 current-proof provenance。
- 实际 Main-App `Universe Keyboard/Services/ReleaseEvidenceStore.swift:338-355` 拥有 App Group 文件位置及 `Diagnostics/v1/release-evidence/records.json`；`:432-452` 定义 canonical `ReleaseEvidenceExport` wrapper。
- adapter `scripts/release/kos_release_evidence_adapter.py:204-210,1135-1167` 的 release dependency prefix 只覆盖 KOS/Assignment/Authorization/Product/architecture 文档；该真实 Services 路径只被 `_area_for_path` 归为 `main_app`，普通路径只能得到 changed/affected scopes。
- `:1385-1410` 的普通路径分支保留了 candidate-identity reuse。对真实路径的定向 probe 实际得到：`profile=triggered`、`ci=full`、`reuse=(EVIDENCE-CANDIDATE-IDENTITY-56,)`、changed/affected 两项失效、`stop=true`。

这与现有 `UK-RE-DELTA-019` 的语义 `source_owner -> full/no reuse` 不等价：真实文件的普通 path 输入可以绕过 source-owner semantic surface。若该文件改变 export shape、store ownership、record identity、retention 或 lifecycle，candidate identity evidence 可能不再安全复用。当前六文件本身没有修改 Swift store，因此这不是本次 package digest 的 changed-file 误报；但它是 P1-A 声称的未来 delta/reuse 安全边界未闭合。

需要在后续修复或明确的 Profile 绑定中将实际 source-owner 路径纳入 full/no-reuse，并增加路径级 fixture；这不授权或扩大 P1-B Main-App UI/storage 实现范围。

### P2-01 — canonical Main-App aggregate `outcome` 只校验枚举，不校验与 steps 一致性（Open）

`scripts/release/kos_release_evidence_adapter.py:383-415` 对 canonical wrapper 做了 top-level exact-key、schema、contract、recordType 和 `outcome` 枚举校验，但返回 run 时没有将 outer outcome 与 `run.steps` 的聚合结果比较。实际 Main-App `ReleaseEvidenceStore.swift:301-318` 的 `ReleaseEvidenceRun.outcome` 是由 steps 和 external promotion mode 计算出的语义字段。

定向 probe 把 outer `outcome` 改为 `fail` 而 steps/delivery/final validation 保持 pass，adapter 仍生成 Envelope，pinned evaluator 仍返回 `current-proof`。因此“canonical export 已经声明 fail”不会阻止 proof classification。该问题目前没有造成数据泄露或外部动作，但违反 canonical export 的 fail-closed 直觉；应增加 contradiction negative fixture，或明确拒绝/保守映射不一致的 aggregate outcome。

### P2-02 — nested source/run/step 的未知或叙事字段被静默接受并丢弃（Open）

adapter 对 wrapper 顶层是 exact keys，但：

- `main_app_source` 只读取 `record_id`、`operation_id`、`sha256`、`retention_class`，未拒绝额外字段；
- `main_app_export.run` 的 identity 只读取需要字段，未对整个 run key set 做 exact 校验；
- `run.steps` 允许 step mapping 中存在未使用字段，`:478-480` 明确只忽略 notes。

定向 probe 验证 `main_app_source.note` 与 nested `run.raw_user_input` 能进入 adapter 输入且被静默丢弃。当前输出 allowlist 通过，输入内容没有泄漏到 Envelope；但用户/receipt/narrative 输入的 fail-closed 边界不完整，且未来新增字段可能被误当成已接受的 canonical schema。建议增加 source/run/step nested unknown-field 和 narrative negative cases，并将“丢弃”与“拒绝”契约明确化。

### P2-03 — delta evidence tuple 的 contract pin 是名称，不是 contract source digest（Open / Unknown binding intent）

`scripts/release/kos_release_evidence_adapter.py:110-128,1197-1263` 的 delta tuple 要求 `contract_pin`，但只比较字符串 `kos.release-evidence`；同时要求 schema/evaluator digest，却没有 contract source digest 字段。runner 会在整套矩阵启动时核验 contract source digest，所以当前 45/21 report 的 pinned source check 通过；但是单个 delta reuse tuple 本身无法表达它所绑定的 contract source bytes。

我无法从当前材料确定这是有意采用“package-level contract binding”，还是遗漏字段，因此保留为 `P2 / Unknown`，不把它升级为当前矩阵失败。若 contract source digest 应属于逐 tuple provenance，应补绑定；若它只在 package-level 绑定，应在 Profile/runner/report 中明确该边界并提供可复核 package digest。

### P3：无需新增阻断 finding

本次没有 Swift/runtime 变更，因而没有将“未重跑设备/性能 trace”伪装成 P3 质量失败。相关未执行项和 non-claims 见第 9 节。

## 8. 重点合同核对结论

### Main-App canonical export、UNKNOWN、identity/receipt/narrative

- canonical wrapper 的顶层版本、contract、recordType、required fields 和 direct-run bypass 负例通过；
- unresolved Main-App source、错误 schema/contract、artifact identity、release lineage、D-01 narrative receipt field 的负例均被拒绝；
- `UNKNOWN` 在允许的 not-run/receipt 字段中保留，未被 adapter 任意填成 pass；unresolved source identity 会直接拒绝；
- 但 outer aggregate contradiction 和 nested unknown/narrative input 分别形成 P2-01/P2-02，baseline shortcut 形成 P1-01。

### P-01 / D-01

固定结果符合 Profile 的保守状态：P-01 missing/unequal head、hosted fail、comparison-basis mismatch 均为 `none`；D-01 final-tree mismatch、checker/version/scope/baseline/output/exit/result 不满足时均未成为 current proof，`pass + output=UNKNOWN` 直接被 evaluator 以 exit 2 拒绝。Profile 要求的 `local_head == published_head == hosted_ci_head == candidate_head` 和显式 `--as-of` 在固定矩阵中被覆盖。

这证明的是 evaluator 对合成 receipt 的结构/新鲜度/绑定语义，不是实际 hosted CI、archive、tag 或最终发布产物的存在性。

### First / subsequent daily Beta → external candidate

`UK-RE-FX-006..014` 覆盖 unbound target、first missing baseline、first with baseline、first with previous、subsequent with baseline、subsequent with lineage history、missing release lineage；实际状态均与期望一致。其缺口是 first baseline helper 可以由布尔值自动构造，因此不能仅凭 FX-010 的绿色结果关闭 P1-01。

### Delta untouched reuse / changed / authority / unsafe / stale / malformed / duplicate / claim / coverage

普通 UI 和 Keyboard path 只复用 candidate identity，受影响 claims 失效并 stop；docs-only checklist 是唯一 `docs_only` CI tier；candidate/privacy/freshness/promotion/schema/Profile/KOS/source-owner/claim/coverage/unknown/unsafe/empty surface 均按固定矩阵进入 full/no-reuse 或 stop。真实 Main-App store path 的 path-level source-owner 缺口仍由 P1-02 单独保留。

## 9. Release / Quality / Performance non-claims

本报告不声明以下任一事项：

- `current-proof` 是 Product acceptance、Quality pass、Release pass、Product Gate、Beta Review approval、upload authorization 或 App Store publication；
- `66/66` fixture green 等于真实 Build、archive、签名、dSYM、设备、hosted CI 或 TestFlight 可安装性；
- 已有 implementation receipt 中记录的 KeyboardCore、RimeBridgeTests、Universe Keyboard simulator tests、Debug/Release build 或 KOS validator 结果是本 reviewer 独立重跑的质量通过；
- 已完成 `REP-Q-01` 的 Main-App implementation identity、final SHA、base/head 或 hosted provenance；
- 已完成 `HOSTED-PROVENANCE`、physical-device matrix、performance/memory profiling、archive/export、App Store Connect、TestFlight、Beta Review、external tester distribution 或 Release；
- P1-B Main-App Diagnostics UI/storage、history migration、background sync、App Group ownership 变更或任何 Keyboard Extension runtime/hot-path 实现已经完成。

按用户要求，本次没有重复完整 Swift CI；没有执行 Swift-format、Swift test、xcodebuild、设备测试或性能 trace。由于本次六文件没有 Swift/runtime 改动，这些未执行项是审查范围限制而不是被伪装成通过的证据。

## 10. 证据路径与后续门

主要证据：

- 当前目标：`/private/tmp/universe-keyboard-kos-upgrade-uk-005`
- 本报告：`/private/tmp/universe-keyboard-kos-upgrade-uk-005/docs/reviews/KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-p1-quality-remediation-exact-digest-review-2026-09-14.md`
- machine report：`/private/tmp/uk-kos-kos-fixtures-fix7/report.json`
- adapter：`scripts/release/kos_release_evidence_adapter.py`
- runner：`scripts/release/run_kos_release_evidence_fixtures.py`
- fixed cases：`scripts/release/fixtures/kos_release_evidence_cases.json`
- focused tests：`scripts/release/tests/test_kos_release_evidence_adapter.py`
- contract：`/Users/doubleshy0n/Dev/kos-agent-kit/ops/release-evidence.md`
- schema：`/Users/doubleshy0n/Dev/kos-agent-kit/schemas/release-evidence-v1.schema.json`
- evaluator：`/Users/doubleshy0n/Dev/kos-agent-kit/scripts/validate_release_evidence.py`
- Main-App source seam：`/Users/doubleshy0n/Dev/Universe Keyboard/Universe Keyboard/Services/ReleaseEvidenceStore.swift`

在 P1-01、P1-02 关闭并由新的 exact-digest 独立审查复核前，本 P1-A 不应标记为独立 Quality/Release 退出完成；`REP-Q-01`、`HOSTED-PROVENANCE` 和单独授权的 P1-B 仍保持各自边界。
