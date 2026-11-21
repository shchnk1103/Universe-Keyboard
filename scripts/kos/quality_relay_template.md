Quality Reviewer；你不是 PM

# 质检任务包：{TASK} 直通复核

- **包头档位**：`quality-check`
- **指派执行者**：{PICK}
- **基线**：`{BASE}`
- **待验提交**：`{COMMIT}`
- **工作树**：`{WORKTREE}`（在此内只读复核，禁止 push、开 PR、合并或改动分支外内容）
- **排除名单**：{EXCLUDES}
- **被审实现包**：`{PACKET}`（SHA-256 `{PACKET_SHA}`）
- **执行报告**：`{EXEC_REPORT}`（SHA-256 `{EXEC_REPORT_SHA}`）
- **质检报告输出路径**：`{QUALITY_REPORT}`（写报告前该文件不存在，直接新建）

## 只读复核边界

- 仅在上述工作树内只读检查 `git show {COMMIT}`、跑测试与既有校验脚本；不得改动仓库文件、不得 `git push`、不得开 PR 或合并。
- 除质检报告输出路径外不得写入任务目录；原始执行报告与实现包保持只读。

## 改动文件

{FILE_LIST}

## 日志与 SHA-256

{LOG_SHA_LIST}

## 复核重点（逐字复制自冻结包，不得另给焦点）

{REVIEW_FOCUS}

## 收尾输出（必须执行）

1. 写完质检报告后运行 `python3 -I scripts/kos/kos-report-lint.py {QUALITY_REPORT}`（须 OK）。
2. 运行 `python3 -I scripts/kos/kos_handoff.py final --report {QUALITY_REPORT}`。
3. 将该命令标准输出**直接作为 Markdown 原样回复**（三行摘要作正文、仅派发块保留 ```text 围栏），严禁外层再套代码块。

## 观察与改进意见（不影响状态，不在本包范围）

（复核中发现的过程性观察写在此处）

## 下一站接力（O41）

- next_role：Jack（PM）
- next_step：按质检结论处置（PASS → 终审/发布；FAIL/STOPPED → 返工）
