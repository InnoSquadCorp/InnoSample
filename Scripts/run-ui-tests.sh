#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ui_simulator_id="${SIMULATOR_ID:-}"
owns_simulator=false
if [[ -z "$ui_simulator_id" ]]; then
    ui_simulator_id="$(python3 "$ROOT/Scripts/select-ui-simulator.py")"
    owns_simulator=true
fi
cleanup() {
    if [[ "$owns_simulator" == true ]]; then
        xcrun simctl shutdown "$ui_simulator_id" >/dev/null 2>&1 || true
    fi
}
trap cleanup EXIT

echo "Running native UI regressions on $ui_simulator_id"
ui_command=(xcodebuild -skipPackagePluginValidation -skipMacroValidation
    -workspace "$ROOT/InnoSample.xcworkspace" -scheme InnoSampleApp
    -destination "platform=iOS Simulator,id=$ui_simulator_id"
    -derivedDataPath "${DERIVED_DATA:-/tmp/innosample-make}"
    -parallel-testing-enabled NO -test-timeouts-enabled YES
    -default-test-execution-time-allowance 120 -maximum-test-execution-time-allowance 180)
if [[ -n "${UI_TEST_RESULT_BUNDLE:-}" ]]; then
    ui_command+=(-resultBundlePath "$UI_TEST_RESULT_BUNDLE")
fi
ui_command+=(-only-testing:InnoSampleAppUITests test)
"${ui_command[@]}"
