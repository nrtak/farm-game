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

## Outstanding — not complete
- True seamless outdoor world/camera travel: maps still switch with a short camera pan.
- Full all-area visual refinement, additional interior detail/stairs, and natural boundary treatment.
- Visually staged dates/wedding; current milestones and outings use dialogue.
- Nature-friend welcoming garden/keepsakes and additional ambient animation beyond idle bobbing.
- Benches currently open a quiet-moment panel; seated poses remain to implement.
- Tractor operation has daily mechanics but no moving vehicle animation.
- Final numbered screenshot approval, movement demo, physical iPhone validation and release.

## Reference standard approved by user
Use Harvest Moon (especially Back to Nature), Story of Seasons and Stardew Valley as polish references when making routine design decisions. Preserve original artwork, characters and story.
- Compare equivalent gameplay views: town street, interior, farmland, waterfront and wilderness at normal playing zoom.
- Prioritize readable entrances, unobstructed routes, consistent scale, connected terrain, grounded structures and clear interaction feedback.
- Inspect moving gameplay as well as still images; screenshots cannot establish collision quality, responsiveness, save correctness or progression balance.
- Do not equate passing automated checks with comparable production polish.
Official reference galleries: https://www.stardewvalley.net/media/ and https://marvelousgames.com/games/story-of-seasons-friends-of-mineral-town
