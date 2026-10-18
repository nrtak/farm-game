extends Node2D
const G=preload("res://world/town/TownDisplayGeometry.gd")
var data:Dictionary
var grass:Texture2D
func _ready():
 data=G.layout();grass=load("res://world/town/grass.png");texture_repeat=CanvasItem.TEXTURE_REPEAT_ENABLED;z_index=-1000;queue_redraw()
func quad(r:Rect2,c:Color):draw_colored_polygon(G.polygon(r),c)
func _draw():
 if data==null or data.is_empty():return
 var rng=RandomNumberGenerator.new();rng.seed=817
 quad(G.WORLD,Color("8eae62"))
 var vertices=G.polygon(G.WORLD)
 var uv=PackedVector2Array()
 var basis=preload("res://world/angled/WorldPerspective.gd").BASIS
 for vertex in vertices:uv.append((basis.affine_inverse()*(vertex-G.ORIGIN)+get_parent().get_parent().position)/grass.get_size())
 draw_polygon(vertices,PackedColorArray([Color(.95,.98,.90,.58)]),uv,grass)
 quad(Rect2(310,275,100,195),Color("d9c8a3"))
 quad(Rect2(850,350,100,260),Color("d9c8a3"))
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
 for a in data.roads+data.aprons+[data.plaza]:quad(G.rect(a).grow(5),Color("c0b091"));quad(G.rect(a),Color("d9c8a3"))
 for y in range(280,1590,14):
  for x in range(165,2170,22):
   var p=Vector2(x+(11 if y%28==0 else 0),y)
   if G.on_road(p+Vector2(11,7),data):
    var colors=[Color("e9d8b5"),Color("decaa4"),Color("d3c5a6"),Color("efe0c1")]
    var tone=colors[rng.randi_range(0,3)]
    quad(Rect2(p,Vector2(20,12)),tone)
