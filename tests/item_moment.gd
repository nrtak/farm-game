extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var farm = load("res://Main.tscn").instantiate()
	root.add_child(farm)
	await process_frame
	farm.set_physics_process(false)
	farm.choose_character("boy")
	farm.window_focused = true
	for item in ["Turnip", "Potato", "Strawberry", "Copper", "Iron", "Tea leaves", "Sardine", "Mackerel", "Sea Bream", "Wallet"]:
		farm.show_item_moment(item)
		assert(farm.item_moment.visible and farm.item_moment.item == item)
		assert(farm.facing_direction == 0)
		var where: Vector2 = farm.player.position
		var minute: float = farm.clock_minutes
		farm._physics_process(0.5)
		assert(farm.player.position == where and farm.clock_minutes == minute)
		farm._physics_process(0.5)
		assert(not farm.item_moment.visible and farm.pickup_time == 0)
	farm.show_item_moment("Iron")
	farm.travel_to("town", Vector2(1200, 910), false)
	assert(not farm.item_moment.visible)
	print("PASS: ten item icons, front-facing display, brief movement/clock pause, automatic dismissal, travel cleanup")
	quit()
