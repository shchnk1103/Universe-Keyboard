#!/usr/bin/env bash
# GitHub macos runners can answer xcodebuild before CoreSimulator has
# registered any devices. The destination name used by swift6-quality.yml is
# then missing, and the job fails before it compiles. Wait, and create one
# iPhone 17 Pro from an installed iOS runtime if the name is still absent.
set -euo pipefail

device_name="iPhone 17 Pro"
device_type="com.apple.CoreSimulator.SimDeviceType.iPhone-17-Pro"

find_device() {
  xcrun simctl list devices available -j | python3 -c '
import json, sys
wanted = sys.argv[1]
payload = json.load(sys.stdin)
for devices in payload.get("devices", {}).values():
    for device in devices:
        if device.get("name") == wanted and device.get("isAvailable", True):
            print(device.get("udid", ""))
            raise SystemExit(0)
raise SystemExit(1)
' "$device_name"
}

newest_ios_runtime() {
  xcrun simctl list runtimes available -j | python3 -c '
import json, sys
payload = json.load(sys.stdin)
runtimes = [
    runtime for runtime in payload.get("runtimes", [])
    if runtime.get("isAvailable") and str(runtime.get("identifier", "")).find("iOS") != -1
]
if not runtimes:
    raise SystemExit(1)
runtimes.sort(key=lambda runtime: str(runtime.get("version", "")))
print(runtimes[-1]["identifier"])
'
}

for attempt in 1 2 3 4 5 6; do
  if udid="$(find_device 2>/dev/null)"; then
    echo "Found ${device_name}: ${udid}"
    exit 0
  fi
  echo "Attempt ${attempt}: ${device_name} is not available yet."
  if runtime="$(newest_ios_runtime 2>/dev/null)"; then
    xcrun simctl create "$device_name" "$device_type" "$runtime" || true
  fi
  sleep 5
done

echo "Available devices:" >&2
xcrun simctl list devices available >&2 || true
echo "No ${device_name} simulator is available." >&2
exit 1
