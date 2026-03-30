#!/bin/bash

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORKSPACE_ROOT="$(cd "$ROOT/.." && pwd)"
INNODI_ROOT="${INNODI_ROOT:-$WORKSPACE_ROOT/InnoDI}"

if [[ ! -d "$INNODI_ROOT" ]]; then
  echo "[FAIL] InnoDI root not found at: $INNODI_ROOT"
  echo "Set INNODI_ROOT to your local InnoDI checkout."
  exit 1
fi

command="${1:-validate}"

case "$command" in
  validate)
    shift || true
    (
      cd "$INNODI_ROOT"
      swift run InnoDI-DependencyGraph --root "$ROOT" --validate-dag "$@"
    )
    ;;
  graph)
    format="${2:-mermaid}"
    output="${3:-$ROOT/Derived/di-graph.$([[ "$format" == "dot" ]] && echo "dot" || echo "mmd")}"
    mkdir -p "$(dirname "$output")"
    (
      cd "$INNODI_ROOT"
      swift run InnoDI-DependencyGraph --root "$ROOT" --format "$format" --output "$output"
    )
    echo "[PASS] DI graph generated at $output"
    ;;
  *)
    echo "Usage: $0 [validate|graph] [format] [output]"
    exit 1
    ;;
esac
