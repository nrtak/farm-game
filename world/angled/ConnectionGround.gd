extends Node2D
var farm
func _ready():
 z_index=-900;texture_repeat=CanvasItem.TEXTURE_REPEAT_ENABLED
func _process(_delta):
 visible=not farm.inside_house and farm.location in preload("res://OutdoorContinuity.gd").AREAS
func lane(a:Vector2,b:Vector2,width:float):
 var side=(b-a).normalized().orthogonal()*width*.5
 var poly=PackedVector2Array([a-side,b-side,b+side,a+side,a-side])
 poly.remove_at(poly.size()-1)
 poly=preload("res://world/angled/TerrainFinish.gd").rounded(poly)
 preload("res://world/angled/TerrainFinish.gd").dirt(self,poly)
 var count=maxi(1,int(a.distance_to(b)/20))
 for i in range(count):
  var p=a.lerp(b,float(i)/count)
  draw_line(p+side*.2,p+side*.2+Vector2(3,1),Color(.57,.46,.29,.25),1,true)
func _draw():
 if farm==null:return
 var t=farm.TOWN_ORIGIN;var g=farm.town.G
 for pair in [[t+g.project(Vector2(1300,315)),farm.REGION_ORIGINS.mountain+Vector2(800,1080)],[t+g.project(Vector2(360,315)),farm.REGION_ORIGINS.historic+Vector2(1440,1080)],[t+g.project(Vector2(205,910)),farm.REGION_ORIGINS.harbor+Vector2(1480,585)],[t+g.project(Vector2(1300,1545)),Vector2(1485,260)],[farm.REGION_ORIGINS.mountain+Vector2(1480,900),farm.REGION_ORIGINS.tea+Vector2(180,675)]]:
  lane(pair[0],pair[1],150)
