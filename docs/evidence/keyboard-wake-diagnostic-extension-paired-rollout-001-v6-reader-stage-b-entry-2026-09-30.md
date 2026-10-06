# Stage B Entry

2026-09-30 Asia/Shanghai。Scoped Entry satisfied for exact Stage A reader verification。

[Authorization](../product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001-v6-reader-stage-b-authorization-2026-09-30.md) 及当前Human独占确认。branch codex/keyboard-wake-v3-compatibility-gate、HEAD84b9c19227330b0fe6ff391be001ee398010fd6a均匹配；Stage A manifest所有五source/test、七readonly dependency和evidence hash匹配。241dirty（10tracked modified/231untracked），porcelain-z SHA256 `ec8353e0ade3c387078f1ae19502a9e635df19036ef11ede13380ac57b75977f`。2340既有文件hash快照在 `/private/tmp/ukey-wake-v6-stage-b-20260930-01a0f254/before-file-hashes.json`；root唯一repo文档writer，reviewers不改repo。

MCP list_sims新鲜发现目标 iPhone18Pro / iOS27.0 UDID405D994F-28CB-4F89-BB22-B64AD81C05A2 available/Booted；状态不是reservation证明，reservation来自Human本次确认。root确认environment action boundaries；本阶段无需Maps人工动作。

`bash scripts/ensure_rime_vendor.sh verify`结构与pinned receipt通过，12framework；receipt与manifest的SHA是archive pin，不能独自证明每个当前vendor byte。byte digest补充核验作为验证证据记录。格式对当前七个Swift候选文件严格lint；host Stage A最终1181/0按AI_WORKFLOW同source/依赖/toolchain复用。Simulator顺序RimeBridgeTests → App+Keyboard Debug test → signed Keychain focused test → Release build；全程独立DerivedData/result paths，关闭parallel destination clones，仅指定UDID。

独立lane新round1，Architecture仅reader合同/边界与coverage，不预先判尚未生成的Simulator结果；Quality在冻结完整结果后派发。Entry不构成最终独立评审/可合并/Release或全局Exit。旧API/父patch恢复为Stage C前置。
