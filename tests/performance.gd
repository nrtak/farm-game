extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var startup := Time.get_ticks_usec()
	var farm = load("res://Main.tscn").instantiate()
	root.add_child(farm)
	await process_frame
	farm.set_physics_process(false)
	farm.choose_character("boy")
	farm.window_focused = true
	farm.travel_to("town", Vector2(1200, 950), false)
	print("Startup including image preparation: %.2f seconds" % ((Time.get_ticks_usec() - startup) / 1000000.0))
	var started := Time.get_ticks_usec()
	for tick in range(6000): farm.town.tick(1.0 / 60, 600)
	print("Town simulation, 14 residents: %.3f ms per update (6000 updates)" % ((Time.get_ticks_usec() - started) / 6000000.0))
	farm.begin_festival()
	started = Time.get_ticks_usec()
	for tick in range(6000):
		farm.festival_elapsed += 1.0 / 60
		farm.animate_festival()
	print("Festival animation, 22 residents: %.3f ms per update (6000 updates)" % ((Time.get_ticks_usec() - started) / 6000000.0))
	farm.end_festival()
	print("Runtime memory during test: %.1f MiB; desktop headless measurement, not mobile battery data" % (Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0))
	farm.queue_free()
	await process_frame
	quit()
