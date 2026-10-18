extends Node2D
var farm
var body:Sprite2D
var original_visible:=true
func begin(f,foot:Vector2):
 farm=f;original_visible=f.farmer.visible
 f.update_walk(0,false,Vector2.DOWN)
 var region:Rect2=f.farmer.region_rect
 body=Sprite2D.new();body.texture=f.farmer.texture;body.region_enabled=true
 body.region_rect=Rect2(region.position,Vector2(region.size.x,region.size.y*.66))
 body.scale=Vector2.ONE*(43.0/body.region_rect.size.y)
 body.position=Vector2(0,-35);add_child(body)
 var basis=f.perspective.BASIS
 transform=basis.affine_inverse()*Transform2D(0,basis*foot)
 z_as_relative=false
 z_index=f.perspective.depth(foot)+1
 f.farmer.hide()
func finish():
 if is_instance_valid(farm):farm.farmer.visible=original_visible
 hide();queue_free()
func _draw():
 # Bent knees and dangling boots keep the pose attached to the bench seat.
 for x in [-7,7]:
  draw_line(Vector2(x,-15),Vector2(x,-6),Color("385367"),9)
  draw_line(Vector2(x,-6),Vector2(x+2,1),Color("2c4355"),7)
  draw_line(Vector2(x,2),Vector2(x+5,2),Color("634529"),7)
