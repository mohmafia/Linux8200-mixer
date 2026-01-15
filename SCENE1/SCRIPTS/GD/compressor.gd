extends Node

var active_button: Button = null

func set_active(button: Button):
	if active_button and active_button != button:
		active_button.modulate = Color.WHITE
		active_button.set_meta("on", false)

	active_button = button
	active_button.modulate = Color.RED
	active_button.set_meta("on", true)
