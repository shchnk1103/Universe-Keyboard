# Product Decision: CODEX-GITHUB-AUTH-DIAG-001 — GitHub CLI 双环境诊断

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "PD-CODEX-GITHUB-AUTH-DIAG-001",
  "record_type": "decision",
  "title": "Document Codex GitHub CLI sandbox false-negative diagnosis",
  "status": "accepted",
  "updated_at": "2026-08-28T18:45:00+08:00",
  "revalidation_triggers": ["diagnostic_behavior_changed", "codex_sandbox_changed", "github_cli_changed"],
  "decision": {
    "authority_role": "Human Product Owner",
    "decision_source": "in-session 2026-08-28 Asia/Shanghai request to document the repeated false token-invalid diagnosis under KOS 2.2",
    "scope": "Publish a privacy-safe runbook and dual-environment evidence so future agents distinguish token expiry from sandbox credential or network visibility failures",
    "outcome": "Authorize docs-only runbook, routing, KOS records, validation and publication on the existing draft PR branch",
    "expires_at": null
  }
}
```

## Current Status

| Field | Value |
|---|---|
| Status | accepted |

---

## Decision

记录本次 GitHub CLI 认证误判，并建立可重复使用的双环境诊断协议。未来 AI 不得仅凭 Codex 沙箱内 `gh auth status` 的 `token invalid` 文案要求 Human 反复登录。

## Non-goals

- 不记录或输出 token、一次性登录码、Keychain 内容或代理凭据。
- 不把 Loon、热点代理或 GitHub 状态猜测成根因。
- 不自动修改代理、钥匙串、GitHub 账号或系统网络设置。
- 不授权新的 push、PR、merge 或 Release 动作；这些动作仍需各自当前授权。
