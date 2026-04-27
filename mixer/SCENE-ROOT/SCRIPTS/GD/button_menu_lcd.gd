extends TextureButton

func _ready():
	pass

func On_button_pressed_settings_scene():
	# We vragen de SceneTree om de wissel 'uit te stellen' tot het huidige frame klaar is.
	# Dit voorkomt de focus-errors en crashes in VirtualBox.
	get_tree().call_deferred("change_scene_to_file", "res://SCENE-ROOT/MIXER-SETTINGS-SCENE/settings_panel.tscn")
	
