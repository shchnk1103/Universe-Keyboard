#!/bin/bash
# Assemble a full 12-framework vendor zip:
#   baseline 11 frameworks (byte-identical to the pinned baseline) +
#   newly built librime-octagram.xcframework
#
# Does not publish a GitHub Release; prints the archive path and SHA-256 so a
# human/agent can upload and then update config/rime-vendor-manifest.env.
set -euo pipefail

readonly ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly BUILD_ENV="${ROOT}/config/rime-octagram-vendor-build.env"
readonly VENDOR_DIR="${ROOT}/Packages/RimeBridge/Vendor"
readonly DEFAULT_PLUGIN_XCF="${ROOT}/.build/td012-octagram/out/librime-octagram.xcframework"
readonly DEFAULT_OUT_DIR="${ROOT}/.build/td012-octagram/out"

# shellcheck source=../config/rime-octagram-vendor-build.env
source "${BUILD_ENV}"

PLUGIN_XCF="${1:-${DEFAULT_PLUGIN_XCF}}"
OUT_DIR="${TD012_OUT_DIR:-${DEFAULT_OUT_DIR}}"
mkdir -p "${OUT_DIR}"
OUT_DIR="$(cd "${OUT_DIR}" && pwd)"

if [[ ! -d "${PLUGIN_XCF}" ]]; then
  printf 'Missing plugin XCFramework: %s\n' "${PLUGIN_XCF}" >&2
  printf 'Build it first: bash scripts/build_rime_octagram_plugin.sh\n' >&2
  exit 1
fi

if [[ ! -f "${VENDOR_DIR}/.rime-vendor-receipt" ]]; then
  printf 'Baseline vendor receipt missing; refuse to assemble without provenance.\n' >&2
  exit 1
fi

# shellcheck disable=SC1091
source "${ROOT}/config/rime-vendor-manifest.env"
if [[ "${RIME_VENDOR_VERSION}" != "${BASELINE_RIME_VENDOR_VERSION}" ]]; then
  printf 'Working tree vendor pin is %s, expected baseline %s while assembling.\n' \
    "${RIME_VENDOR_VERSION}" "${BASELINE_RIME_VENDOR_VERSION}" >&2
  exit 1
fi

stage="${OUT_DIR}/vendor-stage"
rm -rf "${stage}"
mkdir -p "${stage}"

# Copy baseline frameworks unchanged.
for fw in "${RIME_VENDOR_FRAMEWORKS[@]}"; do
  if [[ ! -d "${VENDOR_DIR}/${fw}" ]]; then
    printf 'Missing baseline framework: %s\n' "${fw}" >&2
    exit 1
  fi
  ditto "${VENDOR_DIR}/${fw}" "${stage}/${fw}"
done

ditto "${PLUGIN_XCF}" "${stage}/librime-octagram.xcframework"

# Provenance notice for the extended artifact.
cat >"${stage}/THIRD_PARTY_OCTAGRAM_NOTICE.txt" <<EOF
librime-octagram (octagram / grammar RIME module)
Source: ${OCTAGRAM_GIT_URL}
Commit: ${OCTAGRAM_GIT_COMMIT}
Root LICENSE: BSD-3-Clause (upstream relicense PR #8 merge)
Residual: src/grammar_module.cc still carries a stale GPLv3 file header; see
docs/evidence/td-012-octagram-license-provenance-audit-2026-08-09.md
Baseline ABI vendor: ${BASELINE_RIME_VENDOR_VERSION}
  SHA-256: ${BASELINE_RIME_VENDOR_ARCHIVE_SHA256}
librime peer commit: ${LIBRIME_GIT_COMMIT}
EOF

archive="${OUT_DIR}/${OUTPUT_RIME_VENDOR_ARCHIVE_NAME}"
rm -f "${archive}"
# Archive framework directories at the zip root (ensure_rime_vendor contract).
(
  cd "${stage}"
  ditto -c -k --sequesterRsrc --keepParent \
    . "${archive}.tmp" 2>/dev/null || true
)
# ditto --keepParent nests; produce a flat root zip instead.
rm -f "${archive}"
(
  cd "${stage}"
  zip -qry "${archive}" .
)

sha="$(shasum -a 256 "${archive}" | awk '{ print $1 }')"
printf 'version=%s\n' "${OUTPUT_RIME_VENDOR_VERSION}" >"${OUT_DIR}/assemble-receipt.env"
printf 'archive=%s\n' "${archive}" >>"${OUT_DIR}/assemble-receipt.env"
printf 'sha256=%s\n' "${sha}" >>"${OUT_DIR}/assemble-receipt.env"
printf 'baseline_version=%s\n' "${BASELINE_RIME_VENDOR_VERSION}" >>"${OUT_DIR}/assemble-receipt.env"
printf 'baseline_sha256=%s\n' "${BASELINE_RIME_VENDOR_ARCHIVE_SHA256}" >>"${OUT_DIR}/assemble-receipt.env"

printf 'Assembled archive:\n  %s\nSHA-256:\n  %s\n' "${archive}" "${sha}"
printf 'Next: publish as a GitHub Release asset named %s, then update config/rime-vendor-manifest.env\n' \
  "${OUTPUT_RIME_VENDOR_ARCHIVE_NAME}"
