extends Button

func _ready():
	pass
func On_button_pressed_settings_scene():
	get_tree().change_scene_to_file("res://SCENE1/SCENES/Scene1.tscn")
