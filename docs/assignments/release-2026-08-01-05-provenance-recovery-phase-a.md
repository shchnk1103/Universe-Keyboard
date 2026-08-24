# Assignment: RELEASE-2026-0801-05-PROVENANCE-A — RIME Lua 与 Luna 有界来源恢复

**Policy version:** `1.0.0`
**Parent:** [`RELEASE-2026-0801-05`](release-2026-08-01-05-app-store-materials.md)

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Completed` — Phase A bounded exit reached; Product accepted the derived receipts as an external-candidate residual |
| **Phase** | Phase A 完成：只读/临时构建来源恢复；未改变任何分发产物 |
| **Non-claims** | `types.o` 没有官方 Boost.Regex tag 的精确字节匹配；Luna 是官方 base blob 加单行本地 URL 补丁而非全字节上游 blob；没有授权替换资源、重建/发布 Vendor、在线保存内容版权或关闭 `RELEASE-2026-0801-05` |
| **Next** | 无；内容版权与类别已由 Human 报告保存。不开 Phase B |
| **Residuals** | [`Phase A evidence`](../evidence/release-2026-08-01-05-provenance-recovery-phase-a-2026-08-23.md) · [`PD-RELEASE-2026-0801-05-PROVENANCE-A-ACCEPT`](../product-decisions/RELEASE-2026-0801-05-provenance-a-accept.md) |

---

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human Product Owner acting as Product Lead explicitly authorized Phase A provenance recovery and repository-document handoff suitable for later Grok reassignment, `2026-08-23 Asia/Shanghai`; the same Product Lead then invoked `/resume-codex` on session `01a022ac-c648-7c42-b5b1-b6e0048e33a6` in a Grok session, which is recorded below as Reassignment for the remaining Boost.Regex header check
- **Product Approver:** Human Product Owner acting as Product Lead

## Boundary

- **Scope:**
  - inspect the immutable pinned Vendor archive, retained local clean build trees, static-library members, symbols, metadata and existing receipts;
  - inspect upstream Git history/releases and build only a bounded candidate set in disposable locations when byte comparison is technically meaningful;
  - identify an exact source revision/archive for `librime-lua` and an exact upstream file/archive identity for bundled `Keyboard/Resources/luna_pinyin.dict.yaml`;
  - update Assignment, evidence, Active Work, Dashboard and navigation/handoff documents with observed facts and reproducible commands.
- **Non-goals:** no production Swift/config/resource behavior changes; no replacement of Luna files or generated RIME binaries; no mutation, repackaging, upload or publication of Vendor assets; no manifest change; no RC freeze; no App Store Connect answer; no legal conclusion.
- **Required Inputs:**
  - [`third-party notice provenance`](../evidence/release-2026-08-01-05-third-party-notice-provenance-2026-08-23.md);
  - [`RIME binary artifacts`](../architecture/rime-artifacts.md);
  - `config/rime-vendor-manifest.env` and the locally verified 12-framework Vendor;
  - current bundled Luna source file and its generated T9 provenance;
  - upstream project histories and release assets, treated as read-only evidence.

## Assignment

- **Domain Owner:** 🔧 RIME Platform Maintainer
- **Executor:** Current Grok task for the remaining Boost.Regex header-version check; previous Codex task completed the rest of Phase A
- **Environment Executor:** Current Grok task for read-only local inspection, disposable `/tmp` clones/builds and read-only upstream retrieval
- **Human Dependency:** Human Product Owner for App Store Connect content-rights/category save; Phase B remains unauthorized
- **Architecture Reviewer:** 🏛️ Architecture & Knowledge Steward
- **Quality Reviewer:** 🧪 Quality, Performance & Release Maintainer

## Gates

- **Entry Criteria:** Product authorization and all required Assignment fields are present; pinned Vendor verifies structurally; current repository inputs are preserved; investigation can proceed without modifying production artifacts.
- **Exit Criteria:** each track has either (a) an exact byte-bound upstream identity with reproducible receipt, or (b) a bounded no-match record naming searched inputs, limitations and the smallest Phase B decision; handoff is independently usable without chat history.
- **Stop Conditions:** a conclusion would require guessing a revision; comparison is invalidated by unknown compiler/build inputs; upstream retrieval needs credentials; a command would alter published assets or production resources; a Phase B rebuild/replacement becomes necessary; sensitive/private data would enter evidence.

## Reassignment

- **Previous Executor:** Codex task that completed Phase A Lua 9/10 object matching and the Luna derivation receipt
- **New Executor:** Current Grok task
- **Reason:** Human Product Owner handed the Codex session to Grok to finish the single remaining Boost.Regex `BOOST_RE_VERSION 500` header check
- **Effective date:** `2026-08-23 Asia/Shanghai`
- **Decision source:** Human Product Owner acting as Product Lead, via `/resume-codex 01a022ac-c648-7c42-b5b1-b6e0048e33a6`
- **Remaining work at reassignment:** exact SHA-256 match of `types.o` against an official Boost.Regex tag whose `config.hpp` declares `BOOST_RE_VERSION 500`
- **Outcome of this reassignment:** bounded no-match at the 1.88.0 (500) / 1.89.0 (600) header-version boundary; see evidence. No further header mixing is in scope.

## Handoff

- **Handoff Target:** Parent [`RELEASE-2026-0801-05`](release-2026-08-01-05-app-store-materials.md) for remaining App Store materials; no further Phase A action
- **Required Handoff Content:** exact current branch/worktree status; reading order; fixed hashes and revisions; commands already run; candidate range and exclusions; raw-result locations; remaining unknowns; next safe command; prohibited claims and Stop Conditions.
- **Revalidation Trigger:** Vendor tag/archive bytes, Luna resource bytes, upstream history, build toolchain, Assignment executor or authorized scope changes.

## Review Boundary

- Architecture review checks evidence/source-of-truth boundaries and whether any proposed Phase B would need an ADR.
- Quality review independently verifies exact-match claims and bounded-search reproducibility; Executor-recorded evidence alone cannot close the provenance residual.
- Product Lead accepted the no-match as a release residual under [`PD-RELEASE-2026-0801-05-PROVENANCE-A-ACCEPT`](../product-decisions/RELEASE-2026-0801-05-provenance-a-accept.md).
