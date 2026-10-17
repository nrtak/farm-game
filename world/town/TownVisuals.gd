extends Node2D
const G=preload("res://world/town/TownGeometry.gd")
const ART={
 "Town Hall":["civic",Rect2(0,0,632,662),Vector2(435,598),false],
 "Library":["civic",Rect2(640,0,614,675),Vector2(342,620),false],
 "Police":["civic",Rect2(0,690,630,564),Vector2(430,470),false],
 "Fire":["civic",Rect2(640,640,614,614),Vector2(163,510),false],
 "Hospital":["market",Rect2(0,0,627,625),Vector2(448,560),false],
 "Store":["market",Rect2(627,0,627,625),Vector2(430,530),false],
 "Cafe":["cafe",Rect2(0,0,1254,1254),Vector2(445,1050),false],
 "Inn":["market",Rect2(627,635,627,619),Vector2(396,544),false],
 "Restaurant":["trades",Rect2(0,0,627,625),Vector2(400,582),false],
 "Carpenter":["trades",Rect2(627,0,627,625),Vector2(370,562),false],
 "Blacksmith":["trades",Rect2(0,635,627,619),Vector2(213,515),false],
 "Ranch":["trades",Rect2(627,635,627,619),Vector2(215,520),false],
 "Vet":["garden",Rect2(0,0,682,666),Vector2(475,607),false]}
var art_cache={}
var building_sprites:Array[Sprite2D]=[]
var town_layer:Node2D
func _ready():
 town_layer=self
 add_child(preload("res://world/town/TownGround.gd").new())
 for b in G.layout().buildings:place_building(b)
 place_decoration("garden",Rect2(690,0,564,625),Vector2(282,578),Vector2(680,650),90)
 place_decoration("garden",Rect2(610,640,644,614),Vector2(322,550),Vector2(360,395),140)
 for e in G.EXITS:place_sign(e[0],e[1]+Vector2(38,0))
 place_sign("Festival Square",Vector2(850,625))
 place_sign("Events",Vector2(930,710))
func follow_player(point:Vector2):
 for sprite in building_sprites:
  var bounds=Rect2(sprite.position,sprite.texture.get_size()*sprite.scale)
  sprite.modulate.a=.3 if bounds.intersects(Rect2(point-Vector2(18,65),Vector2(36,65))) and sprite.z_index>int(point.y/10) else 1.0
func atlas(name:String,region:Rect2)->Texture2D:
 if not art_cache.has(name):art_cache[name]=load("res://world/town/"+name+"-atlas.png")
 var a=AtlasTexture.new();a.atlas=art_cache[name];a.region=region;return a
func place_building(b:Array):
 var a=ART[b[0]];var sprite=Sprite2D.new();sprite.texture=atlas(a[0],a[1]);sprite.centered=false
 if b[0] in ["Library","Vet","Fire"]:
  var material=ShaderMaterial.new();material.shader=preload("res://world/town/AtlasBounds.gdshader")
  material.set_shader_parameter("clipping_shape",{"Library":1,"Vet":2,"Fire":3}[b[0]]);sprite.material=material
 var scale_factor=225.0/a[1].size.x
 var anchor:Vector2=a[2]
 if a[3]:sprite.flip_h=true;anchor.x=a[1].size.x-anchor.x
 sprite.scale=Vector2.ONE*scale_factor;sprite.position=G.project(G.door(b))-anchor*scale_factor
 sprite.z_index=int(G.project(G.door(b)).y/10)-1
 town_layer.add_child(sprite);building_sprites.append(sprite)
func place_decoration(sheet:String,region:Rect2,anchor:Vector2,point:Vector2,width:float):
 var sprite=Sprite2D.new();sprite.texture=atlas(sheet,region);sprite.centered=false;sprite.scale=Vector2.ONE*(width/region.size.x)
 sprite.position=G.project(point)-anchor*sprite.scale;sprite.z_index=int(G.project(point).y/10);town_layer.add_child(sprite)
func place_sign(text:String,point:Vector2):
 var sign=Label.new();sign.text=text;sign.position=G.project(point)-Vector2(45,35);sign.z_index=int(G.project(point).y/10)
 sign.add_theme_font_size_override("font_size",14);sign.add_theme_color_override("font_color",Color("473827"))
 var style=StyleBoxFlat.new();style.bg_color=Color("f1dfb3");style.border_color=Color("8a6846");style.set_border_width_all(2);style.content_margin_left=7;style.content_margin_right=7;style.content_margin_top=4;style.content_margin_bottom=4
 sign.add_theme_stylebox_override("normal",style);town_layer.add_child(sign)

