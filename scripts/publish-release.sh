#!/bin/bash

set -euo pipefail

repo_root=$(cd "$(dirname "$0")/.." && pwd)
cd "$repo_root"

version=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" Config/Info.plist)
tag="v$version"
release_root="$repo_root/.build/release-$version"
dmg_path="$release_root/OnePointer-$version.dmg"
checksum_path="$dmg_path.sha256"
release_notes="$repo_root/release-notes/$version.md"

if [[ -n "$(git status --porcelain)" ]]; then
    echo "error: commit and push the release source and appcast first" >&2
    exit 1
fi

git fetch origin main --tags
if [[ "$(git rev-parse HEAD)" != "$(git rev-parse origin/main)" ]]; then
    echo "error: HEAD must match origin/main before publishing" >&2
    exit 1
fi

for required_path in "$dmg_path" "$checksum_path" "$release_notes"; do
    if [[ ! -f "$required_path" ]]; then
        echo "error: missing release file: $required_path" >&2
        exit 1
    fi
done

if git rev-parse "$tag" >/dev/null 2>&1; then
    echo "error: tag already exists: $tag" >&2
    exit 1
fi

git tag -a "$tag" -m "OnePointer $version"
git push origin "$tag"
gh release create "$tag" \
    "$dmg_path" \
    "$checksum_path" \
    --title "OnePointer $version" \
    --notes-file "$release_notes" \
    --verify-tag
