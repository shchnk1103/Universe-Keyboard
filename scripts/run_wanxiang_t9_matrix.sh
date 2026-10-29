#!/bin/bash
# Isolated test fixtures only. Run: prepare, then ice, off, on in order.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TASK="$HOME/.kos-work/Universe-Keyboard/WANXIANG-T9-001"
OUT="${UK_MATRIX_OUTPUT:?Set UK_MATRIX_OUTPUT to a new directory under task scratch}"
case "$OUT" in "$TASK"/scratch/*) ;; *) printf "Output must be under task scratch\n" >&2; exit 2;; esac
case "$OUT" in *..*) printf "Invalid output path\n" >&2; exit 2;; esac
export ROOT TASK OUT
case "${1:-}" in
prepare)
  test ! -e "$OUT"
  mkdir -p "$OUT/tmp"
  python3 - <<'PY'
import hashlib, os, pathlib, re, shutil, zipfile
root=pathlib.Path(os.environ['ROOT']); task=pathlib.Path(os.environ['TASK']); out=pathlib.Path(os.environ['OUT'])
ice=task/'scratch/extract/rime-ice'; archive=task/'scratch/archives/rime-ice/full.zip'
assert archive.stat().st_size == 16050491 and hashlib.sha256(archive.read_bytes()).hexdigest() == '675d23b070be00e1b800f9a6db033ef98f4493cd5b568ed8aa3b3541769c46ac'
with zipfile.ZipFile(archive) as z:
 for i in z.infolist():
  if not i.is_dir():
   p=ice/i.filename; assert p.is_file() and not p.is_symlink() and hashlib.sha256(p.read_bytes()).digest()==hashlib.sha256(z.read(i)).digest(), i.filename
wan=task.parent/'WANXIANG-T9-SPIKE-001/scratch/extract/github'; inv=wan.parents[1]/'github-inventory.txt'
assert hashlib.sha256(inv.read_bytes()).hexdigest()=='6649905a3427f08fd68c5db5421422b983f252d4909b75dd107292841c3362f7'
expected={s[66:]:s[:64] for s in inv.read_text().splitlines()}; actual={str(p.relative_to(wan)):p for p in wan.rglob('*') if p.is_file() or p.is_symlink()}
assert set(expected)==set(actual) and not any(p.is_symlink() for p in actual.values()) and all(hashlib.sha256(actual[k].read_bytes()).hexdigest()==v for k,v in expected.items())
prelude=root/'Universe Keyboard/RimeBuiltin'
for variant,source,schema,preset in [('ice',ice,'t9','rime_ice_preset'),('off',wan,'wanxiang_t9i','wanxiang_preset'),('on',wan,'wanxiang_t9i','wanxiang_preset')]:
 dest=out/variant; shared=dest/'shared'; user=dest/'user'; shutil.copytree(prelude,shared); user.mkdir()
 for p in source.rglob('*'):
  if p.is_file() and p.name!='default.yaml' and p.suffix!='.gram':
   q=shared/p.relative_to(source); q.parent.mkdir(parents=True,exist_ok=True); shutil.copy2(p,q)
 shutil.copy2(source/'default.yaml',shared/(preset+'.yaml'))
 names=(['rime_ice.schema.yaml','t9.schema.yaml','melt_eng.schema.yaml','radical_pinyin.schema.yaml'] if variant=='ice' else ['wanxiang.schema.yaml','wanxiang_english.schema.yaml','wanxiang_mixedcode.schema.yaml','wanxiang_reverse.schema.yaml','wanxiang_t9.schema.yaml','wanxiang_t9i.schema.yaml'])
 for name in names:
  p=shared/name
  if p.exists():
   s=p.read_text(); s=s.replace('__include: default:/',f'__include: {preset}:/'); s=re.sub(r'import_preset:\s*default\b',f'import_preset: {preset}',s); p.write_text(s)
 p=shared/(schema+'.schema.yaml'); before=p.read_bytes(); lines=before.splitlines(keepends=True)
 if variant=='ice':
  s=before.decode(); assert all(x in s for x in ['derive/[abc]/2/','derive/[def]/3/','derive/[hgi]/4/','derive/[jkl]/5/','derive/[omn]/6/','derive/[pqrs]/7/','derive/[tuv]/8/','derive/[wxyz]/9/']); s='\n'.join(l for l in s.split('\n') if 't9_processor' not in l and not (l.strip().startswith('-') and 'force_gc' in l)); p.write_text(s if s.endswith('\n') else s+'\n')
 else:
  found=[l for l in lines if b't9_processor' in l]; assert len(found)==1; p.write_bytes(b''.join(l for l in lines if b't9_processor' not in l))
 (user/'default.custom.yaml').write_text('patch:\n  schema_list:\n    - schema: '+schema+'\n')
 if variant=='on': (user/(schema+'.custom.yaml')).write_text('patch:\n  switches/@3/reset: 1\n')
 assert not list(dest.rglob('*.gram'))
 with (out/(variant+'-inventory.txt')).open('w') as f:
  for q in sorted(dest.rglob('*')):
   if q.is_file(): f.write(hashlib.sha256(q.read_bytes()).hexdigest()+'  '+str(q.relative_to(dest))+'\n')
 print(variant,'source_hash',hashlib.sha256(before).hexdigest(),'compatible_hash',hashlib.sha256(p.read_bytes()).hexdigest())
PY
  ;;
ice|off|on)
  variant="$1"; if [[ "$variant" == ice ]]; then schema=t9; else schema='wanxiang_t9i'; fi
  test -d "$OUT/$variant/user"
  export TMPDIR="$OUT/tmp" UK_MATRIX_SHARED="$OUT/$variant/shared" UK_MATRIX_USER="$OUT/$variant/user" UK_MATRIX_SCHEMA="$schema"
  export TEST_RUNNER_UK_MATRIX_SHARED="$UK_MATRIX_SHARED" TEST_RUNNER_UK_MATRIX_USER="$UK_MATRIX_USER" TEST_RUNNER_UK_MATRIX_SCHEMA="$UK_MATRIX_SCHEMA"
  export SIMCTL_CHILD_UK_MATRIX_SHARED="$UK_MATRIX_SHARED" SIMCTL_CHILD_UK_MATRIX_USER="$UK_MATRIX_USER" SIMCTL_CHILD_UK_MATRIX_SCHEMA="$UK_MATRIX_SCHEMA"
  run_id="${2:-first}"; case "$run_id" in *[!a-zA-Z0-9_-]*|"") exit 2;; esac
  logfile="$OUT/$variant-$run_id.log"; test ! -e "$logfile"
  { printf 'COMMAND: bash scripts/run_wanxiang_t9_matrix.sh %s %s\n' "$variant" "$run_id"; printf 'XCODEBUILD: xcodebuild test -project "%s/Universe Keyboard.xcodeproj" -scheme RimeBridgeTests -configuration Debug -destination "platform=iOS Simulator,id=C45B3E72-42DF-44AB-B614-8BE7D34E54D7" -derivedDataPath "%s" -resultBundlePath "%s/%s.xcresult" -only-testing:RimeBridgeTests/RimeT9R2Tests CODE_SIGNING_ALLOWED=NO\n' "$ROOT" "$OUT/DerivedData-$variant-$run_id" "$OUT" "$variant-$run_id"; printf 'ENV TMPDIR=%s UK_MATRIX_SHARED=%s UK_MATRIX_USER=%s UK_MATRIX_SCHEMA=%s (TEST_RUNNER_ and SIMCTL_CHILD_ mirror UK_MATRIX values)\n' "$TMPDIR" "$UK_MATRIX_SHARED" "$UK_MATRIX_USER" "$UK_MATRIX_SCHEMA"; git -C "$ROOT" rev-parse HEAD; git -C "$ROOT" status --porcelain; set +e; xcodebuild test -project "$ROOT/Universe Keyboard.xcodeproj" -scheme RimeBridgeTests -configuration Debug -destination 'platform=iOS Simulator,id=C45B3E72-42DF-44AB-B614-8BE7D34E54D7' -derivedDataPath "$OUT/DerivedData-$variant-$run_id" -resultBundlePath "$OUT/$variant-$run_id.xcresult" -only-testing:RimeBridgeTests/RimeT9R2Tests CODE_SIGNING_ALLOWED=NO; result=$?; printf 'EXIT:%s\n' "$result"; git -C "$ROOT" rev-parse HEAD; exit "$result"; } > "$logfile" 2>&1
  ;;
negative)
  python3 - <<'PYNEG'
import pathlib,shutil,hashlib,os
out=pathlib.Path(os.environ['OUT']); task=pathlib.Path(os.environ['TASK']); external=task.parent/'WANXIANG-T9-SPIKE-001/scratch/extract/github'
for variant,schema,source in [('ice','t9',task/'scratch/extract/rime-ice/t9.schema.yaml'),('off','wanxiang_t9i',external/'wanxiang_t9i.schema.yaml')]:
 for kind in ['upstream','missing-compiled']:
  dest=out/('script-negative-'+variant+'-'+kind); assert not dest.exists(); shutil.copytree(out/variant,dest,symlinks=True)
  src=dest/'shared'/(schema+'.schema.yaml'); compiled=dest/'user/build'/(schema+'.schema.yaml'); assert compiled.is_file()
  if kind=='upstream': shutil.copy2(source,src)
  else: compiled.unlink()
  source_ok=b't9_processor' not in src.read_bytes(); compiled_ok=compiled.is_file()
  print('preflight',variant,kind,'source',src,'sha256',hashlib.sha256(src.read_bytes()).hexdigest(),'source_ok',source_ok,'compiled',compiled,'compiled_ok',compiled_ok,'accepted',source_ok and compiled_ok)
  assert not (source_ok and compiled_ok)
PYNEG
  ;;
archive)
  python3 - <<'PYARCH'
import hashlib, os, pathlib
out=pathlib.Path(os.environ['OUT'])
for name in ['ice','off','on']:
 dest=out/name
 with (out/(name+'-post-inventory.txt')).open('w') as f:
  for p in sorted(dest.rglob('*')):
   if p.is_file() and not p.is_symlink(): f.write(hashlib.sha256(p.read_bytes()).hexdigest()+'  '+str(p.relative_to(dest))+'\n')
 print(name, 'post_inventory_written')
PYARCH
  ;;
*) printf 'usage: %s prepare|ice|off|on|negative|archive\n' "$0" >&2; exit 2;;
esac
