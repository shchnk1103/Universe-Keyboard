#!/bin/sh

set -eu

# Xcode Cloud exposes the primary checkout explicitly. The local fallback keeps
# this script reproducible before an account or Cloud workflow is available.
SCRIPT_DIRECTORY=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPOSITORY_ROOT=${CI_PRIMARY_REPOSITORY_PATH:-"$(dirname -- "${SCRIPT_DIRECTORY}")"}
VENDOR_BOOTSTRAP="${REPOSITORY_ROOT}/scripts/ensure_rime_vendor.sh"

if [ ! -f "${VENDOR_BOOTSTRAP}" ]; then
    printf 'Missing pinned RIME vendor bootstrap: %s\n' "${VENDOR_BOOTSTRAP}" >&2
    exit 1
fi

printf 'Preparing manifest-pinned RIME artifacts for the Xcode build.\n'
/bin/bash "${VENDOR_BOOTSTRAP}" fetch
printf 'RIME artifacts are ready.\n'
