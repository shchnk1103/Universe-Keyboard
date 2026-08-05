#!/bin/bash

set -u
set -o pipefail

if [ "$#" -ne 2 ]; then
    echo "usage: $0 XCODE_LOG OUTPUT" >&2
    exit 64
fi

log_path="$1"
output_path="$2"
temporary_output="$(mktemp /private/tmp/canary-skip-classifier-v8.XXXXXX)"

awk '
    BEGIN {
        total = 0
        environment = 0
        provenance = 0
        other = 0
        current = "unknown"
        print "schema=CANARY-001-SKIP-CLASSIFICATION-v8"
        print "rule=every XCTest skip is NotObserved and classified without averaging"
    }
    /Test Case .* started/ {
        current = $0
        sub(/^.*Test Case '\''/, "", current)
        sub(/'\'' started.*$/, "", current)
    }
    /Test skipped -/ {
        total += 1
        category = "other"
        if ($0 ~ /immutable 40-character lowercase S4 commit/) {
            category = "provenanceCommit"
            provenance += 1
        } else if ($0 ~ /[Ss]et .*DIR|directories|runtime|fixture|schema|Lua files/) {
            category = "environmentFixture"
            environment += 1
        } else {
            other += 1
        }
        printf "skip[%d].test=%s\n", total, current
        printf "skip[%d].classification=%s\n", total, category
        print "skip[" total "].coverage=NotObserved"
    }
    END {
        print "total=" total
        print "environmentFixture=" environment
        print "provenanceCommit=" provenance
        print "other=" other
        if (other > 0) {
            print "verdict=blockedUnknownSkip"
            exit 1
        }
        print "verdict=pass"
    }
' "$log_path" > "$temporary_output"
status="$?"
mv "$temporary_output" "$output_path"
exit "$status"
