extends RefCounted

# First names and established roles only. Appearance choices remain drafts.
const GROUPS := [
	["Aya", "Hana", "Mika", "Yuta", "Ken", "Hiro"],
	["Keiko", "Kenji", "Gen", "Yumi", "Jiro", "Naomi"],
	["Sachiko", "Kenta", "Haruka", "Rei", "Masao", "Emi"]
]
const ROLES := {
	"Aya": "Clinic assistant", "Hana": "Inn worker", "Mika": "Tea farmer", "Yuta": "Firefighter", "Ken": "Fisherman", "Hiro": "Mountain guide",
	"Keiko": "General Store owner", "Kenji": "Doctor", "Gen": "Blacksmith", "Yumi": "Inn owner", "Jiro": "Fire Chief", "Naomi": "Café owner",
	"Sachiko": "Senior tea farmer", "Kenta": "Carpenter", "Haruka": "Historian", "Rei": "Shrine caretaker", "Masao": "Senior fisherman", "Emi": "Mountain Lodge owner"
}
const HOMES := {
	"Haruka":Vector2(2070,2020),
	"Aya": Vector2(1860, 455), "Kenji": Vector2(1730, 455),
	"Hana": Vector2(1820, 1295), "Yumi": Vector2(1930, 1295),
	"Yuta": Vector2(1690, 1660), "Jiro": Vector2(1810, 1660),
	"Keiko": Vector2(590, 820), "Gen": Vector2(490, 1295),
	"Naomi": Vector2(1890, 820), "Kenta": Vector2(1200, 280)
}
const REGION := {"Mika": "tea", "Sachiko": "tea", "Ken": "harbor", "Masao": "harbor", "Hiro": "mountain", "Emi": "mountain", "Rei": "historic"}
const DIALOGUE := {
	"Aya": ["I'm Aya. I help Kenji at the clinic. I moved here after deciding city life wasn't for me.", "Settling in takes time. A cup of tea and a walk by the lake usually help me."],
	"Hana": ["Welcome. I'm Hana. My mother Yumi and I look after the inn.", "I've been sketching ideas for the rooms. I want to make them brighter without losing the inn's character."],
	"Mika": ["Mika. So you're the new farmer? Let's see how those hands handle a real field!", "I'm teasing. Mostly. Sachiko and I grow tea nearby. Farming has a future if we keep trying new ideas."],
	"Yuta": ["Hey, I'm Yuta! If you need a hand around town, just ask.", "Jiro keeps us busy at the fire station. I try to get a run in whenever I'm off duty."],
	"Ken": ["I'm Ken. Fishing, beach walks, excellent company... that's my usual schedule.", "Masao says I should think more about the future. Maybe he's right. Don't tell him I said that."],
	"Hiro": ["Hiro. I guide the mountain trails and study the plants around the lake.", "My plans change with the weather. If you can't find me, try the forest or Emi's lodge."],
	"Keiko": ["I'm Keiko. Welcome to the General Store. Seira has already told me about our new farmer.", "Seeds and basic supplies are our business. Take care of the farm, and it will take care of you."],
	"Kenji": ["Kenji. I run the clinic, with considerable help from Aya.", "Working hard is admirable. Sleeping properly is even more admirable when you want to avoid my waiting room."],
	"Gen": ["Gen. I work the forge. Shohei's learning the trade, though he has no shortage of opinions.", "Show me you're serious about that farm. A good tool deserves a farmer who looks after it."],
	"Yumi": ["I'm Yumi. If you hear laughter coming from the inn, it's probably my guests.", "Hana has ideas for changing the rooms. I suppose the old place can learn a few new tricks."],
	"Jiro": ["Jiro, fire chief! Welcome to town. Yuta and I are here when the community needs us.", "Taro's my older brother. He likes to think he's the sensible one. I let him enjoy that."],
	"Naomi": ["Naomi! Come by the café at lunchtime. No one does their best work on an empty stomach.", "Everyone stops here sooner or later. Stay for a meal and you might hear something interesting."],
	"Sachiko": ["Sachiko. I've grown tea here longer than most of these young ones have been alive.", "Mika has plenty of ideas. Good. She'll need both ideas and patience to make them work."],
	"Kenta": ["Kenta, carpenter. I build houses, barns, fences... anything that needs good wood and a little imagination.", "Your family property has potential. Once it's cleared, we can talk about what to restore."],
	"Haruka": ["I'm Haruka. Your family's farm has more stories than the weeds would have you believe.", "As you clear the old paths, bring me anything curious. Sometimes a forgotten place has been waiting to be remembered."],
	"Rei": ["Rei. I look after the shrine. Yes, I do smile. Shrine work doesn't require a permanent serious face.", "Haruka and I exchange stories about this place. Some are even true."],
	"Masao": ["Masao. I fish the western coast. The sea rewards patience, not noise.", "Ken knows these waters well. I hope he'll see that knowing a place also means taking care of it."],
	"Emi": ["Emi. I run the mountain lodge. Drop in before you tackle a long trail.", "Hiro passes through often. He notices things most people walk straight past."]
}

static func index_of(person: String) -> Vector2i:
	for group in range(GROUPS.size()):
		var row: int = GROUPS[group].find(person)
		if row >= 0: return Vector2i(group + 2, row)
	return Vector2i(-1, -1)
