#!/bin/bash

set -euo pipefail

repo_root=$(cd "$(dirname "$0")/.." && pwd)
cd "$repo_root"

app_name="OnePointer"
project="OnePointer.xcodeproj"
scheme="OnePointer"
version=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" Config/Info.plist)
release_root="$repo_root/.build/release-$version"
derived_data="$release_root/DerivedData"
archive_path="$release_root/$app_name-$version.xcarchive"
app_path="$archive_path/Products/Applications/$app_name.app"
app_zip="$release_root/$app_name-$version-notarization.zip"
staging_path="$release_root/dmg-root"
dmg_path="$release_root/$app_name-$version.dmg"
checksum_path="$dmg_path.sha256"
updates_path="$release_root/updates"
release_notes="$repo_root/release-notes/$version.md"

developer_id_app="${DEVELOPER_ID_APP:-Developer ID Application: Freedom Dimension (shenzhen) Technology Co., Ltd (PCJ84YD7HQ)}"
development_team="${DEVELOPMENT_TEAM:-PCJ84YD7HQ}"
notary_profile="${NOTARY_PROFILE:-cfdesk-notary}"
sparkle_account="${SPARKLE_ACCOUNT:-oneapps-studio}"
github_repository="${GITHUB_REPOSITORY:-makerjackie/onepointer}"

for command_name in xcodegen xcodebuild codesign hdiutil xcrun; do
    if ! command -v "$command_name" >/dev/null 2>&1; then
        echo "error: missing required command: $command_name" >&2
        exit 1
    fi
done

if [[ ! -f "$release_notes" ]]; then
    echo "error: missing release notes: $release_notes" >&2
    exit 1
fi

if [[ -e "$release_root" ]]; then
    echo "error: release directory already exists: $release_root" >&2
    exit 1
fi

mkdir -p "$release_root"
xcodegen generate

xcodebuild test \
    -project "$project" \
    -scheme "$scheme" \
    -configuration Debug \
    -derivedDataPath "$derived_data" \
    CODE_SIGNING_ALLOWED=NO

xcodebuild archive \
    -project "$project" \
    -scheme "$scheme" \
    -configuration Release \
    -archivePath "$archive_path" \
    -derivedDataPath "$derived_data" \
    -destination "generic/platform=macOS" \
    CODE_SIGN_STYLE=Manual \
    CODE_SIGN_IDENTITY="$developer_id_app" \
    DEVELOPMENT_TEAM="$development_team" \
    PROVISIONING_PROFILE_SPECIFIER=""

sparkle_path="$app_path/Contents/Frameworks/Sparkle.framework/Versions/B"
codesign --force --sign "$developer_id_app" --options runtime --timestamp \
    "$sparkle_path/XPCServices/Installer.xpc"
codesign --force --sign "$developer_id_app" --options runtime --timestamp \
    --preserve-metadata=entitlements \
    "$sparkle_path/XPCServices/Downloader.xpc"
codesign --force --sign "$developer_id_app" --options runtime --timestamp \
    "$sparkle_path/Autoupdate"
codesign --force --sign "$developer_id_app" --options runtime --timestamp \
    "$sparkle_path/Updater.app"
codesign --force --sign "$developer_id_app" --options runtime --timestamp \
    "$app_path/Contents/Frameworks/Sparkle.framework"
codesign --force --sign "$developer_id_app" --options runtime --timestamp \
    --entitlements Config/OnePointer.entitlements \
    "$app_path"
codesign --verify --deep --strict --verbose=4 "$app_path"

/usr/bin/ditto -c -k --keepParent "$app_path" "$app_zip"
xcrun notarytool submit "$app_zip" \
    --keychain-profile "$notary_profile" \
    --wait
xcrun stapler staple "$app_path"
xcrun stapler validate "$app_path"
spctl --assess --type execute -vv "$app_path"

mkdir -p "$staging_path"
/usr/bin/ditto "$app_path" "$staging_path/$app_name.app"
ln -s /Applications "$staging_path/Applications"
hdiutil create \
    -volname "$app_name" \
    -srcfolder "$staging_path" \
    -format UDZO \
    "$dmg_path"
codesign --force --timestamp --sign "$developer_id_app" "$dmg_path"
xcrun notarytool submit "$dmg_path" \
    --keychain-profile "$notary_profile" \
    --wait
xcrun stapler staple "$dmg_path"
xcrun stapler validate "$dmg_path"
spctl --assess --type open -vv \
    --context context:primary-signature \
    "$dmg_path"

shasum -a 256 "$dmg_path" > "$checksum_path"
mkdir -p "$updates_path"
/usr/bin/ditto "$dmg_path" "$updates_path/$app_name-$version.dmg"
/usr/bin/ditto "$release_notes" "$updates_path/$app_name-$version.md"

generate_appcast="$derived_data/SourcePackages/artifacts/sparkle/Sparkle/bin/generate_appcast"
"$generate_appcast" \
    --account "$sparkle_account" \
    --download-url-prefix "https://github.com/$github_repository/releases/download/v$version/" \
    --embed-release-notes \
    --link "https://github.com/$github_repository" \
    -o "$repo_root/appcast.xml" \
    "$updates_path"

echo "Release ready:"
echo "  App: $app_path"
echo "  DMG: $dmg_path"
echo "  SHA: $checksum_path"
echo "  Appcast: $repo_root/appcast.xml"
