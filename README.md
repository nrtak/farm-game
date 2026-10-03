# Coastal Farm — playable prototype

A Godot 4.5.1 project exploring a connected Japanese coastal hillside farm. Fieldwork characters v5 uses a simplified farm environment with fewer flowers, broader foliage shapes and a calmer palette, Fieldwork B boy and girl farmers, live crop overlays, and a single Mount Kaimon-inspired mountain. The environment is visible in the editor and during play. Actual game screenshots are in docs/corner-phone.png (current); earlier previews are retained.

## Open and play

1. Download the repository ZIP from GitHub (Code → Download ZIP), or clone it.
2. Extract it. In Godot 4.5.1 or newer, choose **Import** and select `project.godot`.
3. Open the project and press **F5**.

Move with WASD or arrows. Select Seed, Water, or Harvest with the buttons or keys 1, 2, 3. Stand close to a highlighted bed and press Space, E, Enter, or the action button. After action messages fade, the hint describes the nearby bed and shows a countdown while a watered crop grows.

Seeds cost 5g. Plant, then water. A watered crop matures in 12 seconds; harvesting earns 20g. Unwatered crops wait. Saves are automatic after actions and every 10 seconds; the Save button also saves. Saves are local to each device, stored in Godot's `user://farm_save.json`, and are not synced through GitHub.

The on-screen joystick supports dragging and simultaneous touches with the action controls. Landscape UI expands without stretching artwork, with extra scene space for different screen shapes. Controls account for reported mobile safe areas. Resize the desktop window to compare wide phone and 4:3 tablet layouts. Actual iPhone/iPad testing remains pending.

## Current scope

- Connected 2400 × 1600 map and following camera.
- New games offer a Boy/Girl choice; the Farmer button changes it later without resetting progress. The local save remembers the choice.
- Larger phone-readable farmer with eight facing directions and two alternating stride frames per direction. Movement is continuous; artwork selects the nearest 45-degree direction. Stopping holds the last facing pose.
- Building, terrace and waterfront collision, 15 crop beds, tool selection, farming loop and local persistence.
- Starter house and crop field occupy the southwest corner. Open terraces to the east and north reserve room for expansion; unlock progression is not implemented yet. Older saves keep coins and crops and relocate the player to the new starter field.
- Scenery is currently one static background plate. Decorative fences and plants do not all have collisions or depth sorting. Props will need separate assets for full interaction.
- No building interiors, NPC systems, sound, inventory, polished idle and longer animation cycles, or final terrain tileset.
- iOS source project only: this ZIP is not an installable iPhone app. Device export needs a Mac, Xcode, Godot export templates, and Apple signing setup.

## Validation

The existing farming loop was previously verified with Godot 4.5.1: clean asset import and game startup, planting cost, water requirement, timed growth, harvest payout and replanting, repeated-action protection, save/load, waterfront collision, and phone/tablet control bounds. Rendered desktop screenshots are in `docs/`. Automated checks are in `tests/smoke.gd`: run Godot with `--headless --path . --script res://tests/smoke.gd`. Run checks with a separate user-data profile because they write a test save.

The nearby-bed hints and growth countdown still need a Godot runtime check.

## Working on another computer

Clone or download this private repository while signed into your GitHub account, then import the same `project.godot`. Commit/push work before switching computers; pull updates on the other computer. The `.godot` import cache is excluded and rebuilt automatically. Concept PNGs and project assets are included; they currently fit in ordinary Git. Never commit credentials or Apple signing certificates.
