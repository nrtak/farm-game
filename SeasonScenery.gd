extends RefCounted
var last_season := -1
var materials: Array[ShaderMaterial] = []
func setup(farm) -> void:
	var surfaces: Array = [farm.get_node("OutdoorWorld/Environment") if farm.has_node("OutdoorWorld/Environment") else farm.get_node("Environment"),farm.farmhouse.get_node("Artwork"),farm.town]
	for child in farm.town.get_children():
		if child is Sprite2D and child.z_index == -10: surfaces.append(child)
	surfaces.append_array(farm.regions.values())
	for surface in surfaces:
		var material := ShaderMaterial.new()
		material.shader = preload("res://SeasonScenery.gdshader")
		surface.material=material
		materials.append(material)
	update(farm.day)
func update(day: int) -> void:
	var season := int((day-1)/28)%4
	if season==last_season: return
	last_season=season
	for material in materials: material.set_shader_parameter("season",float(season))
