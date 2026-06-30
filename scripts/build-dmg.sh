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

# --- Code signing (optional) ---------------------------------------------------
# For a clean install on other Macs (no "unidentified developer" / "damaged" warning),
# sign with a Developer ID Application certificate and notarize. Set:
#   DEVELOPER_ID_APP="Developer ID Application: Your Name (TEAMID)"
#   NOTARY_PROFILE="notary-profile"   # created once: xcrun notarytool store-credentials
# If DEVELOPER_ID_APP is unset, the app is left as built by Xcode (likely unsigned/ad-hoc):
# it runs locally, but other users must right-click → Open on first launch.
APP_PATH="$RELEASE_DIR/$APP_NAME.app"
ENTITLEMENTS="MouseHighlighter/MouseHighlighter.entitlements"

if [ -n "$DEVELOPER_ID_APP" ]; then
    echo "Signing app with Developer ID: $DEVELOPER_ID_APP"
    codesign --force --deep --options runtime --timestamp \
        --entitlements "$ENTITLEMENTS" \
        --sign "$DEVELOPER_ID_APP" \
        "$APP_PATH"
    codesign --verify --deep --strict --verbose=2 "$APP_PATH"
else
    echo "WARNING: DEVELOPER_ID_APP not set — the app is NOT Developer ID signed."
    echo "         It runs locally, but other users must right-click → Open on first"
    echo "         launch (Gatekeeper blocks non-notarized downloads)."
fi

# Create DMG staging directory
echo "Creating DMG..."
mkdir -p "$DMG_DIR"
cp -R "$APP_PATH" "$DMG_DIR/"

# Create symbolic link to Applications
ln -s /Applications "$DMG_DIR/Applications"

# Create DMG
DMG_FILE="$BUILD_DIR/${DMG_NAME}-${VERSION}.dmg"
hdiutil create -volname "$APP_NAME" \
    -srcfolder "$DMG_DIR" \
    -ov -format UDZO \
    "$DMG_FILE"

# --- Notarization (optional) ---------------------------------------------------
# Requires a signed app (above) plus a stored notarytool credential profile.
if [ -n "$DEVELOPER_ID_APP" ] && [ -n "$NOTARY_PROFILE" ]; then
    echo "Signing DMG..."
    codesign --force --timestamp --sign "$DEVELOPER_ID_APP" "$DMG_FILE"
    echo "Submitting to Apple notary service (this can take a few minutes)..."
    xcrun notarytool submit "$DMG_FILE" --keychain-profile "$NOTARY_PROFILE" --wait
    echo "Stapling notarization ticket..."
    xcrun stapler staple "$DMG_FILE"
    xcrun stapler validate "$DMG_FILE"
    echo "Notarized DMG ready."
else
    echo "Skipping notarization (set DEVELOPER_ID_APP and NOTARY_PROFILE to enable)."
fi

echo ""
echo "Build complete!"
echo "DMG: $DMG_FILE"
echo ""

# Show file info
ls -lh "$DMG_FILE"
