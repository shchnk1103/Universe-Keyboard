# Evidence: CODEX-GITHUB-AUTH-DIAG-001 — 主机授权对照

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "EVIDENCE-CODEX-GH-AUTH-HOST-20260828",
  "record_type": "evidence",
  "title": "Authorized host GitHub CLI authentication comparison",
  "status": "current",
  "updated_at": "2026-08-28T18:45:00+08:00",
  "revalidation_triggers": ["codex_sandbox_changed", "github_cli_changed", "credential_visibility_changed", "host_network_changed"],
  "evidence": {
    "provenance": "executor_recorded",
    "environment_id": "ENV.CODEX_HOST_AUTHORIZED",
    "assignment_ref": "CODEX-GITHUB-AUTH-DIAG-001",
    "operator_ref": "Current Codex session with Human authorization",
    "reviewer_ref": null,
    "coverage": "focused",
    "observed_at": "2026-08-28T18:36:00+08:00",
    "valid_until": null,
    "artifact_bindings": [
      {"kind": "file", "identity": "docs/kos/codex-github-cli-auth-troubleshooting.md"},
      {"kind": "commit", "identity": "8e8ab1e"}
    ],
    "permits_claim_ids": ["CLAIM.KOS.CODEX_GITHUB_AUTH_SANDBOX_FALSE_NEGATIVE"],
    "prohibits_claim_ids": []
  }
}
```

## Current Status

| Field | Value |
|---|---|
| Status | current |

---

## Observation

- 在 Human 授权的主机／非沙箱环境运行同一最小只读检查 `gh auth status`，GitHub CLI
  确认使用 macOS Keychain 登录，所需 scopes 有效。
- 随后的有界 `git push`、Draft PR 创建与 PR 读取操作均成功。
- 主机通过当前有线网络与 Loon 路径完成上述动作；没有注入或复用历史热点代理地址。
- 未输出 token、一次性验证码、Keychain 内容或代理凭据。

## Conclusion and boundary

在同一事件中，主机认证和有界 GitHub 操作成功，而沙箱检查失败，因此允许成立
`CLAIM.KOS.CODEX_GITHUB_AUTH_SANDBOX_FALSE_NEGATIVE`：本次沙箱文案不是 token
过期的可靠证据。该结论不进一步断言内部原因究竟是 Keychain 可见性、沙箱网络限制
还是两者共同作用，也不授权新的 push、merge、Release 或代理修改。
