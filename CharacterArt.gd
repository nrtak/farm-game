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
	if person in ["Mika","Seira"]:
		var single:Texture2D=load("res://assets/characters/portrait-"+person.to_lower()+"-v3.png")
		portrait_cache[person]=single
		return single
	if not PORTRAITS.has(person): return null
	var info: Array = PORTRAITS[person]
	var source := Image.new()
	var bytes := FileAccess.get_file_as_bytes("res://data/portraits/"+str(info[0])+".bin")
	if source.load_png_from_buffer(bytes)!=OK: return null
	if source==null: return null
	var cuts: Array = {
		"wardrobe":[0.0,0.219,0.35,0.495,0.656,0.787,1.0],
		"town":[0.0,0.238,0.515,0.716,1.0],
		"romance":[0.0,0.165,0.319,0.466,0.65,0.824,1.0],
		"shops":[0.0,0.159,0.317,0.5,0.64,0.84,1.0],
		"regions":[0.0,0.184,0.35,0.489,0.637,0.826,1.0],
		"onsen":[0.018,0.23,0.39,0.593,0.793,0.98],
		"haruka":[0.0,1.0]
	}[info[0]]
	var left:=int(cuts[int(info[1])]*source.get_width())
	var right:=int(cuts[int(info[1])+1]*source.get_width())
	if person=="Mika": right=int(source.get_width()*0.478)
	if person=="Seira": right=int(source.get_width()*0.366)
	if person=="Yuta": left=int(source.get_width()*0.478)
	if person=="Gen": left=int(source.get_width()*0.326)
	# Upper-body framing uses the sheet dimensions, preserving heads and shoulders.
	var image:=source.get_region(Rect2i(left,0,right-left,int(source.get_height()*0.61)))
	image.convert(Image.FORMAT_RGBA8)
	clear_connected_background(image)
	# Two figures touch their neighbours below the shoulders on the source sheet.
	if person in ["Gen","Keiko"]:
		var seam_x:=int(source.get_width()*(0.326 if person=="Gen" else 0.365))-left
		var seam_y:=int(source.get_height()*(0.47 if person=="Gen" else 0.40))
		for y in range(seam_y,image.get_height()):
			for x in range(maxi(0,seam_x)): image.set_pixel(x,y,Color.TRANSPARENT)
	keep_main_figure(image)
	var bounds := image.get_used_rect()
	if bounds.has_area():
		var framed := Image.create(bounds.size.x+24,bounds.size.y+24,false,Image.FORMAT_RGBA8)
		framed.fill(Color.TRANSPARENT)
		framed.blit_rect(image,bounds,Vector2i(12,12))
		image = framed
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

static func keep_main_figure(image: Image) -> void:
	# Remove disconnected pieces of neighbouring figures at atlas boundaries.
	var width:=image.get_width()
	var height:=image.get_height()
	var seen:=PackedByteArray()
	seen.resize(width*height)
	var largest:=PackedInt32Array()
	for seed in range(width*height):
		if seen[seed] or image.get_pixel(seed%width,int(seed/width)).a<0.1: continue
		var component:=PackedInt32Array([seed])
		seen[seed]=1
		var cursor:=0
		while cursor<component.size():
			var index:=component[cursor]
			cursor+=1
			var x:=index%width
			var y:=int(index/width)
			for next in [index-1 if x>0 else -1,index+1 if x<width-1 else -1,index-width if y>0 else -1,index+width if y<height-1 else -1]:
				if next<0 or seen[next]: continue
				seen[next]=1
				if image.get_pixel(next%width,int(next/width)).a>=0.1: component.append(next)
		if component.size()>largest.size(): largest=component
	var keep:=PackedByteArray()
	keep.resize(width*height)
	for index in largest: keep[index]=1
	for index in range(width*height):
		if not keep[index]: image.set_pixel(index%width,int(index/width),Color.TRANSPARENT)
