extends Control

# --- CONFIGURATIE (Protocol conform) ---
@export_group("Protocol Ankers")
@export var my_id: String = "Master_B"      
@export var is_right_channel: bool = false 
@export var my_type: String = "gate_meter" 
@export var my_msg: String = "gate_status" 
@export var error_prefix: String = "ERR-GATE-AUTO"

# --- VISUEEL (De 2 LEDs) ---
@export_group("Visueel")
@export var active_red: Color = Color(3.0, 0.0, 0.0, 1.0)   # Extra fel voor snelle flits
@export var active_green: Color = Color(0.0, 2.5, 0.0, 1.0) 
@export var inactive_color: Color = Color(0.02, 0.02, 0.02, 1.0) # Bijna uit

# --- SYSTEEM ---
var leds = []
var is_windows = OS.get_name() == "Windows"
var my_side_suffix = "L"
# Razendsnelle update interval (10ms)
var update_interval: float = 0.01 
var time_accumulator: float = 0.0

func _ready():
	my_side_suffix = "R" if is_right_channel else "L"
	error_prefix = "ERR-GATE-" + my_id + "-" + my_side_suffix
	
	_initialize_leds()
	
	if Engine.has_meta("MixManager"):
		var manager = Engine.get_meta("MixManager")
		if manager.has_signal("vu_update"):
			manager.vu_update.connect(_on_vu_data_received)
	
	if is_windows:
		print("[%s] Ultra-Fast Gate LEDs geladen." % error_prefix)

func _initialize_leds():
	leds.clear()
	for child in get_children():
		if child is CanvasItem:
			leds.append(child)
	
	# Sorteren op X (Links naar Rechts)
	# Index 0 = Rood (Threshold), Index 1 = Groen (Open)
	leds.sort_custom(func(a, b): return a.position.x < b.position.x)

func _on_vu_data_received(incoming_id: String, incoming_type: String, incoming_msg: String, value: float):
	# Directe check voor maximale snelheid
	if incoming_id == my_id and incoming_type == my_type and incoming_msg == my_msg + "_" + my_side_suffix:
		_update_gate_display(value)

func _update_gate_display(val: float):
	if leds.size() < 2: return
	
	# Harde schakeling (Binary)
	if val <= 0.5:
		leds[0].modulate = active_red
		leds[1].modulate = inactive_color
	else:
		leds[0].modulate = inactive_color
		leds[1].modulate = active_green

# --- ULTRA-FAST WINDOWS SIMULATIE ---
func _process(delta):
	if is_windows and not Engine.has_meta("MixManager"):
		time_accumulator += delta
		if time_accumulator >= update_interval:
			# We gebruiken een snelle blokgolf-simulatie (square wave)
			var t = Time.get_ticks_msec() / 100.0 # 10x sneller dan de vorige
			var mock_val = 1.0 if sin(t) > 0.0 else 0.0
			_update_gate_display(mock_val)
			time_accumulator = 0.0
