extends SceneTree
const Story=preload("res://StoryArc.gd")
func _initialize(): call_deferred("run")
func run():
 var f=load("res://Main.tscn").instantiate();root.add_child(f);await process_frame
 f.set_physics_process(false);f.choose_character("boy");f.interior_progress.story={"intro":true}
 f.day=1;Story.accept(f,0);assert(Story.state(f).accepted.is_empty())
 f.day=10;Story.offer(f,0);f.close_dialogue();assert(Story.state(f).accepted.is_empty())
 Story.accept(f,0);Story.advance(f,0,0);assert(Story.state(f).steps.is_empty(),"Wrong location cannot advance")
 f.harvests=30;f.fish_catches=3;f.tea_lesson_seen=true
 f.interior_progress.restoration=2;f.interior_progress.activities=["Inn","Café","Clinic","Police Box","Fire Station"]
 for i in range(8):
  f.day=Story.CHAPTERS[i].day;Story.accept(f,i)
  f.enter_shop(Story.CHAPTERS[i].room,true);Story.scene(f,i)
  assert(Story.ready(f,i))
  var person:String=Story.CHAPTERS[i].person;var before:int=int(f.friendship.get(person,0))
  Story.advance(f,i,0);Story.advance(f,i,0)
  assert(Story.state(f).steps[str(i)]==1,"Stale Continue never skips a scene")
  f.close_dialogue();Story.scene(f,i)
  assert(f.dialogue_text.text==Story.CHAPTERS[i].lines[1],"Interrupted dialogue resumes")
  var saved=f.read_saved_json(f.SAVE_FILE)
  assert(saved.interior_progress.chapters.steps[str(i)]==1)
  f.load_game();assert(Story.state(f).steps[str(i)]==1,"Reload retains dialogue position")
  f.enter_shop(Story.CHAPTERS[i].room,true);Story.scene(f,i)
  Story.advance(f,i,1);Story.advance(f,i,2);Story.advance(f,i,2)
  assert(Story.state(f).completed[str(i)] and f.friendship[person]==before+2)
 assert(Story.current(f)==-1)
 assert(not f.interior_progress.story.get("won",false),"Chapters never bypass village vote")
 Story.ending(f);assert(not f.dialogue_open)
 f.interior_progress.story.won=true;Story.ending(f);Story.ending_advance(f,0);f.close_dialogue();Story.ending(f)
 assert(f.dialogue_text.text.contains("Haruka"));Story.ending_advance(f,1);Story.ending_advance(f,2)
 assert(Story.state(f).ending_seen and not f.dialogue_open)
 assert(f.read_saved_json(f.SAVE_FILE).interior_progress.chapters.ending_seen)
 Story.journal(f);f.close_dialogue();assert(f.interior_progress.story.won)
 f.queue_free();await create_timer(.3).timeout
 print("PASS: eight accepted chapters, destination guards, saved dialogue resumption, single rewards, vote-independent ending and continued farm life")
 quit()
