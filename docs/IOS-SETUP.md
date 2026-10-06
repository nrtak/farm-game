# iPhone and iPad build preparation

Repository: https://github.com/nrtak/farm-game

The project includes a manual GitHub Actions workflow for an unsigned compilation check or a signed App Store IPA. It does not upload or publish automatically. Windows cannot compile the iOS app; the workflow uses a macOS runner with Xcode 26 or newer and Godot 4.7.2.

## Repository layout

Place the contents of this CoastalFarm project at the repository root, including the hidden `.github` directory. Keep `project.godot`, `ci`, and `.github/workflows/ios-build.yml` at that level. Do not commit `.godot`, export output, certificates, provisioning profiles, or passwords. Preserve existing repository files and compare before replacing older source.

## Apple identity

Register the game's bundle ID in Apple Developer and create a matching app record in App Store Connect. In GitHub Settings → Environments, create an environment named `ios`. Add these environment variables:

| Variable | Value |
| --- | --- |
| APPLE_TEAM_ID | Your 10-character Apple Developer Team ID |
| IOS_BUNDLE_ID | The exact registered app identifier |

These are identifiers, not private keys. The local preset uses Team ID R3233N87DC and bundle ID com.farmgame.play, registered for farmgame.

## First compilation check

In Actions → iOS build → Run workflow, leave **signed** off. Choose a version such as `0.1.0` and a build number. This imports the game, runs ten gameplay checks, exports the Xcode project, and compiles for iPhone/iPad. The unsigned artifact cannot be installed or uploaded to TestFlight.

## Signed TestFlight candidate

Create an Apple Distribution certificate with its private key exported as a password-protected `.p12`, and an App Store distribution provisioning profile matching the app ID. Add these GitHub `ios` environment secrets directly in GitHub, never in chat or source:

| Secret | Value |
| --- | --- |
| IOS_CERTIFICATE_BASE64 | Base64 of the distribution `.p12` |
| IOS_CERTIFICATE_PASSWORD | Password used to export that `.p12` |
| IOS_PROFILE_BASE64 | Base64 of the App Store `.mobileprovision` |
| KEYCHAIN_PASSWORD | A strong temporary CI keychain password |

Run again with **signed** on and a new increasing build number. Download the IPA artifact. Upload it using Apple's Transporter on a Mac, then complete App Store Connect processing and TestFlight setup. No App Store Connect API key is needed for this manual upload path.

## Before submitting

The included icon is a draft. Check it and the generated privacy manifest in the first exported Xcode project. Confirm encryption/export-compliance answers match the finished app. Test landscape layout, touch controls, saving, loading, audio interruptions, performance, and battery use on actual iPhone and iPad devices. Screenshots, privacy policy, age rating, app metadata, and review information remain to be completed before public release.

Local checks do not verify Xcode signing or device behavior. The macOS workflow has not yet been run from this preparation package.

References: [Godot iOS export](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_ios.html), [Apple SDK requirements](https://developer.apple.com/news/upcoming-requirements/?id=04282026a), [Upload builds](https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds/).

