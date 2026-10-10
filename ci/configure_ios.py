"""Set CI-only iOS identity/version; never accepts or writes signing private keys."""
import json, os, re
from pathlib import Path

def configure(path, team, bundle, version, build):
    if not re.fullmatch(r"[A-Z0-9]{10}", team):
        raise ValueError("Set APPLE_TEAM_ID to your 10-character Apple Team ID")
    if not re.fullmatch(r"[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+){2,}", bundle) or bundle.startswith("com.example."):
        raise ValueError("Set IOS_BUNDLE_ID to the registered reverse-DNS app identifier")
    if not re.fullmatch(r"\d+\.\d+\.\d+", version) or not re.fullmatch(r"[1-9]\d*", build):
        raise ValueError("Version must be major.minor.patch and build a positive integer")
    source = path.read_text(encoding="utf-8-sig")
    marker = "[preset.1.options]"
    if marker not in source: raise ValueError("Missing iOS export preset")
    before, options = source.split(marker, 1)
    for key, value in {"application/app_store_team_id": team, "application/bundle_identifier": bundle,
                       "application/short_version": version, "application/version": build}.items():
        pattern = rf'^{re.escape(key)}=.*$'
        options, count = re.subn(pattern, key + "=" + json.dumps(value), options, flags=re.M)
        if count != 1: raise ValueError("Missing or duplicate option: " + key)
    path.write_text(before + marker + options, encoding="utf-8")

if __name__ == "__main__":
    configure(Path("export_presets.cfg"), os.environ.get("APPLE_TEAM_ID", ""), os.environ.get("IOS_BUNDLE_ID", ""),
              os.environ.get("APP_VERSION", "0.1.0"), os.environ.get("BUILD_NUMBER", "1"))
    info=Path("data/build_info.json")
    metadata=json.loads(info.read_text())
    metadata["build"]=os.environ.get("BUILD_NUMBER","local")
    info.write_text(json.dumps(metadata))
    print("Configured iOS identity and version")
