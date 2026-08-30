#!/usr/bin/env bash

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
readonly SOURCE_ROOT="${1:-}"
readonly OUTPUT_ROOT="${2:-$REPO_ROOT/Universe Keyboard/RimeBuiltin}"
readonly RIME_DEPLOYER="${RIME_DEPLOYER:-/opt/homebrew/bin/rime_deployer}"
readonly CMAKE="${CMAKE:-/opt/homebrew/bin/cmake}"

readonly LUNA_REVISION="56b934b099dfbeab842320f13aa8b461a6ab3e42"
readonly ESSAY_REVISION="e9b1a374a6ea015fca5bdd04318924b4483ac35a"
readonly PRELUDE_REVISION="082425ea0684bca36474415d4a0e8db9b016487e"
readonly STROKE_REVISION="1e8fff9b9494ddec23b0cbc526bcfd8171a6fd48"
readonly OPENCC_REVISION="25350017e81b40aa9e3e66c18446b57f83b0607d"
readonly RIME_DEPLOYER_SHA256="84c3556b804579f604c70fb55fe4fc67175bbd3e1116dc863335e4e4b229b01a"

if [[ -z "$SOURCE_ROOT" ]]; then
  echo "usage: $0 <pinned-source-root> [output-root]" >&2
  exit 64
fi

for tool in "$RIME_DEPLOYER" "$CMAKE" python3 shasum cmp; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "required tool is unavailable: $tool" >&2
    exit 69
  fi
done

verify_revision() {
  local directory="$1"
  local expected="$2"
  local actual
  actual="$(git -C "$directory" rev-parse HEAD)"
  if [[ "$actual" != "$expected" ]]; then
    echo "unexpected revision for $directory: $actual" >&2
    exit 65
  fi
  if [[ -n "$(git -C "$directory" status --porcelain)" ]]; then
    echo "pinned source checkout is dirty: $directory" >&2
    exit 65
  fi
}

verify_revision "$SOURCE_ROOT/rime-luna-pinyin" "$LUNA_REVISION"
verify_revision "$SOURCE_ROOT/rime-essay" "$ESSAY_REVISION"
verify_revision "$SOURCE_ROOT/rime-prelude" "$PRELUDE_REVISION"
verify_revision "$SOURCE_ROOT/rime-stroke" "$STROKE_REVISION"
verify_revision "$SOURCE_ROOT/OpenCC" "$OPENCC_REVISION"

actual_deployer_sha="$(shasum -a 256 "$RIME_DEPLOYER" | awk '{print $1}')"
if [[ "$actual_deployer_sha" != "$RIME_DEPLOYER_SHA256" ]]; then
  echo "unexpected rime_deployer SHA-256: $actual_deployer_sha" >&2
  exit 65
fi

readonly WORK_ROOT="$(mktemp -d /tmp/universe-rime-builtin.XXXXXX)"
trap 'rm -rf "$WORK_ROOT"' EXIT

prepare_rime_input() {
  local root="$1"
  mkdir -p "$root/shared" "$root/user" "$root/staging"
  # RIME includes input metadata in generated signatures. Preserve the pinned
  # checkout timestamps so two clean output directories describe one generation.
  cp -p \
    "$SOURCE_ROOT/rime-luna-pinyin/luna_pinyin.schema.yaml" \
    "$SOURCE_ROOT/rime-luna-pinyin/luna_pinyin.dict.yaml" \
    "$SOURCE_ROOT/rime-luna-pinyin/pinyin.yaml" \
    "$SOURCE_ROOT/rime-essay/essay.txt" \
    "$SOURCE_ROOT/rime-prelude/default.yaml" \
    "$SOURCE_ROOT/rime-prelude/key_bindings.yaml" \
    "$SOURCE_ROOT/rime-prelude/punctuation.yaml" \
    "$SOURCE_ROOT/rime-prelude/symbols.yaml" \
    "$SOURCE_ROOT/rime-stroke/stroke.schema.yaml" \
    "$SOURCE_ROOT/rime-stroke/stroke.dict.yaml" \
    "$root/shared/"
}

generate_rime() {
  local root="$1"
  prepare_rime_input "$root"
  "$RIME_DEPLOYER" --compile \
    "$root/shared/luna_pinyin.schema.yaml" \
    "$root/user" "$root/shared" "$root/staging"
  "$RIME_DEPLOYER" --compile \
    "$root/shared/stroke.schema.yaml" \
    "$root/user" "$root/shared" "$root/staging"
}

generate_rime "$WORK_ROOT/rime-a"
generate_rime "$WORK_ROOT/rime-b"

readonly RIME_OUTPUTS=(
  luna_pinyin.table.bin
  luna_pinyin.prism.bin
  luna_pinyin.reverse.bin
  stroke.table.bin
  stroke.prism.bin
  stroke.reverse.bin
)
for name in "${RIME_OUTPUTS[@]}"; do
  cmp "$WORK_ROOT/rime-a/staging/$name" "$WORK_ROOT/rime-b/staging/$name"
done

generate_opencc() {
  local build_root="$1"
  "$CMAKE" \
    -S "$SOURCE_ROOT/OpenCC" \
    -B "$build_root" \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_DOCUMENTATION=OFF \
    -DENABLE_GTEST=OFF
  "$CMAKE" --build "$build_root" --target Dictionaries -j 8
}

generate_opencc "$WORK_ROOT/opencc-a"
generate_opencc "$WORK_ROOT/opencc-b"

readonly OPENCC_OUTPUTS=(
  TSPhrases.ocd2
  TSCharacters.ocd2
  HKVariants.ocd2
  TWVariants.ocd2
  STPhrases.ocd2
  STCharacters.ocd2
)
for name in "${OPENCC_OUTPUTS[@]}"; do
  cmp "$WORK_ROOT/opencc-a/data/$name" "$WORK_ROOT/opencc-b/data/$name"
done

stage_output() {
  local rime_root="$1"
  local opencc_root="$2"
  local output_root="$3"
  mkdir -p "$output_root/build" "$output_root/opencc"
  cp "$rime_root/shared/"*.yaml "$output_root/"
  cp "$rime_root/shared/essay.txt" "$output_root/"
  for name in "${RIME_OUTPUTS[@]}"; do
    cp "$rime_root/staging/$name" "$output_root/build/$name"
  done
  for name in t2s.json t2hk.json t2tw.json s2t.json; do
    cp "$SOURCE_ROOT/OpenCC/data/config/$name" "$output_root/opencc/$name"
  done
  for name in "${OPENCC_OUTPUTS[@]}"; do
    cp "$opencc_root/data/$name" "$output_root/opencc/$name"
  done
}

readonly STAGED_OUTPUT="$WORK_ROOT/output-a"
readonly SECOND_STAGED_OUTPUT="$WORK_ROOT/output-b"
stage_output "$WORK_ROOT/rime-a" "$WORK_ROOT/opencc-a" "$STAGED_OUTPUT"
stage_output "$WORK_ROOT/rime-b" "$WORK_ROOT/opencc-b" "$SECOND_STAGED_OUTPUT"

python3 - \
  "$STAGED_OUTPUT" \
  "$SECOND_STAGED_OUTPUT" \
  "$actual_deployer_sha" \
  "macOS $(sw_vers -productVersion) $(uname -m)" <<'PY'
import hashlib
import json
import pathlib
import sys

root = pathlib.Path(sys.argv[1])
second_root = pathlib.Path(sys.argv[2])
deployer_sha = sys.argv[3]
host = sys.argv[4]
roles = {
    ".yaml": "source",
    ".txt": "preset-vocabulary",
    ".bin": "generated-rime",
    ".json": "opencc-config",
    ".ocd2": "generated-opencc",
}
entries = []
for path in sorted(p for p in root.rglob("*") if p.is_file()):
    relative = path.relative_to(root).as_posix()
    data = path.read_bytes()
    entries.append({
        "path": relative,
        "byteCount": len(data),
        "sha256": hashlib.sha256(data).hexdigest(),
        "role": roles[path.suffix],
    })

def tree_digest(directory: pathlib.Path) -> str:
    digest = hashlib.sha256()
    for path in sorted(p for p in directory.rglob("*") if p.is_file()):
        relative = path.relative_to(directory).as_posix().encode("utf-8")
        digest.update(len(relative).to_bytes(4, "big"))
        digest.update(relative)
        data = path.read_bytes()
        digest.update(len(data).to_bytes(8, "big"))
        digest.update(data)
    return digest.hexdigest()

first_digest = tree_digest(root)
second_digest = tree_digest(second_root)
if first_digest != second_digest:
    raise SystemExit("clean output trees differ")

manifest = {
    "formatVersion": 2,
    "generationID": "luna-official-2026-08-30-v2",
    "sourcePins": {
        "lunaPinyin": "56b934b099dfbeab842320f13aa8b461a6ab3e42",
        "essay": "e9b1a374a6ea015fca5bdd04318924b4483ac35a",
        "prelude": "082425ea0684bca36474415d4a0e8db9b016487e",
        "stroke": "1e8fff9b9494ddec23b0cbc526bcfd8171a6fd48",
        "opencc": "25350017e81b40aa9e3e66c18446b57f83b0607d",
    },
    "generators": {
        "rimeDeployer": {
            "version": "librime 1.17.0 (Homebrew 1.17.0_2)",
            "sha256": deployer_sha,
        },
        "opencc": {
            "version": "1.3.1+g2535001",
            "sourceRevision": "25350017e81b40aa9e3e66c18446b57f83b0607d",
        },
    },
    "reproducibility": {
        "host": host,
        "command": "scripts/generate_builtin_rime_resources.sh <pinned-source-root> <output-root>",
        "cleanOutputSHA256A": first_digest,
        "cleanOutputSHA256B": second_digest,
    },
    "overlayPolicy": {
        "identifier": "universe-luna-overlay-v1",
        "requiredFiles": ["default.custom.yaml", "luna_pinyin.custom.yaml"],
    },
    "entries": entries,
}
(root / "RimeBuiltin.manifest.json").write_text(
    json.dumps(manifest, ensure_ascii=False, indent=2) + "\n",
    encoding="utf-8",
)
PY

mkdir -p "$OUTPUT_ROOT"
rsync -a --delete "$STAGED_OUTPUT/" "$OUTPUT_ROOT/"
echo "generated built-in RIME closure at $OUTPUT_ROOT"
