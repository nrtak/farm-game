extends RefCounted
# Shared, world-anchored ground tones. Decorative only: routes and collisions stay unchanged.
static var tones:Texture2D
static var soil_tones:Texture2D
static var water_tones:Texture2D
static func water_texture()->Texture2D:
 if water_tones==null:
  var image=Image.create(128,128,false,Image.FORMAT_RGBA8)
  for y in range(128):
   for x in range(128):
    var u=TAU*x/128.0;var v=TAU*y/128.0
    var broad=.5+.20*sin(u+sin(v))+.16*cos(v*2+sin(u))
    var ripple=pow(maxf(0,sin(u*7+sin(v*5))*cos(v*6+sin(u*4))),6)*.12
    image.set_pixel(x,y,Color("397f94").lerp(Color("80bfbe"),clampf(broad+ripple,0,1)))
  water_tones=ImageTexture.create_from_image(image)
 return water_tones
static func water(canvas:CanvasItem,poly:PackedVector2Array,origin:Vector2=Vector2.ZERO):
 var uv=PackedVector2Array()
 for p in poly:uv.append((p+origin)/380.0)
 canvas.draw_polygon(poly,PackedColorArray([Color.WHITE]),uv,water_texture())
static func texture() -> Texture2D:
 if tones==null:
  var noise=FastNoiseLite.new();noise.seed=307;noise.frequency=.035;noise.fractal_octaves=3
  var source=noise.get_seamless_image(128,128)
  var image=Image.create(128,128,false,Image.FORMAT_RGBA8)
  for y in range(128):
   for x in range(128):
    var n=source.get_pixel(x,y).r
    image.set_pixel(x,y,Color(.22,.32,.12,.24*(.5-n)*2) if n<.5 else Color(.87,.80,.43,.20*(n-.5)*2))
  tones=ImageTexture.create_from_image(image)
 return tones
static func shade(canvas:CanvasItem,polygon:PackedVector2Array,origin:Vector2=Vector2.ZERO):
 var uv=PackedVector2Array()
 for p in polygon:uv.append((p+origin)/720.0)
 canvas.draw_polygon(polygon,PackedColorArray([Color.WHITE]),uv,texture())
static func soil_texture() -> Texture2D:
 if soil_tones==null:
  var image=Image.create(128,128,false,Image.FORMAT_RGBA8)
  # Broad periodic gradients avoid high-frequency patches and visible tiling seams.
  var shade=Color("c4aa7e");var light=Color("ddc79f")
  for y in range(128):
   for x in range(128):
    var u=TAU*float(x)/128.0;var v=TAU*float(y)/128.0
    var blend=.5+.22*sin(u+.5*sin(v))+.16*cos(v+.4*cos(u))+.08*sin(u+v)
    image.set_pixel(x,y,shade.lerp(light,clampf(blend,0,1)))
  soil_tones=ImageTexture.create_from_image(image)
 return soil_tones
static func rounded(poly:PackedVector2Array) -> PackedVector2Array:
 var result=poly
 for iteration in range(3):
  var next=PackedVector2Array()
  for i in range(result.size()):
   var a=result[i];var b=result[(i+1)%result.size()]
   var amount=minf(.25,48.0/maxf(1,a.distance_to(b)))
   next.append(a.lerp(b,amount));next.append(a.lerp(b,1-amount))
  result=next
 return result
static func dirt(canvas:CanvasItem,poly:PackedVector2Array,origin:Vector2=Vector2.ZERO):
 var edge=poly.duplicate();edge.append(poly[0])
 canvas.draw_polyline(edge,Color(.63,.57,.32,.07),24,true)
 canvas.draw_polyline(edge,Color(.73,.65,.40,.10),12,true)
 # Small worn shoulders break up the outline without turning the walking lane into a winding path.
 for i in range(poly.size()):
  var a=poly[i];var b=poly[(i+1)%poly.size()]
  var count=int(a.distance_to(b)/24)
  for j in range(count):
   var p=a.lerp(b,float(j)/maxi(1,count))
   var wave=sin((p.x+origin.x)*.037+(p.y+origin.y)*.051)
   if wave>.25:
    var radius=4+wave*8
    canvas.draw_circle(p,radius+5,Color(.73,.65,.40,.12))
    canvas.draw_circle(p,radius,Color(.78,.69,.45,.18))
 var uv=PackedVector2Array()
 for p in poly:uv.append((p+origin)/900.0)
 canvas.draw_polygon(poly,PackedColorArray([Color.WHITE]),uv,soil_texture())
 # Scattered wear is clipped to the road and anchored in world coordinates.
 var bounds=Rect2(poly[0],Vector2.ZERO)
 for point in poly:bounds=bounds.expand(point)
 for x in range(int(bounds.position.x),int(bounds.end.x),23):
  for y in range(int(bounds.position.y),int(bounds.end.y),25):
   var seed_value=sin((x+origin.x)*12.9898+(y+origin.y)*78.233)*43758.5453
   var t=seed_value-floor(seed_value)
   var p=Vector2(x+t*20,y+sin(seed_value)*10)
   var end=p+Vector2(7+t*13,2+t*3)
   if not Geometry2D.is_point_in_polygon(p,poly) or not Geometry2D.is_point_in_polygon(end,poly):continue
   canvas.draw_line(p,end,Color(.49,.37,.23,.12+t*.10),1.6,true)
   canvas.draw_line(p+Vector2(0,2),end+Vector2(0,2),Color(.96,.85,.64,.23),1,true)
   if t>.70:
    canvas.draw_circle(p,1.6+t,Color(.53,.45,.32,.34))
    canvas.draw_circle(p+Vector2(-.5,-1),1.1,Color(.87,.78,.58,.55))


# Low ground cover is painted before paths, water, and cultivated beds. It never
# creates collision or covers crops. Broad clusters leave deliberate quiet areas.
static func meadow(canvas:CanvasItem,bounds:Rect2,origin:Vector2=Vector2.ZERO):
 var rng=RandomNumberGenerator.new();rng.seed=4187
 for i in range(int(bounds.get_area()/2500)):
  var p=bounds.position+Vector2(rng.randf()*bounds.size.x,rng.randf()*bounds.size.y)
  var world=p+origin
  var patch=sin(world.x*.008+sin(world.y*.005))*cos(world.y*.009)
  if patch<.20:continue
  var radius=rng.randf_range(9,24)
  canvas.draw_circle(p,radius,Color(.31,.43,.17,.065))
  for blade in range(3):
   var root=p+Vector2(rng.randf_range(-12,12),rng.randf_range(-8,8))
   canvas.draw_line(root,root+Vector2(-3,-6),Color(.32,.46,.20,.48),1.5,true)
   canvas.draw_line(root,root+Vector2(2,-9),Color(.66,.74,.36,.58),1.5,true)
  if patch>.58:
   for bloom in range(3):
    var flower=p+Vector2(rng.randf_range(-15,15),rng.randf_range(-9,9))
    canvas.draw_circle(flower,2.6,Color("eee1b0") if i%3 else Color("d4b2c1"))
    canvas.draw_circle(flower,1,Color("bba05c"))
  elif i%9==0:
   canvas.draw_line(p,p+Vector2(9,3),Color(.43,.40,.27,.40),3,true)
   canvas.draw_line(p+Vector2(1,-1),p+Vector2(7,1),Color(.77,.74,.52,.65),1,true)
