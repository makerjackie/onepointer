#!/bin/bash
# Run the standalone logic tests (no Xcode test target required).
# Usage: ./scripts/run-tests.sh
set -e

cd "$(dirname "$0")/.."

SDK=$(xcrun --show-sdk-path --sdk macosx)
OUT=$(mktemp -d)/geomtests

echo "Building tests..."
swiftc -parse-as-library -sdk "$SDK" \
    MouseHighlighter/Core/Geometry.swift \
    Tests/GeometryTests.swift \
    -o "$OUT"

echo "Running tests..."
"$OUT"
