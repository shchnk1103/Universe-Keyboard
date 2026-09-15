# KOS Release-Evidence Implementation 001 — P1-A Quality / Performance / Release Review

审查日期：2026-09-14
审查工作树：/private/tmp/universe-keyboard-kos-upgrade-uk-005
审查基线 HEAD：3139f8d3bdb6be6622504ea731988f42681896fb
审查对象：仅 package digest 82a2061cf277ecf248d521f8f2f532ad404e84f6db8c677dd5d3877abc795242

本报告是独立 Quality / Performance / Release review。审查期间没有修改六文件实现包、fixture、Profile、Checklist 或 /Users/doubleshy0n/Dev/Universe Keyboard 主工作树；唯一写入的是本报告。没有 commit、push、merge 或发布动作。

## 结论

**Needs work。**

六文件原始字节串接的 exact digest 与声明一致，固定 receipt 与新生成的 76-case matrix 也一致通过；但是对当前 package 做内存级对抗性复核发现两个 P1 实现问题：

1. delta reuse 会把大小写变体的 unknown / tbd 等未解析标量当作可复用绑定，并返回 stop_before_current_proof=false。
2. repo:// 指针接受 .. 穿越和绝对路径形态；这些指针随后仍可被 pinned evaluator 推导为 current-proof。

因此，本 package 不能以当前状态通过 P1-A 的独立退出审查。此结论只针对当前 exact package，不是对 Product、Quality/Release gate、merge、push 或发布授权的判断。

## Exact identity verification

### 六文件 hash

按用户给定顺序、逐文件原始字节读取，结果如下：

| 顺序 | 文件 | 期望 SHA-256 | 实际 SHA-256 | 结果 |
|---:|---|---|---|---|
| 1 | scripts/release/kos_release_evidence_adapter.py | 9e02afa93c4c9f91f7dcdbabe6ad5b4e9c4da6aef5f75ad4770dfa4a6bca2608 | 9e02afa93c4c9f91f7dcdbabe6ad5b4e9c4da6aef5f75ad4770dfa4a6bca2608 | match |
| 2 | scripts/release/run_kos_release_evidence_fixtures.py | 7fe337bcc0b4585ec58b8415ff565be01ffc32dfc6351d9665e483f74c16c499 | 7fe337bcc0b4585ec58b8415ff565be01ffc32dfc6351d9665e483f74c16c499 | match |
| 3 | scripts/release/fixtures/kos_release_evidence_cases.json | c5c1aceacb93aca01a8be08d739f9847b4410f0c997e5e2a9e1b4a5051b38921 | c5c1aceacb93aca01a8be08d739f9847b4410f0c997e5e2a9e1b4a5051b38921 | match |
| 4 | scripts/release/tests/test_kos_release_evidence_adapter.py | 637c34282c0b3f9e5b9163e4f4c27b323dec5ebbd7404c628bab3805c64a70ac | 637c34282c0b3f9e5b9163e4f4c27b323dec5ebbd7404c628bab3805c64a70ac | match |
| 5 | docs/kos/release-evidence-profile.md | 6a1da162be5093b3d2543b274555d750957bc7b1b739954fb0fb94e82cdcd73b | 6a1da162be5093b3d2543b274555d750957bc7b1b739954fb0fb94e82cdcd73b | match |
| 6 | docs/RELEASE_CHECKLIST.md | 04af53964d0381f7ccf59a428eb985259a9f9be55d8cb35e0223877301ccff7c | 04af53964d0381f7ccf59a428eb985259a9f9be55d8cb35e0223877301ccff7c | match |

六文件按上述顺序无分隔符拼接后的实际 digest：

82a2061cf277ecf248d521f8f2f532ad404e84f6db8c677dd5d3877abc795242

复现命令：

~~~bash
cd /private/tmp/universe-keyboard-kos-upgrade-uk-005
sha256sum \
  scripts/release/kos_release_evidence_adapter.py \
  scripts/release/run_kos_release_evidence_fixtures.py \
  scripts/release/fixtures/kos_release_evidence_cases.json \
  scripts/release/tests/test_kos_release_evidence_adapter.py \
  docs/kos/release-evidence-profile.md \
  docs/RELEASE_CHECKLIST.md

python3 -c 'from hashlib import sha256; from pathlib import Path; paths=("scripts/release/kos_release_evidence_adapter.py","scripts/release/run_kos_release_evidence_fixtures.py","scripts/release/fixtures/kos_release_evidence_cases.json","scripts/release/tests/test_kos_release_evidence_adapter.py","docs/kos/release-evidence-profile.md","docs/RELEASE_CHECKLIST.md"); h=sha256(); [h.update(Path(path).read_bytes()) for path in paths]; print(h.hexdigest())'
~~~

## Fixture and pinned-source evidence

### Fixed receipt

独立读取并重新计算固定报告：

| 项目 | 结果 |
|---|---|
| 文件 | /private/tmp/uk-kos-kos-fixtures-fix9/report.json |
| SHA-256 | db846cfd8f1220fdc23c039c05aa7d755dba80747da1a6cbad822561151f0a61，match |
| Envelope | 52/52 passed，0 failed |
| Delta | 24/24 passed，0 failed |
| 总计 | 76/76 passed，0 failed |
| fixture ID inventory | exact；UK-RE-FX-001..052、UK-RE-DELTA-001..024 |
| receipt pinned HEAD | f5c88d57f599d7ef352322ea7664f637fb288d60 |
| candidate tree | actual/expected 均为 fec6889e81ea0807b284de45027e0270a70938e220041a8c367fd41a081a88c9 |

### 独立验证 /Users/doubleshy0n/Dev/kos-agent-kit

没有只接受 receipt 的叙述；直接检查了：

- HEAD = f5c88d57f599d7ef352322ea7664f637fb288d60；
- implementation commit 8e55551a3b56b57e7fc5ab5544d653f9c6854df9 与 adoption/HEAD 都是有效 commit；
- git -C /Users/doubleshy0n/Dev/kos-agent-kit merge-base --is-ancestor 8e55551a3b56b57e7fc5ab5544d653f9c6854df9 f5c88d57f599d7ef352322ea7664f637fb288d60 返回 0；
- git -C /Users/doubleshy0n/Dev/kos-agent-kit status --porcelain 为空；
- 10 个 pinned manifest 文件原始字节串接的 candidate tree digest 为 fec6889e81ea0807b284de45027e0270a70938e220041a8c367fd41a081a88c9；
- contract source、schema、evaluator 的直接 SHA-256 分别为：
  - f7ec8d9363cc37e53201e8bf990af80ba77fc9f88b7f78371d2c39f453a78673
  - 4e48bcf127edb87e67c4d390a3baec93af26ef72aa251e8172cb1044dca893ce
  - a45145681306c2da581f1054f002b7becd909d1bb4a8329ad14892f17839b9d9

对应 runner 的独立校验路径为 /private/tmp/universe-keyboard-kos-upgrade-uk-005/scripts/release/run_kos_release_evidence_fixtures.py:563-634；其确实检查 commit、祖先关系、clean worktree、candidate tree 和三个 semantic digest。

### 新生成 matrix

为避免把固定 receipt 当作唯一执行证据，使用新的临时目录重新执行：

~~~bash
cd /private/tmp/universe-keyboard-kos-upgrade-uk-005
PYTHONPYCACHEPREFIX=/private/tmp/uk-kos-quality-review-20260914.EHTC2J/pycache \
python3 scripts/release/run_kos_release_evidence_fixtures.py \
  --kos-kit-root /Users/doubleshy0n/Dev/kos-agent-kit \
  --work-dir /private/tmp/uk-kos-quality-review-20260914.EHTC2J/fix9-matrix \
  --output /private/tmp/uk-kos-quality-review-20260914.EHTC2J/fix9-matrix-report.json
~~~

结果：

- 新报告 SHA-256：5e651f3d994375f977b038df41e5e942357b3ef44f83f2d6e1829a0fe2331773；
- Envelope 52/52、Delta 24/24、总计 76/76；
- inventory exact 为 true；
- 52 个 evaluator invocation 都带显式 --as-of 2026-09-14T12:00:00+08:00；
- 14 个 adapter-only case 仍然记录了 adapter command；负例没有被错误地送入 evaluator；
- runner 记录的 adapter SHA 与当前 exact package 的第一个文件一致。

matrix 覆盖了 invalid JSON/schema/policy/as-of、pending/none/comparator、first/subsequent、future/stale/expired、P-01/D-01、candidate/source/lineage、Boolean baseline、unused alias、unknown field、unsafe/empty/equal/duplicate changed surface 等固定负例。UK-RE-FX-046（Boolean baseline）和 UK-RE-FX-047（unused baseline verification alias）均通过，未发现它们在当前固定 matrix 中形成伪证据。

## Verification matrix

| 检查 | 命令/范围 | 结果 |
|---|---|---|
| focused release tests | PYTHONPYCACHEPREFIX=... python3 -m unittest discover -s scripts/release/tests -p test_*.py -v | 22/22，exit 0 |
| CI classification tests | PYTHONPYCACHEPREFIX=... python3 -m unittest discover -s scripts/ci/tests -p test_*.py -v | 12/12，exit 0 |
| CI shell matrix | bash scripts/ci/tests/test_kos_trigger_paths.sh；bash scripts/ci/tests/test_verify_final_gate.sh | 两项均 exit 0 |
| Python syntax | release adapter、fixture runner、focused tests、CI classifier、Markdown link checker 的 python3 -m py_compile | exit 0 |
| fixed matrix | fixed /private/tmp/uk-kos-kos-fixtures-fix9/report.json | 76/76 |
| fresh matrix | 新 /private/tmp/uk-kos-quality-review-20260914.EHTC2J/fix9-matrix | 76/76 |
| fixture ID inventory | runner 固定顺序检查 + 独立解析 | exact |
| changed-path whitespace | tracked diff git diff --check HEAD -- .；五个 untracked package file 用 git diff --no-index --check /dev/null <path> | 无 whitespace diagnostic；untracked --no-index 的 exit 1 仅表示与 /dev/null 有差异，stdout/stderr 均为空 |
| Swift delta | git diff --name-only HEAD -- '*.swift' 与 status 检查 | 无 Swift 文件改动 |

## Findings

### P0 — none

没有发现 P0。

### P1-01 — delta reuse 接受大小写变体的未解析标量

**位置：**

- /private/tmp/universe-keyboard-kos-upgrade-uk-005/scripts/release/kos_release_evidence_adapter.py:307-315 的 _token 只对精确大小写的 UNKNOWN、TODO、TBD 做 unresolved 判断；
- /private/tmp/universe-keyboard-kos-upgrade-uk-005/scripts/release/kos_release_evidence_adapter.py:1622-1648 用 _token 解析 delta candidate；
- /private/tmp/universe-keyboard-kos-upgrade-uk-005/scripts/release/kos_release_evidence_adapter.py:1340-1361 用 _token 解析 evidence key、candidate ID 和 comparison basis；
- /private/tmp/universe-keyboard-kos-upgrade-uk-005/scripts/release/kos_release_evidence_adapter.py:1393-1419 的 _evidence_is_reusable 只做相等、identity、freshness 比较，没有再次调用大小写不敏感的 resolved 检查。

Pinned evaluator 则在 /Users/doubleshy0n/Dev/kos-agent-kit/scripts/validate_release_evidence.py:251-256 以 strip().upper() 判断 unresolved，并在 :546-565、:589-606 将 unresolved scalar 阻断为 non-comparable/none。也就是说，adapter 与 evaluator 对同一 unresolved token 的边界不一致。

**只读内存 probe：**

从当前 fixture 的 delta_candidate 深拷贝，在 candidate 与全部 evidence 的 candidate_id 或 comparison_basis 同时替换，再将 changed_surface 设为 ["docs/RELEASE_CHECKLIST.md"]，调用 adapter.plan_delta。结果：

~~~text
candidate_id=unknown  -> profile=delta, reusable=3, invalidated=0, stop=false
candidate_id=Unknown  -> profile=delta, reusable=3, invalidated=0, stop=false
candidate_id=tbd      -> profile=delta, reusable=3, invalidated=0, stop=false
candidate_id=Tbd      -> profile=delta, reusable=3, invalidated=0, stop=false
candidate_id=UNKNOWN  -> profile=full,  reusable=0, invalidated=3, stop=true
candidate_id=TBD      -> profile=full,  reusable=0, invalidated=3, stop=true
comparison_basis=unknown -> profile=delta, reusable=3, invalidated=0, stop=false
~~~

只替换第一条 evidence 的 evidence_key 为 unknown 时，结果仍为 profile=delta、reusable=["EVIDENCE-AFFECTED-SMOKE-56","EVIDENCE-CHANGED-PATH-56","unknown"]、stop=false。这不是仅仅的输出大小写问题，而是 reuse plan 将 unresolved scalar 当作可继续使用的 evidence identity。

另外，构造 Envelope 时把 Main-App run、candidate、delivery、final-validation 的 candidate_id 同时设为 unknown，adapter 返回 accepted=true；pinned evaluator 随后返回 derived_status=none，理由明确包含 candidate.candidate_id is unresolved。因此本轮没有观察到 evaluator 直接把该 Envelope 误判成 current-proof，但 adapter 已经违反了 Profile 对 unresolved binding 的 fail-closed 要求；delta plan 的 stop=false 仍会给下游错误的“可复用且无需停住”信号。

**影响：**

Profile 要求 candidate、claim、comparison basis 任何 binding absent/unknown/mismatched 时不能静默升级或继续复用（release-evidence-profile.md:408-424）。当前实现会在审查/重跑边界把未解析标量包装成正常 token，可能携带旧 evidence 进入后续 current-proof 输入路径，增加伪证据和审计误判风险。

**修复方向：**

统一所有 token-bearing identity/binding 的 unresolved 语义，至少对 UNKNOWN/unknown/Unknown/TBD/tbd 以及允许的空白变体采用大小写不敏感、显式 allowlist；在 reuse 前分别验证 current candidate、每条 evidence 的 candidate_id、comparison_basis、evidence_key，并补充 adapter 与 delta 的 case-variant negative tests。allow_unknown 只能在明确允许 not-run 的字段生效。

### P1-02 — repo pointer grammar 接受路径穿越，且可被推导为 current-proof

**位置：**

- /private/tmp/universe-keyboard-kos-upgrade-uk-005/scripts/release/kos_release_evidence_adapter.py:256-262 的 POINTER_RE 允许 repo path 中出现任意 .、.. 和 /；
- /private/tmp/universe-keyboard-kos-upgrade-uk-005/scripts/release/kos_release_evidence_adapter.py:402-408 的 _pointer 只做正则匹配，没有对 repo path 做绝对路径或 traversal 检查；
- /private/tmp/universe-keyboard-kos-upgrade-uk-005/docs/kos/release-evidence-profile.md:314-328 明确要求 repository path 必须留在 repository 内。

**只读 probe：**

把当前 fixture 的 candidate.artifact_or_input_ref 分别替换为以下值后调用 build_envelope，再以 2026-09-14T12:00:00+08:00 调用 pinned evaluator：

~~~text
repo://../../private#secret;sha256=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa;class=release-candidate
repo:///etc/passwd#x;sha256=bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb;class=diagnostic-short
repo://foo/../bar#x;sha256=cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc;class=release-candidate
~~~

三种输入均为 adapter_accepted=true，并且三种结果均为 derived_status=current-proof。没有读取或写入这些路径；这是对字符串 grammar 和 evaluator binding 的验证。

**影响：**

这违反了 Profile 的 repo-relative pointer boundary。即使 evaluator 当前不 dereference 该路径，Envelope 仍把越界 source pointer 作为 candidate/artifact provenance 接受，并允许 current-proof 派生，削弱 source provenance 的可执行性和审计可靠性。

**修复方向：**

按 scheme 解析 pointer，而非只用一条正则；对 repo:// 的 path 明确拒绝绝对路径、空 segment、./../ traversal，并在必要时做 canonical repository-relative containment 检查。对 appdiag operation UUID 也应使用实际 UUID 校验，而不是仅允许长度为 36 的 [0-9a-f-] 字符串。补充 traversal、absolute-path、非 canonical UUID 的 adapter/evaluator negative tests。

### P2-01 — candidate/provenance adapter input 存在静默丢弃的未约束字段

**位置：**

- /private/tmp/universe-keyboard-kos-upgrade-uk-005/scripts/release/kos_release_evidence_adapter.py:684-726 的 _candidate 没有对输入 mapping 做 exact key closure；
- /private/tmp/universe-keyboard-kos-upgrade-uk-005/scripts/release/kos_release_evidence_adapter.py:1194-1209 的 provenance_input 只读取已知字段，未拒绝其他字段。

**只读 probe：**

在 fixture base_input 的 candidate 和 provenance 同时加入 raw_user_input="SENSITIVE" 后，build_envelope 返回 accepted=true；输出 contains_raw_user_input=false，说明本次 probe 没有观察到该字段泄漏。但它被静默接受并丢弃，而不是被 fail-closed 拒绝。

这与当前已经对 Main-App wrapper、identity、receipt 和 delta evidence tuple 实施的 exact-key 检查不一致。它目前没有直接绕过 pinned evaluator 的证据，因此定为 P2，而不是 P1。

**修复方向：**

为 adapter root input、candidate input、provenance input 建立明确的 required/optional allowlist；未知字段应报告 unsupported 并停止。保持 raw keyboard/user/host data 的输入边界可审计，而不是依赖“最终没有被复制”这一隐式投影行为。

### P2-02 — ci_change_tier 名称/文档与实际 repository classifier 不一致

**位置：**

- Profile 声明 ci_change_tier 保持 repository classifier 的 docs_only/full boundary（docs/kos/release-evidence-profile.md:145-156）；
- repository source of truth 的 docs/** 规则是 docs_only（docs/CI_CHANGE_CLASSIFICATION.md:13-21）；
- adapter 仅把 docs/RELEASE_CHECKLIST.md 视为 docs-only（kos_release_evidence_adapter.py:244-253、:1258-1265），并在 :1577-1587 计算自己的 tier。

同一只读输入 changed_surface=["docs/kos/release-evidence-profile.md"] 的结果是：

~~~text
repository_classifier=docs_only
repository_requires_full=false
release_adapter_ci_change_tier=full
release_validation_profile=full
~~~

这是偏保守的差异，不是本轮发现的错误收窄：当前 exact package 本身含 scripts/release/**，真实 repository change 仍应走 full；adapter 也没有把敏感路径降成 docs-only。问题在于字段名和文档会让下游把 release-specific guard 当成 repository CI tier，或反向误读 CI 结果。

**修复方向：**

二选一并加 parity test：要么让 ci_change_tier 调用/复用 repository classifier；要么把字段改名为 release-specific guard（例如 release_ci_guard_tier）并在 Profile/Checklist/runner report 中明确两者不能互换。保持 scripts/ci/**、workflow、未知路径的 full 行为。

### P3 — none

没有发现 P3。

## Boolean baseline、receipt ref 与负例边界

本轮固定 matrix 明确覆盖并通过：

- UK-RE-FX-046：Boolean baseline shortcut 被 adapter 拒绝；
- UK-RE-FX-047：未使用的 baseline_verification_ref alias 被拒绝；
- external first/subsequent 的 baseline/history precedence；
- P-01/D-01 的 missing/mismatch/fail/unresolved receipt；
- changed-surface 的 unsafe、empty、equal-head、duplicate、unknown path。

没有发现把 Boolean baseline、未使用 receipt ref 或 narrative field 当作独立验证证据的当前 package 行为。上面的 P1 findings 是新增的、固定 76-case 未覆盖的 adversarial input variants。

## Gate and scope boundary

本报告不能、也没有把以下结果解释为授权：

- 22/22 focused release tests、12/12 CI tests、shell checks、py_compile 或 76/76 fixture/evaluator green；
- exact package digest match、pinned Kit clean/ancestor/tree/semantic digest match；
- 任意 current-proof derived status；

它们都不是 Product acceptance、Quality/Release gate pass、merge approval、push approval、commit approval 或 App Store/TestFlight/正式 Release authorization。按照本轮 scope，以下内容未执行、应保持 UNKNOWN/未验证：

- Swift/KeyboardCore、RimeBridge、App/Keyboard 的构建和测试；
- 真机、性能、内存、签名、archive/export；
- Product Gate、Quality/Release Gate、Beta Review、TestFlight、App Store 或外部发布流程；
- commit、push、merge 和远端 hosted run。

## Release decision

**Needs work — 不通过本轮 P1-A independent implementation exit review。**

建议先修复 P1-01 与 P1-02，并为其新增固定负例及 adapter/evaluator 边界测试；随后重新生成新的 matrix 和 exact-digest review。P2-01/P2-02 应在同一修订或后续明确收口，但不应被当前 green receipt 掩盖。

本轮仅新增本审查报告；不需要、也没有更新 CHANGELOG.md 或架构文档。
