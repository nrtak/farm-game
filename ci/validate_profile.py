import datetime, os, plistlib, shutil
from pathlib import Path

profile = plistlib.loads((Path(os.environ['RUNNER_TEMP']) / 'profile.plist').read_bytes())
team, bundle = os.environ['APPLE_TEAM_ID'], os.environ['IOS_BUNDLE_ID']
if team not in profile.get('TeamIdentifier', []):
    raise ValueError('Provisioning profile belongs to another Apple team')
if profile['Entitlements'].get('application-identifier') != team + '.' + bundle:
    raise ValueError('Provisioning profile must match the exact app bundle ID')
if profile['ExpirationDate'] <= datetime.datetime.now(datetime.timezone.utc).replace(tzinfo=None):
    raise ValueError('Provisioning profile has expired')
if profile.get('ProvisionedDevices') or profile.get('ProvisionsAllDevices') or profile['Entitlements'].get('get-task-allow'):
    raise ValueError('Use an App Store distribution provisioning profile')
destination = Path.home() / 'Library/MobileDevice/Provisioning Profiles'
destination.mkdir(parents=True, exist_ok=True)
shutil.copyfile(Path(os.environ['RUNNER_TEMP']) / 'distribution.mobileprovision', destination / (profile['UUID'] + '.mobileprovision'))
with open(os.environ['GITHUB_ENV'], 'a', encoding='utf-8') as environment:
    environment.write('PROFILE_NAME=' + profile['Name'] + '\n')
