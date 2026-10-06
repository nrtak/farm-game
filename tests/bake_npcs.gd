extends SceneTree

func _initialize() -> void:
	var people: Array = ["Seira", "Shohei", "Akira", "Taro"]
	for group in preload("res://Cast.gd").GROUPS: people.append_array(group)
	var result := {}
	for person in people:
		var path := "res://assets/npc-%s-walk.png" % person.to_lower()
		var texture: Texture2D = load(path)
		var figures := find_figures(texture.get_image())
		assert(figures.size() == 16, "Sixteen complete figures detected for " + person)
		var rects: Array = []
		var offsets: Array = []
		var tallest := 1.0
		for row in range(4):
			var ground := 0.0
			for phase in range(4):
				ground = maxf(ground, figures[row * 4 + phase].end.y)
				tallest = maxf(tallest, figures[row * 4 + phase].size.y)
			for phase in range(4):
				var rect: Rect2i = figures[row * 4 + phase]
				rects.append([rect.position.x, rect.position.y, rect.size.x, rect.size.y])
				offsets.append([0, rect.get_center().y - ground])
		result[person] = {"width": texture.get_width(), "height": texture.get_height(), "regions": rects, "offsets": offsets, "scale": 150.0 / tallest}
	var output := FileAccess.open("res://assets/npc-geometry.json", FileAccess.WRITE)
	output.store_string(JSON.stringify(result))
	output.close()
	print("PASS: precomputed sixteen frames for all 22 residents")
	quit()

func find_figures(image: Image) -> Array:
	# Generated sheets have uneven gutters. Detect whole connected figures
	# instead of dividing the canvas into cells that can cut off heads and boots.
	var width := image.get_width()
	var height := image.get_height()
	var mask := PackedByteArray()
	mask.resize(width * height)
	for y in range(height):
		for x in range(width): mask[y * width + x] = 1 if image.get_pixel(x, y).a >= 0.15 else 0
	var components: Array = []
	for index in range(mask.size()):
		if mask[index] == 0: continue
		var pending := PackedInt32Array([index])
		mask[index] = 0
		var first := Vector2i(width, height)
		var last := Vector2i.ZERO
		var count := 0
		while not pending.is_empty():
			var pixel := pending[pending.size() - 1]
			pending.resize(pending.size() - 1)
			var x := pixel % width
			var y := int(pixel / width)
			first = Vector2i(mini(first.x, x), mini(first.y, y))
			last = Vector2i(maxi(last.x, x), maxi(last.y, y))
			count += 1
			for dy in range(-1, 2):
				for dx in range(-1, 2):
					var nx := x + dx
					var ny := y + dy
					if nx < 0 or ny < 0 or nx >= width or ny >= height: continue
					var next := ny * width + nx
					if mask[next] == 0: continue
					mask[next] = 0
					pending.append(next)
		if count > 200: components.append({"rect": Rect2i(first, last - first + Vector2i.ONE), "count": count})
	components.sort_custom(func(a, b): return a.count > b.count)
	assert(components.size() >= 16, "Sheet must contain sixteen independent figures")
	components.resize(16)
	components.sort_custom(func(a, b): return a.rect.get_center().y < b.rect.get_center().y)
	var figures: Array = []
	for row in range(4):
		var poses := components.slice(row * 4, row * 4 + 4)
		poses.sort_custom(func(a, b): return a.rect.get_center().x < b.rect.get_center().x)
		for pose in poses: figures.append(pose.rect)
	return figures
