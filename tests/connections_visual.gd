extends SceneTree
func _initialize():call_deferred("run")
func run():
 root.size=Vector2i(1311,603)
 var f=load("res://Main.tscn").instantiate();root.add_child(f);await process_frame
 f.set_physics_process(false);f.choose_character("boy");f.close_dialogue();f.clock_minutes=780
 var overlay=CanvasLayer.new();overlay.layer=100;root.add_child(overlay)
 var label=Label.new();label.position=Vector2(15,505);label.add_theme_font_size_override("font_size",18);overlay.add_child(label)
 var cases=[["farm",Vector2(1485,145),"town-farm"],["mountain",Vector2(800,1195),"town-highlands"],["historic",Vector2(1440,1195),"town-shrine"],["harbor",Vector2(1595,585),"town-harbor"],["mountain",Vector2(1595,900),"highlands-tea"]]
 for i in range(cases.size()):
  var c=cases[i];f.travel_to(c[0],c[1],false);f.toast_time=0
  label.text="REVIEW PHOTO %02d | CONTINUOUS %s"%[25+i,c[2].to_upper()]
  await create_timer(.5).timeout;await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png(OS.get_cmdline_user_args()[0]+"/connection-"+c[2]+".png")
 print("PASS: all five continuous connections captured");quit()
