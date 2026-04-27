extends ScrollContainer
var dragging = false

#func _on_gui_input(event: InputEvent) -> void:
# 1. Check of de linkermuisknop wordt ingedrukt of losgelaten
#	if event is InputEventMouseButton:
#		if event.button_index == MOUSE_BUTTON_LEFT:
#			dragging = event.pressed
	
	# 2. Als we slepen, verplaatsen we de scrollpositie
#	if event is InputEventMouseMotion and dragging:
		# 'relative' is hoeveel de muis is bewogen sinds het vorige frame
		# We trekken dit af van de huidige scroll-stand voor een 'natuurlijk' gevoel
#		scroll_vertical -= event.relative.y
#		scroll_horizontal -= event.relative.x
