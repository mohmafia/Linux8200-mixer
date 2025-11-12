extends Sprite2D
# Zorg dat dit script op de crossfader-node zit

var min_position = -44  # Links
var max_position = 112   # Rechts
var dragging = false
signal volume_changed(value)

func _ready():
	# Zet fader in middenpositie bij starten
	position.x = (min_position + max_position) / 2.0
	update_volume()

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if get_rect().has_point(to_local(event.position)):
			dragging = true
	
	elif event is InputEventMouseButton and not event.pressed:
		dragging = false
	
	elif event is InputEventMouseMotion and dragging:
		position.x = clamp(position.x + event.relative.x, min_position, max_position)
		update_volume()

func update_volume():
	var volume = (position.x - min_position) / (max_position - min_position)
	emit_signal("volume_changed", volume)
