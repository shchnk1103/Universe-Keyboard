# F2执行授权 — 2026-10-04

Human Product Lead回复“批准，原模拟器仍独占。”，承接root提出的F2执行、180分钟墙钟上限/首个失败或超时即停、新鲜备份及测试runner安装/启动，精确UDID405D994F-28CB-4F89-BB22-B64AD81C05A2。Environment Executor=root。以[修订Prepared Entry](../evidence/keyboard-wake-host-activation-fix-001-f2-prepared-entry-2026-10-04.md)及[本轮冻结回执](../evidence/keyboard-wake-host-activation-fix-001-f2-artifacts/execution-authorization-entry.json)为准，不授权源码修复、自动恢复/卸载/erase、其他模拟器或Release。

root确认原iPhone18Pro/iOS27.0Booted、branch/HEAD/staged0与1156构建/Vendor输入字节一致。旧Keyboard扩展PID55759仍运行；静默完整备份Entry尚未满足，测试未启动。为仅该进程一次正常SIGTERM另向Human请求精确批准，不从F2推定终止旧运行进程权限。若备份无法成立，停止安装/测试，不复制动态容器冒充一致快照。期间不要求重复F2总授权。

独占与工具可用不代替备份；备份hash/结构/模式/owner/xattrs及内部symlink核验、签名读回通过后才能测试。未来F3实现review与F4安装/Maps授权不继承。旧父Completed与独立结论保持。
