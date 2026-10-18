extends RefCounted
# Substantial timber rails on capped stone footings. Visual only; callers retain their gate gaps.
static func paint(canvas:CanvasItem,a:Vector2,b:Vector2,rise:Vector2):
 var spans=maxi(1,ceili(a.distance_to(b)/55.0))
 for level in [.30,.70]:
  canvas.draw_line(a+rise*level,b+rise*level,Color("644d36"),9,true)
  canvas.draw_line(a+rise*level,b+rise*level,Color("b18a56"),6,true)
  canvas.draw_line(a+rise*level+rise.normalized()*2,b+rise*level+rise.normalized()*2,Color("d9ba82"),1.5,true)
 for i in range(spans+1):
  var p=a.lerp(b,float(i)/spans)
  canvas.draw_line(p,p+rise*.28,Color("655f50"),17,true)
  canvas.draw_line(p+rise*.04,p+rise*.30,Color("b9b09a"),13,true)
  canvas.draw_line(p+rise*.25,p+rise,Color("6e5135"),12,true)
  canvas.draw_line(p+rise*.27,p+rise,Color("ac8451"),8,true)
  canvas.draw_circle(p+rise,7,Color("d1bd93"))
  for level in [.30,.70]:canvas.draw_circle(p+rise*level,1.7,Color("514b40"))
