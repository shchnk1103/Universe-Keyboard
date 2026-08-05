#!/bin/bash

set -u
set -o pipefail

if [ "$#" -lt 6 ]; then
    echo "usage: $0 COMMAND_ID LOG RECEIPT PRIVACY_SUMMARY SCANNER [artifact options] -- COMMAND..." >&2
    exit 64
fi

command_id="$1"
log_path="$2"
receipt_path="$3"
privacy_summary_path="$4"
privacy_scanner="$5"
shift 5

artifact_kinds=()
artifact_sources=()
artifact_archives=()
privacy_scopes=()

while [ "$#" -gt 0 ]; do
    case "$1" in
        --file|--binary)
            artifact_kinds+=("${1#--}")
            artifact_sources+=("$2")
            artifact_archives+=("")
            shift 2
            ;;
        --bundle)
            artifact_kinds+=("bundle")
            artifact_sources+=("$2")
            artifact_archives+=("$3")
            shift 3
            ;;
        --xcresult)
            artifact_kinds+=("xcresult")
            artifact_sources+=("$2")
            artifact_archives+=("$3|$4")
            shift 4
            ;;
        --privacy)
            privacy_scopes+=("$2")
            shift 2
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "unknown runner option: $1" >&2
            exit 64
            ;;
    esac
done

if [ "$#" -eq 0 ]; then
    echo "missing child command" >&2
    exit 64
fi

mkdir -p "$(dirname "$log_path")" "$(dirname "$receipt_path")" "$(dirname "$privacy_summary_path")"
start_time="$(date '+%Y-%m-%dT%H:%M:%S%z')"
/usr/bin/script -q "$log_path" "$@"
child_status="$?"
end_time="$(date '+%Y-%m-%dT%H:%M:%S%z')"

temporary_receipt="$(mktemp /private/tmp/canary-command-receipt-v8.XXXXXX)"
capture_status=0
{
    echo "receiptSchema=CANARY-001-QEF-COMMAND-RECEIPT-v8"
    echo "commandID=$command_id"
    echo "startTime=$start_time"
    echo "endTime=$end_time"
    echo "timezone=Asia/Shanghai"
    echo "exitCode=$child_status"
    printf "argv="
    printf "%q " "$@"
    echo

    index=0
    while [ "$index" -lt "${#artifact_kinds[@]}" ]; do
        kind="${artifact_kinds[$index]}"
        source_path="${artifact_sources[$index]}"
        archive_spec="${artifact_archives[$index]}"
        if [ ! -e "$source_path" ]; then
            echo "artifact[$index].kind=$kind"
            echo "artifact[$index].path=$source_path"
            echo "artifact[$index].status=missing"
            if [ "$child_status" -eq 0 ]; then
                capture_status=1
            fi
            index=$((index + 1))
            continue
        fi

        echo "artifact[$index].kind=$kind"
        echo "artifact[$index].path=$source_path"
        echo "artifact[$index].status=present"
        if [ "$kind" = "bundle" ]; then
            archive_path="$archive_spec"
            mkdir -p "$(dirname "$archive_path")"
            ditto -c -k --sequesterRsrc --keepParent "$source_path" "$archive_path"
            archive_status="$?"
            if [ "$archive_status" -ne 0 ]; then
                echo "artifact[$index].archiveStatus=failed"
                capture_status=1
            else
                echo "artifact[$index].archivePath=$archive_path"
                echo "artifact[$index].archiveSHA256=$(shasum -a 256 "$archive_path" | awk '{print $1}')"
                echo "artifact[$index].archiveBytes=$(stat -f '%z' "$archive_path")"
            fi
        elif [ "$kind" = "xcresult" ]; then
            archive_path="${archive_spec%%|*}"
            summary_path="${archive_spec#*|}"
            mkdir -p "$(dirname "$archive_path")" "$(dirname "$summary_path")"
            ditto -c -k --sequesterRsrc --keepParent "$source_path" "$archive_path"
            archive_status="$?"
            if [ "$archive_status" -ne 0 ]; then
                echo "artifact[$index].archiveStatus=failed"
                capture_status=1
            else
                echo "artifact[$index].archivePath=$archive_path"
                echo "artifact[$index].archiveSHA256=$(shasum -a 256 "$archive_path" | awk '{print $1}')"
                echo "artifact[$index].archiveBytes=$(stat -f '%z' "$archive_path")"
            fi
            xcrun xcresulttool get test-results summary --path "$source_path" --compact > "$summary_path"
            summary_status="$?"
            if [ "$summary_status" -ne 0 ]; then
                echo "artifact[$index].summaryStatus=failed"
                capture_status=1
            else
                echo "artifact[$index].summaryPath=$summary_path"
                echo "artifact[$index].summarySHA256=$(shasum -a 256 "$summary_path" | awk '{print $1}')"
                echo "artifact[$index].summaryBytes=$(stat -f '%z' "$summary_path")"
            fi
        else
            echo "artifact[$index].sha256=$(shasum -a 256 "$source_path" | awk '{print $1}')"
            echo "artifact[$index].bytes=$(stat -f '%z' "$source_path")"
        fi
        index=$((index + 1))
    done
} > "$temporary_receipt"
mv "$temporary_receipt" "$receipt_path"

"$privacy_scanner" "$privacy_summary_path" "${privacy_scopes[@]}" "$receipt_path"
privacy_status="$?"
{
    echo "privacySummaryPath=$privacy_summary_path"
    echo "privacySummarySHA256=$(shasum -a 256 "$privacy_summary_path" | awk '{print $1}')"
    echo "privacyStatus=$privacy_status"
} >> "$receipt_path"

if [ "$child_status" -ne 0 ]; then
    exit "$child_status"
fi
if [ "$capture_status" -ne 0 ]; then
    exit 96
fi
if [ "$privacy_status" -ne 0 ]; then
    exit 97
fi
exit 0
