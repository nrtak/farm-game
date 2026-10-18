extends Node2D
var farm
var grass=preload("res://world/town/grass.png")
func _ready():
 z_index=-4090
 texture_repeat=CanvasItem.TEXTURE_REPEAT_ENABLED
 var seasonal=ShaderMaterial.new();seasonal.shader=preload("res://SeasonScenery.gdshader");material=seasonal
 farm.season_scenery.materials.append(seasonal)
 seasonal.set_shader_parameter("season",float(int((farm.day-1)/28)%4))
func _process(_delta):
 visible=not farm.inside_house and farm.location in preload("res://OutdoorContinuity.gd").AREAS
func _draw():
 var bounds=Rect2(-5000,-6000,11000,10000)
 draw_rect(bounds,Color("8eae62"))
 draw_texture_rect(grass,bounds,true,Color(.95,.98,.90,.58))
