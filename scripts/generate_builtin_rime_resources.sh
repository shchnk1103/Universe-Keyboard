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
readonly RIME_SOURCE_REPOSITORY="https://github.com/rime/librime.git"

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

readonly PYTHON3="$(command -v python3)"
readonly BASH_TOOL="${BASH:-/bin/bash}"
readonly SCRIPT_SHA256="$(shasum -a 256 "$0" | awk '{print $1}')"
readonly CMAKE_SHA256="$(shasum -a 256 "$CMAKE" | awk '{print $1}')"
readonly PYTHON_SHA256="$(shasum -a 256 "$PYTHON3" | awk '{print $1}')"
readonly BASH_SHA256="$(shasum -a 256 "$BASH_TOOL" | awk '{print $1}')"
readonly CMAKE_VERSION="$($CMAKE --version | head -n 1)"
readonly PYTHON_VERSION="$($PYTHON3 --version 2>&1)"
readonly BASH_VERSION_OUTPUT="$($BASH_TOOL --version | head -n 1)"
readonly HOST_OS_VERSION="$(sw_vers -productVersion)"
readonly HOST_OS_BUILD="$(sw_vers -buildVersion)"
readonly HOST_ARCHITECTURE="$(uname -m)"

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

readonly CXX_COMPILER="$(
  sed -n 's/^CMAKE_CXX_COMPILER:FILEPATH=//p' "$WORK_ROOT/opencc-a/CMakeCache.txt" | head -n 1
)"
if [[ -z "$CXX_COMPILER" || ! -x "$CXX_COMPILER" ]]; then
  echo "unable to resolve the OpenCC C++ compiler" >&2
  exit 65
fi
readonly CXX_COMPILER_SHA256="$(shasum -a 256 "$CXX_COMPILER" | awk '{print $1}')"
readonly CXX_COMPILER_VERSION="$($CXX_COMPILER --version | head -n 1)"
readonly OPENCC_PYTHON="$(
  sed -n 's/^PYTHON_EXECUTABLE:FILEPATH=//p' "$WORK_ROOT/opencc-a/CMakeCache.txt" | head -n 1
)"
if [[ -z "$OPENCC_PYTHON" || ! -x "$OPENCC_PYTHON" ]]; then
  echo "unable to resolve the Python interpreter selected by OpenCC" >&2
  exit 65
fi
readonly OPENCC_PYTHON_SHA256="$(shasum -a 256 "$OPENCC_PYTHON" | awk '{print $1}')"
readonly OPENCC_PYTHON_VERSION="$($OPENCC_PYTHON --version 2>&1)"

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

"$PYTHON3" - \
  "$STAGED_OUTPUT" \
  "$SECOND_STAGED_OUTPUT" \
  "$SOURCE_ROOT" \
  "$WORK_ROOT" \
  "$RIME_DEPLOYER" \
  "$actual_deployer_sha" \
  "$RIME_SOURCE_REPOSITORY" \
  "$CMAKE" \
  "$CMAKE_VERSION" \
  "$CMAKE_SHA256" \
  "$CXX_COMPILER" \
  "$CXX_COMPILER_VERSION" \
  "$CXX_COMPILER_SHA256" \
  "$OPENCC_PYTHON" \
  "$OPENCC_PYTHON_VERSION" \
  "$OPENCC_PYTHON_SHA256" \
  "$PYTHON3" \
  "$PYTHON_VERSION" \
  "$PYTHON_SHA256" \
  "$BASH_TOOL" \
  "$BASH_VERSION_OUTPUT" \
  "$BASH_SHA256" \
  "$SCRIPT_SHA256" \
  "$HOST_OS_VERSION" \
  "$HOST_OS_BUILD" \
  "$HOST_ARCHITECTURE" <<'PY'
import hashlib
import json
import pathlib
import sys

root = pathlib.Path(sys.argv[1])
second_root = pathlib.Path(sys.argv[2])
source_root = pathlib.Path(sys.argv[3])
work_root = pathlib.Path(sys.argv[4])
rime_deployer = sys.argv[5]
deployer_sha = sys.argv[6]
rime_source_repository = sys.argv[7]
cmake = sys.argv[8]
cmake_version = sys.argv[9]
cmake_sha = sys.argv[10]
cxx_compiler = sys.argv[11]
cxx_compiler_version = sys.argv[12]
cxx_compiler_sha = sys.argv[13]
opencc_python = sys.argv[14]
opencc_python_version = sys.argv[15]
opencc_python_sha = sys.argv[16]
python3 = sys.argv[17]
python_version = sys.argv[18]
python_sha = sys.argv[19]
bash = sys.argv[20]
bash_version = sys.argv[21]
bash_sha = sys.argv[22]
script_sha = sys.argv[23]
host_os_version = sys.argv[24]
host_os_build = sys.argv[25]
host_architecture = sys.argv[26]
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

source_specs = {
    "lunaPinyin": {
        "directory": "rime-luna-pinyin",
        "repository": "https://github.com/rime/rime-luna-pinyin.git",
        "revision": "56b934b099dfbeab842320f13aa8b461a6ab3e42",
        "files": ["luna_pinyin.schema.yaml", "luna_pinyin.dict.yaml", "pinyin.yaml"],
    },
    "essay": {
        "directory": "rime-essay",
        "repository": "https://github.com/rime/rime-essay.git",
        "revision": "e9b1a374a6ea015fca5bdd04318924b4483ac35a",
        "files": ["essay.txt"],
    },
    "prelude": {
        "directory": "rime-prelude",
        "repository": "https://github.com/rime/rime-prelude.git",
        "revision": "082425ea0684bca36474415d4a0e8db9b016487e",
        "files": ["default.yaml", "key_bindings.yaml", "punctuation.yaml", "symbols.yaml"],
    },
    "stroke": {
        "directory": "rime-stroke",
        "repository": "https://github.com/rime/rime-stroke.git",
        "revision": "1e8fff9b9494ddec23b0cbc526bcfd8171a6fd48",
        "files": ["stroke.schema.yaml", "stroke.dict.yaml"],
    },
    "opencc": {
        "directory": "OpenCC",
        "repository": "https://github.com/BYVoid/OpenCC.git",
        "revision": "25350017e81b40aa9e3e66c18446b57f83b0607d",
        "files": [
            "data/config/s2t.json", "data/config/t2hk.json", "data/config/t2s.json",
            "data/config/t2tw.json", "data/dictionary/HKVariants.txt",
            "data/dictionary/STCharacters.txt", "data/dictionary/STPhrases.txt",
            "data/dictionary/TSCharacters.txt", "data/dictionary/TSPhrases.txt",
            "data/dictionary/TWVariants.txt",
        ],
    },
}
source_inputs = {}
for key, spec in source_specs.items():
    files = []
    for relative in spec["files"]:
        data = (source_root / spec["directory"] / relative).read_bytes()
        files.append({"path": relative, "sha256": hashlib.sha256(data).hexdigest()})
    source_inputs[key] = {
        "repository": spec["repository"],
        "revision": spec["revision"],
        "files": files,
    }

def rime_command(run: str, schema: str) -> list[str]:
    root = work_root / run
    return [
        rime_deployer, "--compile", str(root / "shared" / schema),
        str(root / "user"), str(root / "shared"), str(root / "staging"),
    ]

def opencc_commands(run: str) -> list[list[str]]:
    build_root = work_root / run
    return [
        [
            cmake, "-S", str(source_root / "OpenCC"), "-B", str(build_root),
            "-DCMAKE_BUILD_TYPE=Release", "-DBUILD_DOCUMENTATION=OFF", "-DENABLE_GTEST=OFF",
        ],
        [cmake, "--build", str(build_root), "--target", "Dictionaries", "-j", "8"],
    ]

manifest = {
    "formatVersion": 3,
    "generationID": "luna-official-2026-08-31-v3",
    "sourcePins": {
        "lunaPinyin": "56b934b099dfbeab842320f13aa8b461a6ab3e42",
        "essay": "e9b1a374a6ea015fca5bdd04318924b4483ac35a",
        "prelude": "082425ea0684bca36474415d4a0e8db9b016487e",
        "stroke": "1e8fff9b9494ddec23b0cbc526bcfd8171a6fd48",
        "opencc": "25350017e81b40aa9e3e66c18446b57f83b0607d",
    },
    "sourceInputs": source_inputs,
    "generators": {
        "rimeDeployer": {
            "version": "librime 1.17.0 (Homebrew 1.17.0_2)",
            "sha256": deployer_sha,
            "sourceRepository": rime_source_repository,
            "commandArguments": [
                rime_command("rime-a", "luna_pinyin.schema.yaml"),
                rime_command("rime-a", "stroke.schema.yaml"),
                rime_command("rime-b", "luna_pinyin.schema.yaml"),
                rime_command("rime-b", "stroke.schema.yaml"),
            ],
        },
        "opencc": {
            "version": "1.3.1+g2535001",
            "sourceRepository": "https://github.com/BYVoid/OpenCC.git",
            "sourceRevision": "25350017e81b40aa9e3e66c18446b57f83b0607d",
            "commandArguments": opencc_commands("opencc-a") + opencc_commands("opencc-b"),
        },
    },
    "toolchain": {
        "bash": {"path": bash, "version": bash_version, "sha256": bash_sha},
        "cmake": {"path": cmake, "version": cmake_version, "sha256": cmake_sha},
        "cxxCompiler": {
            "path": cxx_compiler,
            "version": cxx_compiler_version,
            "sha256": cxx_compiler_sha,
        },
        "generationScript": {
            "path": "scripts/generate_builtin_rime_resources.sh",
            "version": "repository script",
            "sha256": script_sha,
        },
        "openccPython": {
            "path": opencc_python,
            "version": opencc_python_version,
            "sha256": opencc_python_sha,
        },
        "python3": {"path": python3, "version": python_version, "sha256": python_sha},
    },
    "reproducibility": {
        "hostOSVersion": host_os_version,
        "hostOSBuild": host_os_build,
        "hostArchitecture": host_architecture,
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
