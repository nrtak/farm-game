extends RefCounted
# Adjacent regions share physics coordinates, projection and camera. Crossing a
# seam changes interaction ownership only, never player or camera position.
const PAIR=["mountain","tea"]
static func connected(area:String,other:String)->bool:return area in PAIR and other in PAIR
static func corridor(area:String,p:Vector2)->bool:
 return (area=="mountain" and p.x>=1450 and p.x<=1640 and absf(p.y-900)<78) or (area=="tea" and p.x>=-40 and p.x<=130 and absf(p.y-675)<78)
static func cross(f)->bool:
 if f.location not in PAIR or f.inside_house:return false
 var local=f.player.position-f.REGION_ORIGINS[f.location]
 var target=""
 if f.location=="mountain" and local.x>=1600 and absf(local.y-900)<78:target="tea"
 if f.location=="tea" and local.x<0 and absf(local.y-675)<78:target="mountain"
 if target.is_empty():return false
 f.location=target
 load("res://DailyErrands.gd").visit(f,target)
 f.perspective.cancel_outdoor_pan()
 f.refresh_hud();f.save_game(false)
 return true
