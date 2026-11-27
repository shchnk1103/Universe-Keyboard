# GitHub 发布、认证对照与真机前核对

本文件从 `AGENTS.md`「GitHub 发布与分支清理」下沉操作细节。以下红线仍绑定在 `AGENTS.md`，本文不放宽：未通过适用门禁不得请求合并；含 `.swift` 的提交/推送无格式豁免；远端状态无法确认时保留本地和远端分支；禁止用强制删除掩盖未合并状态；技能不能扩展外部动作权限。squash 双验与 `git branch -D` 禁令见 `AGENTS.md` 与 [pf-023-cleanup.md](pf-023-cleanup.md)。

## 沙箱认证

Codex 沙箱内的 GitHub CLI 认证失败不得单独解释为 token 过期。先按
[`codex-github-cli-auth-troubleshooting.md`](codex-github-cli-auth-troubleshooting.md)
做一次沙箱／主机对照；主机成功后停止重复登录，不猜测或复用旧代理配置。

## 授权范围与清理报告

- 发布按用户授权的具体动作推进：commit、push、PR、merge、Release 分别核对范围。仅要求本地提交不推送；推送使用边界清晰的功能分支。
- 只有在拉取最新远端状态后，确认该工作的提交已经可从 `origin` 的默认分支到达，才允许清理功能分支。
- 清理时先同步默认分支，再使用安全删除方式删除本地分支；确认远端默认分支仍包含对应提交后，才删除远端功能分支。
- 发布与清理过程必须报告提交、远端分支、PR、合并可达性检查和实际删除结果；任一步失败都停止清理并保留可恢复检查点。

## 真机测试前核对口令（O122-D）

任何真机验收或 Xcode 装机前，须先核对当前构建目录 `HEAD` 与 PM 提供的目标封版 SHA 一致（`git rev-parse HEAD` 与授权 SHA 比对），防止因主检出未快进或处于 detached 状态而误测旧代码。不一致则不得装机，并告诉 Human。
