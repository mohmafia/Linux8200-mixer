extends Sprite2D

# Jouw waarden
const X_START = 601.0  # Links (Groen)
const X_END = 731.0    # Rechts (Rood)

var dragging = false
@onready var my_led = $"led-fader_mode"

func _ready():
	# Update de kleur direct bij opstarten
	_update_led_gradient()
	# OS Check [cite: 2026-02-05]
	print("Horizontale Fader klaar op: ", OS.get_name())

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and get_rect().has_point(to_local(event.position)):
				dragging = true
				get_viewport().set_input_as_handled()
			else:
				dragging = false

	if event is InputEventMouseMotion and dragging:
		# FIX 1: Clamp moet altijd (waarde, LAAG, HOOG) zijn!
		# Dus van 601 naar 731
		position.x = clamp(get_parent().get_local_mouse_position().x, X_START, X_END)
		get_viewport().set_input_as_handled()
		_update_led_gradient()

func _update_led_gradient():
	if not my_led: 
		return
	
	# Bereken de factor (0.0 links (601), 1.0 rechts (731))
	var factor = remap(position.x, X_START, X_END, 0.0, 1.0)
	var final_color : Color
	
	# De heldere Groen -> Geel -> Rood overgang
	if factor < 0.5:
		final_color = Color.GREEN.lerp(Color.YELLOW, factor * 2.0)
	else:
		final_color = Color.YELLOW.lerp(Color.RED, (factor - 0.5) * 2.0)
	
	my_led.modulate = final_color
	my_led.self_modulate.a = 0.7 + (factor * 0.3)

# Error code systeem voor debuggen [cite: 2026-02-04]
func _get_fader_error(id):
	var codes = {
		"F001": "Horizontal Fader clamp error",
		"L001": "Spectral LED not found"
	}
	return codes.get(id, "Unknown Error")
