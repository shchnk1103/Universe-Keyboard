# Product Decision: TD-012-OCTAGRAM-VENDOR-G1 — 可复现 iOS octagram Vendor 能力

**Decision ID:** `PD-TD-012-OCTAGRAM-VENDOR-G1`
**Lifecycle status:** `Recorded` — 授权 G1 vendor capability；不授权 grammar 模型或用户功能
**Date / timezone:** `2026-08-09 Asia/Shanghai`
**Parent debt:** [`TD-012`](../TECH_DEBT.md#td-012-optional-rime-grammar-model-万象-lmdg--gram-integration)
**Assignment:** [`TD-012-OCTAGRAM-VENDOR-G1`](../assignments/td-012-octagram-vendor-g1.md)

## Current Status (KOS 2.1 M-01)

| Field | Value |
|---|---|
| **Lifecycle** | `Recorded` — G1 Assignment **Closed** under this PD (2026-08-10) |
| **Phase** | G1 vendor capability **delivered and closed**; model G2+ still require new PD |
| **Non-claims** | No `.gram` download/deploy; no schema/UI/product feature; no claim of model quality, memory budget or App Store readiness |
| **Next** | None for G1. Optional model phases only with a new Product Decision under TD-012 |
| **Residuals** | Upstream stale GPL file header retained in provenance/notice; Jetsam measurement + G2–G6 remain TD-012 follow-on gates |

---

## Decision

Product authorizes a narrowly bounded G1 task to make a reproducible iOS vendor
artifact that can load the concrete `octagram`/`grammar` RIME module.

1. **Source basis:** use `lotem/librime-octagram` at relicense merge commit
   `bfb168ca33d8b372596fdf2007933f3da1cf360e` or a separately audited descendant.
   Preserve the BSD-3-Clause notice and record the relicense PR, merge commit and
   stale GPL file-header residual in the artifact provenance.
2. **Product scope:** G1 proves only vendor/module capability. It may build, link,
   publish and verify a new immutable vendor artifact; it must not obtain, package,
   download, deploy or reference a `*.gram` model.
3. **Safety boundary:** the Main App remains the only deployment owner; the Keyboard
   Extension remains session-only. Existing basic input and Lua behavior must stay
   available if the new artifact or module is unavailable.
4. **Review:** Architecture & Knowledge Steward and Quality, Performance & Release
   Maintainer provide independent conclusions before the task can move from
   `Completed` to `Reviewed`/`Closed`.

## Non-goals

- User-facing “整句增强” setting, catalog item, download, progress, uninstall or copy.
- Any `.gram` content, filename, size, App Group placement or schema patch.
- Automatic enablement for 万象、雾凇、九键或其他方案。
- Accepting upstream source evidence as a legal opinion or App Store release approval.

## Authorization source

Human Product Lead, in-session `2026-08-09 Asia/Shanghai`:

- accepted the upstream relicense record as the G1 vendor-artifact source basis;
- accepted G1-only scope (no model / no user feature);
- directed the completed 万象 base-scheme task to release its Active Work slot for
  this dedicated G1 Assignment;
- named the independent Architecture and Quality reviewer roles above.

## Revalidation triggers

This decision must be revisited if the octagram source/provenance changes, a model
file enters scope, a runtime boundary changes, the artifact cannot be reproduced,
or Architecture/Quality identifies a blocking residual.
