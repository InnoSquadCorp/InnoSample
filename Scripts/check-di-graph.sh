#!/bin/bash

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
INNODI_REMOTE_URL="https://github.com/InnoSquadCorp/InnoDI.git"
INNODI_RELEASE_REVISION="3263926f01ba8e1760e254402d3bd468c477ef5f"
INNODI_ROOT="${INNODI_ROOT:-}"
TEMP_ROOT=""

cleanup() {
  if [[ -n "$TEMP_ROOT" && -d "$TEMP_ROOT" ]]; then
    rm -rf "$TEMP_ROOT"
  fi
}

trap cleanup EXIT

if [[ -n "$INNODI_ROOT" ]]; then
  if [[ ! -d "$INNODI_ROOT" ]]; then
    echo "[FAIL] InnoDI override not found at: $INNODI_ROOT"
    exit 1
  fi
else
  TEMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/innosample-innodi.XXXXXX")"
  INNODI_ROOT="$TEMP_ROOT/InnoDI"

  git init -q "$INNODI_ROOT"
  git -C "$INNODI_ROOT" remote add origin "$INNODI_REMOTE_URL"
  git -C "$INNODI_ROOT" fetch -q --depth 1 origin "$INNODI_RELEASE_REVISION"
  git -C "$INNODI_ROOT" checkout -q --detach FETCH_HEAD

  resolved_revision="$(git -C "$INNODI_ROOT" rev-parse HEAD)"
  if [[ "$resolved_revision" != "$INNODI_RELEASE_REVISION" ]]; then
    echo "[FAIL] InnoDI revision mismatch: $resolved_revision"
    exit 1
  fi
fi

command="${1:-validate}"

case "$command" in
  validate)
    shift || true
    swift run --package-path "$INNODI_ROOT" InnoDI-DependencyGraph \
      --root "$ROOT" \
      --validate-dag \
      "$@"
    ;;
  graph)
    format="${2:-mermaid}"
    output="${3:-$ROOT/Derived/di-graph.$([[ "$format" == "dot" ]] && echo "dot" || echo "mmd")}"
    mkdir -p "$(dirname "$output")"
    swift run --package-path "$INNODI_ROOT" InnoDI-DependencyGraph \
      --root "$ROOT" \
      --format "$format" \
      --output "$output"
    echo "[PASS] DI graph generated at $output"
    ;;
  *)
    echo "Usage: $0 [validate|graph] [format] [output]"
    exit 1
    ;;
esac
