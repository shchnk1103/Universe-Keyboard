# KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001 P1 Architecture Review

## 审查结论

**Needs work。**

本报告只审查本轮指定的六文件实现包，精确 package digest 为
`82a2061cf277ecf248d521f8f2f532ad404e84f6db8c677dd5d3877abc795242`。

包完整性、固定 fixture 报告、Pinned KOS Kit 身份和现有自动化检查均可复现并匹配；但是，当前包仍存在会让声明式、可伪造或未验证的事实进入 `current-proof` 的架构路径。因此本轮不能给 Architecture Pass。`REP-Q-01` 仍是实际 Main-App source binding 的未闭合阻塞项。

本轮没有修改六文件、fixture、Profile、Checklist 或主工作树；没有 commit、push、merge 或任何发布动作。唯一写入的是本报告。

## 审查边界与输入身份

| 项目 | 实测值 / 结论 |
|---|---|
| 审查工作目录 | `/private/tmp/universe-keyboard-kos-upgrade-uk-005` |
| 目标基线 HEAD | `3139f8d3bdb6be6622504ea731988f42681896fb`，匹配要求 |
| 目标工作树 Swift 改动 | none；`git diff`、暂存区和未跟踪 Swift 检查均无输出 |
| 本轮审查对象 | 仅 package digest `82a2061cf277ecf248d521f8f2f532ad404e84f6db8c677dd5d3877abc795242` |
| Main-App source seam | 目标隔离工作树中不存在 `Universe Keyboard/Services/ReleaseEvidenceStore.swift`；按任务要求只读核对了主工作树中的 ambient 文件，未把它当成本轮 package 内容 |
| Main-App ambient 文件身份 | `/Users/doubleshy0n/Dev/Universe Keyboard/Universe Keyboard/Services/ReleaseEvidenceStore.swift` 未被 Git 跟踪；只读 SHA-256 为 `219944fb2da1317a9b7979ebb3b480da9171c2e74d688ea61a0a480e8065a4b1`，不是稳定 commit/source binding |

主工作树的 source 文件只是用于比较 Swift 语义和 owner seam；它没有被修改，也没有被纳入本轮六文件 digest。Profile 本身已声明 `SRC-MAIN-STORE` 只是 seam，只有精确的 `REP-Q-01` implementation identity 才能成为 current-proof binding（见 `docs/kos/release-evidence-profile.md:56-65`）。

## Exact digest 核验

### 六文件原始字节串接

按用户给出的顺序、不加分隔符和文件名执行 `cat ... | shasum -a 256`，结果如下：

| 文件 | 期望 SHA-256 | 实测 SHA-256 | 结果 |
|---|---|---|---|
| `scripts/release/kos_release_evidence_adapter.py` | `9e02afa93c4c9f91f7dcdbabe6ad5b4e9c4da6aef5f75ad4770dfa4a6bca2608` | `9e02afa93c4c9f91f7dcdbabe6ad5b4e9c4da6aef5f75ad4770dfa4a6bca2608` | match |
| `scripts/release/run_kos_release_evidence_fixtures.py` | `7fe337bcc0b4585ec58b8415ff565be01ffc32dfc6351d9665e483f74c16c499` | `7fe337bcc0b4585ec58b8415ff565be01ffc32dfc6351d9665e483f74c16c499` | match |
| `scripts/release/fixtures/kos_release_evidence_cases.json` | `c5c1aceacb93aca01a8be08d739f9847b4410f0c997e5e2a9e1b4a5051b38921` | `c5c1aceacb93aca01a8be08d739f9847b4410f0c997e5e2a9e1b4a5051b38921` | match |
| `scripts/release/tests/test_kos_release_evidence_adapter.py` | `637c34282c0b3f9e5b9163e4f4c27b323dec5ebbd7404c628bab3805c64a70ac` | `637c34282c0b3f9e5b9163e4f4c27b323dec5ebbd7404c628bab3805c64a70ac` | match |
| `docs/kos/release-evidence-profile.md` | `6a1da162be5093b3d2543b274555d750957bc7b1b739954fb0fb94e82cdcd73b` | `6a1da162be5093b3d2543b274555d750957bc7b1b739954fb0fb94e82cdcd73b` | match |
| `docs/RELEASE_CHECKLIST.md` | `04af53964d0381f7ccf59a428eb985259a9f9be55d8cb35e0223877301ccff7c` | `04af53964d0381f7ccf59a428eb985259a9f9be55d8cb35e0223877301ccff7c` | match |
| **六文件原始串接** | `82a2061cf277ecf248d521f8f2f532ad404e84f6db8c677dd5d3877abc795242` | `82a2061cf277ecf248d521f8f2f532ad404e84f6db8c677dd5d3877abc795242` | **match** |

固定 fixture 报告 `/private/tmp/uk-kos-kos-fixtures-fix9/report.json` 的实测 SHA-256 为
`db846cfd8f1220fdc23c039c05aa7d755dba80747da1a6cbad822561151f0a61`，匹配要求；其摘要为 Envelope `52/52`、Delta `24/24`、总计 `76/76`。独立临时目录重跑也得到 Envelope `52/52`、Delta `24/24`、总计 `76/76`；由于 runner 输出包含临时 work directory 相关内容，该独立报告字节 digest 不用于替代固定报告 digest。

### Pinned KOS Kit 身份

对 `/Users/doubleshy0n/Dev/kos-agent-kit` 进行了独立 Git 和原始字节核验：

| 项目 | 实测值 / 结果 |
|---|---|
| adoption/HEAD | `f5c88d57f599d7ef352322ea7664f637fb288d60` |
| implementation commit | `8e55551a3b56b57e7fc5ab5544d653f9c6854df9`，`cat-file` 类型为 commit |
| adoption/HEAD | `cat-file` 类型为 commit |
| ancestor 关系 | `git merge-base --is-ancestor 8e55551a3b56b57e7fc5ab5544d653f9c6854df9 f5c88d57f599d7ef352322ea7664f637fb288d60` exit `0` |
| Kit worktree | `git status --porcelain` 为空 |
| contract semantic digest | `f7ec8d9363cc37e53201e8bf990af80ba77fc9f88b7f78371d2c39f453a78673` |
| schema semantic digest | `4e48bcf127edb87e67c4d390a3baec93af26ef72aa251e8172cb1044dca893ce` |
| evaluator semantic digest | `a45145681306c2da581f1054f002b7becd909d1bb4a8329ad14892f17839b9d9` |
| candidate raw tree digest | `fec6889e81ea0807b284de45027e0270a70938e220041a8c367fd41a081a88c9` |

上述 tree digest 按 adapter/runner 的十文件 `PINNED_CANDIDATE_MANIFEST` 顺序对原始字节串接计算；不是只核对 Git commit message 或 receipt 文字。

## 可复现命令与检查结果

以下命令均在指定隔离工作树执行；Python 命令使用 `-B`，避免再生成目标工作树的 bytecode 缓存。

```bash
pwd
git rev-parse HEAD
git diff --name-only HEAD -- '*.swift'
git diff --cached --name-only -- '*.swift'
git status --short --untracked-files=all | rg '\.swift$'
```

结果分别确认工作目录、目标 HEAD 和无 Swift 改动；主工作树未被用于写入。

```bash
shasum -a 256 \
  scripts/release/kos_release_evidence_adapter.py \
  scripts/release/run_kos_release_evidence_fixtures.py \
  scripts/release/fixtures/kos_release_evidence_cases.json \
  scripts/release/tests/test_kos_release_evidence_adapter.py \
  docs/kos/release-evidence-profile.md \
  docs/RELEASE_CHECKLIST.md

cat \
  scripts/release/kos_release_evidence_adapter.py \
  scripts/release/run_kos_release_evidence_fixtures.py \
  scripts/release/fixtures/kos_release_evidence_cases.json \
  scripts/release/tests/test_kos_release_evidence_adapter.py \
  docs/kos/release-evidence-profile.md \
  docs/RELEASE_CHECKLIST.md \
  | shasum -a 256

shasum -a 256 /private/tmp/uk-kos-kos-fixtures-fix9/report.json
```

```bash
python3 -B -m unittest discover \
  -s scripts/release/tests \
  -p 'test_*.py'
```

结果：`Ran 22 tests`，`OK`。

```bash
python3 -B scripts/release/run_kos_release_evidence_fixtures.py \
  --kos-kit-root /Users/doubleshy0n/Dev/kos-agent-kit \
  --work-dir /private/tmp/uk-kos-architecture-review-A7leD7 \
  --output /private/tmp/uk-kos-architecture-review-A7leD7/report.json
```

结果：exit `0`；独立输出的 Envelope/Delta/总计分别为 `52/52`、`24/24`、`76/76`，且 runner 独立核对了 Kit commit、ancestor、clean、candidate tree 和三个 semantic digest。

## 正向核对结果

以下边界在当前 package 中已得到代码、fixture 或独立命令支持：

- `main_app_export` 的 wrapper 顶层 key、schema/type/contract version、固定 `nonClaims` 和 outer outcome 有 exact 检查；direct run、foreign wrapper、unknown wrapper key 和 unresolved source record 的现有负例会被拒绝（adapter `:427-461`、`docs/kos/release-evidence-profile.md:79-97`）。
- 对 canonical Swift array 形状而言，adapter 的 outer outcome precedence 与 `ReleaseEvidenceRun.outcome` 一致：`fail` → `inconclusive` → `partial/not-run` → external 非 `exact_artifact` 的 `partial` → `pass`。Swift 语义在主工作树文件 `ReleaseEvidenceStore.swift:204-325`；adapter 对应逻辑在 `:630-658`。本结论不覆盖下述把 array 放宽为 object 的问题。
- candidate ID、artifact/context identity、Profile、contract version 和 delivery/final-validation 的字段级相等检查存在；P-01/D-01 的 heads、final tree、checker、scope、output、result 和 exit code 规则由 adapter/evaluator/fixture 共同覆盖。
- first/subsequent 的 `target_sequence`、baseline/previous receipt 的 stage、candidate、context、Profile、contract 和 `release_lineage` 字段相等性有检查；Boolean baseline shortcut 会被拒绝。重复 changed-surface、重复 evidence key、equal base/head with non-empty surface 和 unknown/ambiguous input 的既有负例通过。
- raw user text、note、full log 和未知 export 字段没有被复制到 Envelope；`MAIN_APP_STEP_ALLOWED_KEYS` 与非 claims 边界存在。
- fixture runner 的 inventory 固定为 52 Envelope + 24 Delta，并使用显式 `--as-of`；它没有上传、发布或修改 Product/Quality/Release authority。

这些是结构性正向结果，不抵消下面的 owner authenticity 和 fail-closed 缺口。

## Findings

### P0 — none

本轮范围内没有发现秘密泄露、破坏性写入、跨用户数据读取或会立即扩大外部权限的 P0 问题。

### P1-ARCH-01 — `SRC-MAIN-STORE` 仍是 caller-declared seam，伪造 source facts 可进入 `current-proof`

**证据：**

- adapter 的 `_source_pointer` 只对 `main_app_source` 的五个字段做 key、token、UUID、SHA-256 和 retention-class 检查，并由调用方提供 `record_id`、`operation_id` 和 digest（`scripts/release/kos_release_evidence_adapter.py:464-497`）。它没有读取或核对 `Diagnostics/v1/release-evidence/records.json`，也没有把 source digest 绑定到 `run.id`、export 原始 bytes 或 owner-generated receipt。
- `build_envelope` 把这一 caller-declared pointer 和 digest 直接放进每个非 `not-run` observation 以及 provenance (`:1144-1208`)。因此一个 syntactically valid pointer 同时成为 claim evidence ref、`provenance.source_ref` 和 `content_digest`。
- 主工作树的 Swift `ReleaseEvidenceExport` 只包含 schema/contract/recordType/run/outcome/nonClaims（`/Users/doubleshy0n/Dev/Universe Keyboard/Universe Keyboard/Services/ReleaseEvidenceStore.swift:432-452`）；`ReleaseEvidenceRun` 的 Codable 形状没有 `record_id`、`operation_id` 或 source digest（`:204-298`），store 也只是读写 archive（`:338-430`）。本轮 target 又没有这个 source 文件的稳定 commit identity。
- pinned evaluator 的 provenance 判定只检查 pointer/digest 是否 resolved 和时间是否 fresh（`/Users/doubleshy0n/Dev/kos-agent-kit/scripts/validate_release_evidence.py:829-843`）；`current-proof` 只组合 claim、candidate、delivery、final-validation、provenance 和 promotion 的输入状态（`:920-936`），不会 dereference source pointer。

**独立 adversarial probe：** 保持 fixture 的其它 pass 前提，只把 `main_app_source` 改为 `record_id=FORGED-SOURCE`、随机合法 UUID 和 `d`×64 digest。adapter 接受；pinned evaluator exit `0`；derived status 为 `current-proof`，生成的 source ref 为
`appdiag://release-evidence/FORGED-SOURCE/10000000-0000-4000-8000-000000000056;sha256=<d×64>;class=diagnostic-short`。

**影响：** 当前 package 没有可验证的 Main-App owner trust root。任何能构造 payload 的 caller 都能声明一个不存在或不对应 run 的 Main-App record，并让它满足当前 proof 的结构条件。Profile/Assignment 已要求 `REP-Q-01` 闭合前不得使用该 seam 作为 current-proof provenance（Profile `:56-65`；P1 Assignment `:74-79`、`:244-249`），但 adapter/evaluator 的执行路径没有把这个 stop boundary 变成 fail-closed guard。

**建议（本轮未实施）：** 由 release-evidence owner 先用独立 receipt 闭合 `REP-Q-01`，给出精确、稳定、可追溯的 source implementation identity，并由 owner 生成与 export/run 关系可验证的 immutable record/operation/digest binding。未能核对 owner receipt、目标存在性或内容 digest 时，不应让输出支持 `current-proof`；应保留为 unresolved/non-proof。该修复不应借机实施 P1-B 的 store/UI/retention 变更。

### P1-ARCH-02 — adapter 接受非 Swift Codable 的 `steps` object，绕过 canonical run/step seam

**证据：**

- Swift `ReleaseEvidenceRun` 明确定义 `var steps: [ReleaseEvidenceStep]`，decoder 也调用 `decode([ReleaseEvidenceStep].self, forKey: .steps)`（`ReleaseEvidenceStore.swift:204-298`）。
- Profile 要求 run/step nested fields closed to Main-App Codable shape（`docs/kos/release-evidence-profile.md:79-97`）。
- 但 adapter `_normalize_steps` 明确接受 `Mapping`，把 object 的 key/value 转换为 synthetic entries；`_canonical_main_app_outcome` 也对 Mapping 单独取 values（`scripts/release/kos_release_evidence_adapter.py:511-563`、`:630-658`）。因此这里的实际条件是 “array or object”，不是 canonical array。

**独立 adversarial probe：** 把一个可 current-proof 的 `run.steps` 从 Swift array 改为
`{"candidate_identity":"pass","changed_path_validation":"pass","affected_path_smoke":"pass"}`。adapter 接受，pinned evaluator exit `0`，derived status 仍为 `current-proof`。

**影响：** foreign producer、错误 serializer 或不符合 Swift wire shape 的数据可以跨过 Main-App source seam；outer outcome 仍能被 adapter 自己按 object values 重算，从而无法发现“不是 Main-App Codable export”这一事实。这个问题不是 outcome precedence 错误，而是 precedence 作用在错误输入形状上。

**建议（本轮未实施）：** P1-A 的 adapter 入口只接受 JSON array；每项再按 exact step keys/enum 做校验。若需要 object 形式，只能作为明确的内部 fixture builder 输入，并在进入 adapter canonical boundary 前转换且保留不可混淆的测试标记；同时加入 object-shape rejection fixture。

### P1-ARCH-03 — baseline/previous-target receipt 只有 shape/value binding，没有 target existence 或 owner authenticity

**证据：**

- `_baseline` 和 `_previous_target_receipt` 检查 exact keys、pointer grammar、candidate/artifact/context/stage/Profile/contract 以及 `release_lineage`（`scripts/release/kos_release_evidence_adapter.py:955-1096`）。这是有价值的字段绑定，但 `_pointer` 只执行正则匹配（`:402-408`），没有打开 `verification_ref`/`receipt_ref`、检查目标存在性、验证 digest 或确认 receipt 由指定 promotion owner 产生。
- `_promotion` 对 `target_binding=True` 直接用当前 caller 的 candidate 生成 target object（`:1099-1141`）。最终 Envelope 因而只保存 caller 提供/adapter 推导的 identity 值；它没有独立 target receipt 的 provenance。
- pinned evaluator 对 promotion 只使用 Envelope 内对象和 identity fields；它不会读取 review-record target。KOS contract 也明确 evaluator 不读目录、不联网，exit `0` 只代表结构有效（`/Users/doubleshy0n/Dev/kos-agent-kit/ops/release-evidence.md:152-158`）。

**独立 adversarial probe：**

- first external target：提供所有 candidate-bound baseline 字段，但把 `verification_ref` 改为一个不存在的 `opaque://...;sha256=<0×64>;class=review-record`；adapter 接受，evaluator exit `0`，derived status 为 `current-proof`。
- subsequent external target：提供不同 candidate、同 `release_lineage`、同 context/stage/Profile/contract 的 previous receipt，但把 `receipt_ref` 改为不存在的 `opaque://...;sha256=<1×64>;class=review-record`；adapter 接受，evaluator exit `0`，derived status 为 `current-proof`。

**影响：** first/subsequent 的逻辑关系本身有覆盖，但“显式 receipt object”在当前 package 中仍可由 caller 伪造；不存在的 review-record 不会形成 unresolved blocker。只要 downstream 把 `current-proof` 当作 current candidate proof 输入，就可能把假的 promotion history 当成真实历史。

**建议（本轮未实施）：** receipt 应由独立 owner 产生并带有可核验的 immutable record identity/digest；adapter 或其上游 handoff 必须在进入 current-proof boundary 前完成 target existence/content verification。验证不可用时保留 `pending`/`none` 或 unresolved，不能只依靠 pointer grammar。Boolean baseline rejection 应保留；不能用另一个 Boolean shortcut 替代 owner receipt。

### P1-ARCH-04 — `repo://` pointer grammar 接受 `..`，可以把 provenance 指向仓库外

**证据：**

- `POINTER_RE` 对 `repo://` 的 path 允许任意 `[A-Za-z0-9._/-]+`，包括 `..` 和重复分隔符（`scripts/release/kos_release_evidence_adapter.py:256-262`）；`_pointer` 只调用这个正则，没有 repo-relative canonicalization（`:402-408`）。
- Profile 明确要求 repository path 必须留在 repository 内；missing target、digest mismatch 或 inaccessible export 是 unresolved blocker（`docs/kos/release-evidence-profile.md:314-330`）。
- adapter 的 `_safe_relative_path` 对 changed surface 会拒绝 `..`，但该保护没有复用于 pointer grammar（`:1248-1265`）。

**独立 adversarial probe：** 把 candidate 的 `artifact_or_input_ref` 改为
`repo://../outside#artifact;sha256=<b×64>;class=release-candidate`。pointer syntax 校验通过，adapter 生成 Envelope，pinned evaluator exit `0`，derived status 为 `current-proof`。

**影响：** provenance 和 artifact/input ref 可能指向仓库外的路径；digest 仍只是 caller 声明的字符串，不能补救越界 target。这个路径同时削弱了 owner map、artifact identity 和 current-proof 的来源边界。

**建议（本轮未实施）：** 对 repo pointer 采用 canonical repository-relative path：拒绝 `..`、`.`、空 segment、重复 slash 和绝对路径；在已确定的 repo root 内核对 target regular file、anchor 和 digest。无法完成 dereference 时必须 fail closed，不得把“正则合法”视作已解析 provenance。

### P1-ARCH-05 — delta changed-surface 没有 canonical path，release dependency 变体可绕过全量/no-reuse 规则

**证据：**

- `_safe_relative_path` 只拒绝绝对路径、`..` 和空值，随后原样返回字符串；它接受 `.`、重复 slash 和 trailing slash（`scripts/release/kos_release_evidence_adapter.py:1248-1255`）。
- `_is_release_dependency_path` 只对原始字符串做 exact match/prefix match（`:1262-1265`）。所以 canonical `Universe Keyboard/Services/ReleaseEvidenceStore.swift` 和 `.kos/project.json` 会触发 release dependency，但非 canonical spelling 不一定会触发。
- Profile/Checklist 要求 concrete Main-App source-owner path 和 release dependency 触发 `full`/no reuse；ambiguous path 必须清空 reuse 并 stop（Profile `:145-157`；Checklist `:98-114`；P1 Assignment `:157-175`）。

**独立 adversarial probe：** 在同一 candidate/evidence 前提下，分别提交以下 changed surface：

| 输入 | 实测 delta 结果中的问题 |
|---|---|
| `.kos/project.json/.` | 被接受为 `delta`；`candidate_identity` evidence 仍可 reusable |
| `.kos//project.json` | 被接受为 `delta`；`candidate_identity` evidence 仍可 reusable |
| `Universe Keyboard/Services/ReleaseEvidenceStore.swift/.` | 被接受为 `triggered`；`candidate_identity` evidence 仍可 reusable |
| `Universe Keyboard//Services/ReleaseEvidenceStore.swift` | 被接受为 `delta`；`candidate_identity` evidence 仍可 reusable |

这些输入都不是 Profile 所说的 canonical path；source-owner 变体预期应触发全部 binding invalidation，而不是保留任何 candidate-bound evidence。

**影响：** attacker 或错误的 diff serializer 可以通过路径拼写变体让 owner/dependency 变化看起来像普通 delta，从而保留旧 evidence。单独的 plan 仍可能带 `stop_before_current_proof=true`，但它已经输出了不应被下游消费的 reusable keys；任何下游若按 reusable set 构建下一份 current-proof，就有错误复用路径。

**建议（本轮未实施）：** 在 dependency classification 前先 canonicalize 并严格验证 repo-relative changed path；任何无法证明 canonical identity 的 path 都返回 `full`、空 reuse、全部 invalidated 和 stop。针对 `.kos/project.json`、Main-App source-owner path、重复 slash、`.`、trailing slash 各加 negative fixture。

### P2-ARCH-06 — delta `base_sha`/`head_sha` 只做格式检查，没有 actual Git/diff 或 candidate-head binding

**证据：**

- `plan_delta` 对 `base_sha`/`head_sha` 调用 `_require_commit`，但后者只检查 commit 字符串格式；`DeltaPlan` 注释明确这两个值是 caller inputs，不代表 adapter 验证了 Git diff（`scripts/release/kos_release_evidence_adapter.py:1422-1435`、`:1438-1461`）。函数没有 `git cat-file`、`git diff base..head`、ancestor 检查，也没有要求 `head_sha == candidate.artifact_identity.source_commit` 或与 `candidate.candidate_head` 对齐。
- **独立 probe：** 对 docs-only surface 提供任意格式合法但不属于该 repo 的 `base_sha=a×40`、`head_sha=b×40`，结果为 `release_validation_profile=delta`、`ci_change_tier=docs_only`、三项 evidence 均 reusable、`stop_before_current_proof=false`。

**影响：** 只要上游把未经验证的 base/head 和 changed surface 传入，planner 可能把不存在或不对应实际 diff 的输入当作 dependency-closed reuse plan。由于 `plan_delta` 本身不是 evaluator 的 current-proof 输出，本项定为 P2；但若其 reusable set 被下游当作 proof 输入，风险会升级为当前证明错误。

**建议（本轮未实施）：** 让上游提供并绑定一个可验证的 diff receipt（真实 repo、base/head 存在、changed surface 来自该 diff、head 与 candidate identity 对齐）；或在未完成该验证时强制 `full`/空 reuse/stop。仅保留 40–64 hex 格式检查不足以称为 exact base/head identity binding。

### P3 — none

在本次限定的 package、source seam、delta 和 promotion 边界内，没有另列一个仅影响可读性或低风险 ergonomics 的 P3 finding。Swift `note` 的 Main-App 160 字节语义与 adapter 的较宽输入上限不进入本轮 P3：note 在进入 Envelope 前会被丢弃，未形成 current-proof 或隐私泄露路径；但如果未来要声称 wire-shape 完全等价，仍应补齐该边界。

## P1-A / P1-B 边界判断

- P1-A 的 adapter、fixture、runner、promotion/delta mapping 属于本轮审查范围。
- P1-B 的 Main-App Diagnostics UI、`records.json` persistence、retention、clear、migration/backfill 明确 deferred（P1 Assignment `:107-121`）。本轮没有把缺少 P1-B 当作实现失败，也没有建议通过修改 store/UI 来掩盖 P1-A source binding 缺口。
- 但 P1-A 仍必须尊重现有 Main-App owner seam；“不读取 store”可以是授权边界，不能同时把 caller-provided source pointer 当作已完成 owner proof。当前应保持 `REP-Q-01` blocker，而不是把 `SRC-MAIN-STORE` 文字名升级为事实来源。

## Release / authority boundary

本轮的 `76/76` fixture、`22` 项单测、Kit pin/tree digest、adapter digest 和 evaluator exit `0` 只证明可复现的结构化输入检查及其派生输出。它们**不**是：

- Product acceptance 或 Product Gate；
- Quality/Release gate 或 Release Pass；
- merge、commit、push 的授权或可合并结论；
- upload、Beta Review、TestFlight、App Store Connect、发布或外部动作授权。

Profile 和 Checklist 对 `current-proof` 也明确保留同一 non-claim（`docs/kos/release-evidence-profile.md:368-391`；`docs/RELEASE_CHECKLIST.md:116-121`）。本报告的 `Needs work` 是独立 Architecture Review 结果，不是任何 human Product/Quality/Release decision。

## 最终决定

| 维度 | 结果 |
|---|---|
| 六文件 exact digest | **Pass / match** |
| Fixed fixture report digest 与 76/76 | **Pass / match** |
| Pinned Kit commit/ancestor/clean/semantic/tree identity | **Pass / match** |
| 当前 P1-A architecture review | **Needs work** |
| 本轮是否获得 Product、Quality/Release、merge、push 或发布授权 | **否** |

在 P1-ARCH-01 至 P1-ARCH-05 至少闭合、P2-ARCH-06 的上游责任明确并取得新的 exact-digest 独立复核前，不应把本 package 标记为 Architecture Pass，也不应从其 green validator/fixture 结果推导任何 Release 或外部发布结论。
