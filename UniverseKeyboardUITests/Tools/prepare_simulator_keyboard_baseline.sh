#!/bin/zsh

set -euo pipefail

if [[ "${NE1_SKIP_KEYBOARD_BASELINE_PREACTION:-0}" == "1" ]]; then
    print -r -- "NE1 keyboard baseline pre-action skipped by the external trace runner."
    exit 0
fi

readonly english_keyboard="en_US@sw=QWERTY;hw=Automatic"
readonly chinese_keyboard="zh_Hans-Pinyin@sw=Pinyin-Simplified;hw=Automatic"
readonly universe_keyboard="com.DoubleShy0N.Universe-Keyboard.Keyboard"

resolve_simulator_udid() {
    if [[ -n "${NE1_SIMULATOR_UDID:-}" ]]; then
        print -r -- "$NE1_SIMULATOR_UDID"
        return
    fi

    if [[ -n "${TARGET_DEVICE_IDENTIFIER:-}" && "$TARGET_DEVICE_IDENTIFIER" != dvtdevice-* ]]; then
        print -r -- "$TARGET_DEVICE_IDENTIFIER"
        return
    fi

    local devices_json
    devices_json="$(xcrun simctl list devices booted --json)"

    local booted_count
    booted_count="$(print -r -- "$devices_json" | /usr/bin/jq '[
        .devices
        | to_entries[]
        | select(.key | contains("SimRuntime.iOS"))
        | .value[]
        | select(.state == "Booted")
    ] | length')"

    if [[ "$booted_count" != "1" ]]; then
        print -u2 -- "NE1 baseline preparation requires exactly one booted iOS Simulator when no target identifier is available; found $booted_count."
        return 1
    fi

    print -r -- "$devices_json" | /usr/bin/jq -r '
        .devices
        | to_entries[]
        | select(.key | contains("SimRuntime.iOS"))
        | .value[]
        | select(.state == "Booted")
        | .udid
    '
}

readonly simulator_udid="$(resolve_simulator_udid)"
readonly preferences_domain="com.apple.keyboard.preferences"

# Keep Universe Keyboard enabled, but make the first host-field activation use
# an Apple keyboard so the extension remains cold until the switcher selects it.
xcrun simctl spawn "$simulator_udid" defaults write "$preferences_domain" \
    KeyboardLastUsed -string "$english_keyboard"
xcrun simctl spawn "$simulator_udid" defaults write "$preferences_domain" \
    KeyboardLastUsedForLanguage -dict-add \
    ASCIICapable "$english_keyboard" \
    en_US "$english_keyboard" \
    NonASCII "$chinese_keyboard" \
    zh_Hans "$chinese_keyboard"
xcrun simctl spawn "$simulator_udid" defaults write "$preferences_domain" \
    KeyboardsCurrentAndNext -array \
    "$english_keyboard" \
    "$english_keyboard" \
    "$universe_keyboard"

# Messages and the keyboard services may cache the previous input mode. Their
# next launch must read the baseline written above before any composer is tapped.
xcrun simctl terminate "$simulator_udid" com.apple.MobileSMS >/dev/null 2>&1 || true
xcrun simctl spawn "$simulator_udid" /usr/bin/killall -TERM TextInputUIService >/dev/null 2>&1 || true
xcrun simctl spawn "$simulator_udid" /usr/bin/killall -TERM kbd >/dev/null 2>&1 || true

extension_process_pids() {
    /bin/ps -A \
        | /usr/bin/awk -v simulator_udid="$simulator_udid" '
            index($0, "/Devices/" simulator_udid "/") > 0 && index($0, "/Universe Keyboard.app/PlugIns/Keyboard.appex/Keyboard") > 0 {
                print $1
            }
        '
}

for pid in ${(f)"$(extension_process_pids)"}; do
    /bin/kill -TERM "$pid" >/dev/null 2>&1 || true
done

for _ in {1..30}; do
    [[ -z "$(extension_process_pids)" ]] && break
    /bin/sleep 0.1
done

readonly remaining_extension_pids="$(extension_process_pids)"
if [[ -n "$remaining_extension_pids" ]]; then
    print -u2 -- "NE1 baseline preparation failed: Universe Keyboard Extension remains resident (pid(s): $remaining_extension_pids)."
    exit 1
fi

readonly preferences_file="$(mktemp -t ne1-keyboard-preferences)"
trap 'rm -f "$preferences_file"' EXIT
xcrun simctl spawn "$simulator_udid" defaults export "$preferences_domain" - > "$preferences_file"

readonly actual_current="$(/usr/bin/plutil -extract KeyboardsCurrentAndNext.0 raw -o - "$preferences_file")"
readonly actual_last_used="$(/usr/bin/plutil -extract KeyboardLastUsed raw -o - "$preferences_file")"

if [[ "$actual_current" != "$english_keyboard" || "$actual_last_used" != "$english_keyboard" ]]; then
    print -u2 -- "NE1 baseline preparation failed: current='$actual_current', lastUsed='$actual_last_used'."
    exit 1
fi

print -r -- "NE1 keyboard baseline prepared: simulator=$simulator_udid current=$actual_current next=$universe_keyboard extensionResident=no"
