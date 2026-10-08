extends RefCounted
static func readable_image(texture: Texture2D) -> Image:
	if texture==null: return null
	var image := texture.get_image()
	if image==null or image.is_empty(): return null
	if image.is_compressed() and image.decompress()!=OK: return null
	return image
