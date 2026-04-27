extends Control

# --- CONFIGURATIE ---
@export_group("Protocol Ankers")
@export var my_id: String = "Master_B"
@export var my_type: String = "button_toggle"
@export var error_prefix: String = "ERR-MGR"

var is_windows = OS.get_name() == "Windows"

func _ready():
	error_prefix = "ERR-MGR-" + my_id

# De knop roept deze functie aan
func receive_button_signal(btn_id: String, is_on: bool):
	var val = 1.0 if is_on else 0.0
	_send_to_backend(btn_id, val)

func _send_to_backend(msg: String, value: float):
	if Engine.has_meta("MixManager"):
		var manager = Engine.get_meta("MixManager")
		manager.send_data(my_id, my_type, msg, value)
	
	if is_windows:
		print("[%s] Backend -> %s: %s = %f" % [error_prefix, my_id, msg, value])
