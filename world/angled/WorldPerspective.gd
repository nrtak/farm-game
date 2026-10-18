extends Node2D
# Presentation projection only: physics, saved positions and quest destinations stay in world units.
const BASIS = Transform2D(Vector2(0.558,-0.207),Vector2(0.378,0.315),Vector2.ZERO)
const TOWN_ZOOM = 1.9
var farm
var layers: Array = []
var actor_roots: Array = []
var redraw_clock := 0.0
var travel_pan := Vector2.ZERO
var travel_left := 0.0
func depth_origin()->Vector2:
	return Vector2.ZERO if not farm.inside_house and farm.location in preload("res://OutdoorContinuity.gd").AREAS else farm.polish.area_origin()
func depth(foot:Vector2)->int:
	return clampi(int((BASIS*(foot-depth_origin())).y*.1)+1000,1,4000)
func near_area(origin:Vector2,size:Vector2)->bool:
	var inverse=farm.get_viewport().canvas_transform.affine_inverse()
	var viewport=farm.get_viewport_rect().size
	var bounds=Rect2(inverse*Vector2.ZERO,Vector2.ZERO)
	for corner in [Vector2(viewport.x,0),viewport,Vector2(0,viewport.y)]:bounds=bounds.expand(inverse*corner)
	return bounds.grow(450).intersects(Rect2(origin,size))
func cancel_outdoor_pan():
	travel_left=0.0
	travel_pan=Vector2.ZERO
func begin_outdoor_pan(direction:Vector2):
	travel_pan=-direction.normalized()*95.0
	travel_left=.42
func setup(f):
	farm=f;process_priority=1000
	f.set_meta("angled_world",true)
	var backdrop=preload("res://world/angled/WorldBackdrop.gd").new();backdrop.farm=f;f.add_child(backdrop)
	f.outdoor_world.get_node("Environment").hide()
	f.farmhouse.get_node("Artwork").hide()
	add_layer(f,"farm",Vector2.ZERO)
	add_layer(f.interior,"home",f.ROOM_ORIGIN)
	add_layer(f.road,"road",f.ROAD_ORIGIN)
	for area in f.regions: add_layer(f.regions[area],area,f.REGION_ORIGINS[area])
	for room in f.shops: add_layer(f.shops[room],"room",f.shops[room].position)
	actor_roots=[f,f.town]+f.regions.values()+f.shops.values()
	for area in f.regions.values():
		for child in area.get_children():
			if child is Label: child.hide()
	_process(0)
func add_layer(host,kind:String,origin:Vector2):
	var layer=preload("res://world/angled/WorldScenery.gd").new()
	layer.farm=farm;layer.host=host;layer.kind=kind;layer.position=origin
	farm.add_child(layer);layers.append(layer)
func manual_direction(direction:Vector2)->Vector2:
	return (BASIS.affine_inverse()*direction).normalized()*minf(direction.length(),1.0) if direction.length()>0 else direction
func movement_velocity(direction:Vector2,speed:float)->Vector2:
	var strength=minf(direction.length(),1.0)
	if strength<=0.00001:return Vector2.ZERO
	# Normalize in the visible ground plane, not the skewed logical coordinate system.
	# .5 retains a calm regional pace while removing direction-dependent acceleration.
	var projected=BASIS*direction.normalized()
	return direction.normalized()*(speed*(1.0 if farm.location=="town" else .5)*strength/projected.length())
func _process(_delta):
	if farm==null or not is_instance_valid(farm.player):return
	if not farm.inside_house and farm.location in preload("res://OutdoorContinuity.gd").AREAS:
		farm.town.show();farm.outdoor_world.show()
		for area in ["mountain","tea","harbor","historic"]:farm.regions[area].show()
	travel_left=maxf(0,travel_left-_delta)
	var angled:bool=true
	# One renderer owns the viewport for every area. Camera2D remains only as
	# compatibility storage for scripted festival zoom; it must never overwrite this transform.
	farm.camera.enabled=false
	var zoom=1.9 if not farm.festival_active else .85
	if farm.location=="town":
		if not farm.festival_active:farm.camera.zoom=Vector2.ONE*TOWN_ZOOM
		zoom=farm.camera.zoom.x
	var ground=BASIS if angled else Transform2D.IDENTITY
	var view=ground.scaled(Vector2.ONE*zoom)
	view.origin=farm.get_viewport_rect().size/2+Vector2(0,65)-view*farm.player.position
	if travel_left>0:view.origin+=travel_pan*pow(travel_left/.42,2)
	farm.get_viewport().canvas_transform=view
	if farm.location=="town" and not farm.inside_house:farm.town.visuals.follow_player(farm.player.position-farm.TOWN_ORIGIN)
	if not farm.inside_house and farm.location in preload("res://OutdoorContinuity.gd").AREAS:
		farm.town.visible=near_area(farm.TOWN_ORIGIN,farm.town.SIZE)
		for area in ["mountain","tea","harbor","historic"]:farm.regions[area].visible=near_area(farm.REGION_ORIGINS[area],farm.regions[area].SIZE)
	if angled:
		# Upright character artwork, independent of the projected ground plane.
		var frame:int=maxi(0,farm.walk_frame)%100
		var row:int=int(frame/4)
		var index=(3 if row==1 else row)*4+frame%4
		index=clampi(index,0,farm.side_offsets.size()-1)
		var actor_scale=.50 if farm.inside_house or farm.location=="shop" else .38
		var offset:Vector2=farm.side_offsets[index]*farm.front_scale*actor_scale
		if farm.farmer.flip_h:offset.x*=-1
		farm.farmer.transform=BASIS.affine_inverse()*Transform2D(0,Vector2.ONE*farm.front_scale*actor_scale,0,offset)
		farm.player.z_index=depth(farm.player.position)
	if farm.item_moment.visible:
		var lift=Vector2(0,-98-sin((.9-farm.pickup_time)*PI/.9)*5)
		farm.item_moment.transform=(BASIS.affine_inverse() if angled else Transform2D.IDENTITY)*Transform2D(0,Vector2.ONE*.7,0,lift)
	redraw_clock+=_delta
	for layer in layers:
		layer.visible=layer.active() and (layer.kind in ["home","room"] or near_area(layer.position,Vector2(3000,2000) if layer.kind=="farm" else Vector2(1600,1200)))
		if layer.visible:
			layer.refresh_props()
			if redraw_clock>=.12:layer.queue_redraw()
	if redraw_clock>=.12:redraw_clock=0
	for root in actor_roots:
		if not root.visible:continue
		for actor in root.get_children():
			if actor.get_script()!=preload("res://Npc.gd") and actor.get_script()!=preload("res://AmbientPet.gd"):continue
			var size=.45 if actor.get_script()==preload("res://AmbientPet.gd") else (.55 if farm.location=="shop" or farm.inside_house else .40)
			actor.set_meta("ground_projection",BASIS)
			actor.transform=Transform2D(BASIS.affine_inverse().x*size,BASIS.affine_inverse().y*size,actor.position)
			actor.z_as_relative=false;actor.z_index=depth(actor.global_position)

	if farm.has_node("FarmDog"):
		var dog=farm.get_node("FarmDog")
		var pet_size=.45 if dog.adult(farm) else .31
		dog.pet.transform=Transform2D(BASIS.affine_inverse().x*pet_size,BASIS.affine_inverse().y*pet_size,dog.pet.position)
		dog.pet.z_as_relative=false;dog.pet.z_index=depth(dog.pet.position)
