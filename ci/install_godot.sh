#!/usr/bin/env bash
set -euo pipefail
destination="$RUNNER_TEMP/godot"
mkdir -p "$destination"
cd "$destination"
base=https://github.com/godotengine/godot-builds/releases/download/4.7.2-stable
curl --fail --location --retry 3 "$base/Godot_v4.7.2-stable_macos.universal.zip" -o engine.zip
curl --fail --location --retry 3 "$base/Godot_v4.7.2-stable_export_templates.tpz" -o templates.zip
echo 'c58a24e31d720be9d62f60cb5627c4e695fb72f21b0cfe1bc9ccaa9a3b3ba63e  engine.zip' | shasum -a 256 -c -
echo 'f298490b8d44d934be425a5a65a51bf15f422428b229a06a6e11d9ffea248011  templates.zip' | shasum -a 256 -c -
unzip -q engine.zip
templates="$HOME/Library/Application Support/Godot/export_templates/4.7.2.stable"
mkdir -p "$templates"
unzip -p templates.zip templates/ios.zip > "$templates/ios.zip"
chmod +x Godot.app/Contents/MacOS/Godot
echo "GODOT_BIN=$destination/Godot.app/Contents/MacOS/Godot" >> "$GITHUB_ENV"
