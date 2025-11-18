extends Control

@onready var output_log = %Output_log
var log_file_path := "user://log.txt"

func _ready():
	get_window().set_title("LINUX MIXER BY DAN!!!")
	install_mixer()

func log_line(text: String):
	output_log.append_text(text + "\n")

	var file = FileAccess.open(log_file_path, FileAccess.READ_WRITE)
	if file == null:
		file = FileAccess.open(log_file_path, FileAccess.WRITE)
	file.seek_end()
	file.store_line(text)
	file.close()

func install_mixer():
	var bash_path = "res://SCENE1/SCRIPTS/BASH/firstrun.sh"
	var temp_path = "user://firstrun.sh"

	# Stap 1: kopieer script naar user:// en fix line endings
	var source = FileAccess.open(bash_path, FileAccess.READ)
	if source == null:
		log_line("❌ Kan installatiebestand niet openen: " + bash_path)
		return

	var target = FileAccess.open(temp_path, FileAccess.WRITE)
	while not source.eof_reached():
		var line = source.get_line()
		line = line.replace("\r", "")  # verwijder carriage returns
		target.store_line(line)
	source.close()
	target.close()

	# Stap 2: maak het uitvoerbaar
	var abs_path = ProjectSettings.globalize_path(temp_path)
	var chmod_result = OS.execute("chmod", ["+x", abs_path])
	if chmod_result != 0:
		log_line("❌ chmod mislukt op: " + abs_path)
		return

	# Stap 3: verberg Godot tijdelijk zodat pkexec zichtbaar wordt
	get_window().hide()
	#get_window().minimize()
	await get_tree().create_timer(0.5).timeout

	# Stap 4: voer het script uit
	var output = []
	var exit_code = OS.execute("bash", [abs_path], output, true)

	# Stap 5: toon Godot direct weer
	get_window().show()

	# Stap 6: log output
	for line in output:
		log_line(line)

	# Stap 7: check resultaat
	if exit_code == 0:
		log_line("✅ Installation SUCCESS!")
		log_line("✅ Restart or Log out and in Needed")
		await get_tree().create_timer(4.0).timeout
		get_tree().change_scene_to_file("res://SCENE1/SCENES/Scene1.tscn")
	else:
		log_line("❌ Installation FAILED!!!!!!! (code %d)" % exit_code)
