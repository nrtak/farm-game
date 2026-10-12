extends Control
var farm
var elapsed:=0.0
var sprite:Sprite2D
var caption:Label
var original_pause:=false
var full_region:=Rect2()
func begin(f) -> void:
 farm=f
 original_pause=f.paused_by_player
 f.close_dialogue()
 f.paused_by_player=true
 f.player.velocity=Vector2.ZERO
 f.polish.path.clear()
 f.joystick.reset_stick()
 var layer:=CanvasLayer.new();layer.layer=15;f.add_child(layer);layer.add_child(self)
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 mouse_filter=Control.MOUSE_FILTER_STOP
 f.update_walk(0,false,Vector2.DOWN)
 sprite=Sprite2D.new();sprite.texture=f.farmer.texture;sprite.region_enabled=true;sprite.region_rect=f.farmer.region_rect
 full_region=sprite.region_rect
 sprite.scale=Vector2.ONE*(125.0/maxf(1,sprite.region_rect.size.y));add_child(sprite)
 caption=Label.new();caption.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;caption.add_theme_font_size_override("font_size",26);add_child(caption)
func _process(delta:float) -> void:
 if farm==null or not farm.window_focused: return
 elapsed+=delta
 var center:=size/2
 var start:=center+Vector2(-210,0)
 var pool:=center+Vector2(0,30)
 if elapsed<.8:
  var t:=elapsed/.8;sprite.position=start.lerp(pool,t)-Vector2(0,sin(t*PI)*75)
  caption.text="Into the warm spring…"
 elif elapsed<2.8:
  sprite.region_rect=Rect2(full_region.position,Vector2(full_region.size.x,full_region.size.y*.52))
  sprite.position=pool+Vector2(0,-22+sin(elapsed*3)*3);caption.text="A peaceful soak · Health +35"
 else:
  sprite.region_rect=full_region;sprite.self_modulate=Color.WHITE
  var t:=clampf((elapsed-2.8)/.8,0,1);sprite.position=pool.lerp(start,t)-Vector2(0,sin(t*PI)*65)
  caption.text="Refreshed and ready!"
 caption.position=Vector2(20,center.y+135);caption.size=Vector2(size.x-40,50)
 queue_redraw()
 if elapsed>=4.1: finish()
func finish() -> void:
 if farm==null: return
 farm.paused_by_player=original_pause
 farm.refresh_hud();farm.say("Refreshed! Health restored. Enjoy the rest of your day.")
 farm=null
 get_parent().queue_free()
func _draw() -> void:
 var c:=size/2
 draw_rect(Rect2(Vector2.ZERO,size),Color("405b49"))
 for x in range(0,int(size.x),60): draw_line(Vector2(x,c.y+115),Vector2(x,size.y),Color("536e57"),2)
 for side in [-1,1]:
  for i in range(4): draw_circle(c+Vector2(side*(320+i%2*25),-35+i*35),24,Color("58794e"))
 draw_style_box(rim(),Rect2(c-Vector2(290,90),Vector2(580,220)))
 paint_oval(c+Vector2(35,35),Vector2(175,70),Color("8ac9cc"))
 # Steam and waterline keep the body immersed during the soak.
 if elapsed>=.8 and elapsed<2.8:
  sprite.self_modulate=Color(1,1,1,.85)
 for i in range(4):
  draw_arc(c+Vector2(-90+i*65,-65-sin(elapsed+i)*10),24,-1.6,.5,20,Color(.95,1,1,.5),4)
func paint_oval(center:Vector2,radius:Vector2,color:Color) -> void:
 var points:=PackedVector2Array()
 for i in range(64): points.append(center+Vector2(cos(i*TAU/64),sin(i*TAU/64))*radius)
 draw_colored_polygon(points,color)
static func rim() -> StyleBoxFlat:
 var s:=StyleBoxFlat.new();s.bg_color=Color("c6b996");s.set_corner_radius_all(60);return s
