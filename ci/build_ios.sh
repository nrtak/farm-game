#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
python3 ci/configure_ios.py
mkdir -p export/ios
"$GODOT_BIN" --headless --path . --import
"$GODOT_BIN" --headless --path . --export-release iOS export/ios/CoastalFarm.zip
# Run the exported pack in an empty folder. Editor files must not hide omissions.
pack=$(find "$PWD/export/ios" -name '*.pck' -type f | head -n 1)
[[ -n "$pack" ]]
probe_dir=$(mktemp -d)
"$GODOT_BIN" --headless --path "$probe_dir" --main-pack "$pack" --script "$PWD/ci/pack_startup.gd" --quit-after 600 -- --test-session="ios-export-$BUILD_NUMBER" > export/pack-startup.log 2>&1
cat export/pack-startup.log
grep -q '^PASS:' export/pack-startup.log
if grep -qE 'SCRIPT ERROR:|^ERROR:' export/pack-startup.log; then exit 1; fi
project=export/ios/CoastalFarm.xcodeproj
if [[ ! -d "$project" ]]; then
  echo 'Godot did not generate the expected Xcode project' >&2
  exit 1
fi
xcodebuild -list -project "$project"
if [[ "${SIGNED_BUILD:-false}" != true ]]; then
  xcodebuild -project "$project" -scheme CoastalFarm -configuration Release \
    -sdk iphoneos -destination 'generic/platform=iOS' -derivedDataPath export/DerivedData \
    CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build
  tar -czf export/ios-unsigned-app.tar.gz -C export/DerivedData/Build/Products/Release-iphoneos CoastalFarm.app
else
  : "${PROFILE_NAME:?Missing provisioning profile name}"
  : "${KEYCHAIN_PATH:?Missing signing keychain}"
  xcodebuild -project "$project" -scheme CoastalFarm -configuration Release \
    -destination 'generic/platform=iOS' -archivePath export/CoastalFarm.xcarchive \
    CODE_SIGN_STYLE=Manual DEVELOPMENT_TEAM="$APPLE_TEAM_ID" \
    PROVISIONING_PROFILE_SPECIFIER="$PROFILE_NAME" CODE_SIGN_IDENTITY='Apple Distribution' \
    OTHER_CODE_SIGN_FLAGS="--keychain $KEYCHAIN_PATH" archive
  python3 ci/export_options.py
  xcodebuild -exportArchive -archivePath export/CoastalFarm.xcarchive \
    -exportPath export/ipa -exportOptionsPlist export/ExportOptions.plist
fi
