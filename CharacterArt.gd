extends RefCounted

static var portrait_cache: Dictionary = {}
static var walk_cache: Dictionary = {}
const PORTRAITS := {
	"Aya": ["romance", 0, 6], "Hana": ["romance", 1, 6], "Mika": ["romance", 2, 6], "Yuta": ["romance", 3, 6], "Hiro": ["romance", 5, 6],
	"Shohei": ["town", 1, 4], "Akira": ["town", 2, 4], "Taro": ["town", 3, 4],
	"Kenji": ["shops", 1, 6], "Gen": ["shops", 2, 6], "Yumi": ["shops", 3, 6], "Jiro": ["shops", 4, 6], "Naomi": ["shops", 5, 6],
	"Sachiko": ["regions", 0, 6], "Kenta": ["regions", 1, 6], "Rei": ["regions", 3, 6], "Masao": ["regions", 4, 6],
	"Ren": ["onsen", 0, 5], "Renji": ["onsen", 3, 5], "Midori": ["onsen", 4, 5],
	"Ken": ["wardrobe", 0, 6], "Seira": ["wardrobe", 1, 6], "Keiko": ["wardrobe", 2, 6], "Emi": ["wardrobe", 3, 6], "Chanel": ["wardrobe", 4, 6], "David": ["wardrobe", 5, 6],
	"Haruka": ["haruka", 0, 1]
}

static func canonical_name(person: String) -> String:
	return "Haruka" if person == "Yoshi" else person

static func walk(person: String) -> Texture2D:
	person = canonical_name(person)
	if walk_cache.has(person): return walk_cache[person]
	var path := "res://assets/characters/walk-%s-v2.png" % person.to_lower()
	if not ResourceLoader.exists(path):
		var old := "yoshi" if person == "Haruka" else person.to_lower()
		path = "res://assets/npc-%s-walk.png" % old
		if not ResourceLoader.exists(path): path = "res://assets/npc-%s-walk-v1.png" % old
	var texture: Texture2D = load(path) if ResourceLoader.exists(path) else null
	walk_cache[person] = texture
	return texture

static func portrait(person: String) -> Texture2D:
	person = canonical_name(person)
	if portrait_cache.has(person): return portrait_cache[person]
	if not PORTRAITS.has(person): return null
	var info: Array = PORTRAITS[person]
	var texture: Texture2D = load("res://assets/characters/portraits-%s-v2.png" % info[0])
	var source := preload("res://RuntimeArt.gd").readable_image(texture)
	if source==null: return null
	var width := float(source.get_width()) / int(info[2])
	# Display the upper body, excluding sheet labels and neighbouring figures.
	var top := 20 if person != "Haruka" else 35
	var height := mini(850 if person != "Haruka" else 1360, source.get_height() - top)
	var image := source.get_region(Rect2i(int(width * int(info[1])) + 3, top, int(width) - 6, height))
	image.convert(Image.FORMAT_RGBA8)
	clear_connected_background(image)
	image = image.get_region(Rect2i(0,0,image.get_width(),mini(675,image.get_height())))
	var bounds := image.get_used_rect()
	if bounds.has_area(): image = image.get_region(bounds)
	var result := ImageTexture.create_from_image(image)
	portrait_cache[person] = result
	return result

static func is_paper(color: Color) -> bool:
	return minf(color.r, minf(color.g, color.b)) > 0.57 and color.g >= color.r - 0.025 and color.g >= color.b - 0.025 and maxf(color.r, maxf(color.g, color.b)) - minf(color.r, minf(color.g, color.b)) < 0.25

static func clear_connected_background(image: Image) -> void:
	if image==null or image.is_empty(): return
	var width := image.get_width()
	var height := image.get_height()
	var seen := PackedByteArray()
	seen.resize(width * height)
	var pending := PackedInt32Array()
	for x in range(width): pending.append(x); pending.append((height - 1) * width + x)
	for y in range(height): pending.append(y * width); pending.append(y * width + width - 1)
	var cursor := 0
	while cursor < pending.size():
		var index := pending[cursor]
		cursor += 1
		if seen[index]: continue
		seen[index] = 1
		var x := index % width
		var y := int(index / width)
		var color := image.get_pixel(x, y)
		if not is_paper(color): continue
		color.a = 0
		image.set_pixel(x, y, color)
		if x > 0 and not seen[index - 1]: pending.append(index - 1)
		if x < width - 1 and not seen[index + 1]: pending.append(index + 1)
		if y > 0 and not seen[index - width]: pending.append(index - width)
		if y < height - 1 and not seen[index + width]: pending.append(index + width)
