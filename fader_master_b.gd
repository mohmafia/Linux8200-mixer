extends Sprite2D

var min_position = 520
var max_position = 708
var dragging = false
signal volume_changed(value)

var input_volume := 0.0  # Wordt gezet door Mic1

func _ready():
	# Verbind het signaal "volume_changed" met de methode "set_fader_volume" van Master_A_clip
	var target_callable = Callable($"../Master_B_clip", "set_fader_volume")
	
	# Alleen verbinden als het nog niet verbonden is
	if not $".".is_connected("volume_changed", target_callable):
		$".".connect("volume_changed", target_callable)
	
	# Clamp de startpositie
	position.y = clamp(position.y, min_position, max_position)
	
	# Wacht 1 frame zodat alles correct geinitialiseerd is
	await get_tree().process_frame
	
	# Eerste volume-update
	update_volume()
	
	
func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if get_rect().has_point(to_local(event.position)):
			dragging = true
	elif event is InputEventMouseButton and not event.pressed:
		dragging = false
	elif event is InputEventMouseMotion and dragging:
		position.y = clamp(position.y + event.relative.y, min_position, max_position)
		update_volume()

func update_volume():
	var fader_position = 1.0 - ((position.y - min_position) / (max_position - min_position))

	var effective_volume = fader_position * input_volume
	emit_signal("volume_changed", effective_volume)

func set_input_volume(value: float):
	input_volume = value
	update_volume()
