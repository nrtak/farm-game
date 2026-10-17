extends RefCounted

const Festivals = preload("res://SeasonalFestivals.gd")
const Life = preload("res://EverydayLife.gd")
const PLACES := {"town":"Town square", "tea":"Tea country", "harbor":"West harbor", "historic":"Shrine grounds", "mountain":"Mountain onsen"}

static func entries(f, day_of_year: int) -> Array:
	var result: Array = []
	for event in Festivals.EVENTS:
		if event.day == day_of_year:
			result.append({"kind":"festival", "title":event.name, "event":event})
	for person in f.friendship:
		if Life.birthday(f, person) == day_of_year:
			result.append({"kind":"birthday", "title":person})
	return result

static func open(f, season: int = -1) -> void:
	if season < 0: season = int(posmod(f.day - 1, 112) / 28)
	season = posmod(season, 4)
	var column = f.make_modal("Village calendar · " + f.SEASONS[season])
	f.dialogue_panel.get_child(0).offset_top = -minf(470, f.get_viewport_rect().size.y - 32)
	f.dialogue_text.text = f.calendar_text() + " · ★ Festival   • Birthday   [ ] Today"
	f.dialogue_text.add_theme_font_size_override("font_size", 17)
	f.dialogue_text.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	var nav := HBoxContainer.new()
	column.add_child(nav)
	for i in range(4):
		var button = f.make_button(f.SEASONS[i], open.bind(f, i))
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.disabled = i == season
		nav.add_child(button)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size.y = 100
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(scroll)
	var grid := GridContainer.new()
	grid.name = "CalendarDays"
	grid.columns = 7
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 5)
	grid.add_theme_constant_override("v_separation", 5)
	scroll.add_child(grid)
	for date in range(1, 29):
		var annual_day: int = season * 28 + date
		var marks := ""
		var descriptions: PackedStringArray = []
		for entry in entries(f, annual_day):
			var marker := "★" if entry.kind == "festival" else "•"
			if not marks.contains(marker): marks += marker
			descriptions.append(entry.title + (" birthday" if entry.kind == "birthday" else ""))
		var today: bool = annual_day == posmod(f.day - 1, 112) + 1
		var label := ("[%d]" if today else "%d") % date
		var button = f.make_button(label + "  " + marks, show_day.bind(f, annual_day))
		button.custom_minimum_size.y = 48
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.tooltip_text = "\n".join(descriptions) if not descriptions.is_empty() else "A free day for farm life."
		grid.add_child(button)
	column.add_child(f.make_button("Close", f.close_dialogue))

static func show_day(f, annual_day: int) -> void:
	var season: int = int((annual_day - 1) / 28)
	var column = f.make_modal("%s %d" % [f.SEASONS[season], (annual_day - 1) % 28 + 1])
	f.dialogue_text.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	var lines: PackedStringArray = []
	var people: Array = []
	for entry in entries(f, annual_day):
		if entry.kind == "festival":
			var event: Dictionary = entry.event
			var evening: bool = event.id in ["obon", "lantern", "onsen", "newyear"]
			lines.append("★ %s\n%s · %s" % [event.name, PLACES.get(event.area, event.area), "6–10 PM" if evening else "10 AM–6 PM"])
		else:
			lines.append("• %s's birthday · A thoughtful gift is a nice way to celebrate." % entry.title)
			people.append(entry.title)
	if lines.is_empty(): lines.append("No scheduled celebration. Tend the farm, visit neighbors, or explore at your own pace.")
	f.dialogue_text.text = "\n\n".join(lines)
	for person in people:
		column.add_child(f.make_button("About " + person, Life.relationship.bind(f, person)))
	column.add_child(f.make_button("Back to " + f.SEASONS[season], open.bind(f, season)))
	column.add_child(f.make_button("Close", f.close_dialogue))
