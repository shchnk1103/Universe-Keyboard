#!/bin/bash

set -u
set -o pipefail

if [ "$#" -lt 2 ]; then
    echo "usage: $0 OUTPUT_PATH SCOPE_PATH..." >&2
    exit 64
fi

output_path="$1"
shift

scanner_id="T9RESP-CANARY-PRIVACY-v1/scanner-v8"
scanner_sha="$(shasum -a 256 "$0" | awk '{print $1}')"
pattern='raw(Input|Text)[=:]|pinyin[=:]|candidate(Text)?[=:]|committed(Text)?[=:]|host(Text)?[=:]|surrounding(Text)?[=:]|clipboard(Text)?[=:]|marked(Text)?[=:]|document(Context)?[=:]'
temporary_output="$(mktemp /private/tmp/canary-privacy-v8.XXXXXX)"
status=0

{
    echo "scannerID=$scanner_id"
    echo "scannerSHA256=$scanner_sha"
    echo "allowListVersion=T9RESP-CANARY-PRIVACY-v1"
    echo "scopeRule=textual command logs, xunit, xcresult contents, command receipts, summaries and inventories; build products are hash-only"
    echo "prohibitedPatternSHA256=$(printf '%s' "$pattern" | shasum -a 256 | awk '{print $1}')"
    echo "rawMatchedContentRetained=false"

    for scope_path in "$@"; do
        if [ ! -e "$scope_path" ]; then
            echo "scope=$(basename "$scope_path") status=missing"
            status=1
            continue
        fi

        hit_count="$(
            rg -a -i --count-matches -- "$pattern" "$scope_path" 2>/dev/null \
                | awk -F: '{sum += $NF} END {print sum + 0}'
        )"
        scope_sha="not-applicable-directory"
        if [ -f "$scope_path" ]; then
            scope_sha="$(shasum -a 256 "$scope_path" | awk '{print $1}')"
        fi
        echo "scope=$(basename "$scope_path") sha256=$scope_sha prohibitedHitCount=$hit_count"
        if [ "$hit_count" -ne 0 ]; then
            status=1
        fi
    done

    if [ "$status" -eq 0 ]; then
        echo "verdict=pass"
    else
        echo "verdict=quarantine-blocked"
    fi
} > "$temporary_output"

mv "$temporary_output" "$output_path"
exit "$status"
