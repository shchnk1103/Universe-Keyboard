# Codex GitHub CLI 认证与网络诊断手册

## 目的与适用范围

本手册用于 Codex 在受限沙箱中执行 GitHub CLI 操作时，区分真实认证失效、
主机网络不可达与沙箱认证可见性假阴性。它是该诊断流程的 Source of Truth，
不替代当前 GitHub 账号状态、网络配置、任务授权或发布门禁。

适用场景：沙箱内的 `gh auth status` 报告 token invalid、认证失败或无法连接，
而 Human 刚完成浏览器登录，或主机环境可能拥有不同的 Keychain / 网络可见性。

## 第一性原理边界

- **输入：** 同一账号在两个执行环境中的最小认证检查，以及当前已授权 GitHub
  动作的结果。
- **状态：** 凭据通常由主机 Keychain 管理；沙箱可能无法看到相同凭据或网络路径。
- **副作用：** 重新登录会改变凭据状态，修改代理会改变网络状态；两者都不能由一次
  沙箱失败自动授权。
- **输出：** 只给出足以选择下一步的故障类别；不读取、复制或保存 secret。

## 故障类别

| 类别 | 判定条件 | 允许的结论 |
|---|---|---|
| `SANDBOX_AUTH_VISIBILITY_FALSE_NEGATIVE` | 沙箱报告认证失败，但同一命令在 Human 授权的主机环境成功，或主机上的有界 GitHub 操作成功 | 令牌没有被本次证据证明失效；停止重复登录，并在当前授权范围内使用主机环境执行网络动作 |
| `HOST_NETWORK_UNREACHABLE` | 主机环境报告 DNS、连接、TLS 或当前代理路径错误，且没有给出确定的认证失效结果 | 当前主机到 GitHub 的网络路径不可用；不得改称 token invalid |
| `HOST_TOKEN_INVALID` | Human 授权的主机环境也明确报告认证凭据无效 | 可以请求 Human 完成一次重新登录；仍不得输出凭据 |

沙箱输出本身只能描述沙箱观察，不能单独证明主机令牌失效，也不能证明 Loon、
热点或某个代理地址配置错误。

## 决策流程

1. 在当前沙箱运行最小只读检查 `gh auth status`，不增加任何显示 token 的参数。
2. 如果成功，继续当前已授权的 GitHub 动作；不要额外登录或修改代理。
3. 如果失败，请求 Human 授权在主机／非沙箱环境原样运行一次
   `gh auth status`。这一步是环境对照，不是重新登录。
4. 主机检查成功：分类为 `SANDBOX_AUTH_VISIBILITY_FALSE_NEGATIVE`。停止认证重试；
   当前已授权的 push、PR 查询等网络动作可在主机环境执行。
5. 主机检查报告连接、DNS、TLS 或代理错误：分类为
   `HOST_NETWORK_UNREACHABLE`。只核对当前网络和当前代理路径，不猜测或复用旧配置。
6. 只有主机检查也明确报告凭据无效时，才分类为 `HOST_TOKEN_INVALID`，并请求
   Human 执行一次 `gh auth login -h github.com`。
7. Human 登录成功后，只在主机环境复查一次。若主机成功而沙箱仍失败，按第 4 步
   收敛，不再要求登录。

## 重试预算与停止条件

- 每次事件最多进行一次沙箱／主机对照检查。
- 只有 `HOST_TOKEN_INVALID` 最多触发一次 Human 浏览器登录。
- Human 登录后主机检查成功，即使沙箱仍显示 invalid，也必须停止登录循环。
- 需要读取 secret、枚举 Keychain、无界输出环境变量或未经授权修改账号／代理时停止。
- 当前任务没有 push、PR、merge 或 Release 授权时，诊断成功也不能扩大动作范围。

## 代理与网络规则

- 当前 Human 声明和当前主机网络状态才是代理配置的依据。
- 不得复用历史热点代理地址；尤其不能因为过去使用过某个 IP/端口就自动注入
  `HTTP_PROXY`、`HTTPS_PROXY` 或大小写变体。
- 沙箱认证失败并不能证明 Loon 没有接管主机流量，也不能证明 Loon 配置错误。
- 只有主机返回网络类错误时才进入网络路径诊断；修改代理仍需独立授权。

## 隐私与日志规则

- 禁止运行或记录 `gh auth token`、`gh auth status --show-token`。
- 禁止记录浏览器一次性验证码、Keychain 内容、GitHub token 或代理凭据。
- 禁止用无过滤的 `env`、`printenv` 或日志转储来寻找凭据。
- Evidence 只记录命令类别、环境、成功／失败分类、时间和有界 GitHub 动作结果；
  所有 secret 均保持不可见。

## 当前事件证据

- [沙箱观察](../evidence/codex-github-auth-sandbox-2026-08-28.md)：沙箱报告
  token invalid；该证据单独不足以判断主机令牌状态。
- [主机授权观察](../evidence/codex-github-auth-host-2026-08-28.md)：主机 Keychain
  认证成功，且有界 push / PR 操作成功，因此本事件按沙箱假阴性收敛。

## 重新验证与维护

当 Codex 沙箱、macOS Keychain 集成、GitHub CLI 认证语义或项目网络架构发生变化时，
重新验证本流程。若新工具能可靠呈现跨环境认证状态，应由 Architecture & Knowledge
Steward 更新或 supersede 本手册；历史 Evidence 仍只证明其采集时刻的观察。
