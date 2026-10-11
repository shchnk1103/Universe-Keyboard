# ARCH-C7-UI-CANDIDATE-BINDING R2｜报告一致性补证

**R2：Complete（仅一致性补证，C1/C2 Covered）。** Packet `8dbd34558300d7e822bb4eafd74531bb0c72e48d3c53a2b086918f3f00002b6f` 与7项冻结输入哈希均匹配。

| 项 | 结论 |
|---|---|
| C1 | R1 start `2026-10-02T15:47:44.763710Z`，360秒硬截止 `15:53:44.763710Z`；usage记载402.631986秒，超42.631986秒。最终call 5始于 `15:54:27.395877Z`，已过硬截止；R1 Complete/Positive 与预算事实冲突。root裁定 `Partial / incomplete`，A1/A2仅为历史“Covered reported”。 |
| C2 | R1报告 SHA `f4179e249d1bdee48a6dbd4a541ca02b5a2d035a25ff4ec04eba8a2bd8fff0c3`、usage SHA `2f04ba5b15c97d8631d6c83f12e54d4e13c62e8b9d36158a9a3923a2349b5d45` 与冻结值一致；R1原件保持不变。旧Quality缺少独立交付是另一项 Partial，本补证不改变。 |

本 R2 Complete 只确认报告与预算记录的一致性；不接受R1 artifact review为Complete/Positive，不豁免预算，不确认新artifact，不授权安装、Gate或runtime。基线：`codex/keyboard-wake-v3-compatibility-gate` / `84b9c19227330b0fe6ff391be001ee398010fd6a`；candidate `43d85d612af6c606b5434dcb0a989e43e3c472bf6f296df3bd7c2fcb6220ba50`。
