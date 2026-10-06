# OWN-EXPORT-001 E1 现场 Entry Ready

Human：未重装未部署；已关闭 Maps/主 App、回主屏收起键盘；诊断仍关。

机器：UDID `405D994F-28CB-4F89-BB22-B64AD81C05A2` Booted iPhone 18 Pro / iOS 27.0；安装 78/78 与四模块 UUID/SHA 匹配冻结候选；Group `161B78EE-E85A-47EA-8986-BA1D5AA70E39`。主 App 进程空。诊断三键 `logging_enabled` / `diagnostics_high_fidelity_expiration` / `log_category_disp` 均不存在，未改写。

旧 appex PID 778（start `Tue Oct  6 11:07:17 2026`，路径为当前安装 Keyboard.appex）复核后一次 SIGTERM，已退出；未 SIGKILL。

未 attach、未设断点。下一人工：Maps 空搜索框叫出 Universe Keyboard，确认完全访问开 / 空候选 / 「观测」可见，不要点或输入。
