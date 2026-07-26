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
origin_url=$(git remote get-url origin)

case "$origin_url" in
    git@github.com:*)
        github_repo=${origin_url#git@github.com:}
        ;;
    https://github.com/*)
        github_repo=${origin_url#https://github.com/}
        ;;
    *)
        echo "error: origin is not a supported GitHub URL: $origin_url" >&2
        exit 1
        ;;
esac
github_repo=${github_repo%.git}

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
    if [[ "$(git rev-list -n 1 "$tag")" != "$(git rev-parse HEAD)" ]]; then
        echo "error: existing tag $tag does not point to HEAD" >&2
        exit 1
    fi
else
    git tag -a "$tag" -m "OnePointer $version"
    git push origin "$tag"
fi

gh release create "$tag" \
    "$dmg_path" \
    "$checksum_path" \
    --repo "$github_repo" \
    --title "OnePointer $version" \
    --notes-file "$release_notes" \
    --verify-tag
