extends SceneTree
func _initialize():call_deferred("run")
func run():
 root.size=Vector2i(1311,603)
 var f=load("res://Main.tscn").instantiate();root.add_child(f);await process_frame
 f.set_physics_process(false);f.choose_character("boy");f.close_dialogue();f.clock_minutes=780
 f.friendship.Seira=80;f.interior_progress.story={"intro":true}
 var R=load("res://Relationships.gd")
 var overlay=CanvasLayer.new();overlay.layer=100;root.add_child(overlay)
 var label=Label.new();label.position=Vector2(15,115);label.add_theme_font_size_override("font_size",19);label.add_theme_color_override("font_color",Color.WHITE);label.add_theme_color_override("font_shadow_color",Color.BLACK);label.add_theme_constant_override("shadow_offset_x",2);label.add_theme_constant_override("shadow_offset_y",2);overlay.add_child(label)
 var number=18
 for occasion in ["Tea","Beach walk","Shrine garden","Wedding"]:
  label.text="REVIEW PHOTO %02d | %s" % [number,occasion.to_upper()];number+=1
  f.close_dialogue();f.day+=7
  while f.is_rainy_day():f.day+=1
  if occasion=="Wedding":
   var s=R.state(f,"Seira");s.status="engaged";s.chapter=3;s.affection=90;R.commit(f,"Seira","married")
  else:R.date(f,"Seira",occasion)
  await create_timer(.7).timeout;await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png(OS.get_cmdline_user_args()[0]+"/moment-"+occasion.to_snake_case()+".png")
 f.close_dialogue()
 var places=f.get_node("VillagePlaces")
 f.travel_to("town",f.town.G.project(places.PLACES[0][1]),false)
 f.player.position=places.point(places.PLACES[0])+Vector2(0,20);places.interact()
 label.text="REVIEW PHOTO 22 | LIBRARY BENCH"
 await create_timer(.7).timeout;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(OS.get_cmdline_user_args()[0]+"/moment-bench.png")
 f.close_dialogue();f.travel_to("farm",Vector2(1780,400),false)
 var friends=f.get_node("NatureFriends");var s=friends.state(f);s.friendship["Elder Moss"]=25;s.garden=true;s.keepsakes["Elder Moss"]=friends.KEEPSAKES[0]
 label.text="REVIEW PHOTO 23 | WELCOMING GARDEN"
 await create_timer(.7).timeout;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(OS.get_cmdline_user_args()[0]+"/moment-garden.png")
 load("res://FarmAutomation.gd").state(f).tractor=true;f.player.position=Vector2(2150,480)
 label.text="REVIEW PHOTO 24 | FARM EQUIPMENT"
 await create_timer(.7).timeout;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(OS.get_cmdline_user_args()[0]+"/moment-tractor.png")
 print("PASS: staged relationship scene screenshots captured");quit()
