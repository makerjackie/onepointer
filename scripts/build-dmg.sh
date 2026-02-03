#!/bin/bash

# Build DMG for Mac Cursor Highlighter Thingy
# Usage: ./scripts/build-dmg.sh

set -e

# Configuration
APP_NAME="Mac Cursor Highlighter Thingy"
DMG_NAME="MacMouseHighlighter"
VERSION=$(grep -o 'MARKETING_VERSION = [^;]*' MouseHighlighter.xcodeproj/project.pbxproj | head -1 | cut -d '=' -f2 | tr -d ' ')
SCHEME="MouseHighlighter"
BUILD_DIR="build"
DMG_DIR="$BUILD_DIR/dmg"
RELEASE_DIR="$BUILD_DIR/Release"

echo "Building $APP_NAME v$VERSION..."

# Clean previous builds
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Build the app (Universal Binary)
echo "Building Universal Binary..."
xcodebuild -project MouseHighlighter.xcodeproj \
    -scheme "$SCHEME" \
    -configuration Release \
    -derivedDataPath "$BUILD_DIR/DerivedData" \
    -arch arm64 -arch x86_64 \
    ONLY_ACTIVE_ARCH=NO \
    BUILD_DIR="$BUILD_DIR" \
    clean build

# Verify the app was built
if [ ! -d "$RELEASE_DIR/$APP_NAME.app" ]; then
    echo "Error: App not found at $RELEASE_DIR/$APP_NAME.app"
    exit 1
fi

# Verify architectures
echo "Verifying architectures..."
lipo -info "$RELEASE_DIR/$APP_NAME.app/Contents/MacOS/$APP_NAME"

# Create DMG staging directory
echo "Creating DMG..."
mkdir -p "$DMG_DIR"
cp -R "$RELEASE_DIR/$APP_NAME.app" "$DMG_DIR/"

# Create symbolic link to Applications
ln -s /Applications "$DMG_DIR/Applications"

# Create DMG
DMG_FILE="$BUILD_DIR/${DMG_NAME}-${VERSION}.dmg"
hdiutil create -volname "$APP_NAME" \
    -srcfolder "$DMG_DIR" \
    -ov -format UDZO \
    "$DMG_FILE"

echo ""
echo "Build complete!"
echo "DMG: $DMG_FILE"
echo ""

# Show file info
ls -lh "$DMG_FILE"
