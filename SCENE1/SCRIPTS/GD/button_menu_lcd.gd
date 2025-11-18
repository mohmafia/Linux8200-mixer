extends TextureButton

func _ready():
	pass
func On_button_pressed_install_scene():
	get_tree().change_scene_to_file("res://SCENE1/SCENES/settings_lcd_panel.tscn")
	
