# Connected World Edition - local review audit

Version 0.4.0 / build 300. October 18, 2026. No remote upload.

## Scope checked
- All five outdoor connections in both directions, body collision, fixed camera/character projection, cross-map tap routes and manual cancellation.
- Fifteen version/map save combinations covering schemas 23-25, repeat migration, friendship retention, damaged-save recovery and isolated test storage.
- Town door routes, regional doors, every interior, school and resident schedules, interaction priority, held gifts, equipment and nature friendship.
- Staged outings and wedding cleanup, exact origin restoration, staged-save guards, dry guest positions, seated pose restoration and garden persistence.
- Inventory capacity, shipping/payment idempotence, overnight crops/animals, equipment settlement, 112 nights, Year 2 vote and eight story chapters.
- Shared depth ordering, roof fading during dialogue, seasonal surfaces, distant-region culling, bounded caches/nodes, phone-proportion UI and asset loading.

## Findings fixed
- Town movement used a separate projected physics space. Unified coordinates while preserving displayed storefront proportions.
- Regional transitions teleported the player. Replaced them with continuous boundaries and migrated old saved coordinates.
- Tap targets across a boundary needed a route through the connecting lane. Added routing and cancellation checks.
- Continuous festival exits skipped participant cleanup. Restored the normal festival completion/cleanup path.
- Joining maps exposed horizon trees in another area's walkway and different grass texture scales. Cleared shared entrances and aligned terrain UVs.
- Seated dialogue could leave an opaque roof over the player. Roof fading now updates during paused scenes, and the bench was moved farther clear.
- Wedding staging hid guests behind the shrine. Moved the group and validated every guest's ground position.
- Legacy town coordinates with missing fields needed guarded access. Added safe defaults.

## Evidence and limits
All 64 checks in ci/run_checks.py passed in the complete run. The subsequent festival-exit audit and final bench-placement check passed separately. The final exported package passed phone_revision, home_recovery and farm_systems; its social, connection and motion captures completed without script errors.

Photos 01-29 and connected-world-walk.gif are in ../PhoneFeedbackPreview relative to the repository. These are actual desktop gameplay captures. The motion clip is scripted movement through real collision/camera logic, not a manual full playthrough. Physical iPhone performance, touch feel and final art approval remain review/release gates.

The separate local launcher uses the connected-world-review save session. GitHub and TestFlight remain untouched pending user approval.
