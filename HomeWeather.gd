extends Control
const APPROACH=Vector2(185,345)
var weather:="Normal"
var caption:="Tomorrow"
static func advice(kind:String) -> String:
 match kind:
  "Rain": return "Rain waters outdoor crops. Outdoor work costs more health; animals shelter indoors."
  "Hurricane": return "Stay inside tomorrow. Finish outdoor chores today and rest safely at home during the storm."
  "Heatwave": return "Outdoor crops lose one day of growth. Animals shelter inside; take care of yourself."
 return "A clear day for the farm. Water outdoor crops and make time to explore."
static func show_forecast(f,from_journal:bool=false) -> void:
 var c=f.make_modal("Village weather")
 var row:=HBoxContainer.new();row.add_theme_constant_override("separation",18);c.add_child(row);c.move_child(row,1)
 for offset in range(2):
  var card=load("res://HomeWeather.gd").new()
  card.weather=preload("res://WeatherLife.gd").forecast(f.day+offset)
  card.caption="Today" if offset==0 else "Tomorrow"
  card.custom_minimum_size=Vector2(220,105);card.size_flags_horizontal=Control.SIZE_EXPAND_FILL
  row.add_child(card)
 f.dialogue_text.text=advice(preload("res://WeatherLife.gd").forecast(f.day+1))
 c.add_child(f.make_button("Back",preload("res://EverydayLife.gd").journal.bind(f) if from_journal else f.close_dialogue))
static func draw_tv(room) -> void:
 room.draw_style_box(room.panel(Color("624d3d")),Rect2(115,205,140,83))
 room.draw_style_box(room.panel(Color("364d55")),Rect2(124,213,106,61))
 room.draw_circle(Vector2(241,229),5,Color("d0c7a5"));room.draw_circle(Vector2(241,248),5,Color("d0c7a5"))
 room.draw_line(Vector2(142,288),Vector2(137,299),Color("493e34"),5)
 room.draw_line(Vector2(226,288),Vector2(231,299),Color("493e34"),5)
 room.draw_circle(Vector2(151,233),12,Color("efd078"))
 for point in [Vector2(173,244),Vector2(188,237),Vector2(203,244)]: room.draw_circle(point,12,Color("dde7dd"))
 room.draw_string(ThemeDB.fallback_font,Vector2(153,269),"Weather",HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("fff2cd"))
func _draw() -> void:
 var bg:=StyleBoxFlat.new();bg.bg_color=Color("d9e3d1");bg.set_corner_radius_all(10)
 draw_style_box(bg,Rect2(Vector2.ZERO,size))
 var origin:=Vector2(47,47)
 if weather in ["Normal","Heatwave"]:
  draw_circle(origin,17,Color("d8a94d"))
  for i in range(8):
   var ray:=Vector2.from_angle(i*TAU/8)
   draw_line(origin+ray*23,origin+ray*29,Color("b98d3b"),3)
 else:
  for delta in [Vector2(-17,0),Vector2(0,-8),Vector2(17,0)]: draw_circle(origin+delta,16,Color("7c969b"))
  for x in [-17,0,17]: draw_line(origin+Vector2(x,22),origin+Vector2(x-5,33),Color("5a8697"),3)
 if weather=="Hurricane":
  draw_arc(origin,30,.3,5.5,24,Color("526d76"),4)
 var font=ThemeDB.fallback_font
 draw_string(font,Vector2(88,35),caption,HORIZONTAL_ALIGNMENT_LEFT,-1,20,Color("4b594b"))
 draw_string(font,Vector2(88,66),"Clear" if weather=="Normal" else weather,HORIZONTAL_ALIGNMENT_LEFT,-1,23,Color("354b42"))
