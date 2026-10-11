# F4-I 完整新before／provenance副本例外待决定 — 2026-10-05

Human批准恢复同F4-I，沿原60calls/90分钟累计，未重置；root重新核原UDID/容器/进程静默通过后执行修正清单工具。新before /private/tmp/ukey-host-activation-fix-f4-before-20261005 已完整保存installed-app/main-data/app-group；原live三读一致、副本两读一致，签名有效；尚未安装或启动。

[副本差异回执](keyboard-wake-host-activation-fix-001-f4-i-artifacts/backup-provenance-hold.json)记录883处仅com.apple.provenance新增/改写，非provenance差异0；文件bytes/SHA、目录/内部symlink、模式/owner/flags/ACL和其他xattrs一致。原live未改，不声称副本所有metadata完全相等。各root实际新增/改写数量及private inventory原件hash可复算；原helper receipt残留旧callcount11保持并单独纠正，新backup实际dispatch17，当前累计25/60包括host准备、两poll及本归档。

新before计installed-app78文件／91344780bytes，main-data827文件／1142571bytes，app-group53文件／2内部links／37750594bytes，合计130237945bytes（约124.2MiB）；所有历史备份不删。原值存在性仍有完整private清单。[恢复方案](keyboard-wake-host-activation-fix-001-f4-i-artifacts/restore-plan.json)绑定本次before、保护after/精确旧App重装/实际差量/系统metadata保留/两读回，恢复执行需另授权。

## 唯一新增Product决定

仅本次F4-I新before，是否接受这883处副本com.apple.provenance新增/改写为狭义保护例外？只副本、原live不改；其余差异仍停止，数量/原值存在性及原件保留，不继承旧轮例外或外推完全metadata恢复。如果接受，按已授同F4-I继续重核backup/live/candidate后安装冻结诊断pair及正常健康；不新增预算、不Maps/LLDB/部署/清旧备份。未接受前install_allowed=false保持。
