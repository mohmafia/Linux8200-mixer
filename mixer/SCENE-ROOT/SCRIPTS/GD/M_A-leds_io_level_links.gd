extends Control

# --- CONFIGURATIE ---
@export_group("Protocol Ankers")
@export var my_id: String = "Master_A"
@export var is_right_channel: bool = false
@export var my_type: String = "IO_vumeter"
@export var my_msg: String = "IO_status"
@export var error_prefix: String = "ERR-IO-AUTO"

# --- VISUEEL ---
@export_group("Visueel")
@export var active_green: Color = Color(0.0, 2.0, 0.0, 1.0)
@export var active_yellow: Color = Color(2.0, 2.0, 0.0, 1.0)
@export var active_red: Color = Color(2.5, 0.0, 0.0, 1.0)
@export var inactive_color: Color = Color(0.51, 0.05, 0.05, 1.0)

# --- SYSTEEM ---
var leds = []
var is_windows = OS.get_name() == "Windows"
var my_side_suffix = "L"
var update_interval: float = 0.02 
var time_accumulator: float = 0.0

func _ready():
	my_side_suffix = "R" if is_right_channel else "L"
	error_prefix = "ERR-IO-" + my_id + "-" + my_side_suffix
	_initialize_leds()
	
	if Engine.has_meta("MixManager"):
		var manager = Engine.get_meta("MixManager")
		if manager.has_signal("vu_update"):
			manager.vu_update.connect(_on_vu_data_received)

func _initialize_leds():
	leds.clear()
	for child in get_children():
		if child is CanvasItem:
			leds.append(child)
	
	# Sorteer op Y (onder naar boven)
	leds.sort_custom(func(a, b): return a.position.y > b.position.y)

func _on_vu_data_received(incoming_id: String, incoming_type: String, incoming_msg: String, value: float):
	if incoming_id == my_id and incoming_type == my_type and incoming_msg == "lvl_" + my_side_suffix:
		_update_display(value)

func _update_display(val: float):
	var total = leds.size()
	# We gebruiken 'round' of we voegen een fractie toe om de laatste LED te halen
	var lit_count = int(val * total + 0.1) 
	# Zorg dat we nooit buiten de array schieten
	lit_count = clamp(lit_count, 0, total)
	
	for i in range(total):
		if i < lit_count:
			if i < 4:
				leds[i].modulate = active_green
			elif i < 6:
				leds[i].modulate = active_yellow
			else:
				leds[i].modulate = active_red
		else:
			leds[i].modulate = inactive_color

# --- WINDOWS SIMULATIE (Gecorrigeerd voor volledige uitslag) ---
func _process(delta):
	if is_windows and not Engine.has_meta("MixManager"):
		time_accumulator += delta
		if time_accumulator >= update_interval:
			var t = Time.get_ticks_msec() / 150.0
			var offset = 1.0 if is_right_channel else 0.0
			# We verhogen het bereik iets zodat hij vaker de 1.0 aantikt
			var mock_val = clamp(sin(t + offset) * 0.8 + 0.4, 0.0, 1.0)
			_update_display(mock_val)
			time_accumulator = 0.0
