extends RefCounted
const NAMES := {"General Store":"Store","Town Hall":"Hall","Clinic":"Hospital","Café":"Café","Blacksmith":"Smith","Inn":"Inn","Police Box":"Police","Fire Station":"Fire","Carpentry":"Carpenter","Mountain Carpentry":"Carpenter","Onsen Resort":"Onsen","Archive":"Library","Shrine Residence":"Shrine","Tea Farmhouse":"Home","Tea Processing Shed":"Tea","Harbor Homes":"Home","Fishing Shop":"Fish","Mountain Lodge":"Lodge","Hiro Cabin":"Cabin"}
static func label(text: String,where: Vector2) -> Label:
	var sign := Label.new()
	sign.text=NAMES.get(text,text)
	sign.position=where; sign.size=Vector2(128,38)
	sign.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	sign.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
	sign.add_theme_font_size_override("font_size",17)
	sign.add_theme_color_override("font_color",Color("493b2d"))
	var panel := StyleBoxFlat.new()
	panel.bg_color=Color("c6a16d"); panel.border_color=Color("654832")
	panel.set_border_width_all(3); panel.set_corner_radius_all(1)
	for x in [16,106]:
		var post := ColorRect.new()
		post.position=Vector2(x,36); post.size=Vector2(7,32)
		post.color=Color("654832"); post.mouse_filter=Control.MOUSE_FILTER_IGNORE
		sign.add_child(post)
	sign.add_theme_stylebox_override("normal",panel)
	sign.mouse_filter=Control.MOUSE_FILTER_IGNORE
	return sign
