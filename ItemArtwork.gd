extends RefCounted
const ITEMS := ["Goat milk","Sea Bream","Tea packets","Tea leaves","Strawberry","Mackerel","Sardine","Turnip","Potato","Copper","Iron","Milk","Wool","Egg","Lumber","Cake","Cow","Sheep","Goat","Chicken","Feed","Backpack","Watering can","Pickaxe","Harvest tools","Meal"]
static func identify(text: String) -> String:
	var lower := text.to_lower()
	if "copper pick" in lower: return "Pickaxe"
	if "watering can" in lower: return "Watering can"
	for item in ITEMS:
		if item.to_lower() in lower: return item
	if "feed" in lower: return "Feed"
	if "watering can" in lower: return "Watering can"
	if "copper pick" in lower: return "Pickaxe"
	if "meal" in lower or "lunch" in lower: return "Meal"
	return ""
static func attach(button: Button, item: String) -> void:
	if item.is_empty(): return
	button.set_meta("item_art",item)
	button.custom_minimum_size.y=maxf(button.custom_minimum_size.y,44)
	var icon=preload("res://ItemMoment.gd").new()
	icon.name="ItemArtwork"
	icon.show_caption=false
	icon.scale=Vector2.ONE*0.6
	button.add_child(icon)
	icon.show_item(item)
	button.resized.connect(func(): icon.position=Vector2(25,button.size.y/2))
	var style=button.get_theme_stylebox("normal").duplicate()
	style.content_margin_left=50
	button.add_theme_stylebox_override("normal",style)
static func list_goods(farm,column) -> void:
	farm.dialogue_text.size_flags_vertical=Control.SIZE_SHRINK_BEGIN
	farm.dialogue_panel.get_child(0).offset_top=-minf(430,farm.get_viewport_rect().size.y-32)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size=Vector2(0,100)
	scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL
	column.add_child(scroll)
	var list := VBoxContainer.new()
	list.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	scroll.add_child(list)
	var goods: Dictionary={}
	for inventory in [farm.produce,farm.fish_basket,farm.ore_basket,farm.BarnLife.state(farm).products]:
		for item in inventory:
			goods[item]=[int(inventory[item]),0]
	var prices: Dictionary={}
	for item in farm.CROPS: prices[item]=farm.CROPS[item].sale
	prices.merge(farm.FISH);prices.merge(farm.ORE);prices.merge(farm.BarnLife.PRICES)
	goods["Tea packets"]=[farm.packed_tea,farm.tea_shipping];prices["Tea packets"]=45
	for inventory in [farm.shipping_queue,farm.fish_shipping,farm.ore_shipping,farm.BarnLife.state(farm).shipping]:
		for item in inventory: goods[item][1]=int(inventory[item])
	for item in goods:
		if goods[item][0]+goods[item][1]==0: continue
		var row=farm.make_button("%s · Bag %d · Shipping %d · ¥%d each" % [item,goods[item][0],goods[item][1],prices[item]],func(): pass)
		row.mouse_filter=Control.MOUSE_FILTER_IGNORE
		list.add_child(row)
