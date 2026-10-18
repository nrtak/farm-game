extends Node2D
var festival_decorated := false

const SIZE := Vector2(3000, 2000)
const ART_SCALE := 1.0
const NpcScript = preload("res://Npc.gd")
const Cast = preload("res://Cast.gd")
const SpriteLibrary = preload("res://SpriteLibrary.gd")
const G=preload("res://world/town/TownGeometry.gd")
var BUILDINGS:Array=[]
var data:Dictionary={}
var visuals:Node2D
var npcs: Array[Node2D] = []
var visitors: Array[Node2D] = []
var pets: Array[Node2D] = []
var ambient_period := -1
var greeting_time := 0.0
const EXTRA_DIALOGUE := {
    "Ren": ["I'm Ren. I prepare the mountain onsen baths and keep the resort running.", "The water is warmest when the morning air is cool. Come by for a soak."],
    "Chanel": ["I am Chanel. I welcome guests at the mountain onsen.", "Stop by for a quiet soak after working on the farm."],
    "David": ["David here. I carry deliveries between the general store and harbor.", "If you see a sleepy dog on the road, give it a little room."],
    "Renji": ["I'm Renji. I run the town ranch and help farmers choose their livestock.", "Visit the ranch for animals and feed. Your new animals settle straight into your barn."],
    "Midori": ["I'm Midori, the town veterinarian. I help keep your farm animals comfortable.", "Bring your questions to the veterinary clinic. I can arrange a wellness visit for your barn."]
}
const REST_BENCHES := [Rect2(1540, 562.963, 105, 23.7037), Rect2(1400, 590, 105, 23.7037)]
var solids: Array[Rect2] = []
var navigation := AStarGrid2D.new()
var land_outline := PackedVector2Array()
const TREE_CLUSTERS := []

func _ready() -> void:
 data=G.layout()
 visuals=preload("res://world/town/TownVisuals.gd").new();add_child(visuals)
 for b in data.buildings:
  var raw=Rect2(b[1],b[2],b[3],b[4])
  BUILDINGS.append({"name":G.ALIASES.get(b[0],b[0]),"rect":raw,"door":G.project(G.door(b)),"back":G.project(G.back(b)),"facing":b[5],"raw_door":G.door(b)})
  var body=StaticBody2D.new();body.collision_layer=4;body.collision_mask=0
  var shape=CollisionPolygon2D.new();shape.polygon=G.polygon(raw);body.add_child(shape);add_child(body)
 for person in ["Seira","Shohei","Akira","Taro"]:
  var npc=NpcScript.new();add_child(npc);npc.setup(person,preload("res://CharacterArt.gd").walk(person));npcs.append(npc)
 update_schedules(360)
 add_ambient_life()

func safe_point(point:Vector2)->Vector2:
 if is_walkable(point):return point
 for radius in range(12,600,12):
  for i in range(32):
   var p=point+Vector2.from_angle(i*TAU/32)*radius
   if is_walkable(p):return p
 return G.project(Vector2(1300,910))
func safe_npc_point(point:Vector2)->Vector2:
 for radius in range(0,600,16):
  for i in range(32):
   var p=point+Vector2.from_angle(i*TAU/32)*radius
   if is_npc_walkable(p):return p
 return G.project(Vector2(850,850))
func return_point(service:String)->Vector2:
 for b in BUILDINGS:
  if b.name==service:return safe_point(b.back)
 return G.project(Vector2(1300,910))
func arrival(area:String)->Vector2:
 return G.project({"farm":Vector2(1300,1480),"mountain":Vector2(1300,365),"tea":Vector2(1300,365),"harbor":Vector2(260,910),"historic":Vector2(360,470)}.get(area,Vector2(1300,910)))

func add_obstacle(rect: Rect2) -> void:
    var body := StaticBody2D.new()
    body.collision_layer = 4
    body.collision_mask = 0
    body.position = rect.get_center()
    var collision := CollisionShape2D.new()
    var shape := RectangleShape2D.new()
    shape.size = rect.size
    collision.shape = shape
    body.add_child(collision)
    add_child(body)

func add_label(text: String, where: Vector2, dimensions: Vector2) -> void:
    var label := Label.new()
    label.text = text
    label.position = where
    label.size = dimensions
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.add_theme_font_size_override("font_size", 22)
    label.add_theme_color_override("font_color", Color("403a2c"))
    label.add_theme_color_override("font_shadow_color", Color("f4e3bb"))
    label.add_theme_constant_override("shadow_offset_x", 2)
    label.add_theme_constant_override("shadow_offset_y", 2)
    add_child(label)

func update_schedules(minute:float)->void:
 var period=int(minute/180)
 for npc in npcs:
  if npc.period==period:continue
  var initial=npc.period<0
  npc.period=period
  var destination=preload("res://ResidentRoutine.gd").street_target(self,npc.first_name,minute)
  npc.scale=Vector2.ONE*.35
  npc.speed=52.0
  if initial or not npc.visible:
   npc.position=destination;npc.set_route([])
  else:
   npc.set_route(walk_route(npc.position,[destination]))

func add_supporting_cast() -> void:
    for person in Cast.HOMES:
        var npc := NpcScript.new()
        add_child(npc)
        npc.position = Cast.HOMES[person]
        var source := Cast.index_of(person)
        var walk_path := "res://assets/npc-%s-walk.png" % person.to_lower()
        if preload("res://CharacterArt.gd").walk(person) != null: npc.setup(person, preload("res://CharacterArt.gd").walk(person))
        else: npc.setup_turnaround(person, SpriteLibrary.turnaround(source.x), source.y, source.x)
        npc.z_index = 4
        npcs.append(npc)
    update_supporting_routes(360)

func update_supporting_routes(minute:float)->void:update_schedules(minute)
func walk_route(start:Vector2,destinations:Array)->Array:
 # Cardinal grid with sampled edges: no diagonal corner-cutting through frontages.
 if navigation.region.size==Vector2i.ZERO:
  navigation.region=Rect2i(4,7,43,32)
  navigation.cell_size=Vector2(40,40)
  navigation.diagonal_mode=AStarGrid2D.DIAGONAL_MODE_NEVER
  navigation.update()
  for y in range(7,39):
   for x in range(4,47):
    navigation.set_point_solid(Vector2i(x,y),not is_npc_walkable(G.project(Vector2(x,y)*40)))
 var result=[]
 var cursor=start
 for destination in destinations:
  var from_id=nearest_route_cell(cursor)
  var to_id=nearest_route_cell(destination)
  var ids=navigation.get_id_path(from_id,to_id)
  if ids.is_empty():continue
  var segment=[]
  var previous=cursor
  var safe=true
  for id in ids:
   var point=G.project(Vector2(id)*40)
   if not route_edge_clear(previous,point):safe=false;break
   segment.append(point);previous=point
  if safe and route_edge_clear(previous,destination):
   segment.append(destination);result.append_array(segment);cursor=destination
 return result
func nearest_route_cell(point:Vector2)->Vector2i:
 var best=Vector2i(25,23)
 var distance=INF
 for y in range(7,39):
  for x in range(4,47):
   var id=Vector2i(x,y)
   if navigation.is_point_solid(id):continue
   var candidate=G.project(Vector2(id)*40)
   var d=point.distance_squared_to(candidate)
   if d<distance and route_edge_clear(point,candidate):best=id;distance=d
 return best
func route_edge_clear(a:Vector2,b:Vector2)->bool:
 var count=maxi(1,int(ceil(a.distance_to(b)/6.0)))
 for i in range(count+1):
  if not is_npc_walkable(a.lerp(b,float(i)/count)):return false
 return true
func settle_on_road(npc)->void:npc.position=safe_npc_point(npc.position)

func tick(delta: float, minute: float, rainy: bool = false) -> void:
    update_schedules(minute)
    update_supporting_routes(minute)
    for npc in npcs:
        if not npc.visible: continue
        if not is_npc_walkable(npc.position): settle_on_road(npc)
        npc.tick(delta)
        npc.z_index = clampi(int(npc.position.y / 10), 1, 179)
    for i in range(npcs.size()):
        for j in range(i + 1, npcs.size()):
            var first = npcs[i]
            var second = npcs[j]
            if not first.visible or not second.visible: continue
            var difference: Vector2 = first.position - second.position
            var distance := difference.length()
            if distance >= 55: continue
            if distance < 0.1: difference = Vector2(1, 0)
            var push := difference.normalized() * minf(20 * delta, (55 - distance) * 0.5)
            if not first.paused and is_walkable(first.position + push): first.position += push
            if not second.paused and is_walkable(second.position - push): second.position -= push

func is_walkable(point:Vector2)->bool:
 for offset in [Vector2.ZERO,Vector2(13,0),Vector2(-13,0),Vector2(0,13),Vector2(0,-13)]:
  var p=G.unproject(point+offset)
  if not G.WORLD.has_point(p):return false
  for b in data.buildings:
   if Rect2(b[1],b[2],b[3],b[4]).has_point(p):return false
  if G.rect(data.fountain).has_point(p):return false
 return true

func nearest_npc(point: Vector2) -> Node2D:
    var result: Node2D
    var distance := 120.0
    for npc in get_children():
        if not npc.get_script() == NpcScript or not npc.visible: continue
        var candidate := point.distance_to(npc.position)
        if candidate < distance:
            distance = candidate
            result = npc
    return result

func nearest_service(point: Vector2) -> String:
    var result=""
    var distance=110.0
    for building in BUILDINGS:
        var candidate=point.distance_to(building.door*ART_SCALE)
        if candidate<distance:
            distance=candidate
            result=building.name
    return result

func _draw()->void:
 if festival_decorated:
  for i in range(7):draw_circle(G.project(Vector2(650+i*45,590)),6,Color("efae70"))
func update_label_visibility(point:Vector2)->void:visuals.follow_player(point)

func add_ambient_life() -> void:
    var names := ["Ren", "Chanel", "David", "Renji", "Midori"]
    for i in range(5):
        var npc := NpcScript.new()
        add_child(npc)
        npc.setup(names[i], preload("res://CharacterArt.gd").walk(names[i]))
        npc.first_name = names[i]
        npc.label.text = names[i]
        npc.position = safe_npc_point(G.project(Vector2(850+i*90,900)))
        npc.scale=Vector2.ONE*.35
        npc.speed = 65 + i * 4
        visitors.append(npc)
    for i in range(5):
        var pet := preload("res://AmbientPet.gd").new()
        pet.kind = "shiba" if i == 4 else ("dog" if i < 2 else "cat")
        pet.artwork = "res://assets/%s-walk-rest-v1.png" % ["tan-dog", "cream-dog", "gray-cat", "orange-cat", "shiba"][i]
        add_child(pet)
        pet.coat = [Color("c49b70"), Color("ede0ca"), Color("777f87"), Color("ce9161"), Color("d5a064")][i]
        pet.position = safe_npc_point(G.project(Vector2(850+i*70,900)))
        pet.scale=Vector2.ONE*.45
        pet.route = walk_route(pet.position, [Vector2(1200, 910 + i*60), Vector2(1400, 674.074), Vector2(1200, 925.926)])
        pets.append(pet)

func tick_ambient(delta: float, minute: float, rainy: bool, rooms: Dictionary = {}, regions: Dictionary = {}) -> void:
    var period := (0 if minute < 720 else (1 if minute < 1080 else (2 if minute<1260 else 3))) + (4 if rainy else 0)
    if period != ambient_period:
        ambient_period = period
        for i in range(visitors.size()):
            var npc = visitors[i]
            var destination = self
            var point := Vector2(1200, 674.074)
            if not rooms.is_empty() and not regions.is_empty():
                match npc.first_name:
                    "Chanel": destination = rooms["Onsen Resort"]; point = Vector2(530, 288.889)
                    "Ren":
                        destination = rooms["Onsen Resort"] if minute >= 720 or rainy else regions.mountain
                        point = Vector2(690, 377.778) if destination == rooms["Onsen Resort"] else Vector2(530, 432.593)
                    "Renji": destination = rooms["Ranch"]; point = Vector2(690,370)
                    "David":
                        destination = regions.harbor if minute < 720 and not rainy else rooms["General Store"]
                        point = Vector2(1020, 444.444) if destination == regions.harbor else Vector2(730, 444.444)
                    "Midori": destination = rooms["Veterinarian"]; point = Vector2(690,370)
                if minute >= 1260: destination = rooms["Inn"]; point = Vector2(450+(i%3)*110,510+(i/3)*90)
            else: point = Vector2(1200,520+i*260)
            if npc.get_parent() != destination: npc.reparent(destination,false)
            npc.position = destination.safe_npc_point(point) if destination.has_method("safe_npc_point") else destination.safe_point(point) if destination.has_method("safe_point") else point
            npc.scale=Vector2.ONE*(.35 if destination==self else 1.0)
            npc.set_route([])
            npc.show_frame(0,1)
        for i in range(pets.size()):
            var pet = pets[i]
            if not regions.is_empty() and i >= 2:
                var area = regions[["historic", "harbor", "tea"][i-2]]
                if pet.get_parent() != area:
                    pet.reparent(area)
                    pet.position = area.safe_point(Vector2(620+(i-2)*170,600))
                pet.scale=Vector2.ONE
                pet.route = [pet.position, pet.position + Vector2(0, 25.9259)]
                if rainy: pet.route = [area.safe_point(Vector2(640+(i-2)*160,430))]
                pet.index = 0
                continue
            var shelter := G.project(Vector2(990+i*600,1450))
            pet.position = G.project(Vector2(850+i*700,900))
            pet.scale=Vector2.ONE*.45
            settle_on_road(pet)
            pet.route = walk_route(pet.position,[shelter] if rainy else [pet.position+Vector2(35, 0)])
            pet.index = 0
    for npc in visitors:
        npc.tick(delta)
        npc.z_index = clampi(int(npc.position.y / 10), 1, 215)
    for pet in pets:
        pet.tick(delta)
        pet.z_index = clampi(int(pet.position.y / 10), 1, 215)
    greeting_time -= delta
    if greeting_time <= 0:
        greeting_time = 12.0
        for i in range(visitors.size()):
            var npc = visitors[i]
            npc.label.text = npc.first_name
            for other in visitors:
                if other != npc and other.get_parent() == npc.get_parent() and npc.position.distance_to(other.position) < 120:
                    npc.label.text = "Hello, " + other.first_name + "!"
                    npc.face_player(other.global_position)
                    break
    elif greeting_time < 9:
        for npc in visitors: npc.label.text = npc.first_name

func is_npc_walkable(point:Vector2)->bool:
 if not is_walkable(point):return false
 for b in BUILDINGS:
  if point.distance_to(b.door)<65:return false
 return true
static func design(point:Vector2)->Vector2:
 # Legacy story destinations resolve to the new festival plaza or farm arrival.
 if point.y>1600:return G.project(Vector2(1300,1480))
 if point==Vector2(1350,730):return G.project(Vector2(930,750))
 return G.project(Vector2(820,800))

func panel(color: Color) -> StyleBoxFlat:
    var style:=StyleBoxFlat.new()
    style.bg_color=color
    style.border_color=Color("785437")
    style.set_border_width_all(3)
    style.set_corner_radius_all(5)
    return style

func street_routes()->Array:
 var result=[]
 for pair in [[Vector2(1300,365),Vector2(1300,1480)],[Vector2(260,970),Vector2(1870,970)],[Vector2(950,700),Vector2(1870,700)],[Vector2(950,1250),Vector2(1870,1250)],[Vector2(970,700),Vector2(970,1250)],[Vector2(1630,700),Vector2(1630,1510)]]:
  result.append([G.project(pair[0]),G.project(pair[1])])
 return result
