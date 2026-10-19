extends Node2D
# Ground uses logical map coordinates; upright props cancel only the ground projection.
const B = Transform2D(Vector2(.558,-.207),Vector2(.378,.315),Vector2.ZERO)
const Layout = preload("res://ApprovedMapLayout.gd")
const Roads = preload("res://WideRoads.gd")
var farm
var host
var kind: String
var landmarks: Texture2D
var furniture: Texture2D
var farm_props: Texture2D
var grass_texture: Texture2D
var props: Array = []
var built_level := -1
var road_polygons:Array=[]
var merged_roads:Array=[]
func _ready():
	z_index=-1000
	landmarks=load("res://world/angled/landmarks.png")
	furniture=load("res://world/angled/furniture.png")
	grass_texture=load("res://world/town/grass.png")
	texture_repeat=CanvasItem.TEXTURE_REPEAT_ENABLED
	if kind not in ["home","room"]:
		var seasonal=ShaderMaterial.new();seasonal.shader=load("res://SeasonScenery.gdshader");material=seasonal
		farm.season_scenery.materials.append(seasonal);seasonal.set_shader_parameter("season",float(int((farm.day-1)/28)%4))
	farm_props=load("res://world/angled/farm-props-v2.png")
	build_props()
	build_yards()
	build_horizon()
func active() -> bool:
	if kind=="home": return farm.inside_house
	if kind=="room": return farm.location=="shop" and host==farm.shops.get(farm.shop_name)
	if preload("res://OutdoorContinuity.gd").connected(farm.location,kind):return not farm.inside_house
	return farm.location==kind and not farm.inside_house
func prop(texture: Texture2D, index: int, rows: int, foot: Vector2, width: float, caption: String=""):
	if texture==landmarks and index==11 and not tree_clear(foot):return null
	var s=Sprite2D.new();s.texture=texture;s.region_enabled=true
	s.region_filter_clip_enabled=true
	s.use_parent_material=true
	var cell=Vector2(texture.get_width()/4.0,texture.get_height()/float(rows))
	var start=Vector2(index%4,int(index/4))*cell
	if texture==furniture:
		# This hand-painted atlas is not an exact grid; isolate each prop's real bounds.
		var regions=[Rect2(0,0,335,320),Rect2(360,0,245,322),Rect2(635,50,340,265),Rect2(990,45,310,270),Rect2(0,315,310,300),Rect2(330,320,320,290),Rect2(655,325,325,295),Rect2(1000,310,300,310),Rect2(0,620,325,265),Rect2(335,635,335,245),Rect2(680,610,280,300),Rect2(975,620,325,280),Rect2(0,885,375,305),Rect2(405,890,265,300),Rect2(670,895,350,295),Rect2(1020,900,280,290)]
		start=regions[index].position;cell=regions[index].size
	if rows==3:
		var starts=[0.0,350.0,690.0,1086.0]
		start.y=starts[int(index/4)];cell.y=starts[int(index/4)+1]-start.y
	s.region_rect=Rect2(start+Vector2(4,4),cell-Vector2(8,8))
	s.centered=false
	var ratio=width/cell.x
	s.transform=B.affine_inverse()*Transform2D(0,Vector2.ONE*ratio,0,B*foot-Vector2(width*.5,cell.y*ratio*.91))
	var depth_foot=foot if kind in ["home","room"] else foot+position
	s.z_as_relative=false;s.z_index=clampi(int((B*depth_foot).y*.1)+1000,1,4000)
	add_child(s);props.append(s)
	if not caption.is_empty():
		var sign=Label.new();sign.text=caption;sign.position=cell*Vector2(.20,.74)
		sign.add_theme_font_size_override("font_size",14)
		sign.add_theme_color_override("font_color",Color("49372b"))
		var wood=StyleBoxFlat.new();wood.bg_color=Color("eedbb0");wood.border_color=Color("775234");wood.set_border_width_all(3)
		wood.content_margin_left=5;wood.content_margin_right=5;sign.add_theme_stylebox_override("normal",wood);s.add_child(sign)
	return s
func tree_clear(foot:Vector2)->bool:
	if kind=="farm" and foot.y<300:return false
	if kind=="mountain" and foot.distance_to(Vector2(1600,900))<260:return false
	if kind=="tea" and foot.distance_to(Vector2(0,675))<240:return false
	var world=foot+position
	var g=preload("res://world/town/TownDisplayGeometry.gd")
	if kind=="farm" and g.WORLD.grow(90).has_point(g.unproject(world-farm.TOWN_ORIGIN)):return false
	for region in ["mountain","tea","historic"]:
		var local=world-farm.REGION_ORIGINS[region]
		var spec=Layout.spec(region)
		var water_shapes=spec.get("water_polygons",[]).duplicate()
		if spec.has("pond"):water_shapes.append(spec.pond)
		for points in water_shapes:
			var polygon=PackedVector2Array()
			for p in points:polygon.append(Vector2(p[0],p[1]))
			if Geometry2D.is_point_in_polygon(local,polygon):return false
			for i in range(polygon.size()):
				if local.distance_to(Geometry2D.get_closest_point_to_segment(local,polygon[i],polygon[(i+1)%polygon.size()]))<70:return false
	for route in Roads.ROUTES.get(kind,[]):
		if foot.distance_to(Geometry2D.get_closest_point_to_segment(foot,route[0],route[1]))<135:return false
	return true
func farm_prop(index:int,foot:Vector2,width:float):
	var regions=[Rect2(0,0,625,630),Rect2(625,0,629,690),Rect2(0,635,625,619),Rect2(625,700,629,554)]
	var region:Rect2=regions[index]
	var sprite=Sprite2D.new();sprite.texture=farm_props;sprite.region_enabled=true;sprite.region_filter_clip_enabled=true;sprite.region_rect=region;sprite.centered=false
	var ratio=width/region.size.x
	sprite.transform=B.affine_inverse()*Transform2D(0,Vector2.ONE*ratio,0,B*foot-Vector2(width*.5,region.size.y*ratio*.96))
	sprite.z_as_relative=false;sprite.z_index=clampi(int((B*(foot if kind in ["home","room"] else foot+position)).y*.1)+1000,1,4000)
	add_child(sprite);props.append(sprite)
	return sprite
func refresh_props():
	if kind=="home" and built_level!=host.home_level:
		for p in props:p.queue_free()
		props.clear();build_props()
	var foot:Vector2=B*(farm.player.position-position)
	for i in range(props.size()):
		var s:Sprite2D=props[i]
		var t:Transform2D=B*s.transform
		var bounds=Rect2(t.origin,s.region_rect.size*t.x.length())
		s.modulate.a=.28 if not farm.sleep_in_progress and s.z_index>=farm.player.z_index and bounds.intersects(Rect2(foot-Vector2(18,62),Vector2(36,62))) else 1.0
		if kind=="room" and host.kind=="Mine" and i<host.depleted.size():s.visible=not host.depleted[i]
		if s.has_meta("tea_index"):
			var picked:bool=farm.tea_picked_days[s.get_meta("tea_index")]>=farm.day
			s.self_modulate=Color("91a878") if picked else Color.WHITE
func home_prop(index:int,foot:Vector2,width:float):
	var texture=load("res://world/angled/home-furnishings-v3.png")
	var regions=[Rect2(0,0,512,490),Rect2(512,0,520,490),Rect2(1045,0,491,490),Rect2(0,490,500,534),Rect2(535,530,490,450)]
	var region:Rect2=regions[index]
	var sprite=Sprite2D.new();sprite.texture=texture;sprite.region_enabled=true;sprite.region_filter_clip_enabled=true;sprite.region_rect=region;sprite.centered=false
	var ratio=width/region.size.x
	sprite.transform=B.affine_inverse()*Transform2D(0,Vector2.ONE*ratio,0,B*foot-Vector2(width*.5,region.size.y*ratio*.94))
	sprite.z_as_relative=false;sprite.z_index=clampi(int((B*(foot if kind in ["home","room"] else foot+position)).y*.1)+1000,1,4000)
	add_child(sprite);props.append(sprite)
func build_props():
	if kind=="farm":
		var ranch_sign=preload("res://world/angled/RanchSign.gd").new()
		var sign_foot=Vector2(1485,240)
		ranch_sign.transform=B.affine_inverse()*Transform2D(0,Vector2.ONE*.85,0,B*sign_foot)
		ranch_sign.z_as_relative=false;ranch_sign.z_index=1000+int((B*sign_foot).y*.1)
		add_child(ranch_sign)
		farm_prop(0,farm.SHIPPING_BOX,105)
		farm_prop(1,preload("res://FarmResources.gd").WELL-Vector2(0,73),90)
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
			var building=prop(landmarks,indices[title],3,Layout.doors(kind)[title]-Vector2(0,18),235 if kind=="harbor" else (260 if kind=="historic" else (300 if kind=="tea" else 215)),title.replace(" Residence","").replace("Mountain ",""))
			if title=="Onsen Resort":building.flip_h=true
		for rect: Rect2 in ([] if kind=="harbor" else Layout.scenery(kind)):
			for x in range(int(rect.position.x)+20,int(rect.end.x),100):
				for y in range(int(rect.position.y)+20,int(rect.end.y),110):
					if kind=="tea":
						var obscures_road=false
						for route in Roads.ROUTES.tea:
							if Vector2(x,y).distance_to(Geometry2D.get_closest_point_to_segment(Vector2(x,y),route[0],route[1]))<160:obscures_road=true
						if obscures_road:continue
					prop(landmarks,11,3,Vector2(x,y),95)
		# Secondary sheds are solid too: give every blocked footprint a visible structure.
		var doors=Layout.doors(kind).values()
		var all_buildings=Layout.buildings(kind)
		for i in range(doors.size(),all_buildings.size()):
			var r:Rect2=all_buildings[i];prop(landmarks,5 if kind=="harbor" else 2,3,Vector2(r.get_center().x,r.end.y),120)
		if kind=="harbor":
			for p in [Vector2(470,180),Vector2(1430,170)]:coastal_prop(3,p,110)
			coastal_prop(4,Vector2(1210,800),115)
			expansion_prop(3,Vector2(120,700),260)
			coastal_prop(6,Vector2(540,800),42)
			coastal_prop(6,Vector2(657,965),42)
			coastal_prop(7,Vector2(1310,445),80)
		if kind=="mountain":
			expansion_prop(2,Vector2(375,600),235)
		if kind=="historic":
			wide_waterfall(Vector2(850,390),355)
			for y in range(90,1200,145):
				for x in range(90,1600,145):
					var point=Vector2(x,y)
					if x<210 or Rect2(400,0,1200,600).has_point(point) or (point.y>900 and absf(point.x-1440)<300):continue
					if Geometry2D.is_point_in_polygon(point,host.walk_outline):continue
					var beside_path=false
					for i in range(host.walk_outline.size()):
						if point.distance_to(Geometry2D.get_closest_point_to_segment(point,host.walk_outline[i],host.walk_outline[(i+1)%host.walk_outline.size()]))<65:beside_path=true
					if not beside_path and not Rect2(1200,0,400,480).has_point(point):prop(landmarks,11,3,point,130)
		if kind=="tea":
			for x in [500,710,920]:
				for y in [360,455,550]:
					var p=Vector2(x,y)
					if not farm.TEA_SPOTS.has(p):farm_prop(3,p,78)
			for i in range(farm.TEA_SPOTS.size()):farm_prop(3,farm.TEA_SPOTS[i],78).set_meta("tea_index",i)
	elif kind=="waterfall":
		wide_waterfall(Vector2(800,455),470)
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
			home_prop(0,Vector2(host.BED.get_center().x,host.BED.end.y),145)
			home_prop(1,Vector2(host.TABLE.get_center().x,host.TABLE.end.y),125)
			home_prop(2,Vector2(570,265),95)
			home_prop(3,Vector2(185,285),75)
			home_prop(4,Vector2(host.CHEST.get_center().x,host.CHEST.end.y),85)
		else:
			solid_list.assign(host.solids)
			choices={"General Store":[2,5,5,1],"Blacksmith":[6,7,6],"Carpentry":[6,6,1],"Mountain Carpentry":[6,6,1],"Clinic":[9,8,8],"Veterinarian":[8,1,9],"Ranch":[12,12,2],"Barn":[12],"Mine":[14],"Archive":[1],"Shrine Residence":[13,1,3],"Tea Processing Shed":[11],"Tea Farmhouse":[11,3,1],"Café":[2,3,4],"Restaurant":[3,3,4],"Police Box":[9,1],"Fire Station":[10,9],"Town Hall":[9,1],"Greenhouse":[5,15],"Upper Floor":[0,1,3],"School":[1,1,9,9,9,9],"Inn":[2,1,0,3,3]}.get(host.kind,[2,0,3,1])
			var specific={"Shrine Residence":[13,13,15,3],"Mountain Lodge":[2,4,0,3],"Tea Farmhouse":[3,11,3,15],"Harbor Homes":[3,0,4,15],"Fishing Shop":[2,6,6,6],"Hiro Cabin":[6,0,4,3],"Onsen Resort":[2,15,3,15],"Carpentry":[6,6,6,6],"Mountain Carpentry":[6,6,6,6],"Fire Station":[9,10,10,10]}
			if specific.has(host.kind):choices=specific[host.kind]
		for i in range(solid_list.size()):
			if kind=="home" and i<5:continue
			var r: Rect2=solid_list[i]
			var foot=Vector2(r.get_center().x,r.end.y)
			var width=clampf((r.size.x*.46+r.size.y*.28),55,150)
			if kind=="room" and host.kind=="Onsen Resort" and r.intersects(Rect2(760,400,220,260)):continue
			if kind=="room" and host.kind=="Tea Processing Shed":tea_machine(i%4,foot,maxf(width,125))
			elif kind=="room" and host.kind=="Tea Farmhouse" and i==0:tea_machine(3,foot,width)
			elif kind=="room" and host.kind=="Fishing Shop" and i>0:
				var display=preload("res://world/angled/FishingDisplay.gd").new()
				display.transform=B.affine_inverse()*Transform2D(0,Vector2.ONE*(width/100.0),0,B*foot)
				display.z_as_relative=false;display.z_index=1000+int((B*foot).y*.1);add_child(display)
			elif kind=="room" and host.kind=="School" and i>=2:school_desk(foot)
			else:prop(furniture,choices[i%choices.size()],4,foot,width)
func tea_machine(index:int,foot:Vector2,width:float):
	var texture=load("res://world/angled/tea-production-v1.png")
	var cell=texture.get_size()/2
	var sprite=Sprite2D.new();sprite.texture=texture;sprite.region_enabled=true;sprite.region_filter_clip_enabled=true;sprite.centered=false
	sprite.region_rect=Rect2(Vector2(index%2,index/2)*cell,cell)
	var ratio=width/cell.x
	sprite.transform=B.affine_inverse()*Transform2D(0,Vector2.ONE*ratio,0,B*foot-Vector2(width*.5,cell.y*ratio*.96))
	sprite.z_as_relative=false;sprite.z_index=1000+int((B*foot).y*.1);add_child(sprite);props.append(sprite)
func wide_waterfall(foot:Vector2,width:float):
	var texture=load("res://world/angled/wide-waterfall-v1.png")
	var sprite=Sprite2D.new();sprite.texture=texture;sprite.centered=false
	var ratio=width/texture.get_width()
	sprite.region_rect=Rect2(Vector2.ZERO,texture.get_size())
	sprite.transform=B.affine_inverse()*Transform2D(0,Vector2.ONE*ratio,0,B*foot-Vector2(width*.5,texture.get_height()*ratio*.90))
	sprite.z_as_relative=false;sprite.z_index=1000+int((B*(foot+position)).y*.1);add_child(sprite);props.append(sprite)
func school_desk(foot:Vector2):
	var sprite=Sprite2D.new()
	sprite.texture=load("res://world/angled/school-desk-v1.png")
	var dimensions:Vector2=sprite.texture.get_size()
	var ratio=68.0/dimensions.x
	sprite.centered=false
	sprite.transform=B.affine_inverse()*Transform2D(0,Vector2.ONE*ratio,0,B*foot-Vector2(34,dimensions.y*ratio*.97))
	sprite.z_as_relative=false;sprite.z_index=clampi(int((B*(foot if kind in ["home","room"] else foot+position)).y*.1)+1000,1,4000)
	add_child(sprite);props.append(sprite)
func build_yards():
	if kind in ["tea","harbor","mountain","historic"]:
		var buildings=Layout.buildings(kind)
		for r:Rect2 in buildings:
			var yard_depth=clampi(int((B*(r.get_center()+position)).y*.1)+950,1,4000)
			# Rear and side beds stay inside already-solid building grounds, away from south-facing doors.
			for point in [r.position+Vector2(20,24),Vector2(r.end.x-20,r.position.y+24),Vector2(r.position.x+18,r.end.y-28),r.end-Vector2(18,28)]:
				coastal_prop(2,point,42).z_index=yard_depth
			var index=11 if kind=="tea" else (6 if kind=="mountain" else 15)
			prop(furniture,index,4,Vector2(r.get_center().x,r.position.y+22),58).z_index=yard_depth
	if kind=="tea":
		# Continue the planted estate on the far side of its eastern boundary fence.
		for x in [1380,1510,1640,1770,1900,2030]:
			for y in [775,915,1055,1195]:farm_prop(3,Vector2(x,y),72)
	if kind=="farm":
		for point in [Vector2(570,380),Vector2(970,380),Vector2(2250,260),Vector2(2530,260)]:coastal_prop(2,point,65)
	if kind=="historic":
		for point in [Vector2(980,900),Vector2(1060,990),Vector2(1210,1020),Vector2(1280,900),Vector2(1270,520),Vector2(1570,580)]:farm_prop(3,point,45)
func build_horizon():
	# Continue the scenery past the navigation bounds; never put new solids in a road.
	if kind not in ["tea","mountain","historic","waterfall","harbor"]:return
	for y in [-380,-230,-80,1280,1430]:
		for x in range(-260,1900,150):
			if not horizon_clear(Vector2(x,y)):continue
			if kind=="harbor" and (y>0 or x<250):continue
			if y>1200:continue
			if kind=="historic" and (x<220 or (y>1200 and x>1300)):continue
			prop(landmarks,11,3,Vector2(x,y),120+posmod(x,31))
	if kind=="tea":
		var hills=Sprite2D.new();hills.texture=load("res://world/angled/tea-hills-v2.png");hills.centered=false
		var width=850.0;var scale=width/hills.texture.get_width();var foot=Vector2(2030,860)
		hills.transform=B.affine_inverse()*Transform2D(0,Vector2.ONE*scale,0,B*foot-Vector2(width*.5,hills.texture.get_height()*scale*.93))
		hills.z_as_relative=false;hills.z_index=-950;add_child(hills)
	if kind in ["tea","mountain"]:
		for y in range(140,1180,170):
			for x in [-180,1780]:
				if not horizon_clear(Vector2(x,y)):continue
				if (kind=="tea" and x<0) or (kind=="mountain" and x>1600):continue
				if (kind=="tea" and absf(y-675)<180) or (kind=="mountain" and absf(y-900)<180):continue
				prop(landmarks,11,3,Vector2(x,y),145)
func horizon_clear(point:Vector2)->bool:
	var world=point+position
	if kind!="farm" and Rect2(Vector2.ZERO,Vector2(3000,2000)).grow(120).has_point(world):return false
	if kind!="town" and Rect2(farm.TOWN_ORIGIN,farm.town.SIZE).grow(120).has_point(world):return false
	for area in ["tea","mountain","historic","harbor"]:
		if area!=kind and Rect2(farm.REGION_ORIGINS[area],Vector2(1600,1200)).grow(120).has_point(world):return false
	return true
func road(a: Vector2,b: Vector2,width: float=115):
	var direction=(b-a).normalized()
	if direction==Vector2.ZERO:return
	var side=direction.orthogonal()
	# Merge simple corridors first, then round the complete junction silhouette.
	# Fine shoulder noise made every straight road look saw-toothed at phone scale.
	var shoulder=side*(width*.5+8)
	var outline=PackedVector2Array([a+shoulder,b+shoulder,b-shoulder,a-shoulder])
	road_polygons.append(outline)
func flush_roads():
	if merged_roads.is_empty():
		for polygon in road_polygons:
			var current=polygon
			var changed=true
			while changed:
				changed=false
				for i in range(merged_roads.size()):
					var union=Geometry2D.merge_polygons(current,merged_roads[i])
					if union.size()==1:
						current=union[0];merged_roads.remove_at(i);changed=true;break
			merged_roads.append(current)
	for polygon in merged_roads:
		var smooth=preload("res://world/angled/TerrainFinish.gd").rounded(polygon)
		preload("res://world/angled/TerrainFinish.gd").dirt(self,smooth,position)
		var bounds=Rect2(smooth[0],Vector2.ZERO)
		for point in smooth:bounds=bounds.expand(point)
		for x in range(int(bounds.position.x),int(bounds.end.x),32):
			for y in range(int(bounds.position.y),int(bounds.end.y),32):
				var p=Vector2(x+sin(y)*9,y+cos(x)*9)
				if Geometry2D.is_point_in_polygon(p,smooth):draw_line(p,p+Vector2(3,1),Color(.55,.45,.27,.18),1,true)
func water(poly: PackedVector2Array):
	if poly.size()<3:return
	preload("res://world/angled/TerrainFinish.gd").water(self,poly,position)
	var edge=poly.duplicate();edge.append(poly[0])
	draw_polyline(edge,Color(.39,.53,.38,.45),17,true)
	draw_polyline(edge,Color("adc7ad"),8,true)
	draw_polyline(edge,Color(.85,.94,.83,.55),3,true)
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
	road_polygons.clear()
	var size=Vector2(3000,2000) if kind=="farm" else Vector2(1600,1200)
	if kind=="road":size=Vector2(1000,1000)
	var grass=Color("8eae62")
	var ground_rect=Rect2(Vector2.ZERO,size)
	draw_rect(ground_rect,grass)
	draw_rect(Rect2(Vector2.ZERO,size),grass)
	var vertices=PackedVector2Array([ground_rect.position,Vector2(ground_rect.end.x,ground_rect.position.y),ground_rect.end,Vector2(ground_rect.position.x,ground_rect.end.y)])
	var uv=PackedVector2Array()
	for vertex in vertices:uv.append((vertex+position)/grass_texture.get_size())
	draw_polygon(vertices,PackedColorArray([Color(.95,.98,.90,.26)]),uv,grass_texture)
	preload("res://world/angled/TerrainFinish.gd").shade(self,vertices,position)
	preload("res://world/angled/TerrainFinish.gd").meadow(self,ground_rect,position)
	for y in range(15,int(size.y),48):
		for x in range(15,int(size.x),53):
			var p=Vector2(x+sin(y+x)*14,y+cos(x)*10)
			draw_line(p,p+Vector2(3,-6),Color(.34,.49,.25,.23),2)
	if kind=="harbor":
		preload("res://world/angled/TerrainFinish.gd").water(self,vertices,position)
		var coast:PackedVector2Array=host.land_outline.duplicate()
		coast.remove_at(coast.size()-1)
		coast.insert(0,Vector2(80,0))
		var land=coast.duplicate();land.append(Vector2(1600,0))
		draw_colored_polygon(land,Color("dfd1a2"))
		preload("res://world/angled/TerrainFinish.gd").shade(self,land,position)
		# Broad wet-sand bands follow the actual coast; the sea-facing edge is darker.
		for band in [[48.0,Color(.66,.59,.39,.19)],[24.0,Color(.63,.60,.44,.28)],[11.0,Color(.79,.80,.64,.55)]]:
			draw_polyline(coast,band[1],band[0],true)
		draw_polyline(coast,Color("d1e9da"),10,true)
	elif kind=="tea":water(host.pond_outline)
	elif kind=="mountain":
		for poly in host.water_polygons:water(poly)
		road(Vector2(830,550),Vector2(520,550),140)
		for i in range(5):
			draw_rect(Rect2(500+i*20,535,18,40),Color("b5ac91"));draw_rect(Rect2(500+i*20,535,18,40),Color("d3c9ae"),false,2)
		for i in range(6):
			var lift=fmod(Time.get_ticks_msec()*.018+i*13,70)
			draw_set_transform_matrix(B.affine_inverse()*Transform2D(0,B*Vector2(490+i*12,570)))
			draw_circle(Vector2(sin(lift*.07+i)*7,-lift),6+lift*.08,Color(1,1,.96,.24*(1-lift/70)))
			draw_set_transform_matrix(Transform2D.IDENTITY)
	elif kind=="historic":
		for poly in host.water_polygons:water(poly)

	elif kind=="waterfall":
		draw_texture_rect(grass_texture,Rect2(Vector2.ZERO,size),true)
		water(PackedVector2Array([Vector2(-1400,-1400),Vector2(2800,-1400),Vector2(2800,360),Vector2(1380,460),Vector2(1050,485),Vector2(550,485),Vector2(220,520),Vector2(-1400,440)]))

		for i in range(90):
			var p=Vector2(350+posmod(i*137,900),600+posmod(i*71,500))
			if absf(p.x-800)>145:
				draw_circle(p,6,Color("779646"));draw_circle(p+Vector2(0,-4),2,Color("eadfb2"))
		road(Vector2(800,1240),Vector2(800,580),230)
	elif kind=="road":road(Vector2(500,40),Vector2(500,960),250)
	if kind!="harbor":
		for route in Roads.ROUTES.get(kind,[]):
			if kind=="farm" and route[0].x<1000:continue
			if kind=="mountain" and route[0]==Vector2(800,1200):road(Vector2(800,1250),route[1],145)
			else:road(route[0],route[1],180)
	# Continue the exit scenery beyond the trigger without advertising an out-of-bounds route.
	if kind=="tea":road(Vector2(0,675),Vector2(180,675),180)
	for door: Vector2 in ([] if kind=="harbor" else Layout.doors(kind).values()):
		var best=door+Vector2(0,120);var distance=INF
		for route in Roads.ROUTES.get(kind,[]):
			var p=Geometry2D.get_closest_point_to_segment(door,route[0],route[1])
			if p.distance_to(door)<distance:best=p;distance=p.distance_to(door)
		road(door,best,95)
	if kind in ["harbor","tea"] and host.pier_area.has_area():
		if kind=="harbor":
			# Raised timber deck: shaded fascia and piles continue below it into the water.
			var r=host.pier_area
			var drop=B.affine_inverse()*Vector2(0,16)
			for edge in [[Vector2(r.position.x,r.end.y),r.end],[Vector2(r.end.x,r.position.y),r.end]]:
				draw_colored_polygon(PackedVector2Array([edge[0],edge[1],edge[1]+drop,edge[0]+drop]),Color("67472f"))
			for x in [r.position.x+8,r.end.x-8]:
				for y in range(740,1000,72):
					var foot=Vector2(x,y)
					draw_set_transform_matrix(B.affine_inverse()*Transform2D(0,B*foot))
					draw_circle(Vector2(3,22),10,Color(0.1,0.25,0.28,0.22))
					draw_line(Vector2(0,3),Vector2(0,27),Color("654c36"),8)
					draw_line(Vector2(-2,4),Vector2(-2,24),Color("a58153"),2)
					draw_set_transform_matrix(Transform2D.IDENTITY)
		draw_rect(host.pier_area,Color("94734b"))
		for y in range(int(host.pier_area.position.y),int(host.pier_area.end.y),18):
			var left=host.pier_area.position.x;var right=host.pier_area.end.x
			draw_rect(Rect2(left,y,right-left,16),Color("a78355") if y%36==0 else Color("967347"))
			draw_line(Vector2(left,y),Vector2(right,y),Color("cfb181"),2)
			for x in range(int(left)+8,int(right)-5,29):
				draw_line(Vector2(x,y+7),Vector2(minf(x+22,right-4),y+9),Color(.34,.23,.12,.25),1,true)
			for x in [left+7,right-7]:draw_circle(Vector2(x,y+8),1.4,Color("625842"))
	for fence in preload("res://RegionBorders.gd").rects(kind):
		var horizontal=fence.size.x>fence.size.y
		var start=fence.position;var end=fence.end
		var rise=B.affine_inverse()*Vector2(0,-26)
		preload("res://world/angled/YardFence.gd").paint(self,start,end,rise*1.25)
	if kind=="harbor":
		marina_deck()
		draw_beach_details()

		if host.fishing_state>0:
			var bob:Vector2=fishing_float()
			draw_line(host.fishing_spot,bob,Color("f1ead2"),2)
			draw_circle(bob,8,Color("cf6d53") if host.fishing_state==1 else Color("ffe18c"))
			if host.fishing_state==2:draw_circle(bob,20,Color("ffe18c"),false,4)
	if kind=="farm":
		road(Vector2(1485,140),Vector2(1485,530),140)
		water(farm.world_outline(farm.SOLID_OUTLINES[8]))
		# Continuous cultivated soil joins adjacent planting cells without grass seams.
		for plot in farm.plots:
			draw_rect(Rect2(plot.position-Vector2(50,40),Vector2(100,80)),Color("a18053"))
			for furrow in [-24,-8,8,24]:
				draw_line(plot.position+Vector2(-48,furrow),plot.position+Vector2(48,furrow),Color(.38,.27,.14,.15),2,true)
	flush_roads()
	if kind=="farm":
		var rise=B.affine_inverse()*Vector2(0,-28)
		for ends in [[Vector2(180,190),Vector2(1380,190)],[Vector2(1590,190),Vector2(2780,190)]]:
			preload("res://world/angled/YardFence.gd").paint(self,ends[0],ends[1],rise)
		for y in range(135,221,22):
			for x in range(1405,1565,32):draw_rect(Rect2(x,y,30,20),Color("d9c8a5"))
	if kind=="mountain":
		for y in range(1180,1241,20):
			for x in range(725,875,30):draw_rect(Rect2(x,y,28,18),Color("d9c8a5"))
	if kind=="mountain":
		for i in range(5):
			draw_rect(Rect2(500+i*20,535,18,40),Color("b5ac91"));draw_rect(Rect2(500+i*20,535,18,40),Color("d3c9ae"),false,2)
	var signs={"farm":[Vector2(1550,240),"Town"],"harbor":[Vector2(1450,580),"Town · East"],"tea":[Vector2(160,600),"← Highlands · Town south"],"historic":[Vector2(1390,1040),"Town"],"mountain":[Vector2(900,1040),"Town · South"],"waterfall":[Vector2(900,1090),"Mountain trail"]}
	if kind=="mountain":
		draw_sign(Vector2(1510,1000),"Tea Country →")
	if kind=="historic":draw_sign(Vector2(780,790),"Moonveil Falls")
	if signs.has(kind) and kind!="farm":draw_sign(signs[kind][0],signs[kind][1])
func draw_room():
	var floor_rect:Rect2=host.FLOOR if kind=="home" else Rect2(110,170,880,620)
	var name:String="Home" if kind=="home" else host.kind
	var colors={"Clinic":"c0d8cc","Veterinarian":"c2d5da","Police Box":"b9c7d0","Fire Station":"d9c2af","Shrine Residence":"c7c398","Archive":"c8b5a0","Tea Farmhouse":"c5d0a3","Tea Processing Shed":"bdc99b","Mine":"817e78","Greenhouse":"b2c4a0","Restaurant":"d2b19b"}
	draw_rect(Rect2(-500,-500,3000,2200),Color("344b46"))
	draw_rect(floor_rect,Color(colors.get(name,"c6ad89")))
	for y in range(int(floor_rect.position.y),int(floor_rect.end.y),42):draw_line(Vector2(floor_rect.position.x,y),Vector2(floor_rect.end.x,y),Color(0.3,.25,.20,.16),2)
	for x in range(int(floor_rect.position.x),int(floor_rect.end.x),105):draw_line(Vector2(x,floor_rect.position.y),Vector2(x,floor_rect.end.y),Color(0.3,.25,.20,.10),1)
	preload("res://world/angled/RoomMaterials.gd").floor_detail(self,name,floor_rect)
	if kind=="home":
		var rug=Rect2(host.BED.position+Vector2(-25,20),host.BED.size+Vector2(50,45))
		draw_rect(rug,Color("849fa7"));draw_rect(rug.grow(-5),Color("dfcda7"),false,3)
		var mat=host.TABLE.grow(8)
		draw_rect(mat,Color("ad785a"));draw_rect(mat.grow(-7),Color("e0c798"),false,3)
		for y in range(int(mat.position.y)+12,int(mat.end.y)-10,12):draw_line(Vector2(mat.position.x+10,y),Vector2(mat.end.x-10,y),Color(.95,.85,.66,.25),1)
	var rise=B.affine_inverse()*Vector2(0,-100)
	var a=floor_rect.position;var b=Vector2(floor_rect.end.x,a.y);var c=Vector2(a.x,floor_rect.end.y)
	draw_colored_polygon(PackedVector2Array([a,b,b+rise,a+rise]),Color("dfd4b9"))
	var d=floor_rect.end
	draw_colored_polygon(PackedVector2Array([b,d,d+rise,b+rise]),Color("d8cbb0"))
	preload("res://world/angled/RoomMaterials.gd").wall_detail(self,name,a,b,d,rise)
	draw_polyline(PackedVector2Array([a+rise,b+rise,d+rise]),Color("82715b"),6,true)
	# Shared joinery keeps the two walls coherent; windows sit in the wall plane.
	draw_polyline(PackedVector2Array([a,b,d]),Color("a58b65"),5,true)
	draw_polyline(PackedVector2Array([a+rise*.22,b+rise*.22,d+rise*.22]),Color("c5b18c"),3,true)
	if name!="Mine":
		for fraction in [.24,.72]:
			var center=a.lerp(b,fraction)
			var left=center-Vector2(43,0)+rise*.37
			var right=center+Vector2(43,0)+rise*.37
			var top=rise*.43
			var frame=PackedVector2Array([left,right,right+top,left+top])
			draw_colored_polygon(frame,Color("9dbdc0"))
			draw_polyline(PackedVector2Array([left,right,right+top,left+top,left]),Color("98734e"),5,true)
			draw_line((left+right)*.5,(left+right)*.5+top,Color("e8d4aa"),3,true)
			draw_line(left+top*.5,right+top*.5,Color("e8d4aa"),3,true)
			draw_line(left-Vector2(7,0),right+Vector2(7,0),Color("b89467"),6,true)
	if name not in ["Mine","School","Restaurant","Café","Tea Farmhouse","Tea Processing Shed","Clinic","Veterinarian"]:
		for edge in [[a,b],[b,d]]:
			var direction=(edge[1]-edge[0]).normalized()
			for n in range(20,int(edge[0].distance_to(edge[1])),54):
				var base=edge[0]+direction*n
				draw_line(base,base+rise*.25,Color("bc9a72"),2,true)
			var center=edge[0].lerp(edge[1],.49)+rise*.48
			var span=direction*34;var top=rise*.30
			draw_colored_polygon(PackedVector2Array([center-span,center+span,center+span+top,center-span+top]),Color("8b6748"))
			draw_colored_polygon(PackedVector2Array([center-span*.82+top*.1,center+span*.82+top*.1,center+span*.82+top*.9,center-span*.82+top*.9]),Color("a3b89a"))
			draw_line(center-span*.65+top*.3,center+top*.65,Color("63836b"),6,true)
			draw_line(center+top*.65,center+span*.65+top*.3,Color("63836b"),6,true)
	var exit_point:Vector2=host.EXIT if kind=="home" else Vector2(550,780)
	draw_rect(Rect2(exit_point-Vector2(65,40),Vector2(130,40)),Color("b99965"))
	draw_rect(Rect2(exit_point-Vector2(65,40),Vector2(130,40)),Color("8c714d"),false,2)
	for n in range(1,6):draw_line(exit_point+Vector2(-65+n*22,-36),exit_point+Vector2(-65+n*22,-4),Color("c9ad79"),3)
	if name=="Greenhouse":
		for bed in preload("res://FarmBuildings.gd").greenhouse(farm):
			var p=Vector2(bed.position[0],bed.position[1]);draw_rect(Rect2(p-Vector2(43,36),Vector2(86,72)),Color("93704a"))
			if bed.stage>0:
				draw_circle(p,16,Color("6e9951"))
				if bed.stage==3:draw_circle(p,10,Color(farm.CROPS[bed.crop].color))
	if kind=="home":
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

func draw_beach_details():
	# Tide pools and small crabs sit away from the open boardwalk and pier lane.
	for pool in [Vector2(1020,750),Vector2(1260,850),Vector2(790,650)]:
		var shape=PackedVector2Array()
		var scale=Vector2(1.5,.8) if pool.x==1020 else (Vector2(.8,1.3) if pool.x==1260 else Vector2(1.1,.9))
		for j in range(24):
			var angle=j*TAU/24
			shape.append(pool+Vector2.from_angle(angle)*scale*(28+4*sin(angle*3+pool.x)))
		draw_colored_polygon(shape,Color("6d9f9f"))
		var edge=shape.duplicate();edge.append(shape[0]);draw_polyline(edge,Color("b8b39a"),8,true)
		for j in range(0,24,4):
			draw_circle(shape[j],5+j%3,Color("9faaa0"))
			draw_circle(shape[j]+Vector2(-1,-2),3,Color("d4cbb1"))
		draw_arc(pool,13,PI*.1,PI*.8,12,Color(.82,.94,.88,.7),2,true)
		draw_circle(pool+Vector2(-7,6),4,Color("72936b"))
		var crab=pool+Vector2(45+sin(Time.get_ticks_msec()*.001)*5,18)
		draw_circle(crab,4,Color("c77c60"))
		for side in [-1,1]:draw_line(crab,crab+Vector2(side*8,-4),Color("b66d4e"),2)

	for i in range(80):
		var wave=Vector2(180+posmod(i*137,1400),680+posmod(i*83,560))
		if Geometry2D.is_point_in_polygon(wave,host.land_outline) or host.pier_area.grow(25).has_point(wave):continue
		wave.x+=sin(Time.get_ticks_msec()*.0007+i)*6
		draw_line(wave,wave+Vector2(18+i%13,0),Color(.83,.95,.94,.5),2,true)
	# Sand flecks and shells follow dry land, keeping the promenade unobstructed.
	for i in range(700):
		var p=Vector2(350+posmod(i*137,1200),430+posmod(i*83,490))
		if not Geometry2D.is_point_in_polygon(p,host.land_outline):continue
		draw_circle(p,1.5 if i%4 else 2.5,Color("c8b77d"))
		if i%17==0:
			draw_arc(p,5,PI,TAU,8,Color("fff0d1"),2,true)
	# Wind ripples, shell fragments and driftwood across the open dry sand.
	var sand_rng=RandomNumberGenerator.new();sand_rng.seed=6209
	for i in range(360):
		var p=Vector2(sand_rng.randf_range(300,1550),sand_rng.randf_range(390,750))
		var end=p+Vector2(sand_rng.randf_range(7,24),sand_rng.randf_range(-2,5))
		if not Geometry2D.is_point_in_polygon(p,host.land_outline) or not Geometry2D.is_point_in_polygon(end,host.land_outline):continue
		draw_line(p,end,Color(.65,.53,.32,.17),1.5,true)
		draw_line(p+Vector2(0,2),end+Vector2(0,2),Color(.99,.93,.74,.38),1.5,true)
		if i%19==0:
			draw_circle(p,3,Color("a79778"));draw_circle(p+Vector2(-1,-1),2,Color("f2dfb3"))
		if i%71==0:draw_line(p,p+Vector2(18,-5),Color("aa8c62"),4,true)
	# Wooden boardwalk along the north-side shops.
	for x in range(470,1420,22):
		draw_rect(Rect2(x,245,20,125),Color("b89360"))
		draw_line(Vector2(x,245),Vector2(x,370),Color("d9b981"),1)
	# Pier rails, lamps and flags sit outside its open central walking lane.
	for x in [host.pier_area.position.x+8,host.pier_area.end.x-8]:
		for y in range(740,1000,72):
			var foot=Vector2(x,y)
			draw_set_transform_matrix(B.affine_inverse()*Transform2D(0,B*foot))
			draw_line(Vector2.ZERO,Vector2(0,-27),Color("765239"),5)
			draw_circle(Vector2(0,-28),4,Color("c8a16a"))
			for band in [-9,-12,-15]:draw_line(Vector2(-4,band),Vector2(4,band),Color("d6ba84"),2,true)
			if y<950:
				var next=B*Vector2(0,72)
				draw_line(Vector2(0,-9),next+Vector2(0,-9),Color("97734d"),4,true)
				draw_line(Vector2(0,20),next+Vector2(0,4),Color("785b3d"),5,true)
				draw_line(Vector2(0,4),next+Vector2(0,20),Color("785b3d"),5,true)
				var rope=PackedVector2Array()
				for step in range(13):
					var t=step/12.0;rope.append(Vector2(0,-18)+next*t+Vector2(0,sin(t*PI)*7))
				draw_polyline(rope,Color("d8bd86"),2,true)
			draw_set_transform_matrix(Transform2D.IDENTITY)
func marina_deck():
	var r=Rect2(130,510,330,90)
	var drop=B.affine_inverse()*Vector2(0,15)
	var front=Vector2(r.position.x,r.end.y)
	draw_colored_polygon(PackedVector2Array([front,r.end,r.end+drop,front+drop]),Color("654c35"))
	draw_rect(r,Color("98764e"))
	for x in range(130,460,18):
		draw_rect(Rect2(x,510,16,90),Color("b08d5b"))
		draw_line(Vector2(x+2,514),Vector2(x+2,596),Color("d0ad79"),1,true)
	for x in [140,225,310]:
		for y in [518,592]:
			var p=Vector2(x,y);var screen=B*p
			draw_set_transform_matrix(B.affine_inverse()*Transform2D(0,screen))
			draw_line(Vector2(0,0),Vector2(0,28),Color("654d37"),8,true)
			draw_line(Vector2(-2,0),Vector2(-2,25),Color("b18b5b"),2,true)
			draw_set_transform_matrix(Transform2D.IDENTITY)
func coastal_prop(index:int,foot:Vector2,width:float):
	var sprite=Sprite2D.new();sprite.texture=preload("res://world/angled/CoastalGardenArt.gd").texture(index);sprite.centered=false
	var size=sprite.texture.get_size();var ratio=width/size.x
	sprite.transform=B.affine_inverse()*Transform2D(0,Vector2.ONE*ratio,0,B*foot-Vector2(width*.5,size.y*ratio*.94))
	sprite.z_as_relative=false;sprite.z_index=clampi(int((B*(foot if kind in ["home","room"] else foot+position)).y*.1)+1000,1,4000)
	add_child(sprite);props.append(sprite)
	return sprite

func expansion_prop(index:int,foot:Vector2,width:float):
	var texture=load("res://world/angled/village-expansion-v1.png")
	var cell=texture.get_size()/2.0
	var sprite=Sprite2D.new();sprite.texture=texture;sprite.region_enabled=true;sprite.region_filter_clip_enabled=true
	sprite.region_rect=[Rect2(0,0,665,620),Rect2(665,25,589,610),Rect2(0,630,675,580),Rect2(680,635,574,605)][index];sprite.centered=false
	cell=sprite.region_rect.size
	var ratio=width/cell.x
	sprite.transform=B.affine_inverse()*Transform2D(0,Vector2.ONE*ratio,0,B*foot-Vector2(width*.5,cell.y*ratio*.91))
	sprite.z_as_relative=false;sprite.z_index=clampi(int((B*(foot if kind in ["home","room"] else foot+position)).y*.1)+1000,1,4000)
	add_child(sprite);props.append(sprite)
