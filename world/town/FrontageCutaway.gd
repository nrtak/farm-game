extends Node2D
const G=preload("res://world/town/TownGeometry.gd")
var building:Array=[]
func _ready():
 z_index=int(G.project(Vector2(building[1]+building[3]/2.0,building[2]+building[4])).y/10)
 queue_redraw()
func tile(r:Rect2,color:Color):draw_colored_polygon(G.polygon(r),color)
func wall(a:Vector2,b:Vector2):
 var p=G.project(a);var q=G.project(b);var rise=Vector2(0,-42)
 draw_colored_polygon(PackedVector2Array([p,q,q+rise,p+rise]),Color("e6d6b4"))
 draw_line(p+rise,q+rise,Color("775737"),5,true)
 draw_line(p,p+rise,Color("775737"),4,true)
 draw_line(q,q+rise,Color("775737"),4,true)
func _draw():
 if building.is_empty():return
 var r=Rect2(building[1],building[2],building[3],building[4])
 var color=Color({"Inn":"c7af92","Restaurant":"bb9873","Store":"aebf92","Cafe":"d9b59e","Ranch":"b9ab7d","Vet":"acc9c8"}.get(building[0],"c7af92"))
 tile(r, color)
 for y in range(int(r.position.y)+12,int(r.end.y),12):
  draw_line(G.project(Vector2(r.position.x,y)),G.project(Vector2(r.end.x,y)),color.darkened(.13),1,true)
 var corners=[r.position,Vector2(r.end.x,r.position.y),r.end,Vector2(r.position.x,r.end.y)]
 var front={"N":0,"E":1,"S":2,"W":3}[building[5]]
 for i in range(4):
  var a:Vector2=corners[i];var b:Vector2=corners[(i+1)%4]
  if i==front:
   wall(a,a.lerp(b,.34));wall(a.lerp(b,.66),b)
  else:wall(a,b)
 var counter=Rect2(r.position+Vector2(18,70),Vector2(130,22)) if front==0 else Rect2(r.position+Vector2(16,18),Vector2(26,74))
 tile(counter,Color("896542"))
 var rug=Rect2(r.position+Vector2(60,25),Vector2(55,35))
 tile(rug,color.darkened(.25))
 for i in range(3):
  draw_circle(G.project(counter.position+Vector2(12+i*32,8) if front==0 else counter.position+Vector2(12,12+i*24)),4,Color("e4c278"))
 var door=G.door(building)
 var threshold=Rect2(door-Vector2(22,7),Vector2(44,14)) if front==0 else Rect2(door-Vector2(7,22),Vector2(14,44))
 tile(threshold,Color("c7b48c"))
