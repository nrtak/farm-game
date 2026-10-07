extends RefCounted
static func forecast(value: int) -> String:
	var season := int((value-1)/28)%4
	var roll := posmod(value*73+int(value/7)*19,100)
	if season in [1,2] and roll<4: return "Hurricane"
	if season == 1 and roll>=84: return "Heatwave"
	if value%5 == 3 or roll<14: return "Rain"
	return "Normal"
static func work_multiplier(farm) -> float:
	return 1.5 if forecast(farm.day) == "Rain" and not farm.inside_house and farm.location != "shop" else 1.0
static func heatwave_growth(plot: Dictionary, day: int) -> bool:
	if forecast(day-1) != "Heatwave" or plot.stage == 0: return false
	plot.growth = maxf(0,float(plot.growth)-1)
	plot.stage = 1
	return true
