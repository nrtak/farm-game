extends Node2D
const G=preload("res://world/town/TownDisplayGeometry.gd")
var data:Dictionary
var grass:Texture2D
var paving:Array=[]
func _ready():
 data=G.layout();grass=load("res://world/town/grass.png");texture_repeat=CanvasItem.TEXTURE_REPEAT_ENABLED;z_index=-1000;queue_redraw()
 data.aprons.append_array([[1750,480,150,180],[850,350,100,330]])
 for a in data.roads+data.aprons+[data.plaza]:
  var shape=G.polygon(G.rect(a))
  var changed=true
  while changed:
   changed=false
   for i in range(paving.size()):
    var merged=Geometry2D.merge_polygons(shape,paving[i])
    if merged.size()==1:shape=merged[0];paving.remove_at(i);changed=true;break
  paving.append(shape)
func quad(r:Rect2,c:Color):draw_colored_polygon(G.polygon(r),c)
func _draw():
 if data==null or data.is_empty():return
 var rng=RandomNumberGenerator.new();rng.seed=817
 quad(G.WORLD,Color("8eae62"))
 var vertices=G.polygon(G.WORLD)
 var uv=PackedVector2Array()
 var basis=preload("res://world/angled/WorldPerspective.gd").BASIS
 for vertex in vertices:uv.append((basis.affine_inverse()*(vertex-G.ORIGIN)+get_parent().get_parent().position)/grass.get_size())
 draw_polygon(vertices,PackedColorArray([Color(.95,.98,.90,.26)]),uv,grass)
 preload("res://world/angled/TerrainFinish.gd").shade(self,vertices)
 for i in range(450):
  var point=Vector2(rng.randf_range(230,1850),rng.randf_range(290,1540))
  if G.on_road(point,data):continue
  var p=G.project(point)
  if sin(point.x*.021)+cos(point.y*.017)<1.0:continue
  draw_line(p,p+Vector2(1,-5),Color("6b8846"),1.5,true)
  draw_circle(p+Vector2(1,-5),2,Color("e8d7a2") if i%2 else Color("d5a7b6"))
 for apron in [Rect2(310,275,100,195),Rect2(850,350,100,260)]:
  preload("res://world/angled/TerrainFinish.gd").dirt(self,preload("res://world/angled/TerrainFinish.gd").rounded(G.polygon(apron)))
 # Low planting beds occupy the unused backs of the blocks, never the streets.
 for row in [500,780,1060,1340]:
  for x in [1080,1430,1770]:
   var bed=Rect2(x,row-62,110,28)
   if G.on_road(bed.get_center(),data):continue
   quad(bed.grow(3),Color("857253"));quad(bed,Color("718b4c"))
   for n in range(8):
    var flower=G.project(Vector2(x+8+n*13,row-49))
    draw_circle(flower,3.5,Color("4f713c"))
    draw_circle(flower+Vector2(0,-2),1.8,Color("efd0a0") if n%2==0 else Color("dca0b4"))
 for shape in paving:
  draw_colored_polygon(shape,Color("b8a47e"))
  var edge=shape.duplicate();edge.append(shape[0]);draw_polyline(edge,Color("baad8a"),5,true)
 for y in range(280,1590,14):
  for x in range(165,2170,22):
   var p=Vector2(x+(11 if y%28==0 else 0),y)
   if G.on_road(p+Vector2(11,7),data):
    var colors=[Color("e9d8b5"),Color("decaa4"),Color("d3c5a6"),Color("efe0c1")]
    var tone=colors[rng.randi_range(0,3)]
    var tile=Rect2(p,Vector2(20,12))
    for a in data.roads+data.aprons+[data.plaza]:
     var clipped=tile.intersection(G.rect(a))
     if clipped.has_area():quad(clipped,tone)
