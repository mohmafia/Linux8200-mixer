extends Sprite2D

# --- [cite: 2026-02-10] Settings via Inspector ---
@export_group("Rotary Config")
@export var my_id: String = "comp-A"    # mix-in-1 t/m 8 of master-A t/m C
@export var my_type: String = "MASTER"      # INPUT of MASTER
@export var my_msg: String = "ratio_r"   # Bijv: threshold, ratio, attack, release
@export var error_prefix: String = "COMP-RATIO-R-01"  # [cite: 2026-02-04] English Error Code

# --- ROTATION SETTINGS ---
var dragging = false
var rotation_min = -146
var rotation_max = 153
var sensitivity = 1.8

var current_value = 0.5 
var is_windows = OS.get_name() == "Windows"

func _ready():
	_load_value_from_cache()
	
	# Zet de knop visueel op de juiste plek
	rotation_degrees = (current_value * (rotation_max - rotation_min)) + rotation_min
	
	if is_windows and dragging: # Alleen loggen bij beweging om de console niet te overspoelen met 100 logs
		print("[%s] %s %s initialized" % [error_prefix, my_id, my_msg])

func _load_value_from_cache():
	# Bepaal de sectie (inputs of masters)
	var section = "inputs" if my_type == "INPUT" else "masters"
	
	# [CRASH-SAFE] [cite: 2026-02-27] 
	# We checken elke stap van de dictionary om NULL-pointer crashes te voorkomen
	if MixManager.mixer_data.has(section):
		if MixManager.mixer_data[section].has(my_id):
			var key = my_msg.to_lower()
			if MixManager.mixer_data[section][my_id].has(key):
				current_value = MixManager.mixer_data[section][my_id][key]
				return # Waarde gevonden, we zijn klaar

	# Als we hier komen, bestond de data niet: Gebruik een veilige default
	current_value = 0.5 

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed and get_rect().has_point(to_local(event.position)):
			dragging = true
			get_viewport().set_input_as_handled()
		else:
			if dragging: 
				_sync_to_mixmanager()
			dragging = false

	elif event is InputEventMouseMotion and dragging:
		rotation_degrees = clamp(rotation_degrees - event.relative.y * sensitivity, rotation_min, rotation_max)
		current_value = (rotation_degrees - rotation_min) / (rotation_max - rotation_min)

func _sync_to_mixmanager():
	# [cite: 2026-02-04] De nieuwe 4-argumenten taal
	MixManager.process_action(my_id, my_type, my_msg.to_upper(), current_value)

func set_knob_value(target_val: float):
	current_value = clamp(target_val, 0.0, 1.0)
	var target_deg = (current_value * (rotation_max - rotation_min)) + rotation_min
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rotation_degrees", target_deg, 0.15)
