#!/bin/bash

set -euo pipefail

cd "$(dirname "$0")/.."

APP_NAME="OnePointer"
PROJECT="OnePointer.xcodeproj"
SCHEME="OnePointer"
BUILD_ROOT=".build/distribution"
DERIVED_DATA="$BUILD_ROOT/DerivedData"
STAGING="$BUILD_ROOT/dmg"
APP_PATH="$DERIVED_DATA/Build/Products/Release/$APP_NAME.app"
VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" Config/Info.plist)
DMG_PATH="$BUILD_ROOT/$APP_NAME-$VERSION.dmg"
ENTITLEMENTS="Config/OnePointer.entitlements"

if ! command -v xcodegen >/dev/null 2>&1; then
    echo "error: XcodeGen is required (brew install xcodegen)." >&2
    exit 1
fi

xcodegen generate
xcodebuild \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration Release \
    -derivedDataPath "$DERIVED_DATA" \
    -arch arm64 \
    -arch x86_64 \
    ONLY_ACTIVE_ARCH=NO \
    CODE_SIGNING_ALLOWED=NO \
    build

if [[ -n "${DEVELOPER_ID_APP:-}" ]]; then
    codesign --force --options runtime --timestamp \
        --entitlements "$ENTITLEMENTS" \
        --sign "$DEVELOPER_ID_APP" \
        "$APP_PATH"
    codesign --verify --deep --strict --verbose=2 "$APP_PATH"
else
    echo "warning: DEVELOPER_ID_APP is unset; producing an unsigned local DMG." >&2
fi

mkdir -p "$STAGING"
/usr/bin/ditto "$APP_PATH" "$STAGING/$APP_NAME.app"
ln -sfn /Applications "$STAGING/Applications"
hdiutil create \
    -volname "$APP_NAME" \
    -srcfolder "$STAGING" \
    -ov \
    -format UDZO \
    "$DMG_PATH"

if [[ -n "${DEVELOPER_ID_APP:-}" && -n "${NOTARY_PROFILE:-}" ]]; then
    codesign --force --timestamp --sign "$DEVELOPER_ID_APP" "$DMG_PATH"
    xcrun notarytool submit "$DMG_PATH" \
        --keychain-profile "$NOTARY_PROFILE" \
        --wait
    xcrun stapler staple "$DMG_PATH"
    xcrun stapler validate "$DMG_PATH"
else
    echo "warning: notarization skipped; set DEVELOPER_ID_APP and NOTARY_PROFILE." >&2
fi

echo "$DMG_PATH"
