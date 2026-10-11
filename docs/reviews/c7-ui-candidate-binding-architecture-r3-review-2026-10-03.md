ARCH-C7-UI-CANDIDATE-BINDING R3｜Partial / incomplete
身份：candidate packet candidate；branch packet branch；HEAD packet HEAD。
A1：Partial；重新核对允许输入 {'content': 0, 'binary': 0, 'generated': 0, 'hash_only': 0}，SHA mismatch=0、missing=104；解析 0/2 个 arm64 Mach-O 原始 __TEXT,__entitlements bytes。
A1缺口：未能构成恰好两个 App/appex 最终可执行文件的 Mach-O 与 xcent 配对；允许输入缺失或不可读；paired candidate binding 未能独立重算。
A2：Partial；binding candidate match=None; 78 payloads/paired metadata/signature/6 UUID 与限定source影响见范围记录。
A2缺口：限定 source-impact inputs 未全覆盖。
仅静态 artifact review；不证明安装、runtime、Product Gate 或旧 R1/R2 缺陷已关闭。
