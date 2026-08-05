#!/bin/bash

set -u
set -o pipefail

if [ "$#" -ne 5 ]; then
    echo "usage: $0 ARCHIVE_ROOT OUTPUT MANIFEST_PATH RUN_HEADER_BINDING PRIVACY_SCANNER" >&2
    exit 64
fi

archive_root="$1"
output_path="$2"
manifest_path="$3"
run_header_binding="$4"
privacy_scanner="$5"
temporary_output="$(mktemp /private/tmp/canary-inventory-v8.XXXXXX)"

{
    echo "inventorySchema=CANARY-001-QEF-ARTIFACT-INVENTORY-v8"
    echo "generatedAt=$(date '+%Y-%m-%dT%H:%M:%S%z')"
    echo "timezone=Asia/Shanghai"
    echo "archiveRoot=$archive_root"
    echo "manifestPath=$manifest_path"
    echo "manifestSHA256=$(shasum -a 256 "$manifest_path" | awk '{print $1}')"
    echo "runHeaderBinding=$run_header_binding"
    echo "runHeaderBindingSHA256=$(shasum -a 256 "$run_header_binding" | awk '{print $1}')"
    echo "inventoryScriptSHA256=$(shasum -a 256 "$0" | awk '{print $1}')"
    echo "privacyScannerSHA256=$(shasum -a 256 "$privacy_scanner" | awk '{print $1}')"

    find "$archive_root" -type f ! -name "$(basename "$output_path")" ! -name "$(basename "$output_path").sha256" -print \
        | LC_ALL=C sort \
        | while IFS= read -r artifact; do
            relative_path="${artifact#"$archive_root"/}"
            echo "artifact=$relative_path|sha256=$(shasum -a 256 "$artifact" | awk '{print $1}')|bytes=$(stat -f '%z' "$artifact")"
        done
} > "$temporary_output"

mv "$temporary_output" "$output_path"
shasum -a 256 "$output_path" > "$output_path.sha256"
shasum -a 256 -c "$output_path.sha256" > "$output_path.verify.txt"
"$privacy_scanner" "$output_path.privacy.txt" "$output_path"
