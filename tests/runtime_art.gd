extends SceneTree
const Habitat=preload("res://MapHabitat.gd")
const Art=preload("res://RuntimeArt.gd")
func _initialize(): call_deferred("run")
func run():
 assert(Art.readable_image(null)==null)
 var gpu=PlaceholderTexture2D.new()
 gpu.size=Vector2(128,128)
 assert(Art.readable_image(gpu)==null,"Non-readable GPU artwork must safely return null")
 var npc=preload("res://Npc.gd").new()
 npc.prepare_walk_geometry("unavailable",gpu)
 assert(npc.regions.size()==16,"GPU-only sprites use cell geometry without pixel access")
 npc.free()
 var missing=preload("res://Npc.gd").new()
 missing.setup("missing",null)
 missing.show_frame(0,1)
 missing.free()
 var sources={"farm":"farm-environment-v10-wide.png","town":"map-town-open-v2.png","tea":"map-tea-open-v2.png","mountain":"map-mountain-open-v2.png","harbor":"map-harbor-open-v2.png","historic":"map-historic-approved-v1.png"}
 for kind in sources:
  var texture:Texture2D=load("res://assets/"+sources[kind])
  var image=Art.readable_image(texture)
  assert(image!=null)
  for y in range(17):
   for x in range(23):
    var uv=Vector2(x/22.0,y/16.0)
    var c=image.get_pixel(clampi(int(uv.x*image.get_width()),0,image.get_width()-1),clampi(int(uv.y*image.get_height()),0,image.get_height()-1))
    assert(Habitat.sample(kind,uv*Vector2(1600,1200),Vector2(1600,1200),"path")== (c.r>0.55 and c.g>0.45 and c.r>c.g*0.97),"Path classifications match artwork")
    assert(Habitat.sample(kind,uv*Vector2(1600,1200),Vector2(1600,1200),"grass")== (c.r>0.4 and c.g>0.52 and c.g>c.r*1.12 and c.g>c.b*1.2),"Wildlife classifications match artwork")
 assert(not Habitat.sample("missing",Vector2.ZERO,Vector2.ONE,"path"))
 print("PASS: unavailable GPU image/null artwork handled; precomputed paths and wildlife match all six maps")
 quit()
