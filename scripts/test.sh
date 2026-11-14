#!/bin/bash
#
# Runs every package's tests on macOS.
#
#   scripts/test.sh                 everything
#   scripts/test.sh <Name>          one of StarfoldShared, XboxKit, StreamKit
#
# XCODE_BUILD_ROOT overrides where DerivedData goes (default: Xcode's DerivedData folder).
# The last line is always RESULT: ... so tools can read it.

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DERIVED_DATA="${XCODE_BUILD_ROOT:-$HOME/Library/Developer/Xcode/DerivedData}/Starfold-cli"
ONLY="${1:-}"

failed=()
total=0

run() {
  local name="$1"
  shift
  [[ -n "$ONLY" && "$ONLY" != "$name" ]] && return
  local log
  log="$(mktemp)"
  echo "testing $name"
  if xcodebuild test "$@" >"$log" 2>&1; then
    local count
    count="$(grep -Eo 'Test run with [0-9]+ tests' "$log" | grep -Eo '[0-9]+' \
      | awk '{ sum += $1 } END { print sum + 0 }')"
    total=$((total + ${count:-0}))
    echo "  passed ${count:-0}"
  else
    failed+=("$name")
    grep -E "error:|✘|recorded an issue" "$log" | sort -u | head -20
  fi
  rm -f "$log"
}

for dir in "$ROOT"/Packages/*/; do
  name="$(basename "$dir")"
  scheme="$name"
  cd "$dir" || exit 1
  if xcodebuild -list 2>/dev/null | grep -qx "        $name-Package"; then
    scheme="$name-Package"
  fi
  run "$name" -scheme "$scheme" -destination 'platform=macOS' \
    -derivedDataPath "$DERIVED_DATA-$name"
  cd "$ROOT" || exit 1
done

if [[ ${#failed[@]} -gt 0 ]]; then
  echo "RESULT: TESTS FAILED in ${failed[*]}"
  exit 1
fi
echo "RESULT: TESTS SUCCEEDED count=$total"
