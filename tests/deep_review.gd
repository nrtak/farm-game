extends SceneTree
func _initialize():call_deferred("run")
func run():
 var f=load("res://Main.tscn").instantiate();root.add_child(f);await process_frame
 f.set_physics_process(false);f.choose_character("boy");f.close_dialogue();f.window_focused=true
 f.interior_progress.story={"intro":true};f.day=3
 f.travel_to("waterfall",Vector2(800,750),false);f.close_dialogue()
 f.paused_by_player=true;f.interact();assert(not f.dialogue_open,"Paused waterfall cannot open a menu")
 f.paused_by_player=false;f.window_focused=false;f.interact();assert(not f.dialogue_open,"Unfocused waterfall ignores interaction")
 f.window_focused=true;f.interact();assert(f.dialogue_open,"Waterfall works after resuming")
 var original=f.dialogue_panel
 f.interact();assert(f.dialogue_panel==original or not f.dialogue_open,"Interaction does not replace an open waterfall menu")
 f.close_dialogue();f.travel_to("town",f.town.arrival("farm"),false)
 f.begin_festival();var festival_zoom=f.camera.zoom
 for i in range(3):f.perspective._process(.016)
 assert(f.camera.zoom==festival_zoom,"Festival zoom survives subsequent presentation frames")
 f.end_festival();f.perspective._process(.016);assert(is_equal_approx(f.camera.zoom.x,f.perspective.TOWN_ZOOM),"Walking zoom returns after festival")
 f.save_game(false);f.held_gift="Turnip";f.load_game();assert(f.held_gift.is_empty(),"Reload clears stale held selection")
 f.start_scene("A Table for Everyone")
 assert(not f.scene_actors.is_empty(),"Scene has actors")
 var record=f.scene_actors[0].duplicate();var actor=record.npc
 actor.visible=not record.visible;actor.label.visible=not record.label_visible;actor.z_index=999
 f.close_dialogue()
 assert(actor.visible==record.visible and actor.label.visible==record.label_visible and actor.z_index==record.z_index,"Scene restores resident visibility, label and depth")
 preload("res://PlayerComfort.gd").settings(f).large_text=true
 f.start_conversation(f.town.npcs[0]);await process_frame;await process_frame
 assert(f.dialogue_text.get_theme_font_size("font_size")==25,"Compact dialogue honors large text")
 var dismiss=f.dialogue_panel.find_child("DialogueClose",true,false)
 assert(dismiss!=null and dismiss.is_visible_in_tree(),"Compact dialogue has a visible close button")
 var hit=dismiss.get_global_rect().get_center()
 for pressed in [true,false]:
  var click=InputEventMouseButton.new();click.button_index=MOUSE_BUTTON_LEFT;click.pressed=pressed;click.position=hit
  root.push_input(click,true);await process_frame
 assert(not f.dialogue_open,"Close button receives pointer clicks above the scroll area")
 f.start_conversation(f.town.npcs[0]);f.advance_dialogue();assert(not f.dialogue_open,"Interaction dismisses complete ordinary dialogue")
 print("PASS: waterfall guards, festival camera, reload selection cleanup, scene restoration, large text, pointer dismissal and complete-dialogue close")
 f.queue_free();await process_frame;quit()
