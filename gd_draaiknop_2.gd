extends Sprite2D  # Specifiek voor Sprite2D

var dragging = false
var rotation_min = 0  # Minimale rotatie
var rotation_max = 286  # Maximale rotatie
var middle_position = 148  # Middenpositie (balance start hier)
var sensitivity = 1.8  # Hoe snel de knop reageert op beweging

func _ready():
	rotation_degrees = middle_position  # Zet de standaard rotatie bij start

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if get_rect().has_point(to_local(event.position)):  # Controleer of klik binnen knop is
			dragging = true  
	
	elif event is InputEventMouseButton and not event.pressed:
		dragging = false  

	elif event is InputEventMouseMotion and dragging:
		rotation_degrees = clamp(rotation_degrees - event.relative.y * sensitivity, rotation_min, rotation_max)  # Smooth en begrensd draaien
