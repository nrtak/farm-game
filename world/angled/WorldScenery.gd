extends Node2D
# Ground uses logical map coordinates; upright props cancel only the ground projection.
const B = Transform2D(Vector2(.62,-.23),Vector2(.42,.35),Vector2.ZERO)
const Layout = preload("res://ApprovedMapLayout.gd")
const Roads = preload("res://WideRoads.gd")
var farm
var host
var kind: String
var landmarks: Texture2D
var furniture: Texture2D
var grass_texture: Texture2D
var props: Array = []
var built_level := -1
func _ready():
	z_index=-1000
	landmarks=load("res://world/angled/landmarks.png")
	furniture=load("res://world/angled/furniture.png")
	grass_texture=load("res://world/town/grass.png")
	texture_repeat=CanvasItem.TEXTURE_REPEAT_ENABLED
	if kind not in ["home","room"]:
		var seasonal=ShaderMaterial.new();seasonal.shader=load("res://SeasonScenery.gdshader");material=seasonal
		farm.season_scenery.materials.append(seasonal);seasonal.set_shader_parameter("season",float(int((farm.day-1)/28)%4))
	build_props()
func active() -> bool:
	if kind=="home": return farm.inside_house
	if kind=="room": return farm.location=="shop" and host==farm.shops.get(farm.shop_name)
	return farm.location==kind and not farm.inside_house
func prop(texture: Texture2D, index: int, rows: int, foot: Vector2, width: float, caption: String=""):
	var s=Sprite2D.new();s.texture=texture;s.region_enabled=true
	s.region_filter_clip_enabled=true
	s.use_parent_material=true
	var cell=Vector2(texture.get_width()/4.0,texture.get_height()/float(rows))
	var start=Vector2(index%4,int(index/4))*cell
	if rows==3:
		var starts=[0.0,350.0,690.0,1086.0]
		start.y=starts[int(index/4)];cell.y=starts[int(index/4)+1]-start.y
	s.region_rect=Rect2(start+Vector2(4,4),cell-Vector2(8,8))
	s.centered=false
	var ratio=width/cell.x
	s.transform=B.affine_inverse()*Transform2D(0,Vector2.ONE*ratio,0,B*foot-Vector2(width*.5,cell.y*ratio*.91))
	s.z_as_relative=false;s.z_index=clampi(int((B*foot).y)+1000,1,4000)
	add_child(s);props.append(s)
	if not caption.is_empty():
		var sign=Label.new();sign.text=caption;sign.position=cell*Vector2(.20,.74)
		sign.add_theme_font_size_override("font_size",14)
		sign.add_theme_color_override("font_color",Color("49372b"))
		var wood=StyleBoxFlat.new();wood.bg_color=Color("eedbb0");wood.border_color=Color("775234");wood.set_border_width_all(3)
		wood.content_margin_left=5;wood.content_margin_right=5;sign.add_theme_stylebox_override("normal",wood);s.add_child(sign)
	return s
func refresh_props():
	if kind=="home" and built_level!=host.home_level:
		for p in props:p.queue_free()
		props.clear();build_props()
	var foot:Vector2=B*(farm.player.position-position)
	for i in range(props.size()):
		var s:Sprite2D=props[i]
		var t:Transform2D=B*s.transform
		var bounds=Rect2(t.origin,s.region_rect.size*t.x.length())
		s.modulate.a=.28 if not farm.sleep_in_progress and s.z_index>farm.player.z_index and bounds.intersects(Rect2(foot-Vector2(18,62),Vector2(36,62))) else 1.0
		if kind=="room" and host.kind=="Mine" and i<host.depleted.size():s.visible=not host.depleted[i]
func build_props():
	if kind=="farm":
		prop(landmarks,0,3,Vector2(775,530),410,"Home")
		prop(landmarks,1,3,Vector2(2420,415),300,"Barn")
		for i in range(1,farm.SOLID_OUTLINES.size()):
			if i in [6,7,8]:continue
			var poly:PackedVector2Array=farm.world_outline(farm.SOLID_OUTLINES[i])
			for y in range(65,2000,125):
				for x in range(65,3000,130):
					if Geometry2D.is_point_in_polygon(Vector2(x,y),poly):prop(landmarks,11,3,Vector2(x,y),120)
	elif kind in ["tea","harbor","mountain","historic"]:
		var indices={"Tea Farmhouse":3,"Tea Processing Shed":2,"Fishing Shop":4,"Harbor Homes":5,"Onsen Resort":6,"Mountain Lodge":7,"Mountain Carpentry":7,"Mine":9,"Shrine Residence":8}
		for title in Layout.doors(kind):
			prop(landmarks,indices[title],3,Layout.doors(kind)[title]-Vector2(0,18),210 if kind=="harbor" else (245 if kind=="historic" else 190),title.replace(" Residence","").replace("Mountain ",""))
		for rect: Rect2 in Layout.scenery(kind):
			for x in range(int(rect.position.x)+20,int(rect.end.x),100):
				for y in range(int(rect.position.y)+20,int(rect.end.y),110):
					prop(landmarks,11,3,Vector2(x,y),95)
		# Secondary sheds are solid too: give every blocked footprint a visible structure.
		var doors=Layout.doors(kind).values()
		var all_buildings=Layout.buildings(kind)
		for i in range(doors.size(),all_buildings.size()):
			var r:Rect2=all_buildings[i];prop(landmarks,5 if kind=="harbor" else 2,3,Vector2(r.get_center().x,r.end.y),120)
		if kind=="historic":
			for y in range(90,1200,145):
				for x in range(90,1600,145):
					var point=Vector2(x,y)
					if x<210:continue
					if Geometry2D.is_point_in_polygon(point,host.walk_outline):continue
					var beside_path=false
					for i in range(host.walk_outline.size()):
						if point.distance_to(Geometry2D.get_closest_point_to_segment(point,host.walk_outline[i],host.walk_outline[(i+1)%host.walk_outline.size()]))<65:beside_path=true
					if not beside_path and not Rect2(210,0,410,410).has_point(point):prop(landmarks,11,3,point,130)
	elif kind=="waterfall":
		prop(landmarks,10,3,Vector2(800,485),410)
		for y in range(200,1300,140):
			for x in [-120,30,170,1400,1550,1710]:prop(landmarks,11,3,Vector2(x,y),130)
	elif kind=="road":
		for y in range(150,850,150):
			for x in [150,850]:prop(landmarks,11,3,Vector2(x,y),120)
	elif kind in ["home","room"]:
		var solid_list: Array=[]
		var choices: Array=[]
		if kind=="home":
			solid_list.assign(host.SOLIDS);solid_list.append_array(preload("res://HomeExpansion.gd").solids(host.home_level))
			choices=[0,3,2,4,1];built_level=host.home_level
		else:
			solid_list.assign(host.solids)
			choices={"General Store":[2,5,5,1],"Blacksmith":[6,7,6],"Carpentry":[6,6,1],"Mountain Carpentry":[6,6,1],"Clinic":[9,8,8],"Veterinarian":[8,1,9],"Ranch":[12,12,2],"Barn":[12],"Mine":[14],"Archive":[1],"Shrine Residence":[13,1,3],"Tea Processing Shed":[11],"Tea Farmhouse":[11,3,1],"Café":[2,3,4],"Restaurant":[3,3,4],"Police Box":[9,1],"Fire Station":[10,9],"Town Hall":[9,1],"Greenhouse":[5,15],"Upper Floor":[0,1,3]}.get(host.kind,[2,0,3,1])
		for i in range(solid_list.size()):
			if kind=="home" and i in [2,3]:continue
			var r: Rect2=solid_list[i]
			var foot=Vector2(r.get_center().x,r.end.y)
			var width=clampf((r.size.x*.62+r.size.y*.42),70,220)
			prop(furniture,choices[i%choices.size()],4,foot,width)
func road(a: Vector2,b: Vector2,width: float=115):
	draw_line(a,b,Color("ddc995"),width,true)
	draw_circle(a,width*.5,Color("ddc995"));draw_circle(b,width*.5,Color("ddc995"))
	for i in range(1,int(a.distance_to(b)/45)):
		var p=a.move_toward(b,i*45)
		draw_circle(p+Vector2(sin(i*3.1)*width*.3,cos(i*2.7)*width*.2),2,Color("c3af7d"))
func water(poly: PackedVector2Array):
	if poly.size()<3:return
	draw_colored_polygon(poly,Color("70b4bf"))
	var edge=poly.duplicate();edge.append(poly[0]);draw_polyline(edge,Color("c4ded1"),9,true)
	for y in range(30,1200,57):
		for x in range(20,1600,90):
			var p=Vector2(x+sin(y)*20,y)
			if Geometry2D.is_point_in_polygon(p,poly):draw_line(p,p+Vector2(27,0),Color(0.8,.95,.94,.28),2,true)
func draw_sign(p:Vector2,text:String):
	draw_set_transform_matrix(B.affine_inverse()*Transform2D(0,B*p))
	var width=ThemeDB.fallback_font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,14).x+16
	draw_line(Vector2(0,5),Vector2(0,-24),Color("795d40"),5)
	draw_rect(Rect2(-width/2,-44,width,25),Color("ecdbb6"));draw_rect(Rect2(-width/2,-44,width,25),Color("795d40"),false,2)
	draw_string(ThemeDB.fallback_font,Vector2(-width/2+8,-26),text,HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("493b2d"))
	draw_set_transform_matrix(Transform2D.IDENTITY)
func fishing_float() -> Vector2:
	# Cast beside the dock, not onto the next fishing mark on its planks.
	for candidate in [Vector2(host.pier_area.end.x+70,host.fishing_spot.y),Vector2(host.pier_area.position.x-70,host.fishing_spot.y),Vector2(host.fishing_spot.x,host.pier_area.end.y+70)]:
		if not host.pier_area.grow(20).has_point(candidate) and not Geometry2D.is_point_in_polygon(candidate,host.land_outline):return candidate
	return Vector2(host.pier_area.end.x+70,host.pier_area.end.y+70)
func _draw():
	if not active():return
	if kind in ["home","room"]:
		draw_room();return
	var size=Vector2(3000,2000) if kind=="farm" else Vector2(1600,1200)
	if kind=="road":size=Vector2(1000,1000)
	var grass=Color("8eae62")
	draw_rect(Rect2(Vector2.ZERO,size).grow(1200),grass)
	draw_rect(Rect2(Vector2.ZERO,size),grass)
	draw_texture_rect(grass_texture,Rect2(Vector2.ZERO,size).grow(1200),true,Color(.95,.98,.90,.58))
	for y in range(15,int(size.y),48):
		for x in range(15,int(size.x),53):
			var p=Vector2(x+sin(y+x)*14,y+cos(x)*10)
			draw_line(p,p+Vector2(3,-6),Color(.34,.49,.25,.23),2)
	if kind=="harbor":
		draw_rect(Rect2(Vector2.ZERO,size).grow(1200),Color("70b4bf"))
		draw_colored_polygon(host.land_outline,Color("dfd1a2"))
		var coast:PackedVector2Array=host.land_outline.duplicate();coast.append(coast[0]);draw_polyline(coast,Color("d1e9da"),10,true)
	elif kind=="tea":water(host.pond_outline)
	elif kind=="mountain":
		for poly in host.water_polygons:water(poly)
	elif kind=="historic":
		for poly in host.water_polygons:water(poly)
		draw_texture_rect(grass_texture,Rect2(Vector2.ZERO,size).grow(900),true)
		for poly in host.water_polygons:water(poly)
		# The walkable clearing is grass, with clear stone approaches rather than a polygon slab.
		for p in [Vector2(245,310),Vector2(580,310)]:
			draw_set_transform_matrix(B.affine_inverse()*Transform2D(0,B*p))
			draw_rect(Rect2(-13,-10,26,12),Color("899182"))
			draw_rect(Rect2(-6,-45,12,35),Color("a6ad9b"))
			draw_rect(Rect2(-15,-65,30,24),Color("b4b6a3"))
			draw_rect(Rect2(-8,-59,16,13),Color("eed39a"))
			draw_line(Vector2(-21,-68),Vector2(21,-68),Color("646e62"),7)
			draw_set_transform_matrix(Transform2D.IDENTITY)
		draw_set_transform_matrix(B.affine_inverse()*Transform2D(0,B*Vector2(1450,1080)))
		for x in [-68,68]:draw_line(Vector2(x,0),Vector2(x,-120),Color("a64030"),12)
		draw_line(Vector2(-95,-124),Vector2(95,-124),Color("384f48"),14)
		draw_line(Vector2(-84,-94),Vector2(84,-94),Color("b54c38"),10)
		draw_set_transform_matrix(Transform2D.IDENTITY)
	elif kind=="waterfall":
		draw_texture_rect(grass_texture,Rect2(Vector2.ZERO,size).grow(900),true)
		water(PackedVector2Array([Vector2(260,270),Vector2(1320,270),Vector2(1320,530),Vector2(260,530)]))
		draw_colored_polygon(PackedVector2Array(host.GROUND),Color(.6,.72,.4,.25))
		for i in range(90):
			var p=Vector2(350+posmod(i*137,900),600+posmod(i*71,500))
			if absf(p.x-800)>145:
				draw_circle(p,6,Color("779646"));draw_circle(p+Vector2(0,-4),2,Color("eadfb2"))
		road(Vector2(800,1240),Vector2(800,580),230)
	elif kind=="road":road(Vector2(500,40),Vector2(500,960),250)
	for route in Roads.ROUTES.get(kind,[]):road(route[0],route[1],180)
	for door: Vector2 in Layout.doors(kind).values():
		var best=door+Vector2(0,120);var distance=INF
		for route in Roads.ROUTES.get(kind,[]):
			var p=Geometry2D.get_closest_point_to_segment(door,route[0],route[1])
			if p.distance_to(door)<distance:best=p;distance=p.distance_to(door)
		road(door,best,95)
	if kind in ["harbor","tea"] and host.pier_area.has_area():
		draw_rect(host.pier_area,Color("94734b"))
		for y in range(int(host.pier_area.position.y),int(host.pier_area.end.y),18):draw_line(Vector2(host.pier_area.position.x,y),Vector2(host.pier_area.end.x,y),Color("c3a278"),3)
	if kind=="harbor":
		for spot in farm.FISHING_SPOTS:draw_circle(spot,22,Color("c7af7d"),false,3)
		if host.fishing_state>0:
			var bob:Vector2=fishing_float()
			draw_line(host.fishing_spot,bob,Color("f1ead2"),2)
			draw_circle(bob,8,Color("cf6d53") if host.fishing_state==1 else Color("ffe18c"))
			if host.fishing_state==2:draw_circle(bob,20,Color("ffe18c"),false,4)
	if kind=="tea":
		for x in [850,990,1130,1320,1460]:
			for y in range(800,1070,75):
				draw_rect(Rect2(x-30,y-22,60,44),Color("958258"))
				for dx in [-17,0,17]:
					draw_circle(Vector2(x+dx,y),18,Color("50783c"));draw_circle(Vector2(x+dx-3,y-6),11,Color("70944c"))
		for i in range(farm.TEA_SPOTS.size()):
			var spot:Vector2=farm.TEA_SPOTS[i]
			draw_circle(spot,26,Color("998358"))
			for dx in [-10,10]:draw_circle(spot+Vector2(dx,-4),12,Color("79985a") if farm.tea_picked_days[i]<farm.day else Color("5b7549"))
	if kind=="farm":
		road(Vector2(1485,140),Vector2(1485,530),140)
		road(Vector2(775,550),Vector2(1485,550),140)
		road(Vector2(775,550),Vector2(850,1430),130)
		water(farm.world_outline(farm.SOLID_OUTLINES[8]))
		# The well occupies the existing blocked footprint beside its interaction point.
		var p=Vector2(530,915)
		draw_set_transform_matrix(B.affine_inverse()*Transform2D(0,B*p))
		draw_circle(Vector2.ZERO,35,Color("827f6e"));draw_circle(Vector2(0,-10),29,Color("b9b7a0"));draw_circle(Vector2(0,-13),21,Color("496a70"))
		for x in [-29,29]:draw_line(Vector2(x,0),Vector2(x,-75),Color("816343"),7)
		draw_colored_polygon(PackedVector2Array([Vector2(-48,-68),Vector2(0,-95),Vector2(48,-68)]),Color("867453"))
		draw_set_transform_matrix(Transform2D.IDENTITY)
		for plot in farm.plots:draw_rect(Rect2(plot.position-Vector2(34,34),Vector2(68,68)),Color("a78657"))
	var signs={"farm":[Vector2(1550,240),"Town"],"harbor":[Vector2(1450,580),"Town · East"],"tea":[Vector2(160,600),"Highlands · West"],"historic":[Vector2(1390,1040),"Town"],"mountain":[Vector2(900,1040),"Town · South"],"waterfall":[Vector2(900,1090),"Mountain trail"]}
	if kind=="mountain":
		draw_sign(Vector2(1080,1030),"Tea Country")
		draw_sign(Vector2(1440,710),"Waterfall")
	if signs.has(kind):draw_sign(signs[kind][0],signs[kind][1])
func draw_room():
	var floor_rect:Rect2=host.FLOOR if kind=="home" else Rect2(110,170,880,620)
	var name:String="Home" if kind=="home" else host.kind
	var colors={"Clinic":"c0d8cc","Veterinarian":"c2d5da","Police Box":"b9c7d0","Fire Station":"d9c2af","Shrine Residence":"c7c398","Archive":"c8b5a0","Tea Farmhouse":"c5d0a3","Tea Processing Shed":"bdc99b","Mine":"817e78","Greenhouse":"b2c4a0","Restaurant":"d2b19b"}
	draw_rect(Rect2(-500,-500,3000,2200),Color("344b46"))
	draw_rect(floor_rect,Color(colors.get(name,"c6ad89")))
	for y in range(int(floor_rect.position.y),int(floor_rect.end.y),42):draw_line(Vector2(floor_rect.position.x,y),Vector2(floor_rect.end.x,y),Color(0.3,.25,.20,.16),2)
	for x in range(int(floor_rect.position.x),int(floor_rect.end.x),105):draw_line(Vector2(x,floor_rect.position.y),Vector2(x,floor_rect.end.y),Color(0.3,.25,.20,.10),1)
	var rise=B.affine_inverse()*Vector2(0,-100)
	var a=floor_rect.position;var b=Vector2(floor_rect.end.x,a.y);var c=Vector2(a.x,floor_rect.end.y)
	draw_colored_polygon(PackedVector2Array([a,b,b+rise,a+rise]),Color("dfd4b9"))
	draw_colored_polygon(PackedVector2Array([a,c,c+rise,a+rise]),Color("b9b899"))
	draw_polyline(PackedVector2Array([c+rise,a+rise,b+rise]),Color("6c614f"),8,true)
	var exit_point:Vector2=host.EXIT if kind=="home" else Vector2(550,780)
	draw_rect(Rect2(exit_point-Vector2(65,40),Vector2(130,40)),Color("809784"))
	if name=="Greenhouse":
		for bed in preload("res://FarmBuildings.gd").greenhouse(farm):
			var p=Vector2(bed.position[0],bed.position[1]);draw_rect(Rect2(p-Vector2(43,36),Vector2(86,72)),Color("93704a"))
			if bed.stage>0:
				draw_circle(p,16,Color("6e9951"))
				if bed.stage==3:draw_circle(p,10,Color(farm.CROPS[bed.crop].color))
	if kind=="home":
		draw_set_transform_matrix(B.affine_inverse()*Transform2D(0,B*Vector2(185,280)))
		draw_rect(Rect2(-45,-65,90,60),Color("725640"));draw_rect(Rect2(-38,-59,65,45),Color("607f83"))
		draw_circle(Vector2(-18,-43),10,Color("efd078"));draw_line(Vector2(-42,-5),Vector2(-45,8),Color("493e34"),5)
		draw_line(Vector2(42,-5),Vector2(45,8),Color("493e34"),5)
		draw_set_transform_matrix(Transform2D.IDENTITY)
		var chest:Rect2=host.CHEST
		var up=B.affine_inverse()*Vector2(0,-28)
		var corners=PackedVector2Array([chest.position,Vector2(chest.end.x,chest.position.y),chest.end,Vector2(chest.position.x,chest.end.y)])
		draw_colored_polygon(corners,Color("87623e"))
		var lid=PackedVector2Array()
		for p in corners:lid.append(p+up)
		draw_colored_polygon(lid,Color("b28c59"));lid.append(lid[0]);draw_polyline(lid,Color("755335"),3,true)
		for x in [chest.position.x+26,chest.end.x-26]:draw_line(Vector2(x,chest.position.y)+up,Vector2(x,chest.end.y)+up,Color("6f725f"),7)
		for level in range(host.home_level):
			var x=910+level*220
			for wall in [Rect2(x,230,10,300),Rect2(x,630,10,90)]:draw_rect(wall,Color("816c50"))
		# Keep calendar and upstairs entrance legible beside their original interaction points.
		draw_set_transform_matrix(B.affine_inverse()*Transform2D(0,B*Vector2(570,250)))
		draw_rect(Rect2(-16,-47,32,38),Color("f4e7c7"));draw_rect(Rect2(-16,-47,32,8),Color("b46d52"))
		for y in [-30,-22,-14]:
			for x in [-9,0,9]:draw_circle(Vector2(x,y),1.5,Color("716a53"))
		draw_set_transform_matrix(Transform2D.IDENTITY)
		if farm.interior_progress.get("second_story",false):
			for i in range(6):draw_rect(Rect2(555,540+i*12,110,10),Color("97744f"))
	if name=="Barn":
		farm.BarnLife.prepare_art()
		if not preload("res://AnimalPasture.gd").outside(farm):
			var animals:Array=farm.BarnLife.state(farm).animals
			for i in range(animals.size()):
				var p:Vector2=farm.BarnLife.animal_point(i)
				var r:Rect2=farm.BarnLife.art_regions[farm.BarnLife.SPECIES.keys().find(animals[i].species)]
				var size=r.size*(65.0/r.size.y)
				draw_set_transform_matrix(B.affine_inverse()*Transform2D(0,B*p))
				draw_texture_rect_region(farm.BarnLife.art,Rect2(Vector2(-size.x*.5,-size.y),size),r)
				draw_set_transform_matrix(Transform2D.IDENTITY)
	if name=="Mine":
		for y in range(220,730,36):draw_line(Vector2(510,y),Vector2(590,y),Color("715d45"),7)
		for x in [520,580]:draw_line(Vector2(x,210),Vector2(x,740),Color("aeb5b1"),4)
	if kind=="room" and host.lost_item_visible:
		draw_rect(Rect2(host.WALLET-Vector2(10,6),Vector2(20,12)),Color("836047"))
