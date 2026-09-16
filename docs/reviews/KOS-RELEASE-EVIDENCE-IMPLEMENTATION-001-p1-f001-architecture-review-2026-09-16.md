# KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001 P1 F-001 Architecture 独立审查

审查日期：2026-09-16（Asia/Shanghai）

审查角色：独立 Architecture and Knowledge Steward reviewer（fresh Lody runtime）

审查 session：`ae01c2c6-dbc7-4c00-acb1-53390d96503a`

审查 operation：`uk005-f001-architecture-review-20260916`

结论：**Request changes**

> 本报告是独立审查结果，不是 Product、Quality、Release Gate、TestFlight、App
> Store Connect、merge 或 Release 结论。由于当前 Lody session 未被识别为
> review-agent，唯一一次 `lody_review_submit` 返回 `REVIEW_RUN_NOT_FOUND`；因此
> 没有声称存在已接收的正式 Lody review receipt。

## 1. Exact package 与交接核验

审查对象为 F-001 的固定 13-file raw-byte package，顺序和成员由
[Preflight receipt](../evidence/kos-release-evidence-implementation-001-p1-f001-preflight-2026-09-16.md)
记录。审查 runtime 复算结果：

| 项目 | 值 | 结果 |
|---|---|---|
| Baseline / HEAD | `5692cf60c344d79b428d50430422a7c76832df06` / `5692cf60c344d79b428d50430422a7c76832df06` | match |
| 13-file ordered raw-byte package SHA-256 | `e931d2e71a10555b21d325420a71db8e373da6d2953d927be443d33d5cdaf4d4` | match |
| Preflight receipt SHA-256 | `ef56fe182c9b0f3f8551718c34310824ea3a86ddaadab03c2e60ad50fea8f031` | match |
| 工作树残余 | 4 个既有 mirror 修改、3 个 Assignment/Authorization/receipt 新文件 | 与交接说明一致 |

本轮未修改文件、未切换分支、未提交、未写入缓存，也未执行设备或发布服务操作。

审查结论产生后，执行者只为同步本报告结论更新了 Assignment、`ACTIVE_WORK.md`
和 Dashboard；这些文件属于审核包成员。因此本报告实际审查的 package 仍是上表
的 `e931…` 版本，状态同步后的当前 13-file package SHA-256 为
`37882cfd9a83e3e9affd151a70ab5ca1ab70268be79b15fbf516a210dbb317bc`。该新摘要
尚未被 Architecture 或 Quality reviewer 审查；若继续 remediation 或复审，必须
以新摘要重新建立交接，不得复用本报告的旧 package 结论。

## 2. F-001 Architecture 判断

### 已核实的 fail-closed 机制

- [`kos_release_evidence_adapter.py`](../../scripts/release/kos_release_evidence_adapter.py#L319)
  对解析值执行 `strip().upper()`，`UNKNOWN`、`TODO`、`TBD` 及其大小写/空白变体
  会被拒绝。
- 同一文件的 `_source_pointer` 使用 exact key set，并要求
  `source_identity == SRC-MAIN-STORE`；foreign identity、extra key 和 caller
  supplied binding 字段不能绕过解析（:538-560）。
- `MAIN_APP_SOURCE_BINDING_STATE` 是代码控制的 `unresolved` 状态；未验证时，
  passing source steps 被降为 `inconclusive`，不会由 payload 生成可支持
  `current-proof` 的结果（:1258-1266）。

因此，本审查没有发现历史 F-001 中“对小写 `unknown` fail-open”或“未限定
`SRC-MAIN-STORE`”的当前代码机制复现。

### Blocking finding — 持久化负向覆盖不足以支撑重新分类

**等级：P1 / blocking**

当前 focused test 与 fixture 只持久化了部分边界：

- focused test 的 unresolved 参数为 `UNKNOWN`、`unknown`、` UNKNOWN `、`Tbd`，
  见 [`test_kos_release_evidence_adapter.py`](../../scripts/release/tests/test_kos_release_evidence_adapter.py#L90)；
  fixture `UK-RE-FX-035` 与 `UK-RE-FX-048` 也只分别固定 `UNKNOWN` 与 `unknown`，
  见 [`kos_release_evidence_cases.json`](../../scripts/release/fixtures/kos_release_evidence_cases.json#L839)。
- focused test 只对 caller alias `binding_status` 做了拒绝断言，见
  [`test_kos_release_evidence_adapter.py`](../../scripts/release/tests/test_kos_release_evidence_adapter.py#L85)；
  没有持久化 `is_verified`、`verified` 等同类 caller alias 的负向覆盖。
- focused test 覆盖了 extra source key（:109-112），但没有固定 missing source
  key 的负向用例；本轮 Preflight 对 missing key、多个 alias 以及更多
  `TODO`/`TBD` 大小写组合的 probe 是 in-memory 的临时检查，不是可复用的
  test/fixture evidence。

**Failure scenario：** 后续执行者只运行当前 `25/25` focused tests 和
`76/76` fixture matrix 时，所有持久化检查仍为 green，但可能未执行
`main_app_source` 缺 key、`is_verified`/`verified` caller alias 或完整 unresolved
variant 集合；因此不能仅凭当前绿色结果证明每一条 F-001 exit boundary 都会在
Envelope 构建前 fail closed。把本轮临时 probe 写入 Preflight receipt 也不能替代
长期、可重复的负向测试。

**需要的收口：** 在保持 exact baseline、三文件 allowlist 和 content-free 边界的
前提下，补齐并持久化 F-001 所声明的 unresolved case/whitespace、missing/extra
source key、foreign/case-variant source identity，以及 caller-controlled
`binding_status`/`is_verified`/`verified` 等 alias 的拒绝用例；重新运行相同 pinned
fixture/evaluator checks，并对新的 exact package 重新进行 Architecture 与 Quality
审查。该建议没有在本轮实施。

## 3. Review 状态与下一步

| 项目 | 当前判断 |
|---|---|
| Architecture review | **Request changes**；上方 P1 blocking finding 未解决 |
| Quality review | **尚未开始**；按 Architecture → Quality 顺序停止在当前边界 |
| Assignment | 保持 `Active`；不能进入 `Reviewed` 或 `Closed` |
| Authorization | 保持 `active / consumed`；review finding 触发 revalidation，不扩大范围 |
| 实现文件 | 无修改；当前 baseline 的 adapter/test/fixture 仍与 `5692cf6` 字节一致 |
| Build 55 TD-003～005 | 保持 open；本轮未读取、未修改其状态或证据 |

本报告不把 Executor Preflight、KOS validator、历史 `REP-Q-01` 或本地 fixture
结果提升为 Architecture closure、Quality pass、Product Gate、Release Gate 或
Release authority。
