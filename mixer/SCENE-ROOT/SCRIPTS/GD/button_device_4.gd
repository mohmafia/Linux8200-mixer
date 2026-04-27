extends MenuButton

@export_group("Mixer Routing")
@export var mix_in_name: String = "mixer-in-6"
@export var setting_id: String = "input_6"

var app_ids: Dictionary = {} 

func _ready():
	if OS.get_name() == "Linux" or OS.get_name() == "X11":
		get_popup().about_to_popup.connect(_on_about_to_popup)
	else:
		self.disabled = true
		self.text = "WIN_SIM"


func _on_about_to_popup():
	setup_menu()


func setup_menu():
	var popup := get_popup()
	popup.clear()
	app_ids.clear()

	var output: Array = []
	OS.execute("pactl", ["list", "sink-inputs"], output, true)

	if output.size() > 0:
		var blocks: PackedStringArray = output[0].split("Sink Input #")

		for block in blocks:
			if not block.contains("application.name ="):
				continue

			var id: String = block.split("\n")[0].strip_edges()
			var app_name: String = block.split("application.name = \"")[1].split("\"")[0]

			if app_name != "mixer-project-linux":
				popup.add_item(app_name)
				app_ids[app_name] = id

	if not popup.id_pressed.is_connected(_on_item_selected):
		popup.id_pressed.connect(_on_item_selected)


func _on_item_selected(index: int):
	var selected_name: String = get_popup().get_item_text(index)
	self.text = selected_name

	if not app_ids.has(selected_name):
		return

	var app_id: String = app_ids[selected_name]

	# pactl.move_app_to_input(app_id, mix_in_name)
	# VERWIJDERD — routing gebeurt nu in Go

	# Stuur commando naar Go
	if has_node("/root/MixManager"):
		get_node("/root/MixManager").process_action(
			setting_id,
			"ROUTING",
			"MOVE_APP",
			float(app_id)
		)
