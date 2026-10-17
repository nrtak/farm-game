import os, subprocess, sys, uuid
from pathlib import Path
root = Path(__file__).resolve().parents[1]
override = root / "override.cfg"
previous = override.read_bytes() if override.exists() else None
checks = ["town_integration", "town_connected_walk", "world_smoke", "farming_loop", "fishing", "tea", "mining", "item_moment", "backpack", "storage", "upgrades_weather", "calendar", "routines", "ambient", "progression", "stewardship", "polish", "farm_systems", "region_layout", "daily_polish", "walk_feedback", "home_recovery", "runtime_art", "layout_feedback", "movement_recovery", "open_regions", "feedback_release", "tea_tasting", "door_routes", "town_interiors", "town_activities", "player_feedback", "world_comfort", "indoor_clock", "expansion_fifty", "save_soak", "game_audio", "ranch_services", "everyday_life", "year_cycle", "farm_dog", "story_arc", "home_weather", "recipe_book", "home_expansion", "construction_journal", "everyday_controls", "visual_cues"]
checks[:0] = ["angled_world", "angled_world_regressions"]
try:
    start = os.environ.get("FARM_CHECK_START", "")
    if start:
        checks = checks[checks.index(start):]
    for name in checks:
        override.write_text('[application]\nconfig/use_custom_user_dir=true\nconfig/custom_user_dir_name="CoastalFarmCI/' + name + '-' + uuid.uuid4().hex + '"\n', encoding="utf-8")
        result = subprocess.run([os.environ.get("GODOT_BIN", "godot"), "--headless", "--path", str(root),
                                 "--script", "res://tests/" + name + ".gd", "--quit-after", "600"],
                                capture_output=True, text=True, timeout=90)
        output = result.stdout + result.stderr
        if result.returncode or "PASS:" not in output or "SCRIPT ERROR" in output or "ERROR:" in output:
            print(output)
            raise RuntimeError("Failed check: " + name)
        print(next(line for line in output.splitlines() if line.startswith("PASS:")))
finally:
    if previous is None: override.unlink(missing_ok=True)
    else: override.write_bytes(previous)
