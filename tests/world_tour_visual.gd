extends SceneTree
var f
var label:Label
var records:Array=[]
var output:String
func _initialize():call_deferred("run")
func capture(title:String):
 f.toast_time=0;f.refresh_hud();f.update_walk(0,false,Vector2.DOWN)
 label.text="WORLD TOUR %02d | %s"%[records.size()+1,title.to_upper()]
 await create_timer(.35).timeout
 await RenderingServer.frame_post_draw
 var file="tour-%02d.png"%[records.size()+1]
 assert(root.get_texture().get_image().save_png(output+"/"+file)==OK)
 records.append({"number":records.size()+1,"title":title,"file":file})
func outdoor(area:String,point:Vector2,title:String):
 f.close_dialogue();f.travel_to(area,point,false)
 await capture(title)
func run():
 output=OS.get_cmdline_user_args()[0];DirAccess.make_dir_recursive_absolute(output)
 root.size=Vector2i(1311,603)
 f=load("res://Main.tscn").instantiate();root.add_child(f);await process_frame
 f.set_physics_process(false);f.choose_character("boy");f.close_dialogue();f.clock_minutes=780;f.interior_progress.story={"intro":true}
 var overlay=CanvasLayer.new();overlay.layer=100;root.add_child(overlay)
 var panel=PanelContainer.new();panel.position=Vector2(12,480);overlay.add_child(panel)
 var style=StyleBoxFlat.new();style.bg_color=Color(.07,.12,.10,.9);style.content_margin_left=10;style.content_margin_right=10;style.content_margin_top=5;style.content_margin_bottom=5;panel.add_theme_stylebox_override("panel",style)
 label=Label.new();label.add_theme_font_size_override("font_size",16);panel.add_child(label)
 for c in [[Vector2(900,600),"Farmhouse approach"],[Vector2(1485,300),"Farm entrance lane"],[Vector2(1930,710),"Field and shipping chest"],[Vector2(2250,710),"Field and well"],[Vector2(2420,505),"Barn approach"],[Vector2(2540,605),"Pasture gate"],[Vector2(2200,1150),"Lower crop fields"],[Vector2(850,1200),"Farm garden lane"]]:await outdoor("farm",c[0],c[1])
 var g=f.town.G
 for building in g.layout().buildings:
  await outdoor("town",g.project(g.door(building)+g.outward(building)*95),"Town - "+building[0])
 await outdoor("town",g.project(Vector2(810,700)),"Village square")
 await outdoor("town",g.project(Vector2(900,450)),"School playground")
 for c in [["harbor",Vector2(1480,585),"Harbor entrance"],["harbor",Vector2(1080,360),"Harbor homes"],["harbor",Vector2(660,360),"Fishing shop"],["harbor",Vector2(430,650),"Western marina"],["harbor",Vector2(600,865),"Fishing pier"],["harbor",Vector2(1040,650),"Beach tide pools"],["harbor",Vector2(1250,480),"Eastern beach"],["mountain",Vector2(800,1080),"Highlands entrance"],["mountain",Vector2(700,600),"Onsen approach"],["mountain",Vector2(1000,550),"Mountain village"],["mountain",Vector2(1320,400),"Mine trail"],["mountain",Vector2(1490,900),"Highlands east trail"],["tea",Vector2(270,675),"Tea Country entrance"],["tea",Vector2(620,675),"Northern tea rows"],["tea",Vector2(990,710),"Tea processing yard"],["tea",Vector2(1210,850),"Tea estate boundary"],["historic",Vector2(1440,1000),"Shrine approach"],["historic",Vector2(1440,520),"Shrine entrance"],["historic",Vector2(1100,600),"Shrine lake"],["historic",Vector2(700,610),"Moonveil waterfall"],["historic",Vector2(1170,880),"Nature friends garden"]]:await outdoor(c[0],c[1],c[2])
 for c in [["farm",Vector2(1485,145),"Connection - farm to town"],["mountain",Vector2(800,1195),"Connection - town to Highlands"],["historic",Vector2(1440,1195),"Connection - town to shrine"],["harbor",Vector2(1595,585),"Connection - town to harbor"],["mountain",Vector2(1595,900),"Connection - Highlands to tea"]]:await outdoor(c[0],c[1],c[2])
 f.travel_to("farm",Vector2(775,600),false);f.enter_house();await capture("Farmhouse interior")
 for room in f.shops.keys():
  f.close_dialogue();f.enter_shop(room,true);await capture("Interior - "+room)
 var file=FileAccess.open(output+"/shots.json",FileAccess.WRITE);file.store_string(JSON.stringify(records,"  "));file.close()
 print("PASS: %d normal-camera world tour screenshots captured"%records.size());quit()
