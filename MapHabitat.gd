extends RefCounted
# CPU classifications are packaged separately from GPU textures. Navigation and
# wildlife must never depend on a graphics driver's texture readback succeeding.
static var masks: Dictionary = {}
static func sample(kind: String, point: Vector2, world_size: Vector2, layer: String) -> bool:
	if masks.is_empty():
		var data = JSON.parse_string(FileAccess.get_file_as_string("res://data/map_habitats.json"))
		if not data is Dictionary: return false
		for key in data:
			var entry: Dictionary = data[key]
			masks[key] = {"width":int(entry.width),"height":int(entry.height),"path":Marshalls.base64_to_raw(entry.path),"grass":Marshalls.base64_to_raw(entry.grass)}
	if not masks.has(kind) or world_size.x<=0 or world_size.y<=0: return false
	var entry: Dictionary = masks[kind]
	var width: int = entry.width
	var height: int = entry.height
	var uv := point/world_size
	var x := clampi(int(uv.x*width),0,width-1)
	var y := clampi(int(uv.y*height),0,height-1)
	var index := y*width+x
	var pixels: PackedByteArray = entry.get(layer,PackedByteArray())
	if (index>>3)>=pixels.size(): return false
	return (pixels[index>>3] & (1<<(index&7)))!=0
