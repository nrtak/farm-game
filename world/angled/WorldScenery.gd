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
	build_horizon()
func active() -> bool:
	if kind=="home": return farm.inside_house
	if kind=="room": return farm.location=="shop" and host==farm.shops.get(farm.shop_name)
	if preload("res://OutdoorContinuity.gd").connected(farm.location,kind):return not farm.inside_house
	return farm.location==kind and not farm.inside_house
func prop(texture: Texture2D, index: int, rows: int, foot: Vector2, width: float, caption: String=""):
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
		s.modulate.a=.28 if not farm.sleep_in_progress and s.z_index>farm.player.z_index and bounds.intersects(Rect2(foot-Vector2(18,62),Vector2(36,62))) else 1.0
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
			expansion_prop(2,Vector2(515,620),235)
		if kind=="historic":
			var falls=prop(landmarks,10,3,preload("res://ShrineFalls.gd").WATERLINE,300)
			falls.flip_h=true
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
			home_prop(0,Vector2(host.BED.get_center().x,host.BED.end.y),145)
			home_prop(1,Vector2(host.TABLE.get_center().x,host.TABLE.end.y),125)
			home_prop(2,Vector2(570,265),95)
			home_prop(3,Vector2(185,285),75)
			home_prop(4,Vector2(host.CHEST.get_center().x,host.CHEST.end.y),85)
		else:
			solid_list.assign(host.solids)
			choices={"General Store":[2,5,5,1],"Blacksmith":[6,7,6],"Carpentry":[6,6,1],"Mountain Carpentry":[6,6,1],"Clinic":[9,8,8],"Veterinarian":[8,1,9],"Ranch":[12,12,2],"Barn":[12],"Mine":[14],"Archive":[1],"Shrine Residence":[13,1,3],"Tea Processing Shed":[11],"Tea Farmhouse":[11,3,1],"Café":[2,3,4],"Restaurant":[3,3,4],"Police Box":[9,1],"Fire Station":[10,9],"Town Hall":[9,1],"Greenhouse":[5,15],"Upper Floor":[0,1,3],"School":[1,1,9,9,9,9],"Inn":[2,1,0,3,3]}.get(host.kind,[2,0,3,1])
		for i in range(solid_list.size()):
			if kind=="home" and i<5:continue
			var r: Rect2=solid_list[i]
			var foot=Vector2(r.get_center().x,r.end.y)
			var width=clampf((r.size.x*.46+r.size.y*.28),55,150)
			if kind=="room" and host.kind=="School" and i>=2:school_desk(foot)
			else:prop(furniture,choices[i%choices.size()],4,foot,width)
func school_desk(foot:Vector2):
	var sprite=Sprite2D.new()
	sprite.texture=load("res://world/angled/school-desk-v1.png")
	var dimensions:Vector2=sprite.texture.get_size()
	var ratio=68.0/dimensions.x
	sprite.centered=false
	sprite.transform=B.affine_inverse()*Transform2D(0,Vector2.ONE*ratio,0,B*foot-Vector2(34,dimensions.y*ratio*.97))
	sprite.z_as_relative=false;sprite.z_index=clampi(int((B*(foot if kind in ["home","room"] else foot+position)).y*.1)+1000,1,4000)
	add_child(sprite);props.append(sprite)
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
	var length=a.distance_to(b)
	var steps=maxi(1,ceili(length/24.0))
	var outline=PackedVector2Array()
	# Preserve the full clear lane; irregular shoulders extend outward only.
	for edge in [1,-1]:
		for i in range(steps+1):
			var t=float(i if edge==1 else steps-i)/steps
			var center=a.lerp(b,t)
			var shoulder=4.0+3.0*sin(center.x*.041+center.y*.027)+2.0*sin(center.x*.113-center.y*.061)
			outline.append(center+side*edge*(width*.5+maxf(0,shoulder)))
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
		var smooth=polygon
		for iteration in range(2):
			var next=PackedVector2Array()
			for i in range(smooth.size()):
				var a=smooth[i];var b=smooth[(i+1)%smooth.size()]
				var amount=minf(.15,12.0/maxf(1,a.distance_to(b)))
				next.append(a.lerp(b,amount));next.append(a.lerp(b,1-amount))
			smooth=next
		var edge=smooth.duplicate();edge.append(smooth[0])
		draw_polyline(edge,Color(.66,.65,.42,.20),16,true)
		draw_colored_polygon(smooth,Color("d5c28f"))
		var bounds=Rect2(smooth[0],Vector2.ZERO)
		for point in smooth:bounds=bounds.expand(point)
		for x in range(int(bounds.position.x),int(bounds.end.x),32):
			for y in range(int(bounds.position.y),int(bounds.end.y),32):
				var p=Vector2(x+sin(y)*9,y+cos(x)*9)
				if Geometry2D.is_point_in_polygon(p,smooth):draw_line(p,p+Vector2(3,1),Color(.55,.45,.27,.18),1,true)
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
	draw_polygon(vertices,PackedColorArray([Color(.95,.98,.90,.58)]),uv,grass_texture)
	for y in range(15,int(size.y),48):
		for x in range(15,int(size.x),53):
			var p=Vector2(x+sin(y+x)*14,y+cos(x)*10)
			draw_line(p,p+Vector2(3,-6),Color(.34,.49,.25,.23),2)
	if kind=="harbor":
		draw_rect(Rect2(Vector2.ZERO,size),Color("70b4bf"))
		var coast:PackedVector2Array=host.land_outline.duplicate()
		coast.remove_at(coast.size()-1)
		coast.insert(0,Vector2(80,0))
		var land=coast.duplicate();land.append(Vector2(1600,0))
		draw_colored_polygon(land,Color("dfd1a2"))
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
		for route in Roads.ROUTES.get(kind,[]):road(route[0],route[1],180)
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
		for level in [.4,.85]:draw_line(start+rise*level,end+rise*level,Color("b0936a"),5,true)
		draw_line(start+rise*.85,end+rise*.85,Color("e0c298"),1.5,true)
		for step in range(0,int(start.distance_to(end)),45):
			var at=start.move_toward(end,step);draw_line(at,at+rise,Color("70543c"),9,true);draw_line(at+Vector2(-2,0),at+rise+Vector2(-2,0),Color("b99a6e"),5,true);draw_circle(at+rise,4,Color("ddc297"))
	if kind=="harbor":
		draw_beach_details()

		if host.fishing_state>0:
			var bob:Vector2=fishing_float()
			draw_line(host.fishing_spot,bob,Color("f1ead2"),2)
			draw_circle(bob,8,Color("cf6d53") if host.fishing_state==1 else Color("ffe18c"))
			if host.fishing_state==2:draw_circle(bob,20,Color("ffe18c"),false,4)
	if kind=="farm":
		road(Vector2(1485,140),Vector2(1485,530),140)
		road(Vector2(775,550),Vector2(1485,550),140)
		road(Vector2(775,550),Vector2(850,1430),130)
		water(farm.world_outline(farm.SOLID_OUTLINES[8]))
		road(Vector2(1020,620),Vector2(1490,620),100)
		for plot in farm.plots:draw_rect(Rect2(plot.position-Vector2(34,34),Vector2(68,68)),Color("a78657"))
	flush_roads()
	if kind=="mountain":
		for i in range(5):
			draw_rect(Rect2(500+i*20,535,18,40),Color("b5ac91"));draw_rect(Rect2(500+i*20,535,18,40),Color("d3c9ae"),false,2)
	var signs={"farm":[Vector2(1550,240),"Town"],"harbor":[Vector2(1450,580),"Town · East"],"tea":[Vector2(160,600),"← Highlands · Town south"],"historic":[Vector2(1390,1040),"Town"],"mountain":[Vector2(900,1040),"Town · South"],"waterfall":[Vector2(900,1090),"Mountain trail"]}
	if kind=="mountain":
		draw_sign(Vector2(1510,1000),"Tea Country →")
	if kind=="historic":draw_sign(Vector2(780,790),"Moonveil Falls")
	if signs.has(kind):draw_sign(signs[kind][0],signs[kind][1])
func draw_room():
	var floor_rect:Rect2=host.FLOOR if kind=="home" else Rect2(110,170,880,620)
	var name:String="Home" if kind=="home" else host.kind
	var colors={"Clinic":"c0d8cc","Veterinarian":"c2d5da","Police Box":"b9c7d0","Fire Station":"d9c2af","Shrine Residence":"c7c398","Archive":"c8b5a0","Tea Farmhouse":"c5d0a3","Tea Processing Shed":"bdc99b","Mine":"817e78","Greenhouse":"b2c4a0","Restaurant":"d2b19b"}
	draw_rect(Rect2(-500,-500,3000,2200),Color("344b46"))
	draw_rect(floor_rect,Color(colors.get(name,"c6ad89")))
	for y in range(int(floor_rect.position.y),int(floor_rect.end.y),42):draw_line(Vector2(floor_rect.position.x,y),Vector2(floor_rect.end.x,y),Color(0.3,.25,.20,.16),2)
	for x in range(int(floor_rect.position.x),int(floor_rect.end.x),105):draw_line(Vector2(x,floor_rect.position.y),Vector2(x,floor_rect.end.y),Color(0.3,.25,.20,.10),1)
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
	if name!="Mine":
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
		draw_circle(pool,29,Color("b6a58b"));draw_circle(pool,22,Color("86bdc0"))
		for j in range(5):draw_circle(pool+Vector2.from_angle(j*TAU/5)*27,7,Color("b6b7a5"))
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
	# Wooden boardwalk along the north-side shops.
	for x in range(470,1420,22):
		draw_rect(Rect2(x,275,20,62),Color("b89360"))
		draw_line(Vector2(x,275),Vector2(x,337),Color("d9b981"),1)
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
				var rope=PackedVector2Array()
				for step in range(13):
					var t=step/12.0;rope.append(Vector2(0,-18)+next*t+Vector2(0,sin(t*PI)*7))
				draw_polyline(rope,Color("d8bd86"),2,true)
			draw_set_transform_matrix(Transform2D.IDENTITY)
func coastal_prop(index:int,foot:Vector2,width:float):
	var sprite=Sprite2D.new();sprite.texture=preload("res://world/angled/CoastalGardenArt.gd").texture(index);sprite.centered=false
	var size=sprite.texture.get_size();var ratio=width/size.x
	sprite.transform=B.affine_inverse()*Transform2D(0,Vector2.ONE*ratio,0,B*foot-Vector2(width*.5,size.y*ratio*.94))
	sprite.z_as_relative=false;sprite.z_index=clampi(int((B*(foot if kind in ["home","room"] else foot+position)).y*.1)+1000,1,4000)
	add_child(sprite);props.append(sprite)

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
