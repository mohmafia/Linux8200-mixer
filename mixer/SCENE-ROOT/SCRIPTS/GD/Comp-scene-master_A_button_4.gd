extends ColorRect

# --- [cite: 2026-02-10] Universal Settings via Inspector ---
@export_group("Button Config")
@export var target_id: String = "comp-a"     # comp-A, comp-B, of comp-C
@export var button_type: String = "COMPRESSOR" # COMPRESSOR, INPUT, of MASTER
@export var button_msg: String = "sc_ext_l"    # De naam uit je MixManager lijstje
@export var error_prefix: String = "BEHR-BTN" # [cite: 2026-02-04] English Error Code

@export_group("Visuals")
@export var color_on: Color = Color(1.0, 0.5, 0.0, 1.0)  # Orange
@export var color_off: Color = Color(0.1, 0.1, 0.1, 1.0) # Dark Grey

var is_on: bool = false
var is_windows = OS.get_name() == "Windows"

func _ready():
	# [cite: 2026-02-05] OS Check & Setup
	mouse_filter = Control.MOUSE_FILTER_STOP
	gui_input.connect(_on_gui_input)
	
	_load_initial_state()

func _load_initial_state():
	# We zoeken de status op in de nieuwe MixManager lades
	var section = "compressors" # Standaard voor jouw Behringers
	if button_type == "INPUT": section = "inputs"
	if button_type == "MASTER": section = "masters"
	
	# [CRASH-SAFE] Check of de data bestaat
	if MixManager.mixer_data.has(section) and MixManager.mixer_data[section].has(target_id):
		is_on = MixManager.mixer_data[section][target_id].get(button_msg.to_lower(), false)
	
	_update_visuals()

func _on_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		is_on = !is_on
		_update_visuals()
		_sync_to_mixmanager()

func _update_visuals():
	self.color = color_on if is_on else color_off
	
	if is_windows and is_on:
		print("[%s] %s %s is now ON" % [error_prefix, target_id, button_msg])

func _sync_to_mixmanager():
	# [cite: 2026-02-04] Gebruik de universele 4-argumenten aanroep
	# VAL is 1.0 voor aan, 0.0 voor uit (handig voor Go/Pipewire)
	var val = 1.0 if is_on else 0.0
	MixManager.process_action(target_id, button_type, button_msg.to_upper(), val)
