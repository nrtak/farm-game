extends RefCounted
static func find(f) -> int:
 if f.location!="farm" or f.inside_house: return -1
 var desired:int=[0,1,3][clampi(f.selected_tool,0,2)]
 var best:=-1;var fallback:=-1;var best_distance:=78.0;var fallback_distance:=78.0
 for i in range(f.plots.size()):
  var distance:float=f.player.position.distance_to(f.plots[i].position)
  if distance<fallback_distance: fallback=i;fallback_distance=distance
  if int(f.plots[i].stage)==desired and distance<best_distance: best=i;best_distance=distance
 return best if best>=0 else fallback
