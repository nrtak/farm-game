extends RefCounted
const APPROACH=Vector2(1050,610)
const WATERLINE=Vector2(1050,475)
static func nearby(f) -> bool:
	return f.location=="historic" and not f.inside_house and (f.player.position-f.REGION_ORIGINS.historic).distance_to(APPROACH)<155
