extends Sprite2D
 # Zorg dat dit script op de fader-node zit

var min_position = -90  # Onderaan
var max_position = 26  # Bovenaan
var dragging = false  # Staat van fader
signal volume_changed(value)  # Registreert het signaal


func _ready():
	# Zet fader in middenpositie bij starten
	position.y = (min_position + max_position) / 2.0
	update_volume()

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if get_rect().has_point(to_local(event.position)):
			dragging = true  # Alleen deze fader reageert
	
	elif event is InputEventMouseButton and not event.pressed:
		dragging = false  # Stop slepen
	
	elif event is InputEventMouseMotion and dragging:
		position.y = clamp(position.y + event.relative.y, min_position, max_position)
		update_volume()

func update_volume():
	var volume = 1 - ((position.y - min_position) / (max_position - min_position))
	emit_signal("volume_changed", volume)  # Verbind dit met je mixer-audio!
