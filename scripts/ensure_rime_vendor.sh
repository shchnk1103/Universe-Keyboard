#!/bin/bash
set -euo pipefail

readonly ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly VENDOR_DIR="${ROOT}/Packages/RimeBridge/Vendor"
readonly MANIFEST="${ROOT}/config/rime-vendor-manifest.env"
readonly RECEIPT="${VENDOR_DIR}/.rime-vendor-receipt"
readonly ARCHIVE="${TMPDIR:-/tmp}/universe-keyboard-rime-vendor.zip"
readonly STAGING="${TMPDIR:-/tmp}/universe-keyboard-rime-vendor-staging"

if [[ ! -f "${MANIFEST}" ]]; then
    printf 'Missing RIME vendor manifest: %s\n' "${MANIFEST}" >&2
    exit 1
fi

# The checked-in manifest is trusted input reviewed together with this script.
# shellcheck source=../config/rime-vendor-manifest.env
source "${MANIFEST}"

require_pinned_manifest() {
    if [[ "${RIME_VENDOR_VERSION}" == "UNCONFIGURED" ||
        "${RIME_VENDOR_ARCHIVE_URL}" == "UNCONFIGURED" ||
        "${RIME_VENDOR_ARCHIVE_SHA256}" == "UNCONFIGURED" ]]; then
        printf 'RIME vendor manifest is not configured. Publish a versioned archive and replace UNCONFIGURED values in %s.\n' \
            "${MANIFEST}" >&2
        return 1
    fi
    if [[ ! "${RIME_VENDOR_ARCHIVE_SHA256}" =~ ^[0-9a-fA-F]{64}$ ]]; then
        printf 'Invalid SHA-256 in RIME vendor manifest: %s\n' "${RIME_VENDOR_ARCHIVE_SHA256}" >&2
        return 1
    fi
}

verify_inventory() {
    local missing=0
    local framework
    local framework_path
    for framework in "${RIME_VENDOR_FRAMEWORKS[@]}"; do
        framework_path="${VENDOR_DIR}/${framework}"
        if [[ ! -d "${framework_path}" ]]; then
            printf 'Missing RIME artifact: %s\n' "${framework}" >&2
            missing=1
            continue
        fi
        if [[ ! -f "${framework_path}/Info.plist" ]] ||
            ! plutil -lint "${framework_path}/Info.plist" >/dev/null; then
            printf 'Invalid RIME xcframework Info.plist: %s\n' "${framework}" >&2
            missing=1
        fi
        if [[ -z "$(find "${framework_path}" -type f -name '*.a' -print -quit)" ]]; then
            printf 'RIME xcframework has no static library payload: %s\n' "${framework}" >&2
            missing=1
        fi
    done
    while IFS= read -r framework_path; do
        framework="$(basename "${framework_path}")"
        if ! printf '%s\n' "${RIME_VENDOR_FRAMEWORKS[@]}" | grep -Fxq "${framework}"; then
            printf 'Unexpected RIME artifact not present in manifest: %s\n' "${framework}" >&2
            missing=1
        fi
    done < <(find "${VENDOR_DIR}" -maxdepth 1 -type d -name '*.xcframework' -print 2>/dev/null)
    if [[ "${missing}" -ne 0 ]]; then
        return 1
    fi
    printf 'Verified structural inventory of %d RIME framework artifacts in %s\n' \
        "${#RIME_VENDOR_FRAMEWORKS[@]}" "${VENDOR_DIR}"
}

verify_receipt() {
    if [[ ! -f "${RECEIPT}" ]]; then
        printf 'Missing RIME artifact receipt; local bytes cannot be matched to the pinned archive. Run fetch after configuring the manifest.\n' >&2
        return 1
    fi
    if ! grep -Fxq "version=${RIME_VENDOR_VERSION}" "${RECEIPT}" ||
        ! grep -Fxq "sha256=${RIME_VENDOR_ARCHIVE_SHA256}" "${RECEIPT}"; then
        printf 'RIME artifact receipt does not match the pinned manifest. Run fetch again.\n' >&2
        return 1
    fi
}

fetch_archive() {
    curl --fail --location --retry 3 --output "${ARCHIVE}" "${RIME_VENDOR_ARCHIVE_URL}"

    local received_sha
    received_sha="$(shasum -a 256 "${ARCHIVE}" | awk '{ print $1 }')"
    if [[ "${received_sha}" != "${RIME_VENDOR_ARCHIVE_SHA256}" ]]; then
        printf 'RIME vendor archive checksum mismatch: expected %s, received %s\n' \
            "${RIME_VENDOR_ARCHIVE_SHA256}" "${received_sha}" >&2
        exit 1
    fi

    rm -rf "${STAGING}"
    mkdir -p "${STAGING}"
    ditto -x -k "${ARCHIVE}" "${STAGING}"
    rm -rf "${VENDOR_DIR}"
    mv "${STAGING}" "${VENDOR_DIR}"
    verify_inventory
    printf 'version=%s\nsha256=%s\n' "${RIME_VENDOR_VERSION}" "${RIME_VENDOR_ARCHIVE_SHA256}" > "${RECEIPT}"
    verify_receipt
}

case "${1:-verify}" in
    verify)
        require_pinned_manifest
        verify_inventory
        verify_receipt
        ;;
    fetch)
        require_pinned_manifest
        if verify_inventory >/dev/null 2>&1 && verify_receipt >/dev/null 2>&1; then
            verify_inventory
            verify_receipt
        else
            fetch_archive
        fi
        ;;
    *)
        printf 'Usage: %s [verify|fetch]\n' "$0" >&2
        exit 64
        ;;
esac
