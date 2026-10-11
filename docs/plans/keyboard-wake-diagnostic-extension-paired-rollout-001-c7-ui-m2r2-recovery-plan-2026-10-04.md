# M2R2 恢复方案（Prepared，未执行）

只适用于本轮原UDID405D994F-28CB-4F89-BB22-B64AD81C05A2、候选43d85d612af6c606b5434dcb0a989e43e3c472bf6f296df3bd7c2fcb6220ba50。backup-receipt.json列明每个root的完整副本位置；复用root在本轮与当前源、现存副本全量核验一致后才采用，不通过符号链接拼成恢复点。

此授权不包含恢复。若后续需要：先保全故障后数据，核对应before/after结构与逐路径摘要差异，列出恢复到本轮before会覆盖的用户变更；再请求精确恢复授权。恢复前必须重新核设备独占、关闭App与精确进程退出、已装候选身份。只有安装身份改变且另获安装权限才重装配对包；目录替换不自动扩大到App或部署。完成后核所有恢复字节/结构及诊断原值/存在性，正常输入健康验证另发操作卡。

未覆盖Keychain、Maps数据、系统键盘启用与完全访问；不声称恢复这些项目。ACL/时间戳未逐项验证，原字节/结构/mode/uid/gid/原xattr核验与新增provenance分类详receipt。旧I0/I1/M0保留，未删除；本轮新增副本清理待交付及用户单独批准。

本轮main/App复用M0，Group完整副本位于/private/tmp/ukey-wake-m2r2-20261004/backup/app-group；具体位置/本轮核验来源见backup-receipt。旧副本无修改或删除。不得用目录根backup名称假定三root均在其中，按receipt映射恢复。
