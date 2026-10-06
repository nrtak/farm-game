#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
python3 ci/configure_ios.py
mkdir -p export/ios
"$GODOT_BIN" --headless --path . --import
"$GODOT_BIN" --headless --path . --export-release iOS export/ios/CoastalFarm.zip
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
