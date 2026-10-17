extends RefCounted
const ORIGIN=Vector2(120,1050)
const AXIS_X=Vector2(.86,-.32)
const AXIS_Y=Vector2(.58,.48)
const WORLD=Rect2(165,275,1835,1310)
const ALIASES={"Library":"Archive","Police":"Police Box","Fire":"Fire Station","Hospital":"Clinic","Store":"General Store","Cafe":"Caf\u00e9","Carpenter":"Carpentry","Vet":"Veterinarian"}
const EXITS=[["Highlands",Vector2(1300,300),Vector2(1300,365)],["Harbor",Vector2(185,910),Vector2(260,910)],["Shrine",Vector2(360,390),Vector2(360,470)],["Farm",Vector2(1300,1550),Vector2(1300,1480)]]
static func project(p:Vector2)->Vector2:return ORIGIN+AXIS_X*p.x+AXIS_Y*p.y
static func unproject(p:Vector2)->Vector2:
 var v=p-ORIGIN;var det=AXIS_X.x*AXIS_Y.y-AXIS_Y.x*AXIS_X.y
 return Vector2((v.x*AXIS_Y.y-v.y*AXIS_Y.x)/det,(v.y*AXIS_X.x-v.x*AXIS_X.y)/det)
static func polygon(r:Rect2)->PackedVector2Array:
 return PackedVector2Array([project(r.position),project(r.position+Vector2(r.size.x,0)),project(r.end),project(r.position+Vector2(0,r.size.y))])
static func rect(a:Array)->Rect2:return Rect2(a[0],a[1],a[2],a[3])
static func outward(b:Array)->Vector2:
 return {"N":Vector2.UP,"E":Vector2.RIGHT,"S":Vector2.DOWN,"W":Vector2.LEFT}[b[5]]
static func door(b:Array)->Vector2:
 var center=Vector2(b[1]+b[3]/2.0,b[2]+b[4]/2.0)
 var direction=outward(b)
 return center+direction*(Vector2(b[3],b[4])/2.0+Vector2.ONE*(48 if b[5] in ["N","E"] else 32))
static func back(b:Array)->Vector2:return door(b)+outward(b)*55
static func layout()->Dictionary:return JSON.parse_string(FileAccess.get_file_as_string("res://world/town/layout.json"))
static func river_distance(p:Vector2,data:Dictionary)->float:
 var distance=99999.0
 for i in range(data.river.size()-1):
  var a=Vector2(data.river[i][0],data.river[i][1]);var b=Vector2(data.river[i+1][0],data.river[i+1][1])
  distance=minf(distance,p.distance_to(Geometry2D.get_closest_point_to_segment(p,a,b)))
 return distance
static func on_road(p:Vector2,data:Dictionary)->bool:
 if rect(data.plaza).has_point(p):return true
 for a in data.roads+data.aprons:
  if rect(a).has_point(p):return true
 return false
