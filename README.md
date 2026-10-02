# Coastal Farm — playable prototype

A Godot 4.5.1 project exploring a connected Japanese coastal hillside farm. This first build uses a generated Japanese farmhouse and a static farmer sprite, with simplified terrain and a single Mount Kaimon-inspired mountain. The concept paintings are the target visual direction; they are not screenshots of this build.

## Open and play

1. Download the repository ZIP from GitHub (Code → Download ZIP), or clone it.
2. Extract it. In Godot 4.5.1 or newer, choose **Import** and select `project.godot`.
3. Open the project and press **F5**.

Move with WASD or arrows. Select Seed, Water, or Harvest with the buttons or keys 1, 2, 3. Stand close to a highlighted bed and press Space, E, Enter, or the action button.

Seeds cost 5g. Plant, then water. A watered crop matures in 12 seconds; harvesting earns 20g. Unwatered crops wait. Saves are automatic after actions and every 10 seconds; the Save button also saves. Saves are local to each device, stored in Godot's `user://farm_save.json`, and are not synced through GitHub.

The on-screen joystick supports dragging and simultaneous touches with the action controls. Landscape UI expands without stretching artwork, with extra scene space for different screen shapes. Controls account for reported mobile safe areas. Resize the desktop window to compare wide phone and 4:3 tablet layouts. Actual iPhone/iPad testing remains pending.

## Current scope

- Connected 2400 × 1600 map and following camera.
- Farmhouse and obstacle collision, 15 crop beds, tool selection, farming loop and local persistence.
- Illustrative future animal-yard and woodland areas; no unlock progression yet.
- No building interiors, NPC systems, sound, inventory, finished walking animations, or final terrain tileset.
- iOS source project only: this ZIP is not an installable iPhone app. Device export needs a Mac, Xcode, Godot export templates, and Apple signing setup.

## Validation

Verified with Godot 4.5.1: clean asset import and game startup, planting cost, water requirement, timed growth, harvest payout and replanting, repeated-action protection, save/load, farmhouse collision, and phone/tablet control bounds. Rendered desktop screenshots are in `docs/`. Automated checks are in `tests/smoke.gd`: run Godot with `--headless --path . --script res://tests/smoke.gd`. Run checks with a separate user-data profile because they write a test save.

## Working on another computer

Clone or download this private repository while signed into your GitHub account, then import the same `project.godot`. Commit/push work before switching computers; pull updates on the other computer. The `.godot` import cache is excluded and rebuilt automatically. Concept PNGs and project assets are included; they currently fit in ordinary Git. Never commit credentials or Apple signing certificates.
