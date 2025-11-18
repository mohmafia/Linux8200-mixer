extends TextureButton


func _on_exit_button_pressed():
	get_tree().change_scene_to_file("res://SCENE1/SCENES/Scene1.tscn")
