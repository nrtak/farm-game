extends RefCounted
const ROOMS := {"General Store":"store","Café":"cafe","Clinic":"hospital","Inn":"inn","Blacksmith":"blacksmith","Carpentry":"carpenter","Mountain Carpentry":"carpenter","Archive":"library","Town Hall":"townhall","Police Box":"police","Fire Station":"fire","Onsen Resort":"onsen","Tea Processing Shed":"tea","Fishing Shop":"fishing","Tea Farmhouse":"homeguest","Harbor Homes":"homeguest","Mountain Lodge":"homeguest","Hiro Cabin":"homeguest","Shrine Residence":"homeguest"}
static var textures: Dictionary = {}
static func texture(kind: String) -> Texture2D:
	if not ROOMS.has(kind): return null
	if not textures.has(kind): textures[kind]=load("res://assets/interior-"+ROOMS[kind]+"-v2.png")
	return textures[kind]
static func furnishings(kind: String) -> Array[Rect2]:
	# The artwork keeps service counter and lower central aisle aligned to game coordinates.
	var result: Array[Rect2]=[Rect2(360,210,380,90)]
	match kind:
		"Café": result.append_array([Rect2(120,170,210,140),Rect2(795,170,180,140),Rect2(115,330,210,100),Rect2(790,330,185,100),Rect2(120,525,205,150),Rect2(790,525,190,150)])
		"Clinic": result.append_array([Rect2(110,180,225,170),Rect2(795,170,185,160),Rect2(125,505,205,175),Rect2(790,440,190,155)])
		"General Store": result.append_array([Rect2(110,170,210,185),Rect2(795,170,185,185),Rect2(110,420,210,100),Rect2(795,420,185,100),Rect2(110,565,210,160),Rect2(795,565,185,160)])
		_: result.append_array([Rect2(115,175,210,185),Rect2(790,175,190,185),Rect2(120,510,205,175),Rect2(790,510,190,175)])
	return result
