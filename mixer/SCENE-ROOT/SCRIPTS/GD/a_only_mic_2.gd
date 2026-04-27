extends Button

# --- [cite: 2026-02-10] Universal Settings via Inspector ---
@export_group("Button Config")
@export var target_id: String = "mix-in-2"  
@export var button_type: String = "INPUT"    # INPUT, MASTER, of WORKAROUND
@export var button_msg: String = "send_a"     # MUTE, COMP_ON, of SOLO

@export_group("Visuals")
@export var active_color: Color = Color(1.0, 0.2, 0.2) # Red
@export var inactive_color: Color = Color(1.0, 1.0, 1.0) # White

var is_active: bool = false
var error_prefix: String = "BTN-LOG"

func _ready():
	# [cite: 2026-02-04] English Error Prefix Generation
	error_prefix = "ERR-" + button_msg.to_upper() + "-" + target_id.to_upper()
	
	_load_initial_state()
	_update_visuals()

func _load_initial_state():
	# Map de button_type naar de juiste MixManager dictionary
	var section = "inputs"
	match button_type:
		"INPUT": section = "inputs"
		"MASTER": section = "masters"
		"WORKAROUND": section = "workarounds"
	
	# Crash-safe check voor de nieuwe data-structuur [cite: 2026-02-27]
	if MixManager.mixer_data.has(section) and MixManager.mixer_data[section].has(target_id):
		# We halen de waarde op (bool voor knoppen, float voor workarounds)
		var val = MixManager.mixer_data[section][target_id].get(button_msg.to_lower(), false)
		# Als het een float is (1.0/0.0), zet om naar bool
		is_active = bool(val) if typeof(val) == TYPE_FLOAT else val
	else:
		is_active = false

func _pressed():
	is_active = !is_active
	_update_visuals()
	
	# [cite: 2026-02-04] Universal call with English logging
	# We sturen 1.0 of 0.0 voor maximale compatibiliteit met de Go-backend
	var val = 1.0 if is_active else 0.0
	MixManager.process_action(target_id, button_type, button_msg.to_upper(), val)

func _update_visuals():
	modulate = active_color if is_active else inactive_color
	
	# [cite: 2026-02-05] OS Check for debug logs
	if OS.get_name() == "Windows":
		var state_text = "ENABLED" if is_active else "DISABLED"
		print("[%s] %s set to %s" % [error_prefix, target_id, state_text])
