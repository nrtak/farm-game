extends RefCounted
# Shared, world-anchored ground tones. Decorative only: routes and collisions stay unchanged.
static var tones:Texture2D
static var soil_tones:Texture2D
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
  var noise=FastNoiseLite.new();noise.seed=813;noise.frequency=.055;noise.fractal_octaves=4
  var source=noise.get_seamless_image(128,128)
  var image=Image.create(128,128,false,Image.FORMAT_RGBA8)
  var dark=Color("8b6341");var brown=Color("b58b5b");var sand=Color("ddc498");var light=Color("eddbb5")
  for y in range(128):
   for x in range(128):
    var n=clampf((source.get_pixel(x,y).r-.27)/.46,0,1)
    var color=dark.lerp(brown,n/.33) if n<.33 else (brown.lerp(sand,(n-.33)/.34) if n<.67 else sand.lerp(light,(n-.67)/.33))
    image.set_pixel(x,y,color.lerp(Color("c9ad7b"),.42))
  soil_tones=ImageTexture.create_from_image(image)
 return soil_tones
static func rounded(poly:PackedVector2Array) -> PackedVector2Array:
 var result=poly
 for iteration in range(2):
  var next=PackedVector2Array()
  for i in range(result.size()):
   var a=result[i];var b=result[(i+1)%result.size()]
   var amount=minf(.25,30.0/maxf(1,a.distance_to(b)))
   next.append(a.lerp(b,amount));next.append(a.lerp(b,1-amount))
  result=next
 return result
static func dirt(canvas:CanvasItem,poly:PackedVector2Array,origin:Vector2=Vector2.ZERO):
 var edge=poly.duplicate();edge.append(poly[0])
 canvas.draw_polyline(edge,Color(.63,.57,.32,.12),24,true)
 canvas.draw_polyline(edge,Color(.73,.65,.40,.18),12,true)
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
    canvas.draw_circle(p,radius,Color(.78,.69,.45,.36))
 var uv=PackedVector2Array()
 for p in poly:uv.append((p+origin)/460.0)
 canvas.draw_polygon(poly,PackedColorArray([Color.WHITE]),uv,soil_texture())
 # Broken warm-brown banks, rather than a uniform outline around the path.
 for i in range(poly.size()):
  var a=poly[i];var b=poly[(i+1)%poly.size()]
  var midpoint=(a+b)*.5+origin
  var weight=sin(midpoint.x*.024+midpoint.y*.019)
  if weight>.15:
   canvas.draw_line(a,b,Color(.43,.29,.16,.13+weight*.13),3+weight*5,true)
