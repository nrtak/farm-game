import os, plistlib
from pathlib import Path
options = {"method": "app-store-connect", "teamID": os.environ["APPLE_TEAM_ID"], "signingStyle": "manual",
           "signingCertificate": "Apple Distribution", "manageAppVersionAndBuildNumber": False,
           "provisioningProfiles": {os.environ["IOS_BUNDLE_ID"]: os.environ["PROFILE_NAME"]}}
Path("export/ExportOptions.plist").write_bytes(plistlib.dumps(options))
