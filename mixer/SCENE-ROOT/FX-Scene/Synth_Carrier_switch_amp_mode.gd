# Master Horizontal Switch Script - LEFT/RIGHT TOGGLE
extends Sprite2D

# --- [cite: 2026-02-10] Settings via Inspector ---
@export_group("Switch Config")
@export var my_id: String = ""      # bijv. Mix_CH1, COMP_A, Master_A
@export var my_type: String = "FX"  # INPUT, MASTER, FX, of BUTTON
@export var my_msg: String = ""      # bijv. SC_MON, PHASE, ON_OFF
@export var error_prefix: String = "SW-HZ" # [cite: 2026-02-04]

# --- POSITION SETTINGS (X-as voor links/rechts) ---
@export var X_LEFT: float = 721.0   # Positie Links
@export var X_RIGHT: float = 749.0  # Positie Rechts

var is_right = false
var is_windows = OS.get_name() == "Windows" # [cite: 2026-01-28]

func _ready():
	# [cite: 2026-02-05] OS Check & Initial Sync
	_load_state_from_cache()
	_update_position()
	
	if is_windows:
		print("[%s] Horizontale Switch %s geladen op %s" % [error_prefix, my_id, "RECHTS" if is_right else "LINKS"])

func _load_state_from_cache():
	# We zoeken in de MixManager data
	var section = "inputs" if my_type == "INPUT" else "masters"
	if my_type == "compressors": section = "compressors" # Voor je COMP_A/B/C logs
	
	if MixManager.mixer_data.has(section) and MixManager.mixer_data[section].has(my_id):
		var val = MixManager.mixer_data[section][my_id].get(my_msg.to_lower(), 0.0)
		is_right = val > 0.5
	else:
		is_right = false

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if get_rect().has_point(to_local(event.position)):
				_toggle_horizontal()
				get_viewport().set_input_as_handled()
		
		# [cite: 2026-03-03] Rechtermuisklik voor Factory Reset (naar LINKS)
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if get_rect().has_point(to_local(event.position)):
				_factory_reset()

func _toggle_horizontal():
	is_right = !is_right
	_update_position()
	_sync_to_mixmanager()
	
	if is_windows:
		print("[%s] %s switch naar: %s" % [error_prefix, my_id, "RECHTS" if is_right else "LINKS"])

func _update_position():
	# Verplaats de switch op de X-as
	position.x = X_RIGHT if is_right else X_LEFT

func _sync_to_mixmanager():
	# 0.0 voor Links, 1.0 voor Rechts
	var val = 1.0 if is_right else 0.0
	MixManager.process_action(my_id, my_type, my_msg.to_upper(), val)

func _factory_reset():
	# [cite: 2026-03-03] Terug naar standaard (Links / 0.0)
	is_right = false
	_update_position()
	_sync_to_mixmanager()
