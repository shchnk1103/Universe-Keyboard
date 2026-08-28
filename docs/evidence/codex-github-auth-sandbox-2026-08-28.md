# Evidence: CODEX-GITHUB-AUTH-DIAG-001 — 受限沙箱观察

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "EVIDENCE-CODEX-GH-AUTH-SANDBOX-20260828",
  "record_type": "evidence",
  "title": "Restricted sandbox GitHub CLI authentication observation",
  "status": "current",
  "updated_at": "2026-08-28T18:45:00+08:00",
  "revalidation_triggers": ["codex_sandbox_changed", "github_cli_changed", "credential_visibility_changed"],
  "evidence": {
    "provenance": "executor_recorded",
    "environment_id": "ENV.CODEX_SANDBOX",
    "assignment_ref": "CODEX-GITHUB-AUTH-DIAG-001",
    "operator_ref": "Current Codex session",
    "reviewer_ref": null,
    "coverage": "focused",
    "observed_at": "2026-08-28T18:35:00+08:00",
    "valid_until": null,
    "artifact_bindings": [
      {"kind": "file", "identity": "docs/kos/codex-github-cli-auth-troubleshooting.md"}
    ],
    "permits_claim_ids": [],
    "prohibits_claim_ids": ["CLAIM.KOS.CODEX_GITHUB_AUTH_SANDBOX_FALSE_NEGATIVE"]
  }
}
```

## Current Status

| Field | Value |
|---|---|
| Status | current |

---

## Observation

- Human 已通过 GitHub 浏览器设备流程完成登录。
- 紧接着在受限 Codex 沙箱中运行最小只读检查 `gh auth status`，CLI 报告当前账号
  的 token invalid。
- 未调用显示 token 的命令，未读取 Keychain，未记录一次性验证码或任何凭据。

## Evidence boundary

本记录只证明受限沙箱中的一次失败观察。它不能单独证明主机 token 已失效，也不能
区分沙箱 Keychain 可见性、GitHub API 网络限制或两者共同作用，因此明确禁止仅凭
本记录成立 `CLAIM.KOS.CODEX_GITHUB_AUTH_SANDBOX_FALSE_NEGATIVE`；该 Claim 需要
同一事件的主机授权对照证据。
