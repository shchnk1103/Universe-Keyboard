# REP-Q-01 provenance receipt — 2026-09-15

> 状态：`REP-Q-01 Closed`。
>
> 本记录只闭合“明确 final SHA 后保存实际 base/head 的 CI/lightweight provenance”残差；不构成 Product Gate、Quality Pass、Release Pass、App Store Connect、TestFlight、真机验收、merge 或发布授权。

## 1. Exact candidate provenance

| Field | Value |
|---|---|
| Assignment | [`RELEASE-EVIDENCE-PROMOTION-001`](../assignments/release-evidence-promotion-001.md) |
| Authorization | [`AUTH-RELEASE-EVIDENCE-PROMOTION-001`](../authorizations/AUTH-RELEASE-EVIDENCE-PROMOTION-001.md) |
| Candidate source / local candidate | `ad39f443b7f77d96c28359bd652356a89bb173de` |
| Base SHA | `e7b2f602684553fc9b31cf32109839a3d6141e0d` (`origin/main` at branch creation) |
| Candidate tree | `f7ba5ae358538c8220a8e3d08cc1c2172eec8366` |
| Candidate branch | `codex/rep-q-01-close` |
| Published head at hosted run | `ad39f443b7f77d96c28359bd652356a89bb173de` |
| Hosted CI head | `ad39f443b7f77d96c28359bd652356a89bb173de` |
| Hosted CI result | `green` |
| Coverage | `same-head` |
| Pull request | `none`（本次未创建 PR） |
| Merge / Release action | `not performed` |

这里的 candidate source 是被完整 hosted `build-and-test` 覆盖的代码候选。当前 receipt 是 hosted run 完成后的 docs-only provenance writeback；它不把 writeback 文档提交重新描述成已执行 full build 的另一份候选。

## 2. Hosted CI evidence

触发原因：仓库的 `push` 只监听 `main`，功能分支没有创建 PR 的授权；因此使用现有 [`Swift 6 Quality`](https://github.com/shchnk1103/Universe-Keyboard/actions/workflows/swift6-quality.yml) 的 `workflow_dispatch`，指定 `ref=codex/rep-q-01-close` 和精确 `base_sha=e7b2f602684553fc9b31cf32109839a3d6141e0d`。

Hosted run：[`34865917284`](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/34865917284)。API 返回的 `headSha` 为 `ad39f443b7f77d96c28359bd652356a89bb173de`，与 Candidate source 完全一致。

| Job | Job ID | Result |
|---|---:|---|
| `classify-change` | `104049604889` | `success` |
| `lightweight-checks` | `104049649958` | `success` |
| `build-and-test` | `104049705511` | `success`（11m55s） |
| `final-quality-gate` | `104054031139` | `success` |

`build-and-test` 的成功步骤包括 pinned RIME artifacts、Swift formatting、KeyboardCore、RimeBridge iOS Simulator、App/Keyboard contracts、Debug build 和 Release build。测试输出保留了既有条件性 skipped 用例及其原因；它们没有被本 receipt 改写成已执行。

## 3. Local revalidation evidence

本地使用显式 UDID `8C2943AC-AC97-432F-ACEE-BE3DA2B9ACB2`（iPhone 17 Pro / iOS 26.0）作为本机已安装的 CI 等价 Simulator；默认的 `name=iPhone 17 Pro` 在本机因 latest OS 匹配问题无法解析。

| Area | Result |
|---|---|
| Swift format hard gate | 4 个变更 Swift 文件均 `lint --strict` 通过 |
| Release evidence Python tests | `22/22` passed；`py_compile` passed |
| KeyboardCore | `1125/1125` passed |
| RimeBridgeTests | `101` passed，`20` conditional skipped，`0` failures |
| UniverseKeyboardTests | `369` passed，`9` conditional skipped，`0` failures |
| KeyboardTests | `11/11` passed |
| Debug build | `BUILD SUCCEEDED` |
| Release build | `BUILD SUCCEEDED` |
| Lightweight contract | changed Markdown links、12 CI tests、final gate matrix、KOS trigger paths 均 PASS |

最终 lightweight 命令为：

~~~bash
bash scripts/ci/run_lightweight_checks.sh \
  e7b2f602684553fc9b31cf32109839a3d6141e0d \
  ad39f443b7f77d96c28359bd652356a89bb173de
~~~

本地隔离 worktree 初始没有 tracked/available 的 RIME Vendor 目录；验证时使用主工作树中已按 pinned manifest/receipt 核对的同一份本地框架建立临时、未跟踪符号链接，`bash scripts/ensure_rime_vendor.sh verify` 通过，随后在提交前移除该链接，未将二进制或链接纳入候选提交。Hosted CI 独立执行 `fetch`，不依赖该临时链接。

## 4. Candidate scope

Candidate source commit 只包含以下 18 个 release-evidence 相关文件或对应文档 hunk；主工作树其他脏改动未带入：

- `Universe Keyboard/Services/ReleaseEvidenceStore.swift`
- `Universe Keyboard/Views/Diagnostics/ReleaseEvidenceView.swift`
- `Universe Keyboard/Views/Settings/DiagnosticsSettingsView.swift`
- `UniverseKeyboardTests/ReleaseEvidenceStoreTests.swift`
- `scripts/release/release_evidence.py`
- `scripts/release/tests/test_release_evidence.py`
- `docs/RELEASE_CHECKLIST.md`
- `docs/architecture/decisions/0027-enterprise-local-diagnostic-observability.md`
- `docs/architecture/decisions/0035-release-evidence-accumulation-and-promotion.md`
- `docs/assignments/release-evidence-promotion-001.md`
- `docs/authorizations/AUTH-RELEASE-EVIDENCE-PROMOTION-001.md`
- `docs/product-decisions/RELEASE-EVIDENCE-PROMOTION-001-authorization.md`
- `docs/kos/kos-improvement-suggestions-public-beta-release-2026-09-13.md`
- `docs/reviews/release-evidence-promotion-001-architecture-review.md`
- `docs/reviews/release-evidence-promotion-001-architecture-rereview.md`
- `docs/reviews/release-evidence-promotion-001-quality-review.md`
- `docs/reviews/release-evidence-promotion-001-quality-rereview.md`
- `CHANGELOG.md` 的 release-evidence 条目 hunk

## 5. Closure boundary

- `REP-Q-01` 现在有可复核的 final candidate SHA、真实 base/head、published/hosted head、same-head coverage 和 hosted result。
- `REP-P1-01`–`REP-P2-02` 的独立 Architecture/Quality re-review 结论保持不变；Quality re-review 仍是有界的 Conditional Accept。
- Proposed ADR 0035 仍是 Proposed；下一步由 Human Product Owner 单独决定是否纳入日常发布合同。
- 本记录没有生成 archive/export、签名、dSYM、设备、App Store Connect、TestFlight、Beta Review 或 external distribution 证据。
- 所有记录和实现保持 content-free：不保存用户输入、候选文字、宿主文字、词典、完整日志、archive 内容或凭证。

因此，本 receipt 只支持工程残差 `REP-Q-01 = Closed`，不改变任何更高层级的人工或外部发布门禁。
