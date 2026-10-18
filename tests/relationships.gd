extends SceneTree
const R=preload("res://Relationships.gd")
func _initialize():call_deferred("run")
func run():
 var f=load("res://Main.tscn").instantiate();root.add_child(f);await process_frame
 f.set_physics_process(false);f.choose_character("boy");f.close_dialogue();f.friendship.Seira=60
 var s=R.state(f,"Seira")
 assert(s.status=="friends" and s.affection==0,"Existing friendship must not become romance")
 var before_friendship:int=f.friendship.Seira
 R.date(f,"Seira","Unknown outing")
 assert(f.friendship.Seira==before_friendship and not load("res://EverydayLife.gd").state(f).dates.has("Seira"),"Invalid outing must not consume rewards or cooldown")
 f.friendship.Seira=0;R.finish_scene(f,"Seira",0)
 assert(s.chapter==0,"Story threshold cannot be bypassed")
 f.friendship.Seira=60
 R.finish_scene(f,"Seira",-1);R.finish_scene(f,"Seira",3)
 assert(s.chapter==0,"Invalid chapter leaves progression untouched")
 R.date(f,"Seira","Tea");assert(s.affection==0)
 R.commit(f,"Seira","interested");assert(s.status=="interested")
 R.commit(f,"Seira","dating");assert(s.status=="interested","Cannot bypass milestones")
 for chapter in range(3):R.finish_scene(f,"Seira",chapter)
 assert(s.chapter==3 and s.affection==24)
 R.finish_scene(f,"Seira",2);assert(s.affection==24,"Scenes award once")
 f.day+=7;R.date(f,"Seira","Tea");assert(s.affection==34)
 R.date(f,"Seira","Tea");assert(s.affection==34,"Outing cooldown shared")
 R.commit(f,"Seira","dating");assert(s.status=="dating")
 assert(not R.available(f,"Mika"),"Exclusive commitment")
 R.commit(f,"Seira","engaged");assert(s.status=="dating")
 s.affection=80;R.commit(f,"Seira","engaged");assert(s.status=="engaged")
 R.commit(f,"Seira","married");assert(R.stage(f,"Seira")=="Married")
 R.commit(f,"Shohei","interested");assert(R.state(f,"Shohei").status=="friends")
 f.load_game()
 assert(load("res://EverydayLife.gd").state(f).memories.has("Married with Seira"),"Milestone memory persists immediately")
 f.close_dialogue();f.clock_minutes=400
 while f.is_rainy_day():f.day+=1
 assert(R.greeting(f,"Seira")!="")
 assert(R.maybe_visit(f),"Partner morning visit")
 f.close_dialogue();assert(not R.maybe_visit(f),"Only one visit per week")
 f.save_game(false);f.interior_progress.relationships={};f.load_game()
 assert(R.state(f,"Seira").status=="married" and R.state(f,"Seira").chapter==3,"Relationship saved")
 print("PASS: relationship opt-in, milestones, exclusivity, cooldown and save round trip");quit()
