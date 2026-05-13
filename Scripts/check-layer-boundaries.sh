#!/bin/bash

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

check_absent() {
  local label="$1"
  local target="$2"
  shift 2

  local pattern
  local matches=""

  for pattern in "$@"; do
    local result
    result="$(rg -n "import ${pattern}\$" "$target" -g '*.swift' || true)"
    if [[ -n "$result" ]]; then
      matches+="${result}"$'\n'
    fi
  done

  if [[ -n "$matches" ]]; then
    echo "[FAIL] ${label}"
    printf '%s' "$matches"
    exit 1
  fi
}

check_absent \
  "Layers root module must stay composition-only" \
  "$ROOT/Layers/Sources" \
  "SwiftUI" "InnoFlow" "InnoRouter" "InnoNetwork"

check_absent \
  "App must not import layer implementation modules directly" \
  "$ROOT/App" \
  "Data" "Remote"

check_absent \
  "App must not import leaf feature modules directly" \
  "$ROOT/App" \
  "EntireTabFeature" "PeopleFeature" "PostsFeature" "SettingsFeature"

check_absent \
  "Features root composition must not import lower layers directly" \
  "$ROOT/Features/Sources" \
  "Data" "Remote" "Layers"

check_absent \
  "Features root must compose only router modules" \
  "$ROOT/Features/Sources" \
  "PeopleFeatureUI" "PeopleFeatureLogic" "PostsFeatureUI" "PostsFeatureLogic" \
  "SettingsFeatureUI" "SettingsFeatureLogic" "EntireTabFeatureUI" "EntireTabFeatureLogic"

for feature in PeopleFeature PostsFeature SettingsFeature EntireTabFeature; do
  check_absent \
    "${feature} Logic must not import UI or routing frameworks" \
    "$ROOT/Features/${feature}/Logics" \
    "SwiftUI" "InnoRouter" "Data" "Remote" "Layers"

  check_absent \
    "${feature} UI must not import lower layers or router framework" \
    "$ROOT/Features/${feature}/UIs" \
    "Domain" "Data" "Remote" "Layers" "InnoRouter"

  check_absent \
    "${feature} Router must not import lower layers directly" \
    "$ROOT/Features/${feature}/Router" \
    "Data" "Remote" "Layers"
done

check_absent \
  "PeopleFeature Router must not import sibling or parent routers" \
  "$ROOT/Features/PeopleFeature/Router" \
  "PostsFeatureRouter" "SettingsFeatureRouter" "EntireTabFeatureRouter" "Features"

check_absent \
  "PostsFeature Router must not import sibling or parent routers" \
  "$ROOT/Features/PostsFeature/Router" \
  "PeopleFeatureRouter" "SettingsFeatureRouter" "EntireTabFeatureRouter" "Features"

check_absent \
  "SettingsFeature Router must not import sibling or parent routers" \
  "$ROOT/Features/SettingsFeature/Router" \
  "PeopleFeatureRouter" "PostsFeatureRouter" "EntireTabFeatureRouter" "Features"

check_absent \
  "Domain must not import lower layers" \
  "$ROOT/Layers/Domain" \
  "Data" "Remote" "Layers"

check_absent \
  "Remote must not import Domain directly" \
  "$ROOT/Layers/Remote/Sources" \
  "Domain"

if rg -n '\.layer\(\.domain\)' "$ROOT/Layers/Remote/Project.swift" >/dev/null 2>&1; then
  echo "[FAIL] Remote target must not depend on Domain"
  rg -n '\.layer\(\.domain\)' "$ROOT/Layers/Remote/Project.swift"
  exit 1
fi

echo "[PASS] Layer boundary imports look good."
