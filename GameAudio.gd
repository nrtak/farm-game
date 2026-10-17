extends Node
const MUSIC_BUS:="TeaBlossomMusic"
const EFFECTS_BUS:="TeaBlossomEffects"
const AMBIENCE_BUS:="TeaBlossomAmbience"
const STEPS_BUS:="TeaBlossomSteps"
var farm
var players:Array[AudioStreamPlayer]=[]
var effects:AudioStreamPlayer
var steps:AudioStreamPlayer
var ambience:AudioStreamPlayer
var current:=""
var ambient_key:=""
var slot:=0
var fade:=1.0
var gains:=[0.0,0.0]
var initial:=[0.0,0.0]
var poll:=0.0
var distance:=0.0
var suspended:=false
var sound_cache:Dictionary={}
static func preferences(f) -> Dictionary:
	var s:Dictionary=preload("res://PlayerComfort.gd").settings(f)
	return s
static func volume(f,key:String,default:float) -> float:
	return clampf(float(preferences(f).get(key,default)),0,1)
func setup(f) -> void:
	farm=f
	for title in [MUSIC_BUS,EFFECTS_BUS,AMBIENCE_BUS,STEPS_BUS]:
		if AudioServer.get_bus_index(title)<0:
			AudioServer.add_bus();AudioServer.set_bus_name(AudioServer.bus_count-1,title)
	for bus in [AMBIENCE_BUS,STEPS_BUS]: AudioServer.set_bus_send(AudioServer.get_bus_index(bus),EFFECTS_BUS)
	for i in range(2):
		var player:=AudioStreamPlayer.new();player.bus=MUSIC_BUS;add_child(player);players.append(player)
	effects=AudioStreamPlayer.new();effects.bus=EFFECTS_BUS;effects.volume_db=-12;add_child(effects)
	steps=AudioStreamPlayer.new();steps.bus=STEPS_BUS;steps.volume_db=-28;add_child(steps)
	ambience=AudioStreamPlayer.new();ambience.bus=AMBIENCE_BUS;ambience.volume_db=-18;add_child(ambience)
	farm.resources.action_audio.bus=EFFECTS_BUS
	farm.regions.waterfall.ambience.bus=AMBIENCE_BUS
	apply_volumes()
static func theme(f) -> String:
	if f.inside_house or f.location=="shop": return "interior"
	if preload("res://ShrineFalls.gd").nearby(f): return "falls"
	if f.is_rainy_day(): return "rain"
	if f.clock_minutes>=1140 or f.clock_minutes<360: return "night"
	if f.location=="farm": return "farm"
	if f.location=="town": return "town"
	return "nature"
func apply_volumes() -> void:
	for pair in [[AMBIENCE_BUS,"ambience_volume"],[STEPS_BUS,"footstep_volume"]]:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index(pair[0]),linear_to_db(maxf(.00001,volume(farm,pair[1],1.0))))
		AudioServer.set_bus_mute(AudioServer.get_bus_index(pair[0]),volume(farm,pair[1],1.0)==0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(MUSIC_BUS),linear_to_db(maxf(.00001,volume(farm,"music_volume",.45))))
	AudioServer.set_bus_mute(AudioServer.get_bus_index(MUSIC_BUS),volume(farm,"music_volume",.45)==0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(EFFECTS_BUS),linear_to_db(maxf(.00001,volume(farm,"effects_volume",.65))))
	AudioServer.set_bus_mute(AudioServer.get_bus_index(EFFECTS_BUS),volume(farm,"effects_volume",.65)==0)
func loop_stream(path:String) -> AudioStreamWAV:
	var stream=load(path) as AudioStreamWAV
	if stream!=null:
		stream.loop_mode=AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin=0;stream.loop_end=int(stream.get_length()*stream.mix_rate)
	return stream
func switch_theme(key:String) -> void:
	if current==key: return
	current=key;slot=1-slot;initial=gains.duplicate();gains[slot]=0;initial[slot]=0;fade=0
	players[slot].stop();players[slot].stream=loop_stream("res://assets/audio/music-"+key+".wav");players[slot].volume_db=-80;start_player(players[slot])
func _process(delta:float) -> void:
	if farm==null: return
	suspended=not farm.window_focused or farm.paused_by_player or farm.choosing_character
	for player in players: player.stream_paused=suspended
	for player in [effects,steps,ambience,farm.resources.action_audio]: player.stream_paused=suspended
	if suspended: return
	poll-=delta
	if poll<=0:
		poll=.25
		if volume(farm,"music_volume",.45)>0: switch_theme(theme(farm))
		elif current!="":
			for player in players: player.stop();player.stream=null
			current="";gains=[0.0,0.0]
		update_ambience()
	if current!="":
		fade=minf(1,fade+delta/1.5)
		for i in range(2):
			gains[i]=lerpf(initial[i],1.0 if i==slot else 0.0,fade)
			var duck:float=.45 if farm.sleep_in_progress else (.75 if farm.dialogue_open else 1.0)
			players[i].volume_db=-10+linear_to_db(maxf(.00001,gains[i]*duck))
			if i!=slot and fade>=1 and players[i].stream!=null: players[i].stop();players[i].stream=null
func update_ambience() -> void:
	var key:=""
	if not farm.inside_house and farm.location!="shop" and farm.location!="waterfall" and volume(farm,"effects_volume",.65)>0:
		key="rain" if farm.is_rainy_day() else ("night" if farm.clock_minutes>=1140 else "nature")
	if key==ambient_key: return
	ambient_key=key;ambience.stop();ambience.stream=null
	if key!="": ambience.stream=loop_stream("res://assets/audio/ambience-"+key+".wav");start_player(ambience)
func play_effect(kind:String) -> void:
	if farm==null or not farm.window_focused or volume(farm,"effects_volume",.65)<=0: return
	if not sound_cache.has(kind): sound_cache[kind]=load("res://assets/audio/sfx-"+kind+".wav")
	effects.stream=sound_cache[kind];start_player(effects)
func walked(amount:float) -> void:
	if farm.dialogue_open or farm.sleep_in_progress or volume(farm,"effects_volume",.65)<=0: distance=0;return
	distance+=amount
	if distance<58: return
	distance=fmod(distance,58)
	if not sound_cache.has("step"): sound_cache.step=load("res://assets/audio/sfx-step.wav")
	steps.stream=sound_cache.step;steps.pitch_scale=.72 if farm.inside_house or farm.location=="shop" else .68;start_player(steps)
static func menu(f) -> void:
	f.close_dialogue();var c=f.make_modal("Music & sound");f.dialogue_panel.get_child(0).offset_top=-minf(460,f.get_viewport_rect().size.y-28)
	f.dialogue_text.text="Turn music and sound effects on or off, or adjust their volume."
	f.dialogue_text.size_flags_vertical=Control.SIZE_SHRINK_BEGIN
	var scroll:=ScrollContainer.new();scroll.custom_minimum_size.y=180;scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL;c.add_child(scroll)
	var list:=VBoxContainer.new();list.size_flags_horizontal=Control.SIZE_EXPAND_FILL;scroll.add_child(list)
	for entry in [["music_volume","Music",.45],["effects_volume","All effects",.65],["ambience_volume","Nature ambience",1.0],["footstep_volume","Footsteps",1.0]]:
		var switch:=CheckButton.new();switch.text=entry[1]+" on";switch.add_theme_color_override("font_color",Color("493b2d"));switch.button_pressed=volume(f,entry[0],entry[2])>0;list.add_child(switch)
		for color_key in ["font_pressed_color","font_hover_color","font_hover_pressed_color"]: switch.add_theme_color_override(color_key,Color("493b2d"))
		var switch_key:String=entry[0];var default_volume:float=entry[2]
		switch.toggled.connect(func(on): preferences(f)[switch_key]=default_volume if on else 0.0;f.sound.apply_volumes();f.save_game(false);menu(f))
		var key:String=entry[0];var label:=Label.new();label.add_theme_color_override("font_color",Color("493b2d"));list.add_child(label)
		var slider:=HSlider.new();slider.name=key;slider.min_value=0;slider.max_value=100;slider.step=5;slider.value=volume(f,key,entry[2])*100;slider.custom_minimum_size=Vector2(250,44);list.add_child(slider)
		label.text="%s · %d%%" % [entry[1],slider.value]
		var title:String=entry[1]
		slider.value_changed.connect(func(value):
			preferences(f)[key]=value/100.0;label.text="%s · %d%%" % [title,value];f.sound.apply_volumes())
		slider.drag_ended.connect(func(_changed): f.save_game(false))
	c.add_child(f.make_button("Back to Settings",func(): f.save_game(false);preload("res://PlayerComfort.gd").open_settings(f)))
func _exit_tree() -> void:
	for player in players+[effects,steps,ambience]:
		if is_instance_valid(player): player.stop();player.stream=null
	sound_cache.clear()

func start_player(player:AudioStreamPlayer) -> void:
	# Headless validation has no audio output; avoid queuing playback on its dummy mixer.
	if DisplayServer.get_name()!="headless": player.play()
