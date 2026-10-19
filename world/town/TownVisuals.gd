extends Node2D
const G=preload("res://world/town/TownDisplayGeometry.gd")
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
 var basis=Transform2D(Vector2(.558,-.207),Vector2(.378,.315),Vector2.ZERO)
 transform=basis.affine_inverse()*Transform2D(0,-G.ORIGIN)
 town_layer=self
 z_index=1000+int((basis*get_parent().position-G.ORIGIN).y/10)
 add_child(preload("res://world/town/TownGround.gd").new())
 for b in G.layout().buildings:
  place_building(b)
  plant_frontage(b)
  fill_yard(b)
 place_decoration("garden",Rect2(690,0,564,625),Vector2(282,578),Vector2(680,650),90)
 place_decoration("garden",Rect2(610,640,644,614),Vector2(322,550),Vector2(360,300),190)
 for e in G.EXITS:place_sign(e[0],e[1]+Vector2(38,0))
 place_sign("Festival Square",Vector2(850,625))
 place_sign("Events",Vector2(930,710))
 for segment in [[Vector2(1900,610),Vector2(1900,780)],[Vector2(1900,890),Vector2(1900,1060)],[Vector2(1900,1170),Vector2(1900,1340)]]:add_garden(segment[0],segment[1])
 var texture=load("res://world/angled/village-expansion-v1.png");var cell=texture.get_size()/2.0
 var playground=Sprite2D.new();playground.texture=load("res://world/angled/playground-open-v2.png");playground.centered=false;playground.scale=Vector2.ONE*(195.0/playground.texture.get_width())
 var foot=G.project(Vector2(900,350));playground.position=foot-Vector2(97,145);playground.z_index=int(foot.y/10)-1;add_child(playground)

func follow_player(point:Vector2):
 var basis=Transform2D(Vector2(.558,-.207),Vector2(.378,.315),Vector2.ZERO)
 point=basis*point+G.ORIGIN
 for sprite in building_sprites:
  var bounds=Rect2(sprite.position,sprite.texture.get_size()*sprite.scale)
  var obscures_actor=bounds.intersects(Rect2(point-Vector2(18,65),Vector2(36,65))) and sprite.z_index>int(point.y/10)
  # A nearby conversation partner deserves the same roof fade as the farmer.
  for npc in get_parent().npcs:
   var foot=basis*npc.position+G.ORIGIN
   if not npc.visible or foot.distance_to(point)>150:continue
   if sprite.z_index>int(foot.y/10) and bounds.intersects(Rect2(foot-Vector2(18,65),Vector2(36,65))):obscures_actor=true
  sprite.modulate.a=.3 if obscures_actor else 1.0
func atlas(name:String,region:Rect2)->Texture2D:
 if not art_cache.has(name):art_cache[name]=load("res://world/town/"+name+"-atlas.png")
 var a=AtlasTexture.new();a.atlas=art_cache[name];a.region=region;return a
func place_building(b:Array):
 if b[0]=="School":
  var texture=load("res://world/angled/village-expansion-v1.png")
  var cell=texture.get_size()/2.0
  var a=AtlasTexture.new();a.atlas=texture;a.region=Rect2(0,0,665,620)
  var sprite=Sprite2D.new();sprite.texture=a;sprite.centered=false
  sprite.scale=Vector2.ONE*(260.0/cell.x)
  var foot=G.project(G.door(b));sprite.position=foot-Vector2(130,230)
  sprite.z_index=int(foot.y/10)-1;town_layer.add_child(sprite);building_sprites.append(sprite)
  return
 if b[5] in ["N","E"] and b[0] not in ["Police","Carpenter"]:
  var names=["Inn","Restaurant","Store","Cafe","Ranch","Vet","Police","Carpenter"]
  var index=names.find(b[0])
  var texture=load("res://world/town/perimeter-shops-atlas.png")
  var cell=texture.get_size()/Vector2(4,2)
  var sprite=Sprite2D.new();sprite.texture=atlas("perimeter-shops",Rect2(Vector2(index%4,index/4)*cell,cell));sprite.centered=false
  var width=230.0
  sprite.scale=Vector2.ONE*(width/cell.x)
  var center=G.project(Vector2(b[1]+b[3]/2.0,b[2]+b[4]/2.0))
  sprite.position=center-Vector2(width/2,width*.72)
  sprite.z_index=int(center.y/10)
  town_layer.add_child(sprite);building_sprites.append(sprite)
  var plaque=Label.new();plaque.text=b[0];plaque.position=Vector2(cell.x*.22,cell.y*.60)
  plaque.add_theme_font_size_override("font_size",25)
  plaque.add_theme_color_override("font_color",Color("493523"))
  var board=StyleBoxFlat.new();board.bg_color=Color("e8ce99");board.border_color=Color("795331");board.set_border_width_all(3);board.set_corner_radius_all(3)
  board.content_margin_left=8;board.content_margin_right=8;board.content_margin_top=3;board.content_margin_bottom=3
  plaque.add_theme_stylebox_override("normal",board);sprite.add_child(plaque)
  return
 var a=ART[b[0]];var sprite=Sprite2D.new();sprite.texture=atlas(a[0],a[1]);sprite.centered=false
 if b[0] in ["Library","Vet","Fire"]:
  var material=ShaderMaterial.new();material.shader=preload("res://world/town/AtlasBounds.gdshader")
  material.set_shader_parameter("clipping_shape",{"Library":1,"Vet":2,"Fire":3}[b[0]]);sprite.material=material
 var scale_factor=(300.0 if b[5]=="W" else 250.0)/a[1].size.x
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
 var post=Line2D.new();post.points=PackedVector2Array([Vector2(0,-8),Vector2(0,12)]);post.width=5;post.default_color=Color("795638");post.position=G.project(point);post.z_index=sign.z_index;town_layer.add_child(post)
 sign.add_theme_stylebox_override("normal",style);town_layer.add_child(sign)
 return sign


func plant_frontage(b:Array):
 var r=Rect2(b[1]+4,b[2]+4,b[3]-8,b[4]-8)
 var corners=[r.position,Vector2(r.end.x,r.position.y),r.end,Vector2(r.position.x,r.end.y)]
 for i in range(4):
  var start:Vector2=corners[i];var end:Vector2=corners[(i+1)%4]
  # Keep a generous opening on the actual entrance face.
  var front=(i==2 and b[5]=="S") or (i==3 and b[5]=="W") or (i==0 and b[5]=="N") or (i==1 and b[5]=="E")
  if front:
   if start.distance_to(end)<140:continue
   add_garden(start,start.lerp(end,.22));add_garden(start.lerp(end,.78),end)
  else:add_garden(start,end)
 # A tree behind each block softens the non-entry side without hiding its street.
 var p=Vector2(r.position.x+25,r.position.y+18)
 place_decoration("garden",Rect2(0,655,600,599),Vector2(300,575),p,65)
func add_garden(a:Vector2,b:Vector2):
 var start=G.project(a);var end=G.project(b)
 var count=maxi(1,int(ceil(start.distance_to(end)/90)))
 var texture=preload("res://world/angled/CoastalGardenArt.gd").texture(0 if (end.x-start.x)*(end.y-start.y)<0 else 1)
 for i in range(count):
  var foot=start.lerp(end,(i+.5)/count)
  var sprite=Sprite2D.new();sprite.texture=texture;sprite.centered=false
  var width=start.distance_to(end)/count+10
  sprite.scale=Vector2(1,1.16)*width/texture.get_width()
  sprite.position=foot-Vector2(width*.5,texture.get_height()*sprite.scale.y*.82)
  sprite.z_index=int(foot.y/10);town_layer.add_child(sprite)

func yard_sprite(texture:Texture2D,point:Vector2,width:float):
 var sprite=Sprite2D.new();sprite.texture=texture;sprite.centered=false
 sprite.scale=Vector2.ONE*width/texture.get_width()
 var foot=G.project(point)
 sprite.position=foot-Vector2(width*.5,texture.get_height()*sprite.scale.y*.94)
 sprite.z_index=int(foot.y/10);town_layer.add_child(sprite)
func fill_yard(b:Array):
 var r=Rect2(b[1]+14,b[2]+14,b[3]-28,b[4]-28)
 var corners=[r.position,Vector2(r.end.x,r.position.y),r.end,Vector2(r.position.x,r.end.y)]
 var front={"N":0,"E":1,"S":2,"W":3}[b[5]]
 # Planters belong inside the existing fenced footprint, not in the public street.
 for edge in range(4):
  if edge==front:continue
  for fraction in [.25,.75]:
   yard_sprite(preload("res://world/angled/CoastalGardenArt.gd").texture(2),corners[edge].lerp(corners[(edge+1)%4],fraction),32)
 var back=(front+2)%4
 var center=corners[back].lerp(corners[(back+1)%4],.5)
 var regions={"Carpenter":Rect2(655,325,325,295),"Blacksmith":Rect2(655,325,325,295),"Fire":Rect2(680,610,280,300),"Store":Rect2(330,320,320,290),"Restaurant":Rect2(330,320,320,290),"Cafe":Rect2(990,45,310,270),"Inn":Rect2(990,45,310,270)}
 if regions.has(b[0]):
  var art=AtlasTexture.new();art.atlas=load("res://world/angled/furniture.png");art.region=regions[b[0]]
  yard_sprite(art,center,48)
 else:yard_sprite(preload("res://world/angled/CoastalGardenArt.gd").texture(2),center,42)
