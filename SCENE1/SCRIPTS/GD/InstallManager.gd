extends Node

# 🔧 Installer on/off switch
const INSTALL_ENABLED := false   # ← set to true to use installer

func _ready():
	var install_flag = OS.get_user_data_dir().path_join("installed.flag")

	# 🚫 Install completely off → do nothing automatically so you can test
	if not INSTALL_ENABLED:
		print("⚠️ Installer turned off.")
		return

	# 🟢 Installer is on -> normal flow
	if FileAccess.file_exists(install_flag):
		print("✅ Mixer Already installed")
		call_deferred("load_main_scene")
	else:
		print("🚀 Initial installation required — opening install scene")
		call_deferred("load_install_scene")

func load_main_scene():
	get_tree().change_scene_to_file("res://SCENE1/SCENES/Scene1.tscn")

func load_install_scene():
	get_tree().change_scene_to_file("res://SCENE1/SCENES/install.tscn")
