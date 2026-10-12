extends Node2D
const ART=preload("res://assets/ranch-vet-atlas-v1.png")
func _draw() -> void:
 for data in [[Vector2(360,1040),Vector2(270,190),"Ranch",0],[Vector2(1990,340),Vector2(230,190),"Vet",627]]:
  var p:Vector2=data[0];var size:Vector2=data[1]
  draw_texture_rect_region(ART,Rect2(p-Vector2(24,20),size+Vector2(48,60)),Rect2(data[3],0,627,594))
  var sign:=p+Vector2(size.x-75,size.y-20)
  draw_line(sign+Vector2(0,15),sign+Vector2(0,45),Color("775333"),6)
  draw_rect(Rect2(sign-Vector2(40,15),Vector2(80,32)),Color("f4e3bc"))
  draw_string(ThemeDB.fallback_font,sign+Vector2(-33,8),data[2],HORIZONTAL_ALIGNMENT_LEFT,-1,20,Color("493b2d"))
static func draw_room(room) -> void:
 room.draw_rect(Rect2(Vector2.ZERO,room.SIZE),Color("3d5149"))
 room.draw_texture_rect_region(ART,Rect2(90,70,920,740),Rect2(627 if room.kind=="Veterinarian" else 0,594,627,660))
static func vet_menu(f) -> void:
 f.close_dialogue();var c=f.make_modal("Veterinarian · Midori")
 f.dialogue_text.text="I can visit your barn for a wellness check. ¥30 per animal, once daily. Your animals gain one affection point. Daily feeding is still essential."
 for i in range(f.BarnLife.state(f).animals.size()):
  var animal:Dictionary=f.BarnLife.state(f).animals[i]
  c.add_child(f.make_button("Check %s · ¥30" % animal.get("name",animal.species),checkup.bind(f,i)))
 if f.BarnLife.state(f).animals.is_empty(): f.dialogue_text.text="Visit the town ranch to buy your first animal. Then I can help with wellness visits."
 c.add_child(f.make_button("Back",f.close_dialogue))
static func checkup(f,index:int) -> void:
 if f.location!="shop" or f.shop_name!="Veterinarian": return
 var animals:Array=f.BarnLife.state(f).animals
 if index<0 or index>=animals.size(): return
 var animal:Dictionary=animals[index]
 if int(animal.get("vet_day",-1))==f.day: f.dialogue_text.text="Already checked today. Your animal is ready for its usual care.";return
 if f.coins<30: f.dialogue_text.text="A wellness visit costs ¥30.";return
 f.coins-=30;animal.vet_day=f.day;animal.affection=mini(100,int(animal.get("affection",0))+1)
 f.save_game(false);f.refresh_hud();f.dialogue_text.text="Wellness visit complete. Affection +1. Remember fresh feed each day!"
