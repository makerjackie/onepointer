#!/bin/bash

set -euo pipefail

cd "$(dirname "$0")/.."

if ! command -v xcodegen >/dev/null 2>&1; then
    echo "error: XcodeGen is required (brew install xcodegen)." >&2
    exit 1
fi

xcodegen generate
xcodebuild test \
    -project OnePointer.xcodeproj \
    -scheme OnePointer \
    -configuration Debug \
    -derivedDataPath .build/DerivedData \
    CODE_SIGNING_ALLOWED=NO
