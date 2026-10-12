extends Node2D
var item := ""
var show_caption := true
func show_item(value: String) -> void:
	item = value
	visible = true
	queue_redraw()
func _draw() -> void:
	var ink := Color("493b2d")
	var green := Color("82946d")
	draw_circle(Vector2.ZERO, 34, Color("f3e4be"))
	if item in ["Copper", "Iron"]:
		draw_colored_polygon(PackedVector2Array([Vector2(-23, 14), Vector2(-16, -17), Vector2(10, -23), Vector2(24, 2), Vector2(15, 20)]), Color("747970"))
		draw_rect(Rect2(-10, -8, 20, 15), Color("bc8a63") if item == "Copper" else Color("c0c5c0"))
	elif item in ["Sardine", "Mackerel", "Sea Bream"]:
		draw_colored_polygon(PackedVector2Array([Vector2(-23, 0), Vector2(-8, -14), Vector2(18, -9), Vector2(26, 0), Vector2(18, 9), Vector2(-8, 14)]), Color("80979e") if item != "Sea Bream" else Color("ae7964"))
		draw_colored_polygon(PackedVector2Array([Vector2(-18, 0), Vector2(-31, -13), Vector2(-31, 13)]), Color("80979e"))
		draw_circle(Vector2(15, -3), 3, ink)
	elif item == "Potato":
		draw_circle(Vector2(-7, 6), 17, Color("c3a477"))
		draw_circle(Vector2(12, -5), 14, Color("c3a477"))
		draw_circle(Vector2(-10, 7), 2, ink)
		draw_circle(Vector2(12, -4), 2, ink)
	elif item == "Strawberry":
		draw_colored_polygon(PackedVector2Array([Vector2(-20, -12), Vector2(20, -12), Vector2(0, 25)]), Color("ba6d60"))
		for point in [Vector2(-7, -3), Vector2(7, -3), Vector2(0, 10)]: draw_circle(point, 2, Color("f3e4be"))
		draw_line(Vector2(-14, -14), Vector2(14, -14), green, 9)
	elif item == "Turnip":
		draw_circle(Vector2(0, 6), 18, Color("ece3cf"))
		draw_line(Vector2(0, 18), Vector2(0, 27), Color("ece3cf"), 4)
		draw_line(Vector2(0, -8), Vector2(0, -24), green, 6)
		draw_circle(Vector2(-8, -15), 8, green)
		draw_circle(Vector2(8, -19), 8, green)
	elif item == "Lumber":
		draw_line(Vector2(-22,10),Vector2(22,-10),Color("97734e"),18)
		draw_circle(Vector2(22,-10),9,Color("dbc18b"))
	elif item in ["Milk","Goat milk"]:
		draw_rect(Rect2(-15,-16,30,39),Color("f5edda"))
		draw_rect(Rect2(-10,-25,20,10),Color("8dabb2"))
		draw_rect(Rect2(-15,1,30,12),Color("8dabb2"))
	elif item == "Egg":
		draw_set_transform(Vector2.ZERO,0,Vector2(0.8,1.1))
		draw_circle(Vector2.ZERO,22,Color("f6edd6"))
		draw_set_transform(Vector2.ZERO)
	elif item == "Wool":
		for p in [Vector2(-13,0),Vector2(0,-10),Vector2(13,0),Vector2(0,12)]: draw_circle(p,13,Color("f4efdc"))
	elif item in ["Tea packets","Feed","Backpack"]:
		draw_style_box(box(Color("a88c5f") if item=="Backpack" else Color("78936a")),Rect2(-21,-24,42,49))
		draw_rect(Rect2(-15,-9,30,21),Color("eee0bb"))
		draw_line(Vector2(-14,-20),Vector2(14,-20),ink,3)
	elif item in ["Meal","Cake"]:
		draw_circle(Vector2(0,12),27,Color("eee3c9"))
		if item=="Cake":
			draw_rect(Rect2(-19,-15,38,31),Color("c89968"))
			draw_rect(Rect2(-19,-15,38,9),Color("fff1d5"))
			draw_circle(Vector2(0,-19),6,Color("ba6d60"))
		else:
			draw_circle(Vector2(-8,5),14,Color("f5e6c1"))
			draw_circle(Vector2(10,7),13,Color("b77a49"))
			for p in [Vector2(8,1),Vector2(16,7),Vector2(8,14)]: draw_circle(p,3,green)
	elif item in ["Watering can","Pickaxe","Harvest tools"]:
		if item=="Watering can":
			draw_rect(Rect2(-17,-10,30,30),Color("829fa7"))
			draw_arc(Vector2(-16,0),12,PI/2,PI*1.5,14,ink,4)
			draw_line(Vector2(12,7),Vector2(27,-9),Color("829fa7"),7)
		else:
			draw_line(Vector2(-15,23),Vector2(12,-18),Color("ab7b48"),7)
			draw_arc(Vector2(5,0),22,PI*1.15,PI*1.9,15,Color("7a8b91"),7)
	elif item in ["Cow","Sheep","Goat","Chicken"]:
		var fur:=Color("eee6cf") if item!="Goat" else Color("cba47b")
		draw_circle(Vector2(-5,5),18,fur)
		draw_circle(Vector2(14,-5),12,fur)
		for x in [-15,4]: draw_line(Vector2(x,16),Vector2(x,27),ink,5)
		if item=="Cow": draw_circle(Vector2(-10,3),8,ink)
		if item=="Sheep":
			for p in [Vector2(-17,-6),Vector2(-6,-11),Vector2(4,-4)]: draw_circle(p,9,fur)
		if item=="Goat":
			for x in [10,20]: draw_line(Vector2(x,-12),Vector2(x-3,-25),ink,3)
		if item=="Chicken":
			draw_circle(Vector2(13,-16),5,Color("ba6d60"))
			draw_colored_polygon(PackedVector2Array([Vector2(22,-5),Vector2(32,0),Vector2(22,3)]),Color("d7a54f"))
		draw_circle(Vector2(18,-6),2,ink)
	elif item == "Wallet":
		draw_rect(Rect2(-23, -16, 46, 32), Color("b58654"))
		draw_rect(Rect2(-18, -11, 36, 22), Color("e4cf9c"))
	else:
		draw_line(Vector2(0, 22), Vector2(0, -22), green, 5)
		for point in [Vector2(-10, 6), Vector2(10, -6), Vector2(-8, -16)]: draw_circle(point, 11, green)
	if not show_caption: return
	var width := ThemeDB.fallback_font.get_string_size(item, HORIZONTAL_ALIGNMENT_LEFT, -1, 22).x
	draw_rect(Rect2(-width / 2 - 10, 38, width + 20, 31), Color("f3e4be"))
	draw_string(ThemeDB.fallback_font, Vector2(-width / 2, 61), item, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, ink)

func box(color: Color) -> StyleBoxFlat:
	var style:=StyleBoxFlat.new()
	style.bg_color=color
	style.set_corner_radius_all(6)
	return style
