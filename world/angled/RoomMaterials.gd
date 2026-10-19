extends RefCounted
# Material detail stays on the ground and walls; furniture collision is unchanged.
static func floor_detail(canvas:CanvasItem,room:String,r:Rect2):
 var rng=RandomNumberGenerator.new();rng.seed=217
 var stone=room in ["Mine","Blacksmith","Fire Station","Tea Processing Shed"]
 var tile=room in ["Clinic","Veterinarian","Restaurant","Café"]
 if stone or tile:
  var base=Color("686c65") if room=="Mine" else (Color("a9b3a4") if stone else Color("d4d5bc"))
  canvas.draw_rect(r,base.darkened(.18))
  for y in range(int(r.position.y),int(r.end.y),46):
   for x in range(int(r.position.x),int(r.end.x),72):
    var cell=Rect2(x+2,y+2,minf(68,r.end.x-x-2),minf(42,r.end.y-y-2))
    if cell.size.x<=0 or cell.size.y<=0:continue
    canvas.draw_rect(cell,base.lightened(rng.randf_range(-.09,.08)))
    canvas.draw_line(cell.position,Vector2(cell.end.x,cell.position.y),Color(1,1,.9,.13),1)
    if stone and rng.randf()<.27:
     canvas.draw_line(cell.position+Vector2(11,10),cell.position+Vector2(24,18),base.darkened(.24),1,true)
 else:
  var base=Color("ac875b") if room in ["Barn","Carpentry","Mountain Carpentry","Mountain Lodge","Hiro Cabin"] else Color("c0a078")
  canvas.draw_rect(r,base.darkened(.13))
  for y in range(int(r.position.y),int(r.end.y),32):
   var stagger=0 if int((y-r.position.y)/32)%2==0 else 86
   for x in range(int(r.position.x)-stagger,int(r.end.x),172):
    var board=Rect2(x+1,y+1,170,30).intersection(r)
    if not board.has_area():continue
    canvas.draw_rect(board,base.lightened(rng.randf_range(-.045,.06)))
    for grain in range(3):
     var a=board.position+Vector2(4,5+grain*8)
     canvas.draw_line(a,a+Vector2(maxf(1,board.size.x-12),rng.randf_range(-2,2)),Color(.40,.28,.15,.12),1,true)
    if board.size.x>22:
     for nail in [board.position+Vector2(5,5),board.end-Vector2(5,5)]:canvas.draw_circle(nail,1,Color(.31,.25,.16,.3))
 if room in ["Shrine Residence","Onsen Resort","Tea Farmhouse"]:
  for x in [195,650]:
   var mat=Rect2(x,355,245,270)
   canvas.draw_rect(mat,Color("a8ad75"));canvas.draw_rect(mat.grow(-5),Color("677c58"),false,5)
   for y in range(365,615,7):canvas.draw_line(Vector2(x+10,y),Vector2(x+235,y),Color(.84,.82,.57,.35),1)
 elif room in ["Home","Mountain Lodge","Hiro Cabin","Harbor Homes","Inn"]:
  var mat=Rect2(380,385,340,220)
  var tone=Color("8d665b") if room!="Harbor Homes" else Color("668e99")
  canvas.draw_rect(mat,tone);canvas.draw_rect(mat.grow(-9),Color("dbc591"),false,5)
  canvas.draw_rect(mat.grow(-21),Color("b8a477"),false,2)
 elif room=="Barn":
  for i in range(650):
   var p=Vector2(rng.randf_range(r.position.x+12,r.end.x-12),rng.randf_range(r.position.y+12,r.end.y-12))
   if absf(p.x-550)<100:continue
   canvas.draw_line(p,p+Vector2(rng.randf_range(4,12),rng.randf_range(-4,4)),Color("d4b874"),1.6,true)
 elif room in ["Carpentry","Mountain Carpentry"]:
  for i in range(100):
   var p=Vector2(rng.randf_range(160,330),rng.randf_range(400,660))
   canvas.draw_arc(p,3,0,PI,6,Color("d7b77e"),1,true)
 if room=="Fire Station":
  for x in [390,705]:canvas.draw_line(Vector2(x,370),Vector2(x,730),Color("d8c55a"),5,true)
 if room=="Onsen Resort":
  var bath=Rect2(790,425,175,210)
  canvas.draw_rect(bath,Color("8b9687"));canvas.draw_rect(bath.grow(-13),Color("659fa6"))
  canvas.draw_rect(bath.grow(-5),Color("c3c5a7"),false,5)
  for y in range(455,615,30):canvas.draw_line(Vector2(815,y),Vector2(940,y+4),Color(.80,.94,.86,.6),2,true)

static func wall_detail(canvas:CanvasItem,room:String,a:Vector2,b:Vector2,d:Vector2,rise:Vector2):
 var timber=room in ["Home","Barn","Carpentry","Mountain Carpentry","Mountain Lodge","Hiro Cabin","Harbor Homes","Onsen Resort"]
 var temple=room=="Shrine Residence"
 var mine=room=="Mine"
 var color=Color("aa8c64") if timber else (Color("eee4c6") if temple else Color("dae0cf"))
 if mine:color=Color("666f68")
 if room=="Blacksmith":color=Color("9b998a")
 for edge in [[a,b],[b,d]]:
  var left:Vector2=edge[0];var right:Vector2=edge[1]
  canvas.draw_colored_polygon(PackedVector2Array([left,right,right+rise,left+rise]),color)
  var length=left.distance_to(right);var direction=(right-left).normalized()
  for n in range(0,int(length),38 if timber else 75):
   var base=left+direction*n
   canvas.draw_line(base,base+rise,color.darkened(.18),2,true)
  for f in [.28,.56,.84]:
   if not timber:canvas.draw_line(left+rise*f,right+rise*f,color.darkened(.12),2,true)
  if timber or temple or mine:
   var beam=Color("775938") if not temple else Color("8a4b36")
   for f in [0.0,.5,1.0]:
    var base=left.lerp(right,f);canvas.draw_line(base,base+rise,beam,10,true)
   canvas.draw_line(left+rise*.93,right+rise*.93,beam,9,true)
  if room in ["Clinic","Veterinarian","Fire Station"]:
   canvas.draw_line(left+rise*.35,right+rise*.35,Color("a15e4d") if room=="Fire Station" else Color("6b9990"),10,true)
  if room in ["School","Restaurant","Café","Tea Farmhouse","Tea Processing Shed"]:
   var center=left.lerp(right,.5)+rise*.33
   var half=direction*(120 if room=="School" else 55)
   var top=rise*.48
   canvas.draw_colored_polygon(PackedVector2Array([center-half,center+half,center+half+top,center-half+top]),Color("527067"))
   canvas.draw_polyline(PackedVector2Array([center-half,center+half,center+half+top,center-half+top,center-half]),Color("96724b"),5,true)
   for n in range(3):
    var line_start=center-half*.8+top*(.25+n*.23)
    canvas.draw_line(line_start,line_start+half*(1.15-n*.15),Color("d9dfbb"),2,true)
  if room in ["Clinic","Veterinarian"]:
   var center=left.lerp(right,.5)+rise*.58
   canvas.draw_line(center-direction*18,center+direction*18,Color("a85f52"),9,true)
   canvas.draw_line(center-rise*.14,center+rise*.14,Color("a85f52"),9,true)
