extends RefCounted

static var textures: Dictionary = {}

static func turnaround(group: int) -> Texture2D:
	if textures.has(group): return textures[group]
	var source: Texture2D = load("res://assets/npc-turnaround-group-%d.png" % group)
	var image := preload("res://RuntimeArt.gd").readable_image(source)
	if image==null: return null
	image.convert(Image.FORMAT_RGBA8)
	# Remove only the connected paper outside the outlined figures. White
	# clothing enclosed by outlines stays opaque. This happens once per sheet.
	var width := image.get_width()
	var height := image.get_height()
	var visited := PackedByteArray()
	visited.resize(width * height)
	var queue := PackedInt32Array()
	for x in range(width):
		queue.append(x)
		queue.append((height - 1) * width + x)
	for y in range(height):
		queue.append(y * width)
		queue.append(y * width + width - 1)
	var cursor := 0
	while cursor < queue.size():
		var index := queue[cursor]
		cursor += 1
		if visited[index] != 0: continue
		visited[index] = 1
		var x := index % width
		var y := index / width
		var color := image.get_pixel(x, y)
		if color.r < 0.88 or color.g < 0.85 or color.b < 0.73: continue
		color.a = 0.0
		image.set_pixel(x, y, color)
		if x > 0 and visited[index - 1] == 0: queue.append(index - 1)
		if x < width - 1 and visited[index + 1] == 0: queue.append(index + 1)
		if y > 0 and visited[index - width] == 0: queue.append(index - width)
		if y < height - 1 and visited[index + width] == 0: queue.append(index + width)
	textures[group] = ImageTexture.create_from_image(image)
	return textures[group]
