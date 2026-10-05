# Coastal Farm — playable prototype

A Godot 4.5.1 project exploring a Japanese coastal farm. The farmhouse and starter field share a broad, level meadow with open space to the east and north for future buildings and crops. The calm painterly environment keeps the coastal view, pond, single Mount Kaimon-inspired mountain, and Fieldwork B boy and girl farmers. The environment is visible in the editor and during play. Screenshots in docs/ show the earlier terraced map.

## Open and play

1. Download the repository ZIP from GitHub (Code → Download ZIP), or clone it.
2. Extract it. In Godot 4.5.1 or newer, choose **Import** and select `project.godot`.
3. Open the project and press **F5**.

Move with WASD or arrows. Select Seed, Water, or Harvest with the buttons or keys 1, 2, 3. Stand close to a highlighted bed and press Space, E, Enter, or the action button. After action messages fade, the hint describes the nearby bed and shows a countdown while a watered crop grows.

Approach the farmhouse front steps and press **Enter** on the action button. Inside, approach the bed and choose **Sleep**, then **Sleep until morning**. Sleeping advances one day and matures watered crops; unwatered crops remain unchanged. Seasons last 28 days and a year lasts 112 days. Approach the interior front doorway to **Leave**. Your location and date are saved, and older saves still load.

The clock starts at 6:00 AM. One real second equals one game minute, so a full 24-hour cycle takes 24 real minutes. Midnight advances the date; sleeping wakes you at 6:00 AM and restores Health to 100. Planting and watering cost 2 Health each; harvesting costs 3. Failed actions cost nothing, and walking is free. Below 25 Health the farmer looks tired; you need enough Health to complete a farm action. Staying awake after 9:00 PM drains 0.1 Health per game minute until 6:00 AM. Use Pause/Resume to stop the simulation. Character selection, the sleep dialog and leaving the app also pause time. Clock and Health are saved; older saves start at 6:00 AM with full Health. Food, crop inventory, shipping and the town seed shop are planned.

Seeds cost ¥5. Plant, then water. A watered crop matures in 12 seconds; harvesting earns ¥20. Unwatered crops wait. Saves are automatic after actions and every 10 seconds; the Save button also saves. Saves are local to each device, stored in Godot's `user://farm_save.json`, and are not synced through GitHub.

The on-screen joystick supports dragging and simultaneous touches with the action controls. Landscape UI expands without stretching artwork, with extra scene space for different screen shapes. Controls account for reported mobile safe areas. Resize the desktop window to compare wide phone and 4:3 tablet layouts. Actual iPhone/iPad testing remains pending.

## Current scope

- Connected 2400 × 1600 map and following camera.
- New games offer a Boy/Girl choice; the Farmer button changes it later without resetting progress. The local save remembers the choice.
- Larger phone-readable farmer with eight facing directions. Side and diagonal movement uses four walking phases with lifted passing feet, mirrored rightward cycles, stable scale and shared cell anchors. Strides advance with actual distance traveled and pause against obstacles. Front/back movement retains two poses. Stopping holds the last facing pose.
- Building and waterfront collision, 15 crop beds, tool selection, farming loop and local persistence. The former starter-field terrace barriers have been removed.
- Starter house and crop field occupy the southwest corner. Open level ground to the east and north reserves room for expansion; unlock progression is not implemented yet. Older saves keep coins and crops and relocate the player to the new starter field.
- The farmhouse is a separate scene and sprite with a working entrance and a simple furnished interior. Other scenery remains a static background plate. Decorative fences and plants do not all have collisions or depth sorting. Props will need separate assets for full interaction.
- No NPC systems, sound, inventory, polished idle and longer animation cycles, or final terrain tileset.
- iOS source project only: this ZIP is not an installable iPhone app. Device export needs a Mac, Xcode, Godot export templates, and Apple signing setup.

## Validation

The existing farming loop was previously verified with Godot 4.5.1: clean asset import and game startup, planting cost, water requirement, timed growth, harvest payout and replanting, repeated-action protection, save/load, waterfront collision, and phone/tablet control bounds. Rendered desktop screenshots are in `docs/`. Automated checks are in `tests/smoke.gd`: run Godot with `--headless --path . --script res://tests/smoke.gd`. Run checks with a separate user-data profile because they write a test save.

The current project also passed a clean import and full headless smoke suite in Godot 4.7.2, covering all four stride phases, movement-based timing, mirrored directions, building approaches from four sides, coastal collision, reachable beds, blocked saved-position recovery, tool labels, farming, saves and phone/tablet controls. The farmhouse checks also cover entering/leaving, furniture collision, canceling sleep, overnight growth, season/year rollover, indoor save restoration and older saves. Desktop room and sleep-dialog previews were rendered in Godot. Manual playtesting remains pending.

## Working on another computer

Clone or download this private repository while signed into your GitHub account, then import the same `project.godot`. Commit/push work before switching computers; pull updates on the other computer. The `.godot` import cache is excluded and rebuilt automatically. Concept PNGs and project assets are included; they currently fit in ordinary Git. Never commit credentials or Apple signing certificates.
