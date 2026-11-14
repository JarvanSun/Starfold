#!/bin/bash
#
# Builds the apps.
#
#   scripts/build.sh                  every platform
#   scripts/build.sh <Scheme>         one app: StarfoldMac, StarfoldVision, StarfoldTV or StarfoldiOS
#
# XCODE_BUILD_ROOT overrides where DerivedData goes (default: Xcode's DerivedData folder).
# The last line is always RESULT: ... so tools can read it.

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DERIVED_DATA="${XCODE_BUILD_ROOT:-$HOME/Library/Developer/Xcode/DerivedData}/Starfold-cli"
ONLY="${1:-}"

failed=()

build() {
  local scheme="$1" destination="$2"
  [[ -n "$ONLY" && "$ONLY" != "$scheme" ]] && return
  local log
  log="$(mktemp)"
  echo "building $scheme"
  if xcodebuild build -project "$ROOT/Starfold.xcodeproj" -scheme "$scheme" \
    -destination "$destination" -derivedDataPath "$DERIVED_DATA" >"$log" 2>&1; then
    echo "  succeeded"
  else
    failed+=("$scheme")
    grep -E "error:" "$log" | sort -u | head -20
  fi
  rm -f "$log"
}

build StarfoldMac 'platform=macOS'
build StarfoldVision 'generic/platform=visionOS Simulator'
build StarfoldTV 'generic/platform=tvOS Simulator'
build StarfoldiOS 'generic/platform=iOS Simulator'

if [[ ${#failed[@]} -gt 0 ]]; then
  echo "RESULT: BUILD FAILED in ${failed[*]}"
  exit 1
fi
echo "RESULT: BUILD SUCCEEDED"
