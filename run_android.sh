#!/usr/bin/env bash
set -euo pipefail

# Quick helper to build & run the app on Android (emulator or device)
# Usage: ./run_android.sh [--release]

FLUTTER=~/flutter/bin/flutter
MODE=debug
if [[ ${1:-} == "--release" ]]; then
  MODE=release
fi

# Ensure Android SDK is available
if ! "$FLUTTER" doctor --android-licenses >/dev/null 2>&1; then
  echo "Make sure Android SDK & Android Studio are installed and configured."
fi

echo "Running Dairify on Android ($MODE)..."
"$FLUTTER" run -d android --${MODE}
