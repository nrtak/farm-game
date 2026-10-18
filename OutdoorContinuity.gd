extends RefCounted
const AREAS=["farm","town","mountain","tea","harbor","historic"]
static func connected(area:String,other:String)->bool:return area in AREAS and other in AREAS
static func corridor(area:String,p:Vector2)->bool:
 match area:
  "town":return (p.y>230 and p.y<370 and (absf(p.x-1300)<65 or absf(p.x-360)<65)) or (p.x>120 and p.x<270 and absf(p.y-910)<65) or (p.y>1490 and p.y<1630 and absf(p.x-1300)<65)
  "mountain":return (p.x>=1450 and p.x<=1640 and absf(p.y-900)<78) or (p.y>1050 and p.y<1240 and absf(p.x-800)<78)
  "tea":return p.x>=-40 and p.x<=130 and absf(p.y-675)<78
  "harbor":return p.x>1450 and p.x<1640 and absf(p.y-585)<78
  "historic":return p.y>1050 and p.y<1240 and absf(p.x-1440)<78
 return false
static func cross(f)->bool:
 if f.location not in AREAS or f.inside_house:return false
 var p=f.player.position-f.polish.area_origin()
 var target=""
 match f.location:
  "farm":
   if p.y<140 and absf(p.x-1485)<78:target="town"
  "town":
   p=f.town.G.unproject(p)
   if p.y<275 and absf(p.x-1300)<65:target="mountain"
   elif p.y<275 and absf(p.x-360)<65:target="historic"
   elif p.x<165 and absf(p.y-910)<65:target="harbor"
   elif p.y>=1585 and absf(p.x-1300)<65:target="farm"
  "mountain":
   if p.x>=1600 and absf(p.y-900)<78:target="tea"
   elif p.y>=1200 and absf(p.x-800)<78:target="town"
  "tea":
   if p.x<0 and absf(p.y-675)<78:target="mountain"
  "harbor":
   if p.x>=1600 and absf(p.y-585)<78:target="town"
  "historic":
   if p.y>=1200 and absf(p.x-1440)<78:target="town"
 if target.is_empty():return false
 if f.festival_active:f.end_festival()
 f.location=target
 f.player.collision_mask=1 if target=="farm" else (4 if target=="town" else 16)
 load("res://DailyErrands.gd").visit(f,target)
 f.perspective.cancel_outdoor_pan()
 f.refresh_hud();f.save_game(false)
 f.polish.resume_crossing()
 return true

static func route(f,target:Vector2)->Array:
 if f.polish.area_node().is_walkable(target-f.polish.area_origin()):return []
 var origins={"farm":Vector2.ZERO,"town":f.TOWN_ORIGIN}
 for area in ["mountain","tea","harbor","historic"]:origins[area]=f.REGION_ORIGINS[area]
 var destination=""
 for area in AREAS:
  var node=f if area=="farm" else (f.town if area=="town" else f.regions[area])
  if node.is_walkable(target-origins[area]):destination=area;break
 if destination.is_empty() or destination==f.location:return []
 var graph={"farm":["town"],"town":["farm","mountain","historic","harbor"],"mountain":["town","tea"],"tea":["mountain"],"historic":["town"],"harbor":["town"]}
 var queue=[[f.location]]
 var seen=[f.location]
 var next=""
 while not queue.is_empty():
  var chain=queue.pop_front()
  if chain[-1]==destination:next=chain[1];break
  for area in graph[chain[-1]]:
   if area not in seen:seen.append(area);queue.append(chain+[area])
 if next.is_empty():return []
 var points={"farm-town":[Vector2(1485,180),Vector2(1485,120)],"mountain-town":[Vector2(800,1160),Vector2(800,1220)],"mountain-tea":[Vector2(1560,900),Vector2(1620,900)],"tea-mountain":[Vector2(40,675),Vector2(-20,675)],"historic-town":[Vector2(1440,1160),Vector2(1440,1220)],"harbor-town":[Vector2(1560,585),Vector2(1620,585)]}
 if f.location=="town":
  var raw={"farm":[Vector2(1300,1545),Vector2(1300,1600)],"mountain":[Vector2(1300,315),Vector2(1300,260)],"historic":[Vector2(360,315),Vector2(360,260)],"harbor":[Vector2(205,910),Vector2(150,910)]}[next]
  return [f.TOWN_ORIGIN+f.town.G.project(raw[0]),f.TOWN_ORIGIN+f.town.G.project(raw[1])]
 var pair=points[f.location+"-"+next]
 return [origins[f.location]+pair[0],origins[f.location]+pair[1]]
