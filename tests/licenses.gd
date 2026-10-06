extends SceneTree

func _initialize() -> void:
	var destination := ProjectSettings.globalize_path("res://../PlayCoastalFarm/RUNTIME LICENSE.txt")
	var output := FileAccess.open(destination, FileAccess.WRITE)
	output.store_string("Godot Engine runtime notices\n\n" + Engine.get_license_text() + "\n\n")
	output.store_string("Third-party components and copyright holders\n" + JSON.stringify(Engine.get_copyright_info(), "  ") + "\n\n")
	for title in Engine.get_license_info():
		output.store_string(title + "\n" + Engine.get_license_info()[title] + "\n\n")
	output.close()
	print("PASS: runtime license and third-party notices written")
	quit()
