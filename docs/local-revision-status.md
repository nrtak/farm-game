# Local revision batch — October 17
No GitHub or TestFlight uploads before numbered gameplay screenshot review.
Baseline: 5860f45 (0.3.0 / 202). Existing work preserved.

## Implemented locally
- Barn-adjacent pasture; utility chest/well moved west and main field moved south by stable plot index.
- Compact combined date/time HUD, money beside bag, separate map; adaptive dialogue with anchored portrait and wrapped actions.
- Cream north/east interior walls, no west TV wall, archive shelves against walls.
- Tea rows, matching boundary fences, softer dirt-road edges, civic garden borders.
- Harbor tide pools/crabs/footprints and marina artwork; onsen artwork/steam and reversed resort frontage; shrine-facing falls and pool extending east.
- School beside library and playground, Nao and three children with school/home/play schedules; older residents' existing routines retained.
- Nature friends use only water-drop and fluffy leaf forms with shader color variants.
- Marina moved west of the shore-connected fishing pier; pier now has a raised deck edge and visible support pilings.
- Nature friends accept held gifts, track individual friendship and leader trust, and visit the farm. They do not perform chores.
- Ranch feeder uses stored feed; blacksmith harvest equipment moves at most 12 ripe crops into storage daily. Purchases unlock from Summer, do not repeat charges, and persist.
- Separate romance affection, explicit commitment, personal dialogue milestones, outings, color hearts, warmer greetings and weekly partner morning visits. Residents retain normal schedules.
- Inspectable neighborhood notices and bench interactions.

## Verification
- Existing regression suite run in segments; fixed interaction priority at doors and new-resident friendship reload.
- Updated intentional test expectations for the school, moved field, barn approach and heart-stage display.
- Existing checks cover movement clearance, doors/interiors, farming, shipping, quests, animal care, indoor time freeze, sleep saves, year rollover, story chapters, audio and save recovery.
- Targeted relationship, equipment, nature friend, school and shrine checks passed using isolated saves.
- Local exported preview passed phone_revision, home_recovery and farm_systems; 17 labeled desktop views captured. Visual inspection corrected sprite bleed, playground overlap and stale town-camera centering after an interior.
- Desktop screenshot review is separate from physical iPhone validation.

- October 18 continuation: relationship regression passed with isolated saves after rejecting unknown outings and ineligible/out-of-range story chapters. Verified marriage memory persists immediately; removed a redundant save.
- Visually inspected the latest labeled pier capture: western marina and eastern pier placement are readable, with visible shore attachment and pilings. Pier deck texture remains simpler than adjacent marina artwork and needs refinement.

- October 18 gateway pass: stopped outdoor glide leaking into interiors/direct travel; preserved held touch even at zero velocity; prevented hurricane redirection from restoring outdoor controls. outdoor_flow and angled_world_regressions passed with isolated saves.
- Fresh local export passed phone_revision, home_recovery and farm_systems and regenerated all 17 labeled screenshots. Inspected tea/highlands approach and school: approach is clear; school still uses unsuitable office desks and needs classroom furniture.

- October 18 classroom pass: replaced four office desks with original transparent pupil desk/chair artwork, books and pencils. Export and phone_revision/home_recovery/farm_systems checks passed; refreshed 17 screenshots and visually inspected Photo 15 for scale and clear aisles. Art prompt and provenance are in docs/school-desk-art.txt.

- October 18 movement pass: normalized regional movement in the projected ground plane, eliminating different visible speeds along different directions. Analog pressure and tap routes retain the same pace; town speed is unchanged. angled_world, movement_recovery, outdoor_flow and walk_feedback passed with isolated saves. This is a movement correction, not completion of seamless travel.

- October 18 shared-camera pass: town and regional views now use one canvas renderer and a common player anchor. Removed Camera2D ownership switching and its separate town offset. Repeated town/region transitions, two viewport sizes, every interior, festival zoom, pickup anchoring and existing deep_review checks passed with isolated saves. Local export plus phone_revision/home_recovery/farm_systems passed; 17 labeled captures refreshed; inspected town and shrine framing. Map geometry still switches and is not yet seamless.

- October 18 nature visit pass: visitors rotate through deterministic daily farm locations, avoid crop beds and doorway approaches, and use seasonal farm dialogue plus subtle idle bobbing. Isolated local_expansion checks passed for varied positions, within-day stability, crop clearance, gifts, trust unlock and persistence. No chores were assigned to creatures.

- October 18 interim full regression run: all 58 checks in ci/run_checks.py passed after shared-camera, movement and nature-visit changes. The runner used a separate temporary user directory for every check and restored its override afterward. Coverage included 112 overnight settlements, weekly reloads, Year 2 rollover/vote, eight story chapters, door routes, recovery, inventory, animals, audio and bounded node counts. This is automated regression evidence, not a manual playthrough or completion of the final post-batch audit.

- October 18 path-art pass: replaced repeating scalloped dirt borders with irregular outward shoulders and subtle soil flecks. Preserved clear lane widths; open_regions passed. Screenshot review found overlapping segment outlines, which were removed. Refreshed all 17 labeled images after the correction; local export plus phone_revision/home_recovery/farm_systems passed.

- October 18 checkpoint verification: 21c2704 includes remaining tested source changes and referenced runtime assets. A fresh Git archive in ../checkpoint-validation-21c2704 imported all resources, then passed angled_world and local_expansion with isolated saves. Unrelated draft art/debug files were preserved outside the checkpoint. No remote push or TestFlight upload.

## Review build status — Connected World Edition, 0.4.0 / 300
- Local implementation and regression pass completed for this revision batch. All six outdoor areas share physical coordinates, projection and camera; both joystick and tap routes cross the five connections.
- Numbered screenshots 01–29 and a moving gameplay capture are available from the final local export for user review.
- Remaining release gates: user screenshot/playability review, physical iPhone validation, and explicit approval before GitHub/TestFlight upload. No remote upload has occurred.

## Resumed morning session — October 18
- Outings now stage the player and partner in the cafÃ©, shore or shrine; weddings include three neighbors. Temporary scenes restore the exact origin and never save staged positions. Rainy weddings use the shrine residence. Isolated tests cover five origin areas, all three outings, save guards, cleanup and wedding reload.
- All three benches have a seated pose and restore the player on dismissal. Visual review caught a too-large panel and an obscured library bench; panel corrected, bench placement review still in progress.
- Leader trust unlocks a wildflower welcoming garden. Each nature friend awards a single cosmetic keepsake at 20 friendship; garden and keepsakes persist. Creatures still do no chores.
- Original tractor artwork is integrated with a visible morning-job route, yielding to the player and pausing with the game. Animation never repeats the already-settled crop rewards. Isolated regression passed; generated art provenance is in tractor-art.txt.
- New labeled gameplay captures 18–24 exist in ../PhoneFeedbackPreview/moment-*.png. These are interim views, not evidence that the full revision batch or seamless travel is finished.
- All 61 checks passed before the continuous-region change. The revised library bench was subsequently moved to the open lane and nature-friend panels use the compact layout.
- Highlands and Tea Country now form one physical outdoor stretch with both landscapes rendered together, a clear connecting lane, preserved player position/velocity and no camera switch. Save schema 24 migrates old mountain/tea coordinates. New bidirectional physics/camera/migration regression and phone_revision passed. The 62-check run passed at that checkpoint; the remaining connections were subsequently converted in build 300.

## Reference standard approved by user
Use Harvest Moon (especially Back to Nature), Story of Seasons and Stardew Valley as polish references when making routine design decisions. Preserve original artwork, characters and story.
- Compare equivalent gameplay views: town street, interior, farmland, waterfront and wilderness at normal playing zoom.
- Prioritize readable entrances, unobstructed routes, consistent scale, connected terrain, grounded structures and clear interaction feedback.
- Inspect moving gameplay as well as still images; screenshots cannot establish collision quality, responsiveness, save correctness or progression balance.
- Do not equate passing automated checks with comparable production polish.
Official reference galleries: https://www.stardewvalley.net/media/ and https://marvelousgames.com/games/story-of-seasons-friends-of-mineral-town

## Final morning completion pass
- Unified town physics with the shared projection while preserving rendered storefront proportions. Connected farm/town, town/Highlands, town/shrine, town/harbor and Highlands/tea without teleporting the player or changing camera scale.
- Save schema 25 migrates old outdoor coordinates. Audit covers all five relocated maps in versions 23, 24 and 25, preserved friendship and repeated save/reload.
- Cross-map tap paths route through clear gates; manual movement cancels them. Nearby scenery is rendered together, distant regions are culled, and rooms remain isolated.
- Cleared horizon trees from neighboring gateways, matched terrain at joins, added wall windows/joinery and pier plank grain/fasteners. Repositioned wedding staging on dry ground and updated roof fading during seated dialogue.
- Deep audit found and fixed missing festival cleanup on continuous exits and hardened missing-coordinate legacy saves. Updated obsolete teleport-boundary tests to physical boundary positions; their navigation assertions remain.
- All 64 checks passed in the complete regression run. The additional festival-exit audit passed after its fix. Automated coverage includes 112 overnight settlements, eight story chapters, Year 2 vote, interactions, inventory, relationship scenes, save recovery, movement and rendering isolation. This is not physical iPhone testing or a manual full playthrough.

- Final local export passed phone_revision, home_recovery and farm_systems. Packaged social-scene and connection captures passed. The final bench relocation also passed its seating/restoration regression. No GitHub or TestFlight upload.

## Screenshot feedback revision 2 (local, October 18)
- Added a translucent live world mini-map that opens an expanded map, and grouped the player portrait, Bag, money and health. Date and time share a compact panel. Dialogue hides the money panel and separates relationship name/status.
- Moved farm utilities beside the field and pasture east/south of the barn; removed obstructing tea/library benches; shortened Tea Country frontage by 260 world units. Added an open playground, northern tea rows, expanded scenery, interior wall trim/pictures and coordinated rugs, shoreline/pier detail and continuous connection ground.
- Moved wedding staging into the village square; reduced nature friend size; enlarged dialogue portraits and removed redundant Return controls.
- Deep audit fixed short-distance cross-boundary tap routing, stale friendship/expanded crop beds on reload, tractor storage-capacity mismatch and duplicate door audio. New isolated regression coverage reproduces those cases.
- Regression caught insufficient body clearance beside the revised shrine lake; shoreline pulled back while preserving the waterfall connection. Legacy tea route checks now follow the shorter frontage within the eastern fence.
- Fresh source screenshots include Photo 30 (expanded map). Package refresh and final regression completion are pending at this checkpoint. No upload, physical iPhone test or manual full playthrough.
- Visual follow-up: inspect eastern tea panorama visibility and all five joins in motion; do not infer finished polish from passing tests.

- All 67 regression checks passed across the initial run and resumptions after the lake-clearance fix and updated pasture-position assertion. Local export succeeded; packaged checks/capture are running.
- Packaged phone_revision, home_recovery and farm_systems passed; fresh packaged gameplay screenshots captured. Source social scenes and connection captures passed. Gallery contains 30 labeled views; older motion GIF is explicitly labeled as predating this revision. Remaining visual review includes directional sign overlap at the shrine join and eastern tea panorama visibility.
