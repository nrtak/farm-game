extends RefCounted
static func grid(f,column) -> GridContainer:
 var scroll:=ScrollContainer.new()
 scroll.custom_minimum_size.y=130
 scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL
 scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
 column.add_child(scroll)
 var g:=GridContainer.new()
 g.columns=maxi(2,int((f.get_viewport_rect().size.x-100)/155))
 g.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 g.add_theme_constant_override("h_separation",8)
 g.add_theme_constant_override("v_separation",8)
 scroll.add_child(g)
 f.dialogue_text.size_flags_vertical=Control.SIZE_SHRINK_BEGIN
 return g
static func tile(button:Button) -> void:
 button.custom_minimum_size=Vector2(140,140)
 button.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 button.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 button.add_theme_font_size_override("font_size",17)
 for state in ["normal","hover","pressed","disabled","focus"]:
  var style=button.get_theme_stylebox(state).duplicate()
  style.content_margin_left=8;style.content_margin_right=8;style.content_margin_top=76
  button.add_theme_stylebox_override(state,style)
 var icon=button.get_node_or_null("ItemArtwork")
 if icon!=null:
  for connection in button.resized.get_connections(): button.resized.disconnect(connection.callable)
  icon.scale=Vector2.ONE
  button.resized.connect(func(): icon.position=Vector2(button.size.x/2,39))
  icon.position=Vector2(70,39)
static func arrange(f,column) -> void:
 if not is_instance_valid(column): return
 for child in column.get_children():
  if child is ScrollContainer:
   for inner in child.get_children():
    if inner is VBoxContainer: arrange(f,inner)
 var goods:Array=[]
 for child in column.get_children():
  if child is Button and child.has_meta("item_art"): goods.append(child)
 if goods.size()<2: return
 var index:int=goods[0].get_index()
 var g:GridContainer
 if column.get_parent() is ScrollContainer:
  g=GridContainer.new();g.columns=maxi(2,int((f.get_viewport_rect().size.x-100)/155));g.size_flags_horizontal=Control.SIZE_EXPAND_FILL;column.add_child(g)
 else: g=grid(f,column)
 column.move_child(g if g.get_parent()==column else g.get_parent(),index)
 for button in goods:
  button.reparent(g);tile(button)
