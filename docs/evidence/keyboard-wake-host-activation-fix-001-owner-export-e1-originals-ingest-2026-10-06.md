# E1 KEEP 原件入库 — 2026-10-06

Human 授权：把 KEEP 目录拷进 `docs/evidence`，核 SHA 后再删 tmp。

来源：`/private/tmp/ukey-host-activation-fix-owner-export-20261006`

归档：[`keyboard-wake-host-activation-fix-001-owner-export-e1-originals/`](keyboard-wake-host-activation-fix-001-owner-export-e1-originals/)

清单：[owner-export-e1-originals-manifest.json](keyboard-wake-host-activation-fix-001-owner-export-e1-originals-manifest.json)

拷贝 67 个常规文件，字节与 SHA-256 与 tmp 原件一致。排除 `__pycache__`。跳过 FIFO `e1-lldb.cmd`（非证据文件，不在 Quality packet 内）。冻结 Quality packet 的 27 个 tmp 文本原件 + `owner-buffer.bin` 在归档路径上复算通过。

`owner-buffer.bin` 1496 bytes，SHA-256 `a8b3bde10c0c489e92b1e7f370e257d33c4156f805697af1597fe5d5fd35414d`。

tmp 目录已在归档 SHA 复核后删除：`/private/tmp/ukey-host-activation-fix-owner-export-20261006` 现 ABSENT。in-scope `/private/tmp` ukey 前缀已空。归档 67 文件与 `owner-buffer.bin` SHA 在删除后再次复核通过。

不改写已冻结的 Quality packet。packet 仍记录历史 tmp 路径；复核改读本归档。无源码、模拟器、Git、Release。
