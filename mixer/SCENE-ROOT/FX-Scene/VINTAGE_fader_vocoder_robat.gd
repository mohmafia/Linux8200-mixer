extends Sprite2D

# Jouw gekalibreerde waarden (1183 boven, 1373 onder)
const Y_START = 811.0  # Onderkant (Groen)
const Y_END = 668.0    # Bovenkant (Rood)

var dragging = false
@onready var my_led =  $"led-fader_vocoder_robot"

func _ready():
	# Update de kleur direct bij opstarten
	_update_led_gradient()
	# OS Check [cite: 2026-02-05]
	print("Fader LED klaar voor actie op: ", OS.get_name())

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			# Check of we de fader-knop raken
			if event.pressed and get_rect().has_point(to_local(event.position)):
				dragging = true
				get_viewport().set_input_as_handled()
			else:
				dragging = false

	if event is InputEventMouseMotion and dragging:
		# Volg de muis binnen de grenzen
		position.y = clamp(get_parent().get_local_mouse_position().y, Y_END, Y_START)
		get_viewport().set_input_as_handled()
		_update_led_gradient()

func _update_led_gradient():
	if not my_led: 
		return
	
	# Bereken de factor (0.0 onder, 1.0 boven)
	var factor = remap(position.y, Y_START, Y_END, 0.0, 1.0)
	var final_color : Color
	
	# De heldere Groen -> Geel -> Rood overgang
	if factor < 0.5:
		# Van Groen naar Geel (factor schalen naar 0-1 voor de eerste helft)
		final_color = Color.GREEN.lerp(Color.YELLOW, factor * 2.0)
	else:
		# Van Geel naar Rood (factor schalen naar 0-1 voor de tweede helft)
		final_color = Color.YELLOW.lerp(Color.RED, (factor - 0.5) * 2.0)
	
	my_led.modulate = final_color
	# Houd de LED mooi fel
	my_led.self_modulate.a = 0.7 + (factor * 0.3)

# Error code systeem voor debuggen [cite: 2026-02-04]
func _get_fader_error(id):
	var codes = {
		"F001": "Fader position out of bounds",
		"L001": "LED child node not found"
	}
	return codes.get(id, "Unknown Error")
