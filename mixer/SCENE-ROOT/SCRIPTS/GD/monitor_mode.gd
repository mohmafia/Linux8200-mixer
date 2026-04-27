# Master 3-Way Switch Script - OFF / MID / TOP
extends Sprite2D

# --- [cite: 2026-02-10] Settings via Inspector ---
@export_group("Switch Config")
@export var my_id: String = ""      # bijv. LFO_WAVE, ROUTING
@export var my_type: String = "MONITOR_SELECT"  # INPUT, MASTER of FX
@export var my_msg: String = "MODE"
@export var error_prefix: String = "SW_MODE-01" # [cite: 2026-02-04]

# --- POSITION SETTINGS (3 Standen) ---
@export var X_POS_0: float = 1430.0  # A
@export var X_POS_1: float = 1447.0  # B
@export var X_POS_2: float = 1465.0  # C

# De huidige stand: 0, 1 of 2
var current_state: int = 0
var is_windows = OS.get_name() == "Windows" # [cite: 2026-01-28]

func _ready():
	# [cite: 2026-02-05] OS Check & Initial Sync
	_load_state_from_cache()
	_update_position()
	
	if is_windows:
		print("[%s] 3-Way Switch Monitor Mode %s geladen. Stand: %d" % [error_prefix, my_id, current_state])

func _load_state_from_cache():
	var section = "inputs" if my_type == "INPUT" else "masters"
	if MixManager.mixer_data.has(section) and MixManager.mixer_data[section].has(my_id):
		var val = MixManager.mixer_data[section][my_id].get(my_msg.to_lower(), 0.0)
		# We vertalen de float terug naar 0, 1 of 2
		if val >= 0.9: current_state = 2
		elif val >= 0.4: current_state = 1
		else: current_state = 0
	else:
		current_state = 0

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if get_rect().has_point(to_local(event.position)):
				_cycle_switch()
				get_viewport().set_input_as_handled()
		
		# [cite: 2026-03-03] Rechtermuisklik voor Factory Reset naar stand 0
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if get_rect().has_point(to_local(event.position)):
				_factory_reset()

func _cycle_switch():
	# Cycle door de standen: 0 -> 1 -> 2 -> 0
	current_state = (current_state + 1) % 3
	_update_position()
	_sync_to_mixmanager()
	
	if is_windows:
		print("[%s] %s geklikt naar stand: %d" % [error_prefix, my_id, current_state])

func _update_position():
	# Fysiek de sprite verplaatsen op basis van de state
	match current_state:
		0: position.x = X_POS_0
		1: position.x = X_POS_1
		2: position.x = X_POS_2

func _sync_to_mixmanager():
	# We sturen een float naar Go omdat de MixManager floats verwacht
	# 0.0, 0.5 of 1.0
	var float_val = current_state * 0.5
	MixManager.process_action(my_id, my_type, my_msg.to_upper(), float_val)

func _factory_reset():
	# [cite: 2026-03-03] Terug naar stand 0
	current_state = 0
	_update_position()
	_sync_to_mixmanager()
