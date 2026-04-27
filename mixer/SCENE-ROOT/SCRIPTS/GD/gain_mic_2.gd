extends Sprite2D

# --- [cite: 2026-02-10] Settings via Inspector ---
@export_group("Rotary Config")
@export var my_id: String = "mix-in-2"     # mix-in-1 t/m 8 of master-A t/m C
@export var my_type: String = "INPUT"      # INPUT of MASTER
@export var my_msg: String = "GAIN"       # GAIN, PAN, of COMP
@export var error_prefix: String = "ROT-02" # [cite: 2026-02-04] English Error Code

# --- ROTATION SETTINGS ---
var dragging = false
var rotation_min = 0.0
var rotation_max = 298.0
var sensitivity = 1.8

var current_value = 0.5 
var is_windows = OS.get_name() == "Windows"

func _ready():
	# [cite: 2026-02-05] OS Check for Debugging
	_load_value_from_cache()
	
	# Set visual rotation immediately
	rotation_degrees = (current_value * (rotation_max - rotation_min)) + rotation_min
	
	if is_windows:
		print("[%s] %s %s initialized at: %f" % [error_prefix, my_id, my_msg, current_value])

func _load_value_from_cache():
	# Bepaal in welke lade we moeten kijken op basis van type
	var section = "inputs" if my_type == "INPUT" else "masters"
	
	# [Crash-safe check] [cite: 2026-02-27]
	if MixManager.mixer_data.has(section) and MixManager.mixer_data[section].has(my_id):
		if MixManager.mixer_data[section][my_id].has(my_msg.to_lower()):
			current_value = MixManager.mixer_data[section][my_id][my_msg.to_lower()]
		else:
			current_value = 0.5
	else:
		# Als de ID nog niet bestaat (bijv. tijdens bouwen), gebruik default
		current_value = 0.5

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed and get_rect().has_point(to_local(event.position)):
			dragging = true
		else:
			if dragging: 
				_sync_to_mixmanager()
			dragging = false

	elif event is InputEventMouseMotion and dragging:
		# Manual rotation logic
		rotation_degrees = clamp(rotation_degrees - event.relative.y * sensitivity, rotation_min, rotation_max)
		current_value = (rotation_degrees - rotation_min) / (rotation_max - rotation_min)

func _sync_to_mixmanager():
	# [cite: 2026-02-04] Use the new 4-argument process_action
	MixManager.process_action(my_id, my_type, my_msg.to_upper(), current_value)

# For external control (Go / Streamdeck / Animation)
func set_knob_value(target_val: float):
	current_value = clamp(target_val, 0.0, 1.0)
	var target_deg = (current_value * (rotation_max - rotation_min)) + rotation_min
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rotation_degrees", target_deg, 0.15)
