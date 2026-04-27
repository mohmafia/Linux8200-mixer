extends Control  # Root node

@onready var output_log = %Output_log

func _ready():
	get_window().set_title("LINUX MIXER BY DAN!!!")
	install_mixer()  # Start installatie automatisch

func install_mixer():
	var bash_path = "res://SCENE1/SCRIPTS/BASH/firstrun.sh"
	var abs_path = ProjectSettings.globalize_path(bash_path)

	# Zorg dat het script executable is
	OS.execute("chmod", ["+x", abs_path])

	var args = [abs_path]
	var output = []

	# Voer het script uit en vang output
	var exit_code = OS.execute("bash", args, output, true)

	# Toon output in RichTextLabel (zonder BBCode)
	for line in output:
		output_log.append_text(line + "\n")

	if exit_code == 0:
		output_log.append_text("\n✅ Installation SUCCESS!\n")
		output_log.append_text("✅ Restart or Log out and in Needed\n")
		await get_tree().create_timer(4.0).timeout
		get_tree().change_scene_to_file("res://SCENE1/SCENES/main.tscn")
	else:
		output_log.append_text("\n❌ Installation FAILED!!!!!!! (code %d)\n" % exit_code)
