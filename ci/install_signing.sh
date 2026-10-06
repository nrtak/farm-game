#!/usr/bin/env bash
set -euo pipefail
keychain="$RUNNER_TEMP/coastal-signing.keychain-db"
certificate="$RUNNER_TEMP/distribution.p12"
profile="$RUNNER_TEMP/distribution.mobileprovision"
printf '%s' "$IOS_CERTIFICATE_BASE64" | base64 --decode > "$certificate"
printf '%s' "$IOS_PROFILE_BASE64" | base64 --decode > "$profile"
security create-keychain -p "$KEYCHAIN_PASSWORD" "$keychain"
security set-keychain-settings -lut 21600 "$keychain"
security unlock-keychain -p "$KEYCHAIN_PASSWORD" "$keychain"
security import "$certificate" -P "$IOS_CERTIFICATE_PASSWORD" -A -t cert -f pkcs12 -k "$keychain"
security set-key-partition-list -S apple-tool:,apple: -k "$KEYCHAIN_PASSWORD" "$keychain" >/dev/null
security list-keychains -d user -s "$keychain" "$HOME/Library/Keychains/login.keychain-db"
security cms -D -i "$profile" > "$RUNNER_TEMP/profile.plist"
python3 ci/validate_profile.py
echo "KEYCHAIN_PATH=$keychain" >> "$GITHUB_ENV"
