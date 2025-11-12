extends Sprite2D

var min_position = 520
var max_position = 708
var dragging = false
signal volume_changed(value)

var input_volume := 0.0
var initialized := false

func _ready():
	# Verbind het signaal "volume_changed" met de methode "set_fader_volume" van Master_A_clip
	var target_callable = Callable($"../Master_A_clip", "set_fader_volume")
	
	# Alleen verbinden als het nog niet verbonden is
	if not $".".is_connected("volume_changed", target_callable):
		$".".connect("volume_changed", target_callable)
	
	# Clamp de startpositie
	position.y = clamp(position.y, min_position, max_position)
	
	# Wacht 1 frame zodat alles correct geinitialiseerd is
	await get_tree().process_frame
	
	# Eerste volume-update
	update_volume()
	
	# Debug prints
	print("Master A start pos:", position.y)
	print("Master A connected:", $".".is_connected("volume_changed", target_callable))




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
	var fader_position = clamp(1.0 - ((position.y - min_position) / (max_position - min_position)), 0.0, 1.0)
	if fader_position <= 0.0 and position.y >= max_position - 0.5:
		fader_position = 0.001  # mini offset zodat hij nooit 'vast' op 0 zit
	var effective_volume = fader_position * input_volume
	emit_signal("volume_changed", effective_volume)
	print("Master A volume update Input Volume:", input_volume)


func set_input_volume(value: float):
	input_volume = clamp(value, 0.0, 1.0)
	# deferred zodat de waarde niet in hetzelfde frame als _ready() botst
	call_deferred("update_volume")
	print("Master A received input_volume:", value)
