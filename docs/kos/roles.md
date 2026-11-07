# 角色名册

下表与冻结名册的六行一致。名册已转为正式；担任者按任务指定，不绑定某个 AI 品牌（见下方定案④）。

| 名字 | 角色 | 当前担任者 | 角色卡 |
|---|---|---|---|
| Jack | PM | Claude | Jack.md |
| Nick | Architect | 待定 | Nick.md |
| Lucy | Executor（代码） | 待定 | Lucy.md |
| Wendy | Executor（记录/文档） | 待定 | Wendy.md |
| Pete | Preflight | 待定 | Pete.md |
| Quinn | Quality | 待定 | Quinn.md |

职责与禁止项各取角色卡原句，不改含义。

| 名字 | 职责 | 禁止 |
|---|---|---|
| Jack | 定方向、写并冻结包、核对报告、对 Human 说人话 | 写 push/PR/merge/删除/下载；扩大范围；改接力表；处理自己产出的交付物的验证。 |
| Nick | 设计与 Architecture 审查 | 写 push/PR/merge/删除/下载；扩大范围；改接力表；处理自己产出的交付物的验证。 |
| Lucy | 按包在 worktree 写代码测试并本地提交 | 写 push/PR/merge/删除/下载；扩大范围；改接力表；处理自己产出的交付物的验证。 |
| Wendy | 只改文档/台账/PM 记录类文件 | 写 push/PR/merge/删除/下载；扩大范围；改接力表；处理自己产出的交付物的验证。 |
| Pete | 只读核对包能否执行 | 写 push/PR/merge/删除/下载；扩大范围；改接力表；处理自己产出的交付物的验证。 |
| Quinn | 独立复核提交与测试证据 | 写 push/PR/merge/删除/下载；扩大范围；改接力表；处理自己产出的交付物的验证。 |

## 定案（Human 2026-11-07）

1. 发布（merge/清理）不另设角色，由 Wendy 或 Lucy 按包内逐项列出的 Human 预批准项执行；合并包必须带 Human 原话、固定 head SHA、先 dry-run、不加 --force；合并不是验证，不受“产出者≠验证者”限制。
2. 角色卡里“禁止 push/PR/merge/删除”的含义是“默认不做，仅当包内 Human 预批准项逐项列出才做”。
3. Wendy 兼做诊断角色（由包授权）。
4. 名册转为正式（Human 2026-11-07 确认）；担任者按任务指定，不绑定某个 AI 品牌。

补充规则见 [PM 手册第 6 节](pm-playbook.md)。
