extends RefCounted
const NAMES := {"General Store":"Store","Town Hall":"Hall","Clinic":"Clinic","Café":"Café","Blacksmith":"Smith","Inn":"Inn","Police Box":"Police","Fire Station":"Fire","Carpentry":"Carpenter","Mountain Carpentry":"Carpenter","Onsen Resort":"Onsen","Archive":"Archive","Shrine Residence":"Shrine","Tea Farmhouse":"Home","Tea Processing Shed":"Tea","Harbor Homes":"Home","Fishing Shop":"Fish","Mountain Lodge":"Lodge","Hiro Cabin":"Cabin"}
static func label(text: String,where: Vector2) -> Label:
	var sign := Label.new()
	sign.text=NAMES.get(text,text)
	sign.position=where; sign.size=Vector2(112,30)
	sign.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	sign.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
	sign.add_theme_font_size_override("font_size",17)
	sign.add_theme_color_override("font_color",Color("493b2d"))
	var panel := StyleBoxFlat.new()
	panel.bg_color=Color("e1c799"); panel.border_color=Color("816244")
	panel.set_border_width_all(2); panel.set_corner_radius_all(4)
	sign.add_theme_stylebox_override("normal",panel)
	sign.mouse_filter=Control.MOUSE_FILTER_IGNORE
	return sign
