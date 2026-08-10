#!/bin/bash
# Build a reproducible iOS static octagram plugin XCFramework.
#
# Inputs (see config/rime-octagram-vendor-build.env):
#   - pinned librime commit (ABI peer of baseline vendor)
#   - pinned octagram relicense commit
#   - pinned Boost source tarball (headers only)
#   - baseline vendor static libraries for CMake find_library
#
# Outputs:
#   ${OUT_DIR}/librime-octagram.xcframework
#     ios-arm64 / ios-arm64_x86_64-simulator
#   ${OUT_DIR}/build-receipt.env
#
# Non-goals: does not download, package, or reference any *.gram model.
set -euo pipefail

readonly ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly BUILD_ENV="${ROOT}/config/rime-octagram-vendor-build.env"
readonly VENDOR_DIR="${ROOT}/Packages/RimeBridge/Vendor"
readonly DEFAULT_WORK_DIR="${ROOT}/.build/td012-octagram"
readonly DEFAULT_OUT_DIR="${ROOT}/.build/td012-octagram/out"

if [[ ! -f "${BUILD_ENV}" ]]; then
  printf 'Missing build input ledger: %s\n' "${BUILD_ENV}" >&2
  exit 1
fi
# shellcheck source=../config/rime-octagram-vendor-build.env
source "${BUILD_ENV}"

WORK_DIR="${TD012_WORK_DIR:-${DEFAULT_WORK_DIR}}"
OUT_DIR="${TD012_OUT_DIR:-${DEFAULT_OUT_DIR}}"
KEEP_WORK="${TD012_KEEP_WORK:-1}"

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    printf 'Required command not found: %s\n' "$1" >&2
    exit 1
  }
}

require_cmd cmake
require_cmd git
require_cmd curl
require_cmd shasum
require_cmd lipo
require_cmd nm
require_cmd xcodebuild
require_cmd plutil

if [[ ! -d "${VENDOR_DIR}/librime.xcframework" ]]; then
  printf 'Baseline vendor missing at %s. Run: bash scripts/ensure_rime_vendor.sh fetch\n' \
    "${VENDOR_DIR}" >&2
  exit 1
fi

mkdir -p "${WORK_DIR}" "${OUT_DIR}"
WORK_DIR="$(cd "${WORK_DIR}" && pwd)"
OUT_DIR="$(cd "${OUT_DIR}" && pwd)"

# Logs must go to stderr: slice builders print only the archive path on stdout.
log() { printf '[td012-octagram] %s\n' "$*" >&2; }

fetch_boost() {
  local tarball="${WORK_DIR}/boost_${BOOST_VERSION//./_}.tar.bz2"
  # Official layout uses boost_1_91_0 regardless of minor formatting above.
  tarball="${WORK_DIR}/${BOOST_ROOT_DIRNAME}.tar.bz2"
  local dest="${WORK_DIR}/${BOOST_ROOT_DIRNAME}"
  if [[ -d "${dest}/boost" ]]; then
    log "Boost headers already present: ${dest}"
    return
  fi
  if [[ ! -f "${tarball}" ]]; then
    log "Downloading Boost ${BOOST_VERSION}"
    curl --fail --location --retry 3 --output "${tarball}" "${BOOST_TARBALL_URL}"
  fi
  local got
  got="$(shasum -a 256 "${tarball}" | awk '{ print $1 }')"
  if [[ "${got}" != "${BOOST_TARBALL_SHA256}" ]]; then
    printf 'Boost tarball SHA-256 mismatch: expected %s got %s\n' \
      "${BOOST_TARBALL_SHA256}" "${got}" >&2
    exit 1
  fi
  log "Extracting Boost headers"
  tar -xjf "${tarball}" -C "${WORK_DIR}"
  [[ -d "${dest}/boost" ]] || {
    printf 'Boost extract missing include root: %s/boost\n' "${dest}" >&2
    exit 1
  }
}

checkout_librime() {
  local src="${WORK_DIR}/librime"
  if [[ -d "${src}/.git" ]]; then
    log "Updating librime checkout"
    git -C "${src}" fetch --depth 1 origin "${LIBRIME_GIT_COMMIT}"
    git -C "${src}" checkout --force "${LIBRIME_GIT_COMMIT}"
  else
    log "Cloning librime @ ${LIBRIME_GIT_COMMIT}"
    rm -rf "${src}"
    git clone --filter=blob:none "${LIBRIME_GIT_URL}" "${src}"
    git -C "${src}" checkout --force "${LIBRIME_GIT_COMMIT}"
  fi
  local got
  got="$(git -C "${src}" rev-parse HEAD)"
  if [[ "${got}" != "${LIBRIME_GIT_COMMIT}" ]]; then
    printf 'librime commit mismatch: expected %s got %s\n' \
      "${LIBRIME_GIT_COMMIT}" "${got}" >&2
    exit 1
  fi
  # Submodules provide public headers for glog/yaml/leveldb/marisa/opencc.
  git -C "${src}" submodule sync --recursive
  git -C "${src}" submodule update --init --depth 1 --recursive
}

checkout_octagram() {
  local plugin_dir="${WORK_DIR}/librime/plugins/octagram"
  if [[ -d "${plugin_dir}/.git" ]]; then
    log "Updating octagram plugin checkout"
    git -C "${plugin_dir}" fetch --depth 1 origin "${OCTAGRAM_GIT_COMMIT}"
    git -C "${plugin_dir}" checkout --force "${OCTAGRAM_GIT_COMMIT}"
  else
    log "Cloning octagram @ ${OCTAGRAM_GIT_COMMIT} into plugins/octagram"
    rm -rf "${plugin_dir}"
    git clone --filter=blob:none "${OCTAGRAM_GIT_URL}" "${plugin_dir}"
    git -C "${plugin_dir}" checkout --force "${OCTAGRAM_GIT_COMMIT}"
  fi
  local got
  got="$(git -C "${plugin_dir}" rev-parse HEAD)"
  if [[ "${got}" != "${OCTAGRAM_GIT_COMMIT}" ]]; then
    printf 'octagram commit mismatch: expected %s got %s\n' \
      "${OCTAGRAM_GIT_COMMIT}" "${got}" >&2
    exit 1
  fi
}

prepare_opencc_headers() {
  # Baseline staging historically only exposed the C API. librime still needs
  # OpenCC C++ headers (Config.hpp, …). Point a controlled prefix at the pinned
  # OpenCC submodule sources.
  local prefix="${WORK_DIR}/opencc-headers"
  rm -rf "${prefix}"
  mkdir -p "${prefix}"
  ln -s "${WORK_DIR}/librime/deps/opencc/src" "${prefix}/opencc"
}

vendor_lib() {
  # $1 framework leaf name without .xcframework, $2 slice directory name
  local name="$1"
  local slice="$2"
  local path="${VENDOR_DIR}/${name}.xcframework/${slice}/${name}.a"
  # Framework directory names use lib* / librime-* while binary may match.
  if [[ ! -f "${path}" ]]; then
    # libyaml-cpp is stored as libyaml-cpp.xcframework / libyaml-cpp.a
    path="${VENDOR_DIR}/${name}.xcframework/${slice}/${name}.a"
  fi
  if [[ ! -f "${path}" ]]; then
    # try finding any .a under the slice
    path="$(find "${VENDOR_DIR}/${name}.xcframework/${slice}" -name '*.a' -print -quit || true)"
  fi
  if [[ -z "${path}" || ! -f "${path}" ]]; then
    printf 'Missing vendor library for %s slice %s\n' "${name}" "${slice}" >&2
    exit 1
  fi
  printf '%s' "${path}"
}

configure_and_build_slice() {
  # $1 build dir name, $2 sysroot (iphoneos|iphonesimulator), $3 archs, $4 vendor slice id
  local build_name="$1"
  local sysroot="$2"
  local archs="$3"
  local vendor_slice="$4"
  local src="${WORK_DIR}/librime"
  local build_dir="${WORK_DIR}/${build_name}"
  local boost_include="${WORK_DIR}/${BOOST_ROOT_DIRNAME}"
  local opencc_include="${WORK_DIR}/opencc-headers"

  rm -rf "${build_dir}"
  mkdir -p "${build_dir}"

  local glog_lib yaml_lib leveldb_lib marisa_lib opencc_lib
  glog_lib="$(vendor_lib libglog "${vendor_slice}")"
  yaml_lib="$(vendor_lib libyaml-cpp "${vendor_slice}")"
  leveldb_lib="$(vendor_lib libleveldb "${vendor_slice}")"
  marisa_lib="$(vendor_lib libmarisa "${vendor_slice}")"
  opencc_lib="$(vendor_lib libopencc "${vendor_slice}")"

  log "Configuring ${build_name} (sysroot=${sysroot} archs=${archs})"
  # Keep cmake/xcodebuild chatter on stderr so callers can capture only the archive path.
  cmake -S "${src}" -B "${build_dir}" -G Xcode \
    -DCMAKE_SYSTEM_NAME=iOS \
    -DCMAKE_OSX_SYSROOT="${sysroot}" \
    -DCMAKE_OSX_ARCHITECTURES="${archs}" \
    -DCMAKE_OSX_DEPLOYMENT_TARGET="${IOS_DEPLOYMENT_TARGET}" \
    -DBUILD_SHARED_LIBS=OFF \
    -DBUILD_STATIC=ON \
    -DBUILD_MERGED_PLUGINS=OFF \
    -DBUILD_TEST=OFF \
    -DBUILD_DATA=OFF \
    -DBUILD_TOOLS=OFF \
    -DBUILD_SAMPLE=OFF \
    -DBoost_INCLUDE_DIR="${boost_include}" \
    -DGlog_INCLUDE_PATH="${src}/deps/glog/src" \
    -DGlog_LIBRARY="${glog_lib}" \
    -DYamlCpp_INCLUDE_PATH="${src}/deps/yaml-cpp/include" \
    -DYamlCpp_NEW_API="${src}/deps/yaml-cpp/include" \
    -DYamlCpp_LIBRARY="${yaml_lib}" \
    -DLevelDb_INCLUDE_PATH="${src}/deps/leveldb/include" \
    -DLevelDb_LIBRARY="${leveldb_lib}" \
    -DMarisa_INCLUDE_PATH="${src}/deps/marisa-trie/include" \
    -DMarisa_LIBRARY="${marisa_lib}" \
    -DOpencc_INCLUDE_PATH="${opencc_include}" \
    -DOpencc_LIBRARY="${opencc_lib}" >&2

  log "Building rime-octagram-objs for ${build_name}"
  cmake --build "${build_dir}" --config Release --target rime-octagram-objs >&2

  # Xcode generator deposits the OBJECT library archive under build/
  local archive
  archive="$(find "${build_dir}" -type f -name 'librime-octagram-objs.a' -print | head -n 1)"
  if [[ -z "${archive}" ]]; then
    printf 'Built archive not found under %s\n' "${build_dir}" >&2
    exit 1
  fi
  if ! nm -gU "${archive}" | grep -q 'rime_require_module_octagram'; then
    printf 'Missing rime_require_module_octagram in %s\n' "${archive}" >&2
    exit 1
  fi
  # Single-line path only on stdout for command substitution.
  printf '%s\n' "${archive}"
}

package_static_archive() {
  # Copy objs archive to the stable public name used by the XCFramework.
  local src_a="$1"
  local dest_a="$2"
  mkdir -p "$(dirname "${dest_a}")"
  cp -f "${src_a}" "${dest_a}"
}

main() {
  log "WORK_DIR=${WORK_DIR}"
  log "OUT_DIR=${OUT_DIR}"
  log "Xcode=$(xcodebuild -version | tr '\n' ' ')"

  fetch_boost
  checkout_librime
  checkout_octagram
  prepare_opencc_headers

  local device_a sim_arm_a sim_x86_a
  device_a="$(configure_and_build_slice \
    "build-ios-arm64" "iphoneos" "arm64" "ios-arm64")"
  sim_arm_a="$(configure_and_build_slice \
    "build-ios-sim-arm64" "iphonesimulator" "arm64" "ios-arm64_x86_64-simulator")"
  sim_x86_a="$(configure_and_build_slice \
    "build-ios-sim-x86_64" "iphonesimulator" "x86_64" "ios-arm64_x86_64-simulator")"

  local stage="${WORK_DIR}/xcframework-stage"
  rm -rf "${stage}"
  mkdir -p \
    "${stage}/ios-arm64" \
    "${stage}/ios-arm64_x86_64-simulator"

  package_static_archive "${device_a}" \
    "${stage}/ios-arm64/${PLUGIN_STATIC_ARCHIVE_NAME}"

  local sim_fat="${stage}/ios-arm64_x86_64-simulator/${PLUGIN_STATIC_ARCHIVE_NAME}"
  log "Creating fat simulator archive (arm64 + x86_64)"
  lipo -create "${sim_arm_a}" "${sim_x86_a}" -output "${sim_fat}"
  lipo -info "${sim_fat}"

  for a in \
    "${stage}/ios-arm64/${PLUGIN_STATIC_ARCHIVE_NAME}" \
    "${sim_fat}"; do
    if ! nm -gU "${a}" | grep -q 'rime_require_module_octagram'; then
      printf 'Symbol check failed for %s\n' "${a}" >&2
      exit 1
    fi
  done

  local xcf="${OUT_DIR}/${PLUGIN_XCFRAMEWORK_NAME}"
  rm -rf "${xcf}"
  log "Creating ${PLUGIN_XCFRAMEWORK_NAME}"
  xcodebuild -create-xcframework \
    -library "${stage}/ios-arm64/${PLUGIN_STATIC_ARCHIVE_NAME}" \
    -library "${sim_fat}" \
    -output "${xcf}"

  plutil -lint "${xcf}/Info.plist" >/dev/null

  {
    printf 'OUTPUT_RIME_VENDOR_VERSION=%s\n' "${OUTPUT_RIME_VENDOR_VERSION}"
    printf 'LIBRIME_GIT_COMMIT=%s\n' "${LIBRIME_GIT_COMMIT}"
    printf 'OCTAGRAM_GIT_COMMIT=%s\n' "${OCTAGRAM_GIT_COMMIT}"
    printf 'BOOST_TARBALL_SHA256=%s\n' "${BOOST_TARBALL_SHA256}"
    printf 'IOS_DEPLOYMENT_TARGET=%s\n' "${IOS_DEPLOYMENT_TARGET}"
    printf 'BASELINE_RIME_VENDOR_VERSION=%s\n' "${BASELINE_RIME_VENDOR_VERSION}"
    printf 'BASELINE_RIME_VENDOR_ARCHIVE_SHA256=%s\n' "${BASELINE_RIME_VENDOR_ARCHIVE_SHA256}"
    printf 'PLUGIN_XCFRAMEWORK=%s\n' "${xcf}"
    printf 'XCODE_VERSION=%s\n' "$(xcodebuild -version | tr '\n' ' ' | sed 's/ *$//')"
    printf 'BUILT_AT_UTC=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  } >"${OUT_DIR}/build-receipt.env"

  log "Done: ${xcf}"
  log "Receipt: ${OUT_DIR}/build-receipt.env"

  if [[ "${KEEP_WORK}" != "1" ]]; then
    rm -rf "${WORK_DIR}/build-ios-arm64" \
      "${WORK_DIR}/build-ios-sim-arm64" \
      "${WORK_DIR}/build-ios-sim-x86_64" \
      "${WORK_DIR}/xcframework-stage"
  fi
}

main "$@"
