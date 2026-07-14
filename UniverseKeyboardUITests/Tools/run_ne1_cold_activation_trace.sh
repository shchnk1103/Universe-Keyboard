#!/bin/zsh

set -euo pipefail

readonly tools_dir="${0:A:h}"
readonly repository_root="${tools_dir:h:h}"
readonly script_name="${0:t}"
readonly project_path="$repository_root/Universe Keyboard.xcodeproj"
readonly scheme="UniverseKeyboardUITests"
readonly test_identifier="UniverseKeyboardUITests/NativeExperienceKeyboardAutomationFeasibilityTests/testNE1ColdActivationAndFirstInput"

instrument=""
simulator_id=""
samples=1
time_limit="10s"
completion_timeout=60
configuration="Release"
output_root=""

usage() {
    print -r -- "Usage: $script_name --instrument <time-profiler|system-trace|all> --simulator-id <UDID> [options]"
    print -r -- ""
    print -r -- "Options:"
    print -r -- "  --samples <count>       Number of isolated cold runs per instrument (default: 1)"
    print -r -- "  --time-limit <duration> xctrace duration such as 10s or 20s (default: 10s)"
    print -r -- "  --completion-timeout <seconds> Host wait for xctrace completion (default: 60)"
    print -r -- "  --configuration <name> Xcode configuration (default: Release)"
    print -r -- "  --output-root <path>    Artifact root (default: build/ne1-traces/<timestamp>)"
}

while (( $# > 0 )); do
    case "$1" in
        --instrument)
            instrument="${2:-}"
            shift 2
            ;;
        --simulator-id)
            simulator_id="${2:-}"
            shift 2
            ;;
        --samples)
            samples="${2:-}"
            shift 2
            ;;
        --time-limit)
            time_limit="${2:-}"
            shift 2
            ;;
        --completion-timeout)
            completion_timeout="${2:-}"
            shift 2
            ;;
        --configuration)
            configuration="${2:-}"
            shift 2
            ;;
        --output-root)
            output_root="${2:-}"
            shift 2
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            print -u2 -- "Unknown argument: $1"
            usage >&2
            exit 2
            ;;
    esac
done

if [[ "$instrument" != "time-profiler" && "$instrument" != "system-trace" && "$instrument" != "all" ]]; then
    print -u2 -- "--instrument must be time-profiler, system-trace, or all."
    exit 2
fi
if [[ -z "$simulator_id" ]]; then
    print -u2 -- "--simulator-id is required."
    exit 2
fi
if [[ "$samples" != <1-> ]]; then
    print -u2 -- "--samples must be a positive integer."
    exit 2
fi
if [[ "$completion_timeout" != <1-> ]]; then
    print -u2 -- "--completion-timeout must be a positive integer."
    exit 2
fi

if [[ -z "$output_root" ]]; then
    output_root="$repository_root/build/ne1-traces/$(date -u +%Y%m%dT%H%M%SZ)"
elif [[ "$output_root" != /* ]]; then
    output_root="$repository_root/$output_root"
fi

readonly derived_data_path="$repository_root/build/DerivedData/NE1ColdTraceBuild"
mkdir -p "$output_root"

readonly simulator_json="$(xcrun simctl list devices --json)"
readonly simulator_record="$(print -r -- "$simulator_json" | /usr/bin/jq -c --arg id "$simulator_id" '
    .devices
    | to_entries[]
    | .key as $runtime
    | .value[]
    | select(.udid == $id)
    | {name: .name, state: .state, runtime: $runtime}
')"
if [[ -z "$simulator_record" ]]; then
    print -u2 -- "Simulator not found: $simulator_id"
    exit 1
fi
if [[ "$(print -r -- "$simulator_record" | /usr/bin/jq -r '.state')" != "Booted" ]]; then
    print -u2 -- "Simulator must already be booted: $simulator_id"
    exit 1
fi

readonly simulator_name="$(print -r -- "$simulator_record" | /usr/bin/jq -r '.name')"
readonly runtime_identifier="$(print -r -- "$simulator_record" | /usr/bin/jq -r '.runtime')"
runtime_version="${runtime_identifier##*.iOS-}"
runtime_version="${runtime_version//-/.}"
readonly runtime_version

readonly xctrace_devices="$(xcrun xctrace list devices)"
if ! print -r -- "$xctrace_devices" | /usr/bin/grep -Fq "($simulator_id)"; then
    print -u2 -- "xctrace does not expose simulator $simulator_id."
    exit 1
fi

readonly xctrace_templates="$(xcrun xctrace list templates)"
for required_template in "Time Profiler" "System Trace"; do
    if ! print -r -- "$xctrace_templates" | /usr/bin/grep -Fxq "$required_template"; then
        print -u2 -- "Required xctrace template is unavailable: $required_template"
        exit 1
    fi
done

readonly build_log="$output_root/build-for-testing.log"
xcodebuild \
    -project "$project_path" \
    -scheme "$scheme" \
    -configuration "$configuration" \
    -destination "platform=iOS Simulator,id=$simulator_id" \
    -derivedDataPath "$derived_data_path" \
    CODE_SIGNING_ALLOWED=NO \
    SWIFT_STRICT_CONCURRENCY=complete \
    SWIFT_SUPPRESS_WARNINGS=NO \
    SWIFT_TREAT_WARNINGS_AS_ERRORS=YES \
    build-for-testing > "$build_log" 2>&1

wait_for_process_completion() {
    local pid="$1"
    local timeout_seconds="$2"
    local deadline=$(( SECONDS + timeout_seconds ))

    while /bin/kill -0 "$pid" >/dev/null 2>&1; do
        (( SECONDS >= deadline )) && return 1
        /bin/sleep 0.1
    done
    return 0
}

stop_process() {
    local pid="$1"

    /bin/kill -INT "$pid" >/dev/null 2>&1 || true
    wait_for_process_completion "$pid" 15 || true
    if /bin/kill -0 "$pid" >/dev/null 2>&1; then
        /bin/kill -TERM "$pid" >/dev/null 2>&1 || true
        wait_for_process_completion "$pid" 5 || true
    fi
    if /bin/kill -0 "$pid" >/dev/null 2>&1; then
        /bin/kill -KILL "$pid" >/dev/null 2>&1 || true
    fi
    wait "$pid" >/dev/null 2>&1 || true
}

wait_for_log_marker() {
    local log_path="$1"
    local marker="$2"
    local process_pid="$3"
    local timeout_seconds="$4"
    local deadline=$(( SECONDS + timeout_seconds ))

    while (( SECONDS < deadline )); do
        if [[ -f "$log_path" ]] && /usr/bin/grep -Fq "$marker" "$log_path"; then
            return 0
        fi
        if ! /bin/kill -0 "$process_pid" >/dev/null 2>&1; then
            return 1
        fi
        /bin/sleep 0.1
    done
    return 1
}

write_metadata() {
    local metadata_path="$1"
    local run_id="$2"
    local template="$3"
    local sample_index="$4"
    local started_at="$5"
    local finished_at="$6"
    local trace_status="$7"
    local test_status="$8"

    {
        print -r -- "Evidence ID: $run_id"
        print -r -- "Environment Cell: NE1-ENV-001"
        print -r -- "Host App: Messages"
        print -r -- "Device: $simulator_name Simulator"
        print -r -- "Simulator UDID: $simulator_id"
        print -r -- "OS: iOS $runtime_version"
        print -r -- "Build Configuration: $configuration"
        print -r -- "Instrument: $template"
        print -r -- "Target: All Processes"
        print -r -- "Time Limit: $time_limit"
        print -r -- "Host Completion Timeout: ${completion_timeout}s"
        print -r -- "Sample Index: $sample_index"
        print -r -- "Activation State: Cold activation requested and fail-closed by XCTest"
        print -r -- "Started UTC: $started_at"
        print -r -- "Finished UTC: $finished_at"
        print -r -- "xctrace Exit Status: $trace_status"
        print -r -- "XCTest Exit Status: $test_status"
        print -r -- "Git HEAD: $(git -C "$repository_root" rev-parse HEAD)"
        print -r -- "Working Tree Dirty: $([[ -n "$(git -C "$repository_root" status --porcelain)" ]] && print yes || print no)"
        print -r -- "Xcode: $(xcodebuild -version | tr '\n' ' ')"
        print -r -- "Production Code Modified By Runner: No"
        print -r -- "Performance Conclusion Included: No"
    } > "$metadata_path"
}

active_pids=()
trace_preferences_domain=""
trace_run_token=""

cleanup_active_run() {
    for pid in $active_pids; do
        /bin/kill -TERM "$pid" >/dev/null 2>&1 || true
    done
    if [[ -n "$trace_preferences_domain" && -n "$trace_run_token" ]]; then
        xcrun simctl spawn "$simulator_id" defaults write "$trace_preferences_domain" \
            TraceFinishedToken -string "$trace_run_token" >/dev/null 2>&1 || true
    fi
}
trap cleanup_active_run EXIT INT TERM

run_one_sample() {
    local template="$1"
    local slug="$2"
    local sample_index="$3"
    local sample_number
    sample_number="$(printf '%03d' "$sample_index")"
    local run_id="NE1-ENV001-simulator${runtime_version}-messages-cold-auto-sample-${sample_number}-${slug}"
    local run_dir="$output_root/$run_id"
    local trace_path="$run_dir/$run_id.trace"
    local xcresult_path="$run_dir/$run_id.xcresult"
    trace_run_token="ne1.${slug}.${sample_number}.$(date +%s).$$"
    trace_preferences_domain="com.DoubleShy0N.UniverseKeyboardUITests.NE1TraceGate"
    local ui_ready_marker="NE1_TRACE_UI_READY:$trace_run_token"
    local started_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

    if [[ -e "$run_dir" ]]; then
        print -u2 -- "Refusing to overwrite existing run directory: $run_dir"
        return 1
    fi
    mkdir -p "$run_dir"

    NE1_SIMULATOR_UDID="$simulator_id" \
        /bin/zsh "$tools_dir/prepare_simulator_keyboard_baseline.sh" \
        > "$run_dir/baseline-preparation.log" 2>&1

    xcrun simctl spawn "$simulator_id" defaults write "$trace_preferences_domain" \
        TraceStartedToken -string "pending-$trace_run_token"
    xcrun simctl spawn "$simulator_id" defaults write "$trace_preferences_domain" \
        TraceFinishedToken -string "pending-$trace_run_token"

    export NE1_SKIP_KEYBOARD_BASELINE_PREACTION=1
    export TEST_RUNNER_NE1_COLD_ACTIVATION_RUN=1
    export TEST_RUNNER_NE1_TRACE_HANDSHAKE=1
    export TEST_RUNNER_NE1_TRACE_RUN_TOKEN="$trace_run_token"
    export TEST_RUNNER_NE1_TRACE_PREFERENCES_DOMAIN="$trace_preferences_domain"
    xcodebuild \
        -project "$project_path" \
        -scheme "$scheme" \
        -configuration "$configuration" \
        -destination "platform=iOS Simulator,id=$simulator_id" \
        -derivedDataPath "$derived_data_path" \
        -resultBundlePath "$xcresult_path" \
        CODE_SIGNING_ALLOWED=NO \
        SWIFT_STRICT_CONCURRENCY=complete \
        SWIFT_SUPPRESS_WARNINGS=NO \
        SWIFT_TREAT_WARNINGS_AS_ERRORS=YES \
        -only-testing:"$test_identifier" \
        test-without-building > "$run_dir/xcodebuild-test.log" 2>&1 &
    local test_pid=$!
    unset \
        NE1_SKIP_KEYBOARD_BASELINE_PREACTION \
        TEST_RUNNER_NE1_COLD_ACTIVATION_RUN \
        TEST_RUNNER_NE1_TRACE_HANDSHAKE \
        TEST_RUNNER_NE1_TRACE_RUN_TOKEN \
        TEST_RUNNER_NE1_TRACE_PREFERENCES_DOMAIN
    active_pids=($test_pid)

    if ! wait_for_log_marker "$run_dir/xcodebuild-test.log" "$ui_ready_marker" "$test_pid" 60; then
        print -u2 -- "XCTest did not signal the ready Apple-keyboard baseline: $run_id"
        return 1
    fi

    xcrun xctrace record \
        --template "$template" \
        --device "$simulator_id" \
        --all-processes \
        --time-limit "$time_limit" \
        --output "$trace_path" \
        --no-prompt > "$run_dir/xctrace.log" 2>&1 &
    local trace_pid=$!
    active_pids=($test_pid $trace_pid)

    if ! wait_for_log_marker "$run_dir/xctrace.log" "Starting recording with the $template template." "$trace_pid" 30; then
        print -u2 -- "xctrace did not report recording start: $run_id"
        return 1
    fi
    xcrun simctl spawn "$simulator_id" defaults write "$trace_preferences_domain" \
        TraceStartedToken -string "$trace_run_token"

    local trace_status=0
    if wait_for_process_completion "$trace_pid" "$completion_timeout"; then
        wait "$trace_pid" || trace_status=$?
    else
        print -u2 -- "xctrace exceeded the host completion timeout: $run_id"
        stop_process "$trace_pid"
        trace_status=124
    fi
    active_pids=($test_pid)
    xcrun simctl spawn "$simulator_id" defaults write "$trace_preferences_domain" \
        TraceFinishedToken -string "$trace_run_token"

    local test_status=0
    wait "$test_pid" || test_status=$?
    active_pids=()
    trace_preferences_domain=""
    trace_run_token=""

    local finished_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    write_metadata \
        "$run_dir/$run_id-metadata.txt" \
        "$run_id" \
        "$template" \
        "$sample_index" \
        "$started_at" \
        "$finished_at" \
        "$trace_status" \
        "$test_status"

    if (( trace_status != 0 || test_status != 0 )); then
        print -u2 -- "Cold trace run failed: $run_id (xctrace=$trace_status XCTest=$test_status)"
        return 1
    fi
    if [[ ! -d "$trace_path" || ! -d "$xcresult_path" ]]; then
        print -u2 -- "Expected trace or xcresult bundle is missing: $run_id"
        return 1
    fi

    (
        cd "$run_dir"
        find "$run_id.trace" -type f -exec shasum -a 256 {} + | LC_ALL=C sort -k2
    ) > "$run_dir/$run_id-trace-bundle.sha256"
    (
        cd "$run_dir"
        find "$run_id.xcresult" -type f -exec shasum -a 256 {} + | LC_ALL=C sort -k2
    ) > "$run_dir/$run_id-xcresult-bundle.sha256"
    (
        cd "$run_dir"
        shasum -a 256 \
            "$run_id-metadata.txt" \
            "$run_id-trace-bundle.sha256" \
            "$run_id-xcresult-bundle.sha256" \
            baseline-preparation.log \
            xcodebuild-test.log \
            xctrace.log
    ) > "$run_dir/$run_id-artifacts.sha256"

    print -r -- "Completed $run_id"
}

templates=()
if [[ "$instrument" == "time-profiler" || "$instrument" == "all" ]]; then
    templates+=("Time Profiler|time-profiler")
fi
if [[ "$instrument" == "system-trace" || "$instrument" == "all" ]]; then
    templates+=("System Trace|system-trace")
fi

for template_entry in $templates; do
    template="${template_entry%%|*}"
    slug="${template_entry##*|}"
    for sample_index in $(/usr/bin/seq 1 "$samples"); do
        run_one_sample "$template" "$slug" "$sample_index"
    done
done

trap - EXIT INT TERM
print -r -- "NE1 cold trace artifacts: $output_root"
