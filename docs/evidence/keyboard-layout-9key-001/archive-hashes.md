# Spike archive hashes

- Harness commit: `337dd30ab443ad2d2af497648910946d6beb1a35`
- Local evidence dir (non-transferable convenience only): `evidence/keyboard-layout-9key-spike/20260716-195542`
- **Transferable full xcodebuild log (compressed):** `docs/evidence/keyboard-layout-9key-001/xcodebuild-t9-spike.log.gz`
- Full xcodebuild log SHA-256 (decompressed raw bytes): `784ac88f775d414cc7f181f55e9c7cdb0127b00c8d9d68a79eb59097c7ebe651`
- Full xcodebuild log SHA-256 (compressed `.gz` artifact): `724303a0b3d22783766bcd9e1b1bc76290dc81d79f1c5c5afe7e363ddca8e181`
- Vendor verify log SHA-256: `03fd59b207427813f241bb2217f226ac161e682885d370421269bff6e51b17e4`
- Vendor verify log (tracked): `docs/evidence/keyboard-layout-9key-001/rime-vendor-verify.log`
- Upstream schema SHA-256: `56bc593d2c846666361b3394bdc0bdb0c6f1a663f1fd810dceab2d222b5bf8f6`
- Patched schema SHA-256: `176a01aefcfeba856906ba6e83a9cf147fbd57d39f9923c70b36879c8bb5d57b`
- Concise excerpt (quick review only): `docs/evidence/keyboard-layout-9key-001/xcodebuild-t9-spike-excerpt.log`

## Inspect without local gitignored evidence

```bash
# From a clean clone of this branch:
gunzip -c docs/evidence/keyboard-layout-9key-001/xcodebuild-t9-spike.log.gz | shasum -a 256
# Expect: 784ac88f775d414cc7f181f55e9c7cdb0127b00c8d9d68a79eb59097c7ebe651
shasum -a 256 docs/evidence/keyboard-layout-9key-001/xcodebuild-t9-spike.log.gz
# Expect: 724303a0b3d22783766bcd9e1b1bc76290dc81d79f1c5c5afe7e363ddca8e181
```
